#!/usr/bin/env bash
# Exercices — Chapitre 9 : Bash — Fonctions et scripts modulaires

# Ces exercices portent sur les fonctions, getopts, here-docs et
# les bonnes pratiques de structuration de scripts.

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Exercice 9.1 — Fonctions et portée des variables ==="
    echo "Objectif : Comprendre local vs global"
    echo ""

    # TODO : Expliquer et corriger ce script problématique
    # Problème : la boucle for utilise une variable 'i' sans local
    # qui écrase la variable 'i' du contexte appelant.

    i=100    # Variable globale importante

    boucle_defectueuse() {
        # TODO : ajouter 'local i' ici pour éviter l'écrasement
        for i in 1 2 3; do
            echo "  Dans la boucle : i=$i"
        done
    }

    echo "Avant la fonction : i=$i"
    boucle_defectueuse
    echo "Après la fonction : i=$i"
    echo "Résultat attendu après : i=100 (local doit protéger la variable)"

    echo ""
    # TODO : Écrire une fonction max() qui retourne le maximum de deux nombres
    # en utilisant echo (pas return, qui ne peut retourner que 0-255)
    max() {
        # TODO
        echo "(TODO : retourner le max de \$1 et \$2)"
    }

    resultat=$(max 15 42)
    echo "max(15, 42) = $resultat  (attendu: 42)"

    resultat=$(max 99 7)
    echo "max(99, 7) = $resultat   (attendu: 99)"
}

