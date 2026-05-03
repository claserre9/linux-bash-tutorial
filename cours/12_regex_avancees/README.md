# Chapitre 12 — Regex avancées

Les expressions régulières (regex) sont le couteau suisse de la manipulation de texte sous Linux. Maîtriser BRE, ERE et PCRE, ainsi que leur application dans `grep`, `sed` et `awk`, permet de traiter n'importe quel flux de données texte avec précision et efficacité.

---

## 1. BRE vs ERE vs PCRE

### 1.1 Les trois familles de regex

Linux propose trois syntaxes de regex avec des capacités croissantes :

| Famille | Signification | Outil par défaut | Métacaractères étendus |
|---------|--------------|-----------------|----------------------|
| **BRE** | Basic Regular Expression | `grep`, `sed` | `\+` `\?` `\|` `\(` `\)` `\{` `\}` |
| **ERE** | Extended Regular Expression | `grep -E`, `awk` | `+` `?` `\|` `(` `)` `{` `}` |
| **PCRE** | Perl-Compatible RE | `grep -P` | lookahead, lookbehind, groupes nommés… |

```bash
# BRE : les métacaractères étendus doivent être échappés
grep 'colou\?r' fichier.txt       # ? optionnel en BRE

# ERE : syntaxe naturelle
grep -E 'colou?r' fichier.txt     # ? optionnel en ERE

# PCRE : fonctions avancées
grep -P '(?<=\d{3})\s\w+' fichier.txt   # lookbehind
```

> **Piège courant** : En BRE, écrire `(groupe)` sans backslash crée un groupe littéral, pas capturant. Il faut écrire `\(groupe\)`. En ERE, `(groupe)` est capturant et `\(` est littéral.

---

## 2. Métacaractères fondamentaux

### 2.1 Tableau des métacaractères

| Métacaractère | Signification | Exemple | Correspond à |
|--------------|--------------|---------|-------------|
| `.` | N'importe quel caractère (sauf `\n`) | `a.b` | `axb`, `a1b` |
| `*` | 0 ou plusieurs occurrences du précédent | `ab*c` | `ac`, `abc`, `abbc` |
| `+` | 1 ou plusieurs occurrences (ERE/PCRE) | `ab+c` | `abc`, `abbc` (pas `ac`) |
| `?` | 0 ou 1 occurrence (ERE/PCRE) | `colou?r` | `color`, `colour` |
| `{n,m}` | Entre n et m occurrences | `\d{2,4}` | 2 à 4 chiffres |
| `^` | Début de ligne | `^root` | Lignes commençant par `root` |
| `$` | Fin de ligne | `\.sh$` | Lignes finissant par `.sh` |
| `[]` | Classe de caractères | `[aeiou]` | Une voyelle |
| `[^]` | Négation de classe | `[^0-9]` | Tout sauf chiffre |
| `\b` | Limite de mot (PCRE/ERE) | `\bword\b` | Mot entier `word` |
| `\w` | Caractère de mot `[a-zA-Z0-9_]` | `\w+` | Un ou plusieurs car. de mot |
| `\d` | Chiffre `[0-9]` | `\d{4}` | 4 chiffres |
| `\s` | Espace blanc (espace, tab, `\n`…) | `\s+` | Un ou plusieurs espaces |

```bash
# Exemples pratiques
echo "test123" | grep -P '\d+'          # trouve "123"
echo "hello world" | grep -P '\bworld\b' # trouve "world" (mot entier)
echo "  spaces  " | grep -P '^\s+|\s+$' # espaces en début/fin

# Classes de caractères
grep '[[:upper:]][[:lower:]]*' fichier  # Mot commençant par majuscule
grep '[[:digit:]]{3}-[[:digit:]]{4}' fichier  # Format téléphone
```

### 2.2 Classes POSIX

```bash
# Classes POSIX (portables entre systèmes)
grep '[[:alpha:]]'   # Lettres a-z A-Z
grep '[[:digit:]]'   # Chiffres 0-9
grep '[[:alnum:]]'   # Lettres et chiffres
grep '[[:space:]]'   # Espaces blancs
grep '[[:upper:]]'   # Majuscules
grep '[[:lower:]]'   # Minuscules
grep '[[:punct:]]'   # Ponctuation
grep '[[:print:]]'   # Caractères imprimables
```

