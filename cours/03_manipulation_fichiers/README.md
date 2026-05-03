# Chapitre 3 — Manipulation de fichiers

Créer, copier, déplacer, supprimer, lire, comparer : voici les opérations du quotidien sous Linux. Ce chapitre couvre les commandes fondamentales et les patterns d'expansion (wildcards, accolades) qui multiplient leur puissance.

---

## 1. Créer des fichiers et répertoires

### 1.1 `touch` — Créer un fichier vide ou mettre à jour l'horodatage

```bash
# Créer un fichier vide
touch fichier.txt

# Créer plusieurs fichiers d'un coup
touch a.txt b.txt c.txt

# Créer avec une date de modification précise
touch -t 202401151200 rapport.txt   # 15 jan 2024 à 12h00
touch -d "yesterday" ancien.log

# Mettre à jour uniquement l'heure d'accès / modification
touch -a fichier.txt   # heure d'accès seulement
touch -m fichier.txt   # heure de modification seulement
```

### 1.2 `mkdir` — Créer des répertoires

```bash
# Créer un répertoire
mkdir documents

# Créer avec les parents (pas d'erreur si déjà existant)
mkdir -p projet/src/modules

# Créer avec permissions spécifiques
mkdir -m 755 public
mkdir -m 700 privé

# Créer plusieurs répertoires
mkdir docs src tests build

# Combiné avec brace expansion (voir section 8)
mkdir -p projet/{src,tests,docs}/{images,data}
```

> **Astuce pro** : `mkdir -p` est idempotent — il n'échoue pas si le répertoire existe déjà. Utilisez-le dans vos scripts pour créer des arborescences sans erreur.

---

## 2. Copier des fichiers : `cp`

```bash
# Copie simple
cp source.txt destination.txt
cp source.txt /tmp/

# Copier dans un répertoire
cp fichier.txt /home/alice/documents/

# Options essentielles
cp -r dossier/ copie/      # récursif (copie un répertoire)
cp -p source dest           # préserve les permissions, dates, propriétaire
cp -u source dest           # copie seulement si source plus récente
cp -i source dest           # demande confirmation avant écrasement
cp -v source dest           # verbeux (affiche ce qui se passe)
cp -a source/ dest/         # archive : -r + -p + liens symboliques préservés

# Sauvegardes avec --backup
cp --backup=numbered config.conf config.conf
# crée config.conf.~1~, config.conf.~2~, etc.

cp -b source dest           # backup simple (~ ajouté)

# Copier en préservant la structure
cp -a /source/. /destination/   # le point copie le contenu sans créer un sous-dossier
```

> **Piège courant** : `cp -r dossier copie` crée `/copie/dossier` si `copie` existe, mais crée directement `/copie` si `copie` n'existe pas. Ajoutez `/` à la fin de la source (`cp -r dossier/ copie/`) pour copier le **contenu**.

---

## 3. Déplacer et renommer : `mv`

```bash
# Renommer un fichier
mv ancien.txt nouveau.txt

# Déplacer dans un répertoire
mv fichier.txt /tmp/
mv fichier.txt /home/alice/documents/

# Déplacer plusieurs fichiers
mv a.txt b.txt c.txt /tmp/
mv *.log /var/log/archive/

# Options
mv -i source dest   # confirmation avant écrasement
mv -v source dest   # verbeux
mv -n source dest   # ne pas écraser si la dest existe

# Renommer en lot avec un pattern
for f in *.txt; do mv "$f" "${f%.txt}.md"; done
```

---

## 4. Supprimer : `rm`

```bash
# Supprimer un fichier
rm fichier.txt

# Options
rm -i fichier.txt      # demande confirmation
rm -f fichier.txt      # force (pas d'erreur si absent)
rm -v fichier.txt      # verbeux

# Supprimer un répertoire (vide)
rmdir dossier/

# Supprimer récursivement
rm -r dossier/         # répertoire non vide
rm -rf dossier/        # force + récursif (sans confirmation)

# Supprimer en interactif avec aperçu
rm -ri dossier/        # confirmation pour chaque fichier

# Supprimer plusieurs patterns
rm -f *.log *.tmp *~
```

