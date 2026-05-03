# Chapitre 14 — Bash avancé

Au-delà des scripts simples, Bash offre des structures de données riches, des mécanismes de substitution puissants et des outils de bas niveau rarement documentés. Ce chapitre explore les fonctionnalités avancées qui font la différence entre un script fonctionnel et un script élégant et performant.

---

## 1. Tableaux indexés

### 1.1 Déclaration et initialisation

```bash
# Déclaration explicite
declare -a fruits

# Initialisation directe
fruits=("pomme" "banane" "cerise" "datte")

# Initialisation avec indices explicites
jours=([0]="lundi" [1]="mardi" [6]="dimanche")

# Ajout d'un élément
fruits+=("figue")

# Assignation par indice
fruits[10]="mangue"   # Les indices peuvent être discontinus
```

### 1.2 Accès aux éléments

```bash
fruits=("pomme" "banane" "cerise" "datte" "figue")

echo "${fruits[0]}"       # pomme (premier élément)
echo "${fruits[2]}"       # cerise
echo "${fruits[-1]}"      # figue (dernier élément, Bash 4.3+)
echo "${fruits[@]}"       # tous les éléments
echo "${fruits[*]}"       # tous les éléments (séparés par IFS)
echo "${#fruits[@]}"      # nombre d'éléments : 5
echo "${!fruits[@]}"      # indices : 0 1 2 3 4
```

### 1.3 Slices et sous-tableaux

```bash
fruits=("pomme" "banane" "cerise" "datte" "figue")

# ${array[@]:offset:length}
echo "${fruits[@]:1:3}"   # banane cerise datte (à partir de l'indice 1, 3 éléments)
echo "${fruits[@]:2}"     # cerise datte figue (à partir de l'indice 2)
echo "${fruits[@]: -2}"   # datte figue (2 derniers, notez l'espace avant -)

# Copie partielle dans un nouveau tableau
sous=("${fruits[@]:1:3}")
echo "${sous[@]}"         # banane cerise datte
```

### 1.4 Manipulation

```bash
# Supprimer un élément (laisse un trou dans les indices)
unset 'fruits[2]'
echo "${fruits[@]}"       # pomme banane datte figue

# Reconstruire un tableau sans trous
fruits=("${fruits[@]}")   # Réindexe à partir de 0

# Itération
for fruit in "${fruits[@]}"; do
    echo "Fruit : $fruit"
done

# Itération avec indices
for i in "${!fruits[@]}"; do
    echo "[$i] = ${fruits[$i]}"
done

# Trier un tableau
IFS=$'\n' sorted=($(sort <<<"${fruits[*]}")); unset IFS
```

