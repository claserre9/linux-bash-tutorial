# Chapitre 6 — Recherche et filtrage

Trouver des fichiers dans une arborescence, chercher du texte dans des logs, filtrer par taille, date ou contenu : ce chapitre couvre les outils de recherche Unix classiques (`grep`, `find`) et leurs alternatives modernes (`fd`, `ripgrep`).

---

## 1. `grep` — Recherche dans le texte

### 1.1 Utilisation de base

```bash
# Chercher un motif dans un fichier
grep "motif" fichier.txt

# Chercher dans plusieurs fichiers
grep "erreur" *.log
grep "nginx" /etc/nginx/nginx.conf /etc/hosts

# Chercher dans toute une arborescence (récursif)
grep -r "TODO" /home/alice/projet/
grep -r "password" /etc/
```

### 1.2 Options essentielles

```bash
# Insensible à la casse
grep -i "error" application.log
grep -i "nginx\|apache" /var/log/syslog

# Inverser : lignes qui NE contiennent PAS le motif
grep -v "DEBUG" app.log
grep -v "^#" /etc/ssh/sshd_config    # exclure les commentaires

# Afficher les numéros de ligne
grep -n "motif" fichier.txt
# 42:ligne correspondante

# Afficher seulement les noms de fichiers
grep -l "TODO" *.py          # fichiers contenant "TODO"
grep -L "TODO" *.py          # fichiers ne contenant PAS "TODO"

# Compter les occurrences
grep -c "error" app.log      # nombre de lignes correspondantes
grep -c "" fichier.txt       # nombre total de lignes (vide = tout)

# Afficher seulement la partie correspondante (pas toute la ligne)
grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" access.log
# Extrait toutes les adresses IP

# Contexte autour des correspondances
grep -A 3 "ERROR" app.log    # 3 lignes After (après)
grep -B 2 "ERROR" app.log    # 2 lignes Before (avant)
grep -C 2 "ERROR" app.log    # 2 lignes Context (avant ET après)
```

### 1.3 Expressions régulières

```bash
# Regex de base (BRE — Basic Regular Expressions)
grep "^ERROR"    fichier   # commence par ERROR
grep "\.log$"    fichier   # se termine par .log
grep "a.b"       fichier   # a + n'importe quel caractère + b
grep "co*l"      fichier   # c + zéro ou plusieurs o + l

# Regex étendues (-E ou egrep) — recommandé
grep -E "error|warning|critical" app.log    # OU logique
grep -E "https?://"  fichier               # http ou https
grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}"    # date YYYY-MM-DD en début
grep -E "\b[A-Z]{2,}\b" fichier            # mots en majuscules (2+ lettres)

# Regex Perl (-P) — pour les fonctionnalités avancées
grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" fichier  # IP
grep -P "(?<=user=)\w+" config.txt          # lookbehind
grep -P "\t" fichier.txt                    # tabulations réelles
```

### 1.4 Classes de caractères POSIX

```bash
grep -E "[[:alpha:]]"    # lettres (a-z, A-Z)
grep -E "[[:digit:]]"    # chiffres (0-9)
grep -E "[[:alnum:]]"    # lettres + chiffres
grep -E "[[:space:]]"    # espaces, tabulations, sauts de ligne
grep -E "[[:upper:]]"    # lettres majuscules
grep -E "[[:lower:]]"    # lettres minuscules
grep -E "[[:punct:]]"    # ponctuation
```

### 1.5 Couleurs et affichage

```bash
# Activer les couleurs
grep --color=auto "error" app.log
grep --color=always "error" app.log | less -R  # couleurs dans less

# Définir dans .bashrc
alias grep='grep --color=auto'

# grep silencieux (juste le code de retour)
grep -q "motif" fichier && echo "Trouvé" || echo "Absent"
```

> **Astuce pro** : `grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"` — affiche la configuration sans les commentaires ni les lignes vides. Idéal pour inspecter rapidement un fichier de config.

---

## 2. `find` — Recherche de fichiers

### 2.1 Syntaxe de base

