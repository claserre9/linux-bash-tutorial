# Chapitre 5 — Flux, redirections et pipes

Le principe "tout est fichier" d'Unix se manifeste dans les flux : chaque programme communique via des descripteurs de fichiers standard. Maîtriser les redirections et les pipes, c'est composer des outils simples en pipelines puissants.

---

## 1. Descripteurs de fichiers

### 1.1 Les trois descripteurs standard

Tout processus Unix démarre avec trois flux ouverts :

| Descripteur | Numéro | Nom | Par défaut |
|-------------|--------|-----|------------|
| `stdin` | 0 | Entrée standard | Clavier |
| `stdout` | 1 | Sortie standard | Terminal |
| `stderr` | 2 | Erreur standard | Terminal |

```bash
# Illustration : grep lit stdin (0), écrit sur stdout (1), erreurs sur stderr (2)
grep "motif" fichier.txt
# ──────────────────────────────────────────
# stdin  [0] ← fichier.txt (argument)
# stdout [1] → terminal (lignes correspondantes)
# stderr [2] → terminal (messages d'erreur)

# Vérifier les descripteurs d'un processus
ls -la /proc/$$/fd
# lrwx------ 1 alice alice ... 0 -> /dev/pts/0  (stdin)
# lrwx------ 1 alice alice ... 1 -> /dev/pts/0  (stdout)
# lrwx------ 1 alice alice ... 2 -> /dev/pts/0  (stderr)
```

---

## 2. Redirections de la sortie standard

### 2.1 `>` — Rédiriger stdout (écrase)

```bash
# Écrire la sortie dans un fichier (écrase s'il existe)
ls -la > liste_fichiers.txt
echo "Bonjour" > message.txt
date > timestamp.txt

# Créer un fichier vide (ou vider un fichier existant)
> fichier_vide.txt
: > fichier_vide.txt   # idem, plus portable

# Attention : > écrase sans confirmation !
ls > résultats.txt    # si résultats.txt existait → effacé
```

### 2.2 `>>` — Rédiriger stdout (append)

```bash
# Ajouter à la fin d'un fichier
echo "Ligne 1" >> journal.txt
echo "Ligne 2" >> journal.txt
date >> journal.txt

# Usage typique : log d'actions
echo "$(date) - Déploiement lancé" >> /var/log/deploy.log
```

### 2.3 `2>` — Rédiriger stderr

```bash
# Envoyer les erreurs dans un fichier
ls /dossier_inexistant 2> erreurs.log
find / -name "secret" 2> /dev/null   # ignorer les erreurs

# Séparer stdout et stderr
commande > sortie.log 2> erreurs.log

# Voir seulement les erreurs
ls /etc /inexistant 2>&1 >/dev/null
```

### 2.4 `2>&1` — Fusionner stderr dans stdout

```bash
# Rediriger les deux flux vers un même fichier
commande > tout.log 2>&1

# Ordre important ! (de droite à gauche)
commande 2>&1 > fichier   # FAUX : stderr → terminal, stdout → fichier
commande > fichier 2>&1   # CORRECT : stdout → fichier, stderr → fichier

# Syntaxe courte bash (équivalent de > fichier 2>&1)
commande &> fichier
commande &>> fichier   # version append
```

```bash
# Exemples pratiques
make 2>&1 | tee build.log        # sortie ET erreurs dans le log ET le terminal
./script.sh > /dev/null 2>&1     # exécuter silencieusement
./script.sh >> app.log 2>&1      # logger tout en append
```

---

## 3. Redirections de l'entrée standard

### 3.1 `<` — Lire depuis un fichier

```bash
# Passer un fichier comme stdin
sort < noms.txt
wc -l < access.log
mysql -u root -p < script.sql

# Équivalent (le plus courant car plus lisible)
sort noms.txt
# mais < est utile pour les commandes qui ne prennent pas de nom de fichier
```

### 3.2 Here-Document `<<`

Un here-document permet d'écrire plusieurs lignes directement dans le script.

```bash
# Syntaxe de base
cat << EOF
Ligne 1
Ligne 2
Les variables $USER sont interpolées
EOF

# Désactiver l'interpolation avec quotes
cat << 'EOF'
Ici, $USER n'est PAS interpolé
EOF

# Indentation (tiret supprime les tabulations initiales)
cat <<- EOF
	Ligne indentée (tabulation supprimée)
	Autre ligne
	EOF

# Usage pratique : créer un fichier avec un contenu
cat > /etc/nginx/conf.d/mysite.conf << 'EOF'
server {
    listen 80;
    server_name example.com;
    root /var/www/html;
}
EOF

# Avec sudo
sudo tee /etc/hosts << 'EOF'
127.0.0.1  localhost
192.168.1.1  monserveur
EOF
```

### 3.3 Here-String `<<<`

