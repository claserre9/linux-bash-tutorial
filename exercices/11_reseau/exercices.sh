#!/usr/bin/env bash
# Exercices — Chapitre 11 : Réseau

# REMARQUE : Certains exercices nécessitent une connexion Internet.
# En environnement hors-ligne, les résultats pourront différer.
# Les commandes curl/ping utilisent des serveurs publics.

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Exercice 11.1 — ping et connectivité ==="
    echo "Objectif : Écrire des fonctions de test de connectivité"
    echo ""

    # TODO : Écrire une fonction tester_connectivite() qui :
    # - Prend une liste de hosts en arguments
    # - Pour chacun, fait un ping -c 2 -W 3
    # - Affiche "✓ OK" ou "✗ HORS LIGNE" selon le résultat
    # - Retourne le nombre d'hôtes injoignables

    tester_connectivite() {
        local hors_ligne=0
        # TODO : boucle sur "$@", ping -c 2 -W 3, afficher le résultat
        echo "(TODO : implémenter la boucle de ping)"
        return "$hors_ligne"
    }

    echo "Test de connectivité :"
    tester_connectivite 8.8.8.8 1.1.1.1 192.168.99.254
    echo "Hôtes injoignables : $?"

    echo ""
    echo "--- Comportement attendu ---"
    echo "✓ OK         8.8.8.8 (DNS Google)"
    echo "✓ OK         1.1.1.1 (DNS Cloudflare)"
    echo "✗ HORS LIGNE 192.168.99.254 (probablement inexistant)"
    echo "Hôtes injoignables : 1"
}

ex_2() {
    echo ""
    echo "=== Exercice 11.2 — curl et API ==="
    echo "Objectif : Interroger une API JSON publique"
    echo ""

    # L'API JSONPlaceholder est gratuite et sans authentification
    API="https://jsonplaceholder.typicode.com"

    # TODO 1 : Récupérer l'utilisateur ID 3 et afficher son nom et email
    echo "1) Utilisateur ID 3 :"
    # TODO : curl -s "$API/users/3" | (traiter avec jq ou grep/sed/awk)
    echo "(TODO : curl + extraction du nom et email)"

    echo ""
    echo "--- Référence ---"
    if command -v curl &>/dev/null; then
        data=$(curl -s --max-time 5 "$API/users/3" 2>/dev/null)
        if [[ -n "$data" ]]; then
            if command -v jq &>/dev/null; then
                echo "Nom   : $(echo "$data" | jq -r '.name')"
                echo "Email : $(echo "$data" | jq -r '.email')"
            else
                echo "Réponse brute (installer jq pour un meilleur affichage) :"
                echo "$data" | grep -E '"name"|"email"' | head -2
            fi
        else
            echo "(Pas de connexion Internet ou API indisponible)"
        fi
    fi

    echo ""
    # TODO 2 : Vérifier le code HTTP de plusieurs URLs
    echo "2) Vérifier les codes HTTP de ces URLs :"
    urls=(
        "https://jsonplaceholder.typicode.com/posts/1"
        "https://jsonplaceholder.typicode.com/posts/999"
        "https://httpstat.us/503"
    )

    for url in "${urls[@]}"; do
        # TODO : curl -s -o /dev/null -w "%{http_code}" "$url"
        echo "  $url → (TODO)"
    done

    echo ""
    echo "--- Référence ---"
    echo "  posts/1   → 200 (existe)"
    echo "  posts/999 → 404 (n'existe pas)"
    echo "  503       → 503 (Service Unavailable)"
}

ex_3() {
    echo ""
    echo "=== Exercice 11.3 — SSH et configuration ==="
    echo "Objectif : Comprendre la configuration SSH et les tunnels"
    echo ""

    echo "1) Écrire une entrée ~/.ssh/config pour ce serveur :"
    echo "   Alias     : 'prod'"
    echo "   Hôte réel : prod.exemple.com"
    echo "   User      : deploy"
    echo "   Port      : 2222"
    echo "   Clé       : ~/.ssh/id_prod"
    echo "   KeepAlive : ServerAliveInterval 30"
    echo ""
    echo "Votre entrée config (écrivez-la ici en commentaire) :"
    echo "# TODO :"
    echo "#"
    echo "#"

    echo ""
    echo "--- Référence ---"
    cat << 'EOF'
Host prod
    HostName prod.exemple.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_prod
    ServerAliveInterval 30
    ServerAliveCountMax 3
EOF

    echo ""
    echo "2) Expliquer ces commandes SSH :"
    echo "   a) ssh -L 8080:localhost:80 user@serveur"
    echo "   TODO : explication"
    echo ""
    echo "   b) ssh -R 9090:localhost:3000 user@serveur"
    echo "   TODO : explication"
    echo ""
    echo "   c) ssh -J bastion.example.com user@serveur-interne"
    echo "   TODO : explication"
    echo ""
    echo "--- Explications ---"
    echo "   a) Tunnel local : accéder au port 80 du serveur via localhost:8080"
    echo "   b) Tunnel distant : exposer le port local 3000 comme port 9090 sur le serveur"
    echo "   c) ProxyJump : se connecter à serveur-interne en rebondissant via bastion"
}