> **Piège courant** : `rm -rf /` ou `rm -rf ./*` peut détruire le système. Avec `rm -rf`, relisez toujours la commande DEUX fois. Une protection : `rm --preserve-root /` (activée par défaut sur les systèmes modernes).

> **Astuce pro** : Pour la corbeille en ligne de commande, utilisez `trash-cli` : `trash fichier.txt` permet la récupération. `rm` est irréversible !

---

## 5. Lire des fichiers

### 5.1 `cat` — Concaténer et afficher

```bash
# Afficher un fichier
cat fichier.txt

# Afficher avec numéros de lignes
cat -n fichier.txt

# Afficher les caractères non-imprimables
cat -A fichier.txt    # $ en fin de ligne, ^I pour tabulations

# Concaténer plusieurs fichiers
cat fichier1.txt fichier2.txt fichier3.txt

# Créer un fichier par saisie (Ctrl+D pour terminer)
cat > nouveau.txt
Bonjour le monde
^D

# Appender à un fichier
cat >> existant.txt
Nouvelle ligne
^D
```

### 5.2 `less` et `more` — Lecture paginée

```bash
# less : pagination avancée (recommandé)
less fichier.txt
less +G fichier.txt    # commence à la fin
less +/motif fichier   # commence sur la première occurrence du motif

# Navigation dans less :
# j/k ou ↑↓        : ligne par ligne
# espace / b        : page suivante / précédente
# g / G             : début / fin du fichier
# /motif            : recherche (n = suivant, N = précédent)
# ?motif            : recherche en arrière
# q                 : quitter
# F                 : mode suivi (comme tail -f)
# v                 : ouvrir dans $EDITOR

# more : plus simple, ne permet pas de revenir en arrière
more fichier.txt
```

### 5.3 `head` et `tail` — Début et fin d'un fichier

```bash
# Afficher les 10 premières lignes (défaut)
head fichier.txt

# Nombre de lignes spécifique
head -n 20 fichier.txt
head -20 fichier.txt    # syntaxe courte

# Afficher SAUF les N dernières lignes
head -n -5 fichier.txt  # tout sauf les 5 dernières

# Afficher les 10 dernières lignes
tail fichier.txt

# Nombre de lignes spécifique
tail -n 20 fichier.txt
tail -20 fichier.txt

# Afficher depuis la N-ème ligne
tail -n +5 fichier.txt  # à partir de la ligne 5

# Suivre un fichier en temps réel
tail -f /var/log/syslog

# Suivre avec réouverture si le fichier est recréé (logrotate)
tail -F /var/log/nginx/access.log

# Combiner head et tail pour extraire des lignes
head -20 fichier.txt | tail -10  # lignes 11 à 20
sed -n '11,20p' fichier.txt      # equivalent plus direct
```

---

## 6. Liens : `ln`

### 6.1 Liens durs vs liens symboliques

```bash
# Lien dur : deux noms pour le même contenu sur le disque (même inode)
ln original.txt lien-dur.txt

# Les deux fichiers partagent le même inode
ls -li original.txt lien-dur.txt
# 123456 -rw-r--r-- 2 alice alice 100 ...

# Lien symbolique (soft link) : un pointeur vers un chemin
ln -s /chemin/vers/cible lien-symbolique
ln -s /usr/bin/python3 ~/bin/python

# Vérifier
ls -la lien-symbolique
# lrwxrwxrwx 1 alice alice 20 → /chemin/vers/cible

readlink lien-symbolique       # affiche la cible
readlink -f lien-symbolique    # cible absolue résolue

# Mettre à jour un lien symbolique
ln -sf /nouvelle/cible lien-symbolique  # -f pour forcer la mise à jour
```

