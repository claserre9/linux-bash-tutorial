# Chapitre 1 — Écosystème Linux

Linux est partout : serveurs, smartphones, objets connectés, supercalculateurs. Comprendre son écosystème, c'est maîtriser les outils qui structurent le monde numérique. Ce chapitre pose les fondations : distributions, terminal, shells, variables d'environnement et configuration.

---

## 1. Les distributions Linux

Une **distribution** (distro) est un système d'exploitation complet construit autour du noyau Linux. Chaque distro fait des choix d'outils, de gestionnaire de paquets et de philosophie.

### 1.1 Les grandes familles

| Famille | Distros notables | Gestionnaire de paquets | Usage typique |
|---------|-----------------|------------------------|---------------|
| Debian  | Ubuntu, Linux Mint, Kali | `apt` / `dpkg` | Serveurs, desktop |
| Red Hat | RHEL, Fedora, Rocky, AlmaLinux | `dnf` / `rpm` | Entreprise |
| Arch    | Arch Linux, Manjaro, EndeavourOS | `pacman` | Utilisateurs avancés |
| SUSE    | openSUSE, SLES | `zypper` / `rpm` | Entreprise |
| Alpine  | Alpine Linux | `apk` | Conteneurs Docker |

```bash
# Identifier sa distribution
cat /etc/os-release

# Exemple de sortie (Ubuntu) :
# NAME="Ubuntu"
# VERSION="22.04.3 LTS (Jammy Jellyfish)"
# ID=ubuntu
# ID_LIKE=debian

# Version du noyau Linux
uname -r
# Ex : 5.15.0-88-generic

# Architecture du système
uname -m
# Ex : x86_64
```

> **Astuce pro** : Sur un serveur inconnu, commencez toujours par `cat /etc/os-release && uname -a` pour identifier l'environnement avant toute action.

---

## 2. Le terminal et les émulateurs

### 2.1 Qu'est-ce qu'un terminal ?

Un **terminal** (ou console) est l'interface texte permettant d'interagir avec le shell. Historiquement, c'était un périphérique physique. Aujourd'hui, on utilise des **émulateurs de terminal** — des programmes graphiques qui simulent ce périphérique.

### 2.2 Émulateurs populaires

| Émulateur | Environnement | Particularité |
|-----------|--------------|---------------|
| **gnome-terminal** | GNOME / Ubuntu | Standard, onglets |
| **Konsole** | KDE | Très configurable |
| **iTerm2** | macOS | Puissant, split-panes |
| **Alacritty** | Cross-platform | GPU, très rapide |
| **kitty** | Cross-platform | GPU, protocole étendu |
| **Windows Terminal** | Windows (WSL) | Onglets, GPU |
| **tmux** | Tout | Multiplexeur (pas un émulateur, mais essentiel) |

```bash
# Connaître le terminal en cours d'utilisation
echo $TERM
# Ex : xterm-256color

# Dimensions du terminal
tput cols   # nombre de colonnes
tput lines  # nombre de lignes
```

---

## 3. Les shells

### 3.1 Qu'est-ce qu'un shell ?

Le **shell** est l'interpréteur de commandes : il lit ce que vous tapez, l'interprète, exécute les programmes et affiche les résultats. C'est le pont entre l'utilisateur et le noyau.

### 3.2 Shells courants

| Shell | Description | Fichier de config |
|-------|-------------|-------------------|
| **bash** | Bourne Again SHell — le standard universel | `.bashrc`, `.bash_profile` |
| **zsh** | Bash étendu, défaut sur macOS depuis 2019 | `.zshrc` |
| **fish** | Friendly Interactive SHell, syntaxe non-POSIX | `config.fish` |
| **dash** | Shell POSIX minimaliste, rapide | - |
| **sh** | Shell POSIX de base (souvent un lien vers dash/bash) | - |

```bash
# Connaître son shell actuel
echo $SHELL
# Ex : /bin/bash

# Lister les shells disponibles sur le système
cat /etc/shells
# /bin/sh
# /bin/bash
# /bin/zsh
# ...

# Changer de shell (temporairement)
zsh

# Changer de shell par défaut (permanent)
chsh -s /bin/zsh

# Version de bash
bash --version
```