```bash
# find [chemin] [critères] [actions]

# Trouver par nom
find . -name "*.txt"              # sensible à la casse
find . -iname "*.TXT"             # insensible à la casse

# Trouver par type
find . -type f     # fichiers réguliers
find . -type d     # répertoires
find . -type l     # liens symboliques
find . -type p     # pipes nommés
find . -type s     # sockets

# Exemples de base
find /etc -name "*.conf"
find /var/log -name "*.log" -type f
find /home -type d -name ".git"
```

### 2.2 Critères de recherche

```bash
# Par taille (-size)
find . -size +10M          # plus de 10 Mo
find . -size -1k           # moins de 1 Ko
find . -size 100c          # exactement 100 octets
# Unités : c (octets), k (Ko), M (Mo), G (Go)

# Par date de modification (-mtime, -atime, -ctime)
find . -mtime -7           # modifié dans les 7 derniers jours
find . -mtime +30          # non modifié depuis 30+ jours
find . -mtime 0            # modifié aujourd'hui (dernières 24h)
find . -newer fichier.ref  # plus récent que fichier.ref

# Par date en minutes (-mmin)
find . -mmin -60           # modifié dans la dernière heure
find . -mmin +1440         # non modifié depuis 24h+

# Par propriétaire
find . -user alice         # appartenant à alice
find . -group developers   # appartenant au groupe developers
find . -uid 1000           # par UID numérique

# Par permissions
find . -perm 644           # exactement 644
find . -perm -644          # au moins 644 (tous ces bits sont actifs)
find . -perm /u+x          # exécutable par le propriétaire
find /usr -perm -4000      # fichiers SUID
find / -perm -2000 2>/dev/null  # fichiers SGID
```

### 2.3 Limiter la profondeur

```bash
find . -maxdepth 1 -type f        # seulement le répertoire courant
find . -maxdepth 2 -name "*.conf" # jusqu'à 2 niveaux de profondeur
find . -mindepth 1 -maxdepth 3    # entre 1 et 3 niveaux
```

### 2.4 Actions

```bash
# -print (défaut) : afficher les chemins
find . -name "*.tmp" -print

# -delete : supprimer (ATTENTION : irréversible)
find . -name "*.tmp" -delete
find . -mtime +30 -name "*.log" -delete

# -exec : exécuter une commande sur chaque résultat
find . -name "*.txt" -exec cat {} \;        # cat chaque fichier
find . -name "*.jpg" -exec chmod 644 {} \;  # chmod sur chaque image
find . -type f -exec ls -lh {} \;

# -exec ... {} + : plus efficace (regroupe les arguments)
find . -name "*.log" -exec ls -lh {} +      # un seul appel à ls
find . -name "*.txt" -exec wc -l {} +       # compter toutes les lignes

# Confirmation interactive (-ok)
find . -name "*.bak" -ok rm {} \;           # demande confirmation pour chaque fichier

# Combinaison avec xargs
find . -name "*.tmp" | xargs rm
find . -name "*.log" -print0 | xargs -0 gzip
```

### 2.5 Combinaisons logiques

```bash
# ET implicite (critères consécutifs)
find . -type f -name "*.log" -size +1M

# ET explicite (-and ou -a)
find . -type f -and -name "*.log"

# OU (-or ou -o)
find . -name "*.jpg" -o -name "*.png" -o -name "*.gif"

# NON (-not ou !)
find . -not -name "*.bak"
find . ! -name "*.bak"

# Groupement avec parenthèses
find . \( -name "*.jpg" -o -name "*.png" \) -size +1M

# Exclure un répertoire
find . -path "./.git" -prune -o -type f -print
find . -not -path "*/.git/*" -name "*.py"
```

> **Piège courant** : `-exec cmd {} \;` appelle la commande une fois par fichier. `-exec cmd {} +` regroupe tous les fichiers en un seul appel (bien plus efficace). Mais `+` ne fonctionne pas avec toutes les commandes.

---

## 3. `locate` / `mlocate` — Recherche rapide par base de données

```bash
# Chercher par nom (base de données pré-indexée)
locate passwd
locate "*.conf"
locate -i "readme"      # insensible à la casse

# Mettre à jour la base de données
sudo updatedb

# Limiter le nombre de résultats
locate -n 10 nginx

# Afficher seulement les fichiers existants
locate -e "*.conf"      # vérifie l'existence

# Filtrer par répertoire
locate /etc/*.conf
```

