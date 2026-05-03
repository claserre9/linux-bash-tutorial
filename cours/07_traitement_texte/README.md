# Chapitre 7 — Traitement de texte : sed, awk, cut, sort, uniq, tr, wc

Le traitement de texte est l'une des forces majeures de l'environnement Unix/Linux. Plutôt que d'ouvrir un éditeur graphique, on enchaîne des outils spécialisés dans des pipelines pour transformer, filtrer et analyser des données textuelles à la volée. Ce chapitre couvre les outils fondamentaux de la boîte à outils Unix, de `cut` à `awk`.

---

## 1. `cut` — Extraire des colonnes

`cut` extrait des portions de chaque ligne d'un fichier ou de l'entrée standard.

### 1.1 Découpe par délimiteur (`-d` et `-f`)

```bash
# Fichier exemple : /etc/passwd
# root:x:0:0:root:/root:/bin/bash

# Extraire le 1er champ (nom d'utilisateur)
cut -d: -f1 /etc/passwd

# Extraire les champs 1 et 3 (nom et UID)
cut -d: -f1,3 /etc/passwd

# Extraire les champs 1 à 4
cut -d: -f1-4 /etc/passwd

# Extraire à partir du 5e champ jusqu'à la fin
cut -d: -f5- /etc/passwd

# Avec un fichier CSV
echo "Alice,30,Paris,Développeuse" | cut -d, -f2,4
# 30,Développeuse
```

### 1.2 Découpe par position de caractère (`-c`)

```bash
# Extraire les caractères 1 à 10
cut -c1-10 fichier.txt

# Extraire le premier caractère de chaque ligne
cut -c1 fichier.txt

# Extraire les caractères 5 à 15
ls -la | cut -c5-15

# Obtenir les 8 premiers caractères d'un hash
echo "a1b2c3d4e5f6" | cut -c1-8
# a1b2c3d4
```

> **Piège courant** : `cut` ne gère pas les délimiteurs multiples (espaces consécutifs). Pour des fichiers séparés par des espaces variables, utilisez `awk` à la place.

---

## 2. `sort` — Trier des lignes

`sort` trie les lignes d'un fichier ou de l'entrée standard.

### 2.1 Options essentielles

```bash
# Tri alphabétique (par défaut)
sort fichier.txt

# Tri numérique (-n)
sort -n nombres.txt

# Tri inversé (-r)
sort -r fichier.txt

# Tri numérique inversé
sort -rn nombres.txt

# Supprimer les doublons lors du tri (-u)
sort -u fichier.txt

# Tri stable (-s ou --stable) — préserve l'ordre des lignes égales
sort --stable -k2 fichier.txt
```

### 2.2 Tri par colonne (`-k` et `-t`)

```bash
# Fichier : prenom,nom,age,ville
# Alice,Martin,30,Paris
# Bob,Dupont,25,Lyon
# Charlie,Martin,28,Bordeaux

# Trier par le 3e champ (age) numériquement, délimiteur virgule
sort -t, -k3 -n employes.csv

# Trier par le 2e champ (nom) puis par le 3e (age)
sort -t, -k2,2 -k3,3n employes.csv

# Trier par la 5e colonne numériquement (ls -l)
ls -l | sort -k5 -n

# Trier les processus par utilisation CPU (champ 3)
ps aux | sort -k3 -rn | head -10
```

### 2.3 Tri de tailles humaines (`-h`)

```bash
# Trier les tailles de fichiers au format humain (Ko, Mo, Go)
du -sh * | sort -h

# Trouver les 5 plus gros répertoires
du -sh /var/* 2>/dev/null | sort -rh | head -5
```

> **Astuce pro** : Combinez `sort -u` avec des pipelines pour dédoublonner efficacement sans passer par `uniq`. Mais `sort | uniq -c` vous donnera le compte des occurrences.

---

## 3. `uniq` — Dédoublonner des lignes

`uniq` supprime ou compte les lignes consécutives identiques. **Les entrées doivent être triées** pour que `uniq` fonctionne correctement.

```bash
# Supprimer les doublons (lignes consécutives identiques)
sort fichier.txt | uniq

# Compter les occurrences de chaque ligne (-c)
sort fichier.txt | uniq -c

# Afficher uniquement les lignes dupliquées (-d)
sort fichier.txt | uniq -d

# Afficher uniquement les lignes uniques (-u)
sort fichier.txt | uniq -u

# Top 10 des IPs les plus fréquentes dans un log
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# Trouver les doublons dans un fichier de mails
sort emails.txt | uniq -d

# Compter le nombre de lignes uniques
sort fichier.txt | uniq | wc -l
```

