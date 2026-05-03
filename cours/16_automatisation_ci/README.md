# Chapitre 16 — Automatisation et CI

L'automatisation est l'art de transformer les tâches répétitives en processus fiables et reproductibles. Ce chapitre couvre les outils de planification (`cron`), d'orchestration (`make`), d'intégration continue (GitHub Actions) et se conclut par un projet fil rouge : un toolkit de déploiement complet en Bash.

---

## 1. `cron` avancé

### 1.1 Syntaxe et variables d'environnement

```bash
# Éditer la crontab
crontab -e      # Crontab de l'utilisateur courant
sudo crontab -e # Crontab root
crontab -l      # Lister les tâches
crontab -r      # Supprimer toutes les tâches (ATTENTION !)

# Syntaxe : minute heure jour_mois mois jour_semaine commande
# ┌───────────── minute (0-59)
# │ ┌─────────── heure (0-23)
# │ │ ┌───────── jour du mois (1-31)
# │ │ │ ┌─────── mois (1-12)
# │ │ │ │ ┌───── jour de la semaine (0-7, 0=7=dimanche)
# │ │ │ │ │
# * * * * * commande

# Exemples
0 2 * * *     /opt/scripts/backup.sh          # Tous les jours à 2h
*/15 * * * *  /opt/scripts/healthcheck.sh     # Toutes les 15 minutes
0 0 * * 1     /opt/scripts/rapport_hebdo.sh   # Lundi à minuit
0 9 1 * *     /opt/scripts/factures.sh        # 1er du mois à 9h
0 6,18 * * *  /opt/scripts/sync.sh            # 6h et 18h
0 8-17 * * 1-5 /opt/scripts/check_prod.sh    # 8h-17h, lun-ven
```

### 1.2 Variables d'environnement dans cron

```bash
# cron ne charge PAS le profil shell complet
# Définir les variables en tête de crontab

SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MAILTO=admin@example.com        # Envoyer les sorties par email
HOME=/home/deployer              # Répertoire home

# Capturer les erreurs dans un log
0 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1

# Supprimer la sortie (silencieux)
0 2 * * * /opt/scripts/backup.sh >/dev/null 2>&1

# Horodater les logs
0 2 * * * echo "=== $(date) ===" >> /var/log/backup.log && /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```

### 1.3 `MAILTO` et notifications

```bash
# MAILTO vide = pas d'email
MAILTO=""

# MAILTO avec adresse = email sur chaque sortie
MAILTO="ops@example.com"

# Envoyer seulement en cas d'erreur
0 2 * * * /opt/scripts/backup.sh || echo "BACKUP FAILED $(date)" | mail -s "Alert: backup" admin@example.com
```

### 1.4 `run-parts` et `anacron`

```bash
# run-parts : exécuter tous les scripts d'un répertoire
run-parts /etc/cron.daily
run-parts --test /etc/cron.hourly   # Test sans exécution

# Répertoires standards
/etc/cron.hourly/     # Scripts exécutés toutes les heures
/etc/cron.daily/      # Scripts quotidiens
/etc/cron.weekly/     # Scripts hebdomadaires
/etc/cron.monthly/    # Scripts mensuels

# anacron : pour systèmes non allumés en permanence
# /etc/anacrontab
cat /etc/anacrontab
# Format : période délai nom commande
# 1      5  cron.daily  run-parts --report /etc/cron.daily
# 7     10  cron.weekly run-parts --report /etc/cron.weekly
```

> **Piège courant** : Cron utilise un PATH minimal. Si votre script appelle `python3`, `node` ou des binaires dans `/usr/local/bin`, spécifiez le PATH complet dans la crontab ou utilisez des chemins absolus dans vos scripts.

---

## 2. `Makefile` pour automatiser des tâches

### 2.1 Structure d'un Makefile

