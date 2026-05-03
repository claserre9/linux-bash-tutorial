# Chapitre 11 — Réseau

La ligne de commande Linux offre un arsenal complet pour diagnostiquer des réseaux, consommer des APIs, transférer des fichiers et gérer des connexions distantes. Ce chapitre couvre tous les outils réseau essentiels, des plus simples (`ping`) aux plus avancés (`rsync`, tunnels SSH), et se conclut par un projet fil rouge.

---

## 1. `ping` — Tester la connectivité

```bash
# Ping basique
ping google.com

# Nombre de paquets limité (-c)
ping -c 4 google.com

# Intervalle entre paquets (-i, en secondes)
ping -c 10 -i 0.5 google.com    # Toutes les 0.5 secondes

# Timeout d'attente par paquet (-W)
ping -c 4 -W 2 192.168.1.1    # Attendre 2s max par paquet

# Ping silencieux pour scripts
if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    echo "Internet accessible"
else
    echo "Pas de connectivité"
fi

# Ping avec taille de paquet personnalisée
ping -s 1400 -c 4 google.com

# Ping vers une adresse IPv6
ping6 -c 4 ipv6.google.com

# Mesurer la latence
ping -c 100 8.8.8.8 | tail -1    # Statistiques min/avg/max
```

---

## 2. `curl` — Requêtes HTTP et transferts

### 2.1 Requêtes de base

```bash
# GET simple
curl https://api.github.com

# Afficher seulement les headers (-I = HEAD request)
curl -I https://example.com

# Afficher headers + body
curl -i https://example.com

# Mode silencieux (-s, supprime la barre de progression)
curl -s https://api.github.com/users/torvalds

# Suivre les redirections (-L)
curl -L http://github.com

# Timeout de connexion et de transfert
curl --connect-timeout 5 --max-time 30 https://example.com
```

### 2.2 Méthodes HTTP et données

```bash
# POST avec des données (-X POST -d)
curl -X POST https://api.exemple.com/users \
     -d "name=Alice&age=30"

# POST avec JSON (-H pour l'en-tête Content-Type, -d pour les données)
curl -X POST https://api.exemple.com/users \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice", "age": 30}'

# POST avec un fichier JSON (@)
curl -X POST https://api.exemple.com/users \
     -H "Content-Type: application/json" \
     -d @payload.json

# PUT
curl -X PUT https://api.exemple.com/users/1 \
     -H "Content-Type: application/json" \
     -d '{"name": "Alice Updated"}'

# DELETE
curl -X DELETE https://api.exemple.com/users/1

# PATCH
curl -X PATCH https://api.exemple.com/users/1 \
     -H "Content-Type: application/json" \
     -d '{"age": 31}'
```

### 2.3 En-têtes et authentification

```bash
# En-tête personnalisé (-H)
curl -H "Authorization: Bearer TOKEN123" \
     -H "Accept: application/json" \
     https://api.exemple.com/data

# Authentification Basic (-u)
curl -u "alice:motdepasse" https://api.exemple.com/admin

# Authentification Bearer dans un script
TOKEN="votre_token"
curl -s \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     https://api.exemple.com/resource

# User-Agent personnalisé
curl --user-agent "MonScript/1.0" https://example.com
curl -A "MonNavigateur" https://example.com

# Cookie
curl -b "session=abc123" https://example.com
curl -c cookies.txt -b cookies.txt https://example.com    # Sauvegarder/charger
```

### 2.4 Téléchargement de fichiers

```bash
# Sauvegarder dans un fichier (-o)
curl -o rapport.pdf https://example.com/rapport.pdf

# Garder le nom original (-O)
curl -O https://example.com/fichier.tar.gz

# Téléchargement avec barre de progression
curl -# -O https://example.com/gros_fichier.zip

# Reprendre un téléchargement interrompu (-C -)
curl -C - -O https://example.com/gros_fichier.zip

# Télécharger plusieurs fichiers
curl -O https://example.com/file1.txt -O https://example.com/file2.txt

# Limiter la vitesse (en octets/s)
curl --limit-rate 100K -O https://example.com/fichier.zip
```