> **Piège courant** : `uniq` ne fonctionne que sur des lignes **consécutives**. Sans `sort` en amont, des doublons non adjacents ne seront pas détectés.

---

## 4. `tr` — Transformer des caractères

`tr` traduit, supprime ou compresse des caractères. Il lit toujours depuis l'entrée standard.

### 4.1 Substitution

```bash
# Convertir en majuscules
echo "hello world" | tr 'a-z' 'A-Z'
# HELLO WORLD

# Convertir en minuscules
echo "HELLO WORLD" | tr 'A-Z' 'a-z'
# hello world

# Remplacer les espaces par des underscores
echo "nom de fichier" | tr ' ' '_'
# nom_de_fichier

# Remplacer les virgules par des tabulations
cat csv.txt | tr ',' '\t'

# Remplacer les sauts de ligne par des espaces
tr '\n' ' ' < fichier.txt
```

### 4.2 Suppression (`-d`)

```bash
# Supprimer tous les chiffres
echo "abc123def456" | tr -d '0-9'
# abcdef

# Supprimer les retours chariot Windows (\r)
tr -d '\r' < fichier_windows.txt > fichier_unix.txt

# Supprimer les espaces
echo "h e l l o" | tr -d ' '
# hello

# Supprimer les caractères non alphanumériques
echo "Hello, World! 123" | tr -d -c 'a-zA-Z0-9\n'
# HelloWorld123
```

### 4.3 Compression (`-s`)

```bash
# Compresser les espaces multiples en un seul
echo "trop    d'espaces    ici" | tr -s ' '
# trop d'espaces ici

# Compresser les sauts de ligne multiples
tr -s '\n' < fichier.txt

# Compresser et remplacer
echo "aabbccdd" | tr -s 'a-z'
# abcd
```

> **Astuce pro** : Pour convertir des fins de ligne DOS (CRLF) en Unix (LF), utilisez `tr -d '\r' < input.txt > output.txt`. C'est plus rapide que `sed 's/\r//'`.

---

## 5. `wc` — Compter lignes, mots et caractères

```bash
# Compter lignes, mots et octets
wc fichier.txt
# 42 153 1024 fichier.txt

# Compter seulement les lignes (-l)
wc -l fichier.txt
wc -l /etc/passwd

# Compter seulement les mots (-w)
wc -w fichier.txt

# Compter seulement les caractères/octets (-c)
wc -c fichier.txt

# Compter les caractères Unicode (-m)
wc -m fichier.txt

# Compter plusieurs fichiers
wc -l *.log

# Trouver le fichier le plus long
wc -l *.txt | sort -n | tail -1

# Compter les lignes d'un pipeline
cat /etc/passwd | grep bash | wc -l

# Longueur de la ligne la plus longue (-L)
wc -L fichier.txt
```

---

## 6. `paste` et `join` — Fusionner des fichiers

### 6.1 `paste` — Coller des fichiers côte à côte

```bash
# Coller deux fichiers colonne par colonne (tabulation par défaut)
paste fichier1.txt fichier2.txt

# Avec un délimiteur personnalisé (-d)
paste -d, noms.txt ages.txt

# Transformer des lignes en colonnes (mode série -s)
paste -s fichier.txt

# Assembler toutes les lignes d'un fichier en une seule
paste -sd, liste.txt
# item1,item2,item3,item4

# Exemple pratique : créer un CSV
paste -d, <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)
```

### 6.2 `join` — Jointure sur un champ commun

```bash
# Fichier employes.txt : 1 Alice 30
# Fichier salaires.txt : 1 50000

# Joindre sur le premier champ (par défaut)
join employes.txt salaires.txt

# Joindre sur des champs spécifiques
join -1 2 -2 1 fichier1.txt fichier2.txt
# -1 2 : champ 2 du fichier 1
# -2 1 : champ 1 du fichier 2

# Inclure les lignes sans correspondance
join -a 1 fichier1.txt fichier2.txt

# Avec un délimiteur
join -t, -1 1 -2 1 fichier1.csv fichier2.csv
```

