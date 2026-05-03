# Annexe B — One-liners utiles

Collection de one-liners Linux & Bash organisés par thème. Chaque commande est prête à l'emploi et accompagnée d'une explication concise.

---

## grep

```bash
grep -rn "TODO\|FIXME" src/
```
Chercher tous les TODO et FIXME récursivement avec numéros de ligne.

```bash
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' access.log | sort -u
```
Extraire toutes les adresses IPv4 uniques d'un fichier de log.

```bash
grep -vE '^[[:space:]]*(#|$)' /etc/ssh/sshd_config
```
Afficher une configuration sans commentaires ni lignes vides.

```bash
grep -c "ERROR" app.log && grep -m 5 "ERROR" app.log
```
Compter les erreurs, puis afficher les 5 premières.

```bash
grep -P '(?<=GET )/[^ ]+' access.log | sort | uniq -c | sort -rn | head 20
```
Top 20 des URLs les plus demandées dans un log Apache/Nginx.

```bash
grep -rl "pattern" /etc/ 2>/dev/null
```
Lister tous les fichiers de `/etc/` contenant un pattern.

```bash
grep -A 3 -B 3 "Exception" app.log
```
Afficher les 3 lignes avant et après chaque "Exception" dans un log.

---

## sed

```bash
sed -i.bak 's/localhost/db.prod.internal/g' config/*.conf
```
Remplacer `localhost` par l'hôte de prod dans tous les fichiers de config, avec backup `.bak`.

```bash
sed -n '100,200p' gros_fichier.txt
```
Afficher uniquement les lignes 100 à 200 d'un fichier.

```bash
sed '/^#/d; /^$/d' fichier.conf
```
Supprimer les commentaires et les lignes vides.

```bash
sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/g' dates.csv
```
Convertir les dates du format ISO (AAAA-MM-JJ) vers le format français (JJ/MM/AAAA).

```bash
sed -E 's/<[^>]+>//g' page.html
```
Supprimer toutes les balises HTML d'un fichier.

```bash
sed -n '/START/,/END/p' fichier.txt
```
Extraire le bloc de texte entre les marqueurs START et END.

```bash
sed '1s/^/HEADER\n/' fichier.txt
```
Ajouter une ligne au début d'un fichier.

```bash
sed '$a\DERNIERE_LIGNE' fichier.txt
```
Ajouter une ligne à la fin du fichier.

```bash
sed -i 's/\r$//' fichier_windows.txt
```
Convertir les fins de ligne Windows (CRLF) en Unix (LF).

---

## awk

```bash
awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd
```
Lister les utilisateurs non-système (UID >= 1000) avec leur UID.

```bash
awk 'NR==1 || $5 > 1000000' data.csv
```
Garder l'en-tête (NR==1) et les lignes où la colonne 5 dépasse 1 000 000.

```bash
awk '{sum += $1} END {print "Total:", sum, "Moyenne:", sum/NR}' nombres.txt
```
Calculer la somme et la moyenne de la première colonne.

```bash
awk '!seen[$0]++' fichier.txt
```
Supprimer les doublons tout en préservant l'ordre (contrairement à `sort | uniq`).

```bash
awk -F, 'NR>1 {print $2}' data.csv | sort | uniq -c | sort -rn
```
Compter la fréquence des valeurs de la colonne 2 d'un CSV.

```bash
awk '{gsub(/  +/, " "); print}' fichier.txt
```
Normaliser les espaces multiples en un seul espace.

```bash
awk -v OFS='\t' '{print $3, $1, $2}' fichier.txt
```
Réordonner les colonnes (3, 1, 2) avec tabulation comme séparateur de sortie.

```bash
awk '$9 ~ /^[45]/ {print $1, $9, $7}' access.log | sort | uniq -c | sort -rn
```
Extraire les erreurs HTTP 4xx et 5xx d'un log avec IP et URL.

```bash
awk 'length > 120' fichier.txt
```
Afficher les lignes dépassant 120 caractères.

---

## find

```bash
find . -name "*.log" -mtime +7 -exec gzip {} \;
```
Compresser tous les fichiers `.log` non modifiés depuis plus de 7 jours.

```bash
find /tmp -type f -empty -delete
```
Supprimer tous les fichiers vides du répertoire `/tmp`.

```bash
find . -type f -name "*.py" | xargs grep -l "import os" | wc -l
```
Compter les fichiers Python qui importent le module `os`.

```bash
find /var/log -name "*.gz" -size +10M -ls
```
Lister les archives de logs compressées de plus de 10 Mo.

```bash
find . -newer reference.txt -not -name "reference.txt" -type f
```
Trouver tous les fichiers modifiés après `reference.txt`.

```bash
find / -perm -4000 -type f 2>/dev/null
```
Trouver tous les exécutables setuid (potentiellement dangereux).

```bash
find . -type d -name ".git" -prune -o -name "*.sh" -print | xargs shellcheck
```
Vérifier tous les scripts shell avec shellcheck, en ignorant les dépôts git.

```bash
find /home -name "*.mp4" -o -name "*.avi" -o -name "*.mkv" | xargs du -ch | tail -1
```
Calculer la taille totale de tous les fichiers vidéo dans les homes.

---

## Réseau

```bash
ss -tlnp | grep LISTEN
```
Lister tous les ports en écoute avec le processus associé.

```bash
curl -s -o /dev/null -w "%{http_code} %{time_total}s\n" https://example.com
```
Tester le code HTTP et le temps de réponse d'une URL.

