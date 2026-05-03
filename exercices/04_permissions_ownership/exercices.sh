#!/usr/bin/env bash
# Exercices — Chapitre 4 : Permissions et ownership
# Exécutez : bash exercices.sh
#
# NOTE : Certains exercices nécessitent sudo (chown).
#        Ces parties seront marquées [NÉCESSITE SUDO].
#        Vous pouvez les tester séparément.
#
# Objectifs :
#   - Lire et interpréter les permissions Unix
#   - Utiliser chmod (notation octale et symbolique)
#   - Comprendre umask
#   - Créer des scripts avec les bonnes permissions
#   - Explorer les bits spéciaux (SUID, SGID, sticky)

WORKDIR="/tmp/exo_permissions_$$"

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

# 4.1 — Lire les permissions
ex_1() {
    echo "=== Exercice 4.1 : Lire et interpréter les permissions ==="
    echo ""

    cd "$WORKDIR" || return

    # Créer des fichiers avec différentes permissions
    touch fichier_public.txt
    touch fichier_prive.txt
    touch script_exec.sh
    mkdir dossier_partage
    mkdir dossier_prive

    chmod 644 fichier_public.txt
    chmod 600 fichier_prive.txt
    chmod 755 script_exec.sh
    chmod 755 dossier_partage
    chmod 700 dossier_prive

    # TODO : Listez ces fichiers avec ls -l et interprétez chaque ligne
    echo "--- ls -l dans WORKDIR ---"
    ls -l
    echo ""

    # TODO : Répondez aux questions suivantes (sur papier ou dans un commentaire) :
    echo "--- Questions d'analyse ---"
    echo "Q1 : Qui peut LIRE fichier_public.txt ?"
    echo "     [Réponse : TODO]"
    echo ""
    echo "Q2 : Qui peut LIRE fichier_prive.txt ?"
    echo "     [Réponse : TODO]"
    echo ""
    echo "Q3 : Qui peut ENTRER dans dossier_prive ?"
    echo "     [Réponse : TODO]"
    echo ""
    echo "Q4 : Quelle est la valeur octale de -rwxr-xr-x ?"
    echo "     [Réponse : TODO (indice : rwx=7, r-x=5, r-x=5)]"

    # Vérification
    echo ""
    echo "--- Vérification des permissions créées ---"
    for f in fichier_public.txt fichier_prive.txt script_exec.sh dossier_partage dossier_prive; do
        PERM=$(stat -c "%a %n" "$f" 2>/dev/null || stat -f "%p %N" "$f" 2>/dev/null | awk '{printf "%o %s\n", $1 % 1000, $2}')
        echo "✓ $f : $PERM"
    done
}

# 4.2 — chmod (notation octale et symbolique)
ex_2() {
    echo ""
    echo "=== Exercice 4.2 : chmod ==="
    echo ""

    cd "$WORKDIR" || return

    touch mon_script.sh
    touch ma_config.conf
    touch ma_cle.key
    touch rapport.pdf
    mkdir mon_projet

    # TODO : Appliquez les permissions suivantes avec chmod en notation OCTALE
    echo "--- chmod notation octale ---"
    echo "mon_script.sh  → rwxr-xr-x (755) : [TODO : chmod 755 mon_script.sh]"
    chmod 755 mon_script.sh  # solution

    echo "ma_config.conf → rw-r--r-- (644) : [TODO : chmod 644 ma_config.conf]"
    chmod 644 ma_config.conf  # solution

    echo "ma_cle.key     → rw------- (600) : [TODO : chmod 600 ma_cle.key]"
    chmod 600 ma_cle.key  # solution

    echo "rapport.pdf    → r-------- (400) : [TODO : chmod 400 rapport.pdf]"
    chmod 400 rapport.pdf  # solution

    echo ""
    echo "--- chmod notation symbolique ---"
    # TODO : Appliquez ces changements avec notation SYMBOLIQUE
    echo "Retirez le droit d'écriture groupe sur ma_config.conf :"
    echo "[TODO : chmod g-w ma_config.conf]"

    echo "Ajoutez le droit d'exécution pour tous sur mon_projet :"
    echo "[TODO : chmod a+x mon_projet]"
    chmod a+x mon_projet  # solution

    echo "Définissez exactement u=rw,g=r,o= sur rapport.pdf :"
    echo "[TODO : chmod u=rw,g=r,o= rapport.pdf]"
    chmod u=rw,g=r,o= rapport.pdf  # solution

    # Vérification
    echo ""
    echo "--- Vérification ---"
    declare -A EXPECTED=(
        ["mon_script.sh"]="755"
        ["ma_cle.key"]="600"
    )

    SCRIPT_PERM=$(stat -c "%a" mon_script.sh 2>/dev/null || stat -f "%p" mon_script.sh 2>/dev/null | awk '{printf "%o\n", $1 % 1000}')
    CLE_PERM=$(stat -c "%a" ma_cle.key 2>/dev/null || stat -f "%p" ma_cle.key 2>/dev/null | awk '{printf "%o\n", $1 % 1000}')

    [ "$SCRIPT_PERM" = "755" ] && echo "✓ mon_script.sh : 755" || echo "✗ mon_script.sh : attendu 755, obtenu $SCRIPT_PERM"
    [ "$CLE_PERM" = "600" ]    && echo "✓ ma_cle.key   : 600" || echo "✗ ma_cle.key   : attendu 600, obtenu $CLE_PERM"
}

