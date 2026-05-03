#!/usr/bin/env bash
# Solutions — Chapitre 11 : Réseau

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Solution 11.1 — ping et connectivité ==="

    tester_connectivite() {
        local hors_ligne=0

        for host in "$@"; do
            # ping -c 2 : envoyer 2 paquets
            # ping -W 3 : timeout de 3 secondes par paquet
            # > /dev/null 2>&1 : ignorer la sortie, juste le code de retour
            if ping -c 2 -W 3 "$host" > /dev/null 2>&1; then
                printf "  %-20s → ✓ OK\n" "$host"
            else
                printf "  %-20s → ✗ HORS LIGNE\n" "$host"
                (( hors_ligne++ ))
            fi
        done

        return "$hors_ligne"
    }

    echo "Test de connectivité :"
    tester_connectivite 8.8.8.8 1.1.1.1 192.168.99.254 || true
    local nb_hors_ligne=$?
    echo "Hôtes injoignables : $nb_hors_ligne"

    echo ""
    echo "Points clés :"
    echo "  - ping -c N : nombre de paquets (évite le ping infini)"
    echo "  - ping -W N : timeout en secondes (important pour les scripts)"
    echo "  - > /dev/null 2>&1 : ignorer stdout ET stderr"
    echo "  - if ping ...; then : utiliser directement comme condition"
    echo "  - return \$hors_ligne : retourner le nombre d'hôtes KO"
}

ex_2() {
    echo ""
    echo "=== Solution 11.2 — curl et API ==="

    API="https://jsonplaceholder.typicode.com"

    echo "1) Utilisateur ID 3 :"
    if command -v curl &>/dev/null; then
        local data
        data=$(curl -s --max-time 5 "$API/users/3" 2>/dev/null)

        if [[ -n "$data" ]]; then
            if command -v jq &>/dev/null; then
                # jq est disponible — extraction propre
                echo "Nom   : $(echo "$data" | jq -r '.name')"
                echo "Email : $(echo "$data" | jq -r '.email')"
                echo "Ville : $(echo "$data" | jq -r '.address.city')"
            else
                # Sans jq — utiliser grep + sed
                echo "Nom   : $(echo "$data" | grep '"name"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')"
                echo "Email : $(echo "$data" | grep '"email"' | sed 's/.*: *"\([^"]*\)".*/\1/')"
            fi
        else
            echo "(Connexion indisponible — résultat de référence : Clementine Bauch)"
        fi
    fi

    echo ""
    echo "2) Codes HTTP de plusieurs URLs :"
    declare -a urls=(
        "https://jsonplaceholder.typicode.com/posts/1"
        "https://jsonplaceholder.typicode.com/posts/999"
    )

    for url in "${urls[@]}"; do
        # -s : silencieux (pas de barre de progression)
        # -o /dev/null : ignorer le corps de la réponse
        # -w "%{http_code}" : n'afficher que le code HTTP
        # --max-time 5 : timeout global de 5 secondes
        if command -v curl &>/dev/null; then
            local code
            code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
            printf "  %-50s → %s\n" "$url" "${code:-timeout}"
        fi
    done

    echo ""
    echo "Points clés :"
    echo "  - curl -s : mode silencieux (supprime la barre de progression)"
    echo "  - curl -o /dev/null : ignorer le corps de la réponse"
    echo "  - curl -w '%{http_code}' : afficher seulement le code HTTP"
    echo "  - --max-time N : timeout global (connexion + transfert)"
    echo "  - --connect-timeout N : timeout de connexion seulement"
    echo "  - jq -r '.champ' : extraire un champ JSON (raw, sans guillemets)"
}

ex_3() {
    echo ""
    echo "=== Solution 11.3 — SSH et configuration ==="

    echo "1) Entrée ~/.ssh/config pour le serveur 'prod' :"
    cat << 'EOF'
Host prod
    HostName prod.exemple.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_prod
    ServerAliveInterval 30
    ServerAliveCountMax 3
EOF

    echo ""
    echo "Utilisation : ssh prod  (au lieu de ssh -i ~/.ssh/id_prod -p 2222 deploy@prod.exemple.com)"

    echo ""
    echo "2) Explications des commandes SSH :"
    cat << 'EOF'
a) ssh -L 8080:localhost:80 user@serveur
   → Tunnel LOCAL : redirige localhost:8080 (votre machine) vers localhost:80 du serveur.
     Cas d'usage : accéder à une interface web interne du serveur depuis votre navigateur.
     Exemple : curl http://localhost:8080 → requête vers le port 80 du serveur distant.

b) ssh -R 9090:localhost:3000 user@serveur
   → Tunnel DISTANT : expose votre localhost:3000 comme port 9090 SUR le serveur.
     Cas d'usage : permettre au serveur d'accéder à votre application de développement local.
     Exemple : depuis le serveur, curl http://localhost:9090 → votre app locale sur 3000.

c) ssh -J bastion.example.com user@serveur-interne
   → ProxyJump : se connecte à 'bastion' puis rebondit vers 'serveur-interne'.
     Équivalent de l'ancien ProxyCommand : ssh -o ProxyCommand="ssh bastion.example.com -W %h:%p"
     Cas d'usage : accéder à des serveurs dans un réseau privé via un bastion exposé.
     Peut chaîner plusieurs bastions : -J bastion1,bastion2