```makefile
# Makefile
# Format : target: dependencies
#            <TAB> commands (doit commencer par une tabulation !)

# Variables
APP_NAME    := mon-app
VERSION     := $(shell git describe --tags --always)
BUILD_DIR   := build
DOCKER_IMG  := $(APP_NAME):$(VERSION)

# Cible par défaut (première cible)
.DEFAULT_GOAL := help

# Cibles phony (pas des fichiers)
.PHONY: help build test clean deploy install lint

# Aide automatique
help: ## Afficher cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	    | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Build
build: ## Compiler l'application
	@echo "Build $(APP_NAME) $(VERSION)..."
	mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(APP_NAME) ./cmd/...

# Tests
test: ## Lancer les tests unitaires
	go test ./... -v -cover

test-integration: ## Lancer les tests d'intégration
	docker compose up -d
	go test ./tests/integration/... -tags integration
	docker compose down

# Qualité de code
lint: ## Vérifier la qualité du code
	golangci-lint run
	shellcheck scripts/*.sh

# Docker
docker-build: ## Construire l'image Docker
	docker build -t $(DOCKER_IMG) .
	docker tag $(DOCKER_IMG) $(APP_NAME):latest

docker-push: docker-build ## Pousser l'image Docker
	docker push $(DOCKER_IMG)

# Nettoyage
clean: ## Supprimer les artefacts de build
	rm -rf $(BUILD_DIR)
	go clean

# Déploiement
deploy: test lint build ## Déployer en production (test → lint → build)
	./scripts/deploy.sh -e prod -b $(VERSION)

install: build ## Installer localement
	install -m 755 $(BUILD_DIR)/$(APP_NAME) /usr/local/bin/
```

### 2.2 Pattern rules et variables automatiques

```makefile
# Variables automatiques
# $@ : nom de la cible
# $< : première dépendance
# $^ : toutes les dépendances
# $* : partie correspondante du pattern

# Pattern rule : compiler tous les .c en .o
%.o: %.c
	gcc -c $< -o $@

# Pattern rule : générer des rapports
reports/%.html: data/%.csv
	python3 scripts/generate_report.py $< > $@

# Utilisation des targets comme dépendances
all: main.o utils.o
	gcc $^ -o mon_programme

main.o: main.c main.h utils.h
utils.o: utils.c utils.h
```

### 2.3 `make help` — Auto-documentation

```makefile
# Convention : ## après la cible = description
# grep extrait les lignes avec cette convention

help:
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z_/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	    awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'
```

---

## 3. GitHub Actions avec scripts Bash

### 3.1 Workflow de base avec scripts Bash

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-22.04
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Installer shellcheck
        run: sudo apt-get install -y shellcheck
      
      - name: Vérifier les scripts shell
        shell: bash
        run: |
          set -euo pipefail
          find scripts/ -name "*.sh" -exec shellcheck {} +
          echo "Shellcheck OK"
      
      - name: Lancer les tests
        shell: bash
        run: |
          set -euo pipefail
          chmod +x scripts/run_tests.sh
          ./scripts/run_tests.sh
      
      - name: Build
        run: make build
        env:
          VERSION: ${{ github.sha }}
```

### 3.2 Matrices de tests

```yaml
jobs:
  test-matrix:
    strategy:
      matrix:
        os: [ubuntu-22.04, ubuntu-20.04]
        bash_version: ["5.1", "5.2"]
        fail-fast: false
    
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test sur ${{ matrix.os }}
        shell: bash
        run: |
          echo "OS: ${{ matrix.os }}"
          echo "Bash: $(bash --version | head -1)"
          ./scripts/test_compat.sh
```

### 3.3 Artefacts et cache

```yaml
steps:
  - name: Build
    run: make build
  
  - name: Upload artefact
    uses: actions/upload-artifact@v4
    with:
      name: mon-app-${{ github.sha }}
      path: build/
      retention-days: 30
  
  - name: Cache dépendances
    uses: actions/cache@v4
    with:
      path: ~/.cache/go
      key: ${{ runner.os }}-go-${{ hashFiles('go.sum') }}
      restore-keys: |
        ${{ runner.os }}-go-

  - name: Notifier Slack en cas d'échec
    if: failure()
    shell: bash
    run: |
      curl -s -X POST "${{ secrets.SLACK_WEBHOOK }}" \
        -H 'Content-type: application/json' \
        -d "{\"text\":\"Pipeline échoué sur \`${{ github.ref }}\`\"}"
