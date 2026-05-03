# Annexe A — Aide-mémoire des commandes essentielles

Référence rapide des commandes Linux & Bash les plus utilisées, organisées par catégorie. Chaque ligne présente la commande, sa description et un exemple concret.

---

## Navigation

| Commande | Description | Exemple |
|----------|-------------|---------|
| `pwd` | Afficher le répertoire courant | `pwd` → `/home/alice` |
| `cd` | Changer de répertoire | `cd /var/log` |
| `cd ..` | Remonter d'un niveau | `cd ../..` (deux niveaux) |
| `cd ~` | Aller dans le home | `cd ~` ou `cd` |
| `cd -` | Retourner au répertoire précédent | `cd -` |
| `ls` | Lister les fichiers | `ls -la /etc` |
| `ls -l` | Liste détaillée (permissions, taille, date) | `ls -lh /var/log` |
| `ls -a` | Inclure les fichiers cachés | `ls -la ~` |
| `ls -t` | Trier par date de modification | `ls -lt /tmp` |
| `ls -S` | Trier par taille | `ls -lSh /var/log` |
| `tree` | Arborescence graphique | `tree -L 2 /etc` |
| `pushd` | Empiler le répertoire et changer | `pushd /tmp` |
| `popd` | Dépiler et revenir | `popd` |
| `dirs` | Afficher la pile de répertoires | `dirs -v` |

---

## Fichiers et répertoires

| Commande | Description | Exemple |
|----------|-------------|---------|
| `touch` | Créer un fichier vide / mettre à jour la date | `touch fichier.txt` |
| `mkdir` | Créer un répertoire | `mkdir -p /opt/app/logs` |
| `cp` | Copier un fichier | `cp -av source/ dest/` |
| `mv` | Déplacer ou renommer | `mv ancien.txt nouveau.txt` |
| `rm` | Supprimer un fichier | `rm -rf /tmp/build/` |
| `ln -s` | Créer un lien symbolique | `ln -s /opt/app/current /opt/app/latest` |
| `ln` | Créer un lien physique | `ln fichier.txt fichier_hard.txt` |
| `cat` | Afficher le contenu | `cat /etc/hosts` |
| `less` | Pagination interactive | `less /var/log/syslog` |
| `head` | Premières lignes | `head -20 fichier.txt` |
| `tail` | Dernières lignes / suivi | `tail -f /var/log/nginx/access.log` |
| `wc` | Compter lignes/mots/octets | `wc -l /etc/passwd` |
| `file` | Type d'un fichier | `file image.png` |
| `stat` | Métadonnées d'un fichier | `stat /etc/hosts` |
| `diff` | Comparer deux fichiers | `diff -u fichier1 fichier2` |
| `patch` | Appliquer un patch | `patch -p1 < fix.patch` |
| `split` | Découper un fichier | `split -l 1000 gros.csv partie_` |
| `sort` | Trier les lignes | `sort -k2 -n fichier.txt` |
| `uniq` | Supprimer les doublons | `sort fichier.txt \| uniq -c` |
| `tee` | Lire stdin et écrire dans fichier | `commande \| tee log.txt` |
| `xargs` | Construire des commandes | `find . -name "*.tmp" \| xargs rm` |

---

## Permissions et propriété

| Commande | Description | Exemple |
|----------|-------------|---------|
| `chmod` | Modifier les permissions | `chmod 755 script.sh` |
| `chmod u+x` | Ajouter exécution au propriétaire | `chmod u+x deploy.sh` |
| `chmod -R` | Récursif | `chmod -R 644 /var/www/` |
| `chown` | Changer le propriétaire | `chown alice:www-data /var/www/` |
| `chown -R` | Récursif | `chown -R deployer:deployer /opt/app` |
| `chgrp` | Changer le groupe | `chgrp developers projet/` |
| `umask` | Masque de permissions par défaut | `umask 022` |
| `getfacl` | Lire les ACLs | `getfacl /shared/` |
| `setfacl` | Modifier les ACLs | `setfacl -m u:alice:rwx /shared/` |
| `ls -Z` | Afficher les contextes SELinux | `ls -Z /var/www/html` |
| `sudo` | Exécuter en tant que root | `sudo systemctl restart nginx` |
| `su` | Changer d'utilisateur | `su - alice` |

---

## Recherche de fichiers

| Commande | Description | Exemple |
|----------|-------------|---------|
| `find` | Recherche polyvalente | `find /var/log -name "*.log" -newer /tmp/ref` |
| `find -name` | Par nom | `find . -name "config.yml"` |
| `find -type` | Par type (f/d/l) | `find /tmp -type f -empty` |
| `find -mtime` | Par date de modif | `find /backup -mtime +30 -delete` |
| `find -size` | Par taille | `find / -size +100M -type f` |
| `find -exec` | Exécuter une commande | `find . -name "*.sh" -exec shellcheck {} +` |
| `find -perm` | Par permissions | `find / -perm -4000 2>/dev/null` (setuid) |
| `locate` | Recherche dans base indexée | `locate nginx.conf` |
| `updatedb` | Mettre à jour la base locate | `sudo updatedb` |
| `which` | Trouver un exécutable dans PATH | `which python3` |
| `whereis` | Trouver binaire + man + source | `whereis bash` |
| `type` | Type d'une commande | `type ls` |