| Caractéristique | Lien dur | Lien symbolique |
|----------------|----------|-----------------|
| Traversée partitions | Non | Oui |
| Cible répertoire | Non (généralement) | Oui |
| Si cible supprimée | Données restent | Lien cassé |
| Taille affichée | Taille réelle | Taille du chemin |

---

## 7. Compter et comparer : `wc`, `diff`, `patch`

### 7.1 `wc` — Word Count

```bash
# Compter lignes, mots, octets
wc fichier.txt
# 42  387 2145 fichier.txt
#  │    │    └─ octets
#  │    └─ mots
#  └─ lignes

wc -l fichier.txt   # lignes seulement
wc -w fichier.txt   # mots seulement
wc -c fichier.txt   # octets
wc -m fichier.txt   # caractères (différent si UTF-8)

# Compter le nombre de fichiers dans un répertoire
ls /etc | wc -l
find . -type f | wc -l
```

### 7.2 `diff` — Comparer des fichiers

```bash
# Comparaison basique
diff fichier1.txt fichier2.txt

# Format unifié (patch-friendly, le plus utilisé)
diff -u fichier1.txt fichier2.txt
# --- fichier1.txt  2024-01-01
# +++ fichier2.txt  2024-01-02
# @@ -1,5 +1,5 @@
#  ligne identique
# -ancienne ligne
# +nouvelle ligne

# Comparaison de répertoires
diff -r dossier1/ dossier2/

# Ignorer les espaces
diff -b fichier1 fichier2    # blancs en fin de ligne
diff -w fichier1 fichier2    # tous les espaces

# Format côte à côte
diff -y fichier1 fichier2
diff --side-by-side -W 80 fichier1 fichier2
```

### 7.3 `patch` — Appliquer un diff

```bash
# Créer un patch
diff -u original.txt modifie.txt > corrections.patch

# Appliquer un patch
patch original.txt < corrections.patch

# Appliquer à un répertoire
patch -p1 < corrections.patch   # -p1 supprime le premier / du chemin
patch --dry-run -p1 < corrections.patch  # simulation

# Inverser un patch
patch -R original.txt < corrections.patch
```

---

## 8. Wildcards (caractères génériques)

### 8.1 Globbing de base

```bash
# * : n'importe quelle chaîne de caractères (sauf /)
ls *.txt          # tous les .txt
ls doc*.pdf       # doc + n'importe quoi + .pdf
cp *.log /backup/

# ? : exactement un caractère quelconque
ls fichier?.txt   # fichier1.txt, fichierA.txt, mais pas fichier10.txt
ls ???.sh         # trois caractères + .sh

# [...] : un caractère parmi une liste ou plage
ls [abc]*.txt     # commence par a, b ou c
ls [a-z]*.sh      # commence par une minuscule
ls [0-9]*.log     # commence par un chiffre
ls [!a]*.txt      # ne commence PAS par a (! = négation)
ls [^a]*.txt      # idem (^ = négation, moins portable)

# Exemples pratiques
rm log_2023_[0-9][0-9].txt   # log_2023_01.txt à log_2023_99.txt
ls config.[0-9]              # config.0 à config.9
```

### 8.2 Brace expansion `{}`

```bash
# Liste de valeurs
echo {a,b,c}             # a b c
echo fichier{1,2,3}.txt  # fichier1.txt fichier2.txt fichier3.txt

# Plages numériques
echo {1..5}       # 1 2 3 4 5
echo {01..10}     # 01 02 03 04 05 06 07 08 09 10
echo {a..z}       # a b c d ... z

# Créer une arborescence complète
mkdir -p projet/{src,tests,docs}/{images,data,scripts}
# Crée : projet/src/images, projet/src/data, projet/tests/images, etc.

# Nommage avant/après
cp fichier.conf{,.bak}    # copie vers fichier.conf.bak
# Astuce : sauvegarde rapide avant modification

# Renommer avec double accolade
mv server.{conf,conf.old}   # mv server.conf server.conf.old

# Création de fichiers en lot
touch log_{jan,fev,mar,avr}_{2024,2025}.txt
```

