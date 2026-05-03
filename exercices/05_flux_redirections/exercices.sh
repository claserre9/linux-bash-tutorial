#!/usr/bin/env bash
# Exercices — Chapitre 5 : Flux, redirections et pipes
# Exécutez : bash exercices.sh
#
# Objectifs :
#   - Maîtriser les redirections >, >>, <, 2>, 2>&1
#   - Utiliser les pipes et tee
#   - Travailler avec xargs
#   - Comprendre &&, || et ;
#   - Utiliser la substitution de commandes $()

WORKDIR="/tmp/exo_flux_$$"

setup() {
    mkdir -p "$WORKDIR"
    cd "$WORKDIR" || exit 1

    # Créer des fichiers de données
    for i in $(seq 1 20); do
        echo "2024-01-$(printf '%02d' $((i % 28 + 1))) $([ $((i % 5)) -eq 0 ] && echo 'ERROR' || echo 'INFO') Message ligne $i" >> app.log
    done
    echo "Fichier app.log créé (20 lignes)"

    printf "banane\npomme\ncerise\npomme\nfraise\nbanane\npomme\n" > fruits.txt
    echo "Fichier fruits.txt créé"
}

teardown() {
    cd /tmp || true
    rm -rf "$WORKDIR"
}

main() {
    setup
    echo ""
    ex_1
    ex_2
    ex_3
    ex_4
    ex_5
    teardown
    echo ""
    echo "Tous les exercices terminés ✅"
}

# 5.1 — Redirections stdout et stderr
ex_1() {
    echo "=== Exercice 5.1 : Redirections de base ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Redirigez ls -la vers un fichier liste.txt (écrase)
    echo "--- Capturer la sortie de ls ---"
    echo "[TODO : ls -la > liste.txt]"
    ls -la > liste.txt  # solution

    # TODO : Ajoutez la date à la suite de liste.txt (append)
    echo "[TODO : date >> liste.txt]"
    date >> liste.txt  # solution

    # TODO : Redirigez les erreurs vers erreurs.log et la sortie normale vers sortie.log
    echo ""
    echo "--- Séparer stdout et stderr ---"
    echo "[TODO : ls /etc /dossier_inexistant > sortie.log 2> erreurs.log]"
    ls /etc /dossier_inexistant > sortie.log 2> erreurs.log  # solution

    echo ""
    # TODO : Combiner stdout et stderr dans un seul fichier tout.log
    echo "--- Combiner stdout + stderr ---"
    echo "[TODO : ls /etc /dossier_inexistant > tout.log 2>&1]"
    ls /etc /dossier_inexistant > tout.log 2>&1  # solution

    # TODO : Exécuter une commande silencieusement (sortie ET erreurs ignorées)
    echo ""
    echo "--- Exécution silencieuse ---"
    echo "[TODO : ls /dossier_inexistant &> /dev/null]"
    ls /dossier_inexistant &> /dev/null  # solution
    echo "Code de retour de la commande silencieuse : $?"

    # Vérifications
    echo ""
    [ -f "liste.txt" ]   && echo "✓ liste.txt créé ($(wc -l < liste.txt) lignes)" || echo "✗ liste.txt manquant"
    [ -f "erreurs.log" ] && echo "✓ erreurs.log créé" || echo "✗ erreurs.log manquant"
    [ -s "erreurs.log" ] && echo "✓ erreurs.log contient des erreurs" || echo "⚠ erreurs.log est vide"
    [ -f "tout.log" ]    && echo "✓ tout.log créé ($(wc -l < tout.log) lignes)" || echo "✗ tout.log manquant"
}