> **Piège courant** : `join` exige que les deux fichiers soient **triés sur le champ de jointure**. Utilisez `sort -k1` avant de joindre.

---

## 7. `sed` — Éditeur de flux

`sed` (Stream EDitor) est un éditeur non-interactif qui applique des transformations ligne par ligne.

### 7.1 Substitution : `s/old/new/`

```bash
# Remplacer la première occurrence sur chaque ligne
sed 's/foo/bar/' fichier.txt

# Remplacer toutes les occurrences (/g = global)
sed 's/foo/bar/g' fichier.txt

# Insensible à la casse (/i)
sed 's/foo/bar/gi' fichier.txt

# Afficher seulement les lignes modifiées (/p avec -n)
sed -n 's/foo/bar/p' fichier.txt

# Remplacer le 2e occurrence seulement
sed 's/foo/bar/2' fichier.txt

# Utiliser & pour référencer la correspondance
sed 's/[0-9]*/[&]/' fichier.txt
# "abc 42 xyz" → "abc [42] xyz"

# Groupes de capture avec \1, \2...
sed 's/\(prenom\) \(nom\)/\2 \1/' fichier.txt

# Délimiteur alternatif (utile pour les chemins)
sed 's|/usr/local|/opt|g' chemins.txt
```

### 7.2 Suppression de lignes : `/pattern/d`

```bash
# Supprimer les lignes contenant "DEBUG"
sed '/DEBUG/d' application.log

# Supprimer les lignes vides
sed '/^$/d' fichier.txt

# Supprimer les commentaires (lignes commençant par #)
sed '/^#/d' config.txt

# Supprimer la ligne 5
sed '5d' fichier.txt

# Supprimer les lignes 3 à 7
sed '3,7d' fichier.txt

# Supprimer de la ligne 3 jusqu'à la fin
sed '3,$d' fichier.txt
```

### 7.3 Impression avec `-n` et `/p`

```bash
# Afficher seulement les lignes 5 à 10
sed -n '5,10p' fichier.txt

# Afficher les lignes contenant "ERROR"
sed -n '/ERROR/p' fichier.txt

# Equivalent de grep
sed -n '/pattern/p' fichier.txt

# Afficher de la ligne contenant "START" jusqu'à "END"
sed -n '/START/,/END/p' fichier.txt
```

### 7.4 Édition en place (`-i`)

```bash
# Modifier le fichier directement (SANS sauvegarde)
sed -i 's/ancien/nouveau/g' fichier.txt

# Modifier avec sauvegarde (.bak)
sed -i.bak 's/ancien/nouveau/g' fichier.txt

# Sur macOS, l'extension est obligatoire
sed -i '' 's/ancien/nouveau/g' fichier.txt

# Modifier tous les fichiers .conf dans un répertoire
sed -i 's/localhost/192.168.1.1/g' /etc/app/*.conf
```

### 7.5 Scripts multi-commandes (`-e`)

```bash
# Plusieurs commandes avec -e
sed -e 's/foo/bar/g' -e 's/baz/qux/g' fichier.txt

# Ou avec un point-virgule
sed 's/foo/bar/g; s/baz/qux/g' fichier.txt

# Script dans un fichier (-f)
cat > script.sed << 'EOF'
s/foo/bar/g
/^#/d
/^$/d
s/  */ /g
EOF
sed -f script.sed fichier.txt
```

### 7.6 Autres commandes sed utiles

```bash
# Insérer une ligne avant le pattern (i)
sed '/pattern/i\Ligne insérée avant' fichier.txt

# Ajouter une ligne après le pattern (a)
sed '/pattern/a\Ligne ajoutée après' fichier.txt

# Remplacer une ligne entière (c)
sed '/vieille ligne/c\Nouvelle ligne' fichier.txt

# Afficher le numéro de ligne (=)
sed -n '/pattern/=' fichier.txt

# Translittération (y) — équivalent de tr
sed 'y/abc/ABC/' fichier.txt
```

> **Astuce pro** : Pour des substitutions complexes sur des chemins de fichiers, utilisez `|` comme délimiteur : `sed 's|/home/user|/home/admin|g'`. Cela évite d'échapper les slashes.

---

## 8. `awk` — Traitement de données structurées

`awk` est un langage de traitement de texte orienté lignes et colonnes. C'est l'outil le plus puissant de la boîte à outils Unix pour l'analyse de données.

### 8.1 Structure d'un programme awk

