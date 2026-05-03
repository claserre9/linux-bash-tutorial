#!/usr/bin/env bash
# Solutions — Chapitre 9 : Bash — Fonctions et scripts modulaires

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Solution 9.1 — Fonctions et portée des variables ==="

    i=100    # Variable globale importante

    boucle_corrigee() {
        local i    # Déclarer i comme locale AVANT de l'utiliser
        for i in 1 2 3; do
            echo "  Dans la boucle : i=$i"
        done
    }

    echo "Avant la fonction : i=$i"
    boucle_corrigee
    echo "Après la fonction : i=$i (protégée par local)"

    echo ""

    # max() retourne le maximum via echo (pas return qui est limité à 0-255)
    max() {
        local a="$1"
        local b="$2"
        if (( a >= b )); then
            echo "$a"
        else
            echo "$b"
        fi
    }

    resultat=$(max 15 42)
    echo "max(15, 42) = $resultat  (attendu: 42)"

    resultat=$(max 99 7)
    echo "max(99, 7) = $resultat   (attendu: 99)"

    echo ""
    echo "Points clés :"
    echo "  - 'local i' protège la variable globale du même nom"
    echo "  - Les fonctions Bash ne peuvent return que des codes 0-255"
    echo "  - Pour retourner une valeur, utilisez echo + substitution \$()"
    echo "  - local doit être déclaré AVANT l'utilisation de la variable"
}

ex_2() {
    echo ""
    echo "=== Solution 9.2 — getopts ==="

    parser_options() {
        local nom=""
        local count=1
        local upper=false
        local OPTIND=1    # Réinitialiser OPTIND pour les appels répétés

        while getopts "n:c:uh" opt; do
            case "$opt" in
                n)
                    nom="$OPTARG"
                    ;;
                c)
                    # Validation : doit être un nombre positif
                    if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                        echo "Erreur : -c requiert un nombre positif" >&2
                        return 1
                    fi
                    count="$OPTARG"
                    ;;
                u)
                    upper=true
                    ;;
                h)
                    echo "Usage: parser_options -n <nom> [-c <N>] [-u]"
                    return 0
                    ;;
                \?)
                    echo "Option invalide : -$OPTARG" >&2
                    return 1
                    ;;
                :)
                    echo "L'option -$OPTARG requiert un argument" >&2
                    return 1
                    ;;
            esac
        done

        if [[ -z "$nom" ]]; then
            echo "Erreur : -n <nom> est obligatoire"
            return 1
        fi

        local message="Bonjour, $nom !"
        $upper && message="${message^^}"

        for (( i=0; i<count; i++ )); do
            echo "$message"
        done
    }

    echo "Test : parser_options -n Alice"
    parser_options -n Alice

    echo ""
    echo "Test : parser_options -n Bob -c 3"
    parser_options -n Bob -c 3

    echo ""
    echo "Test : parser_options -n Charlie -u -c 2"
    parser_options -n Charlie -u -c 2

    echo ""
    echo "Test : parser_options (sans -n)"
    parser_options || true

    echo ""
    echo "Points clés :"
    echo "  - getopts 'n:c:uh' : n et c attendent un argument (: après)"
    echo "  - OPTARG contient la valeur de l'option avec argument"
    echo "  - \\? capture les options inconnues"
    echo "  - :  capture les options sans argument obligatoire"
    echo "  - OPTIND doit être réinitialisé pour appels répétés dans une fonction"
    echo "  - shift \$((OPTIND - 1)) après la boucle pour les args restants"
}

ex_3() {
    echo ""
    echo "=== Solution 9.3 — Here-documents ==="

    generer_config() {
        local nom="$1"
        local fichier="/tmp/app_config_$$.ini"
        local nom_lower
        nom_lower=$(echo "$nom" | tr 'A-Z' 'a-z')

        # Here-doc avec expansion de variables (pas de quotes autour de EOF)
        cat > "$fichier" << EOF
[general]
app_name=$nom
version=1.0.0
date=$(date '+%Y-%m-%d')

[database]
host=localhost
port=5432
name=${nom_lower}_db
EOF

        echo "Fichier généré : $fichier"
        echo "Contenu :"
        cat "$fichier"

        # Nettoyage
        rm -f "$fichier"
    }

    generer_config "MonApp"

    echo ""
    echo "Points clés :"
    echo "  - << EOF (sans guillemets) : les variables SONT développées"
    echo "  - << 'EOF' (avec guillemets) : les variables NE sont PAS développées"
    echo "  - cat > fichier << EOF : redirige le here-doc vers le fichier"
    echo "  - \$\$ dans le nom de fichier : PID pour unicité"
    echo "  - Indenter avec <<- EOF supprime les tabulations de début"
}