> **Astuce pro** : Préférez les classes POSIX `[[:digit:]]` à `\d` pour les scripts portables. `\d` est PCRE et non disponible avec `grep` sans le flag `-P`.

---

## 3. Groupes capturants et non-capturants

### 3.1 Groupes capturants `()`

```bash
# ERE : groupes capturants avec ()
echo "2024-01-15" | grep -oE '([0-9]{4})-([0-9]{2})-([0-9]{2})'

# Avec sed (BRE) : \(...\) pour capturer
echo "Jean Dupont" | sed 's/\([A-Z][a-z]*\) \([A-Z][a-z]*\)/\2 \1/'
# Résultat : Dupont Jean

# Avec sed (ERE) : -E simplifie la syntaxe
echo "Jean Dupont" | sed -E 's/([A-Z][a-z]+) ([A-Z][a-z]+)/\2 \1/'
# Résultat : Dupont Jean
```

### 3.2 Groupes non-capturants `(?:)`

```bash
# (?:) groupe sans capture (PCRE / ERE avec grep -P)
echo "foobar foobaz" | grep -oP '(?:foo)(?:bar|baz)'

# Utile pour l'alternation sans polluer les références arrières
echo "color colour" | grep -oP 'colo(?:u?)r'
```

### 3.3 Alternation `|`

```bash
# ERE : alternation avec |
grep -E 'cat|dog|bird' animaux.txt

# Groupée
grep -E '(cat|dog)food' fichier.txt

# BRE : alternation avec \|
grep 'cat\|dog' animaux.txt
```

---

## 4. Références arrières

### 4.1 Dans sed

```bash
# Référence arrière \1, \2... dans sed
# Inverser prénom et nom
sed -E 's/^([A-Z][a-z]+) ([A-Z][a-z]+)$/\2, \1/' prenoms.txt

# Doubler des mots répétés
echo "the the cat sat" | sed -E 's/\b(\w+) \1\b/\1/'
# Résultat : the cat sat

# Reformater une date AAAA-MM-JJ → JJ/MM/AAAA
echo "2024-03-15" | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/'
# Résultat : 15/03/2024

# Encadrer les nombres de crochets
echo "valeur 42 et 100" | sed -E 's/([0-9]+)/[\1]/g'
# Résultat : valeur [42] et [100]
```

### 4.2 Dans grep

```bash
# grep BRE : références arrières \1
grep '\([a-z]\)\1' fichier.txt  # Cherche une lettre doublée (aa, bb...)

# Détecter les mots répétés
grep -E '\b(\w+)\s+\1\b' document.txt
```

> **Piège courant** : `grep -E` supporte `\1` dans certaines implémentations (GNU grep), mais ce n'est pas garanti. Pour les références arrières complexes, utilisez `grep -P` ou `sed`.

---

## 5. Lookahead et Lookbehind (PCRE)

### 5.1 Lookahead positif `(?=)`

```bash
# (?=...) : correspond si suivi de...
# Trouver des nombres suivis de "px"
echo "12px 15em 20px" | grep -oP '\d+(?=px)'
# Résultat : 12  20

# Trouver des mots suivis d'une virgule
echo "pomme, poire, banane" | grep -oP '\w+(?=,)'
# Résultat : pomme  poire
```

### 5.2 Lookahead négatif `(?!)`

```bash
# (?!...) : correspond si NON suivi de...
# Trouver "color" mais pas "colorful"
echo "color colorful" | grep -oP 'color(?!ful)'
# Résultat : color

# Fichiers .sh mais pas .shrc
ls | grep -P '\.sh(?!rc)$'
```

### 5.3 Lookbehind positif `(?<=)`

```bash
# (?<=...) : correspond si précédé de...
# Extraire les valeurs après "prix: "
echo "prix: 42 et coût: 100" | grep -oP '(?<=prix: )\d+'
# Résultat : 42

# Extraire le contenu entre guillemets après "name="
echo 'name="Alice" age="30"' | grep -oP '(?<=name=")[^"]+'
# Résultat : Alice
```

### 5.4 Lookbehind négatif `(?<!)`

```bash
# (?<!...) : correspond si NON précédé de...
# Trouver "port" qui n'est pas précédé de "air"
echo "airport seaport" | grep -oP '(?<!air)port'
# Résultat : port (de seaport seulement)
```