### 2.5 Consommer une API JSON

```bash
#!/usr/bin/env bash

# Requête API avec traitement jq
API_URL="https://jsonplaceholder.typicode.com"

# Récupérer un utilisateur
utilisateur=$(curl -s "$API_URL/users/1")
echo "Nom : $(echo "$utilisateur" | jq -r '.name')"
echo "Email : $(echo "$utilisateur" | jq -r '.email')"

# Lister les titres des posts
curl -s "$API_URL/posts" | jq -r '.[].title' | head -5

# Créer un post
reponse=$(curl -s -X POST "$API_URL/posts" \
    -H "Content-Type: application/json" \
    -d '{"title":"Mon titre","body":"Mon contenu","userId":1}')

nouveau_id=$(echo "$reponse" | jq -r '.id')
echo "Post créé avec l'ID : $nouveau_id"

# Vérifier le code HTTP
code_http=$(curl -s -o /dev/null -w "%{http_code}" https://example.com)
if [[ "$code_http" == "200" ]]; then
    echo "Site accessible"
elif [[ "$code_http" == "404" ]]; then
    echo "Page introuvable"
else
    echo "Code HTTP : $code_http"
fi
```

> **Astuce pro** : Utilisez `curl -s -o /dev/null -w "%{http_code}"` pour récupérer uniquement le code de statut HTTP dans vos scripts de monitoring.

---

## 3. `wget` — Téléchargement web

```bash
# Téléchargement simple
wget https://example.com/fichier.tar.gz

# Mode silencieux (-q)
wget -q https://example.com/fichier.tar.gz

# Nom de fichier personnalisé (-O)
wget -O monnom.tar.gz https://example.com/archive-v1.2.3.tar.gz

# Téléchargement récursif d'un site (-r)
wget -r -l 2 https://example.com    # -l 2 = profondeur 2

# Limiter la vitesse
wget --limit-rate=500k https://example.com/gros_fichier.iso

# Reprendre un téléchargement (-c pour continue)
wget -c https://example.com/gros_fichier.iso

# Télécharger en arrière-plan (-b)
wget -b https://example.com/fichier.tar.gz

# Wget avec authentification
wget --user=alice --password=secret https://ftp.exemple.com/fichier

# Télécharger une liste de fichiers
wget -i liste_urls.txt

# User-agent personnalisé
wget --user-agent="Mozilla/5.0" https://example.com
```

---

## 4. `ssh` — Connexions sécurisées

### 4.1 Connexion de base

```bash
# Connexion SSH
ssh user@serveur.exemple.com

# Port spécifique (-p)
ssh -p 2222 user@serveur.exemple.com

# Avec une clé spécifique (-i)
ssh -i ~/.ssh/ma_cle_privee user@serveur.exemple.com

# Exécuter une commande distante
ssh user@serveur.exemple.com "ls -la /var/log"
ssh user@serveur.exemple.com "df -h && free -h"

# Exécuter un script local sur un serveur distant
ssh user@serveur.exemple.com < script_local.sh

# Connexion avec vérification désactivée (test uniquement !)
ssh -o StrictHostKeyChecking=no user@serveur
```

### 4.2 Gestion des clés SSH

```bash
# Générer une paire de clés (Ed25519, recommandé)
ssh-keygen -t ed25519 -C "alice@exemple.com"

# Générer une clé RSA 4096 bits (compatibilité maximale)
ssh-keygen -t rsa -b 4096 -C "alice@exemple.com"

# Copier la clé publique sur un serveur
ssh-copy-id user@serveur.exemple.com
ssh-copy-id -i ~/.ssh/ma_cle.pub user@serveur.exemple.com

# Manuellement
cat ~/.ssh/id_ed25519.pub | ssh user@serveur "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Agent SSH (évite de retaper la passphrase)
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l    # Lister les clés chargées
```

### 4.3 Tunnels SSH