---

## Traitement de texte

| Commande | Description | Exemple |
|----------|-------------|---------|
| `grep` | Chercher un pattern | `grep -rn "TODO" src/` |
| `grep -E` | ERE (regex étendues) | `grep -E '^[0-9]{4}-' fichier.txt` |
| `grep -P` | PCRE (regex Perl) | `grep -P '(?<=user=)\w+' log.txt` |
| `grep -v` | Inverser le filtre | `grep -v "^#" config.conf` |
| `grep -c` | Compter les correspondances | `grep -c "ERROR" app.log` |
| `grep -l` | Lister les fichiers correspondants | `grep -rl "pattern" /var/` |
| `grep -o` | Afficher uniquement la correspondance | `grep -oE '[0-9.]+' versions.txt` |
| `sed` | Éditeur de flux | `sed -E 's/foo/bar/g' fichier.txt` |
| `sed -n '/pat/p'` | Afficher les lignes correspondantes | `sed -n '/ERROR/p' app.log` |
| `sed -i` | Modification en place | `sed -i 's/localhost/prod.host/g' app.conf` |
| `awk` | Traitement de champs | `awk -F: '{print $1, $3}' /etc/passwd` |
| `awk NR` | Numéro de ligne | `awk 'NR>=10 && NR<=20' fichier.txt` |
| `cut` | Extraire des colonnes | `cut -d: -f1,3 /etc/passwd` |
| `tr` | Translittérer / supprimer | `tr '[:lower:]' '[:upper:]' <<< "hello"` |
| `paste` | Fusionner des fichiers en colonnes | `paste fichier1.txt fichier2.txt` |
| `column` | Aligner en colonnes | `column -t -s, data.csv` |
| `jq` | Traitement JSON | `jq '.users[].name' data.json` |
| `iconv` | Convertir l'encodage | `iconv -f latin1 -t utf-8 fichier.txt` |

---

## Processus et jobs

| Commande | Description | Exemple |
|----------|-------------|---------|
| `ps` | Lister les processus | `ps aux` |
| `ps` filtré | Trouver un processus | `ps aux \| grep nginx` |
| `pgrep` | PID par nom | `pgrep -la nginx` |
| `top` | Moniteur interactif | `top -u alice` |
| `htop` | Moniteur amélioré | `htop` |
| `kill` | Envoyer un signal | `kill -15 1234` (SIGTERM) |
| `kill -9` | Tuer immédiatement | `kill -9 1234` (SIGKILL) |
| `killall` | Tuer par nom | `killall -9 zombie_process` |
| `pkill` | Tuer par pattern | `pkill -f "python worker"` |
| `nice` | Lancer avec priorité | `nice -n 19 make build` |
| `renice` | Changer la priorité | `renice -n 10 -p 1234` |
| `nohup` | Immuniser contre la déconnexion | `nohup long_job.sh > out.log &` |
| `jobs` | Lister les jobs | `jobs -l` |
| `bg` | Reprendre en arrière-plan | `bg %1` |
| `fg` | Reprendre au premier plan | `fg %1` |
| `wait` | Attendre un processus | `wait $PID` |
| `lsof` | Fichiers ouverts par les processus | `lsof -i :80` (port 80) |
| `fuser` | Qui utilise un fichier/port | `fuser -v 80/tcp` |
| `strace` | Tracer les appels système | `strace -p 1234` |
| `time` | Mesurer la durée d'exécution | `time ./build.sh` |

---

## Réseau

| Commande | Description | Exemple |
|----------|-------------|---------|
| `ip addr` | Interfaces réseau et IPs | `ip addr show eth0` |
| `ip route` | Table de routage | `ip route show` |
| `ip link` | État des interfaces | `ip link set eth0 up` |
| `ss` | Sockets (remplace netstat) | `ss -tlnp` |
| `netstat` | Connexions réseau | `netstat -tlnp` |
| `ping` | Tester la connectivité | `ping -c 4 google.com` |
| `traceroute` | Tracer la route | `traceroute google.com` |
| `mtr` | Traceroute continu | `mtr google.com` |
| `dig` | Requêtes DNS | `dig @8.8.8.8 example.com MX` |
| `nslookup` | Résolution DNS simple | `nslookup example.com` |
| `host` | Résolution DNS | `host -t A example.com` |
| `curl` | Transfert HTTP/HTTPS | `curl -sL https://api.example.com/v1/users` |
| `curl -I` | En-têtes HTTP seulement | `curl -I https://example.com` |
| `wget` | Télécharger des fichiers | `wget -q -O fichier.tar.gz https://...` |
| `ssh` | Connexion distante | `ssh -i ~/.ssh/key user@host` |
| `scp` | Copie sécurisée | `scp fichier.tar.gz user@host:/tmp/` |
| `rsync` | Synchronisation | `rsync -avz src/ user@host:/dest/` |
| `nc` / `ncat` | Netcat — lecture/écriture TCP/UDP | `nc -zv host 22` (tester port) |
| `tcpdump` | Capturer le trafic réseau | `tcpdump -i eth0 -n port 80` |
| `nmap` | Scanner de ports | `nmap -sV -p 22,80,443 host` |
| `iptables` | Règles firewall | `iptables -L -n -v` |
| `ufw` | Firewall simplifié | `ufw allow 443/tcp` |