```bash
# Passer une chaîne directement comme stdin
grep "motif" <<< "voici ma chaîne de test"
wc -w <<< "bonjour le monde"    # 3
bc <<< "2 + 3 * 4"              # 14

# Utile pour éviter les pipes avec des chaînes simples
read -r var <<< "valeur"
echo $var   # valeur
```

---

## 4. `/dev/null` — La poubelle

```bash
# Ignorer stdout
commande > /dev/null

# Ignorer stderr
commande 2> /dev/null

# Ignorer les deux
commande > /dev/null 2>&1
commande &> /dev/null       # syntaxe bash courte

# Usage courant : exécuter silencieusement, ne garder que le code de retour
if grep -q "motif" fichier.txt 2>/dev/null; then
    echo "Trouvé"
fi
```

---

## 5. Pipes `|`

### 5.1 Le pipe : connecter des commandes

Un pipe redirige le **stdout** d'une commande vers le **stdin** de la suivante.

```bash
# Syntaxe de base
commande1 | commande2 | commande3

# Exemples classiques
ls -la | grep ".txt"           # filtrer les .txt
cat /etc/passwd | sort          # trier les utilisateurs
ps aux | grep nginx             # trouver les processus nginx
history | grep "git commit"     # trouver dans l'historique

# Pipeline plus complexe
cat /var/log/nginx/access.log \
  | grep "404" \
  | awk '{print $1}' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10
# → Top 10 des IPs faisant des erreurs 404
```

### 5.2 `tee` — Bifurquer un flux

`tee` lit stdin et l'écrit simultanément vers stdout ET vers un fichier.

```bash
# Afficher ET sauvegarder
commande | tee fichier.txt

# Append au lieu d'écraser
commande | tee -a fichier.txt

# Bifurquer vers plusieurs fichiers
commande | tee fichier1.txt fichier2.txt

# Dans un pipeline : garder la vue ET logger
make | tee build.log | grep -E "error|warning"

# Écrire dans un fichier protégé avec sudo
echo "127.0.0.1 local" | sudo tee -a /etc/hosts

# tee dans le milieu d'un pipeline
cat input.txt | tee /tmp/debug_step1.txt | sort | tee /tmp/debug_step2.txt | uniq
```

---

## 6. `xargs` — Passer des arguments

`xargs` lit stdin ligne par ligne et les passe comme arguments à une commande.

```bash
# Syntaxe de base
echo "a b c" | xargs echo
# a b c

# Avec find
find . -name "*.tmp" | xargs rm
find . -name "*.log" | xargs ls -lh

# -I {} : placeholder pour l'argument
find . -name "*.txt" | xargs -I {} cp {} /backup/

# Parallélisme (-P)
find . -name "*.jpg" | xargs -P 4 -I {} convert {} -resize 800x {}

# Gérer les noms avec espaces (-0 avec find -print0)
find . -name "*.txt" -print0 | xargs -0 ls -la

# Limiter le nombre d'arguments par appel (-n)
echo "1 2 3 4 5 6" | xargs -n 2 echo
# 1 2
# 3 4
# 5 6

# Confirmation interactive (-p)
echo "file1 file2" | xargs -p rm
```

> **Piège courant** : Les noms de fichiers contenant des espaces cassent `xargs` par défaut. Utilisez toujours `find -print0 | xargs -0` pour gérer les espaces dans les noms de fichiers.

---

## 7. Chaînes de commandes

### 7.1 `;` — Séquence inconditionnelle

```bash
# Les commandes s'exécutent l'une après l'autre, peu importe le résultat
mkdir /tmp/test; cd /tmp/test; ls
echo "debut"; commande_qui_echoue; echo "fin"  # "fin" s'affiche quand même
```

### 7.2 `&&` — ET logique (exécution conditionnelle)

```bash
# La deuxième commande s'exécute SEULEMENT si la première réussit (exit code 0)
mkdir -p /tmp/test && cd /tmp/test
apt update && apt upgrade       # upgrade seulement si update réussit
./configure && make && make install

# Pattern idiomatique bash
command_1 && command_2 || echo "Erreur"
```

### 7.3 `||` — OU logique

```bash
# La deuxième commande s'exécute SEULEMENT si la première échoue
mkdir /tmp/exists 2>/dev/null || echo "Le répertoire existe déjà"
ping -c1 google.com || echo "Pas de connexion internet"

# Valeur par défaut
VALEUR=${VARIABLE:-"défaut"}   # si VARIABLE vide, utiliser "défaut"
cd /tmp/work || { mkdir /tmp/work && cd /tmp/work; }
```

```bash
# Comprendre les codes de retour
echo $?    # code de retour de la dernière commande (0 = succès)
true       # commande qui réussit toujours (exit 0)
false      # commande qui échoue toujours (exit 1)

# Dans les conditions
if commande; then
    echo "Succès"
fi
```

---

## 8. Substitution de commandes

### 8.1 `$()` — Substitution moderne (recommandée)

