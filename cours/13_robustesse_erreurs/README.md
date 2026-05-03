# Chapitre 13 — Robustesse et gestion d'erreurs

Un script Bash qui fonctionne en conditions normales n'est qu'à moitié écrit. La vraie qualité d'un script se mesure à son comportement face aux erreurs : fichiers manquants, commandes absentes, permissions insuffisantes, interruptions inattendues. Ce chapitre couvre les techniques pour écrire des scripts solides, prévisibles et auto-documentés.

---

## 1. Codes de sortie

### 1.1 Comprendre `$?`

Chaque commande retourne un **code de sortie** entre 0 et 255 :
- **0** : succès
- **1-255** : erreur (conventions ci-dessous)

```bash
ls /tmp
echo "Code de sortie : $?"   # 0

ls /inexistant 2>/dev/null
echo "Code de sortie : $?"   # 2 (erreur ls)

grep "pattern" fichier_inexistant 2>/dev/null
echo "Code de sortie : $?"   # 2 (fichier introuvable)
```

### 1.2 Conventions des codes de sortie

| Code | Signification | Exemples |
|------|--------------|---------|
| `0` | Succès | Commande réussie |
| `1` | Erreur générale | Script, commande interne |
| `2` | Mauvais usage | Mauvais arguments, fichier manquant |
| `126` | Permission refusée | Commande non exécutable |
| `127` | Commande introuvable | Commande absente du PATH |
| `128+n` | Signal fatal n | `130` = Ctrl+C (signal 2) |
| `255` | Erreur hors plage | Exit avec valeur > 255 |

```bash
#!/bin/bash
# Retourner des codes spécifiques

traiter_fichier() {
    local fichier="$1"

    [[ -z "$fichier" ]] && { echo "Erreur : argument manquant" >&2; return 2; }
    [[ ! -f "$fichier" ]] && { echo "Erreur : fichier introuvable: $fichier" >&2; return 2; }
    [[ ! -r "$fichier" ]] && { echo "Erreur : fichier non lisible: $fichier" >&2; return 126; }

    wc -l "$fichier"
    return 0
}

traiter_fichier "/etc/hosts"
echo "Résultat : $?"
```

> **Piège courant** : La variable `$?` ne contient que le code de la **dernière** commande. Si vous en avez besoin plus tard, sauvegardez-la immédiatement : `code=$?`.

---

## 2. Les options `set` essentielles

### 2.1 `set -e` — Exit on error

```bash
#!/bin/bash
set -e  # Quitter immédiatement si une commande échoue

mkdir /dossier_test
cd /dossier_test
cp /fichier_inexistant .  # Échec → le script s'arrête ici
echo "Cette ligne n'est jamais atteinte"
```

### 2.2 `set -u` — Unbound variable

```bash
#!/bin/bash
set -u  # Traiter les variables non définies comme des erreurs

echo "$variable_non_definie"  # Erreur fatale : unbound variable
```

### 2.3 `set -o pipefail` — Pipe failure

```bash
#!/bin/bash
set -o pipefail  # Le code de sortie d'un pipe = code de la première commande en échec

# Sans pipefail : le code de sortie est celui de grep (0)
# Avec pipefail : le code de sortie est celui de cat (1)
cat fichier_inexistant 2>/dev/null | grep "pattern"
echo "Code : $?"   # Avec pipefail : 1
```

### 2.4 `set -x` — Trace d'exécution

```bash
#!/bin/bash
set -x  # Afficher chaque commande avant exécution

var="hello"
echo "$var"
# Sortie :
# + var=hello
# + echo hello
# hello
```

### 2.5 La combinaison robuste : `set -euo pipefail`

```bash
#!/bin/bash
# En-tête recommandé pour TOUT script de production
set -euo pipefail

# Optionnel : trace d'exécution uniquement si DEBUG est défini
[[ "${DEBUG:-}" == "1" ]] && set -x
```

> **Astuce pro** : Placez toujours `set -euo pipefail` en deuxième ligne de vos scripts de production. La seule exception : les scripts de configuration shell (`.bashrc`, `.profile`) où `set -e` causerait des arrêts intempestifs sur des commandes qui peuvent légitimement échouer.