> **Astuce pro** : Les lookaheads/lookbehinds sont des assertions de largeur nulle : ils vérifient la présence sans la consommer. Très puissants pour les extractions précises dans des flux structurés.

---

## 6. Groupes nommés `(?P<nom>)`

```bash
# Groupes nommés avec grep -P
echo "2024-03-15" | grep -oP '(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})'

# Plus lisible que les références numériques
# Utile pour documenter des patterns complexes

# Exemple : parser une ligne de log
LOG='[2024-03-15 14:22:01] ERROR: connexion refusée (code=403)'
echo "$LOG" | grep -oP '\[(?P<date>[^\]]+)\] (?P<level>\w+): (?P<msg>.*)'

# Avec Python (pour traitement avancé) :
python3 -c "
import re
log = '[2024-03-15 14:22:01] ERROR: connexion refusée'
m = re.match(r'\[(?P<date>[^\]]+)\] (?P<level>\w+): (?P<msg>.*)', log)
if m:
    print(m.group('date'), m.group('level'))
"
```

---

## 7. `grep -E` : ERE en détail

### 7.1 Valider une adresse email

```bash
# Pattern email (simplifié mais fonctionnel)
EMAIL_REGEX='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

valider_email() {
    local email="$1"
    if echo "$email" | grep -qE "$EMAIL_REGEX"; then
        echo "$email : valide"
    else
        echo "$email : invalide"
    fi
}

valider_email "user@example.com"     # valide
valider_email "invalid@"             # invalide
valider_email "test.user+tag@co.uk"  # valide
```

### 7.2 Valider une adresse IP

```bash
# IPv4 : chaque octet entre 0 et 255
IP_REGEX='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

valider_ip() {
    local ip="$1"
    if echo "$ip" | grep -qE "$IP_REGEX"; then
        echo "$ip : IP valide"
    else
        echo "$ip : IP invalide"
    fi
}

valider_ip "192.168.1.1"   # valide
valider_ip "256.1.1.1"     # invalide
valider_ip "10.0.0.255"    # valide
```

### 7.3 Valider une date

```bash
# Format AAAA-MM-JJ (vérification basique)
DATE_REGEX='^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'

echo "2024-03-15" | grep -E "$DATE_REGEX"  # correspond
echo "2024-13-01" | grep -E "$DATE_REGEX"  # ne correspond pas (mois 13)
echo "2024-00-15" | grep -E "$DATE_REGEX"  # ne correspond pas (mois 00)
```

### 7.4 Extraire avec `grep -oE`

```bash
# -o : afficher uniquement la partie correspondante
# -E : ERE

# Extraire toutes les URLs d'un fichier HTML
grep -oE 'https?://[a-zA-Z0-9./_?&=-]+' page.html

# Extraire les numéros de version
grep -oE '[0-9]+\.[0-9]+\.[0-9]+' changelog.txt

# Extraire les hashtags d'un fichier texte
grep -oE '#[a-zA-Z0-9_]+' tweets.txt

# Extraire les adresses MAC
grep -oE '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' config.txt
```

---

## 8. `sed` avec des regex avancées

### 8.1 Substitutions complexes

```bash
# Reformater des numéros de téléphone
# 0612345678 → 06 12 34 56 78
sed -E 's/([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})/\1 \2 \3 \4 \5/' phones.txt

# Supprimer les balises HTML
sed -E 's/<[^>]+>//g' page.html

# Remplacer les URLs par [LIEN]
sed -E 's|https?://[^ ]+|[LIEN]|g' document.txt

# Ajouter des guillemets autour des valeurs CSV
sed -E 's/([^,]+)/"\1"/g' data.csv

# Normaliser les espaces multiples
sed -E 's/[[:space:]]+/ /g' fichier.txt
```

### 8.2 BRE vs ERE dans sed

```bash
# BRE (defaut) : groupes avec \( \)
sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\3\/\2\/\1/' dates.txt

# ERE avec -E : syntaxe plus claire
sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/' dates.txt

# Supprimer commentaires et lignes vides
sed -E '/^[[:space:]]*(#|$)/d' config.txt

# Extraire la valeur d'une clé dans un fichier de config
sed -n -E 's/^PORT=([0-9]+).*/\1/p' .env
```

