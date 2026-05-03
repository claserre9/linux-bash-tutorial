#!/bin/bash
# =============================================================================
# Solutions — Chapitre 16 : Automatisation et CI
# =============================================================================

# --- Solution 1 ---
ex_1() {
    echo "--- Exercice 1 : expressions cron ---"

    # "Tous les jours à 3h00 du matin"
    # minute=0, heure=3, jour=*, mois=*, jour_semaine=*
    local tache1="0 3 * * * /opt/scripts/backup.sh"

    # "Toutes les 5 minutes"
    # */5 = toutes les 5 minutes
    local tache2="*/5 * * * * /opt/scripts/check.sh"

    # "Le 1er de chaque mois à 8h30"
    # minute=30, heure=8, jour=1, mois=*, jour_semaine=*
    local tache3="30 8 1 * * /opt/scripts/rapport.sh"

    # "Du lundi au vendredi à 9h et 18h"
    # 0 = minute, 9,18 = deux heures, *, *, 1-5 = lundi(1) à vendredi(5)
    local tache4="0 9,18 * * 1-5 /opt/scripts/sync.sh"

    # "Toutes les heures entre 6h et 22h, les jours ouvrables"
    # 0 = minute, 6-22 = de 6h à 22h, *, *, 1-5 = lun-ven
    local tache5="0 6-22 * * 1-5 /opt/scripts/monitor.sh"

    echo "Tâche 1 (quotidien 3h)     : $tache1"
    echo "Tâche 2 (toutes les 5min)  : $tache2"
    echo "Tâche 3 (1er du mois 8h30) : $tache3"
    echo "Tâche 4 (lun-ven 9h et 18h): $tache4"
    echo "Tâche 5 (horaire 6h-22h)   : $tache5"
}

# --- Solution 2 ---
ex_2() {
    echo "--- Exercice 2 : Makefile ---"

    cat > /tmp/Makefile_ex2 <<'MAKEFILE'
APP_NAME := mon-app

.PHONY: help build test clean all

.DEFAULT_GOAL := help

help: ## Afficher cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	    | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build: ## Compiler l'application
	@echo "Build de $(APP_NAME)..."
	@mkdir -p dist
	@echo "#!/bin/bash" > dist/$(APP_NAME)
	@echo "echo 'Hello from $(APP_NAME)'" >> dist/$(APP_NAME)
	@chmod +x dist/$(APP_NAME)
	@echo "Build terminé"

test: ## Lancer les tests
	@echo "Tests de $(APP_NAME)..."
	@[[ -f dist/$(APP_NAME) ]] && echo "Binaire présent : OK" || { echo "Binaire absent : KO"; exit 1; }
	@echo "Tests passés"

clean: ## Nettoyer les artefacts
	@echo "Nettoyage..."
	@rm -rf dist/
	@echo "Nettoyé"

all: build test ## Build + test
MAKEFILE

    echo "Makefile créé dans /tmp/Makefile_ex2"

    if command -v make &>/dev/null; then
        echo ""
        echo "=== make help ==="
        make -f /tmp/Makefile_ex2 help

        echo ""
        echo "=== make all ==="
        make -f /tmp/Makefile_ex2 all

        echo ""
        echo "=== make clean ==="
        make -f /tmp/Makefile_ex2 clean
    else
        echo "make n'est pas installé"
    fi
}

# --- Solution 3 ---
ex_3() {
    echo "--- Exercice 3 : fonctions de déploiement ---"

    local ENV="dev"
    local REMOTE_HOST="localhost"
    local SOURCE_DIR="/tmp/deploy_source_$$"
    local DEST_DIR="/tmp/deploy_dest_$$"

    mkdir -p "$SOURCE_DIR" "$DEST_DIR"
    echo "version: 1.0.0" > "$SOURCE_DIR/app.conf"
    echo "#!/bin/bash" > "$SOURCE_DIR/app.sh"
    trap 'rm -rf "$SOURCE_DIR" "$DEST_DIR"' RETURN

    check_deps() {
        local deps=("$@")
        local all_ok=true
        for dep in "${deps[@]}"; do
            if command -v "$dep" &>/dev/null; then
                echo "  [OK] $dep"
            else
                echo "  [KO] $dep"
                all_ok=false
            fi
        done
        $all_ok
    }

    pre_checks() {
        local src="$1"
        [[ -d "$src" ]] || { echo "Source inexistante: $src" >&2; return 1; }
        [[ -n "$(ls -A "$src")" ]] || { echo "Source vide: $src" >&2; return 1; }
        echo "Vérifications pré-déploiement OK"
    }

    deploy_files() {
        local src="$1"
        local dest="$2"
        if command -v rsync &>/dev/null; then
            rsync -a "$src"/ "$dest"/
        else
            cp -r "$src"/. "$dest"/
        fi
        echo "Fichiers déployés vers $dest"
    }

    verify() {
        local dest="$1"
        [[ -n "$(ls -A "$dest")" ]] || { echo "Vérification échouée : dest vide" >&2; return 1; }
        echo "Vérification OK : $(ls "$dest" | wc -l) fichiers déployés"
    }

    echo "ENV: $ENV | HOST: $REMOTE_HOST"
    check_deps rsync cp bash
    pre_checks "$SOURCE_DIR"
    deploy_files "$SOURCE_DIR" "$DEST_DIR"
    verify "$DEST_DIR"
    echo "Déploiement simulé terminé"
}

