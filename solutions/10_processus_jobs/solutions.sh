#!/usr/bin/env bash
# Solutions — Chapitre 10 : Processus et jobs

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Solution 10.1 — Inspection des processus ==="

    echo "1) Top 5 processus par CPU :"
    # --sort=-%cpu : tri décroissant sur %CPU
    # head -6 : 1 ligne d'en-tête + 5 processus
    ps aux --sort=-%cpu | head -6

    echo ""
    echo "2) Processus de l'utilisateur courant (PID, %mem, cmd) :"
    # -u $USER : filtrer par utilisateur
    # -o pid,%mem,cmd : colonnes personnalisées
    # --sort=-%mem : tri par mémoire décroissant
    ps -u "$USER" -o pid,%mem,cmd --sort=-%mem | head -10

    echo ""
    echo "3) Nombre de processus actifs :"
    # tail -n +2 : sauter la première ligne (en-tête)
    # wc -l : compter les lignes
    nb=$(ps aux | tail -n +2 | wc -l)
    echo "Nombre de processus : $nb"

    echo ""
    echo "Points clés :"
    echo "  - ps aux : style BSD, tous les processus"
    echo "  - ps -ef : style POSIX, tous les processus"
    echo "  - --sort=-%cpu : tri décroissant sur CPU (le - inverse le tri)"
    echo "  - -o pid,%mem,cmd : sélectionner les colonnes à afficher"
    echo "  - tail -n +2 : ignorer la 1ère ligne (en-tête)"
}

ex_2() {
    echo ""
    echo "=== Solution 10.2 — Jobs en arrière-plan ==="

    executer_en_parallele() {
        local debut
        debut=$(date +%s)

        echo "Lancement des 3 tâches en parallèle..."

        # Lancer les tâches en arrière-plan
        sleep 2 &
        local PID1=$!
        echo "  Tâche 1 lancée (PID: $PID1, durée: 2s)"

        sleep 3 &
        local PID2=$!
        echo "  Tâche 2 lancée (PID: $PID2, durée: 3s)"

        sleep 1 &
        local PID3=$!
        echo "  Tâche 3 lancée (PID: $PID3, durée: 1s)"

        echo "En attente de la fin des tâches..."

        # Attendre chaque tâche et vérifier son code de retour
        if wait "$PID1"; then
            echo "  Tâche 1 (sleep 2) : terminée avec succès"
        else
            echo "  Tâche 1 : échec (code: $?)"
        fi

        if wait "$PID2"; then
            echo "  Tâche 2 (sleep 3) : terminée avec succès"
        else
            echo "  Tâche 2 : échec (code: $?)"
        fi

        if wait "$PID3"; then
            echo "  Tâche 3 (sleep 1) : terminée avec succès"
        else
            echo "  Tâche 3 : échec (code: $?)"
        fi

        local fin
        fin=$(date +%s)
        local duree=$((fin - debut))
        echo ""
        echo "Temps total : ${duree}s (séquentiel serait 6s, économie : $((6 - duree))s)"
    }

    executer_en_parallele

    echo ""
    echo "Points clés :"
    echo "  - & : lancer en arrière-plan"
    echo "  - \$! : PID du dernier processus lancé en arrière-plan"
    echo "  - wait \$PID : attendre un processus spécifique"
    echo "  - wait (sans arg) : attendre TOUS les processus en arrière-plan"
    echo "  - wait retourne le code de sortie du processus attendu"
}

ex_3() {
    echo ""
    echo "=== Solution 10.3 — Signaux et trap ==="

    script_avec_signaux() {
        local pidfile="/tmp/exo10_$$.pid"
        local iterations=0
        local max_iter=5

        # Créer le fichier PID
        echo $$ > "$pidfile"
        echo "Démarrage (PID: $$, pidfile: $pidfile)"

        # Trap pour le nettoyage à la sortie (normal ou signal)
        trap "rm -f '$pidfile'; echo 'Arrêt propre — pidfile supprimé'" EXIT

        # Trap pour SIGINT (Ctrl+C) et SIGTERM
        trap "echo 'Signal d arrêt reçu — au revoir !'; exit 0" SIGTERM SIGINT

        # Trap pour SIGUSR1 — afficher un statut sans arrêter
        trap "echo 'Statut : itération $iterations/$max_iter en cours'" SIGUSR1

        # Boucle principale (simulation rapide)
        while (( iterations < max_iter )); do
            echo "  Itération $((++iterations))/$max_iter..."
            sleep 0.3
        done

        echo "Tâche complétée après $iterations itérations"
        # Le trap EXIT supprime automatiquement le pidfile
    }

    script_avec_signaux

    # Vérifier que le fichier PID a été supprimé
    if [[ ! -f "/tmp/exo10_$$.pid" ]]; then
        echo "Fichier PID correctement supprimé par trap EXIT ✓"
    else
        echo "PROBLÈME : le fichier PID existe encore !"
        rm -f "/tmp/exo10_$$.pid"
    fi

    echo ""
    echo "Points clés :"
    echo "  - trap 'cmd' EXIT : exécuté à la sortie (normal ET erreur)"
    echo "  - trap 'cmd' SIGTERM SIGINT : plusieurs signaux en une fois"
    echo "  - trap 'cmd' SIGUSR1 : signal personnalisé, ne quitte pas"
    echo "  - echo \$\$ > pidfile : stocker le PID pour kill externe"
    echo "  - Le trap EXIT s'exécute même après un Ctrl+C ou kill"
}