> **Piège courant** : `$SHELL` affiche le shell de **login** configuré, pas forcément le shell actif. Pour connaître le shell actif, utilisez `ps -p $$` ou `echo $0`.

```bash
# Shell réellement actif
ps -p $$
#   PID TTY          TIME CMD
# 12345 pts/0    00:00:00 bash

echo $0
# bash (ou -bash pour un shell de login)
```

### 3.3 Modes de shell

- **Shell de login** (`bash -l`) : chargé lors d'une connexion SSH, lit `.bash_profile`
- **Shell interactif non-login** : nouveau terminal dans une session graphique, lit `.bashrc`
- **Shell non-interactif** : scripts, lit les variables d'environnement héritées

```bash
# Tester si on est dans un shell interactif
[[ $- == *i* ]] && echo "Interactif" || echo "Non-interactif"

# Tester si on est dans un shell de login
shopt -q login_shell && echo "Login shell" || echo "Non-login"
```

---

## 4. Variables d'environnement

### 4.1 Variables essentielles

Les variables d'environnement sont des paires clé=valeur transmises aux processus enfants.

```bash
# Afficher toutes les variables d'environnement
env
printenv

# Afficher une variable spécifique
echo $HOME        # /home/utilisateur
echo $USER        # votre nom d'utilisateur
echo $SHELL       # /bin/bash
echo $PATH        # /usr/local/bin:/usr/bin:/bin:...
echo $PWD         # répertoire courant
echo $OLDPWD      # répertoire précédent
echo $LANG        # fr_FR.UTF-8
echo $EDITOR      # vim (ou nano, code...)
echo $TERM        # xterm-256color
```

### 4.2 $PATH : la variable la plus importante

`$PATH` liste les répertoires où le shell cherche les commandes, séparés par `:`.

```bash
# Afficher le PATH formaté (un répertoire par ligne)
echo $PATH | tr ':' '\n'
# /usr/local/sbin
# /usr/local/bin
# /usr/sbin
# /usr/bin
# /sbin
# /bin

# Ajouter un répertoire au PATH temporairement
export PATH="$HOME/.local/bin:$PATH"

# Ajouter au PATH de façon permanente (dans .bashrc)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

> **Piège courant** : Ne faites jamais `PATH="/nouveau/chemin"` sans inclure `$PATH` — vous perdriez l'accès à toutes les commandes système !

### 4.3 Créer et exporter des variables

```bash
# Variable locale (visible seulement dans le shell courant)
MA_VARIABLE="bonjour"
echo $MA_VARIABLE   # bonjour

# Variable d'environnement (transmise aux processus enfants)
export MA_VARIABLE="bonjour"

# Définir et exporter en une ligne
export PROJET="mon-app"

# Supprimer une variable
unset MA_VARIABLE

# Variable en lecture seule
readonly VERSION="1.0.0"
```

```bash
# Démonstration : variable sans export non transmise
LOCALE_VAR="test"
bash -c 'echo "Sous-shell : $LOCALE_VAR"'  # vide

export EXPORT_VAR="test"
bash -c 'echo "Sous-shell : $EXPORT_VAR"'  # test
```

---

## 5. Obtenir de l'aide

### 5.1 `man` — les pages de manuel

```bash
# Ouvrir le manuel d'une commande
man ls
man bash
man 5 passwd   # section 5 = formats de fichiers

# Chercher dans les pages man
man -k "copy file"   # recherche par mot-clé
apropos copy         # équivalent

# Navigation dans man :
# j/k ou flèches    : défilement
# / puis texte      : recherche
# n / N             : occurrence suivante/précédente
# q                 : quitter
```

### 5.2 `--help` — aide rapide intégrée

```bash
ls --help
grep --help
# La plupart des commandes GNU acceptent --help
```

### 5.3 `tldr` — exemples pratiques

`tldr` (Too Long; Didn't Read) fournit des exemples concis à la place des longs manuels.

```bash
# Installation
npm install -g tldr
# ou
pip install tldr
# ou (recommandé)
brew install tldr       # macOS
sudo apt install tldr   # Debian/Ubuntu

