#!/usr/bin/env bash
# Solutions — Chapitre 6 : Recherche et filtrage
# Exécutez : bash solutions.sh

WORKDIR="/tmp/sol_recherche_$$"

setup() {
    mkdir -p "$WORKDIR"
    cd "$WORKDIR" || exit 1

    mkdir -p app/{src/{utils,models,views},tests,config,logs}
    mkdir -p data/{raw,processed}

    cat > app/src/main.py << 'EOF'
#!/usr/bin/env python3
"""Module principal."""
import os
import sys

# TODO: améliorer la gestion des erreurs
DEBUG = False
API_KEY = "sk-test-123abc"  # TODO: utiliser variable d'env

def main():
    """Point d'entrée."""
    print("Démarrage")
    # TODO: implémenter la logique
    pass

if __name__ == "__main__":
    main()
EOF

    cat > app/src/utils/helpers.py << 'EOF'
"""Fonctions utilitaires."""
import re

def validate_email(email):
    pattern = r'^[\w.-]+@[\w.-]+\.[a-z]{2,}$'
    return bool(re.match(pattern, email, re.IGNORECASE))

# TODO: ajouter validation URL
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
HOST=localhost
PORT=8080
DB_PASS=secret123
API_KEY=sk-prod-xyz
EOF

    for i in $(seq 1 60); do
        local level="INFO"
        [ $((i % 10)) -eq 0 ] && level="ERROR"
        [ $((i % 7)) -eq 0 ] && level="WARNING"
        echo "2024-01-$(printf '%02d' $((i % 28 + 1))) $((i % 24)):00:00 [$level] 192.168.1.$((i % 10 + 1)) GET /api/$((i % 5)) HTTP/1.1 $((i % 3 == 0 ? 404 : 200))" >> app/logs/access.log
    done

    touch app/src/utils/cache_{1..3}.tmp
    touch data/raw/data_{jan,fev,mar}.csv
    touch data/processed/clean_{jan,fev,mar}.csv
    dd if=/dev/zero of=data/raw/big_dataset.bin bs=1024 count=1536 2>/dev/null

    echo "Environnement créé dans : $WORKDIR"
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
    echo "=== Exercice 6.1 : grep ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- Tous les TODO dans les .py (récursif) ---"
    grep -r "TODO" app/src/
    echo "✓ grep -r 'TODO' app/src/"

    echo ""
    echo "--- TODO avec numéros de ligne et noms de fichiers ---"
    grep -rn "TODO" app/src/
    echo "✓ grep -rn 'TODO' app/src/"

    echo ""
    echo "--- Fichiers contenant FIXME ---"
    grep -rl "FIXME" app/
    echo "✓ grep -rl 'FIXME' app/"

    echo ""
    echo "--- Données sensibles (password|secret|api_key, insensible à la casse) ---"
    grep -rEi "password|secret|api_key" app/config/
    echo "✓ grep -rEi 'password|secret|api_key' app/config/"

    echo ""
    echo "--- ERRORs avec 2 lignes de contexte ---"
    grep -C 2 "ERROR" app/logs/access.log | head -15
    echo "✓ grep -C 2 'ERROR' app/logs/access.log"

    echo ""
    echo "--- Bonus : grep -v pour exclure les commentaires ---"
    grep -v "^#" app/config/settings.conf | grep -v "^$"
    echo "✓ grep -v '^#' | grep -v '^$' → config sans commentaires ni lignes vides"

    NB_TODO=$(grep -r "TODO" app/src/ | wc -l)
    echo ""
    echo "✓ Nombre de TODO dans app/src/ : $NB_TODO"
}

