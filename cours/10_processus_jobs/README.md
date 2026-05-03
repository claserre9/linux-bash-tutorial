# Chapitre 10 — Processus et jobs

Comprendre la gestion des processus est fondamental pour tout administrateur système ou développeur travaillant sous Linux. Ce chapitre couvre l'inspection des processus, les signaux, la gestion des tâches en arrière-plan, les priorités CPU et la planification de tâches avec cron.

---

## 1. Inspecter les processus

### 1.1 `ps` — Instantané des processus

```bash
# Tous les processus de tous les utilisateurs (style BSD)
ps aux

# Tous les processus (style POSIX)
ps -ef

# Arborescence des processus (style forêt)
ps --forest
ps axf    # Version courte

# Processus d'un utilisateur spécifique
ps -u alice
ps aux | grep alice

# Processus triés par utilisation CPU
ps aux --sort=-%cpu | head -10

# Processus triés par utilisation mémoire
ps aux --sort=-%mem | head -10

# Affichage personnalisé
ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -15

# Processus d'un programme spécifique
ps aux | grep nginx

# Format court pour les scripts
ps -p 1234 -o pid,ppid,cmd    # Infos sur le PID 1234
```

### 1.2 `pstree` — Arborescence visuelle

```bash
# Arborescence complète
pstree

# Avec les PIDs
pstree -p

# Arborescence d'un utilisateur
pstree alice

# Arborescence à partir d'un PID
pstree -p 1234

# Avec les lignes de commande
pstree -a
```

### 1.3 `top` et `htop` — Surveillance en temps réel

```bash
# top — moniteur interactif natif
top

# Commandes interactives dans top :
# q         Quitter
# k         Tuer un processus (saisir le PID)
# r         Reniceer (changer priorité)
# M         Trier par mémoire
# P         Trier par CPU
# N         Trier par PID
# u         Filtrer par utilisateur
# 1         Afficher tous les cœurs CPU
# Space     Rafraîchir

# top non-interactif pour les scripts
top -b -n 1 | head -20    # -b = batch, -n 1 = une itération

# htop — version améliorée (à installer)
apt install htop    # Debian/Ubuntu
brew install htop   # macOS

# htop avec des options
htop -u alice       # Filtrer par utilisateur
htop -p 1234,5678   # Surveiller des PIDs spécifiques
```

> **Astuce pro** : `htop` affiche les cœurs CPU individuellement, les threads, et permet de naviguer avec les touches fléchées. Indispensable pour diagnostiquer les problèmes de performance.

---

## 2. Signaux et commandes `kill`

### 2.1 Les signaux importants

| Signal | Numéro | Nom | Comportement |
|--------|--------|-----|--------------|
| SIGHUP | 1 | Hang Up | Recharger la config (démons) |
| SIGINT | 2 | Interrupt | Ctrl+C |
| SIGQUIT | 3 | Quit | Ctrl+\ (core dump) |
| SIGKILL | 9 | Kill | Terminaison forcée (non interceptable) |
| SIGTERM | 15 | Terminate | Terminaison propre (par défaut) |
| SIGSTOP | 19 | Stop | Pause (non interceptable) |
| SIGCONT | 18 | Continue | Reprendre un processus pausé |
| SIGUSR1 | 10 | User 1 | Signal personnalisé |
| SIGUSR2 | 12 | User 2 | Signal personnalisé |

```bash
# Lister tous les signaux
kill -l

# kill — envoyer un signal à un PID
kill 1234              # SIGTERM (15) par défaut
kill -15 1234          # SIGTERM explicite
kill -TERM 1234        # Même chose
kill -9 1234           # SIGKILL — force brute
kill -KILL 1234        # Même chose
kill -HUP 1234         # Recharger la config

# Envoyer à plusieurs processus
kill 1234 5678 9012

# killall — tuer par nom
killall nginx
killall -9 python3
killall -HUP sshd    # Recharger sshd

# pkill — tuer par pattern de nom (plus flexible)
pkill nginx
pkill -9 "python.*worker"
pkill -u alice          # Tous les processus de alice
pkill -f "script.py"    # Correspondance sur la ligne de commande complète

# pgrep — trouver des PIDs par nom
pgrep nginx             # Affiche les PIDs
pgrep -l nginx          # Avec les noms
pgrep -u alice          # Processus de alice
pgrep -f "mon_script"   # Par ligne de commande
```

> **Piège courant** : `kill -9` (SIGKILL) ne peut pas être intercepté par le processus. Il ne lui laisse pas le temps de se nettoyer (fermer des fichiers, libérer des ressources). Toujours essayer `kill -15` en premier, et attendre quelques secondes.

### 2.2 Envoyer des signaux depuis un script

