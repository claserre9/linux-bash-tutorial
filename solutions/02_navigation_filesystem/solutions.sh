#!/usr/bin/env bash
# Solutions — Chapitre 2 : Navigation et système de fichiers
# Exécutez : bash solutions.sh

WORKDIR="/tmp/sol_navigation_$$"

setup() {
    mkdir -p "$WORKDIR"
    mkdir -p "$WORKDIR/projets/web/css"
    mkdir -p "$WORKDIR/projets/web/js"
    mkdir -p "$WORKDIR/projets/api"
    mkdir -p "$WORKDIR/logs"
    mkdir -p "$WORKDIR/.config"
    echo "body { color: red; }" > "$WORKDIR/projets/web/css/style.css"
    echo "console.log('hello');" > "$WORKDIR/projets/web/js/app.js"
    echo "# Config" > "$WORKDIR/.config/settings.conf"
    echo "GET /index.html 200" > "$WORKDIR/logs/access.log"
    echo "ERROR 404 not found" > "$WORKDIR/logs/error.log"
    touch "$WORKDIR/README.md"
    touch "$WORKDIR/.gitignore"
    dd if=/dev/zero of="$WORKDIR/dummy_file" bs=1024 count=512 2>/dev/null
    echo "Environnement créé dans : $WORKDIR"
}

teardown() {
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

# 2.1 — Navigation et pwd
ex_1() {
    echo "=== Exercice 2.1 : Navigation de base ==="
    echo ""

    INITIAL=$(pwd)
    echo "Répertoire de départ : $INITIAL"

    # Aller dans WORKDIR
    cd "$WORKDIR"
    echo "Après cd WORKDIR  : $(pwd)"

    # Aller dans /etc
    cd /etc
    echo "Après cd /etc     : $(pwd)"

    # Revenir avec cd -
    cd -
    echo "Après cd -        : $(pwd)"

    # Vérification
    echo ""
    if [ "$(pwd)" = "$WORKDIR" ]; then
        echo "✓ cd - fonctionne correctement — retour à $WORKDIR"
    fi

    # Démonstration de ~ et ..
    echo ""
    echo "--- Raccourcis de navigation ---"
    echo "~ = $HOME"
    cd ~ && echo "cd ~  → $(pwd)" && cd "$WORKDIR"
    cd .. && echo "cd .. → $(pwd)" && cd "$WORKDIR"

    cd "$INITIAL"
}

# 2.2 — Options de ls
ex_2() {
    echo ""
    echo "=== Exercice 2.2 : Options de ls ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- ls simple (fichiers visibles seulement) ---"
    ls

    echo ""
    echo "--- ls -a (tous les fichiers, y compris cachés) ---"
    ls -a

    echo ""
    echo "--- ls -lh (format long, tailles lisibles) ---"
    ls -lh

    echo ""
    echo "--- ls -lha (tout combiné) ---"
    ls -lha

    echo ""
    echo "--- ls -lhR projets/ (récursif) ---"
    ls -lhR projets/

    echo ""
    echo "--- ls -lt (tri par date) ---"
    ls -lt

    NB_CACHES=$(ls -a "$WORKDIR" | grep "^\." | wc -l)
    echo ""
    echo "✓ Nombre de fichiers/dossiers cachés dans WORKDIR : $NB_CACHES"

    cd - > /dev/null
}

# 2.3 — Chemins relatifs vs absolus
ex_3() {
    echo ""
    echo "=== Exercice 2.3 : Chemins relatifs et absolus ==="
    echo ""

    cd "$WORKDIR/projets/web" || return
    echo "Répertoire courant : $(pwd)"

    echo ""
    echo "--- Chemin relatif vers style.css ---"
    cat css/style.css

    echo ""
    echo "--- Chemin absolu vers style.css ---"
    cat "$WORKDIR/projets/web/css/style.css"

    echo ""
    FICHIER="$WORKDIR/projets/web/css/style.css"
    echo "basename : $(basename "$FICHIER")"
    echo "dirname  : $(dirname "$FICHIER")"
    echo "basename sans extension : $(basename "$FICHIER" .css)"

    echo ""
    echo "--- realpath ---"
    realpath "../../README.md"

    echo ""
    echo "✓ basename : $(basename "$FICHIER")"
    echo "✓ dirname  : $(dirname "$FICHIER")"

    cd - > /dev/null
}

# 2.4 — stat et file
ex_4() {
    echo ""
    echo "=== Exercice 2.4 : stat et file ==="
    echo ""

    echo "--- stat sur README.md ---"
    stat "$WORKDIR/README.md"

    echo ""
    echo "--- stat format personnalisé ---"
    stat -c "%n : %s octets, modifié le %y" "$WORKDIR/dummy_file" 2>/dev/null \
        || stat -f "%N : %z octets" "$WORKDIR/dummy_file" 2>/dev/null

    echo ""
    echo "--- file sur plusieurs éléments ---"
    file "$WORKDIR/README.md"
    file "$WORKDIR/dummy_file"
    file "$WORKDIR/logs/access.log"
    file "$WORKDIR/projets/web/css/style.css"

    echo ""
    echo "--- Vérification ---"
    TAILLE=$(stat -c "%s" "$WORKDIR/dummy_file" 2>/dev/null \
          || stat -f "%z" "$WORKDIR/dummy_file" 2>/dev/null)
    echo "✓ dummy_file taille : $TAILLE octets"
}

# 2.5 — Espace disque avec du et df
ex_5() {
    echo ""
    echo "=== Exercice 2.5 : Espace disque ==="
    echo ""

    echo "--- df -h (espace disque disponible) ---"
    df -h

    echo ""
    echo "--- Taille de WORKDIR ---"
    du -sh "$WORKDIR"

    echo ""
    echo "--- Taille de chaque sous-répertoire ---"
    du -sh "$WORKDIR"/*/

    echo ""
    echo "--- Sous-répertoire le plus volumineux ---"
    du -sh "$WORKDIR"/*/ | sort -rh | head -1

    echo ""
    echo "--- Top 5 des plus gros éléments de WORKDIR ---"
    du -ah "$WORKDIR" | sort -rh | head -5

    TAILLE_TOTALE=$(du -sh "$WORKDIR" 2>/dev/null | cut -f1)
    echo ""
    echo "✓ Taille totale de WORKDIR : $TAILLE_TOTALE"
}

main
