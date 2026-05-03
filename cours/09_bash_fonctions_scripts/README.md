# Chapitre 9 — Bash : Fonctions et scripts modulaires

Un bon script Bash n'est pas qu'une suite de commandes : c'est un programme structuré, lisible et maintenable. Ce chapitre explore les fonctions, la gestion des options, le débogage et toutes les pratiques qui distinguent un script professionnel d'un enchaînement de commandes fragile.

---

## 1. Fonctions Bash

### 1.1 Déclaration de fonctions

```bash
# Syntaxe 1 — avec le mot-clé function
function dire_bonjour() {
    echo "Bonjour !"
}

# Syntaxe 2 — sans le mot-clé function (POSIX, recommandée)
dire_bonjour() {
    echo "Bonjour !"
}

# Appel de la fonction
dire_bonjour

# Les fonctions acceptent des arguments positionnels ($1, $2...)
saluer() {
    local nom="$1"
    local titre="${2:-M.}"
    echo "Bonjour, $titre $nom !"
}

saluer "Dupont" "Dr"    # Bonjour, Dr Dupont !
saluer "Martin"         # Bonjour, M. Martin !
```

### 1.2 Variables `local`

```bash
# Sans local : la variable est globale
compteur=0
incrementer() {
    compteur=$((compteur + 1))    # Modifie la variable globale
}
incrementer
echo "$compteur"    # 1

# Avec local : la variable est locale à la fonction
multiplier() {
    local resultat=$(( $1 * $2 ))    # Locale à multiplier
    echo "$resultat"
}

r=$(multiplier 3 4)
echo "$r"           # 12
echo "$resultat"    # Vide — n'existe pas en dehors

# Les paramètres $1..$9 et $# sont locaux à la fonction
afficher_args() {
    echo "Nb args fonction : $#"
    echo "1er arg fonction : $1"
}
afficher_args "a" "b" "c"
echo "Nb args script : $#"    # Inchangé
```

> **Piège courant** : Oublier `local` dans une fonction peut corrompre des variables du scope global portant le même nom. Déclarez **toujours** vos variables de travail avec `local`.

### 1.3 Valeur de retour

```bash
# Bash : les fonctions retournent un code de sortie (0-255)
# Pour retourner une valeur, utilisez echo + $(...)

verifier_age() {
    local age="$1"
    if (( age >= 18 )); then
        return 0    # Succès (majeur)
    else
        return 1    # Échec (mineur)
    fi
}

if verifier_age 20; then
    echo "Majeur"
fi

verifier_age 15
echo "Code retour : $?"    # 1

# Retourner une valeur complexe
obtenir_date() {
    echo "$(date '+%Y-%m-%d')"
}

aujourd_hui=$(obtenir_date)
echo "Aujourd'hui : $aujourd_hui"

# Retourner plusieurs valeurs avec des variables globales
# (ou via stdout et un tableau)
calculer() {
    local a=$1 b=$2
    SOMME=$((a + b))
    PRODUIT=$((a * b))
}

calculer 3 4
echo "Somme: $SOMME, Produit: $PRODUIT"
```

> **Astuce pro** : Pour "retourner" une valeur depuis une fonction, `echo` + substitution de commande `$()` est le pattern idiomatique en Bash. Évitez les variables globales sauf pour des cas très spécifiques.

---

## 2. Portée des variables

```bash
#!/usr/bin/env bash

# Variable globale
GLOBAL="je suis global"

demo_portee() {
    local LOCAL="je suis local"
    echo "Dans la fonction : GLOBAL=$GLOBAL"
    echo "Dans la fonction : LOCAL=$LOCAL"
    GLOBAL="modifié depuis la fonction"
}

demo_portee
echo "Après la fonction : GLOBAL=$GLOBAL"
echo "Après la fonction : LOCAL='$LOCAL'"    # Vide

# Sous-shell — les modifications ne remontent pas
modifier_dans_sous_shell() {
    (
        GLOBAL="modifié dans sous-shell"
        echo "Dans sous-shell: $GLOBAL"
    )
    echo "Après sous-shell: $GLOBAL"    # Inchangé !
}

modifier_dans_sous_shell
```

---

## 3. `getopts` — Parser les options

