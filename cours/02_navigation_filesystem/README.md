# Chapitre 2 — Navigation et système de fichiers

Linux organise tous ses fichiers dans une arborescence unique partant de la racine `/`. Savoir s'y repérer, lire les métadonnées d'un fichier et comprendre l'espace disque sont des compétences quotidiennes indispensables.

---

## 1. L'arborescence Linux (FHS)

Le **Filesystem Hierarchy Standard (FHS)** définit la structure des répertoires Linux. Tout part de `/` (la racine).

```
/
├── bin/        → Commandes essentielles (ls, cp, bash…)
├── boot/       → Noyau et chargeur de démarrage
├── dev/        → Périphériques (disques, terminaux…)
├── etc/        → Fichiers de configuration système
├── home/       → Répertoires personnels des utilisateurs
│   └── alice/
├── lib/        → Bibliothèques partagées essentielles
├── media/      → Points de montage (USB, CD…)
├── mnt/        → Montages temporaires manuels
├── opt/        → Logiciels tiers optionnels
├── proc/       → Système de fichiers virtuel (processus, noyau)
├── root/       → Répertoire personnel de root
├── run/        → Données d'exécution temporaires
├── sbin/       → Commandes d'administration système
├── srv/        → Données servies (web, ftp…)
├── sys/        → Système de fichiers virtuel (matériel)
├── tmp/        → Fichiers temporaires (vidé au redémarrage)
├── usr/        → Programmes et ressources utilisateurs
│   ├── bin/    → Commandes non-essentielles
│   ├── lib/    → Bibliothèques
│   └── share/  → Données partagées (man, doc…)
└── var/        → Données variables (logs, spool, cache…)
    ├── log/    → Fichiers journaux
    └── www/    → Fichiers web (Apache/Nginx)
```

### 1.1 Répertoires clés à connaître

```bash
# Voir les fichiers de configuration système
ls /etc/

# Logs système
ls /var/log/
tail -f /var/log/syslog    # Ubuntu/Debian
tail -f /var/log/messages  # RHEL/CentOS

# Informations sur les processus (système de fichiers virtuel)
cat /proc/cpuinfo     # infos CPU
cat /proc/meminfo     # infos mémoire
cat /proc/version     # version du noyau

# Périphériques
ls /dev/sd*    # disques SATA/SCSI
ls /dev/tty*   # terminaux
```

> **Astuce pro** : `/proc` et `/sys` ne sont pas de vrais fichiers sur disque — ce sont des interfaces vers le noyau. Vous pouvez les lire mais écrire dans `/proc` ou `/sys` modifie le comportement du système en temps réel !

---

## 2. Se repérer : `pwd`, `ls`, `cd`

### 2.1 `pwd` — Print Working Directory

```bash
pwd
# /home/alice/documents

# Résoudre les liens symboliques
pwd -P
```

### 2.2 `ls` — Lister les fichiers

```bash
# Listage basique
ls
ls /etc

# Options essentielles
ls -l          # format long (permissions, taille, date)
ls -a          # tout afficher (fichiers cachés inclus)
ls -la         # combiné : long + cachés
ls -lh         # tailles lisibles (K, M, G)
ls -lha        # tout combiné

# Tri
ls -lt         # trier par date de modification (plus récent en premier)
ls -ltr        # trier par date (plus ancien en premier)
ls -lS         # trier par taille (plus grand en premier)
ls -lX         # trier par extension

# Récursif
ls -R          # lister récursivement tous les sous-répertoires
ls -R /etc/nginx/

# Couleurs et indicateurs de type
ls --color=auto     # activer les couleurs
ls -F              # indicateurs : / pour dossier, * pour exécutable, @ pour lien
```

```bash
# Décrypter la sortie de ls -l :
ls -la /etc/passwd
# -rw-r--r-- 1 root root 2847 jan  5 10:23 /etc/passwd
# │││││││││ │  │    │    │    │              └─ nom du fichier
# │││││││││ │  │    │    │    └─ date de modification
# │││││││││ │  │    │    └─ taille en octets
# │││││││││ │  │    └─ groupe propriétaire
# │││││││││ │  └─ utilisateur propriétaire
# │││││││││ └─ nombre de liens durs
# ││││││││└─ autres : lecture
# │││││││└─ autres : écriture (-)
# ││││││└─ autres : exécution (-)
# │││││└─ groupe : lecture
# ││││└─ groupe : écriture (-)
# │││└─ groupe : exécution (-)
# ││└─ propriétaire : lecture
# │└─ propriétaire : écriture
# └─ type : - (fichier régulier), d (répertoire), l (lien)
```

### 2.3 `cd` — Changer de répertoire