```

---

## 4. Déploiement avec rsync + SSH

### 4.1 Pattern de déploiement rsync

```bash
#!/bin/bash
# deploy_rsync.sh — Déploiement simple via rsync

REMOTE_USER="deployer"
REMOTE_HOST="prod.example.com"
REMOTE_DIR="/var/www/mon-app"
LOCAL_DIR="./dist/"

# Options rsync
RSYNC_OPTS=(
    --archive           # Préserver permissions, timestamps, liens symboliques
    --verbose           # Sortie détaillée
    --compress          # Compresser pendant le transfert
    --delete            # Supprimer les fichiers absents en local
    --checksum          # Utiliser checksum plutôt que date/taille
    --exclude="*.log"   # Exclure les logs
    --exclude=".env"    # Exclure la config sensible
    --backup            # Faire une backup des fichiers remplacés
    --backup-dir="/var/www/backups/$(date +%Y%m%d_%H%M%S)"
)

rsync "${RSYNC_OPTS[@]}" \
    -e "ssh -i $HOME/.ssh/deploy_key -o StrictHostKeyChecking=no" \
    "$LOCAL_DIR" \
    "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"
```

---

## 5. Projet fil rouge — Toolkit de déploiement

Voici le script `deploy.sh` complet, illustrant toutes les techniques avancées du niveau 3.

```bash
#!/bin/bash
# =============================================================================
# deploy.sh — Toolkit de déploiement robuste
# Usage : ./deploy.sh -e <env> [-b <branch>] [-d] [-v]
# =============================================================================
set -euo pipefail

# =============================================================================
# CONSTANTES ET CONFIGURATION
# =============================================================================
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEPLOY_USER="deployer"
readonly BACKUP_RETAIN=5
readonly LOG_FILE="/var/log/deploy.log"

# =============================================================================
# COULEURS
# =============================================================================
if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# =============================================================================
# LOGGING
# =============================================================================
ts()   { date '+%Y-%m-%d %H:%M:%S'; }
log()  { echo -e "${GREEN}[$(ts)] INFO${NC}  $*" | tee -a "${LOG_FILE}" >&2; }
warn() { echo -e "${YELLOW}[$(ts)] WARN${NC}  $*" | tee -a "${LOG_FILE}" >&2; }
die()  { echo -e "${RED}[$(ts)] ERROR${NC} $*" | tee -a "${LOG_FILE}" >&2; exit 1; }
dbg()  { [[ ${VERBOSE:-0} -eq 1 ]] && echo -e "${CYAN}[$(ts)] DEBUG${NC} $*" >&2 || true; }
step() { echo -e "\n${BOLD}${BLUE}==>${NC}${BOLD} $*${NC}" >&2; }

# =============================================================================
# ÉTAT GLOBAL
# =============================================================================
ENV=""
BRANCH="main"
DRY_RUN=0
VERBOSE=0
REMOTE_HOST=""
REMOTE_DIR=""
SLACK_WEBHOOK=""
TMPDIR_WORK=""

# =============================================================================
# NETTOYAGE
# =============================================================================
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        warn "Script terminé avec erreur (code=$exit_code)"
        notify "ÉCHEC" "Déploiement échoué sur $ENV (code=$exit_code)"
    fi
    [[ -n "${TMPDIR_WORK:-}" ]] && rm -rf "$TMPDIR_WORK"
    dbg "Nettoyage terminé"
}
trap cleanup EXIT
trap 'die "Interrupted (SIGINT)"' INT
trap 'die "Terminated (SIGTERM)"' TERM