> **Astuce pro** : `locate` est bien plus rapide que `find` pour chercher un fichier par nom car il utilise une base de données indexée. Inconvénient : la base n'est mise à jour qu'une fois par jour (via cron). Pour les fichiers très récents, utilisez `find`.

---

## 4. `which` et `whereis` — Localiser les commandes

```bash
# which : chemin de la commande dans $PATH
which python3
# /usr/bin/python3

which -a git   # toutes les occurrences
# /usr/bin/git
# /usr/local/bin/git

# whereis : trouver binaire + sources + pages man
whereis nginx
# nginx: /usr/sbin/nginx /etc/nginx /usr/share/doc/nginx

whereis python3
# python3: /usr/bin/python3 /usr/lib/python3 /usr/share/man/man1/python3.1.gz
```

---

## 5. Outils modernes : `fd` et `ripgrep`

### 5.1 `fd` — Alternative moderne à `find`

`fd` est plus rapide, ignore `.gitignore` par défaut et a une syntaxe plus simple.

```bash
# Installation
sudo apt install fd-find   # Debian/Ubuntu (binaire : fdfind)
brew install fd             # macOS

# Utilisation (aussi simple que grep)
fd "\.txt$"                 # fichiers .txt
fd -t f "\.conf"            # fichiers uniquement
fd -t d "node_modules"      # répertoires
fd -H "\.gitignore"         # inclure les fichiers cachés

# Insensible à la casse
fd -i "readme"

# Dans un répertoire spécifique
fd "\.log" /var/log

# Exécuter une commande
fd "\.jpg" -x convert {} -resize 800x {}

# Ignorer un répertoire
fd --exclude ".git" "\.py"

# Par extension
fd -e py    # tous les fichiers Python
fd -e js -e ts   # JS et TypeScript
```

### 5.2 `ripgrep` (`rg`) — Alternative moderne à `grep`

`rg` est extrêmement rapide, respecte `.gitignore`, et a une sortie colorée par défaut.

```bash
# Installation
sudo apt install ripgrep    # Debian/Ubuntu
brew install ripgrep        # macOS

# Utilisation
rg "TODO" .                      # chercher dans le répertoire courant
rg -i "error" /var/log/          # insensible à la casse
rg -n "function" src/            # avec numéros de ligne
rg -l "import" src/              # seulement les noms de fichiers
rg -c "def " *.py                # compter par fichier

# Options utiles
rg -t py "class "                # dans les fichiers Python seulement
rg -T py "TODO"                  # exclure les fichiers Python
rg --no-ignore "secret"          # inclure les fichiers ignorés par .gitignore
rg -w "word"                     # mots entiers seulement
rg -A 3 -B 1 "def main"          # contexte

# Recherche multilignes
rg -U "def \w+\(.*\):\n" src/

# Remplacer (mode dry-run, affiche sans modifier)
rg -r "nouveau_nom" "ancien_nom" fichier.py
```

---

## 6. Combinaisons avancées

### 6.1 `find` + `xargs`

```bash
# Supprimer les fichiers temporaires
find /tmp -name "*.tmp" -mtime +7 -print0 | xargs -0 rm -f

# Compresser les vieux logs
find /var/log -name "*.log" -mtime +30 -print0 | xargs -0 gzip

# Changer les permissions de tous les scripts
find . -name "*.sh" -print0 | xargs -0 chmod +x

# grep dans tous les fichiers Python
find . -name "*.py" -print0 | xargs -0 grep -l "import os"
```

### 6.2 `find` + `grep`

```bash
# Chercher un texte dans des fichiers d'un type spécifique
find . -name "*.conf" -exec grep -l "ssl" {} \;
find /etc -name "*.conf" -exec grep -H "PermitRoot" {} \;

# Version avec xargs (plus efficace)
find . -name "*.py" -print0 | xargs -0 grep -n "def main"

# Chercher en excluant des répertoires
find . -not -path "*/.git/*" -name "*.js" -print0 \
  | xargs -0 grep -l "console.log"
```

### 6.3 Filtrer des logs

