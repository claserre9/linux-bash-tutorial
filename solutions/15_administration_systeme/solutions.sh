#!/bin/bash
# =============================================================================
# Solutions — Chapitre 15 : Administration système
# =============================================================================

# --- Solution 1 ---
ex_1() {
    echo "--- Exercice 1 : inspection des utilisateurs ---"

    # 1. UID >= 1000 = utilisateurs non-système
    echo "Utilisateurs non-système :"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print "  " $1 " (UID=" $3 ")"}' /etc/passwd | head -5

    # 2. id retourne les infos de l'utilisateur courant
    echo "UID : $(id -u)"
    echo "GID : $(id -g)"

    # 3. groups ou id -Gn
    echo "Mes groupes : $(groups)"

    # 4. Nombre de lignes dans /etc/passwd
    echo "Total utilisateurs : $(wc -l < /etc/passwd)"
}

# --- Solution 2 ---
ex_2() {
    echo "--- Exercice 2 : surveillance système ---"

    echo "=== Mémoire ==="
    # grep pour garder seulement Mem et Swap
    free -h | grep -E "^(Mem|Swap):"

    echo ""
    echo "=== Top 5 processus (mémoire) ==="
    # --sort=-%mem : tri décroissant par %MEM
    # awk pour sélectionner les colonnes pertinentes
    ps aux --sort=-%mem | head -6 | awk 'NR==1 {print "  " $1, $2, $3, $4, $11; next} {printf "  %-12s %6s %5s%% %5s%% %s\n", $1, $2, $3, $4, $11}'

    echo ""
    echo "=== Charge système ==="
    # uptime | awk extrait la partie après "load average:"
    uptime | awk -F'load average:' '{print "  Load average:" $2}'

    echo ""
    echo "=== Espace disque ==="
    # Exclure tmpfs, devtmpfs, udev (pseudo-filesystems)
    df -h | grep -v -E "^(tmpfs|devtmpfs|udev|Filesystem)"
}

# --- Solution 3 ---
ex_3() {
    echo "--- Exercice 3 : analyse des logs ---"

    echo "=== Dernières entrées syslog ==="
    if [[ -f /var/log/syslog ]]; then
        tail -10 /var/log/syslog
    elif command -v journalctl &>/dev/null; then
        # --no-pager évite l'appel à less
        journalctl -n 10 --no-pager
    fi

    echo ""
    echo "=== Erreurs SSH/auth ==="
    if [[ -f /var/log/auth.log ]]; then
        local count
        count=$(grep -c "Failed\|Invalid" /var/log/auth.log 2>/dev/null) || count=0
        echo "$count tentatives échouées"
    else
        echo "Fichier auth.log non accessible"
    fi

    echo ""
    echo "=== Services en échec ==="
    if command -v systemctl &>/dev/null; then
        # --state=failed : seulement les services en état failed
        systemctl list-units --state=failed --no-legend 2>/dev/null || echo "Aucun service en échec"
    fi

    echo ""
    echo "=== Historique des boots ==="
    if command -v journalctl &>/dev/null; then
        journalctl --list-boots 2>/dev/null | tail -5
    fi
}

# --- Solution 4 ---
ex_4() {
    echo "--- Exercice 4 : packages et services ---"

    if command -v dpkg &>/dev/null; then
        # dpkg -l : liste tous les packages, ii = installé
        echo "Packages installés : $(dpkg -l | grep -c "^ii")"
    fi

    echo ""
    echo "5 packages récents :"
    if [[ -f /var/log/dpkg.log ]]; then
        # Extraire le nom du package depuis les lignes "status installed"
        grep "status installed" /var/log/dpkg.log | awk '{print $5}' | tail -5
    else
        echo "dpkg.log non disponible"
    fi

    echo ""
    if command -v dpkg &>/dev/null; then
        # dpkg -S : quel package fournit ce fichier
        echo "Package fournissant bash : $(dpkg -S "$(which bash)" 2>/dev/null | cut -d: -f1)"
    fi

    echo ""
    echo "Services activés au boot (extrait) :"
    if command -v systemctl &>/dev/null; then
        # --state=enabled : seulement les services activés au démarrage
        systemctl list-unit-files --type=service --state=enabled --no-legend 2>/dev/null | head -10
    fi
}

# --- Solution 5 ---
ex_5() {
    echo "--- Exercice 5 : rapport système ---"

    generer_rapport() {
        echo "========================================"
        echo "  RAPPORT SYSTÈME — $(date '+%Y-%m-%d %H:%M:%S')"
        echo "========================================"

        echo ""
        echo "SYSTÈME"
        echo "  Hostname : $(hostname)"
        # /etc/os-release contient NAME et VERSION_ID
        if [[ -f /etc/os-release ]]; then
            echo "  OS       : $(. /etc/os-release && echo "$NAME $VERSION_ID")"
        else
            echo "  OS       : $(uname -s) $(uname -r)"
        fi

        echo ""
        echo "PERFORMANCE"
        echo "  Uptime   : $(uptime -p 2>/dev/null || uptime | awk '{print $3, $4}' | tr -d ',')"
        # /proc/loadavg : "load1 load5 load15 procs uptime_ticks"
        echo "  Load     : $(cat /proc/loadavg | awk '{print "1min=" $1, "5min=" $2, "15min=" $3}')"

        echo ""
        echo "MÉMOIRE"
        free -h | awk '/^Mem:/ {printf "  Totale: %s  |  Utilisée: %s  |  Libre: %s\n", $2, $3, $4}'

        echo ""
        echo "DISQUES (partitions > 50%)"
        df -h | awk 'NR>1 && $1 !~ /tmpfs|udev|devtmpfs/ {
            gsub(/%/, "", $5)
            if ($5+0 > 50) printf "  %-20s %5s%% utilisé (libre: %s)\n", $6, $5, $4
        }'

        echo ""
        echo "PROCESSUS"
        # ps aux donne un header + les processus
        echo "  Total : $(($(ps aux | wc -l) - 1))"

        echo ""
        echo "RÉSEAU"
        if command -v ss &>/dev/null; then
            # ss -t state established liste les connexions TCP établies
            echo "  Connexions établies : $(($(ss -t state established | wc -l) - 1))"
        else
            echo "  ss non disponible"
        fi
    }

    generer_rapport
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 15 — Administration système : Solutions"
    echo "============================================="
    echo ""
    ex_1; echo ""
    ex_2; echo ""
    ex_3; echo ""
    ex_4; echo ""
    ex_5; echo ""
    echo "Solutions terminées."
}

main