```bash
# Navigation de base
cd /etc              # chemin absolu
cd documents         # chemin relatif
cd ..                # répertoire parent
cd ../..             # deux niveaux au-dessus
cd -                 # revenir au répertoire précédent
cd ~                 # aller dans son répertoire personnel
cd                   # idem (sans argument = $HOME)
cd ~alice            # aller dans le home d'alice

# Exemples pratiques
cd /var/log && ls -lt | head -10   # aller dans les logs et lister
```

> **Astuce pro** : `cd -` est extrêmement pratique pour alterner entre deux répertoires. Chaque `cd -` vous fait basculer entre le répertoire courant et le précédent.

---

## 3. Chemins relatifs vs absolus

```bash
# Chemin ABSOLU : commence toujours par /
/home/alice/documents/rapport.pdf
/etc/nginx/nginx.conf
/usr/bin/python3

# Chemin RELATIF : par rapport au répertoire courant
# Si on est dans /home/alice :
documents/rapport.pdf      # = /home/alice/documents/rapport.pdf
../bob/partage.txt          # = /home/bob/partage.txt
../../etc/hosts             # = /etc/hosts

# Caractères spéciaux dans les chemins
~              # répertoire home de l'utilisateur courant
~/documents    # = /home/alice/documents
~bob/          # répertoire home de bob
.              # répertoire courant
..             # répertoire parent
```

```bash
# Construire et manipuler des chemins
FICHIER="/home/alice/documents/rapport.pdf"

dirname  "$FICHIER"    # /home/alice/documents
basename "$FICHIER"    # rapport.pdf
basename "$FICHIER" .pdf  # rapport (sans extension)

# Résoudre un chemin (liens symboliques inclus)
realpath "../../etc/hosts"  # /etc/hosts
readlink -f ~/documents      # chemin absolu résolu
```

---

## 4. `tree` — Visualiser l'arborescence

```bash
# Installation si nécessaire
sudo apt install tree   # Debian/Ubuntu
brew install tree        # macOS

# Affichage de l'arborescence
tree                     # depuis le répertoire courant
tree /etc/nginx          # d'un répertoire spécifique
tree -L 2                # profondeur maximale : 2 niveaux
tree -a                  # inclure les fichiers cachés
tree -d                  # répertoires seulement
tree -h                  # tailles lisibles
tree -I "*.log"          # exclure les fichiers .log
tree --du                # afficher l'espace utilisé

# Exemple de sortie :
# /etc/nginx
# ├── conf.d
# │   └── default.conf
# ├── nginx.conf
# └── sites-enabled
#     └── mysite.conf
```

---

## 5. `stat` — Métadonnées détaillées d'un fichier

```bash
stat /etc/passwd
# File: /etc/passwd
# Size: 2847       Blocks: 8       IO Block: 4096  regular file
# Device: 8,1      Inode: 524290   Links: 1
# Access: (0644/-rw-r--r--)  Uid: (0/root)  Gid: (0/root)
# Access: 2024-01-05 10:23:45.000000000
# Modify: 2024-01-03 08:15:22.000000000
# Change: 2024-01-03 08:15:22.000000000

# Format personnalisé
stat -c "%n : %s octets, modifié le %y" /etc/passwd

# Comprendre les trois dates :
# Access (atime) : dernier accès en lecture
# Modify (mtime) : dernière modification du contenu
# Change (ctime) : dernier changement des métadonnées (permissions, nom…)
```

---

## 6. `file` — Identifier le type d'un fichier

Ne jamais se fier uniquement à l'extension. La commande `file` analyse le contenu.

```bash
file /etc/passwd
# /etc/passwd: ASCII text

file /bin/ls
# /bin/ls: ELF 64-bit LSB pie executable, x86-64...

file image.jpg
# image.jpg: JPEG image data, JFIF standard 1.01

file archive.tar.gz
# archive.tar.gz: gzip compressed data

file script.sh
# script.sh: Bourne-Again shell script, ASCII text executable

# Sur plusieurs fichiers
file /etc/*
file *
```

---

## 7. `du` et `df` — Espace disque

### 7.1 `du` — Espace utilisé par des fichiers/répertoires

```bash
# Taille d'un répertoire (récursif)
du /home/alice

# Options essentielles
du -h          # tailles lisibles (K, M, G)
du -s          # résumé seulement (pas de récursion)
du -sh /home/* # taille de chaque sous-répertoire

# Les 10 plus gros répertoires
du -h /var | sort -rh | head -10

# Taille totale du répertoire courant
du -sh .

# Exclure certains répertoires
du -sh --exclude='.git' .
```

### 7.2 `df` — Espace disponible sur les systèmes de fichiers

