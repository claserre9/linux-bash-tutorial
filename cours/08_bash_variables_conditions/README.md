# Chapitre 8 — Bash : Variables, conditions et boucles

Bash est bien plus qu'un simple interpréteur de commandes : c'est un langage de programmation complet. Ce chapitre couvre les fondamentaux du scripting Bash — variables, expansion de paramètres, arithmétique, tests conditionnels et boucles — qui sont la base de tout script robuste et maintenable.

---

## 1. Variables

### 1.1 Déclaration et affectation

```bash
# Affectation : PAS d'espace autour du =
nom="Alice"
age=30
chemin="/home/alice"

# Mauvais (erreur)
# nom = "Alice"   ← INTERDIT

# Afficher une variable
echo $nom
echo "Bonjour, $nom !"

# Forme avec accolades (recommandée)
echo "${nom}"
echo "Prénom : ${nom}, âge : ${age}"
```

### 1.2 Guillemets simples vs doubles

```bash
nom="Alice"

# Guillemets doubles : les variables sont développées
echo "Bonjour $nom"        # Bonjour Alice
echo "Chemin: $HOME"       # Chemin: /home/alice

# Guillemets simples : tout est littéral, aucune expansion
echo 'Bonjour $nom'        # Bonjour $nom
echo 'Chemin: $HOME'       # Chemin: $HOME

# Mélanger les deux
echo "Il a dit: 'bonjour'"
echo 'Le signe dollar : $'

# Échappement dans les doubles guillemets
echo "Prix: \$5"           # Prix: $5
echo "Tabulation: \t"      # Tabulation: \t (avec $'...' pour l'interpolation)
echo $'Tabulation:\there'  # Tabulation:    ici
```

### 1.3 Variables spéciales

```bash
# $0 — nom du script
echo "Script : $0"

# $1 à $9 — arguments positionnels
echo "1er arg : $1"
echo "2e arg  : $2"

# ${10} et au-delà — accolades obligatoires
echo "10e arg : ${10}"

# $@ — tous les arguments (liste préservant les espaces)
for arg in "$@"; do
    echo "Argument: $arg"
done

# $* — tous les arguments (concaténés)
echo "Tous: $*"

# $# — nombre d'arguments
echo "Nombre d'arguments : $#"

# $? — code de retour de la dernière commande
ls /tmp
echo "Code retour ls : $?"

grep "pattern" fichier.txt
if [ $? -eq 0 ]; then
    echo "Pattern trouvé"
fi

# $$ — PID du processus courant
echo "PID du script : $$"
LOCK_FILE="/tmp/monscript.$$.lock"

# $! — PID de la dernière commande en arrière-plan
sleep 10 &
echo "PID du sleep : $!"

# $_ — dernier argument de la commande précédente
ls /tmp
echo "Dernier arg : $_"    # /tmp
```

> **Piège courant** : Utilisez toujours `"$@"` (avec guillemets) pour passer des arguments. `$*` concatène les arguments avec le premier caractère de `$IFS`, ce qui peut causer des surprises.

---

## 2. Expansion de paramètres

### 2.1 Valeurs par défaut

```bash
# ${VAR:-default} : utiliser default si VAR est vide ou non définie
nom="${1:-Anonyme}"
echo "Bonjour, ${nom}"

fichier="${CONFIG_FILE:-/etc/app/config.conf}"

# ${VAR:=default} : affecter ET utiliser default si VAR est vide ou non définie
: "${LOG_DIR:=/var/log/app}"
echo "Logs dans : $LOG_DIR"   # /var/log/app si non définie

# ${VAR:+alt} : utiliser alt si VAR est définie et non vide
debug="${DEBUG:+--verbose}"
commande $debug              # Ajoute --verbose seulement si DEBUG est défini

# ${VAR:?message} : afficher l'erreur et quitter si VAR est vide ou non définie
: "${DATABASE_URL:?La variable DATABASE_URL est requise}"
```

### 2.2 Longueur et extraction