---

## 3. Ignorer une erreur spécifique

```bash
#!/bin/bash
set -euo pipefail

# Ignorer l'échec d'une commande spécifique avec || true
rm -f /tmp/fichier_peut_etre_absent || true

# Ou avec if
if ! commande_qui_peut_echouer; then
    echo "Commande échouée, on continue"
fi

# Ignorer le code de sortie de grep (1 si aucun résultat)
count=$(grep -c "pattern" fichier.txt || true)

# Vérification explicite
result=$(some_command) || {
    echo "Commande échouée, résultat par défaut" >&2
    result="defaut"
}
```

---

## 4. `trap` : nettoyage garanti

### 4.1 Syntaxe de base

```bash
# trap 'commandes' SIGNAL [SIGNAL...]
# Signaux courants : EXIT ERR INT TERM HUP

trap 'echo "Nettoyage..."' EXIT        # À la sortie (normale ou erreur)
trap 'echo "Erreur ligne $LINENO"' ERR # Sur chaque erreur
trap 'echo "Interrupted"; exit 1' INT  # Ctrl+C
trap 'echo "Terminated"' TERM          # kill
trap 'echo "Hangup"' HUP               # Perte de connexion SSH
```

### 4.2 Pattern de nettoyage de fichiers temporaires

```bash
#!/bin/bash
set -euo pipefail

# Créer un fichier temporaire sécurisé
tmpfile=$(mktemp /tmp/monscript.XXXXXX)

# Garantir sa suppression quelle que soit la fin du script
trap 'rm -f "$tmpfile"' EXIT

# Utiliser le fichier temporaire
echo "données de travail" > "$tmpfile"
sort "$tmpfile" > /tmp/resultat_final.txt

echo "Traitement terminé"
# $tmpfile sera automatiquement supprimé
```

### 4.3 Trap avec plusieurs ressources

```bash
#!/bin/bash
set -euo pipefail

# Nettoyage de plusieurs ressources
tmpdir=$(mktemp -d /tmp/monscript.XXXXXX)
lockfile="/var/run/monscript.lock"

cleanup() {
    echo "Nettoyage en cours..." >&2
    rm -rf "$tmpdir"
    rm -f "$lockfile"
    # Éventuellement : kill tous les processus enfants
    jobs -p | xargs -r kill 2>/dev/null || true
}

trap cleanup EXIT

# Créer le lockfile
echo $$ > "$lockfile"

# Vérifier qu'on est le seul exemplaire en cours
if [[ $(cat "$lockfile") != $$ ]]; then
    echo "Script déjà en cours d'exécution" >&2
    exit 1
fi

# Travail réel...
echo "Traitement dans $tmpdir"
```

### 4.4 Trap pour logging d'erreurs

```bash
#!/bin/bash
set -euo pipefail

# Log automatique des erreurs avec numéro de ligne
trap 'echo "[ERREUR] Ligne $LINENO : commande \"$BASH_COMMAND\" a échoué (code $?)" >&2' ERR

traiter() {
    cp /inexistant /tmp/  # Provoque une erreur
}

traiter
```

> **Piège courant** : `trap ... ERR` ne se déclenche pas dans les sous-shells ni dans les fonctions si celles-ci utilisent `|| `. Utilisez `set -E` (errtrace) pour propager le trap ERR aux fonctions.

```bash
set -euo pipefail -E  # -E = errtrace : ERR trap héréditaire
```

---

## 5. Fonctions d'erreur standardisées

### 5.1 Les fonctions `die()`, `log()`, `warn()`

```bash
#!/bin/bash
set -euo pipefail

# Couleurs (désactivées si pas de terminal)
if [[ -t 2 ]]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' YELLOW='' GREEN='' BLUE='' NC=''
fi

# Timestamp
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

# Logging vers stderr
log()  { echo -e "${GREEN}[$(timestamp)] INFO${NC}  : $*" >&2; }
warn() { echo -e "${YELLOW}[$(timestamp)] WARN${NC}  : $*" >&2; }
die()  { echo -e "${RED}[$(timestamp)] ERROR${NC} : $*" >&2; exit 1; }

# Utilisation
log "Démarrage du script"
warn "Fichier de config absent, utilisation des valeurs par défaut"
die "Impossible de se connecter à la base de données"  # Quitte avec code 1
```