### 8.3 Adresses de lignes avec regex

```bash
# Agir uniquement sur les lignes correspondant au pattern
sed '/^#/d' config.txt          # Supprimer commentaires
sed '/error/s/error/ERROR/g' log.txt  # Mettre ERROR en majuscule sur lignes contenant error

# Entre deux patterns (inclusif)
sed -n '/^START$/,/^END$/p' fichier.txt

# De la ligne N jusqu'au prochain pattern
sed '10,/^---/d' fichier.txt
```

> **Piège courant** : Dans `sed`, le séparateur par défaut est `/`. Si votre pattern contient des `/` (ex: chemin de fichier), utilisez un autre séparateur : `sed 's|/ancien/chemin|/nouveau/chemin|g'`.

---

## 9. `awk` avec des regex

### 9.1 Opérateurs `~` et `!~`

```bash
# ~ : le champ correspond au pattern
# !~ : le champ ne correspond pas

awk '$1 ~ /^[0-9]/' fichier.txt       # Lignes dont le 1er champ commence par un chiffre
awk '$3 !~ /^$/' fichier.txt          # Lignes dont le 3e champ n'est pas vide
awk '$0 ~ /ERROR|WARN/' logs.txt      # Lignes contenant ERROR ou WARN
awk 'NR > 1 && $2 ~ /^[0-9.]+$/' data.csv  # Ligne > 1 avec champ 2 numérique
```

### 9.2 `sub()` et `gsub()`

```bash
# sub() : remplace la première occurrence
awk '{sub(/foo/, "bar"); print}' fichier.txt

# gsub() : remplace toutes les occurrences
awk '{gsub(/  +/, " "); print}' fichier.txt  # Normaliser espaces

# gsub() avec groupes (via match())
awk '{
    while (match($0, /[0-9]+/, arr)) {
        printf "[%s] ", arr[0]
        $0 = substr($0, RSTART + RLENGTH)
    }
    print ""
}' fichier.txt
```

### 9.3 `match()` et extraction

```bash
# match() : trouver un pattern et obtenir position/longueur
awk '{
    if (match($0, /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)) {
        print "IP trouvée:", substr($0, RSTART, RLENGTH)
    }
}' access.log

# Avec gawk (GNU awk) : match() avec tableau de capture
gawk '{
    if (match($0, /([0-9]{4})-([0-9]{2})-([0-9]{2})/, arr)) {
        print "Année:", arr[1], "Mois:", arr[2], "Jour:", arr[3]
    }
}' dates.txt
```

---

## 10. Exemples pratiques

### 10.1 Extraire les IPs d'un log Apache

```bash
# Extraire et compter les IPs uniques
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -rn | head 20

# Filtrer les IPs d'une plage réseau
grep -E '^192\.168\.[0-9]{1,3}\.' access.log

# Exclure les IPs locales
grep -vE '^(127\.|192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)' access.log
```

### 10.2 Valider et parser des formats

```bash
#!/bin/bash
# Validation de données d'entrée

valider_code_postal() {
    local cp="$1"
    if [[ "$cp" =~ ^[0-9]{5}$ ]]; then
        echo "Code postal valide: $cp"
    else
        echo "Erreur: $cp n'est pas un code postal valide" >&2
        return 1
    fi
}

extraire_domaine() {
    local url="$1"
    echo "$url" | grep -oP '(?<=https?://)[^/]+'
}

# Extraire les erreurs HTTP 4xx d'un log
extraire_erreurs() {
    local logfile="$1"
    awk '$9 ~ /^4[0-9]{2}$/ {print $1, $7, $9}' "$logfile"
}
```

### 10.3 Parser un CSV simple

```bash
#!/bin/bash
# Parser CSV avec awk et regex

parse_csv() {
    local fichier="$1"
    local colonne="${2:-1}"

    awk -F',' -v col="$colonne" '
    NR > 1 {  # Sauter l'"'"'en-tête
        # Gérer les champs entre guillemets
        gsub(/^"/, "", $col)
        gsub(/"$/, "", $col)
        if ($col ~ /[^[:space:]]/) print $col
    }' "$fichier"
}

# Extraire et valider des emails d'un CSV
extraire_emails() {
    local fichier="$1"
    grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$fichier" | sort -u
}
```