EOF

    echo ""
    echo "Points clés supplémentaires :"
    echo "  - ssh -f -N -L ... : tunnel en arrière-plan sans shell"
    echo "  - ssh -D 1080 host : proxy SOCKS pour tout le trafic"
    echo "  - ~/.ssh/config : centralise la configuration, évite les options longues"
    echo "  - AddKeysToAgent yes : ajoute auto les clés à l'agent ssh"
}

ex_4() {
    echo ""
    echo "=== Solution 11.4 — rsync ==="

    local src="/tmp/rsync_src_$$"
    local dst="/tmp/rsync_dst_$$"

    mkdir -p "$src/sous_dossier"
    echo "fichier1" > "$src/fichier1.txt"
    echo "fichier2" > "$src/fichier2.txt"
    echo "sous" > "$src/sous_dossier/fichier3.txt"
    echo "log content" > "$src/debug.log"
    mkdir -p "$dst"

    local src_base
    src_base=$(basename "$src")

    echo "1) AVEC slash final → copie le CONTENU de src dans dst/avec_slash/"
    rsync -a "$src/" "$dst/avec_slash/" 2>/dev/null
    echo "Fichiers créés :"
    find "$dst/avec_slash" -type f | sort | sed "s|$dst/||"
    # Le contenu de src est directement dans avec_slash/

    echo ""
    echo "2) SANS slash final → copie le DOSSIER src dans dst/sans_slash/"
    rsync -a "$src" "$dst/sans_slash/" 2>/dev/null
    echo "Fichiers créés :"
    find "$dst/sans_slash" -type f | sort | sed "s|$dst/||"
    # Un sous-dossier portant le nom de src est créé dans sans_slash/

    echo ""
    echo "DIFFÉRENCE CLÉ :"
    echo "  rsync src/  dst/  → contenu de src va dans dst"
    echo "  rsync src   dst/  → le dossier src lui-même va dans dst (crée dst/src/)"

    echo ""
    echo "3) Exclusion des fichiers .log :"
    rsync -a --exclude="*.log" "$src/" "$dst/sans_logs/" 2>/dev/null
    echo "Fichiers copiés (sans .log) :"
    find "$dst/sans_logs" -type f | sort | sed "s|$dst/||"

    echo ""
    echo "4) Dry-run — simulation de --delete :"
    # Créer un fichier dans dst qui n'est pas dans src
    mkdir -p "$dst/avec_slash"
    echo "à supprimer" > "$dst/avec_slash/fichier_orphelin.txt"
    echo "Simulation (--dry-run --delete) — fichiers qui seraient supprimés :"
    rsync -av --dry-run --delete "$src/" "$dst/avec_slash/" 2>/dev/null | grep "^deleting" || echo "(aucune suppression simulée)"

    # Nettoyage
    rm -rf "$src" "$dst"
    echo ""
    echo "Nettoyage effectué"

    echo ""
    echo "Points clés :"
    echo "  - -a (--archive) : préserve permissions, dates, liens sym, récursif"
    echo "  - -v : verbose (affiche les fichiers copiés)"
    echo "  - -z : compression pendant le transfert (utile sur réseau lent)"
    echo "  - --delete : supprime les fichiers de dst absents de src"
    echo "  - --exclude : exclure des patterns de fichiers"
    echo "  - --dry-run / -n : simuler sans modifier"
    echo "  - --progress : afficher la progression fichier par fichier"
    echo "  - TOUJOURS tester avec --dry-run avant --delete !"
}