```bash
#!/usr/bin/env bash

# Intercepter les signaux dans un script (trap)
cleanup() {
    echo "Signal reçu — nettoyage..."
    rm -f /tmp/monscript.lock
    exit 0
}

trap cleanup SIGTERM SIGINT SIGQUIT

# Recharger la config sur SIGHUP
reload_config() {
    echo "Rechargement de la configuration..."
    # ... relire le fichier de config ...
}

trap reload_config SIGHUP

echo "Script démarré (PID: $$)"
echo "Envoyez 'kill -HUP $$' pour recharger"

while true; do
    sleep 1
done
```

---

## 3. Gestion des jobs en arrière-plan

### 3.1 `&`, `jobs`, `fg`, `bg`

```bash
# Lancer une commande en arrière-plan (&)
sleep 60 &
echo "Sleep lancé en arrière-plan, PID: $!"

# Lancer plusieurs commandes en arrière-plan
./traitement_long.sh &
./autre_traitement.sh &

# Lister les jobs de la session courante
jobs
# [1]+ Running    sleep 60 &
# [2]- Running    ./traitement_long.sh &

# jobs avec les PIDs (-l)
jobs -l

# Passer un job en avant-plan (fg)
fg          # Le job courant (+)
fg %1       # Job numéro 1
fg %sleep   # Job dont le nom commence par "sleep"

# Mettre un processus en pause (Ctrl+Z dans le terminal)
# Puis le passer en arrière-plan
bg
bg %1

# Séquence typique :
# 1. Lancer une commande qui prend du temps
# 2. Ctrl+Z pour la suspendre
# 3. bg pour la continuer en arrière-plan
# 4. Continuer à travailler dans le terminal
```

### 3.2 `disown` et `nohup`

```bash
# disown — détacher un job du shell courant
sleep 1000 &
jobs          # [1] Running sleep 1000
disown %1     # Le job n'est plus attaché au shell
jobs          # (vide)
# Maintenant le job survit à la fermeture du shell

# disown -h — empêche SIGHUP sans détacher complètement
sleep 1000 &
disown -h %1

# nohup — lancer une commande immune au SIGHUP
nohup ./script_long.sh &
# Sortie redirigée vers nohup.out par défaut

# nohup avec redirection explicite
nohup ./script_long.sh > /var/log/script.log 2>&1 &

# Vérifier que le processus tourne encore
ps aux | grep script_long.sh
```

### 3.3 `wait` — Attendre la fin des jobs

```bash
#!/usr/bin/env bash

# Lancer plusieurs tâches en parallèle
echo "Démarrage des tâches parallèles..."

traitement_a() { sleep 2; echo "Tâche A terminée"; }
traitement_b() { sleep 3; echo "Tâche B terminée"; }
traitement_c() { sleep 1; echo "Tâche C terminée"; }

traitement_a &
PID_A=$!

traitement_b &
PID_B=$!

traitement_c &
PID_C=$!

echo "PIDs: $PID_A, $PID_B, $PID_C"

# Attendre un processus spécifique
wait $PID_C
echo "C est terminé, toujours en attente de A et B..."

# Attendre tous les processus en arrière-plan
wait
echo "Toutes les tâches sont terminées"

# Récupérer le code de retour
commande_async &
pid=$!
wait $pid
echo "Code de retour : $?"
```

---

## 4. `nice` et `renice` — Priorités CPU

```bash
# Priorité "nice" : de -20 (la plus haute) à +19 (la plus basse)
# Valeur par défaut : 0
# Seul root peut donner des valeurs négatives (priorité élevée)

# Lancer une commande avec une priorité basse (+10)
nice -n 10 ./traitement_intensif.sh

# Priorité très basse (pour les tâches de fond non urgentes)
nice -n 19 rsync -av /home/ /backup/

# Priorité haute (root uniquement)
sudo nice -n -10 ./service_critique.sh

# renice — modifier la priorité d'un processus déjà lancé
renice +5 -p 1234           # Réduire la priorité du PID 1234
sudo renice -5 -p 1234      # Augmenter la priorité (root)
renice +10 -u alice         # Tous les processus de alice
renice +15 -g 1000          # Tous les processus du groupe 1000

# Vérifier la priorité (colonne NI dans ps)
ps -eo pid,ni,cmd | grep 1234
top    # Colonne NI = valeur nice
```

---

## 5. `lsof` — Fichiers ouverts

