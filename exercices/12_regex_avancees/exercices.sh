#!/bin/bash
# =============================================================================
# Exercices — Chapitre 12 : Regex avancées
# =============================================================================
# Complétez chaque fonction en remplaçant les '???' par votre code.
# Testez avec : bash exercices.sh
# =============================================================================

# --- Exercice 1 ---
# Extraire les adresses email valides d'un texte.
# Entrée : une chaîne de texte contenant plusieurs mots et emails
# Sortie : une adresse email par ligne
# Utilisez grep -oE avec un pattern approprié.
ex_1() {
    local texte="Contactez alice@example.com ou support@my-company.org pour info@invalid. Pas_un_email ni @sansnom.fr"
    echo "--- Exercice 1 : extraire les emails ---"
    # Votre code ici
    echo "$texte" | grep -oE ???
}

# --- Exercice 2 ---
# Valider des adresses IPv4 et afficher "valide" ou "invalide".
# Entrée : tableau d'adresses IP
# Sortie : "IP : valide" ou "IP : invalide"
# Rappel : chaque octet est entre 0 et 255
ex_2() {
    echo "--- Exercice 2 : valider des IPs ---"
    local ips=("192.168.1.1" "256.0.0.1" "10.0.0.255" "0.0.0.0" "999.999.999.999" "172.16.254.1")
    local pattern=???

    for ip in "${ips[@]}"; do
        if echo "$ip" | grep -qE "$pattern"; then
            echo "$ip : valide"
        else
            echo "$ip : invalide"
        fi
    done
}

# --- Exercice 3 ---
# Reformater des dates ISO en format français avec sed.
# Entrée : fichier (simulé) avec des dates AAAA-MM-JJ
# Sortie : même contenu avec dates au format JJ/MM/AAAA
ex_3() {
    echo "--- Exercice 3 : reformater des dates ---"
    local dates="Événement du 2024-01-15 au 2024-03-31. Rapport du 2023-12-25."
    echo "$dates" | sed -E ???
    # Attendu : Événement du 15/01/2024 au 31/03/2024. Rapport du 25/12/2023.
}

# --- Exercice 4 ---
# Extraire les URLs d'un fichier HTML (href="..." et src="...").
# Utilisez grep -oP avec lookahead/lookbehind.
ex_4() {
    echo "--- Exercice 4 : extraire les URLs ---"
    local html='<a href="https://example.com/page">lien</a>
<img src="/images/logo.png" alt="logo">
<script src="https://cdn.example.com/app.js"></script>
<link rel="stylesheet" href="/css/style.css">'

    echo "$html" | grep -oP ???
    # Attendu : une URL par ligne (https://example.com/page, /images/logo.png, etc.)
}

# --- Exercice 5 ---
# Parser un log Apache/Nginx et extraire les requêtes lentes (>1000ms).
# Format de log : IP - - [date] "METHOD /path HTTP/1.1" code taille durée_ms
# Utilisez awk avec regex pour filtrer et extraire les infos pertinentes.
ex_5() {
    echo "--- Exercice 5 : parser un log ---"
    local log_data='192.168.1.1 - - [15/Jan/2024:10:22:01] "GET /api/users HTTP/1.1" 200 1234 145
10.0.0.5 - - [15/Jan/2024:10:22:05] "POST /api/orders HTTP/1.1" 201 567 2543
192.168.1.1 - - [15/Jan/2024:10:22:10] "GET /static/logo.png HTTP/1.1" 200 45678 23
172.16.0.1 - - [15/Jan/2024:10:22:15] "DELETE /api/cache HTTP/1.1" 204 0 3210
10.0.0.5 - - [15/Jan/2024:10:22:20] "GET /health HTTP/1.1" 200 12 8'

    echo "$log_data" | awk ???
    # Attendu : afficher IP, path et durée pour les requêtes dont durée > 1000ms
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo "============================================="
    echo "Chapitre 12 — Regex avancées : Exercices"
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