# 6.2 — find avec critères avancés
ex_2() {
    echo ""
    echo "=== Exercice 6.2 : find ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- Tous les fichiers .py ---"
    find app/ -name "*.py" -type f
    echo "✓ find app/ -name '*.py' -type f"

    echo ""
    echo "--- Fichiers de plus de 1 Mo ---"
    find . -type f -size +1M
    echo "✓ find . -type f -size +1M"

    echo ""
    echo "--- Fichiers .tmp ---"
    find . -name "*.tmp" -type f
    echo "✓ find . -name '*.tmp' -type f"

    echo ""
    echo "--- Répertoires vides ---"
    find . -type d -empty
    echo "✓ find . -type d -empty"

    echo ""
    echo "--- Fichiers modifiés dans les 10 dernières minutes ---"
    find . -type f -mmin -10
    echo "✓ find . -type f -mmin -10"

    echo ""
    echo "--- Logs non vides (> 100 octets) ---"
    find app/logs -name "*.log" -size +100c -type f
    echo "✓ find app/logs -name '*.log' -size +100c -type f"

    echo ""
    echo "--- Combinaison : .py de plus de 100 octets, max 2 niveaux ---"
    find app/ -name "*.py" -size +100c -maxdepth 3 -type f
    echo "✓ find app/ -name '*.py' -size +100c -maxdepth 3 -type f"

    NB_PY=$(find app/ -name "*.py" -type f | wc -l)
    NB_TMP=$(find . -name "*.tmp" | wc -l)
    echo ""
    echo "✓ Fichiers Python : $NB_PY"
    echo "✓ Fichiers .tmp : $NB_TMP"
}

# 6.3 — find + exec + xargs
ex_3() {
    echo ""
    echo "=== Exercice 6.3 : find + exec/xargs ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- Taille de chaque .py avec exec ---"
    find app/ -name "*.py" -exec ls -lh {} \;
    echo "✓ find app/ -name '*.py' -exec ls -lh {} \\;"

    echo ""
    echo "--- Compter les lignes dans tous les .py ---"
    find app/ -name "*.py" -print0 | xargs -0 wc -l
    echo "✓ find app/ -name '*.py' -print0 | xargs -0 wc -l"
    echo "  (print0 + xargs -0 gère les espaces dans les noms)"

    echo ""
    echo "--- Supprimer les .tmp ---"
    NB_AVANT=$(find . -name "*.tmp" | wc -l)
    find . -name "*.tmp" -delete
    NB_APRES=$(find . -name "*.tmp" | wc -l)
    echo "✓ find . -name '*.tmp' -delete"
    echo "  Avant : $NB_AVANT, Après : $NB_APRES"

    echo ""
    echo "--- Chercher 'import' dans les .py avec xargs ---"
    find app/ -name "*.py" -print0 | xargs -0 grep -l "import"
    echo "✓ find app/ -name '*.py' -print0 | xargs -0 grep -l 'import'"

    echo ""
    echo "--- Compter les TODO avec exec + grep + wc ---"
    find app/ -name "*.py" -exec grep -c "TODO" {} \; 2>/dev/null | awk '{s+=$1}END{print "Total TODO dans les .py : " s}'
    echo "✓ find + exec + grep -c + awk pour total"

    echo ""
    echo "--- find -exec vs -exec {} + ---"
    echo "  {} \\; → une commande par fichier (N appels)"
    echo "  {} +  → tous les fichiers en un seul appel (1 appel) — plus efficace"
    find app/ -name "*.py" -exec echo "Fichier :" {} +
}