# =============================================================================
# AIDE
# =============================================================================
usage() {
    cat <<EOF
${BOLD}Usage:${NC} $SCRIPT_NAME [OPTIONS]

${BOLD}Description:${NC}
  Toolkit de déploiement avec build, tests, rsync et rollback.

${BOLD}Options:${NC}
  -e ENV      Environnement cible : dev, staging, prod (obligatoire)
  -b BRANCH   Branche Git à déployer (défaut: main)
  -d          Dry-run : simuler sans effectuer de changements
  -v          Mode verbeux
  -h          Afficher cette aide

${BOLD}Exemples:${NC}
  $SCRIPT_NAME -e staging -b feature/my-feature
  $SCRIPT_NAME -e prod -b v1.2.3
  $SCRIPT_NAME -e prod -d      # Dry-run en production
EOF
    exit 0
}

# =============================================================================
# PARSING DES ARGUMENTS
# =============================================================================
parse_args() {
    while getopts "e:b:dvh" opt; do
        case "$opt" in
            e) ENV="$OPTARG" ;;
            b) BRANCH="$OPTARG" ;;
            d) DRY_RUN=1 ;;
            v) VERBOSE=1 ;;
            h) usage ;;
            *) die "Option invalide. Utilisez -h pour l'aide." ;;
        esac
    done
    shift $((OPTIND - 1))

    [[ -z "$ENV" ]] && die "Environnement obligatoire (-e dev|staging|prod)"
    [[ "$ENV" =~ ^(dev|staging|prod)$ ]] || die "Environnement invalide: $ENV"
}

# =============================================================================
# CHARGEMENT DE LA CONFIGURATION
# =============================================================================
load_config() {
    local config_file="$SCRIPT_DIR/configs/${ENV}.conf"
    [[ -f "$config_file" ]] || die "Config introuvable: $config_file"

    # shellcheck source=/dev/null
    source "$config_file"

    # Valider les variables requises
    [[ -n "${REMOTE_HOST:-}" ]] || die "REMOTE_HOST non défini dans $config_file"
    [[ -n "${REMOTE_DIR:-}" ]]  || die "REMOTE_DIR non défini dans $config_file"

    SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
    dbg "Config chargée: host=$REMOTE_HOST dir=$REMOTE_DIR"
}