ex_2() {
    echo ""
    echo "=== Exercice 9.2 — getopts ==="
    echo "Objectif : Parser les options d'un script avec getopts"
    echo ""

    # TODO : Compléter la fonction parser_options() qui doit supporter :
    # -n <nom>    : définir le nom (obligatoire)
    # -c <nombre> : nombre de répétitions (défaut: 1)
    # -u          : mettre en majuscules
    # -h          : afficher l'aide

    parser_options() {
        local nom=""
        local count=1
        local upper=false

        # TODO : compléter le while getopts
        # while getopts "..." opt; do
        #     case "$opt" in ...

        # Vérification : nom obligatoire
        if [[ -z "$nom" ]]; then
            echo "Erreur : -n <nom> est obligatoire"
            return 1
        fi

        # Afficher selon les options
        local message="Bonjour, $nom !"
        $upper && message="${message^^}"    # ^^ = majuscules en Bash 4+

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
    parser_options

    echo ""
    echo "--- Résultats attendus ---"
    echo "Test 1 : Bonjour, Alice !"
    echo "Test 2 : Bonjour, Bob ! (×3)"
    echo "Test 3 : BONJOUR, CHARLIE ! (×2)"
    echo "Test 4 : Erreur : -n <nom> est obligatoire"
}

ex_3() {
    echo ""
    echo "=== Exercice 9.3 — Here-documents ==="
    echo "Objectif : Générer des fichiers de configuration avec here-docs"
    echo ""

    # TODO : Écrire une fonction generer_config() qui crée un fichier
    # /tmp/app_config_$$.ini avec le contenu suivant (variables développées) :
    # [general]
    # app_name=<nom passé en arg>
    # version=1.0.0
    # date=<date du jour au format YYYY-MM-DD>
    #
    # [database]
    # host=localhost
    # port=5432
    # name=<nom passé en arg en minuscules>_db

    generer_config() {
        local nom="$1"
        local fichier="/tmp/app_config_$$.ini"

        # TODO : utiliser un here-doc pour créer le fichier
        # cat > "$fichier" << EOF
        #   ... contenu ...
        # EOF

        echo "Fichier généré : $fichier"
        echo "Contenu :"
        cat "$fichier" 2>/dev/null || echo "(fichier non créé — à implémenter)"
    }

    generer_config "MonApp"

    echo ""
    echo "--- Résultat attendu ---"
    local nom="MonApp"
    cat << EOF
[general]
app_name=$nom
version=1.0.0
date=$(date '+%Y-%m-%d')

[database]
host=localhost
port=5432
name=$(echo "${nom,,}")_db
EOF
}

ex_4() {
    echo ""
    echo "=== Exercice 9.4 — Gestion d'erreurs avec trap ==="
    echo "Objectif : Implémenter un nettoyage automatique avec trap"
    echo ""

    # TODO : Compléter la fonction traitement_avec_cleanup() qui :
    # 1. Crée un fichier temporaire avec mktemp
    # 2. Enregistre un trap pour le supprimer à la sortie (EXIT)
    # 3. Écrit "données" dans le fichier temporaire
    # 4. Simule une erreur (commande inconnue) si l'argument est "erreur"
    # 5. Affiche "Traitement réussi" en cas de succès
    # Le fichier temporaire DOIT être supprimé dans les deux cas

    traitement_avec_cleanup() {
        local mode="${1:-normal}"
        local tmpfile

        # TODO 1 : Créer le fichier temporaire
        # tmpfile=$(mktemp)

        # TODO 2 : Enregistrer le trap
        # trap "rm -f \"\$tmpfile\"; echo 'Nettoyage effectué'" EXIT

        # TODO 3 : Écrire dans le fichier
        # echo "données importantes" > "$tmpfile"
        # echo "Fichier temporaire : $tmpfile"

        if [[ "$mode" == "erreur" ]]; then
            # TODO 4 : Simuler une erreur
            echo "(TODO : simuler une erreur)"
        fi

        # TODO 5 : Succès
        echo "Traitement réussi (implémentez le TODO)"
    }

    echo "Mode normal :"
    traitement_avec_cleanup "normal" || true

    echo ""
    echo "Mode avec erreur :"
    traitement_avec_cleanup "erreur" || true

    echo ""
    echo "--- Comportements attendus ---"
    echo "Mode normal  : crée tmpfile, écrit dedans, affiche succès, supprime tmpfile"
    echo "Mode erreur  : crée tmpfile, déclenche erreur, trap supprime quand même tmpfile"
}

ex_5() {
    echo ""
    echo "=== Exercice 9.5 — Script complet avec printf et validation ==="
    echo "Objectif : Créer un générateur de rapport formaté"
    echo ""

    # TODO : Compléter la fonction generer_tableau() qui affiche un tableau
    # formaté des données d'employés.
    # Format attendu :
    # ┌─────────────────────┬────────────┬──────────┐
    # │ Nom                 │ Poste      │ Salaire  │
    # ├─────────────────────┼────────────┼──────────┤
    # │ Alice Martin        │ Ingénieure │ 75000 €  │
    # │ ...                 │ ...        │ ...      │
    # └─────────────────────┴────────────┴──────────┘

    # Données (tableau de tableaux simulé avec strings)
    declare -a employes=(
        "Alice Martin:Ingénieure:75000"
        "Bob Dupont:Manager:85000"
        "Charlie Bernard:Développeur:68000"
    )

    generer_tableau() {
        # TODO : afficher le tableau avec printf
        # Indice : printf "│ %-20s │ %-10s │ %8s │\n" "$nom" "$poste" "$salaire €"

        echo "┌─────────────────────┬────────────┬──────────┐"
        echo "│ Nom                 │ Poste      │ Salaire  │"
        echo "├─────────────────────┼────────────┼──────────┤"

        for entree in "${employes[@]}"; do
            # TODO : extraire les 3 champs avec IFS ou cut
            # IFS=: read -r nom poste salaire <<< "$entree"
            echo "│ (TODO)              │ (TODO)     │ (TODO)   │"
        done

        echo "└─────────────────────┴────────────┴──────────┘"
    }

    generer_tableau

    echo ""
    echo "--- Résultat attendu ---"
    echo "┌─────────────────────┬────────────┬──────────┐"
    echo "│ Nom                 │ Poste      │ Salaire  │"
    echo "├─────────────────────┼────────────┼──────────┤"
    printf "│ %-20s│ %-11s│ %6d € │\n" "Alice Martin" "Ingénieure" 75000
    printf "│ %-20s│ %-11s│ %6d € │\n" "Bob Dupont" "Manager" 85000
    printf "│ %-20s│ %-11s│ %6d € │\n" "Charlie Bernard" "Développeur" 68000
    echo "└─────────────────────┴────────────┴──────────┘"
}

main