```bash
#!/usr/bin/env bash

# getopts est le standard POSIX pour les options courtes (-v, -f fichier)
usage() {
    echo "Usage: $0 [-v] [-f fichier] [-n nombre] <argument>"
    echo "  -v          : mode verbose"
    echo "  -f fichier  : fichier d'entrée"
    echo "  -n nombre   : nombre d'itérations"
    exit 1
}

VERBOSE=false
FICHIER=""
NOMBRE=10

while getopts "vf:n:h" opt; do
    case "$opt" in
        v)
            VERBOSE=true
            ;;
        f)
            FICHIER="$OPTARG"    # OPTARG contient la valeur de l'option
            ;;
        n)
            NOMBRE="$OPTARG"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Option invalide : -$OPTARG" >&2
            usage
            ;;
        :)
            echo "L'option -$OPTARG requiert un argument" >&2
            usage
            ;;
    esac
done

# Supprimer les options traitées — $@ contient maintenant les arguments restants
shift $((OPTIND - 1))

$VERBOSE && echo "[VERBOSE] Fichier=$FICHIER, Nombre=$NOMBRE"
echo "Arguments restants : $@"
```

> **Piège courant** : `getopts` ne gère que les options courtes (`-v`, `-f`). Pour les options longues (`--verbose`, `--file`), utilisez `getopt` (externe) ou parsez manuellement avec un `while` + `case`.

---

## 4. `source` et inclusion de fichiers

```bash
# source (ou .) charge un fichier dans le shell courant
# Les variables et fonctions deviennent disponibles immédiatement

# Fichier lib/utils.sh
cat > /tmp/lib_utils.sh << 'EOF'
LOG_LEVEL="INFO"

log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%H:%M:%S')] [$level] $message"
}

verifier_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Ce script doit être exécuté en root" >&2
        return 1
    fi
    return 0
}
EOF

# Dans votre script principal
source /tmp/lib_utils.sh
# ou équivalent POSIX :
. /tmp/lib_utils.sh

log "INFO" "Script démarré"
verifier_root || exit 1

# Source avec vérification d'existence
LIB_DIR="$(dirname "$0")/lib"
if [[ -f "$LIB_DIR/utils.sh" ]]; then
    source "$LIB_DIR/utils.sh"
else
    echo "Bibliothèque introuvable : $LIB_DIR/utils.sh" >&2
    exit 1
fi
```

---

## 5. Shebang et portabilité

```bash
#!/usr/bin/env bash
# ↑ Recommandé : trouve bash dans le PATH (portable entre systèmes)

#!/bin/bash
# Chemin absolu — peut ne pas exister sur certains systèmes (macOS, BSD)

#!/usr/bin/env sh
# POSIX sh — le plus portable, mais sans les extensions Bash

# Vérifier la version de bash
bash --version
# GNU bash, version 5.2.15

# Tester si une commande est disponible
if ! command -v jq &>/dev/null; then
    echo "jq n'est pas installé. Installez-le avec : apt install jq" >&2
    exit 1
fi
```

---

## 6. Variables `readonly` et `export`

```bash
#!/usr/bin/env bash

# readonly — empêche la modification
readonly VERSION="1.0.0"
readonly MAX_RETRIES=3
readonly CONFIG_FILE="/etc/app/config.conf"

# Tentative de modification → erreur
# VERSION="2.0"    # bash: VERSION: variable en lecture seule

# export — rend visible dans les processus enfants
export DATABASE_URL="postgresql://localhost/mydb"
export PATH="$HOME/bin:$PATH"

# Déclarer et exporter en même temps
export -r API_KEY="secret123"    # readonly + export

# Vérifier les variables exportées
export -p | grep DATABASE

# Constantes en majuscules (convention)
readonly -a COULEURS=("rouge" "vert" "bleu")
echo "${COULEURS[0]}"    # rouge
```

---

## 7. `printf` vs `echo`

