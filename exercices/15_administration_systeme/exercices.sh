#!/bin/bash
# =============================================================================
# Exercices — Chapitre 15 : Administration système
# =============================================================================
# ATTENTION : certains exercices nécessitent des droits sudo.
# Ceux-ci sont marqués [SUDO REQUIS]. Sur un système personnel ou en VM.
# Les exercices de lecture (sans sudo) peuvent être exécutés librement.
# Complétez chaque fonction en remplaçant les '???' par votre code.
# =============================================================================

# --- Exercice 1 ---
# Inspecter les utilisateurs du système (lecture seule, sans sudo).
# 1. Afficher les 5 premiers utilisateurs de /etc/passwd (sans les système, UID >= 1000)
# 2. Afficher votre propre UID et GID
# 3. Afficher tous vos groupes
# 4. Compter le nombre total d'utilisateurs dans /etc/passwd
ex_1() {
    echo "--- Exercice 1 : inspection des utilisateurs ---"

    # 1. Utilisateurs avec UID >= 1000 (non-système)
    echo "Utilisateurs non-système :"
    awk -F: ??? /etc/passwd

    # 2. Votre UID et GID
    echo "UID : ???"
    echo "GID : ???"

    # 3. Vos groupes
    echo "Mes groupes : ???"

    # 4. Nombre total d'utilisateurs
    echo "Total utilisateurs : ???"
}

# --- Exercice 2 ---
# Surveiller l'utilisation du système.
# 1. Afficher la mémoire totale, utilisée et libre
# 2. Afficher le top 5 des processus par utilisation mémoire
# 3. Afficher le load average (charge)
# 4. Afficher l'espace disque pour les partitions montées
ex_2() {
    echo "--- Exercice 2 : surveillance système ---"

    # 1. Mémoire (utiliser free)
    echo "=== Mémoire ==="
    free -h | ???    # Afficher seulement les lignes Mem et Swap

    # 2. Top 5 processus par mémoire
    echo ""
    echo "=== Top 5 processus (mémoire) ==="
    ps aux --sort=-??? | head -6 | ???   # Trier par %MEM, afficher USER PID %CPU %MEM COMMAND

    # 3. Load average
    echo ""
    echo "=== Charge système ==="
    uptime | ???   # Extraire la partie "load average"

    # 4. Espace disque
    echo ""
    echo "=== Espace disque ==="
    df -h | grep -v ???   # Exclure les pseudo-filesystems (tmpfs, devtmpfs, udev)
}

# --- Exercice 3 ---
# Analyser les logs système.
# 1. Afficher les 10 dernières entrées de syslog (ou journalctl)
# 2. Compter les occurrences d'erreurs SSH (si auth.log existe)
# 3. Afficher les services systemd actifs en échec (si systemctl disponible)
# 4. Afficher les 5 derniers boots (si journalctl disponible)
ex_3() {
    echo "--- Exercice 3 : analyse des logs ---"

    # 1. Dernières entrées syslog (adapter selon le système)
    echo "=== Dernières entrées syslog ==="
    if [[ -f /var/log/syslog ]]; then
        tail -10 ???
    elif command -v journalctl &>/dev/null; then
        journalctl -n 10 ???   # Sans pager
    fi

    # 2. Erreurs d'authentification
    echo ""
    echo "=== Erreurs SSH/auth ==="
    if [[ -f /var/log/auth.log ]]; then
        grep -c "Failed\|Invalid" /var/log/auth.log 2>/dev/null || echo "0 erreurs"
    else
        echo "Fichier auth.log non accessible"
    fi

    # 3. Services en échec
    echo ""
    echo "=== Services en échec ==="
    if command -v systemctl &>/dev/null; then
        systemctl list-units --state=??? --no-legend 2>/dev/null || echo "Aucun service en échec"
    fi

    # 4. Historique des boots
    echo ""
    echo "=== Historique des boots ==="
    if command -v journalctl &>/dev/null; then
        journalctl --list-boots 2>/dev/null | ???   # 5 derniers boots
    fi
}

# --- Exercice 4 ---
# Analyser les packages installés et les services.
# 1. Compter le nombre de packages installés (apt/dpkg)
# 2. Afficher les 5 packages les plus récemment installés
# 3. Trouver quel package fournit la commande 'bash'
# 4. Lister les services systemd activés au démarrage
ex_4() {
    echo "--- Exercice 4 : packages et services ---"

    # 1. Nombre de packages installés
    if command -v dpkg &>/dev/null; then
        echo "Packages installés : ???"   # dpkg -l | compter les lignes ii
    fi

    # 2. Packages récemment installés
    echo ""
    echo "5 packages récents :"
    if [[ -f /var/log/dpkg.log ]]; then
        grep "status installed" /var/log/dpkg.log | ??? | tail -5
    else
        echo "dpkg.log non disponible"
    fi

    # 3. Quel package fournit bash ?
    echo ""
    if command -v dpkg &>/dev/null; then
        echo "Package fournissant bash : ???"   # dpkg -S $(which bash)
    fi

    # 4. Services activés au démarrage
    echo ""
    echo "Services activés au boot (extrait) :"
    if command -v systemctl &>/dev/null; then
        systemctl list-unit-files --type=service --state=??? --no-legend 2>/dev/null | head -10
    fi
}

# --- Exercice 5 ---
# Script de rapport système : agréger les informations clés.
# Écrire une fonction qui génère un rapport concis avec :
#   - Hostname et OS
#   - Uptime et load average
#   - Mémoire (utilisée/totale)
#   - Espace disque (partitions > 50%)
#   - Nombre de processus en cours
#   - Connexions réseau actives
ex_5() {
    echo "--- Exercice 5 : rapport système ---"

    generer_rapport() {
        echo "========================================"
        echo "  RAPPORT SYSTÈME — $(date '+%Y-%m-%d %H:%M:%S')"
        echo "========================================"

        # Hostname et OS
        echo ""
        echo "SYSTÈME"
        echo "  Hostname : $(hostname)"
        echo "  OS       : ???"   # /etc/os-release ou uname

        # Uptime et charge
        echo ""
        echo "PERFORMANCE"
        echo "  Uptime   : $(uptime -p 2>/dev/null || uptime)"
        echo "  Load     : ???"   # Extraire load average

        # Mémoire
        echo ""
        echo "MÉMOIRE"
        free -h | awk '/^Mem:/ {printf "  Totale: %s  |  Utilisée: %s  |  Libre: %s\n", $2, $3, $4}'

        # Disques
        echo ""
        echo "DISQUES (partitions > 50%)"
        df -h | awk 'NR>1 && $1 !~ /tmpfs|udev/ {
            gsub(/%/, "", $5)
            if (???) printf "  %-20s %5s%% utilisé (libre: %s)\n", $6, $5, $4
        }'

        # Processus
        echo ""
        echo "PROCESSUS"
        echo "  Total : ???"   # ps aux | wc -l - 1

        # Connexions réseau
        echo ""
        echo "RÉSEAU"
        echo "  Connexions établies : ???"   # ss -t state established | wc -l - 1
    }

    generer_rapport
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 15 — Administration système : Exercices"
    echo "============================================="
    echo ""
    ex_1; echo ""
    ex_2; echo ""
    ex_3; echo ""
    ex_4; echo ""
    ex_5; echo ""
    echo "Exercices terminés."
}

main
