#!/usr/bin/env bash
# Solutions — Chapitre 5 : Flux, redirections et pipes
# Exécutez : bash solutions.sh

WORKDIR="/tmp/sol_flux_$$"

setup() {
    mkdir -p "$WORKDIR"
    cd "$WORKDIR" || exit 1

    for i in $(seq 1 20); do
        echo "2024-01-$(printf '%02d' $((i % 28 + 1))) $([ $((i % 5)) -eq 0 ] && echo 'ERROR' || echo 'INFO') Message ligne $i" >> app.log
    done

    printf "banane\npomme\ncerise\npomme\nfraise\nbanane\npomme\n" > fruits.txt
    echo "Fichiers de données créés"
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

    echo "--- Capturer la sortie de ls ---"
    ls -la > liste.txt
    echo "✓ ls -la > liste.txt ($(wc -l < liste.txt) lignes)"

    date >> liste.txt
    echo "✓ date >> liste.txt (append — maintenant $(wc -l < liste.txt) lignes)"

    echo "Contenu de liste.txt :"
    cat liste.txt

    echo ""
    echo "--- Séparer stdout et stderr ---"
    ls /etc /dossier_inexistant > sortie.log 2> erreurs.log
    echo "✓ stdout → sortie.log  ($(wc -l < sortie.log) lignes)"
    echo "✓ stderr → erreurs.log ($(wc -l < erreurs.log) lignes)"
    echo "Erreurs capturées :"
    cat erreurs.log

    echo ""
    echo "--- Combiner stdout + stderr ---"
    ls /etc /dossier_inexistant > tout.log 2>&1
    echo "✓ tout dans tout.log ($(wc -l < tout.log) lignes)"
    echo "Explication : 2>&1 = 'le fd 2 va vers où pointe le fd 1 (tout.log)'"

    echo ""
    echo "--- Exécution silencieuse ---"
    ls /dossier_inexistant &> /dev/null
    echo "✓ Code de retour : $? (1 = erreur, mais rien affiché)"

    echo ""
    echo "--- Différence > et >> ---"
    echo "premiere" > test_overwrite.txt
    cat test_overwrite.txt
    echo "deuxieme" > test_overwrite.txt    # ÉCRASE la première ligne
    cat test_overwrite.txt
    echo "troisieme" >> test_overwrite.txt  # AJOUTE
    cat test_overwrite.txt
}

# 5.2 — Pipes et tee
ex_2() {
    echo ""
    echo "=== Exercice 5.2 : Pipes et tee ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- Trier et dédupliquer fruits.txt ---"
    sort fruits.txt | uniq
    echo "✓ sort fruits.txt | uniq"

    echo ""
    echo "--- Fréquence de chaque fruit ---"
    sort fruits.txt | uniq -c | sort -rn
    echo "✓ sort fruits.txt | uniq -c | sort -rn"

    echo ""
    echo "--- Filtrer errors avec tee ---"
    grep "ERROR" app.log | tee errors_only.log
    echo "✓ grep 'ERROR' app.log | tee errors_only.log"
    echo "  → affiché à l'écran ET sauvegardé dans errors_only.log"

    echo ""
    echo "--- Pipeline multi-étapes ---"
    NB_INFO=$(grep "INFO" app.log | wc -l | tee count_info.txt)
    echo "✓ Lignes INFO : $NB_INFO (sauvegardé dans count_info.txt)"

    echo ""
    echo "--- Démonstration tee -a (append) ---"
    echo "Ligne 1" | tee rapport.txt > /dev/null
    echo "Ligne 2" | tee -a rapport.txt > /dev/null
    echo "Contenu de rapport.txt :"
    cat rapport.txt

    echo ""
    echo "--- Pipeline avancé : top 3 fréquences ---"
    cat fruits.txt fruits.txt | sort | uniq -c | sort -rn | head -3
    echo "✓ Pipeline : cat | sort | uniq -c | sort -rn | head"
}

