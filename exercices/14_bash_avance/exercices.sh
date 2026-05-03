#!/bin/bash
# =============================================================================
# Exercices — Chapitre 14 : Bash avancé
# =============================================================================
# Complétez chaque fonction en remplaçant les '???' par votre code.
# Testez avec : bash exercices.sh
# =============================================================================

# --- Exercice 1 ---
# Travailler avec les tableaux indexés.
# 1. Créer un tableau de 5 langages de programmation
# 2. Afficher le premier et le dernier élément
# 3. Afficher le nombre d'éléments
# 4. Ajouter 2 langages
# 5. Afficher un slice des éléments 2 à 4 (index 1 à 3, 3 éléments)
ex_1() {
    echo "--- Exercice 1 : tableaux indexés ---"

    # 1. Créer le tableau
    local langages=(???)   # 5 langages de programmation

    # 2. Premier et dernier
    echo "Premier : ${langages[0]}"
    echo "Dernier : ???"   # Utiliser l'index -1

    # 3. Nombre d'éléments
    echo "Nombre : ???"

    # 4. Ajouter 2 langages
    ???

    # 5. Slice (3 éléments à partir de l'index 1)
    echo "Slice [1:3] : ???"
}

# --- Exercice 2 ---
# Travailler avec les tableaux associatifs.
# 1. Créer un tableau associatif de 4 pays/capitales
# 2. Ajouter une entrée
# 3. Afficher toutes les paires clé:valeur (triées par clé)
# 4. Tester si une clé existe
# 5. Compter les entrées
ex_2() {
    echo "--- Exercice 2 : tableaux associatifs ---"

    # 1. Déclaration et initialisation
    declare -A capitales
    ???   # Ajouter 4 paires pays/capitale

    # 2. Ajouter une entrée
    capitales["Espagne"]="Madrid"

    # 3. Afficher toutes les paires triées par clé
    for pays in $(echo "${!capitales[@]}" | tr ' ' '\n' | sort); do
        echo "  $pays → ???"
    done

    # 4. Tester si une clé existe
    if ???; then
        echo "France est dans le tableau"
    fi

    # 5. Nombre d'entrées
    echo "Nombre de capitales : ???"
}

# --- Exercice 3 ---
# Utiliser here-document et here-string.
# 1. Créer un here-document pour un fichier de configuration (variables non expansées)
# 2. Utiliser un here-string pour compter les mots d'une phrase
# 3. Utiliser la substitution de processus pour comparer deux listes triées
ex_3() {
    echo "--- Exercice 3 : here-doc et here-string ---"

    # 1. Here-document avec variables NON expansées (guillemets sur EOF)
    echo "Contenu du fichier de config :"
    cat <<???
[database]
host = ${DB_HOST}
port = ${DB_PORT}
user = ${DB_USER}
???

    # 2. Here-string : compter les mots de la phrase
    local phrase="le Bash est un langage de script puissant"
    local nb_mots
    nb_mots=$(wc -w <<< ???)
    echo "Mots dans la phrase : $nb_mots"

    # 3. Substitution de processus : comparer deux listes
    local liste1="pomme banane cerise"
    local liste2="banane datte fraise cerise"
    echo "Différences entre les deux listes :"
    diff <(echo "$liste1" | tr ' ' '\n' | sort) <(echo "$liste2" | tr ' ' '\n' | sort)
}

# --- Exercice 4 ---
# Utiliser mapfile et declare avancé.
# 1. Lire /etc/shells dans un tableau avec mapfile
# 2. Afficher le nombre de shells et les 3 premiers
# 3. Utiliser declare -i pour un compteur d'entiers
# 4. Utiliser declare -r pour une constante
# 5. Utiliser printf pour un tableau aligné
ex_4() {
    echo "--- Exercice 4 : mapfile et declare ---"

    # 1. Lire /etc/shells dans un tableau
    ???
    echo "Nombre de shells : ${shells[???]}"

    # 2. Afficher les 3 premiers shells
    echo "3 premiers shells :"
    for shell in "${shells[@]:0:3}"; do
        echo "  $shell"
    done

    # 3. Compteur entier avec declare -i
    declare -i compteur=0
    compteur=compteur+10
    compteur+=5
    echo "Compteur : $compteur"   # Attendu : 15

    # 4. Constante avec declare -r
    declare -r MAX_RETRIES=3
    echo "Max retries : $MAX_RETRIES"
    # MAX_RETRIES=5  # Décommenter pour voir l'erreur

    # 5. Tableau aligné avec printf
    printf "%-20s %8s %10s\n" "Produit" "Quantité" "Prix HT"
    printf "%-20s %8d %10.2f\n" "Clavier mécanique" 5 89.90
    printf "%-20s %8d %10.2f\n" "Souris ergonomique" 3 45.00
    printf "%-20s %8d %10.2f\n" "Écran 27 pouces" 2 349.00
}

# --- Exercice 5 ---
# Manipuler IFS pour parser des données.
# 1. Parser une ligne CSV avec IFS
# 2. Lire les éléments d'un PATH dans un tableau
# 3. Rejoindre un tableau avec un séparateur personnalisé
# 4. Utiliser read -a pour splitter une chaîne
ex_5() {
    echo "--- Exercice 5 : IFS et parsing ---"

    # 1. Parser un CSV avec IFS
    local ligne_csv="Alice,30,Paris,ingénieure"
    local nom age ville metier
    IFS=, read -r ??? <<< "$ligne_csv"
    echo "Nom: $nom | Âge: $age | Ville: $ville | Métier: $metier"

    # 2. Lire PATH dans un tableau
    local -a chemins
    IFS=: read -ra ??? <<< "$PATH"
    echo "Nombre de répertoires dans PATH : ${#chemins[@]}"
    echo "Premier répertoire : ${chemins[0]}"

    # 3. Rejoindre un tableau avec ":"
    local -a fruits=("pomme" "banane" "cerise" "datte")
    local ancien_ifs="$IFS"
    IFS=:
    local joint="${fruits[*]}"
    IFS="$ancien_ifs"
    echo "Tableau joint : $joint"   # pomme:banane:cerise:datte

    # 4. Splitter avec read -a
    local chaine="un deux trois quatre cinq"
    local -a mots
    read -ra ??? <<< "$chaine"
    echo "Mots : ${mots[@]}"
    echo "3e mot : ${mots[2]}"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 14 — Bash avancé : Exercices"
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
