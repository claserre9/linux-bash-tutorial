#!/usr/bin/env bash
# Exercices — Chapitre 8 : Bash — Variables, conditions et boucles

# Chaque exercice présente un problème à résoudre.
# Remplacez les lignes "# TODO" par du code Bash correct.

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Exercice 8.1 — Expansion de paramètres ==="
    echo "Objectif : Manipuler des chemins de fichiers avec l'expansion de paramètres"
    echo ""

    chemin="/home/alice/documents/rapport_final.pdf"

    # TODO 1 : Afficher uniquement le nom du fichier (rapport_final.pdf)
    # Indice : ${chemin##*/}
    echo "Nom du fichier  : (TODO)"

    # TODO 2 : Afficher le répertoire parent (/home/alice/documents)
    # Indice : ${chemin%/*}
    echo "Répertoire      : (TODO)"

    # TODO 3 : Afficher l'extension (pdf)
    # Indice : ${chemin##*.}
    echo "Extension       : (TODO)"

    # TODO 4 : Remplacer 'rapport' par 'compte_rendu' dans le chemin
    # Indice : ${chemin/rapport/compte_rendu}
    echo "Nouveau chemin  : (TODO)"

    echo ""
    echo "--- Résultats attendus ---"
    echo "Nom du fichier  : rapport_final.pdf"
    echo "Répertoire      : /home/alice/documents"
    echo "Extension       : pdf"
    echo "Nouveau chemin  : /home/alice/documents/compte_rendu_final.pdf"
}

ex_2() {
    echo ""
    echo "=== Exercice 8.2 — Arithmétique et tests ==="
    echo "Objectif : Calculatrice simple avec validation"
    echo ""

    # TODO : Écrire une fonction calculer() qui prend 3 arguments :
    # calculer <nombre1> <opérateur> <nombre2>
    # Supporte : + - * /
    # Affiche le résultat ou "Division par zéro" si applicable
    # Exemple : calculer 10 + 5  → "10 + 5 = 15"
    #           calculer 10 / 0  → "Erreur : division par zéro"

    # TODO : Écrire la fonction calculer() ici
    calculer() {
        echo "(TODO : implémenter la fonction)"
    }

    # Tests
    calculer 10 + 5
    calculer 20 - 8
    calculer 6 "*" 7
    calculer 15 / 3
    calculer 10 / 0

    echo ""
    echo "--- Résultats attendus ---"
    echo "10 + 5 = 15"
    echo "20 - 8 = 12"
    echo "6 * 7 = 42"
    echo "15 / 3 = 5"
    echo "Erreur : division par zéro"
}

ex_3() {
    echo ""
    echo "=== Exercice 8.3 — case et gestion de fichiers ==="
    echo "Objectif : Identifier le type d'un fichier selon son extension"
    echo ""

    # TODO : Écrire une fonction type_fichier() qui prend un nom de fichier
    # et affiche son type selon l'extension :
    # .txt .md .rst → "Document texte"
    # .jpg .jpeg .png .gif .webp → "Image"
    # .mp3 .flac .ogg .wav → "Audio"
    # .mp4 .mkv .avi → "Vidéo"
    # .sh .bash → "Script shell"
    # .py → "Script Python"
    # .tar.gz .zip .tar.bz2 → "Archive"
    # autre → "Type inconnu"

    type_fichier() {
        echo "(TODO : implémenter avec case/esac)"
    }

    # Tests
    type_fichier "README.md"
    type_fichier "photo.jpg"
    type_fichier "musique.mp3"
    type_fichier "film.mkv"
    type_fichier "deploy.sh"
    type_fichier "data.py"
    type_fichier "backup.tar.gz"
    type_fichier "fichier.xyz"
}

ex_4() {
    echo ""
    echo "=== Exercice 8.4 — Boucles ==="
    echo "Objectif : Générer une table de multiplication"
    echo ""

    # TODO : Afficher la table de multiplication de 1 à 5
    # Format souhaité :
    # 1 x 1 = 1   1 x 2 = 2   1 x 3 = 3   ...
    # 2 x 1 = 2   2 x 2 = 4   ...
    # ...jusqu'à 5 x 5 = 25

    echo "Table de multiplication (1 à 5) :"
    # TODO : boucle imbriquée for (( ))
    echo "(TODO)"

    echo ""
    echo "--- Résultat attendu ---"
    for (( i=1; i<=5; i++ )); do
        for (( j=1; j<=5; j++ )); do
            printf "%d x %d = %-4d" "$i" "$j" "$((i*j))"
        done
        echo ""
    done
}

ex_5() {
    echo ""
    echo "=== Exercice 8.5 — read et validation ==="
    echo "Objectif : Script interactif de validation d'un mot de passe"
    echo ""
    echo "Règles : au moins 8 caractères, au moins 1 chiffre, au moins 1 majuscule"
    echo "(En mode non-interactif, on teste avec des valeurs prédéfinies)"
    echo ""

    # Fonction de validation de mot de passe
    # TODO : Compléter la fonction valider_mdp()
    # Retourne 0 si valide, 1 sinon
    # Affiche le(s) problème(s) détecté(s)
    valider_mdp() {
        local mdp="$1"
        local valide=true

        # TODO : Vérifier longueur >= 8
        # Indice : ${#mdp}

        # TODO : Vérifier présence d'un chiffre
        # Indice : [[ "$mdp" =~ [0-9] ]]

        # TODO : Vérifier présence d'une majuscule
        # Indice : [[ "$mdp" =~ [A-Z] ]]

        if $valide; then
            echo "Mot de passe valide ✓"
            return 0
        else
            return 1
        fi
    }

    # Tests avec des valeurs prédéfinies (pas de lecture interactive)
    echo "Test 'abc' :"
    valider_mdp "abc"

    echo "Test 'password123' :"
    valider_mdp "password123"

    echo "Test 'Password1' :"
    valider_mdp "Password1"

    echo ""
    echo "--- Comportements attendus ---"
    echo "Test 'abc'         : trop court"
    echo "Test 'password123' : pas de majuscule"
    echo "Test 'Password1'   : Mot de passe valide ✓"
}

main