```bash
# echo — simple mais avec des pièges
echo "Bonjour"
echo -n "Sans saut de ligne"
echo -e "Avec\tTabulation\net\nSauts"

# echo varie selon les shells et systèmes — évitez les options non-POSIX

# printf — plus robuste et portable
printf "Bonjour\n"
printf "Sans saut de ligne"
printf "Avec\tTabulation\n"

# Formatage numérique
printf "%d\n" 42              # 42
printf "%05d\n" 42            # 00042
printf "%.2f\n" 3.14159       # 3.14
printf "%e\n" 1234567         # 1.234567e+06
printf "%10s\n" "droite"      #      droite (alignement droite)
printf "%-10s\n" "gauche"     # gauche     (alignement gauche)

# Plusieurs valeurs
printf "%-15s %5d €\n" "Alice" 2500
printf "%-15s %5d €\n" "Bob" 3200
printf "%-15s %5d €\n" "Charlie" 1800

# printf dans une variable
message=$(printf "Erreur %d : %s\n" 404 "Not Found")
echo "$message"

# Couleurs avec printf
ROUGE='\033[0;31m'
VERT='\033[0;32m'
RESET='\033[0m'

printf "${VERT}Succès${RESET}\n"
printf "${ROUGE}Erreur${RESET}\n"
```

---

## 8. Here-documents (`<<EOF`)

```bash
# Passer un bloc de texte multi-lignes à une commande
cat << 'EOF'
Ligne 1
Ligne 2 avec $variable non développée (guillemets simples sur EOF)
Ligne 3
EOF

# Avec expansion de variables
nom="Alice"
cat << EOF
Bonjour $nom,
Votre répertoire home est : $HOME
La date est : $(date)
EOF

# Indentation avec <<- (supprime les tabulations initiales)
if true; then
    cat <<- EOF
        Cette ligne est indentée dans le code
        mais pas dans la sortie
    EOF
fi

# Rediriger vers un fichier
cat > /tmp/config.ini << 'EOF'
[database]
host=localhost
port=5432
name=mydb
EOF

# Utiliser avec d'autres commandes
mysql -u root << 'SQL'
CREATE DATABASE IF NOT EXISTS myapp;
USE myapp;
CREATE TABLE users (id INT AUTO_INCREMENT, name VARCHAR(100));
SQL

# Here-string (<<< pour une seule ligne)
read -r ligne <<< "une seule ligne"
grep "pattern" <<< "$variable"
```

---

## 9. Débogage

### 9.1 `bash -x` et `set -x`

```bash
# Lancer un script en mode débogage
bash -x mon_script.sh

# Activer le débogage dans le script
set -x    # Active la trace d'exécution
# ... code ...
set +x    # Désactive la trace

# PS4 — personnaliser le prompt de débogage
export PS4='[${BASH_SOURCE[0]}:${LINENO}] '
set -x

# PS4 avec numéro de ligne coloré
export PS4='\033[0;33m[${BASH_SOURCE##*/}:${LINENO}]\033[0m '
```

### 9.2 `set -e`, `set -u`, `set -o pipefail`

```bash
#!/usr/bin/env bash

# set -e : quitter si une commande retourne une erreur
set -e

# set -u : traiter les variables non définies comme des erreurs
set -u

# set -o pipefail : un pipe échoue si une commande intermédiaire échoue
set -o pipefail

# La combinaison recommandée pour tout script de production
set -euo pipefail

# Exemple — sans set -e, le script continue après l'erreur
ls /repertoire/inexistant     # Erreur ignorée sans set -e
echo "Cette ligne s'exécute quand même..."

# Avec set -e, le script s'arrête à la première erreur

# Contourner set -e pour une commande qui peut échouer
grep "pattern" fichier.txt || true    # Ignore l'erreur de grep
commande_optionnelle || :             # : est équivalent à true
```

### 9.3 `trap` — Gestion des erreurs et nettoyage

```bash
#!/usr/bin/env bash
set -euo pipefail

# Nettoyage automatique à la sortie
TMPDIR=$(mktemp -d)

cleanup() {
    echo "Nettoyage..."
    rm -rf "$TMPDIR"
    echo "Terminé."
}

trap cleanup EXIT         # Exécuté à la sortie (normale ou erreur)
trap cleanup INT TERM     # Exécuté sur Ctrl+C ou kill

# Capturer les erreurs avec ERR
on_error() {
    echo "ERREUR à la ligne $LINENO : commande '$BASH_COMMAND' a échoué" >&2
}
trap on_error ERR

# Réinitialiser un trap
trap - EXIT
```

---

## 10. `shellcheck` — Analyser les scripts

