#!/bin/bash
# =============================================================================
# Solutions — Chapitre 13 : Robustesse et gestion d'erreurs
# =============================================================================

# --- Solution 1 ---
ex_1() {
    echo "--- Exercice 1 : fonctions die/log/warn ---"

    die() {
        echo "[ERROR] $*" >&2
        exit 1
    }

    log() {
        echo "[INFO]  $(date '+%H:%M:%S') $*" >&2
    }

    warn() {
        echo "[WARN]  $(date '+%H:%M:%S') $*" >&2
    }

    log "Démarrage de l'exercice 1"
    warn "Ceci est un avertissement de test"
    echo "Les fonctions sont définies (die n'est pas appelée pour ne pas quitter)"
    # Vérification : les messages log/warn apparaissent sur stderr
}

# --- Solution 2 ---
ex_2() {
    echo "--- Exercice 2 : trap et nettoyage ---"

    local tmpfile
    tmpfile=$(mktemp /tmp/exercice2.XXXXXX)

    # Le trap supprime le fichier temporaire à la sortie
    trap 'rm -f "$tmpfile"' EXIT

    echo "Données de test" > "$tmpfile"
    echo "Fichier temporaire créé : $tmpfile"
    echo "Contenu : $(cat "$tmpfile")"
    echo "Le trap supprimera $tmpfile à la fin de cette sous-fonction"

    # Désinstaller le trap pour ne pas interférer avec les autres exercices
    trap - EXIT
    rm -f "$tmpfile"
    echo "Nettoyage manuel effectué (trap désactivé pour les exercices suivants)"
}

# --- Solution 3 ---
ex_3() {
    echo "--- Exercice 3 : vérification des dépendances ---"

    check_deps() {
        local deps=("$@")
        local missing=()

        for dep in "${deps[@]}"; do
            # command -v retourne 0 si la commande existe, non-zéro sinon
            if command -v "$dep" &>/dev/null; then
                echo "  [OK]  $dep"
            else
                echo "  [KO]  $dep (absent)"
                missing+=("$dep")
            fi
        done

        if [[ ${#missing[@]} -gt 0 ]]; then
            echo "Dépendances manquantes : ${missing[*]}"
            return 1
        else
            echo "Toutes les dépendances sont présentes"
            return 0
        fi
    }

    check_deps bash grep awk sed commande_inexistante_xyz || true
    # bash  : [OK]
    # grep  : [OK]
    # awk   : [OK]
    # sed   : [OK]
    # commande_inexistante_xyz : [KO]
}

# --- Solution 4 ---
ex_4() {
    echo "--- Exercice 4 : set -euo pipefail ---"

    (
        set -euo pipefail

        echo "1. Commande réussie : OK"

        # || true permet d'ignorer l'erreur sans quitter le script
        ls /chemin/inexistant/xyz 2>/dev/null || true && echo "2. Erreur ignorée avec || true"

        echo "3. Suite normale"

        # Valeur par défaut pour variable non définie
        # ${VAR:-defaut} : si VAR est vide/non définie, utiliser defaut
        echo "4. Valeur par défaut : ${MA_VAR:-valeur_par_defaut}"

        # Démonstration variable non définie avec valeur par défaut
        MA_VAR=""
        echo "5. VAR vide avec défaut : ${MA_VAR:-fallback}"

        # set -u empêche l'utilisation de variable non déclarée sans défaut :
        # echo "$var_inexistante"  # ← provoquerait : unbound variable
    )
    echo "Sous-shell terminé"
}

# --- Solution 5 ---
ex_5() {
    echo "--- Exercice 5 : traitement de fichier robuste ---"

    traiter_fichier_robuste() {
        [[ $# -ge 1 ]] || { echo "Erreur : argument manquant" >&2; return 2; }

        local fichier="$1"
        local tmpresult

        # Vérifications défensives
        [[ -f "$fichier" ]] || { echo "Erreur : fichier introuvable : $fichier" >&2; return 2; }
        [[ -r "$fichier" ]] || { echo "Erreur : fichier non lisible : $fichier" >&2; return 126; }

        # Fichier temporaire avec nettoyage garanti à la fin de la fonction
        tmpresult=$(mktemp /tmp/result.XXXXXX)
        trap 'rm -f "$tmpresult"' RETURN

        # Traitement
        wc -lwc "$fichier" > "$tmpresult"
        echo "Statistiques de $fichier :"
        cat "$tmpresult"
    }

    traiter_fichier_robuste "/etc/hosts"
    echo ""

    traiter_fichier_robuste "/fichier/qui/nexiste/pas" || echo "Erreur attendue : fichier inexistant"
    echo ""

    traiter_fichier_robuste || echo "Erreur attendue : argument manquant"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 13 — Robustesse : Solutions"
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