```bash
# Analyser les logs d'accès nginx
# Top 10 des IPs
grep -E "^[0-9]" access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head 10

# Erreurs 5xx
grep -E '" 5[0-9]{2} ' access.log | wc -l

# Erreurs dans la dernière heure
find /var/log -name "*.log" -mmin -60 -exec grep -H "ERROR" {} \;

# Suivre plusieurs fichiers
tail -f /var/log/nginx/access.log /var/log/nginx/error.log

# Chercher entre deux dates
awk '/2024-01-15 10:00/,/2024-01-15 11:00/' application.log | grep "ERROR"

# Les 10 URLs les plus demandées
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head 10

# Codes HTTP par fréquence
grep -oP '" \K[0-9]{3}(?= )' access.log | sort | uniq -c | sort -rn
```

> **Astuce pro** : Pour analyser des gros fichiers de logs, préférez `rg` à `grep` — il est souvent 10x plus rapide et peut chercher dans des répertoires récursifs avec exclusions intelligentes.

---

## 7. Patterns utiles

### 7.1 Trouver les gros fichiers

```bash
# Top 10 des plus gros fichiers
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh | head 10

# Alternative avec du
du -ah /var | sort -rh | head 20
```

### 7.2 Trouver les fichiers récemment modifiés

```bash
# Modifiés dans les 24 dernières heures
find /etc -mtime -1 -type f 2>/dev/null

# Modifiés depuis un point de référence
touch /tmp/reference_time
# ... faire des actions ...
find / -newer /tmp/reference_time -type f 2>/dev/null
```

### 7.3 Trouver et supprimer les fichiers vides

```bash
# Fichiers vides
find . -type f -empty
find . -type f -empty -delete

# Répertoires vides
find . -type d -empty
find . -type d -empty -delete
```

### 7.4 Chercher du contenu sensible

```bash
# Rechercher des mots de passe dans des fichiers de config
grep -r -i "password\s*=" /etc/ 2>/dev/null
grep -r -E "passwd|password|secret|api_key" ~/.config/ 2>/dev/null

# Fichiers world-writable (risque sécurité)
find / -type f -perm -002 2>/dev/null

# Fichiers SUID
find / -perm -4000 -type f 2>/dev/null
```

---

## Tableau récapitulatif

| Commande | Description | Exemple |
|----------|-------------|---------|
| `grep -r "motif" .` | Recherche récursive | `grep -r "TODO" src/` |
| `grep -i` | Insensible à la casse | `grep -i "error" app.log` |
| `grep -v` | Inverser (exclure) | `grep -v "^#" config` |
| `grep -n` | Numéros de ligne | `grep -n "bug" code.py` |
| `grep -l` | Noms de fichiers seulement | `grep -l "import" *.py` |
| `grep -c` | Compter les occurrences | `grep -c "404" access.log` |
| `grep -E` | Regex étendue | `grep -E "err\|warn" log` |
| `grep -A/-B/-C` | Contexte | `grep -C 3 "ERROR" log` |
| `grep -o` | Extraire la correspondance | `grep -oE "[0-9.]+" log` |
| `find . -name` | Par nom | `find . -name "*.conf"` |
| `find . -type f/d` | Par type | `find /etc -type d` |
| `find . -size +10M` | Par taille | `find / -size +100M` |
| `find . -mtime -7` | Par date | `find . -mtime -1` |
| `find . -user` | Par propriétaire | `find . -user alice` |
| `find . -exec` | Exécuter | `find . -exec ls -lh {} +` |
| `find . -delete` | Supprimer | `find . -name "*.tmp" -delete` |
| `locate nom` | Recherche rapide (DB) | `locate passwd` |
| `which cmd` | Chemin dans $PATH | `which python3` |
| `whereis cmd` | Binaire + man + sources | `whereis nginx` |
| `fd "\.txt"` | Recherche moderne | `fd -e py` |
| `rg "motif"` | Grep moderne | `rg -i "error" .` |

---

## À retenir

- `grep -r` pour chercher du texte, `find` pour chercher des fichiers — ils sont complémentaires
- `grep -E` (regex étendues) est presque toujours préférable à `grep` de base
- `find -print0 | xargs -0` protège contre les noms de fichiers avec espaces
- `locate` est rapide mais sa base peut être obsolète — `updatedb` pour rafraîchir
- `fd` et `ripgrep` sont des alternatives modernes plus rapides et intelligentes
- `grep -q` est idéal dans les scripts pour tester la présence d'un motif sans afficher

➡️ [Chapitre 7 — Traitement de texte](../07_traitement_texte/README.md)
