#!/bin/bash
# =============================================================================
# Exercices — Chapitre 16 : Automatisation et CI
# =============================================================================
# Complétez chaque fonction en remplaçant les '???' par votre code.
# Testez avec : bash exercices.sh
# =============================================================================

# --- Exercice 1 ---
# Générer des entrées crontab valides.
# Pour chaque tâche décrite, écrire l'expression cron correspondante.
ex_1() {
    echo "--- Exercice 1 : expressions cron ---"

    # Chaque variable doit contenir une expression cron valide (5 champs + commande)
    # Indice : minute heure jour_mois mois jour_semaine commande

    # "Tous les jours à 3h00 du matin"
    local tache1="??? /opt/scripts/backup.sh"

    # "Toutes les 5 minutes"
    local tache2="??? /opt/scripts/check.sh"

    # "Le 1er de chaque mois à 8h30"
    local tache3="??? /opt/scripts/rapport.sh"

    # "Du lundi au vendredi à 9h et 18h"
    local tache4="??? /opt/scripts/sync.sh"

    # "Toutes les heures entre 6h et 22h, les jours ouvrables"
    local tache5="??? /opt/scripts/monitor.sh"

    echo "Tâche 1 (quotidien 3h)     : $tache1"
    echo "Tâche 2 (toutes les 5min)  : $tache2"
    echo "Tâche 3 (1er du mois 8h30) : $tache3"
    echo "Tâche 4 (lun-ven 9h et 18h): $tache4"
    echo "Tâche 5 (horaire 6h-22h)   : $tache5"
}

# --- Exercice 2 ---
# Écrire un Makefile minimal (affiché par la fonction).
# Le Makefile doit avoir :
#   - Une variable APP_NAME
#   - Les targets : help, build, test, clean, all
#   - .PHONY pour toutes les targets
#   - help auto-généré depuis les commentaires ##
# BONUS : écrire le Makefile réel dans /tmp/Makefile_ex2 et l'exécuter
ex_2() {
    echo "--- Exercice 2 : Makefile ---"

    # Créer le Makefile dans /tmp
    cat > /tmp/Makefile_ex2 <<'MAKEFILE'
# Complétez ce Makefile
APP_NAME := mon-app

.PHONY: help build test clean all

# La target par défaut est help
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

    # Exécuter make help (si make est disponible)
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
        echo "make n'est pas installé (apt install make)"
    fi
}

# --- Exercice 3 ---
# Écrire les fonctions d'un script de déploiement simplifié.
# Implémenter : check_deps(), pre_checks(), deploy_files(), verify()
ex_3() {
    echo "--- Exercice 3 : fonctions de déploiement ---"

    # Configuration
    local ENV="dev"
    local REMOTE_HOST="localhost"
    local SOURCE_DIR="/tmp/deploy_source_$$"
    local DEST_DIR="/tmp/deploy_dest_$$"

    # Préparer les répertoires de test
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
        # Vérifier que le répertoire source existe et n'est pas vide
        [[ -d "$src" ]] || { echo "Source inexistante: $src" >&2; return 1; }
        [[ -n "$(ls -A "$src")" ]] || { echo "Source vide: $src" >&2; return 1; }
        echo "Vérifications pré-déploiement OK"
    }

    deploy_files() {
        local src="$1"
        local dest="$2"
        # Copier les fichiers de src vers dest
        # Utiliser cp -r ou rsync si disponible
        if command -v rsync &>/dev/null; then
            rsync -a "$src"/ "$dest"/
        else
            cp -r "$src"/. "$dest"/
        fi
        echo "Fichiers déployés vers $dest"
    }

    verify() {
        local dest="$1"
        # Vérifier que le déploiement a réussi (dest non vide)
        [[ -n "$(ls -A "$dest")" ]] || { echo "Vérification échouée : dest vide" >&2; return 1; }
        echo "Vérification OK : $(ls "$dest" | wc -l) fichiers déployés"
    }

    # Orchestration
    echo "ENV: $ENV | HOST: $REMOTE_HOST"
    check_deps rsync cp bash
    pre_checks "$SOURCE_DIR"
    deploy_files "$SOURCE_DIR" "$DEST_DIR"
    verify "$DEST_DIR"
    echo "Déploiement simulé terminé"
}

# --- Exercice 4 ---
# Écrire un script avec getopts qui parse les options suivantes :
#   -e ENV   : environnement (dev/staging/prod), obligatoire
#   -n NOM   : nom du service
#   -d       : mode dry-run
#   -v       : mode verbeux
#   -h       : aide
# Afficher les valeurs parsées et valider l'environnement.
ex_4() {
    echo "--- Exercice 4 : getopts ---"

    parse_and_show() {
        local ENV="" NOM="default-service" DRY_RUN=0 VERBOSE=0

        while getopts "e:n:dvh" opt; do
            case "$opt" in
                e) ???;;
                n) ???;;
                d) ???;;
                v) ???;;
                h) echo "Usage: $0 -e <env> [-n nom] [-d] [-v] [-h]"; return 0;;
                *) echo "Option invalide" >&2; return 1;;
            esac
        done

        # Validation
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

# --- Exercice 5 ---
# Écrire une fonction notify_slack() qui envoie une notification via webhook.
# Elle doit :
#   - Prendre : statut, message, environnement
#   - Construire un payload JSON (utiliser printf ou heredoc)
#   - Simuler l'envoi (curl vers /dev/null pour l'exercice)
#   - Gérer l'absence de webhook (variable vide → log seulement)
ex_5() {
    echo "--- Exercice 5 : notification ---"

    notify() {
        local statut="$1"
        local message="$2"
        local env="${3:-unknown}"
        local webhook="${SLACK_WEBHOOK:-}"

        # Construire le payload JSON
        local payload
        payload=$(printf '{"text": "[%s] %s : %s (env: %s, by: %s)"}' \
            "$statut" \
            "$(date '+%H:%M:%S')" \
            "$message" \
            "$env" \
            "$(whoami)")

        if [[ -z "$webhook" ]]; then
            # Pas de webhook : juste logger
            echo "  [NOTIFY] $statut | $message | env=$env"
            return 0
        fi

        # Envoyer vers le webhook (simulé ici)
        if curl -s -X POST "$webhook" \
            -H 'Content-type: application/json' \
            -d "$payload" &>/dev/null; then
            echo "  Notification envoyée"
        else
            echo "  Notification échouée" >&2
            return 1
        fi
    }

    # Tests
    echo "Test 1 : sans webhook (log seulement)"
    SLACK_WEBHOOK="" notify "SUCCÈS" "Déploiement v1.2.3 terminé" "prod"

    echo ""
    echo "Test 2 : statuts différents"
    SLACK_WEBHOOK="" notify "ÉCHEC" "Tests échoués" "staging"
    SLACK_WEBHOOK="" notify "ROLLBACK" "Retour à v1.2.2" "prod"

    echo ""
    echo "Test 3 : avec webhook simulé (vers /dev/null)"
    # Simuler un webhook fonctionnel via un endpoint qui accepte tout
    SLACK_WEBHOOK="http://httpbin.org/post" notify "INFO" "Test webhook" "dev" 2>/dev/null \
        || echo "  (webhook externe non accessible en mode hors ligne — comportement normal)"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 16 — Automatisation et CI : Exercices"
    echo "============================================="
    echo ""
    ex_1; echo ""
    ex_2; echo ""
    ex_3; echo ""
    ex_4; echo ""
    ex_5; echo ""
    echo "Exercices terminés."
}

main