### 5.2 `die()` avec code de sortie personnalisé

```bash
die() {
    local code="${1:-1}"
    shift
    echo -e "${RED}[$(timestamp)] ERROR${NC} : $*" >&2
    exit "$code"
}

die 2 "Mauvais argument : $1"    # Code 2
die 127 "Commande introuvable"   # Code 127
```

---

## 6. Vérifications défensives

### 6.1 Tester l'existence de fichiers et répertoires

```bash
#!/bin/bash
set -euo pipefail

verifier_prérequis() {
    local config="$1"
    local outdir="$2"

    # Fichier de config obligatoire
    [[ -f "$config" ]] || die "Fichier de config introuvable: $config"
    [[ -r "$config" ]] || die "Fichier de config non lisible: $config"

    # Répertoire de sortie
    if [[ ! -d "$outdir" ]]; then
        log "Création du répertoire de sortie: $outdir"
        mkdir -p "$outdir" || die "Impossible de créer: $outdir"
    fi
    [[ -w "$outdir" ]] || die "Répertoire non accessible en écriture: $outdir"
}
```

### 6.2 `command -v` — Tester la présence d'une commande

```bash
#!/bin/bash
set -euo pipefail

# Vérifier qu'une commande est disponible
verifier_commande() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        die "Commande requise absente: $cmd (installez-la d'abord)"
    fi
}

# Vérifier plusieurs dépendances
verifier_deps() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        verifier_commande "$dep"
    done
    log "Toutes les dépendances sont présentes"
}

verifier_deps curl jq git rsync

# Avec suggestion d'installation
require() {
    command -v "$1" &>/dev/null || {
        echo "Erreur : '$1' requis mais absent." >&2
        case "$1" in
            jq)     echo "  → apt install jq  ou  brew install jq" >&2 ;;
            rsync)  echo "  → apt install rsync" >&2 ;;
        esac
        exit 127
    }
}
```

### 6.3 Vérification de l'utilisateur courant

```bash
# Vérifier qu'on est root (ou non-root)
require_root() {
    [[ $EUID -eq 0 ]] || die "Ce script doit être exécuté en root (sudo)"
}

require_non_root() {
    [[ $EUID -ne 0 ]] || die "Ce script ne doit PAS être exécuté en root"
}

# Vérifier qu'on est dans un dépôt git
require_git_repo() {
    git rev-parse --git-dir &>/dev/null || die "Pas dans un dépôt git"
}
```

---

## 7. `shellcheck` — Analyse statique

### 7.1 Installation et utilisation

```bash
# Installation
sudo apt install shellcheck          # Debian/Ubuntu
brew install shellcheck              # macOS

# Vérifier un script
shellcheck monscript.sh

# Vérifier plusieurs scripts
shellcheck scripts/*.sh

# Ignorer une règle spécifique (à utiliser avec parcimonie)
# shellcheck disable=SC2086
echo $variable_non_quotee
```

### 7.2 Erreurs classiques détectées par shellcheck

```bash
# SC2086 : Double quote to prevent globbing and word splitting
name="John Doe"
echo $name          # MAUVAIS : peut splitter sur l'espace
echo "$name"        # CORRECT

# SC2046 : Quote this to prevent word splitting
files=$(ls *.txt)
cp $files /dest/    # MAUVAIS
cp "$files" /dest/  # CORRECT (mais ls n'est pas la bonne approche)

# SC2091 : Remove surrounding quotes/brackets from $(...)
result="$(cat fichier)"  # CORRECT (avec guillemets)
result=$(cat fichier)    # Aussi correct, mais résultat doit être quoté à l'usage

# SC2164 : Use 'cd ... || exit' or 'cd ... || return'
cd /tmp              # MAUVAIS avec set -e : peut continuer si cd échoue
cd /tmp || exit 1    # CORRECT

# SC2181 : Check exit code directly
if [ $? -eq 0 ]; then  # MAUVAIS : $? peut être pollué
    echo "ok"
fi
if commande; then       # CORRECT
    echo "ok"
fi

# SC2006 : Use $(...) instead of legacy backticks
result=`commande`    # MAUVAIS (déprécié)
result=$(commande)   # CORRECT
```

