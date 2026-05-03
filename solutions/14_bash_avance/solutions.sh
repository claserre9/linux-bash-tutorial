#!/bin/bash
# =============================================================================
# Solutions — Chapitre 14 : Bash avancé
# =============================================================================

# --- Solution 1 ---
ex_1() {
    echo "--- Exercice 1 : tableaux indexés ---"

    local langages=("Bash" "Python" "Rust" "Go" "Java")

    echo "Premier : ${langages[0]}"   # Bash
    echo "Dernier : ${langages[-1]}"  # Java (index -1 = dernier, Bash 4.3+)

    echo "Nombre : ${#langages[@]}"   # 5

    langages+=("C" "TypeScript")     # Ajouter 2 langages
    echo "Après ajout (${#langages[@]} éléments) : ${langages[@]}"

    # Slice : 3 éléments à partir de l'index 1
    echo "Slice [1:3] : ${langages[@]:1:3}"   # Python Rust Go
}

# --- Solution 2 ---
ex_2() {
    echo "--- Exercice 2 : tableaux associatifs ---"

    declare -A capitales
    capitales["France"]="Paris"
    capitales["Allemagne"]="Berlin"
    capitales["Japon"]="Tokyo"
    capitales["Italie"]="Rome"

    capitales["Espagne"]="Madrid"

    # Afficher triées par clé
    for pays in $(echo "${!capitales[@]}" | tr ' ' '\n' | sort); do
        echo "  $pays → ${capitales[$pays]}"
    done

    # Tester si une clé existe avec -v
    if [[ -v capitales["France"] ]]; then
        echo "France est dans le tableau"
    fi

    echo "Nombre de capitales : ${#capitales[@]}"   # 5
}

# --- Solution 3 ---
ex_3() {
    echo "--- Exercice 3 : here-doc et here-string ---"

    # 1. Guillemets sur 'EOF' → variables non expansées (affichage littéral de $DB_HOST etc.)
    echo "Contenu du fichier de config :"
    cat <<'EOF'
[database]
host = ${DB_HOST}
port = ${DB_PORT}
user = ${DB_USER}
EOF

    # 2. Here-string
    local phrase="le Bash est un langage de script puissant"
    local nb_mots
    nb_mots=$(wc -w <<< "$phrase")
    echo "Mots dans la phrase : $nb_mots"   # 9

    # 3. Substitution de processus
    local liste1="pomme banane cerise"
    local liste2="banane datte fraise cerise"
    echo "Différences entre les deux listes :"
    diff <(echo "$liste1" | tr ' ' '\n' | sort) <(echo "$liste2" | tr ' ' '\n' | sort)
    # < pomme     (seulement dans liste1)
    # > datte     (seulement dans liste2)
    # > fraise    (seulement dans liste2)
}

# --- Solution 4 ---
ex_4() {
    echo "--- Exercice 4 : mapfile et declare ---"

    # 1. mapfile lit chaque ligne dans un élément du tableau
    # -t supprime le \n final de chaque ligne
    mapfile -t shells < /etc/shells 2>/dev/null || shells=("/bin/bash" "/bin/sh")
    echo "Nombre de shells : ${#shells[@]}"

    echo "3 premiers shells :"
    for shell in "${shells[@]:0:3}"; do
        echo "  $shell"
    done

    # 3. declare -i : opérations arithmétiques directes sans $(( ))
    declare -i compteur=0
    compteur=compteur+10   # Bash interprète comme arithmétique
    compteur+=5
    echo "Compteur : $compteur"   # 15

    # 4. declare -r : variable en lecture seule
    declare -r MAX_RETRIES=3
    echo "Max retries : $MAX_RETRIES"

    # 5. printf pour alignement
    printf "%-20s %8s %10s\n" "Produit" "Quantité" "Prix HT"
    printf "%-20s %8d %10.2f\n" "Clavier mécanique" 5 89.90
    printf "%-20s %8d %10.2f\n" "Souris ergonomique" 3 45.00
    printf "%-20s %8d %10.2f\n" "Écran 27 pouces" 2 349.00
}

# --- Solution 5 ---
ex_5() {
    echo "--- Exercice 5 : IFS et parsing ---"

    # 1. IFS=, pour parser un CSV
    local ligne_csv="Alice,30,Paris,ingénieure"
    local nom age ville metier
    IFS=, read -r nom age ville metier <<< "$ligne_csv"
    echo "Nom: $nom | Âge: $age | Ville: $ville | Métier: $metier"

    # 2. IFS=: pour lire PATH
    local -a chemins
    IFS=: read -ra chemins <<< "$PATH"
    echo "Nombre de répertoires dans PATH : ${#chemins[@]}"
    echo "Premier répertoire : ${chemins[0]}"

    # 3. Jointure avec IFS
    local -a fruits=("pomme" "banane" "cerise" "datte")
    local ancien_ifs="$IFS"
    IFS=:
    local joint="${fruits[*]}"
    IFS="$ancien_ifs"
    echo "Tableau joint : $joint"   # pomme:banane:cerise:datte

    # 4. read -a splitte sur IFS (par défaut espace)
    local chaine="un deux trois quatre cinq"
    local -a mots
    read -ra mots <<< "$chaine"
    echo "Mots : ${mots[@]}"
    echo "3e mot : ${mots[2]}"   # trois
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 14 — Bash avancé : Solutions"
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