```bash
chaine="Bonjour le monde"

# ${#VAR} — longueur de la variable
echo "${#chaine}"             # 17

# ${VAR:offset} — sous-chaîne depuis offset
echo "${chaine:8}"            # le monde

# ${VAR:offset:length} — sous-chaîne depuis offset, longueur length
echo "${chaine:8:2}"          # le

# Offset négatif (depuis la fin) — espace obligatoire avant le -
echo "${chaine: -5}"          # monde
```

### 2.3 Suppression de préfixe/suffixe

```bash
fichier="/home/alice/documents/rapport.pdf"

# ${VAR#pattern} — supprimer le préfixe le plus court
echo "${fichier#*/}"          # home/alice/documents/rapport.pdf

# ${VAR##pattern} — supprimer le préfixe le plus long (greedy)
echo "${fichier##*/}"         # rapport.pdf  ← basename !

# ${VAR%pattern} — supprimer le suffixe le plus court
echo "${fichier%.*}"          # /home/alice/documents/rapport

# ${VAR%%pattern} — supprimer le suffixe le plus long (greedy)
echo "${fichier%%/*}"         # (vide — tout supprimé)

# Cas pratiques
nom_fichier="${fichier##*/}"  # rapport.pdf
extension="${fichier##*.}"    # pdf
sans_ext="${fichier%.*}"      # /home/alice/documents/rapport
repertoire="${fichier%/*}"    # /home/alice/documents
```

### 2.4 Substitution dans les variables

```bash
texte="Je mange des pommes et des pommes vertes"

# ${VAR/old/new} — remplacer la première occurrence
echo "${texte/pommes/poires}"
# Je mange des poires et des pommes vertes

# ${VAR//old/new} — remplacer toutes les occurrences
echo "${texte//pommes/poires}"
# Je mange des poires et des poires vertes

# ${VAR/#old/new} — remplacer si en début de chaîne
url="http://example.com"
echo "${url/#http/https}"     # https://example.com

# ${VAR/%old/new} — remplacer si en fin de chaîne
fichier="rapport.txt"
echo "${fichier/%.txt/.pdf}"  # rapport.pdf
```

> **Astuce pro** : Combinez ces expansions pour manipuler des chemins sans forker `basename` ou `dirname` :
> ```bash
> chemin="/var/log/app/error.log"
> nom="${chemin##*/}"    # error.log
> dir="${chemin%/*}"     # /var/log/app
> ext="${nom##*.}"       # log
> ```

---

## 3. Arithmétique

### 3.1 `$(( ))` — Expansion arithmétique

```bash
# Opérations de base
echo $((2 + 3))         # 5
echo $((10 - 4))        # 6
echo $((3 * 7))         # 21
echo $((17 / 5))        # 3 (division entière)
echo $((17 % 5))        # 2 (modulo)
echo $((2 ** 10))       # 1024 (puissance)

# Avec des variables
a=10; b=3
echo $((a + b))         # 13
echo $((a * b))         # 30

# Affectation dans l'arithmétique
i=0
echo $((++i))           # 1 (pré-incrément)
echo $((i++))           # 1 (post-incrément, affiche avant)
echo $i                 # 2

# Opérateurs composés
n=10
(( n += 5 ))
echo $n                 # 15
(( n *= 2 ))
echo $n                 # 30
```

### 3.2 `(( ))` — Test arithmétique

```bash
# (( )) retourne 0 (vrai) si le résultat est non-zéro
n=5
if (( n > 3 )); then
    echo "$n est supérieur à 3"
fi

# Combinaisons
if (( n >= 0 && n <= 10 )); then
    echo "n est entre 0 et 10"
fi

# Boucle for arithmétique
for (( i=0; i<5; i++ )); do
    echo "i = $i"
done
```

### 3.3 `let` et `bc`

```bash
# let — commande arithmétique (moins recommandé)
let "n = 5 + 3"
let n++
let "resultat = n * 2"

# bc — calculatrice avec virgule flottante
echo "scale=2; 22/7" | bc      # 3.14
echo "scale=4; sqrt(2)" | bc   # 1.4142
echo "3.14 * 2.5" | bc         # 7.85

# bc dans un script
pi=$(echo "scale=10; 4*a(1)" | bc -l)
echo "Pi = $pi"

# Conversion de base
echo "obase=2; 255" | bc       # 11111111 (décimal → binaire)
echo "ibase=16; FF" | bc       # 255 (hexadécimal → décimal)
```

