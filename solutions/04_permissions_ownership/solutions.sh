#!/usr/bin/env bash
# Solutions — Chapitre 4 : Permissions et ownership
# Exécutez : bash solutions.sh

WORKDIR="/tmp/sol_permissions_$$"

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

    echo "--- ls -l dans WORKDIR ---"
    ls -l
    echo ""

    echo "--- Réponses aux questions ---"
    echo ""
    echo "Q1 : Qui peut LIRE fichier_public.txt ? (permissions : 644 = rw-r--r--)"
    echo "     Réponse : Tout le monde (user, group, others) — r est actif pour les 3"
    echo ""
    echo "Q2 : Qui peut LIRE fichier_prive.txt ? (permissions : 600 = rw-------)"
    echo "     Réponse : Seulement le propriétaire (user) — group et others n'ont aucun droit"
    echo ""
    echo "Q3 : Qui peut ENTRER dans dossier_prive ? (permissions : 700 = rwx------)"
    echo "     Réponse : Seulement le propriétaire — x (exécution) = droit d'entrer (cd)"
    echo ""
    echo "Q4 : Valeur octale de -rwxr-xr-x ?"
    echo "     Réponse : r=4 w=2 x=1"
    echo "     user  : rwx = 4+2+1 = 7"
    echo "     group : r-x = 4+0+1 = 5"
    echo "     other : r-x = 4+0+1 = 5"
    echo "     → 755"

    echo ""
    echo "--- Vérification des permissions ---"
    for f in fichier_public.txt fichier_prive.txt script_exec.sh dossier_partage dossier_prive; do
        PERM=$(stat -c "%a" "$f" 2>/dev/null)
        echo "✓ $f : $PERM"
    done
}

# 4.2 — chmod
ex_2() {
    echo ""
    echo "=== Exercice 4.2 : chmod ==="
    echo ""

    cd "$WORKDIR" || return

    touch mon_script.sh ma_config.conf ma_cle.key rapport.pdf
    mkdir mon_projet

    echo "--- chmod notation octale ---"
    chmod 755 mon_script.sh
    echo "✓ chmod 755 mon_script.sh   → rwxr-xr-x"

    chmod 644 ma_config.conf
    echo "✓ chmod 644 ma_config.conf  → rw-r--r--"

    chmod 600 ma_cle.key
    echo "✓ chmod 600 ma_cle.key      → rw-------"

    chmod 400 rapport.pdf
    echo "✓ chmod 400 rapport.pdf     → r--------"

    echo ""
    echo "--- Vérification notation octale ---"
    ls -la mon_script.sh ma_config.conf ma_cle.key rapport.pdf

    echo ""
    echo "--- chmod notation symbolique ---"

    # Retirer le droit d'écriture groupe
    chmod g-w ma_config.conf
    echo "✓ chmod g-w ma_config.conf  → retire write pour group"

    # Ajouter exécution pour tous sur le répertoire
    chmod a+x mon_projet
    echo "✓ chmod a+x mon_projet      → ajoute exécution pour user/group/other"

    # Définir exactement u=rw,g=r,o= sur rapport.pdf
    chmod u=rw,g=r,o= rapport.pdf
    echo "✓ chmod u=rw,g=r,o= rapport.pdf → rw-r-----"

    echo ""
    echo "--- Vérification finale ---"
    ls -la mon_script.sh ma_config.conf ma_cle.key rapport.pdf mon_projet

    echo ""
    SCRIPT_PERM=$(stat -c "%a" mon_script.sh 2>/dev/null)
    CLE_PERM=$(stat -c "%a" ma_cle.key 2>/dev/null)
    [ "$SCRIPT_PERM" = "755" ] && echo "✓ mon_script.sh : 755" || echo "✗ mon_script.sh : $SCRIPT_PERM"
    [ "$CLE_PERM" = "600" ]    && echo "✓ ma_cle.key   : 600" || echo "✗ ma_cle.key : $CLE_PERM"

    echo ""
    echo "--- Cas pratique : chmod -R avec X majuscule ---"
    mkdir -p public/assets/images
    touch public/index.html public/assets/images/logo.png
    # Le X majuscule : active x seulement pour les répertoires
    chmod -R u=rwX,g=rX,o=rX public/
    echo "✓ chmod -R u=rwX,g=rX,o=rX public/"
    find public/ -exec ls -ld {} \;
}

