#!/bin/bash
# =============================================================================
# Exercices — Chapitre 13 : Robustesse et gestion d'erreurs
# =============================================================================
# Complétez chaque fonction en remplaçant les '???' par votre code.
# Testez avec : bash exercices.sh
# =============================================================================

# --- Exercice 1 ---
# Écrire une fonction die() qui affiche un message sur stderr et quitte avec le code donné.
# Écrire une fonction log() qui affiche avec timestamp sur stderr.
# Écrire une fonction warn() qui affiche un avertissement sur stderr.
# Puis les utiliser dans un script qui vérifie un répertoire passé en argument.
ex_1() {
    echo "--- Exercice 1 : fonctions die/log/warn ---"

    # Définir les fonctions ici
    die() {
        # Afficher "$*" sur stderr avec préfixe [ERROR] et quitter avec code 1
        ???
    }

    log() {
        # Afficher "[INFO] $*" sur stderr
        ???
    }

    warn() {
        # Afficher "[WARN] $*" sur stderr
        ???
    }

    # Test des fonctions
    log "Démarrage de l'exercice 1"
    warn "Ceci est un avertissement de test"
    echo "Les fonctions sont définies (die n'est pas appelée pour ne pas quitter)"
}

# --- Exercice 2 ---
# Utiliser trap pour garantir le nettoyage d'un fichier temporaire.
# Le script doit :
#   1. Créer un fichier temporaire avec mktemp
#   2. Installer un trap EXIT qui le supprime
#   3. Écrire quelque chose dans le fichier
#   4. Vérifier que le fichier existe, puis sortir normalement
# Le trap doit garantir la suppression même en cas d'erreur.
ex_2() {
    echo "--- Exercice 2 : trap et nettoyage ---"

    local tmpfile
    tmpfile=$(mktemp /tmp/exercice2.XXXXXX)

    # Installer le trap
    trap ??? EXIT

    echo "Données de test" > "$tmpfile"
    echo "Fichier temporaire créé : $tmpfile"
    echo "Contenu : $(cat "$tmpfile")"
    echo "Le trap supprimera $tmpfile à la fin de cette sous-fonction"

    # Désinstaller le trap pour ne pas interférer avec les autres exercices
    trap - EXIT
    rm -f "$tmpfile"
    echo "Nettoyage manuel effectué (trap désactivé pour les exercices suivants)"
}

# --- Exercice 3 ---
# Écrire une fonction check_deps() qui vérifie la présence de commandes
# et affiche quelles commandes sont présentes/absentes.
# Utiliser command -v pour chaque dépendance.
ex_3() {
    echo "--- Exercice 3 : vérification des dépendances ---"

    check_deps() {
        local deps=("$@")
        local missing=()

        for dep in "${deps[@]}"; do
            if ???; then
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

    # Tester avec des commandes existantes et une imaginaire
    check_deps bash grep awk sed commande_inexistante_xyz || true
}

# --- Exercice 4 ---
# Écrire un script qui illustre set -euo pipefail.
# La fonction doit :
#   1. Activer set -euo pipefail dans un sous-shell
#   2. Démontrer que les variables non définies provoquent une erreur
#   3. Démontrer que || true permet d'ignorer une erreur
#   4. Démontrer que set -e arrête le script sur erreur
ex_4() {
    echo "--- Exercice 4 : set -euo pipefail ---"

    # Sous-shell pour isoler les effets de set
    (
        set -euo pipefail

        echo "1. Commande réussie : OK"

        # Ignorer une erreur avec || true
        ls /chemin/inexistant/xyz 2>/dev/null ??? && echo "2. Erreur ignorée avec || true"

        echo "3. Suite normale"

        # Test variable non définie (doit provoquer une erreur)
        # Décommenter pour tester : echo "${variable_non_definie}"

        # Valeur par défaut pour variable non définie
        echo "4. Valeur par défaut : ${MA_VAR:-valeur_par_defaut}"
    )
    echo "Sous-shell terminé"
}

# --- Exercice 5 ---
# Écrire une fonction qui traite un fichier de manière robuste :
#   - Vérifie que l'argument est fourni
#   - Vérifie que le fichier existe et est lisible
#   - Utilise trap pour créer un fichier de résultats temporaire
#   - Compte les lignes, les mots et les caractères (wc)
#   - En cas de succès, affiche les résultats
#   - En cas d'erreur à n'importe quelle étape, affiche un message clair
ex_5() {
    echo "--- Exercice 5 : traitement de fichier robuste ---"

    traiter_fichier_robuste() {
        # Vérifier qu'un argument est fourni
        [[ $# -ge 1 ]] || { echo "Erreur : argument manquant" >&2; return 2; }

        local fichier="$1"
        local tmpresult

        # Vérifications défensives
        ???
        ???

        # Fichier temporaire avec nettoyage garanti
        tmpresult=$(mktemp /tmp/result.XXXXXX)
        trap 'rm -f "$tmpresult"' RETURN

        # Traitement
        wc -lwc "$fichier" > "$tmpresult"
        echo "Statistiques de $fichier :"
        cat "$tmpresult"
    }

    # Test avec un fichier existant
    traiter_fichier_robuste "/etc/hosts"
    echo ""

    # Test avec un fichier inexistant
    traiter_fichier_robuste "/fichier/qui/nexiste/pas" || echo "Erreur attendue : fichier inexistant"
    echo ""

    # Test sans argument
    traiter_fichier_robuste || echo "Erreur attendue : argument manquant"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 13 — Robustesse : Exercices"
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