# --- Solution 4 ---
ex_4() {
    echo "--- Exercice 4 : getopts ---"

    parse_and_show() {
        local ENV="" NOM="default-service" DRY_RUN=0 VERBOSE=0

        while getopts "e:n:dvh" opt; do
            case "$opt" in
                e) ENV="$OPTARG" ;;          # Stocker la valeur de l'option -e
                n) NOM="$OPTARG" ;;          # Stocker le nom du service
                d) DRY_RUN=1 ;;             # Flag booléen
                v) VERBOSE=1 ;;             # Flag booléen
                h) echo "Usage: -e <env> [-n nom] [-d] [-v] [-h]"; return 0 ;;
                *) echo "Option invalide" >&2; return 1 ;;
            esac
        done

        [[ -z "$ENV" ]] && { echo "Erreur : -e env est obligatoire" >&2; return 1; }
        [[ "$ENV" =~ ^(dev|staging|prod)$ ]] || { echo "Erreur : env invalide ($ENV)" >&2; return 1; }

        echo "Résultat du parsing :"
        echo "  ENV      = $ENV"
        echo "  NOM      = $NOM"
        echo "  DRY_RUN  = $DRY_RUN"
        echo "  VERBOSE  = $VERBOSE"
    }

    echo "Test 1 : options complètes"
    parse_and_show -e prod -n mon-service -d -v

    echo ""
    echo "Test 2 : env seulement"
    parse_and_show -e staging

    echo ""
    echo "Test 3 : env manquant (erreur attendue)"
    parse_and_show || echo "Erreur capturée"

    echo ""
    echo "Test 4 : env invalide (erreur attendue)"
    parse_and_show -e recette || echo "Erreur capturée"
}

# --- Solution 5 ---
ex_5() {
    echo "--- Exercice 5 : notification ---"

    notify() {
        local statut="$1"
        local message="$2"
        local env="${3:-unknown}"
        local webhook="${SLACK_WEBHOOK:-}"

        local payload
        payload=$(printf '{"text": "[%s] %s : %s (env: %s, by: %s)"}' \
            "$statut" \
            "$(date '+%H:%M:%S')" \
            "$message" \
            "$env" \
            "$(whoami)")

        if [[ -z "$webhook" ]]; then
            echo "  [NOTIFY] $statut | $message | env=$env"
            return 0
        fi

        if curl -s -X POST "$webhook" \
            -H 'Content-type: application/json' \
            -d "$payload" &>/dev/null; then
            echo "  Notification envoyée"
        else
            echo "  Notification échouée" >&2
            return 1
        fi
    }

    echo "Test 1 : sans webhook (log seulement)"
    SLACK_WEBHOOK="" notify "SUCCÈS" "Déploiement v1.2.3 terminé" "prod"

    echo ""
    echo "Test 2 : statuts différents"
    SLACK_WEBHOOK="" notify "ÉCHEC" "Tests échoués" "staging"
    SLACK_WEBHOOK="" notify "ROLLBACK" "Retour à v1.2.2" "prod"

    echo ""
    echo "Test 3 : webhook simulé"
    SLACK_WEBHOOK="http://httpbin.org/post" notify "INFO" "Test webhook" "dev" 2>/dev/null \
        || echo "  (webhook externe non accessible — comportement normal hors ligne)"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 16 — Automatisation et CI : Solutions"
    echo "============================================="
    echo ""
    ex_1; echo ""
    ex_2; echo ""
    ex_3; echo ""
    ex_4; echo ""
    ex_5; echo ""
    echo "Solutions terminées."
}

main
