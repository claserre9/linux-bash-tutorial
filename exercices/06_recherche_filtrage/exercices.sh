#!/usr/bin/env bash
# Exercices — Chapitre 6 : Recherche et filtrage
# Exécutez : bash exercices.sh
#
# Objectifs :
#   - Utiliser grep avec ses options avancées
#   - Maîtriser find avec critères de taille, date, type
#   - Combiner find + xargs pour des opérations en masse
#   - Analyser des fichiers de logs réalistes
#   - Utiliser locate et which

WORKDIR="/tmp/exo_recherche_$$"

setup() {
    mkdir -p "$WORKDIR"
    cd "$WORKDIR" || exit 1

    # Créer une arborescence de projet simulée
    mkdir -p app/{src/{utils,models,views},tests,config,logs}
    mkdir -p data/{raw,processed}

    # Fichiers source
    cat > app/src/main.py << 'EOF'
#!/usr/bin/env python3
"""Module principal de l'application."""
import os
import sys

# TODO: améliorer la gestion des erreurs
DEBUG = False
API_KEY = "sk-test-123abc"  # TODO: utiliser une variable d'environnement

def main():
    """Point d'entrée principal."""
    print("Démarrage de l'application")
    # TODO: implémenter la logique principale
    pass

if __name__ == "__main__":
    main()
EOF

    cat > app/src/utils/helpers.py << 'EOF'
"""Fonctions utilitaires."""
import re

def validate_email(email):
    """Valide un email."""
    pattern = r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$'
    return bool(re.match(pattern, email, re.IGNORECASE))

# TODO: ajouter validation URL
# TODO: ajouter validation IP
def format_date(date_str):
    pass
EOF

    cat > app/src/models/user.py << 'EOF'
"""Modèle utilisateur."""

class User:
    def __init__(self, name, email, password):
        self.name = name
        self.email = email
        self.password = password  # FIXME: hacher le mot de passe !

    def save(self):
        # TODO: implémenter la persistance
        pass
EOF

    cat > app/config/settings.conf << 'EOF'
# Configuration principale
HOST=localhost
PORT=8080
DEBUG=false
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=admin
DB_PASS=secret123
# TODO: chiffrer les mots de passe
EOF

    # Fichiers de logs simulés
    generate_log() {
        local filename=$1
        local nb_lines=$2
        for i in $(seq 1 "$nb_lines"); do
            local level
            local r=$((RANDOM % 10))
            if [ "$r" -lt 7 ]; then level="INFO"
            elif [ "$r" -lt 9 ]; then level="WARNING"
            else level="ERROR"
            fi
            local ip="192.168.$((RANDOM % 5 + 1)).$((RANDOM % 254 + 1))"
            echo "2024-01-$(printf '%02d' $((i % 28 + 1))) $(printf '%02d' $((i % 24))):$(printf '%02d' $((RANDOM % 60))):$(printf '%02d' $((RANDOM % 60))) [$level] $ip GET /api/endpoint_$((RANDOM % 5)) HTTP/1.1 $((RANDOM % 3 == 0 ? 404 : (RANDOM % 10 == 0 ? 500 : 200)))" >> "$filename"
        done
    }

    generate_log "app/logs/access.log" 100
    generate_log "app/logs/error.log" 30
    echo "2024-01-28 23:59:59 [ERROR] 10.0.0.1 Connection refused: database unreachable" >> app/logs/error.log
    echo "2024-01-29 00:00:01 [ERROR] 10.0.0.2 Timeout after 30s" >> app/logs/error.log

    # Fichiers temporaires
    touch app/src/utils/cache_{1..5}.tmp
    touch data/raw/data_{jan,fev,mar}.csv
    touch data/processed/clean_{jan,fev,mar}.csv

    # Fichiers anciens simulés
    touch -d "40 days ago" app/logs/old_access.log 2>/dev/null || \
        touch -t "$(date -d '40 days ago' +%Y%m%d%H%M 2>/dev/null || date -v-40d +%Y%m%d%H%M 2>/dev/null || echo '202312010000')" app/logs/old_access.log 2>/dev/null || \
        touch app/logs/old_access.log

    # Créer un fichier volumineux
    dd if=/dev/zero of=data/raw/big_dataset.bin bs=1024 count=2048 2>/dev/null

    echo "Environnement de travail créé dans : $WORKDIR"
    echo "Structure :"
    find . -type f | sed 's|^./||' | sort
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

# 6.1 — grep de base et options
ex_1() {
    echo "=== Exercice 6.1 : grep — recherche dans les fichiers source ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Trouvez tous les "TODO" dans les fichiers Python (récursif)
    echo "--- Tous les TODO dans les .py ---"
    echo "[TODO : grep -r 'TODO' app/src/]"
    grep -r "TODO" app/src/

    echo ""
    # TODO : Affichez les TODO avec numéros de ligne ET noms de fichiers
    echo "--- TODO avec numéros de ligne ---"
    echo "[TODO : grep -rn 'TODO' app/src/]"
    grep -rn "TODO" app/src/

    echo ""
    # TODO : Trouvez les fichiers contenant "FIXME" (seulement les noms)
    echo "--- Fichiers contenant FIXME ---"
    echo "[TODO : grep -rl 'FIXME' app/]"
    grep -rl "FIXME" app/

    echo ""
    # TODO : Cherchez "password" ou "secret" (insensible à la casse, regex étendue)
    echo "--- Données sensibles (password|secret) ---"
    echo "[TODO : grep -rEi 'password|secret' app/config/]"
    grep -rEi "password|secret" app/config/

    echo ""
    # TODO : Affichez 2 lignes de contexte autour de chaque ERROR dans error.log
    echo "--- ERRORs avec contexte (2 lignes) ---"
    echo "[TODO : grep -C 2 'ERROR' app/logs/error.log | head -20]"
    grep -C 2 "ERROR" app/logs/error.log | head -20

    # Vérification
    echo ""
    NB_TODO=$(grep -r "TODO" app/src/ | wc -l)
    echo "✓ Nombre de TODO dans app/src/ : $NB_TODO"
}

# 6.2 — find avec critères avancés
ex_2() {
    echo ""
    echo "=== Exercice 6.2 : find — recherche par critères ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Trouvez tous les fichiers Python dans app/
    echo "--- Tous les fichiers .py ---"
    echo "[TODO : find app/ -name '*.py' -type f]"
    find app/ -name "*.py" -type f

    echo ""
    # TODO : Trouvez les fichiers de plus de 1 Mo
    echo "--- Fichiers de plus de 1 Mo ---"
    echo "[TODO : find . -type f -size +1M]"
    find . -type f -size +1M

    echo ""
    # TODO : Trouvez les fichiers .tmp dans le projet
    echo "--- Fichiers temporaires (.tmp) ---"
    echo "[TODO : find . -name '*.tmp' -type f]"
    find . -name "*.tmp" -type f

    echo ""
    # TODO : Trouvez les répertoires vides
    echo "--- Répertoires vides ---"
    echo "[TODO : find . -type d -empty]"
    find . -type d -empty

    echo ""
    # TODO : Trouvez les fichiers modifiés dans les 10 dernières minutes
    echo "--- Fichiers récemment modifiés ---"
    echo "[TODO : find . -type f -mmin -10]"
    find . -type f -mmin -10

    echo ""
    # TODO : Combinez : fichiers .log de plus de 100 octets
    echo "--- Logs non vides ---"
    echo "[TODO : find app/logs -name '*.log' -size +100c -type f]"
    find app/logs -name "*.log" -size +100c -type f

    # Vérification
    echo ""
    NB_PY=$(find app/ -name "*.py" -type f | wc -l)
    NB_TMP=$(find . -name "*.tmp" | wc -l)
    echo "✓ Fichiers Python trouvés : $NB_PY"
    echo "✓ Fichiers .tmp trouvés : $NB_TMP"
}

# 6.3 — find + exec + xargs
ex_3() {
    echo ""
    echo "=== Exercice 6.3 : find + exec/xargs ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Affichez la taille de chaque fichier Python avec find + exec
    echo "--- Taille de chaque .py ---"
    echo "[TODO : find app/ -name '*.py' -exec ls -lh {} \;]"
    find app/ -name "*.py" -exec ls -lh {} \;

    echo ""
    # TODO : Comptez les lignes dans TOUS les .py avec find + xargs
    echo "--- Lignes dans tous les .py ---"
    echo "[TODO : find app/ -name '*.py' -print0 | xargs -0 wc -l]"
    find app/ -name "*.py" -print0 | xargs -0 wc -l

    echo ""
    # TODO : Supprimez TOUS les fichiers .tmp avec find + delete
    echo "--- Supprimer les .tmp ---"
    NB_AVANT=$(find . -name "*.tmp" | wc -l)
    echo "Avant suppression : $NB_AVANT fichiers .tmp"
    echo "[TODO : find . -name '*.tmp' -delete]"
    find . -name "*.tmp" -delete  # solution
    NB_APRES=$(find . -name "*.tmp" | wc -l)
    echo "✓ Après suppression : $NB_APRES fichiers .tmp"

    echo ""
    # TODO : Cherchez "import" dans tous les .py avec find + xargs + grep
    echo "--- 'import' dans les .py ---"
    echo "[TODO : find app/ -name '*.py' -print0 | xargs -0 grep -l 'import']"
    find app/ -name "*.py" -print0 | xargs -0 grep -l "import"

    echo ""
    # TODO : Créez une archive des fichiers CSV avec find + tar
    echo "--- Archiver les CSV ---"
    echo "[TODO : find data/ -name '*.csv' -print0 | xargs -0 tar -czf /tmp/csv_backup_$$.tar.gz]"
    CSV_LIST=$(find data/ -name "*.csv" | tr '\n' ' ')
    if [ -n "$CSV_LIST" ]; then
        tar -czf /tmp/csv_backup_$$.tar.gz $CSV_LIST 2>/dev/null && \
            echo "✓ Archive créée : /tmp/csv_backup_$$.tar.gz" && \
            rm -f /tmp/csv_backup_$$.tar.gz
    fi
}

# 6.4 — Analyser des logs
ex_4() {
    echo ""
    echo "=== Exercice 6.4 : Analyser les logs ==="
    echo ""

    cd "$WORKDIR" || return

    LOG="app/logs/access.log"

    # TODO : Comptez le nombre de lignes ERROR, WARNING, INFO dans access.log
    echo "--- Statistiques par niveau ---"
    echo "[TODO : grep -c 'INFO' $LOG]"
    for level in INFO WARNING ERROR; do
        NB=$(grep -c "$level" "$LOG" 2>/dev/null || echo 0)
        echo "  $level : $NB ligne(s)"
    done

    echo ""
    # TODO : Extrayez uniquement les adresses IP du log avec grep -oE
    echo "--- Toutes les IPs dans le log ---"
    echo "[TODO : grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' $LOG | sort -u]"
    grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$LOG" | sort -u

    echo ""
    # TODO : Trouvez les IPs qui apparaissent le plus souvent (top 3)
    echo "--- Top 3 des IPs ---"
    echo "[TODO : grep -oE '[0-9.]+' $LOG | sort | uniq -c | sort -rn | head -3]"
    grep -oE "192\.[0-9]+\.[0-9]+\.[0-9]+" "$LOG" | sort | uniq -c | sort -rn | head -3

    echo ""
    # TODO : Trouvez les lignes avec le code HTTP 500
    echo "--- Erreurs HTTP 500 ---"
    echo "[TODO : grep -E ' 500$' $LOG]"
    grep -E " 500$" "$LOG" | head -5

    echo ""
    # TODO : Comptez les codes HTTP distincts et leur fréquence
    echo "--- Distribution des codes HTTP ---"
    echo "[TODO : grep -oE ' [0-9]{3}$' $LOG | sort | uniq -c | sort -rn]"
    grep -oE " [0-9]{3}$" "$LOG" | sort | uniq -c | sort -rn

    # Vérification
    echo ""
    NB_TOTAL=$(wc -l < "$LOG")
    NB_ERRORS=$(grep -c "ERROR" "$LOG")
    echo "✓ Total lignes access.log : $NB_TOTAL"
    echo "✓ Erreurs : $NB_ERRORS"
}

# 6.5 — Combinaisons avancées
ex_5() {
    echo ""
    echo "=== Exercice 6.5 : Combinaisons avancées ==="
    echo ""

    cd "$WORKDIR" || return

    # TODO : Trouvez tous les fichiers Python contenant "TODO" et affichez-les avec contexte
    echo "--- TODO dans les .py (avec contexte) ---"
    echo "[TODO : find app/ -name '*.py' -print0 | xargs -0 grep -n 'TODO']"
    find app/ -name "*.py" -print0 | xargs -0 grep -n "TODO"

    echo ""
    # TODO : Trouvez les données sensibles (password, secret, api_key) dans TOUS les fichiers
    echo "--- Données sensibles dans tout le projet ---"
    echo "[TODO : grep -rEi 'password|secret|api_key' --include='*.py' --include='*.conf' app/]"
    grep -rEi "password|secret|api_key" --include="*.py" --include="*.conf" app/ 2>/dev/null

    echo ""
    # TODO : Listez les fichiers modifiés récemment (24h) avec leur taille
    echo "--- Fichiers récents avec taille ---"
    echo "[TODO : find . -type f -mtime -1 -exec ls -lh {} \;]"
    find . -type f -mtime -1 -exec ls -lh {} \; | head -10

    echo ""
    # TODO : Utilisez which et whereis pour localiser grep et find
    echo "--- Localiser grep et find ---"
    echo "[TODO : which grep && which find]"
    which grep && which find

    echo ""
    echo "[TODO : whereis grep]"
    whereis grep 2>/dev/null || echo "(whereis non disponible)"

    echo ""
    # TODO : Bilan final — résumez le projet en une commande pipeline
    echo "--- Bilan du projet ---"
    echo "Fichiers par extension :"
    find . -type f | grep -oE '\.[a-z]+$' | sort | uniq -c | sort -rn
    echo ""
    echo "Total fichiers : $(find . -type f | wc -l)"
    echo "Total répertoires : $(find . -type d | wc -l)"
    echo "Espace total : $(du -sh . 2>/dev/null | cut -f1)"

    # Vérification finale
    echo ""
    NB_SENSIBLE=$(grep -rEi "password|secret|api_key" app/ 2>/dev/null | wc -l)
    echo "✓ Données sensibles trouvées : $NB_SENSIBLE occurrence(s) — pensez à les sécuriser !"
}

main