---

## 4. Tests et conditions

### 4.1 `[ ]` vs `[[ ]]`

```bash
# [ ] est la commande test POSIX (compatible sh)
[ -f /etc/passwd ] && echo "fichier existe"

# [[ ]] est une construction Bash (plus puissante)
[[ -f /etc/passwd ]] && echo "fichier existe"

# Différences clés :

# 1. Pas besoin de guillemets avec [[
nom="Alice Martin"
[ "$nom" = "Alice" ]    # Guillemets nécessaires avec [ ]
[[ $nom = "Alice" ]]    # OK sans guillemets avec [[ ]]

# 2. Opérateur regex =~ disponible avec [[
email="user@example.com"
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && echo "Email valide"

# 3. Opérateurs && et || dans [[ ]]
[[ -f "$fichier" && -r "$fichier" ]] && echo "Lisible"

# 4. Wildcards dans [[ ]]
[[ "$fichier" == *.txt ]] && echo "Fichier texte"
```

### 4.2 Opérateurs de comparaison

```bash
# Comparaison numérique
[ $a -eq $b ]    # égal (equal)
[ $a -ne $b ]    # différent (not equal)
[ $a -lt $b ]    # inférieur (less than)
[ $a -gt $b ]    # supérieur (greater than)
[ $a -le $b ]    # inférieur ou égal (less or equal)
[ $a -ge $b ]    # supérieur ou égal (greater or equal)

# Comparaison de chaînes
[ "$a" = "$b" ]   # égal
[ "$a" != "$b" ]  # différent
[ "$a" < "$b" ]   # ordre lexicographique (peu fiable dans [ ])
[[ "$a" < "$b" ]] # ordre lexicographique dans [[ ]]
[ -z "$a" ]       # chaîne vide (zero length)
[ -n "$a" ]       # chaîne non vide (non-zero length)

# Tests sur les fichiers
[ -e "$f" ]   # existe (exist)
[ -f "$f" ]   # est un fichier régulier (file)
[ -d "$f" ]   # est un répertoire (directory)
[ -l "$f" ]   # est un lien symbolique (link)
[ -r "$f" ]   # lisible (readable)
[ -w "$f" ]   # accessible en écriture (writable)
[ -x "$f" ]   # exécutable (executable)
[ -s "$f" ]   # taille non nulle (size > 0)
[ -p "$f" ]   # est un pipe (named pipe)
[ -S "$f" ]   # est un socket
[ "$f1" -nt "$f2" ]  # f1 plus récent que f2 (newer than)
[ "$f1" -ot "$f2" ]  # f1 plus ancien que f2 (older than)
```

---

## 5. Structures conditionnelles

### 5.1 `if / elif / else`

```bash
#!/usr/bin/env bash

note=75

if (( note >= 90 )); then
    echo "Mention : Très bien"
elif (( note >= 80 )); then
    echo "Mention : Bien"
elif (( note >= 70 )); then
    echo "Mention : Assez bien"
elif (( note >= 60 )); then
    echo "Mention : Passable"
else
    echo "Mention : Insuffisant"
fi

# Vérification d'un fichier
fichier="/etc/hosts"
if [[ -f "$fichier" && -r "$fichier" ]]; then
    echo "Le fichier $fichier est lisible"
elif [[ -e "$fichier" ]]; then
    echo "Le fichier existe mais n'est pas lisible"
else
    echo "Le fichier n'existe pas"
fi

# Vérification d'arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi
```

### 5.2 `case / esac`

