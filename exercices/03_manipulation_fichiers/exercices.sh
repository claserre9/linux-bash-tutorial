#!/usr/bin/env bash
# Exercices — Chapitre 3 : Manipulation de fichiers
# Exécutez : bash exercices.sh
#
# Objectifs :
#   - Créer des fichiers et répertoires avec touch et mkdir -p
#   - Utiliser cp (avec options), mv, rm de façon sûre
#   - Lire des fichiers avec cat, head, tail
#   - Créer des liens symboliques avec ln -s
#   - Utiliser les wildcards et la brace expansion

WORKDIR="/tmp/exo_fichiers_$$"

setup() {
    mkdir -p "$WORKDIR"
    echo "Espace de travail créé : $WORKDIR"
    cd "$WORKDIR" || exit 1
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

# 3.1 — touch, mkdir, brace expansion
ex_1() {
    echo "=== Exercice 3.1 : Créer une arborescence de projet ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Créez l'arborescence suivante EN UNE SEULE commande mkdir avec -p et {}
    # projet/
    # ├── src/
    # │   ├── utils/
    # │   └── models/
    # ├── tests/
    # ├── docs/
    # └── config/
    echo "--- Créer l'arborescence (une seule commande) ---"
    echo "[TODO : mkdir -p projet/{src/{utils,models},tests,docs,config}]"

    echo ""
    # TODO : Créez ces fichiers dans les bons répertoires avec touch
    # projet/README.md, projet/src/main.py, projet/config/settings.conf
    echo "--- Créer les fichiers ---"
    echo "[TODO : touch projet/README.md projet/src/main.py projet/config/settings.conf]"

    echo ""
    # TODO : Créez 5 fichiers de logs numérotés avec brace expansion
    # log_1.txt, log_2.txt, ..., log_5.txt dans projet/
    echo "--- Créer les logs avec brace expansion ---"
    echo "[TODO : touch projet/log_{1..5}.txt]"

    # Solution de référence pour les vérifications suivantes
    mkdir -p "projet/{src/{utils,models},tests,docs,config}" 2>/dev/null || \
    mkdir -p projet/src/utils projet/src/models projet/tests projet/docs projet/config
    touch projet/README.md projet/src/main.py projet/config/settings.conf
    touch projet/log_{1..5}.txt

    # Vérifications
    echo ""
    DIRS=("projet/src/utils" "projet/src/models" "projet/tests" "projet/docs" "projet/config")
    ALL_OK=true
    for dir in "${DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "✓ $dir existe"
        else
            echo "✗ $dir manquant"
            ALL_OK=false
        fi
    done

    NB_LOGS=$(ls projet/log_*.txt 2>/dev/null | wc -l)
    if [ "$NB_LOGS" -eq 5 ]; then
        echo "✓ 5 fichiers log créés"
    else
        echo "✗ Attendu 5 logs, trouvé : $NB_LOGS"
    fi
}

# 3.2 — cp, mv, rm
ex_2() {
    echo ""
    echo "=== Exercice 3.2 : Copier, déplacer, supprimer ==="
    echo ""

    cd "$WORKDIR" || return

    # Préparation
    echo "Fichier source original" > source.txt
    echo "Config importante" > important.conf
    mkdir -p backup

    # TODO : Copiez source.txt en source_backup.txt EN PRÉSERVANT les métadonnées (-p)
    echo "--- Copie avec préservation ---"
    echo "[TODO : cp -p source.txt source_backup.txt]"
    cp -p source.txt source_backup.txt  # solution

    # TODO : Copiez important.conf dans backup/ avec sauvegarde automatique (--backup=numbered)
    echo ""
    echo "--- Copie avec backup numéroté ---"
    cp important.conf backup/
    echo "[TODO : cp --backup=numbered important.conf backup/important.conf]"
    cp --backup=numbered important.conf backup/important.conf  # solution

    # TODO : Renommez source.txt en source_v1.txt
    echo ""
    echo "--- Renommage ---"
    echo "[TODO : mv source.txt source_v1.txt]"
    mv source.txt source_v1.txt  # solution

    # TODO : Créez des fichiers temporaires et supprimez-les avec un wildcard
    touch temp_{1..3}.tmp
    echo ""
    echo "--- Suppression par wildcard ---"
    ls *.tmp
    echo "[TODO : rm *.tmp]"
    rm *.tmp  # solution

    # Vérifications
    echo ""
    [ -f "source_backup.txt" ] && echo "✓ source_backup.txt existe" || echo "✗ source_backup.txt manquant"
    [ -f "source_v1.txt" ]     && echo "✓ source_v1.txt existe"     || echo "✗ source_v1.txt manquant"
    [ ! -f "source.txt" ]      && echo "✓ source.txt renommé"       || echo "⚠ source.txt toujours présent"
    [ $(ls *.tmp 2>/dev/null | wc -l) -eq 0 ] && echo "✓ Fichiers .tmp supprimés" || echo "✗ Des .tmp restent"
}

# 3.3 — cat, head, tail
ex_3() {
    echo ""
    echo "=== Exercice 3.3 : Lire des fichiers ==="
    echo ""

    cd "$WORKDIR" || return

    # Créer un fichier de log simulé (50 lignes)
    for i in $(seq 1 50); do
        echo "2024-01-$(printf '%02d' $((i % 28 + 1))) INFO ligne $i du journal" >> journal.log
    done
    echo "2024-01-28 ERROR problème critique détecté" >> journal.log
    echo "2024-01-28 WARN avertissement important" >> journal.log
    echo "Fichier journal.log créé (52 lignes)"

    # TODO : Affichez les 10 premières lignes de journal.log
    echo ""
    echo "--- 10 premières lignes ---"
    echo "[TODO : head -10 journal.log]"

    # TODO : Affichez les 5 dernières lignes
    echo ""
    echo "--- 5 dernières lignes ---"
    echo "[TODO : tail -5 journal.log]"

    # TODO : Affichez les lignes 20 à 25 (hint : head + tail ou sed)
    echo ""
    echo "--- Lignes 20 à 25 ---"
    echo "[TODO : head -25 journal.log | tail -6]"

    # TODO : Comptez le nombre de lignes ERROR dans le journal
    echo ""
    echo "--- Nombre d'erreurs ---"
    echo "[TODO : grep -c 'ERROR' journal.log]"

    # Vérifications
    echo ""
    NB_LIGNES=$(wc -l < journal.log)
    NB_ERREURS=$(grep -c "ERROR" journal.log)
    echo "✓ journal.log : $NB_LIGNES lignes, $NB_ERREURS erreur(s)"
}

# 3.4 — Liens symboliques
ex_4() {
    echo ""
    echo "=== Exercice 3.4 : Liens symboliques ==="
    echo ""

    cd "$WORKDIR" || return

    # Créer un fichier cible
    echo "Je suis la configuration principale" > config_prod.conf
    mkdir -p /tmp/exo_liens_$$
    LIENS_DIR="/tmp/exo_liens_$$"

    # TODO : Créez un lien symbolique 'config.conf' pointant vers config_prod.conf
    echo "--- Créer un lien symbolique ---"
    echo "[TODO : ln -s $WORKDIR/config_prod.conf config.conf]"
    ln -s "$WORKDIR/config_prod.conf" config.conf  # solution

    # TODO : Vérifiez le lien avec ls -la et readlink
    echo ""
    echo "--- Vérifier le lien ---"
    echo "[TODO : ls -la config.conf]"
    ls -la config.conf
    echo "[TODO : readlink config.conf]"

    # TODO : Lisez le contenu via le lien symbolique
    echo ""
    echo "--- Lire via le lien ---"
    echo "[TODO : cat config.conf]"

    # TODO : Créez un lien dur vers config_prod.conf
    echo ""
    echo "--- Lien dur ---"
    echo "[TODO : ln config_prod.conf config_dur.conf]"
    ln config_prod.conf config_dur.conf  # solution

    # Vérifications
    echo ""
    if [ -L config.conf ]; then
        CIBLE=$(readlink config.conf)
        echo "✓ Lien symbolique config.conf → $CIBLE"
    else
        echo "✗ config.conf n'est pas un lien symbolique"
    fi

    if [ -f config_dur.conf ]; then
        INODE_SRC=$(stat -c "%i" config_prod.conf 2>/dev/null || stat -f "%i" config_prod.conf)
        INODE_DUR=$(stat -c "%i" config_dur.conf 2>/dev/null || stat -f "%i" config_dur.conf)
        if [ "$INODE_SRC" = "$INODE_DUR" ]; then
            echo "✓ Lien dur : même inode ($INODE_SRC)"
        fi
    fi

    rm -rf "$LIENS_DIR"
}

# 3.5 — wc, diff, wildcards avancés
ex_5() {
    echo ""
    echo "=== Exercice 3.5 : wc, diff et wildcards ==="
    echo ""

    cd "$WORKDIR" || return

    # Créer deux fichiers à comparer
    cat > version1.txt << 'HEREDOC'
Bonjour le monde
Ceci est la version 1
Une ligne commune
La fin
HEREDOC

    cat > version2.txt << 'HEREDOC'
Bonjour le monde
Ceci est la version 2 (modifiée)
Une ligne commune
Un ajout
La fin
HEREDOC

    # TODO : Comparez version1.txt et version2.txt avec diff -u
    echo "--- diff -u version1 vs version2 ---"
    echo "[TODO : diff -u version1.txt version2.txt]"

    echo ""
    # TODO : Comptez les lignes, mots et caractères de version1.txt avec wc
    echo "--- wc sur version1.txt ---"
    echo "[TODO : wc version1.txt]"

    echo ""
    # TODO : Utilisez des wildcards pour lister uniquement les .txt commençant par 'version'
    echo "--- Wildcards : fichiers version*.txt ---"
    echo "[TODO : ls version*.txt]"

    # TODO : Avec la brace expansion, copiez version1.txt et version2.txt dans backup/
    # en une seule commande
    echo ""
    echo "--- Copie avec brace expansion ---"
    echo "[TODO : cp version{1,2}.txt backup/]"
    cp version1.txt version2.txt backup/ 2>/dev/null || true  # solution

    # Vérifications
    echo ""
    NB_DIFF=$(diff version1.txt version2.txt | grep "^[<>]" | wc -l)
    echo "✓ Différences entre version1 et version2 : $NB_DIFF ligne(s) modifiée(s)"
    NB_MOTS=$(wc -w < version1.txt)
    echo "✓ version1.txt : $NB_MOTS mots"
    [ -f "backup/version1.txt" ] && [ -f "backup/version2.txt" ] \
        && echo "✓ Les deux versions copiées dans backup/" \
        || echo "⚠ Copie dans backup/ à compléter"
}

main