```bash
# Installer shellcheck
apt install shellcheck        # Debian/Ubuntu
brew install shellcheck       # macOS

# Analyser un script
shellcheck mon_script.sh

# Analyser avec un format spécifique
shellcheck -f gcc mon_script.sh    # Format GCC
shellcheck -f json mon_script.sh   # Format JSON

# Désactiver une règle spécifique
# shellcheck disable=SC2086
echo $variable_sans_guillemets

# Spécifier le shell cible
shellcheck -s bash mon_script.sh
shellcheck -s sh mon_script.sh

# Erreurs fréquentes détectées par shellcheck :
# SC2086 : variable sans guillemets (risque de word splitting)
# SC2046 : résultat de commande sans guillemets
# SC2181 : utilisation de $? au lieu de if commande
# SC2006 : utilisation de backticks au lieu de $()
# SC1091 : fichier sourcé introuvable
```

---

## 11. Organisation d'un script

```bash
#!/usr/bin/env bash
# =============================================================================
# Script : nom_du_script.sh
# Description : Description courte du script
# Auteur  : Prénom Nom <email@exemple.com>
# Version : 1.0.0
# Date    : 2024-01-15
# Usage   : ./nom_du_script.sh [-v] [-h] <argument>
# =============================================================================

set -euo pipefail

# --- Constantes ---------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

# --- Couleurs -----------------------------------------------------------------
readonly ROUGE='\033[0;31m'
readonly VERT='\033[0;32m'
readonly JAUNE='\033[1;33m'
readonly RESET='\033[0m'

# --- Fonctions utilitaires ----------------------------------------------------
log_info()  { printf "${VERT}[INFO]${RESET}  %s\n" "$*"; }
log_warn()  { printf "${JAUNE}[WARN]${RESET}  %s\n" "$*" >&2; }
log_error() { printf "${ROUGE}[ERROR]${RESET} %s\n" "$*" >&2; }

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [-v] [-h] <argument>

Options:
    -v    Mode verbose
    -h    Afficher cette aide

Arguments:
    argument    Description de l'argument

Examples:
    $SCRIPT_NAME -v mon_argument
EOF
}

cleanup() {
    log_info "Nettoyage..."
    # Supprimer les fichiers temporaires
}

# --- Parsing des options ------------------------------------------------------
VERBOSE=false

while getopts "vh" opt; do
    case "$opt" in
        v) VERBOSE=true ;;
        h) usage; exit 0 ;;
        \?) log_error "Option invalide: -$OPTARG"; usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# --- Vérifications préalables -------------------------------------------------
if [[ $# -lt 1 ]]; then
    log_error "Argument manquant"
    usage
    exit 1
fi

# --- Corps principal ----------------------------------------------------------
main() {
    local argument="$1"

    trap cleanup EXIT

    $VERBOSE && log_info "Mode verbose activé"
    log_info "Traitement de : $argument"

    # Logique principale ici

    log_info "Script terminé avec succès"
}

main "$@"
```

---

## 12. Exemple complet : script de backup