```bash
# Tunnel local (-L) : accéder à un port distant via un port local
# Accéder à la base de données distante (port 5432) via localhost:15432
ssh -L 15432:localhost:5432 user@serveur.exemple.com

# En arrière-plan (-f -N)
ssh -f -N -L 15432:localhost:5432 user@serveur.exemple.com
# -f : passer en arrière-plan
# -N : ne pas exécuter de commande (juste le tunnel)

# Accéder à un service dans un réseau privé via le serveur
# (bastion host)
ssh -L 8080:serveur-interne:80 user@bastion.exemple.com

# Tunnel distant (-R) : exposer un port local sur le serveur
# Exposer le port local 3000 en tant que port 8080 sur le serveur
ssh -R 8080:localhost:3000 user@serveur.exemple.com

# Proxy SOCKS (-D) : faire passer tout le trafic par le serveur
ssh -D 1080 user@serveur.exemple.com
# Configurer le navigateur pour utiliser le proxy SOCKS sur localhost:1080

# ProxyJump (-J) : rebondir via un bastion
ssh -J user@bastion.exemple.com user@serveur-interne.local
```

### 4.4 Configuration `~/.ssh/config`

```
# ~/.ssh/config

# Configuration globale
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes

# Serveur de développement
Host dev
    HostName dev.exemple.com
    User alice
    IdentityFile ~/.ssh/id_ed25519
    Port 2222

# Connexion via bastion
Host serveur-prod
    HostName 10.0.1.50
    User deploy
    IdentityFile ~/.ssh/prod_key
    ProxyJump alice@bastion.exemple.com

# Groupe de serveurs
Host *.staging.exemple.com
    User deploy
    IdentityFile ~/.ssh/staging_key
```

```bash
# Utilisation avec la config
ssh dev                    # Se connecte à dev.exemple.com
ssh serveur-prod           # Via le bastion automatiquement
```

---

## 5. `scp` et `rsync` — Transfert de fichiers

### 5.1 `scp` — Copie sécurisée simple

```bash
# Copier un fichier local vers un serveur distant
scp fichier.txt user@serveur:/home/user/

# Copier un fichier distant vers local
scp user@serveur:/var/log/app.log /tmp/

# Copier récursivement un répertoire (-r)
scp -r /local/repertoire user@serveur:/remote/

# Avec un port spécifique (-P)
scp -P 2222 fichier.txt user@serveur:/tmp/

# Avec une clé spécifique (-i)
scp -i ~/.ssh/ma_cle fichier.txt user@serveur:/tmp/

# Entre deux serveurs distants
scp user1@serveur1:/fichier.txt user2@serveur2:/destination/
```

### 5.2 `rsync` — Synchronisation efficace

```bash
# Synchronisation de base (-avz)
# -a : archive (préserve permissions, dates, liens symboliques)
# -v : verbose
# -z : compression pendant le transfert
rsync -avz /source/ /destination/

# IMPORTANT : le slash final dans la source
rsync -av /source/   /dest/    # Contenu de source → dans dest
rsync -av /source    /dest/    # Répertoire source entier → dans dest/source/

# Synchronisation avec un serveur distant
rsync -avz /local/repertoire/ user@serveur:/remote/repertoire/

# Suppression des fichiers disparus de la source (--delete)
rsync -avz --delete /source/ user@serveur:/destination/

# Exclure des fichiers (--exclude)
rsync -avz --exclude="*.log" --exclude=".git" /source/ /dest/

# Exclure depuis un fichier (--exclude-from)
rsync -avz --exclude-from=.rsyncignore /source/ /dest/

# Afficher la progression (--progress)
rsync -avz --progress /source/ /dest/

# Tester sans modifier (--dry-run / -n)
rsync -avz --dry-run --delete /source/ user@serveur:/dest/

# Limiter la bande passante (en Ko/s)
rsync -avz --bwlimit=500 /source/ /dest/

# Synchroniser seulement si fichier plus récent
rsync -avzu /source/ /dest/    # -u = update (skip newer)

# Backup incrémental avec lien dur (--link-dest)
rsync -avz --link-dest=/backup/last /source/ /backup/$(date +%Y%m%d)/

# Avec port SSH spécifique
rsync -avz -e "ssh -p 2222" /source/ user@serveur:/dest/
```