---

## Variables et Bash

| Commande / Syntaxe | Description | Exemple |
|--------------------|-------------|---------|
| `$VAR` | Lire une variable | `echo "$HOME"` |
| `${VAR:-defaut}` | Valeur par défaut si vide | `${PORT:-8080}` |
| `${VAR:=defaut}` | Assigner si vide | `${TMP:=/tmp}` |
| `${#VAR}` | Longueur d'une chaîne | `${#USER}` |
| `${VAR:2:5}` | Sous-chaîne (offset:length) | `${URL:8:10}` |
| `${VAR##*/}` | Supprimer le plus long préfixe | `${path##*/}` → nom de fichier |
| `${VAR%.*}` | Supprimer le suffixe court | `${file%.*}` → sans extension |
| `${VAR/foo/bar}` | Remplacer première occurrence | `${url/http/https}` |
| `${VAR//foo/bar}` | Remplacer toutes les occurrences | `${str// /_}` |
| `$(commande)` | Substitution de commande | `date=$(date +%Y%m%d)` |
| `$((expr))` | Arithmétique entière | `$((2 ** 10))` → 1024 |
| `declare -a` | Tableau indexé | `declare -a liste=("a" "b")` |
| `declare -A` | Tableau associatif | `declare -A map=([key]="val")` |
| `declare -r` | Variable en lecture seule | `declare -r PI=3.14159` |
| `declare -i` | Variable entière | `declare -i n=0; n+=1` |
| `export` | Exporter vers l'environnement | `export PATH="$PATH:/opt/bin"` |
| `readonly` | Constante | `readonly VERSION="1.0.0"` |
| `local` | Variable locale à une fonction | `local tmp=$(mktemp)` |
| `[[ ]]` | Test étendu | `[[ "$f" =~ \.sh$ ]]` |
| `(( ))` | Test arithmétique | `(( count > 0 ))` |
| `set -euo pipefail` | Rigueur maximale | En tête de tout script de prod |
| `trap 'cleanup' EXIT` | Nettoyage garanti | `trap 'rm -f "$tmp"' EXIT` |

---

## Archivage et compression

| Commande | Description | Exemple |
|----------|-------------|---------|
| `tar -czf` | Créer une archive gzip | `tar -czf archive.tar.gz dossier/` |
| `tar -xzf` | Extraire une archive gzip | `tar -xzf archive.tar.gz` |
| `tar -cjf` | Créer une archive bzip2 | `tar -cjf archive.tar.bz2 dossier/` |
| `tar -cJf` | Créer une archive xz | `tar -cJf archive.tar.xz dossier/` |
| `tar -tf` | Lister le contenu sans extraire | `tar -tf archive.tar.gz` |
| `gzip` | Compresser un fichier | `gzip fichier.txt` → `fichier.txt.gz` |
| `gunzip` | Décompresser | `gunzip fichier.txt.gz` |
| `zcat` | Lire un fichier gzip | `zcat fichier.gz \| grep "pattern"` |
| `zip` | Créer un archive zip | `zip -r archive.zip dossier/` |
| `unzip` | Extraire un zip | `unzip -d /dest archive.zip` |
| `unzip -l` | Lister sans extraire | `unzip -l archive.zip` |

---

## Surveillance et performance

| Commande | Description | Exemple |
|----------|-------------|---------|
| `top` | Vue dynamique CPU/mémoire | `top -d 1` (rafraîchir chaque seconde) |
| `vmstat` | Mémoire, CPU, I/O | `vmstat 2 5` |
| `iostat` | Statistiques disques | `iostat -x 2` |
| `sar` | Historique de performances | `sar -r` (mémoire) |
| `free -h` | Utilisation mémoire | `free -h` |
| `uptime` | Charge système | `uptime` |
| `df -h` | Espace disque | `df -h` |
| `du -sh` | Taille d'un répertoire | `du -sh /var/log/*` |
| `lsblk` | Périphériques bloc | `lsblk -f` |
| `dmesg` | Messages du noyau | `dmesg \| tail -20` |
| `journalctl` | Logs systemd | `journalctl -u nginx -f` |
| `watch` | Répéter une commande | `watch -n 2 'df -h'` |

---

*Pour aller plus loin : [Annexe B — One-liners utiles](B_one_liners.md)*