```bash
#!/usr/bin/env bash
# =============================================================================
# backup.sh — Script de sauvegarde avec options
# Usage: ./backup.sh -s <source> -d <destination> [-v] [-c]
# =============================================================================

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

ROUGE='\033[0;31m'; VERT='\033[0;32m'; JAUNE='\033[1;33m'; RESET='\033[0m'
log_info()  { printf "${VERT}[INFO]${RESET}  %s\n" "$*"; }
log_warn()  { printf "${JAUNE}[WARN]${RESET}  %s\n" "$*" >&2; }
log_error() { printf "${ROUGE}[ERROR]${RESET} %s\n" "$*" >&2; }

usage() {
    cat << EOF
Usage: $SCRIPT_NAME -s <source> -d <destination> [-v] [-c] [-h]

Options:
    -s DIR    Répertoire source (obligatoire)
    -d DIR    Répertoire de destination (obligatoire)
    -v        Mode verbose (affiche les fichiers copiés)
    -c        Compression (crée une archive .tar.gz)
    -h        Afficher cette aide

Example:
    $SCRIPT_NAME -s /home/alice -d /backup -v
    $SCRIPT_NAME -s /etc -d /mnt/usb -c
EOF
}

verifier_prerequis() {
    local source="$1"
    local destination="$2"

    if [[ ! -d "$source" ]]; then
        log_error "Source introuvable : $source"
        exit 1
    fi

    if [[ ! -r "$source" ]]; then
        log_error "Source non lisible : $source"
        exit 1
    fi

    # Créer la destination si elle n'existe pas
    if [[ ! -d "$destination" ]]; then
        log_info "Création du répertoire de destination : $destination"
        mkdir -p "$destination"
    fi

    if [[ ! -w "$destination" ]]; then
        log_error "Destination non accessible en écriture : $destination"
        exit 1
    fi
}

backup_rsync() {
    local source="$1"
    local destination="$2"
    local verbose="$3"

    local rsync_opts=("-a" "--delete" "--progress")
    $verbose && rsync_opts+=("-v")

    local dest_dir="${destination}/$(basename "$source")_${TIMESTAMP}"

    log_info "Démarrage de la sauvegarde..."
    log_info "Source      : $source"
    log_info "Destination : $dest_dir"

    rsync "${rsync_opts[@]}" "$source/" "$dest_dir/"

    local taille=$(du -sh "$dest_dir" | cut -f1)
    log_info "Sauvegarde terminée : $dest_dir ($taille)"
}

backup_compress() {
    local source="$1"
    local destination="$2"

    local nom_archive="$(basename "$source")_${TIMESTAMP}.tar.gz"
    local chemin_archive="${destination}/${nom_archive}"

    log_info "Création de l'archive : $chemin_archive"
    tar -czf "$chemin_archive" -C "$(dirname "$source")" "$(basename "$source")"

    local taille=$(du -sh "$chemin_archive" | cut -f1)
    log_info "Archive créée : $chemin_archive ($taille)"
}

# Parsing des options
SOURCE=""
DESTINATION=""
VERBOSE=false
COMPRESS=false

while getopts "s:d:vch" opt; do
    case "$opt" in
        s) SOURCE="$OPTARG" ;;
        d) DESTINATION="$OPTARG" ;;
        v) VERBOSE=true ;;
        c) COMPRESS=true ;;
        h) usage; exit 0 ;;
        \?) log_error "Option invalide : -$OPTARG"; usage; exit 1 ;;
        :)  log_error "L'option -$OPTARG requiert un argument"; exit 1 ;;
    esac
done

# Vérifier les arguments obligatoires
if [[ -z "$SOURCE" || -z "$DESTINATION" ]]; then
    log_error "Les options -s et -d sont obligatoires"
    usage
    exit 1
fi

main() {
    verifier_prerequis "$SOURCE" "$DESTINATION"

    if $COMPRESS; then
        backup_compress "$SOURCE" "$DESTINATION"
    else
        backup_rsync "$SOURCE" "$DESTINATION" "$VERBOSE"
    fi
}

main
```

---

## Tableau récapitulatif

| Concept | Syntaxe | Notes |
|---------|---------|-------|
| Fonction | `nom() { ... }` | Préférer sans `function` |
| Variable locale | `local var="val"` | Obligatoire dans les fonctions |
| Valeur de retour | `echo val` + `$(...)` | Pattern idiomatique |
| Code de sortie | `return N` | 0=succès, 1-255=erreur |
| Options | `getopts "vh:f:"` | `:` = option avec argument |
| Source | `source fichier.sh` ou `. fichier.sh` | POSIX : `.` |
| Shebang | `#!/usr/bin/env bash` | Plus portable |
| Readonly | `readonly VAR=val` | Ne peut plus être modifiée |
| Export | `export VAR=val` | Visible dans les processus enfants |
| Printf | `printf "%s\n" "$val"` | Plus robuste qu'echo |
| Here-doc | `cat << 'EOF' ... EOF` | `'EOF'` désactive l'expansion |
| Débogage | `bash -x script.sh` | Trace toutes les commandes |
| Mode strict | `set -euo pipefail` | Recommandé en production |
| Trap | `trap cleanup EXIT` | Nettoyage automatique |

---

## À retenir

- **`local`** est indispensable dans chaque fonction — sans lui, vous polluez le scope global.
- **`set -euo pipefail`** doit être la première ligne de tout script de production.
- **`getopts`** est la méthode standard pour parser les options courtes — apprenez sa syntaxe.
- La structure **header / constantes / fonctions / main()** rend les scripts maintenables.
- **`shellcheck`** doit être intégré à votre workflow — il détecte la majorité des bugs courants.
- Utilisez **`trap cleanup EXIT`** pour nettoyer les fichiers temporaires quoi qu'il arrive.
- **`printf`** est plus fiable qu'`echo` pour le formatage et les messages avec des caractères spéciaux.

➡️ [Chapitre 10 — Processus et jobs](../10_processus_jobs/README.md)