> **Piège courant** : Le slash `/` final après la source change radicalement le comportement de rsync. `rsync src/ dest/` copie le *contenu* de `src` dans `dest`, tandis que `rsync src dest/` crée `dest/src/`. Testez toujours avec `--dry-run`.

---

## 6. Outils DNS

```bash
# dig — outil DNS complet (recommandé)
dig example.com                    # Enregistrement A (IPv4)
dig example.com AAAA               # Enregistrement AAAA (IPv6)
dig example.com MX                 # Serveurs de mail
dig example.com NS                 # Serveurs de noms
dig example.com TXT                # Enregistrements TXT
dig example.com CNAME              # Alias

# Sortie courte (+short)
dig +short example.com
dig +short google.com MX

# Requête vers un serveur DNS spécifique (@)
dig @8.8.8.8 example.com           # Utiliser le DNS de Google
dig @1.1.1.1 example.com           # Utiliser le DNS de Cloudflare

# Résolution inverse (IP → nom)
dig -x 8.8.8.8
dig -x 142.250.185.46

# Trace le chemin de résolution
dig +trace example.com

# nslookup — alternative interactive
nslookup example.com
nslookup example.com 8.8.8.8    # Utiliser DNS spécifique

# host — outil simple
host example.com
host -t MX example.com           # Enregistrements MX
host 8.8.8.8                     # Résolution inverse
```

---

## 7. `ss` et `netstat` — Connexions réseau actives

```bash
# ss — outil moderne (recommandé, remplace netstat)

# Toutes les connexions TCP (-t) et UDP (-u) en écoute (-l) avec numéros (-n)
ss -tuln

# Toutes les connexions établies
ss -tn state established

# Avec le nom du processus (-p)
ss -tulnp

# Sockets UNIX
ss -x

# Filtrer par port
ss -tn sport = :80
ss -tn dport = :443

# Filtrer par état
ss -t state time-wait

# netstat — plus disponible sur tous les systèmes
netstat -tuln    # En écoute
netstat -tnp     # Avec processus (root)
netstat -rn      # Table de routage

# Statistiques réseau
ss -s            # Résumé des statistiques
netstat -s       # Statistiques détaillées par protocole
```

---

## 8. `ip` — Gestion des interfaces réseau

```bash
# ip remplace ifconfig et route (déprécié)

# Afficher les adresses IP
ip addr show
ip addr show eth0       # Interface spécifique
ip a                    # Forme courte

# Afficher les routes
ip route show
ip route show default   # Route par défaut
ip r                    # Forme courte

# Afficher les interfaces
ip link show
ip l                    # Forme courte

# Ajouter une adresse IP (temporaire)
sudo ip addr add 192.168.1.100/24 dev eth0

# Supprimer une adresse IP
sudo ip addr del 192.168.1.100/24 dev eth0

# Activer/désactiver une interface
sudo ip link set eth0 up
sudo ip link set eth0 down

# Ajouter une route statique
sudo ip route add 10.0.0.0/8 via 192.168.1.1

# Table ARP (voisins)
ip neigh show
ip n

# Statistiques de l'interface
ip -s link show eth0
```

---

## 9. `nc` (netcat) — Couteau suisse TCP/UDP

```bash
# Tester la connectivité à un port
nc -zv 192.168.1.1 80      # -z = scan, -v = verbose
nc -zv example.com 443

# Tester plusieurs ports
nc -zv example.com 80 443 8080

# Scanner une plage de ports (avec timeout)
nc -zv -w 1 example.com 20-100

# Écouter sur un port (serveur simple)
nc -l 8080

# Connexion simple (client)
nc example.com 80

# Transfert de fichier
# Côté récepteur :
nc -l 9999 > fichier_recu.txt
# Côté émetteur :
nc recepteur.exemple.com 9999 < fichier_a_envoyer.txt

# Test de service HTTP simple
echo -e "GET / HTTP/1.0\r\nHost: example.com\r\n\r\n" | nc example.com 80

# Chat simple entre deux terminaux
# Terminal 1 (serveur) :
nc -l 1234
# Terminal 2 (client) :
nc localhost 1234

# Vérification de port UDP
nc -zu -w 1 serveur.exemple.com 53    # DNS
```