```bash
#!/usr/bin/env bash

# case est idéal pour les correspondances multiples
action="${1:-help}"

case "$action" in
    start)
        echo "Démarrage du service..."
        ;;
    stop)
        echo "Arrêt du service..."
        ;;
    restart | reload)
        echo "Redémarrage du service..."
        ;;
    status)
        echo "Vérification du statut..."
        ;;
    -h | --help | help)
        echo "Usage: $0 {start|stop|restart|status}"
        ;;
    *)
        echo "Action inconnue : $action"
        exit 1
        ;;
esac

# Avec des wildcards
extension="${fichier##*.}"
case "$extension" in
    txt | md | rst)
        echo "Document texte"
        ;;
    jpg | jpeg | png | gif | webp)
        echo "Image"
        ;;
    mp3 | flac | ogg | wav)
        echo "Audio"
        ;;
    mp4 | mkv | avi | mov)
        echo "Vidéo"
        ;;
    sh | bash)
        echo "Script shell"
        ;;
    *)
        echo "Extension inconnue : $extension"
        ;;
esac
```

> **Piège courant** : Dans `case`, chaque motif se termine par `)` et chaque bloc par `;;`. Oublier un `;;` peut provoquer un comportement inattendu (fall-through avec `;&` en Bash 4+).

---

## 6. Boucles

### 6.1 `for in` — Itérer sur une liste

```bash
# Liste de valeurs
for fruit in pomme poire cerise banane; do
    echo "Fruit : $fruit"
done

# Fichiers correspondant à un glob
for fichier in /etc/*.conf; do
    echo "Config : $fichier"
done

# Arguments du script
for arg in "$@"; do
    echo "Arg : $arg"
done

# Résultat d'une commande
for user in $(cut -d: -f1 /etc/passwd); do
    echo "User : $user"
done

# Séquence numérique avec {start..end}
for i in {1..10}; do
    echo "Numéro : $i"
done

# Séquence avec pas {start..end..step}
for i in {0..20..5}; do
    echo "$i"    # 0, 5, 10, 15, 20
done
```

### 6.2 `for (( ))` — Boucle arithmétique de style C

```bash
# Compteur classique
for (( i=1; i<=10; i++ )); do
    echo "i = $i"
done

# Compteur décroissant
for (( i=10; i>=1; i-- )); do
    echo "Compte à rebours : $i"
done

# Pas de 2
for (( i=0; i<=20; i+=2 )); do
    echo "Pair : $i"
done

# Avec plusieurs variables
for (( i=0, j=10; i<5; i++, j-- )); do
    echo "i=$i, j=$j"
done
```

### 6.3 `while` et `until`

```bash
# while : s'exécute TANT QUE la condition est vraie
compteur=0
while (( compteur < 5 )); do
    echo "Compteur : $compteur"
    (( compteur++ ))
done

# Lire un fichier ligne par ligne
while IFS= read -r ligne; do
    echo ">> $ligne"
done < fichier.txt

# Lire un fichier avec traitement
while IFS=: read -r user pass uid gid info home shell; do
    echo "User: $user, Shell: $shell"
done < /etc/passwd

# until : s'exécute JUSQU'À ce que la condition soit vraie
n=0
until (( n >= 5 )); do
    echo "n = $n"
    (( n++ ))
done

# Attendre qu'un fichier existe
until [[ -f "/tmp/signal.done" ]]; do
    echo "En attente..."
    sleep 1
done
echo "Signal reçu !"
```

### 6.4 `break` et `continue`

```bash
# break — quitter la boucle
for i in {1..10}; do
    if (( i == 5 )); then
        break    # Sort de la boucle
    fi
    echo "$i"    # Affiche 1 2 3 4
done

# continue — passer à l'itération suivante
for i in {1..10}; do
    if (( i % 2 == 0 )); then
        continue    # Ignore les pairs
    fi
    echo "$i"       # Affiche 1 3 5 7 9
done

# break N — quitter N niveaux de boucles imbriquées
for i in {1..3}; do
    for j in {1..3}; do
        if (( i == 2 && j == 2 )); then
            break 2    # Quitte les DEUX boucles
        fi
        echo "i=$i, j=$j"
    done
done
```

> **Astuce pro** : Pour lire des fichiers ligne par ligne, utilisez toujours la forme `while IFS= read -r ligne`. Le `IFS=` préserve les espaces en début/fin de ligne, et `-r` empêche l'interprétation des backslashes.