ex_4() {
    echo ""
    echo "=== Exercice 11.4 — rsync ==="
    echo "Objectif : Comprendre les options rsync et le slash final"
    echo ""

    # Créer une structure de test
    local src="/tmp/rsync_src_$$"
    local dst="/tmp/rsync_dst_$$"
    mkdir -p "$src/sous_dossier"
    echo "fichier1" > "$src/fichier1.txt"
    echo "fichier2" > "$src/fichier2.txt"
    echo "sous" > "$src/sous_dossier/fichier3.txt"
    echo "log content" > "$src/debug.log"
    mkdir -p "$dst"

    echo "Structure source créée dans $src"
    echo ""

    echo "1) Synchro AVEC slash final (copie le contenu) :"
    echo "   rsync -av $src/ $dst/avec_slash/"
    # TODO : exécuter la commande et afficher la structure résultante
    rsync -av "$src/" "$dst/avec_slash/" 2>/dev/null
    echo "Résultat : $(find "$dst/avec_slash" -type f 2>/dev/null | sort)"

    echo ""
    echo "2) Synchro SANS slash final (copie le dossier lui-même) :"
    echo "   rsync -av $src $dst/sans_slash/"
    # TODO : exécuter et afficher
    rsync -av "$src" "$dst/sans_slash/" 2>/dev/null
    echo "Résultat : $(find "$dst/sans_slash" -type f 2>/dev/null | sort)"

    echo ""
    echo "3) Synchro avec exclusion des fichiers .log :"
    # TODO : utiliser --exclude="*.log"
    echo "   (TODO : commande rsync avec --exclude)"
    rsync -av --exclude="*.log" "$src/" "$dst/sans_logs/" 2>/dev/null
    echo "Résultat : $(find "$dst/sans_logs" -type f 2>/dev/null | sort)"

    echo ""
    echo "4) Dry-run — que ferait --delete ?"
    # TODO : rsync avec --dry-run et --delete
    echo "   (TODO : commande rsync --dry-run --delete)"

    # Nettoyage
    rm -rf "$src" "$dst"
    echo ""
    echo "Nettoyage effectué"
}

ex_5() {
    echo ""
    echo "=== Exercice 11.5 — Analyseur de logs (projet fil rouge) ==="
    echo "Objectif : Analyser un fichier de log Apache/Nginx"
    echo ""

    # Créer un fichier de log de test
    local logfile="/tmp/access_test_$$.log"
    cat > "$logfile" << 'EOF'
192.168.1.10 - - [02/May/2024:10:00:01 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
192.168.1.20 - - [02/May/2024:10:00:02 +0000] "POST /api/login HTTP/1.1" 200 567 "-" "curl/7.68.0"
192.168.1.10 - - [02/May/2024:10:00:05 +0000] "GET /api/users HTTP/1.1" 403 89 "-" "Mozilla/5.0"
10.0.0.1 - - [02/May/2024:10:00:10 +0000] "GET /admin HTTP/1.1" 404 123 "-" "python-requests/2.28"
192.168.1.10 - - [02/May/2024:10:01:00 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "Mozilla/5.0"
192.168.1.30 - - [02/May/2024:11:00:01 +0000] "GET /static/app.js HTTP/1.1" 200 45678 "-" "Mozilla/5.0"
10.0.0.1 - - [02/May/2024:11:30:00 +0000] "GET /wp-login.php HTTP/1.1" 404 123 "-" "python-requests/2.28"
10.0.0.1 - - [02/May/2024:11:30:01 +0000] "POST /xmlrpc.php HTTP/1.1" 404 89 "-" "python-requests/2.28"
192.168.1.20 - - [02/May/2024:12:00:00 +0000] "GET /dashboard HTTP/1.1" 200 3456 "-" "Mozilla/5.0"
192.168.1.10 - - [02/May/2024:14:00:00 +0000] "DELETE /api/users/5 HTTP/1.1" 403 45 "-" "curl/7.68.0"
EOF

    echo "Fichier de log de test : $logfile"
    echo ""

    # TODO 1 : Afficher le nombre total de requêtes
    echo "1) Nombre total de requêtes : (TODO)"
    # Référence : wc -l < "$logfile"

    # TODO 2 : Afficher le top 3 des IPs
    echo "2) Top 3 des IPs :"
    # Référence : awk '{print $1}' | sort | uniq -c | sort -rn | head -3

    # TODO 3 : Distribution des codes HTTP
    echo "3) Distribution des codes HTTP :"
    # Référence : awk '{print $9}' | sort | uniq -c | sort -rn

    # TODO 4 : Toutes les requêtes avec une erreur 4xx
    echo "4) Requêtes avec erreur 4xx :"
    # Référence : awk '$9 ~ /^4/ {print $1, $7, $9}'

    # TODO 5 : Nombre d'octets transférés au total (somme du champ 10)
    echo "5) Total octets transférés : (TODO)"
    # Référence : awk '{sum += $10} END {print sum " octets"}'

    echo ""
    echo "--- Références ---"
    echo "1) $(wc -l < "$logfile") requêtes"
    echo "2) Top 3 IPs :"
    awk '{print $1}' "$logfile" | sort | uniq -c | sort -rn | head -3 | awk '{printf "   %d req : %s\n", $1, $2}'
    echo "3) Codes HTTP :"
    awk '{print $9}' "$logfile" | sort | uniq -c | sort -rn | awk '{printf "   %s : %d req\n", $2, $1}'
    echo "4) Erreurs 4xx :"
    awk '$9 ~ /^4/ {printf "   %s %s %s\n", $1, $7, $9}' "$logfile"
    echo "5) $(awk '{sum += $10} END {print sum}' "$logfile") octets transférés"

    # Nettoyage
    rm -f "$logfile"
}

main
