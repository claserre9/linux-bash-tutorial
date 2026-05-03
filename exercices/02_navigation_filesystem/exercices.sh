#!/usr/bin/env bash
# Exercices — Chapitre 2 : Navigation et système de fichiers
# Exécutez : bash exercices.sh
#
# Objectifs :
#   - Naviguer dans l'arborescence Linux
#   - Utiliser ls avec diverses options
#   - Comprendre les chemins relatifs et absolus
#   - Analyser l'espace disque avec du et df
#   - Identifier les types de fichiers avec stat et file

WORKDIR="/tmp/exo_navigation_$$"

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
    echo "Environnement de travail créé dans : $WORKDIR"
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

    echo "Répertoire de départ : $(pwd)"
    echo ""

    # TODO : Naviguez dans $WORKDIR, affichez le chemin avec pwd,
    # puis revenez au répertoire précédent avec cd -
    echo "--- Actions à effectuer ---"
    echo "1. cd $WORKDIR"
    echo "2. pwd     → doit afficher $WORKDIR"
    echo "3. cd /etc"
    echo "4. pwd     → doit afficher /etc"
    echo "5. cd -    → retour à $WORKDIR"
    echo "6. pwd     → doit afficher $WORKDIR"
    echo ""

    # Vérification automatique
    INITIAL=$(pwd)
    cd "$WORKDIR" 2>/dev/null
    if [ "$(pwd)" = "$WORKDIR" ]; then
        echo "✓ Déplacement vers WORKDIR réussi : $(pwd)"
    fi
    cd "$INITIAL"
    if [ "$(pwd)" = "$INITIAL" ]; then
        echo "✓ Retour au répertoire initial réussi : $(pwd)"
    fi
}

# 2.2 — Options de ls
ex_2() {
    echo ""
    echo "=== Exercice 2.2 : Options de ls ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Exécutez chacune des commandes suivantes et observez les différences

    echo "--- ls simple (fichiers visibles seulement) ---"
    # TODO : ls
    ls

    echo ""
    echo "--- ls -a (tous les fichiers, y compris cachés) ---"
    # TODO : ls -a
    echo "[TODO : ls -a]"

    echo ""
    echo "--- ls -lh (format long, tailles lisibles) ---"
    # TODO : ls -lh
    echo "[TODO : ls -lh]"

    echo ""
    echo "--- ls -lha (tout combiné) ---"
    # TODO : ls -lha
    echo "[TODO : ls -lha]"

    echo ""
    echo "--- ls -lhR projets/ (récursif) ---"
    # TODO : ls -lhR projets/
    echo "[TODO : ls -lhR projets/]"

    echo ""
    # Vérification : compte les fichiers cachés
    NB_CACHES=$(ls -a "$WORKDIR" | grep "^\." | wc -l)
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

    # TODO : Affichez le contenu de style.css avec un chemin RELATIF
    echo "--- Chemin relatif vers style.css ---"
    echo "[TODO : cat css/style.css   (chemin relatif)]"

    echo ""
    # TODO : Affichez le contenu de style.css avec un chemin ABSOLU
    echo "--- Chemin absolu vers style.css ---"
    echo "[TODO : cat $WORKDIR/projets/web/css/style.css   (chemin absolu)]"

    echo ""
    # TODO : Utilisez basename et dirname
    FICHIER="$WORKDIR/projets/web/css/style.css"
    echo "Fichier complet : $FICHIER"
    echo "[TODO : basename $FICHIER]  → doit afficher : style.css"
    echo "[TODO : dirname  $FICHIER]  → doit afficher : $WORKDIR/projets/web/css"

    # Vérification
    RESULT_BASE=$(basename "$FICHIER")
    RESULT_DIR=$(dirname "$FICHIER")
    echo ""
    echo "✓ basename : $RESULT_BASE"
    echo "✓ dirname  : $RESULT_DIR"

    cd - > /dev/null
}

# 2.4 — stat et file
ex_4() {
    echo ""
    echo "=== Exercice 2.4 : stat et file ==="
    echo ""

    # TODO : Utilisez stat pour afficher les métadonnées de ces fichiers
    echo "--- stat sur README.md ---"
    # TODO : stat $WORKDIR/README.md
    echo "[TODO : stat $WORKDIR/README.md]"

    echo ""
    echo "--- stat format personnalisé (taille en octets) ---"
    # TODO : stat -c "%n : %s octets" $WORKDIR/dummy_file
    echo "[TODO : stat -c '%n : %s octets' $WORKDIR/dummy_file]"

    echo ""
    # TODO : Utilisez 'file' pour identifier le type de ces éléments
    echo "--- file sur plusieurs éléments ---"
    # TODO : file $WORKDIR/README.md $WORKDIR/dummy_file $WORKDIR/logs/access.log
    echo "[TODO : file $WORKDIR/README.md $WORKDIR/dummy_file $WORKDIR/logs/access.log]"

    echo ""
    # Vérification automatique
    echo "--- Vérification automatique ---"
    TAILLE=$(stat -c "%s" "$WORKDIR/dummy_file" 2>/dev/null || stat -f "%z" "$WORKDIR/dummy_file" 2>/dev/null)
    if [ -n "$TAILLE" ]; then
        echo "✓ dummy_file taille : $TAILLE octets (environ 512 Ko)"
    fi
    TYPE=$(file "$WORKDIR/README.md" 2>/dev/null)
    echo "✓ Type de README.md : $TYPE"
}

# 2.5 — Espace disque avec du et df
ex_5() {
    echo ""
    echo "=== Exercice 2.5 : Espace disque (du et df) ==="
    echo ""

    # TODO : Affichez l'espace disque disponible sur toutes les partitions
    echo "--- df -h (espace disque disponible) ---"
    df -h

    echo ""
    # TODO : Calculez la taille totale du répertoire de travail
    echo "--- Taille de WORKDIR ---"
    # TODO : du -sh $WORKDIR
    echo "[TODO : du -sh $WORKDIR]"

    echo ""
    # TODO : Affichez la taille de chaque sous-répertoire dans WORKDIR
    echo "--- Taille de chaque sous-répertoire ---"
    # TODO : du -sh $WORKDIR/*
    echo "[TODO : du -sh $WORKDIR/*]"

    echo ""
    # TODO : Trouvez le sous-répertoire le plus volumineux avec sort
    echo "--- Sous-répertoire le plus volumineux ---"
    # TODO : du -sh $WORKDIR/* | sort -rh | head -1
    echo "[TODO : du -sh $WORKDIR/* | sort -rh | head -1]"

    # Vérification automatique
    echo ""
    TAILLE_TOTALE=$(du -sh "$WORKDIR" 2>/dev/null | cut -f1)
    echo "✓ Taille totale de WORKDIR : $TAILLE_TOTALE"
}

main
