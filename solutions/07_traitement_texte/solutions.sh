#!/usr/bin/env bash
# Solutions — Chapitre 7 : Traitement de texte — sed, awk, cut, sort, uniq, tr, wc

DONNEES_DIR="/tmp/exo07"
mkdir -p "$DONNEES_DIR"

setup_data() {
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
    echo "=== Solution 7.1 — cut et sort ==="
    echo "Prénoms et salaires triés par salaire décroissant :"
    echo ""

    # cut extrait les colonnes 1 (prénom) et 4 (salaire)
    # sort trie numériquement (-n) sur la 2e colonne (-k2) avec le délimiteur virgule (-t,)
    # en ordre décroissant (-r)
    cut -d, -f1,4 "$DONNEES_DIR/employes.csv" | sort -t, -k2 -rn

    echo ""
    echo "Explications :"
    echo "  cut -d, -f1,4  : extraire colonnes 1 (prénom) et 4 (salaire), délimiteur virgule"
    echo "  sort -t, -k2 -rn : trier sur la 2e colonne (-k2), numériquement (-n), décroissant (-r)"
}

ex_2() {
    echo ""
    echo "=== Solution 7.2 — sort et uniq ==="
    echo "IPs apparaissant plus d'une fois :"
    echo ""

    # awk extrait le 1er champ (IP)
    # sort trie les IPs (obligatoire pour uniq)
    # uniq -c compte les occurrences consécutives
    # sort -rn trie par fréquence décroissante
    # awk '$1 > 1' filtre pour ne garder que les doublons
    awk '{print $1}' "$DONNEES_DIR/access.log" \
        | sort \
        | uniq -c \
        | sort -rn \
        | awk '$1 > 1 {printf "%-6d %s\n", $1, $2}'

    echo ""
    echo "Explications :"
    echo "  awk '{print \$1}'   : extraire le 1er champ (IP)"
    echo "  sort               : trier (obligatoire avant uniq !)"
    echo "  uniq -c            : compter les occurrences consécutives"
    echo "  sort -rn           : trier par fréquence décroissante"
    echo "  awk '\$1 > 1'       : ne garder que les IPs > 1 occurrence"
}

ex_3() {
    echo ""
    echo "=== Solution 7.3 — tr et wc ==="

    echo "1) Contenu en minuscules :"
    # tr traduit les majuscules en minuscules
    tr 'A-Z' 'a-z' < "$DONNEES_DIR/mots.txt"

    echo ""
    echo "2) Nombre de mots uniques (insensible à la casse) :"
    # Pipeline : normaliser en minuscules → trier → dédoublonner → compter
    nb=$(tr 'A-Z' 'a-z' < "$DONNEES_DIR/mots.txt" | sort -u | wc -l)
    echo "  $nb mots uniques"

    echo ""
    echo "Explications :"
    echo "  tr 'A-Z' 'a-z'  : convertir majuscules en minuscules"
    echo "  sort -u          : trier ET dédoublonner"
    echo "  wc -l            : compter les lignes"
}

ex_4() {
    echo ""
    echo "=== Solution 7.4 — sed ==="
    echo "Employés non-managers avec Paris en majuscules :"
    echo ""

    # sed -e permet d'enchaîner plusieurs commandes
    # 's/Paris/PARIS/g' : remplacer toutes les occurrences de Paris
    # '/Manager/d'      : supprimer les lignes contenant Manager
    sed -e 's/Paris/PARIS/g' -e '/Manager/d' "$DONNEES_DIR/employes.csv"

    echo ""
    echo "Explications :"
    echo "  -e 's/Paris/PARIS/g' : remplacer Paris → PARIS (g = toutes occurrences)"
    echo "  -e '/Manager/d'      : supprimer les lignes contenant Manager"
    echo ""
    echo "Alternative avec un point-virgule :"
    echo "  sed 's/Paris/PARIS/g; /Manager/d' fichier.csv"
}

ex_5() {
    echo ""
    echo "=== Solution 7.5 — awk ==="
    echo "Salaire moyen par ville :"
    echo ""

    # awk avec tableaux associatifs pour accumuler les données par ville
    awk -F, '
    {
        # $5 = ville, $4 = salaire
        total[$5] += $4
        count[$5]++
    }
    END {
        for (ville in total) {
            printf "%-12s : %7.0f € moy (%d employé(s))\n",
                   ville,
                   total[ville] / count[ville],
                   count[ville]
        }
    }' "$DONNEES_DIR/employes.csv" | sort

    echo ""
    echo "Explications :"
    echo "  -F,                  : séparateur de champs = virgule"
    echo "  total[\$5] += \$4     : accumuler les salaires par ville"
    echo "  count[\$5]++         : compter les employés par ville"
    echo "  END { for (ville in total) } : itérer sur le tableau en fin de fichier"
    echo "  printf \"%7.0f\"       : formatage : 7 caractères, 0 décimales"
}

main