ex_4() {
    echo ""
    echo "=== Solution 10.4 — nice et priorités ==="

    echo "1) Valeur nice par défaut (0) d'un processus :"
    sleep 10 &
    local pid_defaut=$!
    echo "PID: $pid_defaut"
    ps -p "$pid_defaut" -o pid,ni,cmd 2>/dev/null || true
    kill "$pid_defaut" 2>/dev/null

    echo ""
    echo "2) Processus avec priorité basse (nice +15) :"
    nice -n 15 sleep 10 &
    local pid_nice=$!
    echo "PID: $pid_nice"
    ps -p "$pid_nice" -o pid,ni,cmd 2>/dev/null || true
    kill "$pid_nice" 2>/dev/null

    echo ""
    echo "3) Explications des entrées cron :"
    cat << 'EOF'
  */15 * * * *    → Toutes les 15 minutes (0, 15, 30, 45)
  0 2 * * 1       → Chaque lundi à 2h00
  0 9-17 * * 1-5  → Toutes les heures de 9h à 17h, du lundi au vendredi
  @reboot         → Au démarrage du système

Rappel syntaxe : minute(0-59) heure(0-23) jour_mois(1-31) mois(1-12) jour_sem(0-7)
  *  = toutes les valeurs
  */n = toutes les n valeurs
  n-m = de n à m
  n,m = n ou m
EOF

    echo ""
    echo "Points clés :"
    echo "  - nice -n N : N va de -20 (priorité haute) à +19 (priorité basse)"
    echo "  - Seul root peut utiliser des valeurs négatives"
    echo "  - renice permet de changer la priorité d'un processus existant"
    echo "  - ps -o ni : afficher la valeur nice dans ps"
}

ex_5() {
    echo ""
    echo "=== Solution 10.5 — Script de monitoring de processus ==="

    surveiller_processus() {
        local nom_processus="${1:-sleep}"
        local intervalle="${2:-1}"
        local max_checks="${3:-3}"
        local checks=0
        local alertes=0

        echo "Surveillance de '$nom_processus' (${max_checks} vérifications)..."

        while (( checks < max_checks )); do
            (( checks++ ))
            echo -n "Vérification $checks/$max_checks : "

            # pgrep -x : correspondance exacte sur le nom du processus
            if pgrep -x "$nom_processus" > /dev/null 2>&1; then
                echo "OK — '$nom_processus' est actif (PIDs: $(pgrep -x "$nom_processus" | tr '\n' ' '))"
            else
                echo "ALERTE — '$nom_processus' n'est PAS actif !"
                (( alertes++ ))
            fi

            sleep "$intervalle"
        done

        echo ""
        if (( alertes > 0 )); then
            echo "Résumé : $alertes/$max_checks vérifications en alerte"
            return 1
        else
            echo "Résumé : processus actif sur toutes les vérifications ✓"
            return 0
        fi
    }

    echo "Test avec un processus existant (bash) :"
    surveiller_processus "bash" 0.2 3

    echo ""
    echo "Test avec un processus inexistant :"
    surveiller_processus "processus_fictif_xyz" 0.2 3 || true

    echo ""
    echo "Points clés :"
    echo "  - pgrep -x 'nom' : cherche une correspondance exacte du nom"
    echo "  - pgrep -x 'nom' > /dev/null 2>&1 : juste le code de retour"
    echo "  - pgrep 'nom' (sans -x) : correspondance partielle"
    echo "  - Alternatives : pidof, ps aux | grep | grep -v grep"
    echo "  - Dans un vrai script de supervision : ajouter un redémarrage automatique"
    echo ""
    echo "Exemple de redémarrage automatique (non exécuté) :"
    echo "  pgrep -x nginx || systemctl start nginx"
}

main
