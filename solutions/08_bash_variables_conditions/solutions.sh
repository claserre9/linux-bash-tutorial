#!/usr/bin/env bash
# Solutions — Chapitre 8 : Bash — Variables, conditions et boucles

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Solution 8.1 — Expansion de paramètres ==="

    chemin="/home/alice/documents/rapport_final.pdf"

    # ${chemin##*/} : supprime le préfixe le plus long se terminant par /
    # → équivalent de basename
    echo "Nom du fichier  : ${chemin##*/}"

    # ${chemin%/*} : supprime le suffixe le plus court commençant par /
    # → équivalent de dirname
    echo "Répertoire      : ${chemin%/*}"

    # ${chemin##*.} : supprime le préfixe le plus long se terminant par .
    # → extrait l'extension
    echo "Extension       : ${chemin##*.}"

    # ${chemin/rapport/compte_rendu} : remplace la 1ère occurrence
    echo "Nouveau chemin  : ${chemin/rapport/compte_rendu}"

    echo ""
    echo "Explications :"
    echo "  \${var##*/}   : supprime tout jusqu'au dernier / (basename)"
    echo "  \${var%/*}    : supprime depuis le dernier / (dirname)"
    echo "  \${var##*.}   : supprime tout jusqu'au dernier . (extension)"
    echo "  \${var/old/new} : remplace la 1ère occurrence"
    echo "  \${var//old/new} : remplace toutes les occurrences"
}

ex_2() {
    echo ""
    echo "=== Solution 8.2 — Arithmétique et tests ==="

    calculer() {
        local a="$1"
        local op="$2"
        local b="$3"

        # Vérifier que les arguments sont numériques
        if ! [[ "$a" =~ ^-?[0-9]+$ ]] || ! [[ "$b" =~ ^-?[0-9]+$ ]]; then
            echo "Erreur : arguments non numériques"
            return 1
        fi

        local resultat
        case "$op" in
            +) resultat=$(( a + b )) ;;
            -) resultat=$(( a - b )) ;;
            "*") resultat=$(( a * b )) ;;
            /)
                if (( b == 0 )); then
                    echo "Erreur : division par zéro"
                    return 1
                fi
                resultat=$(( a / b ))
                ;;
            *)
                echo "Erreur : opérateur inconnu '$op'"
                return 1
                ;;
        esac

        echo "$a $op $b = $resultat"
    }

    calculer 10 + 5
    calculer 20 - 8
    calculer 6 "*" 7
    calculer 15 / 3
    calculer 10 / 0

    echo ""
    echo "Points clés :"
    echo "  - case pour dispatcher selon l'opérateur"
    echo "  - (( b == 0 )) pour tester la division par zéro"
    echo "  - \$(( )) pour l'arithmétique entière"
    echo "  - =~ ^-?[0-9]+\$ pour valider que c'est un nombre"
}

ex_3() {
    echo ""
    echo "=== Solution 8.3 — case et gestion de fichiers ==="

    type_fichier() {
        local fichier="$1"
        local nom="${fichier##*/}"     # Nom sans répertoire
        local ext="${nom##*.}"         # Extension (tout après le dernier .)
        local ext_lower
        ext_lower=$(echo "$ext" | tr 'A-Z' 'a-z')

        # Cas spécial pour .tar.gz, .tar.bz2
        if [[ "$nom" == *.tar.* ]]; then
            echo "$fichier → Archive"
            return
        fi

        case "$ext_lower" in
            txt | md | rst | org)
                echo "$fichier → Document texte"
                ;;
            jpg | jpeg | png | gif | webp | svg | bmp)
                echo "$fichier → Image"
                ;;
            mp3 | flac | ogg | wav | aac | m4a)
                echo "$fichier → Audio"
                ;;
            mp4 | mkv | avi | mov | webm)
                echo "$fichier → Vidéo"
                ;;
            sh | bash)
                echo "$fichier → Script shell"
                ;;
            py)
                echo "$fichier → Script Python"
                ;;
            zip | gz | bz2 | xz | 7z | rar)
                echo "$fichier → Archive"
                ;;
            *)
                echo "$fichier → Type inconnu (.$ext_lower)"
                ;;
        esac
    }

    type_fichier "README.md"
    type_fichier "photo.jpg"
    type_fichier "musique.mp3"
    type_fichier "film.mkv"
    type_fichier "deploy.sh"
    type_fichier "data.py"
    type_fichier "backup.tar.gz"
    type_fichier "fichier.xyz"

    echo ""
    echo "Points clés :"
    echo "  - ${nom##*.} extrait l'extension"
    echo "  - tr pour normaliser en minuscules avant case"
    echo "  - [[ \"\$nom\" == *.tar.* ]] pour les extensions doubles"
    echo "  - Les patterns dans case séparés par | (pipe)"
}

ex_4() {
    echo ""
    echo "=== Solution 8.4 — Boucles ==="
    echo "Table de multiplication (1 à 5) :"
    echo ""

    # Boucle imbriquée : boucle externe pour les lignes, interne pour les colonnes
    for (( i=1; i<=5; i++ )); do
        for (( j=1; j<=5; j++ )); do
            # printf pour un formatage aligné
            # %-4d : entier aligné à gauche sur 4 caractères
            printf "%d x %d = %-4d" "$i" "$j" "$(( i * j ))"
        done
        echo ""    # Saut de ligne après chaque rangée
    done

    echo ""
    echo "Variante avec {1..5} :"
    for i in {1..5}; do
        for j in {1..5}; do
            printf "%2d " "$(( i * j ))"
        done
        echo ""
    done

    echo ""
    echo "Points clés :"
    echo "  - for (( i=1; i<=5; i++ )) : boucle arithmétique style C"
    echo "  - printf pour l'alignement (%-4d = gauche sur 4 chars)"
    echo "  - echo \"\" pour le saut de ligne en fin de rangée"
}

ex_5() {
    echo ""
    echo "=== Solution 8.5 — Validation de mot de passe ==="

    valider_mdp() {
        local mdp="$1"
        local valide=true
        local erreurs=()

        # Vérifier la longueur (>= 8 caractères)
        if (( ${#mdp} < 8 )); then
            erreurs+=("trop court (${#mdp} caractères, minimum 8)")
            valide=false
        fi

        # Vérifier la présence d'au moins un chiffre
        if ! [[ "$mdp" =~ [0-9] ]]; then
            erreurs+=("aucun chiffre")
            valide=false
        fi

        # Vérifier la présence d'au moins une majuscule
        if ! [[ "$mdp" =~ [A-Z] ]]; then
            erreurs+=("aucune majuscule")
            valide=false
        fi

        if $valide; then
            echo "  → Mot de passe valide ✓"
            return 0
        else
            echo "  → Invalide : ${erreurs[*]}"
            return 1
        fi
    }

    echo "Test 'abc' :"
    valider_mdp "abc"

    echo "Test 'password123' :"
    valider_mdp "password123"

    echo "Test 'Password1' :"
    valider_mdp "Password1"

    echo "Test 'Tr0ub4dor&3' :"
    valider_mdp "Tr0ub4dor&3"

    echo ""
    echo "Points clés :"
    echo "  - \${#mdp} : longueur de la chaîne"
    echo "  - [[ \"\$mdp\" =~ [0-9] ]] : test regex Bash (=~ avec [[]])"
    echo "  - tableau erreurs=() pour accumuler les messages"
    echo "  - \${erreurs[*]} pour afficher tous les éléments"
    echo "  - return 0/1 pour le code de sortie"
}

main