---

## 10. Configuration réseau système

### 10.1 `/etc/hosts`

```bash
# Afficher le fichier hosts
cat /etc/hosts

# Résolution locale — /etc/hosts est consulté avant le DNS
# Format : IP    nom_de_domaine    [alias...]

# Exemples d'entrées utiles
# 127.0.0.1    localhost
# ::1          localhost ip6-localhost
# 192.168.1.10 serveur-dev dev
# 10.0.0.1     bastion.interne

# Bloquer un domaine (pointer vers localhost)
# 0.0.0.0    tracking.exemple.com

# Modifier /etc/hosts (nécessite root)
sudo bash -c 'echo "192.168.1.50 mon-serveur" >> /etc/hosts'

# Tester la résolution locale
ping mon-serveur
getent hosts mon-serveur
```

### 10.2 `/etc/resolv.conf`

```bash
# Configuration des serveurs DNS
cat /etc/resolv.conf

# Contenu typique :
# nameserver 8.8.8.8
# nameserver 8.8.4.4
# search exemple.com local.exemple.com
# options ndots:5

# ATTENTION : Ce fichier est souvent géré automatiquement
# (par systemd-resolved, NetworkManager, etc.)
# Sur Ubuntu moderne, c'est un lien symbolique :
ls -la /etc/resolv.conf

# Voir les serveurs DNS actifs (systemd-resolved)
resolvectl status
systemd-resolve --status

# Vider le cache DNS
sudo systemd-resolve --flush-caches
sudo resolvectl flush-caches
```

---

## 11. Projet fil rouge niveau 2 — Analyseur de logs Apache/Nginx

Ce script analyse des fichiers de logs de serveur web, extrait les statistiques importantes et génère un rapport lisible.