> **Astuce pro** : Intégrez `shellcheck` dans votre éditeur (extension VS Code, plugin Vim/Neovim) pour obtenir le feedback en temps réel. En CI, ajoutez `shellcheck scripts/*.sh` comme étape obligatoire.

---

## 8. Tests avec `bats`

### 8.1 Installation de bats

```bash
# Via git
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local

# Via npm
npm install -g bats

# Via apt (Ubuntu 22.04+)
sudo apt install bats
```

### 8.2 Structure d'un fichier de test

```bash
#!/usr/bin/env bats
# tests/test_monscript.bats

# Charger le script à tester
setup() {
    # Préparation avant chaque test
    export TMPDIR=$(mktemp -d)
    source "$(dirname "$BATS_TEST_FILENAME")/../lib/fonctions.sh"
}

teardown() {
    # Nettoyage après chaque test
    rm -rf "$TMPDIR"
}

@test "valider_email accepte une adresse valide" {
    run valider_email "user@example.com"
    [ "$status" -eq 0 ]
    [[ "$output" == *"valide"* ]]
}

@test "valider_email rejette une adresse invalide" {
    run valider_email "pas-un-email"
    [ "$status" -ne 0 ]
}

@test "traiter_fichier échoue si le fichier n'existe pas" {
    run traiter_fichier "/fichier/inexistant"
    [ "$status" -eq 2 ]
    [[ "$output" == *"introuvable"* ]]
}

@test "compter_lignes retourne le bon nombre" {
    echo -e "a\nb\nc" > "$TMPDIR/test.txt"
    run compter_lignes "$TMPDIR/test.txt"
    [ "$status" -eq 0 ]
    [ "$output" -eq 3 ]
}
```

### 8.3 Lancer les tests

```bash
# Un fichier
bats tests/test_monscript.bats

# Tous les tests
bats tests/

# Avec sortie TAP (intégration CI)
bats --tap tests/

# Exemple de sortie :
# ok 1 valider_email accepte une adresse valide
# ok 2 valider_email rejette une adresse invalide
# ok 3 traiter_fichier échoue si le fichier n'existe pas
# ok 4 compter_lignes retourne le bon nombre
```

---

## 9. Logging structuré vers syslog

### 9.1 La commande `logger`

```bash
# logger : envoyer des messages vers syslog
logger "Message simple"

# Avec priorité (facility.level)
logger -p user.info    "Démarrage du service"
logger -p user.warning "Ressource faible"
logger -p user.err     "Erreur critique"
logger -p daemon.err   "Erreur daemon"

# Avec tag (identifiant du programme)
logger -t "monscript" "Traitement démarré"
logger -t "monscript" -p user.err "Échec traitement fichier.txt"

# Combiner avec votre fonction log()
log_syslog() {
    local level="${1:-info}"
    shift
    echo "[$(timestamp)] $level: $*" >&2
    logger -t "$(basename "$0")" -p "user.${level}" "$*"
}
```

### 9.2 Consulter les logs syslog

```bash
# Voir les logs syslog
tail -f /var/log/syslog
grep "monscript" /var/log/syslog

# Via journalctl (systemd)
journalctl -t monscript
journalctl -t monscript --since "1 hour ago"
journalctl -t monscript -p err
```

### 9.3 Modèle complet de script robuste