# 5.3 — xargs
ex_3() {
    echo ""
    echo "=== Exercice 5.3 : xargs ==="
    echo ""

    cd "$WORKDIR" || return

    touch rapport_{jan,fev,mar,avr}.pdf
    touch données_{2023,2024}.csv

    echo "--- Taille des fichiers PDF ---"
    ls *.pdf | xargs ls -lh
    echo "✓ ls *.pdf | xargs ls -lh"

    echo ""
    echo "--- Déplacer les PDF dans archives/ ---"
    mkdir -p archives
    find . -maxdepth 1 -name "*.pdf" -print0 | xargs -0 -I {} mv {} archives/
    echo "✓ find . -maxdepth 1 -name '*.pdf' -print0 | xargs -0 -I {} mv {} archives/"
    echo "PDFs dans archives/ :"
    ls archives/

    echo ""
    echo "--- xargs avec liste de fichiers ---"
    ls *.csv > liste_csv.txt
    cat liste_csv.txt | xargs wc -l
    echo "✓ cat liste_csv.txt | xargs wc -l"

    echo ""
    echo "--- xargs -n 1 (un argument par appel) ---"
    echo "données_2023.csv données_2024.csv" | xargs -n 1 echo "Traitement :"
    echo "✓ xargs -n 1 : une exécution par argument"

    echo ""
    echo "--- Démonstration xargs -P (parallèle) ---"
    echo "find . -name '*.csv' | xargs -P 2 -I {} wc -l {}"
    find . -name "*.csv" | xargs -P 2 -I {} wc -l {}
    echo "✓ -P 2 = 2 processus parallèles"

    echo ""
    NB_PDF=$(ls archives/*.pdf 2>/dev/null | wc -l)
    echo "✓ PDFs dans archives/ : $NB_PDF"
}

# 5.4 — Chaînes &&, ||, ;
ex_4() {
    echo ""
    echo "=== Exercice 5.4 : Chaînes de commandes ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- && (ET logique) ---"
    mkdir -p build && echo "✓ build créé && echo exécuté (succès → succès)"
    mkdir /root/impossible 2>/dev/null && echo "ne s'affiche pas" || true

    echo ""
    echo "--- || (OU logique) ---"
    mkdir /root/impossible 2>/dev/null || echo "✓ Création échouée — || exécuté (échec → succès)"

    echo ""
    echo "--- ; (séquence inconditionnelle) ---"
    echo "étape 1" ; false ; echo "✓ étape 3 avec ; (s'exécute même après false)"

    echo ""
    echo "--- Démonstration : différence && et ; ---"
    echo "Avec && :"
    false && echo "(ne s'affiche pas)"
    echo "Rien après false &&"
    echo ""
    echo "Avec ; :"
    false ; echo "✓ S'affiche après false ;"

    echo ""
    echo "--- Pattern pratique : vérification ou création ---"
    FICHIER="$WORKDIR/config.conf"
    [ -f "$FICHIER" ] && echo "Fichier existe" || { touch "$FICHIER" && echo "✓ Fichier créé : $FICHIER"; }

    echo ""
    echo "--- Pattern : commande avec rollback ---"
    echo "Démarrage déploiement..."
    cd "$WORKDIR" \
        && mkdir -p deploy \
        && touch deploy/app.py \
        && echo "✓ Déploiement réussi (toutes les étapes avec &&)" \
        || echo "✗ Déploiement échoué (s'arrête à la première erreur)"

    echo ""
    echo "--- Codes de retour ---"
    true  ; echo "true  → \$? = $?"
    false ; echo "false → \$? = $?"
    ls /etc/passwd > /dev/null 2>&1 ; echo "ls /etc/passwd → \$? = $?"
    ls /inexistant > /dev/null 2>&1 ; echo "ls /inexistant → \$? = $?"
}

# 5.5 — Substitution de commandes et here-string
ex_5() {
    echo ""
    echo "=== Exercice 5.5 : Substitution de commandes et here-string ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- Substitution \$() ---"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
    echo "✓ TIMESTAMP = $TIMESTAMP"
    echo "✓ ARCHIVE_NAME = $ARCHIVE_NAME"

    echo ""
    echo "--- Compter les fichiers ---"
    NB=$(find "$WORKDIR" -type f | wc -l)
    echo "✓ Fichiers dans WORKDIR : $NB"

    echo ""
    echo "--- Utilisation dans les chaînes ---"
    echo "Utilisateur : $(whoami), Heure : $(date +%H:%M:%S)"
    echo "Répertoire : $(pwd)"
    echo "Lignes dans /etc/passwd : $(wc -l < /etc/passwd)"

    echo ""
    echo "--- Here-string <<< ---"
    NB_MOTS=$(wc -w <<< "bonjour le monde")
    echo "✓ wc -w <<< 'bonjour le monde' = $NB_MOTS mots"

    # Utilité : éviter echo "..." | cmd
    RESULTAT=$(bc <<< "2 + 3 * 4")
    echo "✓ bc <<< '2 + 3 * 4' = $RESULTAT"

    UPPER=$(tr '[:lower:]' '[:upper:]' <<< "bonjour monde")
    echo "✓ tr <<< 'bonjour monde' = $UPPER"

    echo ""
    echo "--- Here-document ---"
    cat > "$WORKDIR/app.conf" << 'EOF'
# Configuration de l'application
HOST=localhost
PORT=8080
DEBUG=false
LOG_LEVEL=INFO
EOF
    echo "✓ app.conf créé par here-document :"
    cat "$WORKDIR/app.conf"

    echo ""
    echo "--- Here-document avec variables ---"
    APP_NAME="MonApp"
    VERSION="1.0.0"
    cat << EOF
Application : $APP_NAME
Version     : $VERSION
Heure       : $(date)
(Les variables sont interpolées dans << EOF sans guillemets)
EOF

    echo ""
    echo "--- Test compte courant ---"
    if [ "$(id -u)" -eq 0 ]; then
        echo "✓ Vous êtes root (UID=0)"
    else
        echo "✓ Vous êtes non-root (UID=$(id -u))"
    fi

    echo ""
    echo "--- Comparaison \$() vs backticks ---"
    echo "Moderne   : DATE=\$(date) → $(date +%Y-%m-%d)"
    echo "Ancien    : DATE=\`date\` → $(date +%Y-%m-%d)"
    echo "→ Utilisez toujours \$() — plus lisible et imbriquable"

    [ -f "$WORKDIR/app.conf" ] && echo "✓ app.conf créé avec $(wc -l < "$WORKDIR/app.conf") lignes"
}

main
