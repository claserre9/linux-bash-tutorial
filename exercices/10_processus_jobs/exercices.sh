#!/usr/bin/env bash
# Exercices — Chapitre 10 : Processus et jobs

# ATTENTION : Certains exercices lancent des processus réels.
# Ils sont conçus pour être propres et sans effets de bord durables.

main() {
    ex_1; ex_2; ex_3; ex_4; ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

ex_1() {
    echo ""
    echo "=== Exercice 10.1 — Inspection des processus ==="
    echo "Objectif : Écrire des commandes ps pour extraire des informations précises"
    echo ""

    echo "1) Afficher les 5 processus consommant le plus de CPU :"
    echo "   (votre commande ici)"
    # TODO : ps avec --sort=-%cpu et head -6 (6 car 1 ligne d'en-tête)
    echo "--- Référence ---"
    ps aux --sort=-%cpu | head -6

    echo ""
    echo "2) Afficher les processus de l'utilisateur courant avec PID, commande et %mem :"
    echo "   (votre commande ici)"
    # TODO : ps -eo pid,%mem,cmd --sort=-%mem filtrés par user
    echo "--- Référence ---"
    ps -u "$USER" -o pid,%mem,cmd --sort=-%mem | head -10

    echo ""
    echo "3) Compter le nombre de processus actifs sur le système :"
    echo "   (votre commande ici)"
    # TODO : ps aux | wc -l (soustraire 1 pour l'en-tête)
    echo "--- Référence ---"
    nb=$(ps aux | tail -n +2 | wc -l)
    echo "Nombre de processus : $nb"
}

ex_2() {
    echo ""
    echo "=== Exercice 10.2 — Jobs en arrière-plan ==="
    echo "Objectif : Gérer plusieurs processus en parallèle avec wait"
    echo ""

    # TODO : Compléter la fonction executer_en_parallele() qui :
    # 1. Lance 3 "tâches" (simples sleep) en arrière-plan
    # 2. Stocke leurs PIDs
    # 3. Attend chacune et affiche son temps d'exécution
    # 4. Affiche le temps total

    executer_en_parallele() {
        local debut
        debut=$(date +%s)

        echo "Lancement des tâches en parallèle..."

        # TODO : lancer 3 tâches (sleep 2, sleep 3, sleep 1) en arrière-plan
        # et stocker leurs PIDs dans PID1, PID2, PID3

        # TODO : attendre chaque PID et afficher son code de retour
        # wait $PID1 && echo "Tâche 1 terminée (succès)" || echo "Tâche 1 échouée"

        local fin
        fin=$(date +%s)
        echo "Temps total : $((fin - debut)) secondes"
        echo "(sans parallélisme, ce serait 2+3+1=6s ; avec parallélisme ~3s)"
    }

    executer_en_parallele
}

ex_3() {
    echo ""
    echo "=== Exercice 10.3 — Signaux et trap ==="
    echo "Objectif : Créer un script qui gère proprement les signaux"
    echo ""

    # TODO : Compléter la fonction script_avec_signaux() qui :
    # 1. Crée un fichier PID dans /tmp
    # 2. Installe un trap sur SIGTERM et SIGINT pour le cleanup
    # 3. Installe un trap sur SIGUSR1 pour afficher un statut
    # 4. Tourne en boucle pendant max 10 itérations (simulation courte)
    # 5. Supprime le fichier PID à la sortie

    script_avec_signaux() {
        local pidfile="/tmp/exo10_$$.pid"
        local iterations=0
        local max_iter=5

        # TODO 1 : Créer le fichier PID
        # echo $$ > "$pidfile"
        echo "Démarrage (PID: $$, pidfile: $pidfile)"

        # TODO 2 : Trap cleanup
        # trap "rm -f '$pidfile'; echo 'Arrêt propre'" EXIT SIGTERM SIGINT

        # TODO 3 : Trap SIGUSR1
        # trap "echo 'Statut: iteration $iterations/$max_iter'" SIGUSR1

        # Boucle principale (simulation rapide)
        while (( iterations < max_iter )); do
            echo "  Itération $((++iterations))/$max_iter..."
            sleep 0.5
        done

        echo "Tâche complétée après $iterations itérations"
        # TODO : vérifier que pidfile a été supprimé
    }

    script_avec_signaux
    echo "Fichier PID supprimé : $([[ ! -f /tmp/exo10_$$.pid ]] && echo 'oui' || echo 'non')"
}

ex_4() {
    echo ""
    echo "=== Exercice 10.4 — nice et priorités ==="
    echo "Objectif : Lancer des commandes avec différentes priorités"
    echo ""

    echo "1) Vérifier la valeur nice par défaut d'un processus :"
    # TODO : lancer 'sleep 10 &' et vérifier sa valeur nice avec ps
    sleep 10 &
    local pid_sleep=$!
    echo "PID du sleep : $pid_sleep"
    # TODO : afficher la valeur nice de ce processus
    # Indice : ps -p $pid_sleep -o pid,ni,cmd
    echo "--- Référence ---"
    ps -p "$pid_sleep" -o pid,ni,cmd 2>/dev/null || true
    kill "$pid_sleep" 2>/dev/null

    echo ""
    echo "2) Lancer une commande avec priorité basse (nice +15) et vérifier :"
    # TODO : nice -n 15 sleep 10 & puis vérifier avec ps
    nice -n 15 sleep 10 &
    local pid_nice=$!
    echo "--- Référence ---"
    ps -p "$pid_nice" -o pid,ni,cmd 2>/dev/null || true
    kill "$pid_nice" 2>/dev/null

    echo ""
    echo "3) Comprendre la syntaxe de crontab :"
    echo "Expliquer ces entrées cron (écrivez les réponses dans les commentaires) :"
    echo ""
    echo "  */15 * * * *    → TODO : explication"
    echo "  0 2 * * 1       → TODO : explication"
    echo "  0 9-17 * * 1-5  → TODO : explication"
    echo "  @reboot         → TODO : explication"
    echo ""
    echo "--- Explications ---"
    echo "  */15 * * * *    → Toutes les 15 minutes"
    echo "  0 2 * * 1       → Chaque lundi à 2h00"
    echo "  0 9-17 * * 1-5  → Toutes les heures de 9h à 17h, du lun. au ven."
    echo "  @reboot         → Au démarrage du système"
}

ex_5() {
    echo ""
    echo "=== Exercice 10.5 — Script de monitoring de processus ==="
    echo "Objectif : Créer un script qui surveille un processus et le redémarre si nécessaire"
    echo ""

    # TODO : Compléter la fonction surveiller_processus() qui :
    # - Vérifie si un processus (passé en argument) est vivant (pgrep)
    # - Si non, affiche une alerte
    # - Simule 3 vérifications avec un intervalle court

    surveiller_processus() {
        local nom_processus="${1:-sleep}"
        local intervalle="${2:-1}"
        local max_checks="${3:-3}"
        local checks=0

        echo "Surveillance de '$nom_processus' (${max_checks} vérifications)..."

        while (( checks < max_checks )); do
            (( checks++ ))
            echo -n "Vérification $checks/$max_checks : "

            # TODO : utiliser pgrep pour vérifier si le processus tourne
            # if pgrep -x "$nom_processus" > /dev/null 2>&1; then
            #     echo "OK — '$nom_processus' est actif"
            # else
            #     echo "ALERTE — '$nom_processus' n'est PAS actif !"
            # fi

            echo "(TODO : utiliser pgrep -x \"$nom_processus\")"
            sleep "$intervalle"
        done
    }

    echo "Test avec un processus existant (bash) :"
    surveiller_processus "bash" 0.2 3

    echo ""
    echo "Test avec un processus inexistant :"
    surveiller_processus "processus_fictif_xyz" 0.2 3

    echo ""
    echo "--- Comportement attendu ---"
    echo "bash        → OK — 'bash' est actif (3 fois)"
    echo "xxx_fictif  → ALERTE — 'processus_fictif_xyz' n'est PAS actif (3 fois)"
}

main