```bash
#!/usr/bin/env bash
# =============================================================================
# log_analyser.sh — Analyseur de logs Apache/Nginx
# Usage: ./log_analyser.sh [-f fichier_log] [-n top_n] [-o rapport.txt] [-v]
# =============================================================================

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly DATE_RAPPORT="$(date '+%Y-%m-%d %H:%M:%S')"

# --- Couleurs et logging
ROUGE='\033[0;31m'; VERT='\033[0;32m'; JAUNE='\033[1;33m'
BLEU='\033[0;34m'; GRAS='\033[1m'; RESET='\033[0m'

log_info()  { printf "${VERT}[INFO]${RESET}  %s\n" "$*"; }
log_error() { printf "${ROUGE}[ERROR]${RESET} %s\n" "$*" >&2; }
log_titre() { printf "\n${GRAS}${BLEU}%s${RESET}\n" "$*"; printf '%0.s─' {1..60}; echo; }

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [-f fichier_log] [-n N] [-o sortie] [-v] [-h]

Options:
    -f FICHIER  Fichier de log à analyser (défaut: /var/log/nginx/access.log)
    -n N        Afficher le top N résultats (défaut: 10)
    -o FICHIER  Sauvegarder le rapport dans un fichier
    -v          Mode verbose
    -h          Afficher cette aide

Format de log supporté (Combined Log Format) :
    IP - - [date] "METHOD /path HTTP/1.1" STATUS bytes "referer" "user-agent"
EOF
}

# Vérifie si le fichier de log existe et est lisible
verifier_log() {
    local fichier="$1"
    if [[ ! -f "$fichier" ]]; then
        log_error "Fichier introuvable : $fichier"
        exit 1
    fi
    if [[ ! -r "$fichier" ]]; then
        log_error "Fichier non lisible : $fichier"
        exit 1
    fi
}

# Compte le nombre total de requêtes
compter_requetes() {
    local fichier="$1"
    wc -l < "$fichier"
}

# Extraire et afficher le top N des IPs
top_ips() {
    local fichier="$1"
    local n="$2"
    log_titre "Top $n des adresses IP"
    awk '{print $1}' "$fichier" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -"$n" \
        | awk '{printf "  %-6d requêtes  %s\n", $1, $2}'
}

# Distribution des codes HTTP
codes_http() {
    local fichier="$1"
    log_titre "Distribution des codes HTTP"
    awk '{print $9}' "$fichier" \
        | grep -E '^[0-9]{3}$' \
        | sort \
        | uniq -c \
        | sort -rn \
        | awk '{
            code=$2
            if (code ~ /^2/) couleur="\033[0;32m"
            else if (code ~ /^3/) couleur="\033[0;34m"
            else if (code ~ /^4/) couleur="\033[1;33m"
            else couleur="\033[0;31m"
            printf "  %s%s\033[0m : %d requêtes\n", couleur, code, $1
          }'
}

# Top N des URLs les plus visitées
top_urls() {
    local fichier="$1"
    local n="$2"
    log_titre "Top $n des URLs"
    awk '{print $7}' "$fichier" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -"$n" \
        | awk '{printf "  %-6d  %s\n", $1, $2}'
}

# Requêtes par heure (analyse temporelle)
requetes_par_heure() {
    local fichier="$1"
    log_titre "Répartition par heure"
    awk '{
        # Format : [02/Jan/2024:14:32:21 +0000]
        match($4, /:[0-9]{2}:/)
        heure = substr($4, RSTART+1, 2)
        heures[heure]++
    }
    END {
        for (h in heures) printf "  %sh : %d requêtes\n", h, heures[h]
    }' "$fichier" | sort
}

# IPs avec le plus d'erreurs 4xx
top_erreurs_clients() {
    local fichier="$1"
    local n="$2"
    log_titre "Top $n des IPs avec des erreurs 4xx"
    awk '$9 ~ /^4[0-9][0-9]$/ {print $1}' "$fichier" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -"$n" \
        | awk '{printf "  %-6d erreurs  %s\n", $1, $2}'
}

# User-agents les plus courants
top_user_agents() {
    local fichier="$1"
    local n="$2"
    log_titre "Top $n des User-Agents"
    # Le user-agent est le dernier champ entre guillemets
    awk -F'"' '{print $6}' "$fichier" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -"$n" \
        | awk '{
            ua = ""
            for (i=2; i<=NF; i++) ua = ua " " $i
            printf "  %-6d  %s\n", $1, substr(ua, 1, 60)
          }'
}

# Générer le rapport complet
generer_rapport() {
    local fichier="$1"
    local top_n="$2"
    local total

    total=$(compter_requetes "$fichier")

    echo ""
    printf "${GRAS}╔══════════════════════════════════════════════════════════╗${RESET}\n"
    printf "${GRAS}║         RAPPORT D'ANALYSE DES LOGS WEB                  ║${RESET}\n"
    printf "${GRAS}╚══════════════════════════════════════════════════════════╝${RESET}\n"
    echo ""
    printf "  Fichier   : %s\n" "$fichier"
    printf "  Date      : %s\n" "$DATE_RAPPORT"
    printf "  Total     : %s requêtes\n" "$total"
    echo ""

    top_ips "$fichier" "$top_n"
    codes_http "$fichier"
    top_urls "$fichier" "$top_n"
    requetes_par_heure "$fichier"
    top_erreurs_clients "$fichier" "$top_n"
    top_user_agents "$fichier" "$top_n"

    echo ""
    log_info "Analyse terminée."
}

# --- Parsing des options
LOG_FILE="/var/log/nginx/access.log"
TOP_N=10
OUTPUT_FILE=""
VERBOSE=false

while getopts "f:n:o:vh" opt; do
    case "$opt" in
        f) LOG_FILE="$OPTARG" ;;
        n) TOP_N="$OPTARG" ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        v) VERBOSE=true ;;
        h) usage; exit 0 ;;
        \?) log_error "Option invalide : -$OPTARG"; usage; exit 1 ;;
        :)  log_error "L'option -$OPTARG requiert un argument"; exit 1 ;;
    esac
done

# --- Exécution principale
verifier_log "$LOG_FILE"

$VERBOSE && log_info "Analyse du fichier : $LOG_FILE (top $TOP_N)"

if [[ -n "$OUTPUT_FILE" ]]; then
    # Rediriger vers le fichier tout en affichant dans le terminal
    generer_rapport "$LOG_FILE" "$TOP_N" | tee "$OUTPUT_FILE"
    log_info "Rapport sauvegardé dans : $OUTPUT_FILE"
else
    generer_rapport "$LOG_FILE" "$TOP_N"
fi
```