# 5.2 — Pipes et tee
ex_2() {
    echo ""
    echo "=== Exercice 5.2 : Pipes et tee ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Triez fruits.txt et supprimez les doublons via un pipe
    echo "--- Trier et dédupliquer fruits.txt ---"
    echo "[TODO : sort fruits.txt | uniq]"
    echo "Résultat attendu : banane, cerise, fraise, pomme (triés, sans doublons)"
    echo ""
    sort fruits.txt | uniq

    echo ""
    # TODO : Comptez combien de fois chaque fruit apparaît
    echo "--- Fréquence de chaque fruit ---"
    echo "[TODO : sort fruits.txt | uniq -c | sort -rn]"
    sort fruits.txt | uniq -c | sort -rn

    echo ""
    # TODO : Filtrez les lignes ERROR de app.log et sauvegardez dans errors_only.log
    # Utilisez tee pour AUSSI afficher à l'écran pendant que vous sauvegardez
    echo "--- Filtrer errors avec tee ---"
    echo "[TODO : grep 'ERROR' app.log | tee errors_only.log]"
    grep "ERROR" app.log | tee errors_only.log

    echo ""
    # TODO : Construisez un pipeline pour :
    # 1. Afficher app.log
    # 2. Filtrer les INFO
    # 3. Compter les lignes
    # 4. Sauvegarder dans un fichier count_info.txt
    echo "--- Pipeline multi-étapes ---"
    echo "[TODO : grep 'INFO' app.log | wc -l | tee count_info.txt]"
    grep "INFO" app.log | wc -l | tee count_info.txt > /dev/null

    # Vérifications
    echo ""
    [ -f "errors_only.log" ] && echo "✓ errors_only.log : $(wc -l < errors_only.log) ligne(s)" || echo "✗ errors_only.log manquant"
    NB_FRUITS_UNIQ=$(sort fruits.txt | uniq | wc -l)
    echo "✓ Fruits uniques : $NB_FRUITS_UNIQ"
}

