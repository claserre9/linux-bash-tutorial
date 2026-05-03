#!/bin/bash
# =============================================================================
# Solutions — Chapitre 12 : Regex avancées
# =============================================================================

# --- Solution 1 ---
# Pattern email : user@domaine.tld
# [a-zA-Z0-9._%+-]+ : partie locale (lettres, chiffres, ._%+-)
# @ : arobase
# [a-zA-Z0-9.-]+ : domaine
# \.[a-zA-Z]{2,} : extension (min 2 lettres)
ex_1() {
    local texte="Contactez alice@example.com ou support@my-company.org pour info@invalid. Pas_un_email ni @sansnom.fr"
    echo "--- Exercice 1 : extraire les emails ---"
    echo "$texte" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    # alice@example.com
    # support@my-company.org
    # (info@invalid n'a pas d'extension valide, mais ici le point final du texte peut poser pb)
}

# --- Solution 2 ---
# IPv4 : 4 octets séparés par des points
# Chaque octet : 0-255
#   25[0-5]         = 250-255
#   2[0-4][0-9]     = 200-249
#   [01]?[0-9][0-9]? = 0-199
ex_2() {
    echo "--- Exercice 2 : valider des IPs ---"
    local ips=("192.168.1.1" "256.0.0.1" "10.0.0.255" "0.0.0.0" "999.999.999.999" "172.16.254.1")
    local octet='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
    local pattern="^${octet}\.${octet}\.${octet}\.${octet}$"

    for ip in "${ips[@]}"; do
        if echo "$ip" | grep -qE "$pattern"; then
            echo "$ip : valide"
        else
            echo "$ip : invalide"
        fi
    done
    # 192.168.1.1      : valide
    # 256.0.0.1        : invalide
    # 10.0.0.255       : valide
    # 0.0.0.0          : valide
    # 999.999.999.999  : invalide
    # 172.16.254.1     : valide
}

# --- Solution 3 ---
# sed ERE : groupes capturants pour réorganiser les parties de la date
# Groupe 1 : année ([0-9]{4})
# Groupe 2 : mois ([0-9]{2})
# Groupe 3 : jour ([0-9]{2})
# → \3/\2/\1 = JJ/MM/AAAA
ex_3() {
    echo "--- Exercice 3 : reformater des dates ---"
    local dates="Événement du 2024-01-15 au 2024-03-31. Rapport du 2023-12-25."
    echo "$dates" | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/g'
    # Événement du 15/01/2024 au 31/03/2024. Rapport du 25/12/2023.
}

# --- Solution 4 ---
# grep -P avec lookbehind pour capturer les valeurs de href= et src=
# (?<=href=") ou (?<=src=") : lookbehind positif
# [^"]+ : tout sauf guillemet
# Alternative : pattern avec alternation dans le lookbehind
ex_4() {
    echo "--- Exercice 4 : extraire les URLs ---"
    local html='<a href="https://example.com/page">lien</a>
<img src="/images/logo.png" alt="logo">
<script src="https://cdn.example.com/app.js"></script>
<link rel="stylesheet" href="/css/style.css">'

    echo "$html" | grep -oP '(?<=href="|src=")[^"]+'
    # https://example.com/page
    # /images/logo.png
    # https://cdn.example.com/app.js
    # /css/style.css
}

# --- Solution 5 ---
# awk : le dernier champ ($NF) est la durée en ms
# Filtrer les lignes où $NF > 1000
# Extraire : $1 (IP), $7 (path dans les guillemets), $NF (durée)
ex_5() {
    echo "--- Exercice 5 : parser un log ---"
    local log_data='192.168.1.1 - - [15/Jan/2024:10:22:01] "GET /api/users HTTP/1.1" 200 1234 145
10.0.0.5 - - [15/Jan/2024:10:22:05] "POST /api/orders HTTP/1.1" 201 567 2543
192.168.1.1 - - [15/Jan/2024:10:22:10] "GET /static/logo.png HTTP/1.1" 200 45678 23
172.16.0.1 - - [15/Jan/2024:10:22:15] "DELETE /api/cache HTTP/1.1" 204 0 3210
10.0.0.5 - - [15/Jan/2024:10:22:20] "GET /health HTTP/1.1" 200 12 8'

    echo "$log_data" | awk '$NF > 1000 {
        # $1 = IP, $7 = path (entre guillemets), $NF = durée
        gsub(/"/, "", $7)
        printf "IP: %-15s  Path: %-25s  Durée: %sms\n", $1, $7, $NF
    }'
    # IP: 10.0.0.5         Path: /api/orders             Durée: 2543ms
    # IP: 172.16.0.1       Path: /api/cache              Durée: 3210ms
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 12 — Regex avancées : Solutions"
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