```bash
curl -sL https://api.github.com/repos/torvalds/linux/releases/latest | jq -r '.tag_name'
```
Obtenir la dernière version d'un dépôt GitHub via l'API.

```bash
while true; do ping -c 1 -W 1 8.8.8.8 >/dev/null && echo "$(date): OK" || echo "$(date): KO"; sleep 5; done
```
Surveiller la connectivité internet en continu avec horodatage.

```bash
dig +short TXT google.com | tr -d '"'
```
Afficher les enregistrements TXT DNS (utile pour SPF, DKIM...).

```bash
nc -zv -w 2 db.host.com 5432 && echo "Port ouvert" || echo "Port fermé"
```
Tester si un port TCP est ouvert (ici PostgreSQL 5432).

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 user@host 'echo ok' 2>&1
```
Tester une connexion SSH sans interactivité (pour les scripts).

```bash
curl -s ifconfig.me
```
Connaître son adresse IP publique.

```bash
arp -n | grep -v incomplete
```
Afficher les hôtes connus sur le réseau local.

```bash
nmap -sn 192.168.1.0/24 2>/dev/null | grep "Nmap scan report"
```
Découvrir les hôtes actifs sur un sous-réseau (scan ping).

---

## Système

```bash
ps aux --sort=-%mem | head 10
```
Top 10 des processus consommant le plus de mémoire.

```bash
ps aux --sort=-%cpu | head 10
```
Top 10 des processus consommant le plus de CPU.

```bash
du -sh /var/log/* | sort -h | tail 10
```
Top 10 des répertoires de log les plus volumineux.

```bash
df -h | awk '$5+0 > 80 {print "ALERTE:", $0}'
```
Alerter si un système de fichiers dépasse 80% d'utilisation.

```bash
free -h | awk '/^Mem:/ {print "RAM utilisée:", $3, "/ Total:", $2}'
```
Afficher l'utilisation mémoire de façon lisible.

```bash
lsof -i TCP -s TCP:ESTABLISHED | awk '{print $1, $3, $9}' | sort | uniq -c | sort -rn
```
Lister les connexions TCP établies, groupées par processus.

```bash
cat /proc/loadavg | awk '{print "Load:", $1, $2, $3}'
```
Afficher la charge système sur 1, 5 et 15 minutes.

```bash
last | grep -v "^$\|reboot\|wtmp" | awk '{print $1}' | sort | uniq -c | sort -rn
```
Compter les connexions par utilisateur dans l'historique.

```bash
who | awk '{print $1, $5}' | sort -u
```
Lister les utilisateurs connectés avec leur IP d'origine.

```bash
systemctl list-units --state=failed --no-legend
```
Lister uniquement les services systemd en échec.

```bash
journalctl --since "24 hours ago" -p err --no-pager | grep -v audit
```
Afficher toutes les erreurs syslog des dernières 24 heures.

```bash
timedatectl | grep -E "Local time|Time zone|NTP"
```
Vérifier l'heure système, le fuseau horaire et la synchronisation NTP.

---

## Bash et scripting

```bash
echo {a..z} | tr ' ' '\n'
```
Générer l'alphabet lettre par lettre, une par ligne.

```bash
history | awk '{print $2}' | sort | uniq -c | sort -rn | head 20
```
Top 20 des commandes les plus utilisées dans l'historique.

```bash
for f in *.jpg; do convert "$f" "${f%.jpg}.webp"; done
```
Convertir tous les JPEG en WebP (nécessite ImageMagick).

```bash
printf '%s\n' *.txt | wc -l
```
Compter les fichiers `.txt` sans forker un sous-shell.

```bash
read -sp "Mot de passe : " pass && echo && echo "Longueur: ${#pass}"
```
Lire un mot de passe sans l'afficher et afficher sa longueur.

```bash
diff <(ssh host1 'cat /etc/hosts') <(ssh host2 'cat /etc/hosts')
```
Comparer un fichier de configuration entre deux serveurs distants.

```bash
while IFS= read -r line; do echo "$(date +%T) $line"; done < <(tail -f app.log)
```
Horodater chaque ligne d'un fichier de log en temps réel.

```bash
tar -czf - ./dossier | ssh user@host 'cat > /backup/archive.tar.gz'
```
Compresser et transférer un dossier via SSH en une seule commande, sans fichier intermédiaire.

```bash
( trap '' HUP; nohup long_job.sh >> /var/log/job.log 2>&1 & )
```
Lancer un job en arrière-plan immunisé contre la déconnexion, avec log.

```bash
for host in host1 host2 host3; do echo "=== $host ===" && ssh "$host" 'uptime' 2>/dev/null; done
```
Exécuter `uptime` sur plusieurs serveurs en séquence.

---

## Archives et transferts

```bash
tar -czf - /etc | ssh user@backup 'cat > /backups/etc-$(date +%Y%m%d).tar.gz'
```
Sauvegarder `/etc` directement sur un serveur distant sans fichier temporaire.

```bash
find . -name "*.log" | tar -czf logs_$(date +%Y%m%d).tar.gz -T -
```
Archiver tous les fichiers `.log` listés par find en utilisant `-T -`.

```bash
rsync -avz --progress --exclude='.git' ./ user@host:/opt/app/
```
Synchroniser un projet vers un serveur en excluant le dossier git.

```bash
rsync -avz --dry-run /source/ /destination/
```
Simuler une synchronisation rsync sans effectuer de modifications.

---

*Retour au cours : [Chapitre 16 — Automatisation et CI](../cours/16_automatisation_ci/README.md)*
