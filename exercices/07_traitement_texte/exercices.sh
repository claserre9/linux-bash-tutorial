#!/usr/bin/env bash
# Exercices — Chapitre 7 : Traitement de texte — sed, awk, cut, sort, uniq, tr, wc

# Ce script crée des données de test, puis vous demande de compléter les commandes
# indiquées par # TODO pour produire le résultat attendu.

DONNEES_DIR="/tmp/exo07"
mkdir -p "$DONNEES_DIR"

# Génération des données de test
setup_data() {
    # Fichier CSV d'employés
    cat > "$DONNEES_DIR/employes.csv" << 'EOF'
Alice,Martin,Ingénieure,75000,Paris
Bob,Dupont,Manager,85000,Lyon
Charlie,Bernard,Développeur,68000,Paris
Diana,Petit,Designer,62000,Bordeaux
Eve,Robert,Ingénieure,78000,Paris
Frank,Moreau,Manager,90000,Lyon
Grace,Simon,Développeuse,71000,Marseille
Henry,Laurent,Designer,60000,Paris
EOF

    # Fichier de log simplifié
    cat > "$DONNEES_DIR/access.log" << 'EOF'
192.168.1.10 GET /index.html 200
192.168.1.20 POST /api/login 200
192.168.1.10 GET /api/users 403
10.0.0.1 GET /admin 404
192.168.1.10 GET /index.html 200
192.168.1.30 GET /static/app.js 200
10.0.0.1 GET /wp-login.php 404
10.0.0.1 POST /xmlrpc.php 404
192.168.1.20 GET /dashboard 200
192.168.1.10 DELETE /api/users/5 403
EOF

    # Fichier de nombres
    cat > "$DONNEES_DIR/nombres.txt" << 'EOF'
42
7
100
3
55
7
88
3
42
17
100
5
EOF

    # Fichier texte avec doublons et casse mixte
    cat > "$DONNEES_DIR/mots.txt" << 'EOF'
Bonjour
monde
BONJOUR
linux
Bash
monde
Linux
BASH
bonjour
EOF
}

main() {
    setup_data
    echo "Données de test créées dans $DONNEES_DIR"
    echo "=================================================="
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Exercice 7.1 — cut et sort ==="
    echo "Objectif : Extraire les prénoms et salaires du CSV, puis trier par salaire décroissant"
    echo "Résultat attendu : liste 'Prénom Salaire' du plus riche au moins riche"
    echo ""

    # TODO : Compléter la commande
    # Indice : utiliser cut pour extraire colonnes 1 et 4 (délimiteur ,)
    #          puis trier numériquement sur la 2e colonne (-k2 -t, -rn)
    echo "--- Votre résultat (complétez le TODO) ---"
    # TODO : cut ... | sort ...
    echo "(remplacer cette ligne par la commande)"

    echo ""
    echo "--- Résultat de référence ---"
    cut -d, -f1,4 "$DONNEES_DIR/employes.csv" | sort -t, -k2 -rn
}

ex_2() {
    echo ""
    echo "=== Exercice 7.2 — sort et uniq ==="
    echo "Objectif : Trouver les IPs qui apparaissent plus d'une fois dans access.log"
    echo "Résultat attendu : IP avec leur nombre d'occurrences, triées du plus fréquent"
    echo ""

    echo "--- Votre résultat (complétez le TODO) ---"
    # TODO : extraire le 1er champ de access.log, trier, compter, filtrer doublons, trier
    echo "(remplacer cette ligne par la commande)"

    echo ""
    echo "--- Résultat de référence ---"
    awk '{print $1}' "$DONNEES_DIR/access.log" | sort | uniq -c | sort -rn | awk '$1 > 1'
}

ex_3() {
    echo ""
    echo "=== Exercice 7.3 — tr et wc ==="
    echo "Objectif 1 : Convertir le fichier mots.txt entier en minuscules"
    echo "Objectif 2 : Compter le nombre de mots uniques (insensible à la casse)"
    echo ""

    echo "--- Votre résultat (complétez les TODOs) ---"
    # TODO 1 : Convertir en minuscules avec tr
    echo "Minuscules : (remplacer cette ligne)"

    # TODO 2 : Compter les mots uniques après normalisation en minuscules
    echo "Mots uniques : (remplacer cette ligne)"

    echo ""
    echo "--- Résultat de référence ---"
    echo "Minuscules :"
    tr 'A-Z' 'a-z' < "$DONNEES_DIR/mots.txt"
    echo "Mots uniques : $(tr 'A-Z' 'a-z' < "$DONNEES_DIR/mots.txt" | sort -u | wc -l)"
}

ex_4() {
    echo ""
    echo "=== Exercice 7.4 — sed ==="
    echo "Objectif : Dans employes.csv :"
    echo "  1. Remplacer 'Paris' par 'PARIS' (toutes occurrences)"
    echo "  2. Supprimer les lignes concernant les Managers"
    echo "  3. Afficher le résultat (sans modifier le fichier)"
    echo ""

    echo "--- Votre résultat (complétez le TODO) ---"
    # TODO : utiliser sed avec plusieurs -e
    echo "(remplacer cette ligne par la commande)"

    echo ""
    echo "--- Résultat de référence ---"
    sed -e 's/Paris/PARIS/g' -e '/Manager/d' "$DONNEES_DIR/employes.csv"
}

ex_5() {
    echo ""
    echo "=== Exercice 7.5 — awk ==="
    echo "Objectif : Analyser employes.csv avec awk pour afficher :"
    echo "  - Le salaire moyen par ville"
    echo "  Format : 'Ville: XXX (N employés)'"
    echo ""

    echo "--- Votre résultat (complétez le TODO) ---"
    # TODO : utiliser awk avec un tableau associatif
    # Indice : FS=",", accumuler les salaires par ville ($5), compter, afficher en END
    echo "(remplacer cette ligne par la commande)"

    echo ""
    echo "--- Résultat de référence ---"
    awk -F, '{
        total[$5] += $4
        count[$5]++
    }
    END {
        for (ville in total)
            printf "%s: %.0f € moy (%d employés)\n", ville, total[ville]/count[ville], count[ville]
    }' "$DONNEES_DIR/employes.csv" | sort
}

main