# 4.3 — umask
ex_3() {
    echo ""
    echo "=== Exercice 4.3 : umask ==="
    echo ""

    cd "$WORKDIR" || return

    UMASK_COURANT=$(umask)
    echo "umask actuel : $UMASK_COURANT"

    echo ""
    echo "--- Calcul avec umask $UMASK_COURANT ---"
    # Calculer les permissions résultantes
    UMASK_DEC=$((8#$UMASK_COURANT))
    FILE_PERM=$((0666 & ~UMASK_DEC))
    DIR_PERM=$((0777 & ~UMASK_DEC))
    printf "Fichier    : 666 & ~%s = %o → " "$UMASK_COURANT" "$FILE_PERM"
    # Afficher la notation symbolique
    for oct in $(printf '%o' "$FILE_PERM" | sed 's/./& /g'); do
        case $oct in
            0) printf "---";;  1) printf "--x";;  2) printf "-w-";;  3) printf "-wx";;
            4) printf "r--";;  5) printf "r-x";;  6) printf "rw-";;  7) printf "rwx";;
        esac
    done
    echo ""
    printf "Répertoire : 777 & ~%s = %o → " "$UMASK_COURANT" "$DIR_PERM"
    for oct in $(printf '%o' "$DIR_PERM" | sed 's/./& /g'); do
        case $oct in
            0) printf "---";;  1) printf "--x";;  2) printf "-w-";;  3) printf "-wx";;
            4) printf "r--";;  5) printf "r-x";;  6) printf "rw-";;  7) printf "rwx";;
        esac
    done
    echo ""

    echo ""
    echo "--- Test avec umask 027 ---"
    (
        umask 027
        echo "  umask dans le sous-shell : $(umask)"
        touch fichier_027.txt
        mkdir dossier_027
        echo "  Fichier créé avec umask 027 :"
        ls -la fichier_027.txt
        ls -ld dossier_027
        PERM=$(stat -c "%a" fichier_027.txt 2>/dev/null)
        echo "  fichier_027.txt : $PERM (666 - 027 = 640 → rw-r-----)"
        PERM_DIR=$(stat -c "%a" dossier_027 2>/dev/null)
        echo "  dossier_027     : $PERM_DIR (777 - 027 = 750 → rwxr-x---)"
    )

    echo ""
    echo "--- Explication umask 027 ---"
    echo "  Fichier    : 666 - 027 = 640 (rw-r-----)"
    echo "  Répertoire : 777 - 027 = 750 (rwxr-x---)"
    echo "  → Groupe peut lire (mais pas écrire), autres n'ont aucun droit"

    umask "$UMASK_COURANT"
    echo ""
    echo "✓ umask restauré à : $(umask)"
}