### Tester avec un fichier de log d'exemple

```bash
# Générer un fichier de log de test
cat > /tmp/access_test.log << 'EOF'
192.168.1.10 - - [02/May/2024:10:00:01 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
192.168.1.20 - - [02/May/2024:10:00:02 +0000] "POST /api/login HTTP/1.1" 200 567 "-" "curl/7.68.0"
192.168.1.10 - - [02/May/2024:10:00:05 +0000] "GET /api/users HTTP/1.1" 403 89 "-" "Mozilla/5.0"
10.0.0.1 - - [02/May/2024:10:00:10 +0000] "GET /admin HTTP/1.1" 404 123 "-" "python-requests/2.28"
192.168.1.10 - - [02/May/2024:10:01:00 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
192.168.1.30 - - [02/May/2024:11:00:01 +0000] "GET /static/app.js HTTP/1.1" 200 45678 "-" "Mozilla/5.0"
10.0.0.1 - - [02/May/2024:11:30:00 +0000] "GET /wp-login.php HTTP/1.1" 404 123 "-" "python-requests/2.28"
10.0.0.1 - - [02/May/2024:11:30:01 +0000] "POST /xmlrpc.php HTTP/1.1" 404 89 "-" "python-requests/2.28"
EOF

# Analyser le fichier de test
./log_analyser.sh -f /tmp/access_test.log -n 5 -v

# Sauvegarder le rapport
./log_analyser.sh -f /tmp/access_test.log -o /tmp/rapport.txt
```

---

## Tableau récapitulatif

| Outil | Usage | Options clés |
|-------|-------|--------------|
| `ping` | Tester connectivité | `-c` nombre, `-i` intervalle, `-W` timeout |
| `curl` | Requêtes HTTP | `-X` méthode, `-H` header, `-d` data, `-o` fichier, `-L` redirections |
| `wget` | Téléchargement | `-q` silencieux, `-O` nom, `-r` récursif, `-c` reprise |
| `ssh` | Connexion distante | `-i` clé, `-p` port, `-L/-R/-D` tunnels, `-J` ProxyJump |
| `scp` | Copie sécurisée | `-r` récursif, `-P` port, `-i` clé |
| `rsync` | Synchronisation | `-avz`, `--delete`, `--exclude`, `--dry-run`, `--progress` |
| `dig` | Requêtes DNS | `+short`, `@serveur`, `-x` inverse, `+trace` |
| `ss` | Connexions réseau | `-tuln` écoute, `-p` processus |
| `ip` | Interfaces réseau | `addr`, `route`, `link` |
| `nc` | Test TCP/UDP | `-z` scan, `-l` écoute, `-w` timeout |

---

## À retenir

- **`curl -s -o /dev/null -w "%{http_code}"`** est le pattern de référence pour le monitoring HTTP dans les scripts.
- **`rsync --dry-run`** avant toute synchronisation avec `--delete` — une erreur peut être irréversible.
- Le **slash final dans `rsync`** change complètement le comportement : testez toujours avant.
- Les **tunnels SSH** (`-L`, `-R`, `-D`) sont des outils puissants pour accéder à des services derrière des pare-feux.
- Configurez **`~/.ssh/config`** pour simplifier vos connexions répétitives.
- **`dig +short`** est l'outil le plus rapide pour vérifier la résolution DNS depuis un script.
- Pour les logs Apache/Nginx, `awk` + `sort` + `uniq -c` est la combinaison la plus efficace pour extraire des statistiques.

➡️ [Chapitre 12 — Regex avancées](../12_regex_avancees/README.md)