### 10.4 Parser un JSON simple avec regex

```bash
# Extraire une valeur d'un JSON simple (sans jq)
# Pour des JSON complexes, utilisez toujours jq !

# Extraire la valeur d'une clé string
json_get() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -oP "(?<=\"${key}\":\s?\")[^\"]+"
}

# Exemple
json='{"name": "Alice", "city": "Paris", "age": "30"}'
json_get "$json" "name"   # Résultat : Alice
json_get "$json" "city"   # Résultat : Paris

# Extraire une valeur numérique
json_get_num() {
    local json="$1"
    local key="$2"
    echo "$json" | grep -oP "(?<=\"${key}\":\s?)[0-9]+"
}
```

> **Astuce pro** : Pour parser du JSON réel, installez `jq`. Les regex sur JSON deviennent vite fragiles face aux variations de formatage. `echo "$json" | jq -r '.name'` est toujours plus fiable.

---

## 11. Cas d'usage avancés

### 11.1 Réécriture de liens Markdown

```bash
# Convertir les liens absolus en relatifs
sed -E 's|\[([^\]]+)\]\(https://example\.com(/[^)]*)\)|\[\1\](\2)|g' doc.md

# Extraire tous les liens d'un fichier Markdown
grep -oE '\[([^\]]+)\]\(([^)]+)\)' doc.md | grep -oE '\([^)]+\)' | tr -d '()'
```

### 11.2 Analyser des logs structurés

```bash
#!/bin/bash
# Analyser un log au format : [DATE] LEVEL: message

analyser_log() {
    local logfile="$1"

    echo "=== Résumé par niveau ==="
    grep -oP '(?<=\] )\w+(?=:)' "$logfile" | sort | uniq -c | sort -rn

    echo ""
    echo "=== Erreurs récentes ==="
    grep -P '\] ERROR:' "$logfile" | tail -10

    echo ""
    echo "=== Distribution horaire ==="
    grep -oP '\d{2}(?=:\d{2}:\d{2}\])' "$logfile" | sort | uniq -c
}

# Extraire les requêtes lentes (>1000ms)
grep_requetes_lentes() {
    local logfile="$1"
    grep -P 'duration=\d{4,}' "$logfile" | grep -oP 'duration=\K\d+'
}
```

### 11.3 Nettoyage de données

```bash
# Supprimer les accents (substitution caractère par caractère)
iconv -f utf-8 -t ascii//TRANSLIT fichier.txt

# Normaliser les fins de ligne (CRLF → LF)
sed -i 's/\r$//' fichier.txt
# Ou avec tr :
tr -d '\r' < windows.txt > unix.txt

# Supprimer les caractères non-imprimables
sed 's/[^[:print:]]//g' fichier.txt
# Avec PCRE :
grep -oP '[\x20-\x7E]+' fichier.txt
```

---

## Tableau récapitulatif

| Outil | Syntaxe | Groupes capturants | Lookahead | Groupes nommés |
|-------|---------|-------------------|-----------|---------------|
| `grep` | BRE (défaut) | `\( \)` → `\1` | Non | Non |
| `grep -E` | ERE | `( )` → `\1` | Non | Non |
| `grep -P` | PCRE | `( )` → `\1` | Oui | Oui `(?P<n>)` |
| `sed` | BRE (défaut) | `\( \)` → `\1` | Non | Non |
| `sed -E` | ERE | `( )` → `\1` | Non | Non |
| `awk` | ERE | `( )` (via match gawk) | Non | Non |

## À retenir

- **BRE** : syntaxe par défaut de `grep` et `sed` — les métacaractères `+?|(){}` doivent être échappés avec `\`
- **ERE** (`-E`) : syntaxe naturelle, plus lisible, recommandée pour les scripts
- **PCRE** (`-P`) : lookahead, lookbehind, groupes nommés — réservé aux cas complexes
- `grep -oE` extrait uniquement les parties correspondantes — précieux pour le parsing
- Les références arrières `\1` `\2` dans `sed` permettent de réorganiser des champs
- Pour du JSON/YAML réels, utilisez `jq`/`yq` — les regex ont leurs limites face aux formats imbriqués

➡️ [Chapitre 13 — Robustesse et gestion d'erreurs](../13_robustesse_erreurs/README.md)