# 5.3 — xargs
ex_3() {
    echo ""
    echo "=== Exercice 5.3 : xargs ==="
    echo ""

    cd "$WORKDIR" || return

    # Créer des fichiers de test
    touch rapport_{jan,fev,mar,avr}.pdf
    touch données_{2023,2024}.csv
    echo "Fichiers créés : $(ls *.pdf *.csv | tr '\n' ' ')"
    echo ""

    # TODO : Utilisez xargs pour afficher la taille de tous les fichiers .pdf
    echo "--- Taille des fichiers PDF ---"
    echo "[TODO : ls *.pdf | xargs ls -lh]"
    ls *.pdf | xargs ls -lh

    echo ""
    # TODO : Créez un répertoire archives/ et déplacez tous les .pdf dedans
    # avec find + xargs -I {}
    mkdir -p archives
    echo "--- Déplacer les PDF dans archives/ ---"
    echo "[TODO : find . -maxdepth 1 -name '*.pdf' | xargs -I {} mv {} archives/]"
    find . -maxdepth 1 -name "*.pdf" | xargs -I {} mv {} archives/  # solution

    echo ""
    # TODO : Créez un fichier liste_fichiers.txt contenant les noms des fichiers .csv
    # puis utilisez xargs pour lire chacun avec cat
    echo "--- xargs avec un fichier de noms ---"
    ls *.csv > liste_csv.txt
    cat liste_csv.txt
    echo "[TODO : cat liste_csv.txt | xargs wc -l]"
    cat liste_csv.txt | xargs wc -l

    echo ""
    # TODO : Avec xargs -n 1, affichez chaque fichier CSV sur une ligne séparée
    echo "--- xargs -n 1 (un argument par appel) ---"
    echo "[TODO : echo 'fichier1.csv fichier2.csv' | xargs -n 1 echo 'Traitement :']"
    echo "données_2023.csv données_2024.csv" | xargs -n 1 echo "Traitement :"

    # Vérifications
    echo ""
    NB_PDF_ARCHIVES=$(ls archives/*.pdf 2>/dev/null | wc -l)
    echo "✓ PDFs dans archives/ : $NB_PDF_ARCHIVES"
}

# 5.4 — Chaînes &&, ||, ;
ex_4() {
    echo ""
    echo "=== Exercice 5.4 : Chaînes de commandes &&, ||, ; ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Utilisez && pour créer un répertoire et y entrer seulement si la création réussit
    echo "--- && (ET logique) ---"
    echo "[TODO : mkdir -p build && echo 'build créé avec succès']"
    mkdir -p build && echo "✓ build créé avec succès"

    echo ""
    # TODO : Utilisez || pour afficher un message si la création échoue
    echo "--- || (OU logique, gestion d'erreur) ---"
    echo "[TODO : mkdir /root/impossible 2>/dev/null || echo 'Création échouée (attendu)']"
    mkdir /root/impossible 2>/dev/null || echo "✓ Création échouée (attendu — sans sudo)"

    echo ""
    # TODO : Enchaînez 3 commandes avec ; (la 3e s'exécute peu importe le résultat des autres)
    echo "--- ; (séquence inconditionnelle) ---"
    echo "[TODO : echo 'étape 1' ; false ; echo 'étape 3 exécutée quand même']"
    echo "étape 1" ; false ; echo "✓ étape 3 exécutée quand même (false ignoré avec ;)"

    echo ""
    # TODO : Construisez une vérification : si un fichier existe, affichez sa taille,
    # sinon créez-le
    echo "--- Condition pratique ---"
    FICHIER="$WORKDIR/config.conf"
    echo "[TODO : [ -f '$FICHIER' ] && stat -c '%s octets' '$FICHIER' || touch '$FICHIER' && echo 'créé']"
    [ -f "$FICHIER" ] && stat -c "%s octets" "$FICHIER" \
        || { touch "$FICHIER" && echo "✓ $FICHIER créé"; }

    echo ""
    # TODO : Démontrez la différence entre && et ; avec une commande qui échoue au milieu
    echo "--- Différence && vs ; ---"
    echo "Avec && : false && echo 'après false' (ne s'affiche pas)"
    false && echo "après false (ne devrait pas apparaître)"
    echo "Avec ;  : false ; echo 'après false' (s'affiche)"
    false ; echo "✓ 'après false' s'affiche avec ;"
}

# 5.5 — Substitution de commandes et here-string
ex_5() {
    echo ""
    echo "=== Exercice 5.5 : Substitution de commandes et here-string ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Capturez la date courante dans une variable et utilisez-la dans un nom de fichier
    echo "--- Substitution de commandes ---"
    echo "[TODO : TIMESTAMP=\$(date +%Y%m%d_%H%M%S)]"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
    echo "✓ Nom d'archive généré : $ARCHIVE_NAME"

    echo ""
    # TODO : Comptez le nombre de fichiers dans $WORKDIR avec $()
    echo "[TODO : NB=\$(find $WORKDIR -type f | wc -l) && echo \"Fichiers : \$NB\"]"
    NB=$(find "$WORKDIR" -type f | wc -l)
    echo "✓ Nombre de fichiers dans WORKDIR : $NB"

    echo ""
    # TODO : Utilisez here-string pour passer une chaîne à wc -w
    echo "--- Here-string <<< ---"
    echo "[TODO : wc -w <<< 'bonjour le monde']"
    NB_MOTS=$(wc -w <<< "bonjour le monde")
    echo "✓ 'bonjour le monde' contient $NB_MOTS mots"

    echo ""
    # TODO : Utilisez un here-document pour créer un fichier de configuration
    echo "--- Here-document ---"
    cat > "$WORKDIR/app.conf" << 'EOF'
# Configuration de l'application
HOST=localhost
PORT=8080
DEBUG=false
LOG_LEVEL=INFO
EOF
    echo "✓ app.conf créé :"
    cat "$WORKDIR/app.conf"

    echo ""
    # TODO : Vérifiez si vous êtes root avec la substitution $(id -u)
    echo "--- Test du compte courant ---"
    echo "[TODO : if [ \"\$(id -u)\" -eq 0 ]; then echo root; else echo non-root; fi]"
    if [ "$(id -u)" -eq 0 ]; then
        echo "✓ Vous êtes root"
    else
        echo "✓ Vous êtes non-root (UID=$(id -u))"
    fi

    # Vérification finale
    echo ""
    [ -f "$WORKDIR/app.conf" ] && echo "✓ app.conf créé avec $(wc -l < "$WORKDIR/app.conf") lignes" || echo "✗ app.conf manquant"
}

main