> **Astuce pro** : `cp fichier.conf{,.bak}` est le raccourci ultime pour sauvegarder un fichier avant modification. `{,.bak}` s'expand en ` fichier.conf fichier.conf.bak`.

---

## 9. Commandes utilitaires

### 9.1 `realpath` — Chemin absolu résolu

```bash
realpath ../etc/passwd        # /etc/passwd
realpath -m /nonexistant/path # sans vérifier l'existence
```

### 9.2 `basename` et `dirname`

```bash
basename /home/alice/documents/rapport.pdf
# rapport.pdf

basename /home/alice/documents/rapport.pdf .pdf
# rapport (sans extension)

dirname /home/alice/documents/rapport.pdf
# /home/alice/documents

# Dans un script
FICHIER="/var/log/nginx/access.log"
DOSSIER=$(dirname "$FICHIER")    # /var/log/nginx
NOM=$(basename "$FICHIER")       # access.log
EXT="${NOM##*.}"                 # log
SANS_EXT="${NOM%.*}"             # access
```

### 9.3 Manipulation de contenu en bloc

```bash
# Trier les lignes
sort fichier.txt
sort -r fichier.txt       # ordre inverse
sort -n nombres.txt       # tri numérique
sort -u fichier.txt       # supprime les doublons

# Supprimer les doublons (lignes consécutives)
uniq fichier-trie.txt
uniq -c fichier.txt       # compter les occurrences
uniq -d fichier.txt       # afficher seulement les doublons

# Combinaison classique
sort fichier.txt | uniq -c | sort -rn | head -10
```

---

## Tableau récapitulatif

| Commande | Description | Exemple |
|----------|-------------|---------|
| `touch fichier` | Créer fichier vide / mettre à jour date | `touch rapport.txt` |
| `mkdir -p a/b/c` | Créer arborescence | `mkdir -p src/main/java` |
| `cp -a src/ dst/` | Copie complète avec préservation | `cp -a /backup/. /restore/` |
| `cp --backup=numbered` | Copie avec sauvegarde numérotée | - |
| `mv ancien nouveau` | Renommer / déplacer | `mv tmp/ archive/` |
| `rm -ri dossier/` | Supprimer interactivement | - |
| `cat -n fichier` | Afficher avec numéros de ligne | - |
| `less fichier` | Lecture paginée | - |
| `head -n 20` | 20 premières lignes | - |
| `tail -f log` | Suivi en temps réel | `tail -f syslog` |
| `ln -s cible lien` | Lien symbolique | `ln -s /usr/bin/python3 python` |
| `wc -l fichier` | Compter les lignes | `wc -l access.log` |
| `diff -u f1 f2` | Comparer en format unifié | - |
| `*.txt` | Tous les .txt | `rm *.tmp` |
| `{a,b,c}` | Expansion par liste | `mkdir {src,tests,docs}` |
| `{1..10}` | Plage numérique | `touch log_{1..7}.txt` |
| `basename` | Nom du fichier | `basename /a/b/c.txt` |
| `dirname` | Répertoire parent | `dirname /a/b/c.txt` |

---

## À retenir

- `mkdir -p` et `rm -rf` sont les deux commandes à double-vérifier avant exécution
- `cp -a` préserve tout (permissions, dates, liens) — idéal pour les sauvegardes
- `tail -f` suit un fichier en temps réel — indispensable pour déboguer
- `cp fichier.conf{,.bak}` est le raccourci de sauvegarde le plus rapide
- Les wildcards (`*`, `?`, `[]`) et la brace expansion (`{}`) permettent d'agir sur des groupes de fichiers en une seule commande

➡️ [Chapitre 4 — Permissions et ownership](../04_permissions_ownership/README.md)