# =============================================================================
# VÉRIFICATION DES DÉPENDANCES
# =============================================================================
check_deps() {
    step "Vérification des dépendances"
    local deps=(git rsync ssh curl jq)
    local missing=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            dbg "  ✓ $dep"
        else
            missing+=("$dep")
        fi
    done

    [[ ${#missing[@]} -gt 0 ]] && die "Dépendances manquantes: ${missing[*]}"
    log "Dépendances OK"
}

# =============================================================================
# BUILD
# =============================================================================
build() {
    step "Build ($BRANCH)"

    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] make clean build VERSION=$BRANCH"
        return 0
    fi

    log "Nettoyage des artefacts précédents"
    make clean

    log "Compilation"
    make build VERSION="$BRANCH"
    log "Build terminé"
}

# =============================================================================
# TESTS
# =============================================================================
run_tests() {
    step "Tests"

    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] make test"
        return 0
    fi

    log "Lancement des tests unitaires"
    if ! make test; then
        die "Tests échoués — déploiement annulé"
    fi

    log "Tests passés"
}

# =============================================================================
# VÉRIFICATIONS PRÉ-DÉPLOIEMENT
# =============================================================================
pre_deploy_checks() {
    step "Vérifications pré-déploiement"

    # Vérifier que le repo git est propre
    if [[ -n "$(git status --porcelain)" ]]; then
        if [[ "$ENV" == "prod" ]]; then
            die "Dépôt git non propre — commit avant déploiement en prod"
        else
            warn "Dépôt git non propre (toléré en $ENV)"
        fi
    fi

    # Vérifier la connexion SSH
    log "Test de connexion SSH vers $REMOTE_HOST"
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "${DEPLOY_USER}@${REMOTE_HOST}" 'echo ok' &>/dev/null; then
        die "Connexion SSH échouée vers ${DEPLOY_USER}@${REMOTE_HOST}"
    fi
    log "SSH OK"

    # Vérifier l'espace disque distant
    local free_kb
    free_kb=$(ssh "${DEPLOY_USER}@${REMOTE_HOST}" "df -k '$REMOTE_DIR' | awk 'NR==2{print \$4}'")
    if [[ $free_kb -lt 512000 ]]; then
        warn "Espace disque faible sur $REMOTE_HOST : ${free_kb}k disponibles"
    fi
    log "Espace disque OK (${free_kb}k disponibles)"
}

# =============================================================================
# BACKUP
# =============================================================================
backup() {
    step "Backup de la version actuelle"
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"

    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Backup → ${REMOTE_DIR}-backups/${backup_name}"
        return 0
    fi

    ssh "${DEPLOY_USER}@${REMOTE_HOST}" "
        set -e
        if [[ -d '${REMOTE_DIR}' ]]; then
            mkdir -p '${REMOTE_DIR}-backups'
            cp -a '${REMOTE_DIR}' '${REMOTE_DIR}-backups/${backup_name}'
            echo 'Backup créé: ${backup_name}'
        fi

        # Nettoyer les anciennes backups (garder les $BACKUP_RETAIN dernières)
        ls -t '${REMOTE_DIR}-backups' | tail -n +$((BACKUP_RETAIN + 1)) | \
            xargs -I{} rm -rf '${REMOTE_DIR}-backups/{}'
    "
    log "Backup créé: $backup_name"
}

# =============================================================================
# DÉPLOIEMENT
# =============================================================================
deploy() {
    step "Déploiement vers $ENV ($REMOTE_HOST)"

    local rsync_opts=(
        --archive
        --verbose
        --compress
        --delete
        --checksum
        --exclude=".env*"
        --exclude="*.log"
        --exclude=".git"
        --exclude="node_modules"
    )

    if [[ $DRY_RUN -eq 1 ]]; then
        rsync_opts+=(--dry-run)
        log "[DRY-RUN] rsync vers ${REMOTE_HOST}:${REMOTE_DIR}"
    fi

    log "Synchronisation des fichiers"
    rsync "${rsync_opts[@]}" \
        -e "ssh -o StrictHostKeyChecking=no" \
        ./dist/ \
        "${DEPLOY_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

    if [[ $DRY_RUN -eq 0 ]]; then
        # Redémarrer le service
        log "Redémarrage du service"
        ssh "${DEPLOY_USER}@${REMOTE_HOST}" \
            "sudo systemctl restart mon-app && sudo systemctl is-active mon-app"
        log "Service redémarré avec succès"
    fi
}

# =============================================================================
# VÉRIFICATION POST-DÉPLOIEMENT
# =============================================================================
post_deploy_verify() {
    step "Vérification post-déploiement"

    if [[ $DRY_RUN -eq 1 ]]; then
        log "[DRY-RUN] Vérification healthcheck"
        return 0
    fi

    local url="https://${REMOTE_HOST}/health"
    local retries=5
    local delay=3

    log "Vérification healthcheck: $url"
    for i in $(seq 1 $retries); do
        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" || true)
        if [[ "$http_code" == "200" ]]; then
            log "Healthcheck OK (tentative $i/$retries)"
            return 0
        fi
        warn "Healthcheck KO (tentative $i/$retries, code=$http_code)"
        [[ $i -lt $retries ]] && sleep "$delay"
    done

    die "Healthcheck échoué après $retries tentatives — rollback recommandé"
}

# =============================================================================
# ROLLBACK
# =============================================================================
rollback() {
    step "Rollback vers la dernière backup"

    local last_backup
    last_backup=$(ssh "${DEPLOY_USER}@${REMOTE_HOST}" \
        "ls -t '${REMOTE_DIR}-backups' | head -1")

    [[ -z "$last_backup" ]] && die "Aucune backup disponible pour rollback"

    log "Rollback vers: $last_backup"
    ssh "${DEPLOY_USER}@${REMOTE_HOST}" "
        set -e
        rm -rf '${REMOTE_DIR}'
        cp -a '${REMOTE_DIR}-backups/${last_backup}' '${REMOTE_DIR}'
        sudo systemctl restart mon-app
    "
    log "Rollback terminé"
    notify "ROLLBACK" "Rollback vers $last_backup sur $ENV"
}

# =============================================================================
# NOTIFICATION SLACK
# =============================================================================
notify() {
    local status="$1"
    local message="$2"

    [[ -z "$SLACK_WEBHOOK" ]] && { dbg "Slack webhook non configuré"; return 0; }

    local color icon
    case "$status" in
        "SUCCÈS")   color="good";    icon=":white_check_mark:" ;;
        "ÉCHEC")    color="danger";  icon=":x:" ;;
        "ROLLBACK") color="warning"; icon=":warning:" ;;
        *)          color="#aaa";    icon=":information_source:" ;;
    esac

    local payload
    payload=$(jq -n \
        --arg color "$color" \
        --arg icon "$icon" \
        --arg status "$status" \
        --arg message "$message" \
        --arg env "$ENV" \
        --arg branch "$BRANCH" \
        --arg user "$(whoami)" \
        '{
            attachments: [{
                color: $color,
                title: "\($icon) Déploiement \($status)",
                text: $message,
                fields: [
                    {title: "Environnement", value: $env, short: true},
                    {title: "Branche", value: $branch, short: true},
                    {title: "Déclenché par", value: $user, short: true}
                ],
                ts: (now | floor)
            }]
        }')

    curl -s -X POST "$SLACK_WEBHOOK" \
        -H 'Content-type: application/json' \
        -d "$payload" &>/dev/null || warn "Notification Slack échouée"
    dbg "Notification envoyée"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    log "=== Déploiement démarré : env=$ENV branch=$BRANCH dry_run=$DRY_RUN ==="
    TMPDIR_WORK=$(mktemp -d "/tmp/deploy.XXXXXX")

    [[ $DRY_RUN -eq 1 ]] && warn "Mode DRY-RUN activé — aucun changement ne sera effectué"

    load_config
    check_deps
    pre_deploy_checks
    run_tests
    build
    backup
    deploy
    post_deploy_verify

    log "=== Déploiement terminé avec succès ==="
    notify "SUCCÈS" "Déploiement de $BRANCH sur $ENV réussi"
}