# 6.4 — Analyser les logs
ex_4() {
    echo ""
    echo "=== Exercice 6.4 : Analyser les logs ==="
    echo ""

    cd "$WORKDIR" || return

    LOG="app/logs/access.log"

    echo "--- Statistiques par niveau ---"
    for level in INFO WARNING ERROR; do
        NB=$(grep -c "$level" "$LOG" 2>/dev/null || echo 0)
        echo "  $level : $NB ligne(s)"
    done
    echo "✓ grep -c 'NIVEAU' $LOG"

    echo ""
    echo "--- Toutes les IPs uniques ---"
    grep -oE "192\.[0-9]+\.[0-9]+\.[0-9]+" "$LOG" | sort -u
    echo "✓ grep -oE '[0-9.]+' access.log | sort -u"

    echo ""
    echo "--- Top 3 des IPs ---"
    grep -oE "192\.[0-9]+\.[0-9]+\.[0-9]+" "$LOG" | sort | uniq -c | sort -rn | head -3
    echo "✓ grep -oE | sort | uniq -c | sort -rn | head -3"

    echo ""
    echo "--- Erreurs HTTP 404 ---"
    grep -E " 404$" "$LOG" | head -5
    echo "✓ grep -E ' 404$' access.log"

    echo ""
    echo "--- Distribution des codes HTTP ---"
    grep -oE " [0-9]{3}$" "$LOG" | sort | uniq -c | sort -rn
    echo "✓ grep -oE ' [0-9]{3}$' | sort | uniq -c | sort -rn"

    echo ""
    echo "--- Bonus : extraire et trier les endpoints ---"
    grep -oE "GET /[^ ]+" "$LOG" | sort | uniq -c | sort -rn | head -5
    echo "✓ grep -oE 'GET /[^ ]+' | sort | uniq -c | sort -rn"

    NB_TOTAL=$(wc -l < "$LOG")
    NB_ERRORS=$(grep -c "ERROR" "$LOG")
    echo ""
    echo "✓ Total lignes : $NB_TOTAL, Erreurs : $NB_ERRORS"
}

# 6.5 — Combinaisons avancées
ex_5() {
    echo ""
    echo "=== Exercice 6.5 : Combinaisons avancées ==="
    echo ""

    cd "$WORKDIR" || return

    echo "--- TODO dans les .py avec numéros de ligne ---"
    find app/ -name "*.py" -print0 | xargs -0 grep -n "TODO"
    echo "✓ find ... -print0 | xargs -0 grep -n 'TODO'"

    echo ""
    echo "--- Données sensibles dans .py et .conf ---"
    grep -rEi "password|secret|api_key" --include="*.py" --include="*.conf" app/ 2>/dev/null
    echo "✓ grep -rEi --include='*.py' --include='*.conf'"

    echo ""
    echo "--- Fichiers récents avec taille ---"
    find . -type f -mtime -1 -exec ls -lh {} \; | head -10
    echo "✓ find . -type f -mtime -1 -exec ls -lh {} \\;"

    echo ""
    echo "--- Localiser grep et find ---"
    which grep && which find
    echo "✓ which grep && which find"

    echo ""
    echo "--- whereis (binaire + sources + man) ---"
    whereis grep 2>/dev/null || echo "(whereis non disponible)"
    echo "✓ whereis grep"

    echo ""
    echo "--- Bilan complet du projet ---"
    echo "Fichiers par extension :"
    find . -type f | grep -oE '\.[a-z]+$' | sort | uniq -c | sort -rn
    echo ""
    echo "Total fichiers    : $(find . -type f | wc -l)"
    echo "Total répertoires : $(find . -type d | wc -l)"
    echo "Espace total      : $(du -sh . 2>/dev/null | cut -f1)"

    echo ""
    echo "--- Bonus : pipeline d'audit de sécurité ---"
    echo "Fichiers contenant des données potentiellement sensibles :"
    grep -rEil "password|secret|api_key|token|private_key" app/ 2>/dev/null
    NB_SENSIBLE=$(grep -rEi "password|secret|api_key" app/ 2>/dev/null | wc -l)
    echo ""
    echo "✓ $NB_SENSIBLE occurrence(s) de données sensibles trouvées"
    echo "  Action recommandée : déplacer vers des variables d'environnement"

    echo ""
    echo "--- Bonus : trouver les gros fichiers ---"
    find . -type f -size +500k -exec ls -lh {} \;
    echo "✓ find . -type f -size +500k -exec ls -lh {} \\;"
}

main