ex_4() {
    echo ""
    echo "=== Solution 9.4 — Gestion d'erreurs avec trap ==="

    traitement_avec_cleanup() {
        local mode="${1:-normal}"
        local tmpfile

        # Créer le fichier temporaire
        tmpfile=$(mktemp /tmp/traitement_XXXXXX)

        # Enregistrer le trap : s'exécute à la sortie de la FONCTION (sous-shell)
        # Note : dans une fonction, trap s'applique au shell courant
        # On utilise un sous-shell ( ) pour isoler le trap
        (
            trap "echo 'Nettoyage : suppression de $tmpfile'; rm -f '$tmpfile'" EXIT

            echo "données importantes" > "$tmpfile"
            echo "Fichier temporaire créé : $tmpfile"
            echo "Contenu : $(cat "$tmpfile")"

            if [[ "$mode" == "erreur" ]]; then
                echo "Simulation d'une erreur..."
                # Forcer une erreur
                false    # Retourne 1
            fi

            echo "Traitement réussi !"
        )

        local code=$?
        if [[ ! -f "$tmpfile" ]]; then
            echo "Fichier temporaire bien supprimé"
        fi
        return $code
    }

    echo "Mode normal :"
    traitement_avec_cleanup "normal"

    echo ""
    echo "Mode avec erreur :"
    traitement_avec_cleanup "erreur" || true

    echo ""
    echo "Points clés :"
    echo "  - mktemp crée un fichier temporaire avec nom unique"
    echo "  - trap 'commande' EXIT : exécuté à chaque sortie du shell"
    echo "  - Le sous-shell ( ) isole le trap pour ne pas affecter le shell parent"
    echo "  - Le trap EXIT s'exécute même en cas d'erreur"
    echo "  - Utiliser trap dans le script principal pour un nettoyage global"
}

ex_5() {
    echo ""
    echo "=== Solution 9.5 — Script complet avec printf et validation ==="

    declare -a employes=(
        "Alice Martin:Ingénieure:75000"
        "Bob Dupont:Manager:85000"
        "Charlie Bernard:Développeur:68000"
    )

    generer_tableau() {
        local separateur_haut="┌─────────────────────┬─────────────┬──────────┐"
        local separateur_mid=" ├─────────────────────┼─────────────┼──────────┤"
        local separateur_bas="└─────────────────────┴─────────────┴──────────┘"

        echo "$separateur_haut"
        printf "│ %-20s│ %-12s│ %-9s│\n" "Nom" "Poste" "Salaire"
        echo "$separateur_mid"

        for entree in "${employes[@]}"; do
            # Extraire les 3 champs avec IFS et read -r
            IFS=: read -r nom poste salaire <<< "$entree"
            printf "│ %-20s│ %-12s│ %6d € │\n" "$nom" "$poste" "$salaire"
        done

        echo "$separateur_bas"

        # Calculer le salaire moyen
        local total=0
        local nb=${#employes[@]}
        for entree in "${employes[@]}"; do
            local sal
            sal=$(echo "$entree" | cut -d: -f3)
            (( total += sal ))
        done
        echo ""
        printf "  Salaire moyen : %d €\n" "$(( total / nb ))"
        printf "  Nombre d'employés : %d\n" "$nb"
    }

    generer_tableau

    echo ""
    echo "Points clés :"
    echo "  - printf '%-20s' : alignement gauche sur 20 chars"
    echo "  - printf '%6d'   : alignement droite sur 6 chars (entier)"
    echo "  - IFS=: read -r nom poste sal <<< \"\$entree\" : split sur :"
    echo "  - Les tableaux Bash : declare -a, \${tableau[@]}, \${#tableau[@]}"
    echo "  - (( total += sal )) : arithmétique sur entiers"
}

main