# Utilisation
tldr ls
tldr tar
tldr find
```

> **Astuce pro** : `tldr` est idéal pour les commandes que vous utilisez rarement. Pour les détails exacts, consultez `man`.

### 5.4 `type` et `which` — localiser les commandes

```bash
# type : nature d'une commande (builtin, alias, fonction, fichier)
type ls
# ls is /bin/ls

type cd
# cd is a shell builtin

type ll
# ll is aliased to 'ls -alF'

type -a python
# python is /usr/bin/python
# python is /usr/local/bin/python  (si plusieurs versions)

# which : chemin de la commande exécutée
which python3
# /usr/bin/python3

which -a python3  # toutes les occurrences dans $PATH
```

---

## 6. Historique des commandes

### 6.1 `history`

```bash
# Afficher l'historique
history
history 20        # 20 dernières commandes

# Rechercher dans l'historique
history | grep git

# Effacer l'historique
history -c

# Effacer une entrée spécifique (ex : commande avec mot de passe)
history -d 142    # supprime l'entrée n°142

# Taille de l'historique (dans .bashrc)
HISTSIZE=10000        # nb de commandes en mémoire
HISTFILESIZE=20000    # nb de commandes dans le fichier
```

### 6.2 Raccourcis d'historique

```bash
!!        # répète la dernière commande
!42       # répète la commande n°42
!git      # répète la dernière commande commençant par "git"
!$        # dernier argument de la commande précédente
!*        # tous les arguments de la commande précédente

# Exemple pratique
ls /etc/nginx/nginx.conf
cat !$    # cat /etc/nginx/nginx.conf
```

> **Astuce pro** : `sudo !!` est votre meilleur ami quand vous oubliez `sudo` devant une commande.

---

## 7. Alias

```bash
# Créer un alias temporaire
alias ll='ls -alF --color=auto'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Afficher tous les alias
alias

# Supprimer un alias
unalias ll