parse_args "$@"
main
```

> **Astuce pro** : Gardez ce script dans un dépôt Git séparé (infrastructure-as-code). Versionnez les fichiers de configuration par environnement et ne committez jamais les secrets — utilisez des variables d'environnement ou un vault (HashiCorp Vault, AWS Secrets Manager).

---

## Tableau récapitulatif

| Outil | Force | Cas d'usage |
|-------|-------|------------|
| `cron` | Simple, universel | Tâches planifiées récurrentes |
| `anacron` | Gère les machines éteintes | Laptops, serveurs non 24/7 |
| `Makefile` | Dépendances, auto-documentation | Build, tests, CI locale |
| GitHub Actions | CI/CD intégré Git | Tests auto, déploiement continu |
| `rsync` | Efficace, différentiel | Synchronisation fichiers, déploiement |
| `deploy.sh` | Flexible, robuste | Déploiement contrôlé en production |

## À retenir

- Toujours définir `PATH` et `SHELL` dans les crontabs — l'environnement cron est minimal
- `.PHONY` dans un Makefile déclare les cibles qui ne correspondent pas à des fichiers
- `getopts` dans le script de déploiement : parser les options proprement
- `trap cleanup EXIT` garantit le nettoyage et les notifications même en cas d'erreur
- Le pattern backup→deploy→verify→rollback-on-failure est la fondation de tout déploiement fiable
- En dry-run, toutes les étapes s'exécutent mais aucun changement n'est appliqué — testez toujours avant prod

➡️ [Annexes](../../annexes/A_aide_memoire.md)