ex_5() {
    echo ""
    echo "=== Solution 11.5 — Analyseur de logs ==="

    local logfile="/tmp/access_test_$$.log"
    cat > "$logfile" << 'EOF'
192.168.1.10 - - [02/May/2024:10:00:01 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
192.168.1.20 - - [02/May/2024:10:00:02 +0000] "POST /api/login HTTP/1.1" 200 567 "-" "curl/7.68.0"
192.168.1.10 - - [02/May/2024:10:00:05 +0000] "GET /api/users HTTP/1.1" 403 89 "-" "Mozilla/5.0"
10.0.0.1 - - [02/May/2024:10:00:10 +0000] "GET /admin HTTP/1.1" 404 123 "-" "python-requests/2.28"
192.168.1.10 - - [02/May/2024:10:01:00 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
192.168.1.30 - - [02/May/2024:11:00:01 +0000] "GET /static/app.js HTTP/1.1" 200 45678 "-" "Mozilla/5.0"
10.0.0.1 - - [02/May/2024:11:30:00 +0000] "GET /wp-login.php HTTP/1.1" 404 123 "-" "python-requests/2.28"
10.0.0.1 - - [02/May/2024:11:30:01 +0000] "POST /xmlrpc.php HTTP/1.1" 404 89 "-" "python-requests/2.28"
192.168.1.20 - - [02/May/2024:12:00:00 +0000] "GET /dashboard HTTP/1.1" 200 3456 "-" "Mozilla/5.0"
192.168.1.10 - - [02/May/2024:14:00:00 +0000] "DELETE /api/users/5 HTTP/1.1" 403 45 "-" "curl/7.68.0"
EOF

    echo "Analyse du fichier : $logfile"
    echo ""

    echo "1) Nombre total de requêtes :"
    echo "   $(wc -l < "$logfile") requêtes"

    echo ""
    echo "2) Top 3 des adresses IP :"
    awk '{print $1}' "$logfile" \
        | sort \
        | uniq -c \
        | sort -rn \
        | head -3 \
        | awk '{printf "   %-6d requêtes : %s\n", $1, $2}'

    echo ""
    echo "3) Distribution des codes HTTP :"
    awk '{print $9}' "$logfile" \
        | sort \
        | uniq -c \
        | sort -rn \
        | awk '{printf "   HTTP %s : %d requête(s)\n", $2, $1}'

    echo ""
    echo "4) Requêtes avec erreur 4xx (IP, URL, code) :"
    awk '$9 ~ /^4[0-9][0-9]$/ {printf "   %-16s %-25s %s\n", $1, $7, $9}' "$logfile"

    echo ""
    echo "5) Total octets transférés :"
    awk '{sum += $10} END {printf "   %d octets (%.2f Ko)\n", sum, sum/1024}' "$logfile"

    echo ""
    echo "Bonus — Requêtes par heure :"
    awk '{
        match($4, /:[0-9]{2}:/)
        h = substr($4, RSTART+1, 2)
        heures[h]++
    }
    END {
        for (h in heures) printf "   %sh00 : %d requête(s)\n", h, heures[h]
    }' "$logfile" | sort

    rm -f "$logfile"
    echo ""
    echo "Points clés :"
    echo "  - \$9 = code HTTP dans le Combined Log Format Apache/Nginx"
    echo "  - \$10 = nombre d'octets transférés"
    echo "  - \$4 = timestamp [DD/Mon/YYYY:HH:MM:SS +ZONE]"
    echo "  - awk '{sum += \$10} END{print sum}' : accumulation simple"
    echo "  - match(\$4, /regex/) + substr : extraction de sous-chaîne"
    echo "  - Le projet complet (log_analyser.sh) est dans le cours ch.11"
}

main