# Alias permanent : ajoutez dans ~/.bashrc
echo "alias ll='ls -alF --color=auto'" >> ~/.bashrc
```

> **Piège courant** : Un alias ne peut pas être utilisé dans un script non-interactif sauf si vous activez explicitement les alias avec `shopt -s expand_aliases`.

---

## 8. Configuration du shell

### 8.1 Fichiers de configuration bash

```
~/.bashrc           # shell interactif non-login (nouveau terminal)
~/.bash_profile     # shell de login (connexion SSH, TTY)
~/.bash_aliases     # alias (souvent sourcé depuis .bashrc)
~/.bash_history     # fichier historique
/etc/bash.bashrc    # configuration globale (tous les utilisateurs)
/etc/profile        # configuration de login globale
/etc/profile.d/*.sh # scripts de configuration globaux
```

```bash
# Structure typique d'un ~/.bashrc
# -----------------------------------------------
# 1. Variables d'environnement
export EDITOR="nano"
export LANG="fr_FR.UTF-8"

# 2. PATH personnalisé
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# 3. Alias
alias ll='ls -alF --color=auto'
alias grep='grep --color=auto'

# 4. Fonctions personnalisées
mkcd() { mkdir -p "$1" && cd "$1"; }

# 5. Options du shell
HISTSIZE=10000
HISTCONTROL=ignoredups:erasedups   # ignore les doublons
```

### 8.2 Recharger la configuration

```bash
# Recharger .bashrc sans ouvrir un nouveau terminal
source ~/.bashrc
# ou
. ~/.bashrc
```

### 8.3 Configuration zsh

```bash
~/.zshrc            # configuration principale zsh
~/.zprofile         # équivalent de .bash_profile pour zsh
~/.zshenv           # variables d'environnement (tous les modes)
```

---

## 9. Édition en ligne de commande (raccourcis clavier)

Ces raccourcis fonctionnent dans bash, zsh, et tout terminal utilisant **readline**.

### 9.1 Déplacement du curseur

| Raccourci | Action |
|-----------|--------|
| `Ctrl+A` | Aller au **début** de la ligne |
| `Ctrl+E` | Aller à la **fin** de la ligne |
| `Ctrl+←` / `Alt+B` | Mot précédent |
| `Ctrl+→` / `Alt+F` | Mot suivant |
| `Ctrl+XX` | Basculer entre début de ligne et position actuelle |

### 9.2 Suppression et modification

| Raccourci | Action |
|-----------|--------|
| `Ctrl+W` | Supprimer le mot **avant** le curseur |
| `Alt+D` | Supprimer le mot **après** le curseur |
| `Ctrl+U` | Supprimer du curseur **jusqu'au début** |
| `Ctrl+K` | Supprimer du curseur **jusqu'à la fin** |
| `Ctrl+Y` | Coller (yank) le dernier texte supprimé |
| `Ctrl+_` | Annuler la dernière modification |

### 9.3 Historique et recherche

| Raccourci | Action |
|-----------|--------|
| `Ctrl+R` | Recherche **incrémentale** dans l'historique |
| `Ctrl+S` | Recherche vers l'avant (si activé) |
| `Ctrl+G` | Annuler la recherche |
| `↑` / `↓` | Commande précédente / suivante |
| `Alt+.` | Insérer le dernier argument de la commande précédente |

### 9.4 Contrôle du terminal

| Raccourci | Action |
|-----------|--------|
| `Ctrl+C` | Interrompre le processus en cours |
| `Ctrl+Z` | Suspendre le processus en cours |
| `Ctrl+D` | EOF / fermer le terminal |
| `Ctrl+L` | Effacer l'écran (`clear`) |
| `Ctrl+S` | Suspendre l'affichage (scroll lock) |
| `Ctrl+Q` | Reprendre l'affichage |

```bash
# Activer Ctrl+R vers l'avant (Ctrl+S)
stty -ixon   # à ajouter dans .bashrc pour le rendre permanent
```

> **Astuce pro** : `Ctrl+R` est l'un des raccourcis les plus puissants. Tapez `Ctrl+R` puis quelques lettres de la commande cherchée. Appuyez de nouveau sur `Ctrl+R` pour passer à l'occurrence précédente.

---

## Tableau récapitulatif

| Commande / Concept | Description | Exemple |
|-------------------|-------------|---------|
| `echo $SHELL` | Shell de login configuré | `/bin/bash` |
| `echo $PATH` | Chemins de recherche des commandes | `/usr/bin:/bin:...` |
| `echo $HOME` | Répertoire personnel | `/home/alice` |
| `export VAR=val` | Créer une variable d'environnement | `export EDITOR=vim` |
| `man cmd` | Manuel complet | `man ls` |
| `cmd --help` | Aide rapide | `ls --help` |
| `tldr cmd` | Exemples pratiques | `tldr tar` |
| `type cmd` | Nature de la commande | `type cd` |
| `which cmd` | Chemin de la commande | `which python3` |
| `history` | Historique des commandes | `history 20` |
| `alias` | Créer/lister les alias | `alias ll='ls -la'` |
| `source ~/.bashrc` | Recharger la config | `. ~/.bashrc` |
| `Ctrl+R` | Recherche dans l'historique | - |
| `Ctrl+A/E` | Début/fin de ligne | - |
| `Ctrl+W/U` | Supprimer mot/ligne | - |

---

## À retenir

- Linux existe en de nombreuses **distributions** regroupées en familles (Debian, Red Hat, Arch…)
- Le **shell** (bash, zsh…) interprète vos commandes ; sa configuration est dans `.bashrc`/`.zshrc`
- `$PATH` détermine quelles commandes sont disponibles — ne le cassez jamais !
- `man`, `--help` et `tldr` sont vos trois niveaux d'aide
- Les raccourcis **Ctrl+R**, **Ctrl+A/E**, **Ctrl+W/U** transforment votre productivité

➡️ [Chapitre 2 — Navigation et système de fichiers](../02_navigation_filesystem/README.md)