```bash
# Capturer la sortie d'une commande
DATE=$(date +%Y%m%d)
NB_FICHIERS=$(find . -type f | wc -l)
UTILISATEUR=$(whoami)

# Dans une chaîne
echo "Aujourd'hui : $(date)"
echo "Il y a $(ls | wc -l) fichiers"
ARCHIVE="sauvegarde_$(date +%Y%m%d_%H%M%S).tar.gz"

# Imbrication
echo "Le shell de root est : $(grep "^root" /etc/passwd | cut -d: -f7)"

# Dans des conditions
if [ "$(id -u)" -eq 0 ]; then
    echo "Je suis root"
fi
```

### 8.2 Backticks `` ` `` — Ancienne syntaxe (à éviter)

```bash
# Ancienne syntaxe — fonctionnelle mais à éviter
DATE=`date +%Y%m%d`
echo `whoami`

# Problèmes des backticks :
# - Difficile à imbriquer
# - Confusion visuelle avec les apostrophes
# - Préférez toujours $()
```

---

## 9. `/dev/stdin`, `/dev/stdout`, `/dev/stderr`

```bash
# Pseudo-fichiers représentant les flux
cat /dev/stdin           # lire depuis le clavier
echo "test" > /dev/stdout  # écrire sur le terminal
echo "erreur" > /dev/stderr  # écrire sur stderr

# Utile dans les scripts
log() {
    echo "[$(date +%T)] $*" >> /tmp/app.log
    echo "[$(date +%T)] $*" > /dev/stderr  # aussi sur stderr
}

# Rediriger vers /dev/fd/N
commande > /dev/fd/3   # écrire sur le descripteur 3

# Ouvrir des descripteurs personnalisés
exec 3> fichier_log.txt      # ouvrir le fd 3 en écriture
echo "message" >&3            # écrire dedans
exec 3>&-                     # fermer le fd 3
```

---

## 10. Pipelines avancés

```bash
# Pipeline avec traitement d'erreurs
set -o pipefail   # le pipeline échoue si UNE commande échoue
command1 | command2 | command3

# Vérifier le code de sortie de chaque commande dans un pipeline
command1 | command2
echo ${PIPESTATUS[@]}   # ex : 0 1 (command1 ok, command2 fail)

# Named pipe (FIFO) pour communication entre scripts
mkfifo /tmp/mon_pipe
cat fichier.txt > /tmp/mon_pipe &    # écrire en background
grep "motif" < /tmp/mon_pipe         # lire depuis le pipe
rm /tmp/mon_pipe

# Process substitution (bash uniquement)
diff <(ls dir1/) <(ls dir2/)         # comparer sans fichiers temporaires
sort -k2 <(cat fichier1.txt fichier2.txt)  # trier la concaténation
```

---

## Tableau récapitulatif

| Syntaxe | Description | Exemple |
|---------|-------------|---------|
| `cmd > f` | stdout vers fichier (écrase) | `ls > liste.txt` |
| `cmd >> f` | stdout vers fichier (append) | `date >> log.txt` |
| `cmd 2> f` | stderr vers fichier | `cmd 2> err.log` |
| `cmd > f 2>&1` | stdout+stderr vers fichier | `make > out.log 2>&1` |
| `cmd &> f` | stdout+stderr (bash court) | `cmd &> tout.log` |
| `cmd < f` | stdin depuis fichier | `sort < noms.txt` |
| `cmd << EOF` | Here-document | `cat << 'EOF' ... EOF` |
| `cmd <<< str` | Here-string | `wc -w <<< "bonjour"` |
| `> /dev/null` | Ignorer la sortie | `cmd &>/dev/null` |
| `cmd1 \| cmd2` | Pipe stdout→stdin | `ls \| grep .txt` |
| `tee f` | Bifurquer stdout + fichier | `make \| tee build.log` |
| `xargs` | Args depuis stdin | `find . \| xargs rm` |
| `xargs -I {}` | Placeholder | `find . \| xargs -I{} cp {} /bak/` |
| `cmd1 ; cmd2` | Séquence | `cmd1; cmd2` |
| `cmd1 && cmd2` | Si cmd1 réussit | `test && deploy` |
| `cmd1 \|\| cmd2` | Si cmd1 échoue | `mkdir x \|\| true` |
| `$(cmd)` | Substitution de commande | `DATE=$(date)` |

---

## À retenir

- **stdin=0, stdout=1, stderr=2** — ces numéros sont la base de toutes les redirections
- `>` écrase, `>>` append — confondre les deux peut détruire un fichier
- `2>&1` doit toujours venir **après** la redirection de stdout
- `&&` et `||` permettent la logique conditionnelle en une ligne
- `tee` est indispensable pour logger ET voir la sortie simultanément
- `find -print0 | xargs -0` protège contre les espaces dans les noms de fichiers

➡️ [Chapitre 6 — Recherche et filtrage](../06_recherche_filtrage/README.md)