```
awk 'BEGIN{init} /pattern/{action} END{final}' fichier
```

```bash
# Afficher toutes les lignes (équivalent cat)
awk '{print}' fichier.txt

# Afficher le 1er champ de chaque ligne
awk '{print $1}' fichier.txt

# Afficher les champs 1 et 3
awk '{print $1, $3}' fichier.txt

# Afficher la ligne entière ($0)
awk '{print $0}' fichier.txt

# Afficher le dernier champ ($NF)
awk '{print $NF}' fichier.txt

# Afficher l'avant-dernier champ
awk '{print $(NF-1)}' fichier.txt
```

### 8.2 Variables spéciales

```bash
# NR = numéro de ligne courant
awk '{print NR, $0}' fichier.txt

# NF = nombre de champs de la ligne courante
awk '{print NF, $0}' fichier.txt

# FS = séparateur de champs (Field Separator)
awk -F: '{print $1}' /etc/passwd
awk 'BEGIN{FS=":"}{print $1}' /etc/passwd

# OFS = séparateur de champs en sortie
awk -F: 'BEGIN{OFS=","}{print $1,$3,$6}' /etc/passwd

# RS = séparateur d'enregistrements (Record Separator)
# ORS = séparateur d'enregistrements en sortie
awk 'BEGIN{ORS=","}{print $1}' fichier.txt
```

### 8.3 Filtrage par pattern

```bash
# Afficher les lignes contenant "ERROR"
awk '/ERROR/{print}' app.log

# Afficher les lignes NE contenant PAS "DEBUG"
awk '!/DEBUG/{print}' app.log

# Condition sur un champ
awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Plage de lignes
awk 'NR>=5 && NR<=10' fichier.txt

# Plage par pattern
awk '/START/,/END/{print}' fichier.txt

# Lignes avec plus de 3 champs
awk 'NF > 3' fichier.txt
```

### 8.4 BEGIN et END

```bash
# Calculer la somme d'une colonne
awk '{sum += $1} END{print "Somme:", sum}' nombres.txt

# Compter les lignes correspondant à un pattern
awk '/ERROR/{count++} END{print count " erreurs"}' app.log

# En-tête et pied de page
awk 'BEGIN{print "=== Rapport ==="} {print} END{print "=== Fin ==="}' fichier.txt

# Statistiques basiques
awk '{sum+=$1; count++} END{print "Moy:", sum/count, "Total:", sum}' data.txt
```

### 8.5 Structures de contrôle

```bash
# if/else
awk '{if ($3 > 100) print $1, "ÉLEVÉ"; else print $1, "NORMAL"}' data.txt

# Boucle for
awk '{for(i=1; i<=NF; i++) print $i}' fichier.txt

# Boucle while
awk '{i=1; while(i<=NF) {print $i; i++}}' fichier.txt

# Boucle for sur tableau associatif
awk '{count[$1]++} END{for(ip in count) print ip, count[ip]}' access.log
```

### 8.6 Fonctions intégrées

```bash
# length() — longueur d'une chaîne ou d'un tableau
awk '{print length($0), $0}' fichier.txt

# substr() — sous-chaîne
awk '{print substr($1, 1, 3)}' fichier.txt

# split() — diviser une chaîne
awk '{n=split($1,a,"-"); for(i=1;i<=n;i++) print a[i]}' fichier.txt

# gsub() — remplacer toutes les occurrences
awk '{gsub(/foo/, "bar"); print}' fichier.txt

# sub() — remplacer la première occurrence
awk '{sub(/foo/, "bar"); print}' fichier.txt

# index() — trouver une sous-chaîne
awk '{print index($0, "ERROR")}' fichier.txt

# tolower() / toupper()
awk '{print tolower($0)}' fichier.txt
awk '{print toupper($1)}' fichier.txt

# printf — formatage
awk '{printf "%-20s %5d\n", $1, $2}' fichier.txt
awk 'END{printf "Total: %d lignes\n", NR}' fichier.txt
```

### 8.7 Tableaux associatifs

```bash
# Compter les occurrences (fréquence)
awk '{count[$1]++} END{for(k in count) print count[k], k}' fichier.txt | sort -rn

# Somme par catégorie
awk '{total[$1]+=$2} END{for(cat in total) print cat, total[cat]}' ventes.txt

# Top 5 des IPs dans un log Apache
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -5

# Dédoublonner sur un champ
awk '!seen[$1]++' fichier.txt
```