# 4.4 — Bits spéciaux
ex_4() {
    echo ""
    echo "=== Exercice 4.4 : Bits spéciaux ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- Fichiers SUID sur le système ---"
    echo "find /usr/bin -perm -4000 -type f 2>/dev/null | head -5"
    find /usr/bin -perm -4000 -type f 2>/dev/null | head -5

    echo ""
    echo "--- Analyse de /usr/bin/passwd ---"
    PASSWD_PATH=$(which passwd 2>/dev/null)
    if [ -n "$PASSWD_PATH" ]; then
        ls -l "$PASSWD_PATH"
        echo ""
        echo "Explication du SUID sur passwd :"
        echo "  /etc/shadow contient les mots de passe hachés avec permissions 640 (root:shadow)"
        echo "  Un utilisateur normal (non-root) ne peut pas écrire dans /etc/shadow"
        echo "  Grâce au SUID, passwd s'exécute avec les droits de root (le propriétaire)"
        echo "  → Il peut modifier /etc/shadow même si l'appelant est un utilisateur normal"
        echo "  → C'est un exemple de design sécurisé : accès limité, contrôlé, auditable"
    fi

    echo ""
    echo "--- Sticky bit sur répertoire partagé ---"
    mkdir -p "$WORKDIR/partage"
    chmod +t "$WORKDIR/partage"
    ls -ld "$WORKDIR/partage"
    echo "→ Le 't' final indique le sticky bit"
    echo "→ Chaque utilisateur ne peut supprimer QUE ses propres fichiers"

    echo ""
    echo "--- SGID sur répertoire d'équipe ---"
    mkdir -p "$WORKDIR/projet_equipe"
    chmod g+s "$WORKDIR/projet_equipe"
    ls -ld "$WORKDIR/projet_equipe"
    echo "→ Le 's' sur le groupe indique le SGID"
    echo "→ Tout nouveau fichier créé ici héritera du groupe du répertoire"

    echo ""
    echo "--- Récapitulatif bits spéciaux ---"
    echo "  SUID  (4xxx) : exécuter avec les droits du propriétaire"
    echo "  SGID  (2xxx) : groupe hérité pour les nouveaux fichiers du dossier"
    echo "  Sticky(1xxx) : seul le propriétaire peut supprimer son fichier"

    echo ""
    STICKY=$(stat -c "%a" "$WORKDIR/partage" 2>/dev/null)
    SGID=$(stat -c "%a" "$WORKDIR/projet_equipe" 2>/dev/null)
    [[ "$STICKY" == 1* ]] && echo "✓ Sticky bit actif ($STICKY)" || echo "⚠ Sticky : $STICKY"
    [[ "$SGID" == 2* ]]   && echo "✓ SGID actif ($SGID)" || echo "⚠ SGID : $SGID"
}

# 4.5 — Infos utilisateur et groupes
ex_5() {
    echo ""
    echo "=== Exercice 4.5 : Utilisateurs et groupes ==="
    echo ""

    echo "--- Vos informations complètes (id) ---"
    id
    echo ""
    echo "  Décomposition :"
    echo "  uid=$(id -u) = UID numérique"
    echo "  gid=$(id -g) = GID du groupe principal"
    echo "  groups = tous les groupes auxquels vous appartenez"

    echo ""
    echo "--- Vos groupes (groups) ---"
    groups

    echo ""
    echo "--- Votre entrée dans /etc/passwd ---"
    grep "^$(whoami):" /etc/passwd
    echo ""
    echo "  Format : nom:x:uid:gid:commentaire:home:shell"
    echo "  (le 'x' signifie que le mot de passe est dans /etc/shadow)"

    echo ""
    echo "--- Membres du groupe sudo/wheel ---"
    getent group sudo 2>/dev/null || getent group wheel 2>/dev/null || \
        echo "(groupe sudo/wheel non trouvé avec getent)"
    echo ""
    echo "  Alternative : grep '^sudo' /etc/group"
    grep "^sudo" /etc/group 2>/dev/null || grep "^wheel" /etc/group 2>/dev/null || true

    echo ""
    echo "--- Permissions de /etc/shadow ---"
    ls -la /etc/shadow 2>/dev/null || echo "(non lisible sans sudo — normal !)"
    echo ""
    echo "  /etc/shadow est protégé pour éviter les attaques par force brute"
    echo "  Seul root peut le lire directement"

    echo ""
    echo "--- Comment ajouter un utilisateur à un groupe ---"
    echo "  sudo usermod -aG docker \$USER"
    echo "  sudo usermod -aG sudo \$USER"
    echo "  (déconnecter/reconnecter pour que les changements prennent effet)"
    echo "  Ou immédiatement : newgrp nom_groupe"

    echo ""
    UID_COURANT=$(id -u)
    GID_COURANT=$(id -g)
    NOM_USER=$(whoami)
    NB_GROUPES=$(id -G | tr ' ' '\n' | wc -l)
    echo "✓ Utilisateur : $NOM_USER (UID=$UID_COURANT, GID=$GID_COURANT)"
    echo "✓ Nombre de groupes : $NB_GROUPES"
}

main