```bash
#!/bin/bash
# ============================================================
# Modèle de script robuste
# Usage : monscript.sh [-v] [-c config] fichier_entrée
# ============================================================
set -euo pipefail

# --- Variables globales ---
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

VERBOSE=0
CONFIG_FILE="/etc/monscript/config.conf"
TMPDIR_WORK=""

# --- Couleurs ---
if [[ -t 2 ]]; then
    R='\033[0;31m' Y='\033[1;33m' G='\033[0;32m' B='\033[0;34m' N='\033[0m'
else
    R='' Y='' G='' B='' N=''
fi

# --- Fonctions de log ---
ts()   { date '+%Y-%m-%d %H:%M:%S'; }
log()  { echo -e "${G}[$(ts)] INFO${N}  $*" >&2; }
warn() { echo -e "${Y}[$(ts)] WARN${N}  $*" >&2; }
die()  { echo -e "${R}[$(ts)] ERROR${N} $*" >&2; exit 1; }
dbg()  { [[ $VERBOSE -eq 1 ]] && echo -e "${B}[$(ts)] DEBUG${N} $*" >&2 || true; }

# --- Nettoyage ---
cleanup() {
    local exit_code=$?
    dbg "Nettoyage (code=$exit_code)"
    [[ -n "$TMPDIR_WORK" ]] && rm -rf "$TMPDIR_WORK"
    exit $exit_code
}
trap cleanup EXIT

# --- Aide ---
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [-v] [-c config] fichier

Options:
  -v          Mode verbeux
  -c fichier  Fichier de configuration (défaut: $CONFIG_FILE)
  -h          Afficher cette aide

EOF
    exit 0
}

# --- Parsing des arguments ---
while getopts "vc:h" opt; do
    case "$opt" in
        v) VERBOSE=1 ;;
        c) CONFIG_FILE="$OPTARG" ;;
        h) usage ;;
        *) die "Option invalide: -$OPTARG" ;;
    esac
done
shift $((OPTIND - 1))

[[ $# -lt 1 ]] && die "Argument manquant. Utilisez -h pour l'aide."

FICHIER_ENTREE="$1"

# --- Vérifications ---
command -v jq &>/dev/null || die "jq requis (apt install jq)"
[[ -f "$FICHIER_ENTREE" ]] || die "Fichier introuvable: $FICHIER_ENTREE"
[[ -r "$FICHIER_ENTREE" ]] || die "Fichier non lisible: $FICHIER_ENTREE"

# --- Initialisation ---
TMPDIR_WORK=$(mktemp -d "/tmp/${SCRIPT_NAME%.sh}.XXXXXX")
log "Répertoire de travail: $TMPDIR_WORK"

# --- Logique principale ---
main() {
    log "Démarrage du traitement: $FICHIER_ENTREE"
    dbg "Config: $CONFIG_FILE"

    # ... traitement ...

    log "Traitement terminé avec succès"
}

main
```

---

## Tableau récapitulatif

| Technique | Rôle | Quand l'utiliser |
|-----------|------|-----------------|
| `set -e` | Quitte sur erreur | Toujours en script de production |
| `set -u` | Erreur sur variable non définie | Toujours |
| `set -o pipefail` | Propage erreurs dans les pipes | Toujours |
| `set -x` | Trace d'exécution | Debug uniquement |
| `trap ... EXIT` | Nettoyage garanti | Dès qu'on crée des ressources temporaires |
| `trap ... ERR` | Log des erreurs | Debug et audit |
| `trap ... INT` | Gestion Ctrl+C | Scripts interactifs |
| `command -v` | Tester présence commande | Avant d'utiliser une dépendance |
| `die()` / `log()` | Messages standardisés | Tout script |
| `shellcheck` | Analyse statique | En développement + CI |
| `bats` | Tests unitaires | Librairies Bash |
| `logger` | Syslog | Scripts système/daemon |

## À retenir

- `set -euo pipefail` doit être la première chose après le shebang de tout script de production
- `trap cleanup EXIT` garantit le nettoyage même en cas d'erreur ou d'interruption
- Les fonctions `die()`/`log()`/`warn()` uniformisent les messages et simplifient la maintenance
- `command -v` est la façon idiomatique de tester la présence d'une commande (pas `which`)
- `shellcheck` détecte 80% des bugs courants avant l'exécution — intégrez-le à votre workflow
- `$?` ne capte que le code de la **dernière** commande : sauvegardez-le si nécessaire

➡️ [Chapitre 14 — Bash avancé](../14_bash_avance/README.md)