### 8.8 One-liners awk courants

```bash
# Afficher les lignes entre 10 et 20
awk 'NR==10,NR==20' fichier.txt

# Supprimer les lignes vides
awk 'NF' fichier.txt

# Numéroter les lignes
awk '{printf "%4d %s\n", NR, $0}' fichier.txt

# Calculer la somme de la dernière colonne
awk '{s+=$NF} END{print s}' fichier.txt

# Inverser l'ordre des champs
awk '{for(i=NF;i>=1;i--) printf "%s%s",$i,(i>1?OFS:ORS)}' fichier.txt

# Extraire un champ d'un CSV avec guillemets
awk -F'"' '{print $2}' fichier.csv

# Filtrer un CSV par valeur dans une colonne
awk -F, '$3 > 50000' employes.csv

# Reformatter /etc/passwd en CSV lisible
awk -F: 'BEGIN{print "User,UID,GID,Home"} {print $1","$3","$4","$6}' /etc/passwd
```

> **Astuce pro** : Le one-liner `awk '!seen[$0]++'` est l'un des plus utiles : il supprime les doublons **tout en préservant l'ordre** original, contrairement à `sort | uniq`.

---

## 9. Pipelines avancés — Combiner les outils

```bash
# Analyse d'un fichier de log : top 10 des erreurs par type
grep "ERROR" app.log \
  | awk '{print $5}' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10

# Statistiques sur les tailles de fichiers
ls -la | awk 'NR>1 && $1!~/^d/ {sum+=$5; count++} END{printf "Moyenne: %.0f octets\n", sum/count}'

# Extraire et reformater des données CSV
cut -d, -f1,3 data.csv \
  | sort -t, -k2 -n \
  | awk -F, '{printf "%-20s: %s\n", $1, $2}'

# Trouver les utilisateurs avec un shell bash
cut -d: -f1,7 /etc/passwd | grep bash | cut -d: -f1

# Compter les méthodes HTTP dans un log Apache
awk '{print $6}' access.log \
  | tr -d '"' \
  | sort \
  | uniq -c \
  | sort -rn

# Rapport de fréquence des codes HTTP
awk '{print $9}' access.log \
  | sort \
  | uniq -c \
  | sort -rn \
  | awk '{printf "%s: %d occurrences\n", $2, $1}'
```

---

## Tableau récapitulatif

| Outil | Usage principal | Options clés |
|-------|----------------|--------------|
| `cut` | Extraire colonnes | `-d` délimiteur, `-f` champs, `-c` caractères |
| `sort` | Trier lignes | `-n` numérique, `-r` inversé, `-k` colonne, `-t` délimiteur, `-u` unique |
| `uniq` | Dédoublonner | `-c` compter, `-d` doublons, `-u` uniques |
| `tr` | Transformer caractères | `-d` supprimer, `-s` compresser |
| `wc` | Compter | `-l` lignes, `-w` mots, `-c` octets, `-m` caractères |
| `paste` | Coller fichiers côte à côte | `-d` délimiteur, `-s` série |
| `join` | Jointure sur champ commun | `-1` `-2` champs, `-t` délimiteur |
| `sed` | Édition de flux | `s/old/new/g`, `/pat/d`, `-n /pat/p`, `-i` en place |
| `awk` | Traitement structuré | `-F` séparateur, `$1..$NF`, `NR`, `NF`, tableaux associatifs |

---

## À retenir

- **`cut`** est idéal pour les fichiers avec un délimiteur fixe et propre (CSV, `/etc/passwd`). Pour les espaces multiples, préférez `awk`.
- **`sort`** doit précéder **`uniq`** pour que la déduplication soit complète.
- **`tr`** ne prend en entrée que des caractères uniques, pas des chaînes. Pour les chaînes, utilisez `sed`.
- **`sed`** excelle pour les substitutions et suppressions simples. Pour la logique complexe, passez à `awk`.
- **`awk`** est un langage complet : utilisez-le pour les calculs, agrégations et reformatages de données tabulaires.
- Le one-liner `awk '!seen[$0]++'` dédoublonne **en préservant l'ordre**.
- L'option `-i` de `sed` modifie les fichiers en place — **toujours tester sans `-i` d'abord**.

➡️ [Chapitre 8 — Bash : variables, conditions, boucles](../08_bash_variables_conditions/README.md)