---

## 7. `read` — Lire des entrées

```bash
# Lecture simple
read nom
echo "Bonjour, $nom"

# Avec un prompt (-p)
read -p "Entrez votre nom : " nom

# Sans écho pour les mots de passe (-s)
read -s -p "Mot de passe : " mdp
echo ""    # Saut de ligne après le mot de passe

# Avec timeout (-t)
if read -t 10 -p "Répondez dans 10 secondes : " reponse; then
    echo "Réponse : $reponse"
else
    echo "Timeout !"
fi

# Lire dans un tableau (-a)
read -a fruits -p "Entrez des fruits (séparés par espaces) : "
echo "Premier : ${fruits[0]}"
echo "Nombre  : ${#fruits[@]}"

# Lecture sans interprétation des backslashes (-r)
read -r chemin -p "Chemin : "    # Recommandé par défaut

# Lire un seul caractère (-n 1)
read -n 1 -p "Continuer ? [o/n] : " choix
echo ""
```

---

## 8. `select` — Menus interactifs

```bash
#!/usr/bin/env bash

# select génère automatiquement un menu numéroté
options=("Afficher les fichiers" "Voir l'espace disque" "Voir la mémoire" "Quitter")

PS3="Choisissez une option : "    # Prompt personnalisé

select option in "${options[@]}"; do
    case $option in
        "Afficher les fichiers")
            ls -la
            ;;
        "Voir l'espace disque")
            df -h
            ;;
        "Voir la mémoire")
            free -h
            ;;
        "Quitter")
            echo "Au revoir !"
            break
            ;;
        *)
            echo "Option invalide : $REPLY"
            ;;
    esac
done

# select boucle jusqu'au break ou EOF (Ctrl+D)
# $REPLY contient la saisie brute de l'utilisateur
```

---

## Tableau récapitulatif

| Concept | Syntaxe | Notes |
|---------|---------|-------|
| Variable | `nom="valeur"` | Pas d'espace autour du `=` |
| Accès | `$VAR` ou `${VAR}` | Préférer `${VAR}` |
| Guillemets doubles | `"$VAR"` | Expansion active |
| Guillemets simples | `'$VAR'` | Littéral, pas d'expansion |
| Défaut | `${VAR:-défaut}` | Valeur si vide/non définie |
| Longueur | `${#VAR}` | Nombre de caractères |
| Suppression préfixe | `${VAR##*/}` | Greedy (plus long) |
| Suppression suffixe | `${VAR%.*}` | Non-greedy (plus court) |
| Substitution | `${VAR//old/new}` | Toutes les occurrences |
| Arithmétique | `$(( expr ))` | Entiers uniquement |
| Test fichier | `[[ -f "$f" ]]` | Double crochets recommandés |
| Test regex | `[[ "$s" =~ regex ]]` | Uniquement avec `[[` |
| for liste | `for x in a b c` | Glob, tableau, commande |
| for C-style | `for (( i=0; i<n; i++ ))` | Arithmétique |
| while | `while condition; do` | Tant que vrai |
| until | `until condition; do` | Jusqu'à vrai |
| Lecture fichier | `while IFS= read -r ligne` | Forme canonique |

---

## À retenir

- Toujours **mettre les variables entre guillemets** : `"$VAR"` évite les problèmes de séparation de mots et de globbing.
- **`[[ ]]`** est plus sûr et plus puissant que `[ ]` : utilisez `[[` dans vos scripts Bash.
- **`$(( ))`** pour l'arithmétique entière, **`bc`** pour les flottants.
- **`${VAR:-default}`** est le pattern le plus utilisé pour les valeurs par défaut et les arguments optionnels.
- Pour lire des fichiers ligne par ligne, la forme canonique est `while IFS= read -r ligne; do ... done < fichier`.
- **`case`** est plus lisible qu'une série de `if/elif` pour les comparaisons sur une même variable.

➡️ [Chapitre 9 — Bash : fonctions et scripts](../09_bash_fonctions_scripts/README.md)