> **Piège courant** : `"${tableau[*]}"` concatène tous les éléments en une seule chaîne (séparateur = premier caractère d'`IFS`). `"${tableau[@]}"` les traite comme des éléments séparés. Utilisez toujours `[@]` pour itérer.

---

## 2. Tableaux associatifs (dictionnaires)

### 2.1 Déclaration et usage

```bash
# Déclaration obligatoire avec declare -A
declare -A capitales

# Assignation
capitales["France"]="Paris"
capitales["Allemagne"]="Berlin"
capitales["Japon"]="Tokyo"
capitales["Brésil"]="Brasília"

# Initialisation en une ligne
declare -A config=(
    [host]="localhost"
    [port]="5432"
    [user]="admin"
    [dbname]="production"
)
```

### 2.2 Accès et tests

```bash
# Accès
echo "${capitales["France"]}"     # Paris
echo "${config[port]}"            # 5432

# Nombre d'entrées
echo "${#capitales[@]}"           # 4

# Toutes les clés
echo "${!capitales[@]}"           # France Allemagne Japon Brésil

# Toutes les valeurs
echo "${capitales[@]}"            # Paris Berlin Tokyo Brasília

# Tester si une clé existe
if [[ -v capitales["France"] ]]; then
    echo "Clé trouvée"
fi

# Ou avec expansion :
if [[ -n "${capitales["Italie"]+existe}" ]]; then
    echo "Italie est dans le tableau"
fi
```

### 2.3 Itération sur un tableau associatif

```bash
declare -A scores=(
    [Alice]=95
    [Bob]=87
    [Charlie]=92
    [Diana]=88
)

# Itérer sur les clés
for nom in "${!scores[@]}"; do
    echo "$nom : ${scores[$nom]}"
done

# Trier par clé
for nom in $(echo "${!scores[@]}" | tr ' ' '\n' | sort); do
    echo "$nom : ${scores[$nom]}"
done

# Trier par valeur
for nom in $(
    for k in "${!scores[@]}"; do echo "${scores[$k]} $k"; done | sort -rn | awk '{print $2}'
); do
    echo "$nom : ${scores[$nom]}"
done
```

### 2.4 Cas d'usage : comptage de fréquences

```bash
#!/bin/bash
declare -A freq

while read -r mot; do
    ((freq["$mot"]++)) || true
done < <(tr -s '[:space:]' '\n' < document.txt | tr '[:upper:]' '[:lower:]')

# Afficher les 10 mots les plus fréquents
for mot in "${!freq[@]}"; do
    echo "${freq[$mot]} $mot"
done | sort -rn | head 10
```

---

## 3. Here-documents et here-strings

### 3.1 Here-document `<<EOF`

```bash
# Bloc de texte multi-lignes
cat <<EOF
Bonjour $USER,
Nous sommes le $(date +%d/%m/%Y).
Votre home est : $HOME
EOF

# Désactiver l'expansion des variables avec 'EOF' quoté
cat <<'EOF'
Ceci est $USER (non expansé)
Et $(date) non plus
EOF

# Indentation avec <<-EOF (supprime les tabulations initiales)
if true; then
    cat <<-EOF
        Cette ligne est indentée dans le code
        mais pas dans la sortie
    EOF
fi
```

### 3.2 Here-document pour écrire des fichiers

```bash
# Créer un fichier de configuration
cat > /tmp/nginx.conf <<EOF
server {
    listen 80;
    server_name ${DOMAINE:-localhost};
    root /var/www/html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Écrire un script en une opération
cat > /usr/local/bin/mon-outil <<'SCRIPT'
#!/bin/bash
echo "Outil installé"
SCRIPT
chmod +x /usr/local/bin/mon-outil
```

### 3.3 Here-string `<<<`

```bash
# Envoyer une chaîne comme stdin
grep "pattern" <<< "ma chaîne à tester"

# Convertir en majuscules
tr '[:lower:]' '[:upper:]' <<< "hello world"

# Parser une valeur
read -r annee mois jour <<< "2024-03-15"

# Alimenter une boucle while
while read -r ligne; do
    echo "Lu : $ligne"
done <<< "$(ls /tmp)"
```

> **Astuce pro** : Préférez `<<<` à `echo "..." |` car le here-string évite un sous-shell supplémentaire et est plus lisible pour les chaînes courtes.

---

## 4. Substitution de processus

### 4.1 `<(commande)` — En entrée

```bash
# Comparer deux listes triées sans fichiers temporaires
diff <(ls /dir1 | sort) <(ls /dir2 | sort)

# Joindre deux fichiers CSV sur une colonne commune
join <(sort -k1 fichier1.csv) <(sort -k1 fichier2.csv)

# Comparer deux sorties de commandes
diff <(ssh serveur1 'cat /etc/hosts') <(ssh serveur2 'cat /etc/hosts')

# Lire depuis une commande dans un while (sans sous-shell !)
while IFS= read -r ligne; do
    echo "Traitement: $ligne"
done < <(find /var/log -name "*.log" -newer /tmp/ref)
```

### 4.2 `>(commande)` — En sortie

```bash
# Dupliquer vers deux destinations
cat fichier.txt | tee >(grep "ERROR" > erreurs.log) >(grep "WARN" > warnings.log) > /dev/null

# Compression à la volée
tar cf >(gzip > archive.tar.gz) /repertoire/

# Logger et continuer
mon_script 2> >(logger -t monscript)
```

> **Piège courant** : La substitution de processus crée un fichier spécial dans `/dev/fd/` — elle ne fonctionne pas dans tous les shells (uniquement Bash/Zsh, pas sh/dash). Vérifiez la compatibilité si vos scripts doivent être portables.

---

## 5. Coprocessus `coproc`

```bash
# Démarrer un coprocessus
coproc MON_PROC { while read -r line; do echo "Echo: $line"; done; }

# Communiquer avec lui
echo "Bonjour" >&"${MON_PROC[1]}"    # Écrire vers son stdin
read -r reponse <&"${MON_PROC[0]}"   # Lire son stdout
echo "$reponse"   # Echo: Bonjour

# Cas d'usage : coprocessus SQL interactif
coproc PSQL { psql -U admin mydb; }
echo "SELECT count(*) FROM users;" >&"${PSQL[1]}"
read -r count <&"${PSQL[0]}"

# Fermer le coprocessus
exec {PSQL[1]}>&-   # Fermer stdin du coproc
wait "${PSQL_PID}"  # Attendre sa fin
```

---

## 6. `eval` — Puissance et dangers

```bash
# eval exécute une chaîne comme code Bash
commande="ls -la /tmp"
eval "$commande"

# Construire dynamiquement des noms de variables
for env in dev staging prod; do
    declare "URL_${env^^}=https://${env}.example.com"
done
eval "echo \$URL_PROD"   # https://prod.example.com

# Alternative plus sûre : tableaux associatifs
declare -A URL
URL[dev]="https://dev.example.com"
URL[prod]="https://prod.example.com"
echo "${URL[prod]}"   # Plus sûr qu'eval
```

> **Piège courant** : `eval` est dangereux avec des entrées utilisateur non validées. `eval "ls $user_input"` avec `user_input="; rm -rf /"` est catastrophique. N'utilisez `eval` que sur des chaînes que vous contrôlez entièrement. Préférez les tableaux associatifs ou `declare -n` (nameref).

---

## 7. `mapfile` / `readarray`

```bash
# Lire un fichier dans un tableau (une ligne par élément)
mapfile -t lignes < /etc/hosts

# Équivalent avec readarray
readarray -t lignes < /etc/hosts

echo "Nombre de lignes : ${#lignes[@]}"
echo "Première ligne : ${lignes[0]}"

# Ignorer les premières lignes (header)
mapfile -t -s 1 donnees < data.csv   # Sauter la première ligne

# Depuis une commande
mapfile -t processus < <(ps aux | awk 'NR>1 {print $1, $2, $11}')

# Lire N lignes à la fois
mapfile -t -n 100 chunk < fichier_large.txt   # Lire 100 lignes

# Traitement par blocs
while mapfile -t -n 50 batch < fichier.txt && ((${#batch[@]} > 0)); do
    echo "Traitement de ${#batch[@]} lignes"
    # traiter "${batch[@]}"
done
```

---

## 8. `declare` et ses options

### 8.1 Tableau des flags declare

| Flag | Signification | Exemple |
|------|--------------|---------|
| `-r` | Readonly (constante) | `declare -r PI=3.14159` |
| `-i` | Integer (arithmétique auto) | `declare -i compteur=0` |
| `-x` | Export (variable d'env) | `declare -x PATH` |
| `-a` | Tableau indexé | `declare -a fruits` |
| `-A` | Tableau associatif | `declare -A config` |
| `-f` | Fonction | `declare -f ma_fonction` |
| `-F` | Lister les fonctions | `declare -F` |
| `-p` | Afficher la déclaration | `declare -p ma_var` |
| `-n` | Nameref (référence) | `declare -n ref=autre_var` |

```bash
# Readonly : constante
declare -r VERSION="1.2.3"
VERSION="2.0.0"  # Erreur : readonly variable

# Integer : opérations arithmétiques sans $(( ))
declare -i count=0
count=count+1    # Arithmétique automatique
count+=5         # Aussi arithmétique

# Print : voir la déclaration complète
declare -p PATH     # declare -x PATH="..."
declare -p fruits   # declare -a fruits=([0]="pomme" ...)

# Lister toutes les fonctions
declare -F
declare -f ma_fonction  # Afficher le code de la fonction
```

### 8.2 `nameref` — Références de variables

```bash
# declare -n crée une référence à une autre variable
declare -n ref=ma_variable
ma_variable="bonjour"
echo "$ref"   # bonjour

ref="modifié"
echo "$ma_variable"  # modifié

# Cas d'usage : passer un tableau à une fonction
modifier_tableau() {
    declare -n tableau_ref="$1"
    tableau_ref+=("nouvel_element")
}

fruits=("pomme" "banane")
modifier_tableau fruits
echo "${fruits[@]}"   # pomme banane nouvel_element

# Retourner une valeur depuis une fonction
calculer() {
    declare -n _result="$1"
    local a="$2" b="$3"
    _result=$((a + b))
}

calculer mon_resultat 10 20
echo "$mon_resultat"  # 30
```

---

## 9. `printf` avancé

### 9.1 Formats et padding

```bash
# Formats de base
printf "%-20s %5d %8.2f\n" "Article"  42   3.14
printf "%-20s %5d %8.2f\n" "Produit"  7   99.99
printf "%-20s %5d %8.2f\n" "Service"  1  149.00

# Sortie alignée :
# Article               42     3.14
# Produit                7    99.99
# Service                1   149.00

# Padding avec zéros
printf "%05d\n" 42      # 00042
printf "%010.3f\n" 3.14  # 000003.140

# Formats spéciaux
printf "%x\n" 255        # ff (hexadécimal)
printf "%o\n" 8          # 10 (octal)
printf "%b\n" "a\tb\n"  # a	b (avec tabulation et newline)
printf "%q\n" "hello world"  # 'hello world' (shell-escaped)
```

### 9.2 Couleurs ANSI avec printf

```bash
# Codes ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Affichage coloré
printf "${GREEN}[OK]${RESET} %s\n" "Traitement réussi"
printf "${RED}[ERREUR]${RESET} %s\n" "Fichier introuvable"
printf "${YELLOW}[AVERT]${RESET} %s\n" "Espace disque faible"

# Barre de progression
progress_bar() {
    local current="$1"
    local total="$2"
    local width=50
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))
    local bar=""
    bar+=$(printf '#%.0s' $(seq 1 $filled))
    bar+=$(printf '.%.0s' $(seq 1 $empty))
    printf "\r[${bar}] %d/%d (%.0f%%)" "$current" "$total" "$(echo "scale=0; $current * 100 / $total" | bc)"
}

for i in $(seq 1 100); do
    progress_bar "$i" 100
    sleep 0.05
done
echo ""
```

---

## 10. Arithmétique : entière vs flottante

### 10.1 Arithmétique entière avec `(( ))`

```bash
# (( )) : arithmétique entière native
a=10; b=3
echo $(( a + b ))    # 13
echo $(( a - b ))    # 7
echo $(( a * b ))    # 30
echo $(( a / b ))    # 3 (division entière !)
echo $(( a % b ))    # 1 (modulo)
echo $(( a ** b ))   # 1000 (puissance)

# Opérateurs combinés
(( a++ ))     # Post-incrément
(( ++a ))     # Pré-incrément
(( a += 5 ))  # Incrément de 5
(( a *= 2 ))  # Doubler

# Bits
echo $(( 5 & 3 ))   # 1 (AND)
echo $(( 5 | 3 ))   # 7 (OR)
echo $(( 5 ^ 3 ))   # 6 (XOR)
echo $(( ~5 ))      # -6 (NOT)
echo $(( 5 << 1 ))  # 10 (shift left)
echo $(( 5 >> 1 ))  # 2 (shift right)
```

### 10.2 Arithmétique flottante avec `bc`

```bash
# bc : calculatrice en ligne de commande
echo "scale=4; 10 / 3" | bc         # 3.3333
echo "scale=2; sqrt(2)" | bc -l     # 1.41
echo "scale=5; 4*a(1)" | bc -l      # 3.14159 (π, avec -l pour les fonctions math)

# Fonctions disponibles avec bc -l :
# s(x)   sin(x)
# c(x)   cos(x)
# a(x)   arctan(x)
# l(x)   log naturel
# e(x)   e^x
# sqrt(x)

# Intégration dans un script
calcul_tva() {
    local ht="$1"
    local taux="${2:-20}"
    echo "scale=2; $ht * (1 + $taux / 100)" | bc
}

calcul_tva 100      # 120.00
calcul_tva 49.99 10 # 54.98

# Comparaison de flottants
est_superieur() {
    local a="$1" b="$2"
    [[ $(echo "$a > $b" | bc) -eq 1 ]]
}
```

---

## 11. `IFS` — Séparateur de champs

### 11.1 Comportement d'IFS

```bash
# IFS par défaut : espace, tabulation, newline
# Impact sur read
ligne="alice:30:Paris"

# Sans IFS modifié
read -r champ1 champ2 champ3 <<< "$ligne"
# champ1 = "alice:30:Paris" (tout dans le premier champ)

# Avec IFS modifié
IFS=: read -r nom age ville <<< "$ligne"
echo "$nom $age $ville"   # alice 30 Paris
```

### 11.2 Impact sur l'expansion

```bash
# IFS et word splitting
fruits="pomme banane cerise"
IFS=, lire en tableau
IFS=' ' read -ra tableau <<< "$fruits"
echo "${tableau[1]}"   # banane

# Parser un PATH
IFS=: read -ra chemins <<< "$PATH"
for chemin in "${chemins[@]}"; do
    echo "  $chemin"
done

# Jointure de tableau avec IFS
tableau=("a" "b" "c" "d")
IFS=, ; joint="${tableau[*]}"
echo "$joint"   # a,b,c,d
unset IFS       # Toujours restaurer !
```

### 11.3 Bonne pratique avec IFS

```bash
# Sauvegarder et restaurer IFS
ancien_ifs="$IFS"
IFS=:
# ... opérations ...
IFS="$ancien_ifs"

# Ou utiliser un sous-shell pour isoler
(
    IFS=:
    read -ra parties <<< "a:b:c"
    echo "${parties[@]}"
)
# IFS original préservé dans le shell parent

# Lecture ligne par ligne sans modifier IFS global
while IFS= read -r ligne; do
    # IFS vide : préserve les espaces en début/fin de ligne
    echo "'$ligne'"
done < fichier.txt
```

> **Piège courant** : Ne jamais oublier de restaurer `IFS` après l'avoir modifié. Une modification persistante d'`IFS` peut casser tous les traitements suivants dans le script. La forme `IFS=: command args` (IFS local à la commande) est la plus sûre.

---

## Tableau récapitulatif

| Fonctionnalité | Syntaxe clé | Usage |
|---------------|------------|-------|
| Tableau indexé | `arr=(...); ${arr[@]}` | Listes ordonnées |
| Tableau associatif | `declare -A map; ${!map[@]}` | Dictionnaires clé/valeur |
| Here-document | `<<EOF ... EOF` | Blocs de texte multi-lignes |
| Here-string | `<<< "texte"` | Stdin depuis une chaîne |
| Substitution processus | `<(cmd)` `>(cmd)` | Pipes sans fichiers temporaires |
| Coprocessus | `coproc NOM { ... }` | Processus interactif bidirectionnel |
| mapfile | `mapfile -t arr < fichier` | Fichier → tableau |
| declare -n | `declare -n ref=var` | Références de variables |
| printf couleurs | `\033[0;31m` | Sorties colorées |
| bc | `echo "expr" \| bc` | Arithmétique flottante |
| IFS | `IFS=: read -ra arr` | Parsing de champs |

## À retenir

- Utilisez `"${tableau[@]}"` (avec guillemets) pour itérer sur un tableau — jamais `${tableau[*]}`
- `declare -A` est indispensable pour les tableaux associatifs — sans elle, c'est un tableau indexé ordinaire
- La substitution de processus `<(cmd)` est plus propre que les fichiers temporaires et évite des sous-shells inutiles
- `declare -n` (nameref) remplace avantageusement `eval` pour les références de variables
- Sauvegardez et restaurez toujours `IFS` après modification
- `(( ))` pour l'arithmétique entière, `bc` pour les flottants

➡️ [Chapitre 15 — Administration système](../15_administration_systeme/README.md)