```bash
# Lister tous les fichiers ouverts
lsof

# Fichiers ouverts par un processus
lsof -p 1234

# Fichiers ouverts par un utilisateur
lsof -u alice

# Qui utilise un fichier spécifique ?
lsof /var/log/syslog

# Qui utilise un répertoire ?
lsof +D /var/log

# Connexions réseau ouvertes
lsof -i               # Toutes
lsof -i TCP           # TCP seulement
lsof -i :80           # Port 80
lsof -i :80,443       # Ports 80 et 443
lsof -i TCP:22        # SSH

# Trouver quel processus utilise un port
lsof -i :8080

# Fichiers supprimés mais encore ouverts (pour libérer de l'espace)
lsof | grep deleted

# Libérer de l'espace occupé par un fichier log supprimé mais ouvert
lsof | grep deleted | awk '{print $2}' | xargs -I{} sh -c 'truncate -s 0 /proc/{}/fd/$(ls /proc/{}/fd -la | grep deleted | awk "{print \$9}")'
# Alternative simple : redémarrer le service concerné
```

---

## 6. `flock` — Verrous de fichiers

```bash
# flock empêche l'exécution simultanée de scripts (mutex)

# Acquérir un verrou exclusif sur un fichier
flock /tmp/monscript.lock mon_script.sh

# Depuis l'intérieur d'un script
(
    flock -n 9 || { echo "Script déjà en cours d'exécution"; exit 1; }
    # Section critique
    echo "Traitement en cours..."
    sleep 10
) 9>/tmp/monscript.lock

# Avec timeout (-w)
(
    flock -w 30 9 || { echo "Timeout : impossible d'acquérir le verrou"; exit 1; }
    echo "Verrou acquis, traitement..."
) 9>/tmp/monscript.lock

# Pattern recommandé pour les scripts cron
#!/usr/bin/env bash
LOCKFILE="/tmp/${0##*/}.lock"

if flock -n 200; then
    echo "Traitement..."
else
    echo "Déjà en cours d'exécution" >&2
    exit 1
fi 200>"$LOCKFILE"
```

---

## 7. `cron` — Planification de tâches

### 7.1 Syntaxe crontab

```
┌───────────── minute (0-59)
│ ┌───────────── heure (0-23)
│ │ ┌───────────── jour du mois (1-31)
│ │ │ ┌───────────── mois (1-12)
│ │ │ │ ┌───────────── jour de la semaine (0-7, 0 et 7 = dimanche)
│ │ │ │ │
* * * * * commande
```

```bash
# Éditer la crontab de l'utilisateur courant
crontab -e

# Lister la crontab
crontab -l

# Supprimer la crontab
crontab -r

# Éditer la crontab d'un autre utilisateur (root)
crontab -u alice -e

# Exemples de planification
* * * * *       /script.sh              # Chaque minute
0 * * * *       /script.sh              # Chaque heure (à HH:00)
0 9 * * *       /script.sh              # Chaque jour à 9h00
0 9 * * 1-5     /script.sh              # Lun-Ven à 9h00
0 0 1 * *       /script.sh              # 1er du mois à minuit
0 2 * * 0       /backup.sh              # Dimanche à 2h
*/5 * * * *     /check.sh               # Toutes les 5 minutes
0 9,17 * * *    /script.sh              # 9h et 17h
0 9 * * 1,3,5   /script.sh              # Lun, Mer, Ven à 9h
```

### 7.2 Macros cron

```bash
@reboot     commande     # Au démarrage du système
@yearly     commande     # = 0 0 1 1 *
@annually   commande     # Idem
@monthly    commande     # = 0 0 1 * *
@weekly     commande     # = 0 0 * * 0
@daily      commande     # = 0 0 * * *
@midnight   commande     # Idem @daily
@hourly     commande     # = 0 * * * *
```

### 7.3 Bonnes pratiques cron

```bash
# Toujours utiliser des chemins absolus dans cron
0 2 * * * /usr/local/bin/backup.sh

# Rediriger les sorties (cron envoie les sorties par email sinon)
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1

# Taire la sortie si non désirée
* * * * * /usr/local/bin/check.sh > /dev/null 2>&1

# Variables d'environnement dans la crontab
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=admin@example.com

0 2 * * * /usr/local/bin/backup.sh

# Tester qu'une commande fonctionne en dehors de cron
env -i SHELL=/bin/bash HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin /usr/local/bin/backup.sh
```

> **Piège courant** : Le `PATH` de cron est minimal — il ne contient pas `/usr/local/bin`. Utilisez toujours des chemins absolus dans vos scripts cron, ou définissez `PATH` en haut de la crontab.

---

## 8. `at` — Exécution différée

```bash
# Exécuter une commande dans 5 minutes
echo "/usr/local/bin/rapport.sh" | at now + 5 minutes

# Exécuter à une heure précise
at 14:30
# (saisir les commandes, terminer avec Ctrl+D)

# Syntaxes de date variées
at 14:30 tomorrow
at 14:30 2024-12-25
at now + 1 hour
at noon tomorrow
at midnight

# Lire les jobs en attente
atq

# Supprimer un job (numéro dans atq)
atrm 5

# Voir le contenu d'un job
at -c 5

# Avec une redirection
echo "tar -czf /backup/etc_$(date +%Y%m%d).tar.gz /etc" | at 03:00
```