# 4.3 — umask
ex_3() {
    echo ""
    echo "=== Exercice 4.3 : umask ==="
    echo ""

    cd "$WORKDIR" || return

    # Afficher le umask actuel
    UMASK_COURANT=$(umask)
    echo "umask actuel : $UMASK_COURANT"
    echo ""

    # TODO : Calculez les permissions résultantes pour ce umask
    echo "--- Calcul avec umask $UMASK_COURANT ---"
    echo "Fichier    : 666 - umask = [TODO : calculez]"
    echo "Répertoire : 777 - umask = [TODO : calculez]"
    echo ""

    # TODO : Changez le umask à 027 et créez un fichier
    echo "--- Test avec umask 027 ---"
    echo "[TODO : umask 027]"
    (
        umask 027
        touch fichier_027.txt
        mkdir dossier_027
        echo "Avec umask 027 :"
        ls -la fichier_027.txt dossier_027
        # Que remarquez-vous sur les permissions ?
    )

    echo ""
    # TODO : Calculez : avec umask 027, quelles sont les permissions de fichier_027.txt ?
    echo "Question : avec umask 027 :"
    echo "  - Un fichier aura les permissions : [TODO]  (666 - 027 = ?)"
    echo "  - Un répertoire aura les permissions : [TODO] (777 - 027 = ?)"

    # Vérification
    echo ""
    echo "--- Vérification ---"
    PERM_027=$(stat -c "%a" fichier_027.txt 2>/dev/null)
    if [ "$PERM_027" = "640" ]; then
        echo "✓ fichier_027.txt : 640 (rw-r-----) — correct pour umask 027"
    else
        echo "→ fichier_027.txt : $PERM_027 (umask = $UMASK_COURANT)"
    fi

    # Restaurer le umask original
    umask "$UMASK_COURANT"
    echo "umask restauré à : $(umask)"
}

# 4.4 — Bits spéciaux
ex_4() {
    echo ""
    echo "=== Exercice 4.4 : Bits spéciaux (SUID, SGID, sticky bit) ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Vérifiez les fichiers SUID présents sur le système
    echo "--- Fichiers SUID sur le système ---"
    echo "[TODO : find /usr/bin -perm -4000 -type f 2>/dev/null | head -5]"
    find /usr/bin -perm -4000 -type f 2>/dev/null | head -5

    echo ""
    # TODO : Expliquez le SUID sur /usr/bin/passwd
    echo "--- Analyser /usr/bin/passwd ---"
    ls -l /usr/bin/passwd 2>/dev/null || ls -l /bin/passwd 2>/dev/null || echo "passwd introuvable"
    echo "Question : Pourquoi /usr/bin/passwd a-t-il le bit SUID ?"
    echo "[Réponse : TODO — que se passe-t-il quand un utilisateur change son mot de passe ?]"

    echo ""
    # TODO : Créez un répertoire partagé avec le sticky bit
    mkdir -p "$WORKDIR/partage"
    echo "[TODO : chmod +t $WORKDIR/partage]"
    chmod +t "$WORKDIR/partage"  # solution

    echo "--- Vérifier le sticky bit ---"
    ls -ld "$WORKDIR/partage"

    echo ""
    # TODO : Créez un répertoire avec SGID (pour que les nouveaux fichiers héritent du groupe)
    mkdir -p "$WORKDIR/projet_equipe"
    echo "[TODO : chmod g+s $WORKDIR/projet_equipe]"
    chmod g+s "$WORKDIR/projet_equipe"  # solution

    echo "--- Vérifier le SGID ---"
    ls -ld "$WORKDIR/projet_equipe"

    # Vérification
    echo ""
    STICKY=$(stat -c "%a" "$WORKDIR/partage" 2>/dev/null)
    SGID=$(stat -c "%a" "$WORKDIR/projet_equipe" 2>/dev/null)

    [[ "$STICKY" == 1* ]] && echo "✓ Sticky bit actif sur partage/ (octal : $STICKY)" || echo "⚠ Sticky bit : $STICKY"
    [[ "$SGID" == 2* ]]   && echo "✓ SGID actif sur projet_equipe/ (octal : $SGID)"   || echo "⚠ SGID : $SGID"
}

# 4.5 — Infos utilisateur et groupes
ex_5() {
    echo ""
    echo "=== Exercice 4.5 : Utilisateurs et groupes ==="
    echo ""

    # TODO : Affichez vos informations complètes avec id
    echo "--- Vos informations (id) ---"
    id
    echo ""

    # TODO : Listez tous vos groupes avec groups
    echo "--- Vos groupes ---"
    groups
    echo ""

    # TODO : Cherchez votre entrée dans /etc/passwd
    echo "--- Entrée dans /etc/passwd ---"
    echo "[TODO : grep \"^$(whoami)\" /etc/passwd]"
    grep "^$(whoami)" /etc/passwd 2>/dev/null || echo "Utilisateur non trouvé dans /etc/passwd"

    echo ""
    # TODO : Listez les membres du groupe sudo (ou wheel sur RHEL)
    echo "--- Membres du groupe sudo/wheel ---"
    echo "[TODO : getent group sudo || getent group wheel]"
    getent group sudo 2>/dev/null || getent group wheel 2>/dev/null || echo "Groupe sudo/wheel non trouvé"

    echo ""
    # TODO : Identifiez le propriétaire et groupe de /etc/shadow
    echo "--- Permissions de /etc/shadow ---"
    ls -la /etc/shadow 2>/dev/null || echo "/etc/shadow non accessible (normal sans sudo)"

    # Vérification
    echo ""
    UID_COURANT=$(id -u)
    GID_COURANT=$(id -g)
    NOM_USER=$(whoami)
    echo "✓ Utilisateur courant : $NOM_USER (UID=$UID_COURANT, GID=$GID_COURANT)"
    NB_GROUPES=$(id -G | tr ' ' '\n' | wc -l)
    echo "✓ Nombre de groupes : $NB_GROUPES"
}

main
