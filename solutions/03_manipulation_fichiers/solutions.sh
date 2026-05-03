#!/usr/bin/env bash
# Solutions — Chapitre 3 : Manipulation de fichiers
# Exécutez : bash solutions.sh

WORKDIR="/tmp/sol_fichiers_$$"

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

    # Créer l'arborescence en une seule commande
    mkdir -p projet/{src/{utils,models},tests,docs,config}
    echo "✓ Arborescence créée avec : mkdir -p projet/{src/{utils,models},tests,docs,config}"

    # Créer les fichiers
    touch projet/README.md projet/src/main.py projet/config/settings.conf
    echo "✓ Fichiers de base créés"

    # Créer 5 logs avec brace expansion
    touch projet/log_{1..5}.txt
    echo "✓ Logs créés : $(ls projet/log_*.txt)"

    # Afficher le résultat
    echo ""
    echo "--- Arborescence finale ---"
    if command -v tree &>/dev/null; then
        tree projet/
    else
        find projet/ | sort | sed 's|[^/]*/|  |g'
    fi

    # Vérifications
    echo ""
    DIRS=("projet/src/utils" "projet/src/models" "projet/tests" "projet/docs" "projet/config")
    for dir in "${DIRS[@]}"; do
        [ -d "$dir" ] && echo "✓ $dir" || echo "✗ $dir manquant"
    done
    NB_LOGS=$(ls projet/log_*.txt 2>/dev/null | wc -l)
    echo "✓ $NB_LOGS fichiers log créés"
}

# 3.2 — cp, mv, rm
ex_2() {
    echo ""
    echo "=== Exercice 3.2 : Copier, déplacer, supprimer ==="
    echo ""

    cd "$WORKDIR" || return

    echo "Fichier source original" > source.txt
    echo "Config importante" > important.conf
    mkdir -p backup

    # Copie avec préservation des métadonnées
    cp -p source.txt source_backup.txt
    echo "✓ cp -p source.txt source_backup.txt"
    echo "  Vérif métadonnées :"
    ls -la source.txt source_backup.txt

    # Copie avec backup numéroté
    cp important.conf backup/
    cp --backup=numbered important.conf backup/important.conf
    echo ""
    echo "✓ cp --backup=numbered important.conf backup/important.conf"
    echo "  Fichiers dans backup/ :"
    ls -la backup/

    # Renommage
    mv source.txt source_v1.txt
    echo ""
    echo "✓ mv source.txt source_v1.txt"
    ls -la source_v1.txt

    # Suppression par wildcard
    touch temp_{1..3}.tmp
    echo ""
    echo "Fichiers .tmp créés : $(ls *.tmp)"
    rm *.tmp
    echo "✓ rm *.tmp — fichiers supprimés"
    ls *.tmp 2>/dev/null || echo "  (aucun .tmp restant)"

    # Vérifications finales
    echo ""
    [ -f "source_backup.txt" ] && echo "✓ source_backup.txt existe" || echo "✗ manquant"
    [ -f "source_v1.txt" ]     && echo "✓ source_v1.txt existe" || echo "✗ manquant"
    [ ! -f "source.txt" ]      && echo "✓ source.txt renommé" || echo "⚠ source.txt toujours présent"
}

# 3.3 — cat, head, tail
ex_3() {
    echo ""
    echo "=== Exercice 3.3 : Lire des fichiers ==="
    echo ""

    cd "$WORKDIR" || return

    # Créer le fichier de log (52 lignes)
    for i in $(seq 1 50); do
        echo "2024-01-$(printf '%02d' $((i % 28 + 1))) INFO ligne $i du journal" >> journal.log
    done
    echo "2024-01-28 ERROR problème critique détecté" >> journal.log
    echo "2024-01-28 WARN avertissement important" >> journal.log

    NB=$(wc -l < journal.log)
    echo "journal.log créé : $NB lignes"

    echo ""
    echo "--- 10 premières lignes ---"
    head -10 journal.log

    echo ""
    echo "--- 5 dernières lignes ---"
    tail -5 journal.log

    echo ""
    echo "--- Lignes 20 à 25 (méthode 1 : head + tail) ---"
    head -25 journal.log | tail -6

    echo ""
    echo "--- Lignes 20 à 25 (méthode 2 : sed) ---"
    sed -n '20,25p' journal.log

    echo ""
    echo "--- Nombre d'erreurs ---"
    NB_ERR=$(grep -c "ERROR" journal.log)
    echo "Erreurs trouvées : $NB_ERR"

    echo ""
    echo "--- Suivi en temps réel (simulation) ---"
    echo "(tail -f journal.log → utilisez Ctrl+C pour arrêter)"
    echo "En script : tail -F /var/log/syslog"

    echo ""
    echo "✓ journal.log : $NB lignes, $NB_ERR erreur(s)"
}