---

## 9. Timers systemd

```bash
# Lister les timers actifs
systemctl list-timers

# Lister tous les timers (actifs + inactifs)
systemctl list-timers --all

# Créer un timer systemd (alternative à cron, plus puissant)
# Fichier service : /etc/systemd/system/mon-script.service
cat > /etc/systemd/system/mon-script.service << 'EOF'
[Unit]
Description=Mon script de maintenance
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/mon-script.sh
User=www-data
EOF

# Fichier timer : /etc/systemd/system/mon-script.timer
cat > /etc/systemd/system/mon-script.timer << 'EOF'
[Unit]
Description=Timer pour mon script
Requires=mon-script.service

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:30:00
Persistent=true    # Rattraper les exécutions manquées

[Install]
WantedBy=timers.target
EOF

# Activer et démarrer le timer
systemctl daemon-reload
systemctl enable mon-script.timer
systemctl start mon-script.timer

# Vérifier le statut
systemctl status mon-script.timer

# Déclencher manuellement
systemctl start mon-script.service

# Voir les logs
journalctl -u mon-script.service
journalctl -u mon-script.service -n 50 --no-pager
```

> **Astuce pro** : Les timers systemd ont plusieurs avantages sur cron : journalisation intégrée via `journalctl`, dépendances entre services, `Persistent=true` pour rattraper les exécutions manquées (si le serveur était éteint), et une syntaxe de calendrier plus expressive.

---

## 10. Surveillance et diagnostic

```bash
# Voir l'historique d'exécution cron dans syslog
grep CRON /var/log/syslog | tail -20
journalctl -u cron | tail -20

# Surveiller les processus en temps réel
watch -n 2 'ps aux | head -15'

# Surveiller un processus spécifique
watch -n 1 "ps aux | grep nginx | grep -v grep"

# Temps d'exécution d'une commande
time ./mon_script.sh

# Ressources utilisées par un processus
/usr/bin/time -v mon_script.sh 2>&1 | tail -20

# Tracer les appels système
strace -p 1234           # Attacher à un processus
strace ./mon_programme   # Tracer depuis le début

# Utilisation CPU et mémoire détaillée
cat /proc/1234/status    # Infos détaillées sur le PID 1234
cat /proc/1234/cmdline   # Ligne de commande
ls /proc/1234/fd/        # Descripteurs de fichiers ouverts
```

---

## Tableau récapitulatif

| Commande | Usage | Options clés |
|----------|-------|--------------|
| `ps aux` | Tous les processus | `--sort=-%cpu`, `-eo pid,cmd` |
| `pstree` | Arborescence | `-p` PIDs, `-a` arguments |
| `top` | Temps réel | `M` mémoire, `P` CPU, `k` kill |
| `htop` | Temps réel amélioré | Interactif, graphique |
| `kill` | Envoyer signal | `-9` force, `-15` propre, `-HUP` reload |
| `pkill` | Kill par nom | `-u` utilisateur, `-f` ligne complète |
| `pgrep` | PID par nom | `-l` avec nom, `-u` utilisateur |
| `jobs` | Lister jobs shell | `-l` avec PIDs |
| `fg` / `bg` | Avant/arrière-plan | `%N` job numéro N |
| `disown` | Détacher du shell | `-h` SIGHUP seulement |
| `nohup` | Immune au SIGHUP | Sortie dans `nohup.out` |
| `wait` | Attendre processus | `$PID` spécifique |
| `nice` | Priorité au lancement | `-n N` (-20 à +19) |
| `renice` | Changer priorité | `-p` PID, `-u` user |
| `lsof` | Fichiers ouverts | `-p` PID, `-i` réseau, `-u` user |
| `flock` | Verrous fichiers | `-n` non-bloquant, `-w` timeout |
| `crontab` | Planification | `-e` éditer, `-l` lister, `-r` supprimer |
| `at` | Exécution différée | `atq` lister, `atrm` supprimer |

---

## À retenir

- **`kill -15`** (SIGTERM) d'abord, **`kill -9`** (SIGKILL) seulement en dernier recours.
- Utilisez **`pgrep`** et **`pkill`** plutôt que `ps | grep | awk | kill` — c'est plus fiable.
- **`nohup` + `&`** pour les processus longs qui doivent survivre à la déconnexion SSH.
- **`wait`** est essentiel pour la parallélisation dans les scripts — toujours récupérer les codes de retour.
- Dans **crontab**, utilisez des chemins absolus et redirigez toujours les sorties.
- Les **timers systemd** sont la solution moderne pour remplacer cron sur les systèmes utilisant systemd.
- **`flock`** évite les exécutions simultanées de scripts cron — à toujours utiliser pour les tâches critiques.

➡️ [Chapitre 11 — Réseau](../11_reseau/README.md)