```bash
# Vue d'ensemble
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   20G   28G  42% /
# tmpfs           2.0G  1.2M  2.0G   1% /run
# /dev/sda2       200G   80G  110G  42% /home

# Options
df -h          # tailles lisibles
df -T          # afficher le type de système de fichiers
df -i          # inodes (nombre de fichiers)
df /home       # espace pour un point de montage spécifique
```

> **Piège courant** : Un disque peut être "plein" au sens des **inodes** même si de l'espace reste disponible. Vérifiez avec `df -i`. Cela arrive souvent avec de nombreux petits fichiers.

---

## 8. Types de fichiers Linux

Linux utilise un seul caractère pour identifier le type de fichier (visible dans `ls -l`).

| Caractère | Type | Exemple |
|-----------|------|---------|
| `-` | Fichier régulier | `/etc/passwd` |
| `d` | Répertoire | `/home/alice` |
| `l` | Lien symbolique | `/usr/bin/python → python3` |
| `b` | Périphérique bloc | `/dev/sda` |
| `c` | Périphérique caractère | `/dev/tty1` |
| `p` | Pipe nommé (FIFO) | `/run/systemd/initctl/fifo` |
| `s` | Socket | `/run/docker.sock` |

```bash
# Identifier le type sans ls -l
file /dev/sda     # block special
file /dev/tty     # character special
file /run/*.sock  # socket

# Avec find, filtrer par type
find /dev -type b   # périphériques bloc
find /dev -type c   # périphériques caractère
find /tmp -type p   # pipes nommés
find /run -type s   # sockets

# Lire le type avec stat
stat -c "%F" /etc/passwd   # regular file
stat -c "%F" /home         # directory
stat -c "%F" /usr/bin/python3  # symbolic link
```

### 8.1 Liens symboliques

```bash
# Créer un lien symbolique
ln -s /chemin/cible /chemin/lien
ln -s /usr/bin/python3 ~/bin/python

# Vérifier un lien
ls -la /usr/bin/python
# lrwxrwxrwx 1 root root 7 jan  1 10:00 /usr/bin/python -> python3

readlink /usr/bin/python   # affiche la cible : python3
readlink -f /usr/bin/python  # cible absolue résolue

# Un lien symbolique cassé (cible inexistante)
ln -s /fichier/inexistant /tmp/lien-casse
ls -la /tmp/lien-casse   # apparaît en rouge
```

---

## 9. Navigation avancée

### 9.1 `pushd` et `popd` — Pile de répertoires

```bash
# Empiler le répertoire courant et aller ailleurs
pushd /etc/nginx
# Faire du travail...
pushd /var/log
# Faire du travail...

# Revenir au répertoire précédent
popd   # retour à /etc/nginx
popd   # retour au répertoire d'origine

# Voir la pile
dirs -v
# 0  /var/log
# 1  /etc/nginx
# 2  /home/alice
```

### 9.2 Complétion automatique

```bash
# Tab : compléter le nom de fichier/commande
ls /etc/pa<Tab>   # complète en /etc/passwd
cd /ho<Tab><Tab>  # liste les possibilités si ambiguïté

# Avec zsh, la complétion est encore plus intelligente
# (complétion des options, des arguments de commande, etc.)
```

---

## Tableau récapitulatif

| Commande | Description | Exemple |
|----------|-------------|---------|
| `pwd` | Répertoire courant | `pwd` |
| `ls -lha` | Listing détaillé (tout) | `ls -lha /etc` |
| `cd /path` | Aller à un chemin absolu | `cd /var/log` |
| `cd ..` | Répertoire parent | `cd ..` |
| `cd -` | Répertoire précédent | `cd -` |
| `tree -L 2` | Arborescence (2 niveaux) | `tree -L 2 /etc` |
| `stat fichier` | Métadonnées complètes | `stat /etc/passwd` |
| `file fichier` | Type réel du fichier | `file /bin/ls` |
| `du -sh dossier` | Taille d'un dossier | `du -sh /home` |
| `df -h` | Espace disque disponible | `df -h` |
| `realpath chemin` | Chemin absolu résolu | `realpath ../etc` |
| `dirname path` | Répertoire parent d'un chemin | `dirname /a/b/c` |
| `basename path` | Nom final d'un chemin | `basename /a/b/c` |

---

## À retenir

- L'arborescence Linux est unique et part de `/` — tout y est organisé par convention (FHS)
- `/proc` et `/sys` sont des **systèmes de fichiers virtuels** : des fenêtres sur le noyau
- `ls -lha` est votre commande de listage universelle
- `cd -` fait basculer entre deux répertoires, `pushd`/`popd` gèrent une pile
- `stat` donne les métadonnées complètes, `file` identifie le type réel du contenu
- `du -sh` résume la taille, `df -h` donne l'espace disponible sur les partitions

➡️ [Chapitre 3 — Manipulation de fichiers](../03_manipulation_fichiers/README.md)