# 3.4 — Liens symboliques
ex_4() {
    echo ""
    echo "=== Exercice 3.4 : Liens symboliques ==="
    echo ""

    cd "$WORKDIR" || return

    echo "Je suis la configuration principale" > config_prod.conf

    # Lien symbolique
    ln -s "$WORKDIR/config_prod.conf" config.conf
    echo "✓ Lien symbolique créé : ln -s config_prod.conf config.conf"

    echo ""
    echo "--- ls -la config.conf ---"
    ls -la config.conf

    echo ""
    echo "--- readlink ---"
    echo "Cible : $(readlink config.conf)"
    echo "Chemin absolu : $(readlink -f config.conf)"

    echo ""
    echo "--- Lecture via le lien ---"
    cat config.conf

    # Lien dur
    ln config_prod.conf config_dur.conf
    echo ""
    echo "✓ Lien dur créé : ln config_prod.conf config_dur.conf"

    echo ""
    echo "--- Comparaison inodes ---"
    ls -lai config_prod.conf config_dur.conf config.conf

    # Vérifications
    echo ""
    if [ -L config.conf ]; then
        echo "✓ config.conf est bien un lien symbolique → $(readlink config.conf)"
    fi

    INODE_SRC=$(stat -c "%i" config_prod.conf 2>/dev/null || stat -f "%i" config_prod.conf)
    INODE_DUR=$(stat -c "%i" config_dur.conf 2>/dev/null || stat -f "%i" config_dur.conf)
    if [ "$INODE_SRC" = "$INODE_DUR" ]; then
        echo "✓ Lien dur : même inode ($INODE_SRC)"
    fi

    # Démonstration : modification visible via le lien
    echo ""
    echo "--- Modification visible via le lien ---"
    echo "Nouvelle ligne ajoutée" >> config_prod.conf
    echo "Contenu via lien symbolique :"
    cat config.conf
}

# 3.5 — wc, diff, wildcards
ex_5() {
    echo ""
    echo "=== Exercice 3.5 : wc, diff et wildcards ==="
    echo ""

    cd "$WORKDIR" || return

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

    echo "--- wc sur version1.txt ---"
    wc version1.txt
    echo "  (lignes mots caractères)"
    wc -l version1.txt   # lignes
    wc -w version1.txt   # mots
    wc -c version1.txt   # octets

    echo ""
    echo "--- diff -u version1 vs version2 ---"
    diff -u version1.txt version2.txt
    echo "(code retour diff : $?  — 0=identiques, 1=différents)"

    echo ""
    echo "--- diff côte à côte ---"
    diff -y --width=70 version1.txt version2.txt

    echo ""
    echo "--- Wildcards ---"
    echo "Fichiers version*.txt : $(ls version*.txt)"
    echo "Fichiers *.txt : $(ls *.txt 2>/dev/null | tr '\n' ' ')"

    echo ""
    echo "--- Brace expansion : copie dans backup/ ---"
    mkdir -p backup
    cp version{1,2}.txt backup/
    echo "Contenu de backup/ : $(ls backup/)"

    # Vérifications
    echo ""
    NB_DIFF=$(diff version1.txt version2.txt | grep "^[<>]" | wc -l)
    echo "✓ Différences : $NB_DIFF ligne(s)"
    NB_MOTS=$(wc -w < version1.txt)
    echo "✓ Mots dans version1.txt : $NB_MOTS"
    [ -f "backup/version1.txt" ] && [ -f "backup/version2.txt" ] \
        && echo "✓ Deux versions copiées dans backup/" \
        || echo "✗ Copie incomplète"
}

main
