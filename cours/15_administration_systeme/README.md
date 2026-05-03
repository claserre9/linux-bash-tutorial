# Chapitre 15 — Administration système

L'administration système Linux couvre la gestion des utilisateurs, des packages, des services et de la surveillance. Ce chapitre présente les commandes et patterns essentiels pour maintenir un système Linux en production, de la gestion des comptes à la sécurité en passant par `systemd` et les logs.

---

## 1. Gestion des utilisateurs

### 1.1 Créer des utilisateurs

```bash
# useradd (bas niveau, disponible partout)
sudo useradd -m -s /bin/bash -c "Alice Dupont" alice
# -m : créer le home dir
# -s : shell par défaut
# -c : commentaire (nom complet)
# -G : groupes supplémentaires
# -u : UID spécifique

sudo useradd -m -s /bin/bash -G sudo,docker -u 1500 alice

# adduser (script Debian interactif, plus convivial)
sudo adduser bob
# Pose des questions : mot de passe, nom complet, etc.

# Définir ou changer un mot de passe
sudo passwd alice

# Forcer le changement de mot de passe à la prochaine connexion
sudo passwd -e alice
sudo chage -d 0 alice  # Même effet via chage
```

### 1.2 Modifier un utilisateur

```bash
# usermod : modifier un compte existant
sudo usermod -s /bin/zsh alice                # Changer le shell
sudo usermod -G docker,sudo alice             # Remplacer les groupes (attention !)
sudo usermod -aG docker alice                 # Ajouter au groupe docker (-a = append)
sudo usermod -l alice_nouveau alice           # Renommer le compte
sudo usermod -d /home/alice_new -m alice      # Déplacer le home
sudo usermod -L alice                         # Verrouiller le compte
sudo usermod -U alice                         # Déverrouiller

# Voir les groupes d'un utilisateur
groups alice
id alice
```

### 1.3 Supprimer un utilisateur

```bash
# userdel : supprimer un compte
sudo userdel alice           # Supprimer le compte (garde le home)
sudo userdel -r alice        # Supprimer compte + home + mail spool

# Vérifier avant suppression
grep "alice" /etc/passwd
ls -la /home/alice
```

### 1.4 Fichiers de configuration des comptes

```bash
# /etc/passwd : informations de base (pas les mots de passe !)
# Format : login:x:UID:GID:commentaire:home:shell
cat /etc/passwd | grep alice
# alice:x:1001:1001:Alice Dupont:/home/alice:/bin/bash

# /etc/shadow : mots de passe hashés (root seulement)
# Format : login:hash:lastchange:min:max:warn:inactive:expire
sudo cat /etc/shadow | grep alice

# /etc/group : groupes et membres
# Format : nom_groupe:x:GID:membres
cat /etc/group | grep docker
# docker:x:999:alice,bob

# Gestion des groupes
sudo groupadd devops          # Créer un groupe
sudo groupdel anciengroupe    # Supprimer un groupe
sudo gpasswd -a alice devops  # Ajouter alice au groupe devops
sudo gpasswd -d alice devops  # Retirer alice du groupe devops
```

> **Piège courant** : `usermod -G groupe alice` **remplace** tous les groupes de alice par `groupe`. Utilisez **toujours** `-aG` pour ajouter à un groupe sans perdre les autres.

---

## 2. Gestion des packages

### 2.1 `apt` — Debian/Ubuntu

```bash
# Mise à jour de la liste des packages
sudo apt update

# Mise à jour des packages installés
sudo apt upgrade
sudo apt full-upgrade   # Inclut les changements de dépendances

# Installer un package
sudo apt install nginx
sudo apt install -y nginx git curl   # -y : répondre oui automatiquement

# Supprimer un package
sudo apt remove nginx          # Garde les fichiers de config
sudo apt purge nginx           # Supprime aussi les fichiers de config

# Supprimer les dépendances orphelines
sudo apt autoremove
sudo apt autoremove --purge    # Purger aussi leurs configs

# Rechercher un package
apt search "web server"
apt-cache search nginx

# Informations sur un package
apt show nginx
apt-cache show nginx

# Lister les packages installés
apt list --installed
apt list --installed | grep nginx

# Voir les fichiers d'un package installé
dpkg -L nginx

# Voir quel package fournit un fichier
dpkg -S /usr/sbin/nginx
```

### 2.2 `dpkg` — Gestion bas niveau

```bash
# Installer un .deb local
sudo dpkg -i monpackage.deb
sudo apt install -f  # Résoudre les dépendances manquantes après dpkg

# Lister les packages installés
dpkg -l
dpkg -l | grep nginx   # Filtrer
dpkg -l | grep "^ii"   # Seulement les installés (ii = installed)

# Voir les fichiers d'un package
dpkg -L nginx

# Quel package fournit ce fichier ?
dpkg -S /etc/nginx/nginx.conf

# Vérifier l'intégrité
dpkg --verify nginx
```

### 2.3 `snap` — Packages universels

```bash
# Lister les snaps disponibles
snap find vlc

# Installer
sudo snap install vlc
sudo snap install code --classic   # --classic : accès au système de fichiers

# Lister les snaps installés
snap list

# Mettre à jour
sudo snap refresh
sudo snap refresh vlc   # Un snap spécifique

# Supprimer
sudo snap remove vlc
```

### 2.4 Autres gestionnaires de packages

```bash
# yum / dnf (Red Hat, Fedora, Rocky, AlmaLinux)
sudo dnf update
sudo dnf install nginx
sudo dnf remove nginx
sudo dnf search nginx
sudo dnf info nginx

# pacman (Arch Linux, Manjaro)
sudo pacman -Syu          # Synchroniser et mettre à jour
sudo pacman -S nginx      # Installer
sudo pacman -R nginx      # Supprimer
sudo pacman -Ss nginx     # Rechercher
sudo pacman -Qi nginx     # Infos sur un package installé
```

> **Astuce pro** : Sur un serveur, préférez `apt-get` à `apt` dans les scripts — `apt` est interactif et peut afficher des avertissements non désirés. `apt-get` est stable et conçu pour l'utilisation non interactive.

---

## 3. systemd et systemctl

### 3.1 Gestion des services

```bash
# Démarrer / arrêter / redémarrer
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx        # Recharger la config sans arrêt
sudo systemctl reload-or-restart nginx  # Reload si possible, sinon restart

# Activer / désactiver au démarrage
sudo systemctl enable nginx        # Activer au boot
sudo systemctl disable nginx       # Désactiver au boot
sudo systemctl enable --now nginx  # Activer ET démarrer immédiatement

# État
systemctl status nginx
systemctl is-active nginx          # active ou inactive
systemctl is-enabled nginx         # enabled ou disabled
systemctl is-failed nginx          # failed ou not-failed

# Lister les unités
systemctl list-units                           # Toutes les unités actives
systemctl list-units --type=service            # Services seulement
systemctl list-units --state=failed            # Services en échec
systemctl list-unit-files --type=service       # Tous les fichiers de service
```

### 3.2 Écrire un unit file systemd

```bash
# Créer un service personnalisé
# /etc/systemd/system/mon-service.service

cat > /etc/systemd/system/mon-service.service <<'EOF'
[Unit]
Description=Mon service personnalisé
Documentation=https://example.com/docs
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=monuser
Group=mongroup
WorkingDirectory=/opt/mon-service
ExecStart=/opt/mon-service/bin/start.sh
ExecStop=/opt/mon-service/bin/stop.sh
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal
SyslogIdentifier=mon-service

# Limites de ressources
LimitNOFILE=65536
MemoryMax=512M

# Sécurité
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Recharger la configuration systemd
sudo systemctl daemon-reload

# Activer et démarrer le service
sudo systemctl enable --now mon-service
sudo systemctl status mon-service
```

### 3.3 Types de services

```bash
# Type=simple    : ExecStart est le processus principal (défaut)
# Type=forking   : Le processus se forke (style daemon traditionnel)
# Type=oneshot   : Tâche ponctuelle (type=oneshot + RemainAfterExit=yes)
# Type=notify    : Notifie systemd quand il est prêt
# Type=idle      : Attend que les autres jobs soient terminés

# Service one-shot (tâche de démarrage)
cat > /etc/systemd/system/init-base.service <<'EOF'
[Unit]
Description=Initialisation de la base de données
After=postgresql.service
Requires=postgresql.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/opt/scripts/init_db.sh
User=postgres

[Install]
WantedBy=multi-user.target
EOF
```

### 3.4 `journalctl` — Consultation des logs systemd

```bash
# Logs d'un service spécifique
journalctl -u nginx
journalctl -u nginx -f          # Suivi en temps réel
journalctl -u nginx -n 50       # 50 dernières lignes

# Filtrage temporel
journalctl -u nginx --since "2024-01-15"
journalctl -u nginx --since "2024-01-15 10:00" --until "2024-01-15 12:00"
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx --since "yesterday"

# Filtrage par priorité (0=emerg, 1=alert, 2=crit, 3=err, 4=warning, 5=notice, 6=info, 7=debug)
journalctl -p err                # Erreurs et plus graves
journalctl -p warning..err       # Plage de priorités
journalctl -u nginx -p err

# Format de sortie
journalctl -u nginx -o json-pretty   # JSON
journalctl -u nginx -o short         # Format compact
journalctl -u nginx -o verbose       # Tous les champs

# Depuis le dernier boot
journalctl -b                    # Boot actuel
journalctl -b -1                 # Boot précédent
journalctl --list-boots          # Historique des boots

# Taille et maintenance des logs
journalctl --disk-usage
sudo journalctl --vacuum-size=500M    # Garder max 500 Mo
sudo journalctl --vacuum-time=30d     # Garder 30 jours max
```

---

## 4. Surveillance système

### 4.1 `vmstat` — Statistiques mémoire/CPU

```bash
# Snapshot instantané
vmstat

# Rafraîchissement toutes les 2 secondes, 5 fois
vmstat 2 5

# Sorties :
# r  : processus en attente de CPU
# b  : processus bloqués (I/O)
# swpd : swap utilisé (ko)
# free : mémoire libre (ko)
# si/so : swap in/out (ko/s)
# bi/bo : blocs disk in/out
# us/sy/id/wa : % CPU user/system/idle/wait I/O
```

### 4.2 `iostat` — Statistiques disques

```bash
# Aperçu CPU + disques
iostat

# Disques seulement, toutes les 2 secondes
iostat -d 2

# Format étendu avec taux de transfert
iostat -x 2

# Sortie clé :
# tps   : transactions par seconde
# kB_read/s, kB_wrtn/s : ko/s lus/écrits
# %util : utilisation du disque (proche de 100% = saturé)
```

### 4.3 `free`, `uptime`, `uname`

```bash
# Mémoire
free -h           # Format lisible (G, M, K)
free -s 2         # Mise à jour toutes les 2s

# Uptime et charge système
uptime
# Sortie : 14:22:01 up 45 days, 3:12,  2 users,  load average: 0.15, 0.10, 0.05
# Load average : charge CPU sur 1, 5, 15 min
# < nombre de CPU = OK, > nombre de CPU = surcharge

# Nombre de CPUs
nproc
grep -c processor /proc/cpuinfo

# Informations système
uname -a    # Tout : noyau, hostname, version, archi
uname -r    # Version du noyau seulement
uname -m    # Architecture (x86_64, aarch64...)
uname -n    # Hostname
```

### 4.4 `sar` — Archivage des performances

```bash
# Installer sysstat
sudo apt install sysstat

# Activer la collecte (si nécessaire)
sudo systemctl enable --now sysstat

# CPU depuis le début de la journée
sar

# CPU toutes les 2 secondes, 10 fois
sar 2 10

# Mémoire
sar -r

# Disques
sar -d

# Réseau
sar -n DEV

# Données historiques (journée précédente)
sar -f /var/log/sysstat/sa$(date -d yesterday +%d)
```

---

## 5. Gestion des disques

### 5.1 `lsblk` et informations disques

```bash
# Lister les périphériques block
lsblk
lsblk -f    # Avec filesystems et UUIDs
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,UUID

# Utilisation disque
df -h           # Humain lisible
df -h /         # Seulement la racine
df -i           # Inodes (important pour les systèmes avec beaucoup de petits fichiers)

# Espace utilisé par répertoire
du -sh /var/log          # Taille totale de /var/log
du -sh /var/log/*        # Taille de chaque sous-répertoire
du -h --max-depth=1 /    # Premier niveau depuis la racine
du -sh * | sort -h       # Trier par taille
```

### 5.2 Partitionnement

```bash
# fdisk : partitionnement MBR/GPT (interactif)
sudo fdisk /dev/sdb
# Commandes interactives :
# n : nouvelle partition
# d : supprimer une partition
# p : afficher la table de partition
# w : écrire et quitter
# q : quitter sans sauvegarder

# gdisk : partitionnement GPT
sudo gdisk /dev/sdb

# parted : outil non interactif
sudo parted /dev/sdb print                          # Afficher les partitions
sudo parted /dev/sdb mklabel gpt                    # Créer table GPT
sudo parted /dev/sdb mkpart primary ext4 0% 50%     # Créer partition
```

### 5.3 `mount`, `umount` et `/etc/fstab`

```bash
# Monter un périphérique
sudo mount /dev/sdb1 /mnt/data
sudo mount -t ext4 /dev/sdb1 /mnt/data   # Avec type de FS
sudo mount -o ro /dev/sdb1 /mnt/data     # En lecture seule
sudo mount -o remount,rw /mnt/data       # Remonter en lecture/écriture

# Démonter
sudo umount /mnt/data
sudo umount -l /mnt/data    # Lazy unmount (si occupé)

# Afficher les montages
mount | grep sdb
findmnt

# /etc/fstab : montages permanents
# Format : <device> <mount_point> <type> <options> <dump> <pass>
cat /etc/fstab

# Exemple d'entrée fstab
# UUID=12345678-... /data ext4 defaults,noatime 0 2
# //nas/share /mnt/nas cifs credentials=/etc/samba/creds,uid=1000 0 0

# Tester /etc/fstab sans redémarrer
sudo mount -a   # Monter tout ce qui n'est pas déjà monté
```

### 5.4 Créer un système de fichiers

```bash
# Formater une partition
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.ext4 -L "data" /dev/sdb1   # Avec label
sudo mkfs.xfs /dev/sdb1
sudo mkfs.btrfs /dev/sdb1

# Vérifier et réparer
sudo e2fsck -f /dev/sdb1   # Vérifier ext4 (partition non montée !)
```

---

## 6. Logs système

### 6.1 Les fichiers de log importants

```bash
# Principaux logs sous /var/log/
/var/log/syslog         # Logs système généraux (Debian/Ubuntu)
/var/log/messages       # Logs système (Red Hat)
/var/log/auth.log       # Authentification SSH, sudo... (Debian)
/var/log/secure         # Authentification (Red Hat)
/var/log/kern.log       # Logs du noyau
/var/log/nginx/         # Logs Nginx
/var/log/apache2/       # Logs Apache
/var/log/dpkg.log       # Opérations dpkg/apt
/var/log/boot.log       # Démarrage système
/var/log/faillog        # Échecs de connexion

# Consultation
tail -f /var/log/syslog         # Suivi en temps réel
grep "sshd" /var/log/auth.log   # Filtrer
zcat /var/log/syslog.2.gz | grep "error"  # Logs compressés
```

### 6.2 `logrotate` — Rotation des logs

```bash
# Configuration globale : /etc/logrotate.conf
# Configurations par service : /etc/logrotate.d/

# Exemple de configuration logrotate
cat > /etc/logrotate.d/mon-service <<'EOF'
/var/log/mon-service/*.log {
    daily               # Rotation quotidienne
    rotate 14           # Garder 14 fichiers
    compress            # Compresser les anciens
    delaycompress       # Compresser avec 1 jour de décalage
    missingok           # Ne pas errorer si fichier absent
    notifempty          # Ne pas tourner si fichier vide
    create 0640 monuser adm  # Créer avec permissions
    sharedscripts
    postrotate
        systemctl reload mon-service 2>/dev/null || true
    endscript
}
EOF

# Tester sans appliquer
sudo logrotate --debug /etc/logrotate.d/mon-service

# Forcer la rotation
sudo logrotate --force /etc/logrotate.d/mon-service
```

---

## 7. Sécurité basique

### 7.1 `ufw` — Firewall simplifié (Debian/Ubuntu)

```bash
# Activer ufw
sudo ufw enable
sudo ufw status
sudo ufw status verbose

# Règles de base
sudo ufw allow ssh             # Autoriser SSH (port 22)
sudo ufw allow 80/tcp          # HTTP
sudo ufw allow 443/tcp         # HTTPS
sudo ufw allow 8080            # Port spécifique
sudo ufw allow from 192.168.1.0/24 to any port 22  # SSH depuis réseau local seulement

# Bloquer
sudo ufw deny 3306             # Bloquer MySQL depuis l'extérieur
sudo ufw deny from 10.0.0.1    # Bloquer une IP

# Supprimer une règle
sudo ufw delete allow 8080
sudo ufw delete allow from 10.0.0.1

# Politique par défaut (recommandé)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Numéroter les règles
sudo ufw status numbered
sudo ufw delete 3   # Supprimer la règle numéro 3
```

### 7.2 `fail2ban` — Protection contre les brute-force

```bash
# Installation
sudo apt install fail2ban

# Configuration
# /etc/fail2ban/jail.local (ne pas modifier jail.conf !)
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 3600         # Bannir 1 heure
findtime = 600          # Fenêtre de détection (10 min)
maxretry = 5            # Tentatives avant bannissement
ignoreip = 127.0.0.1/8 192.168.1.0/24   # IPs jamais bannies

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s

[nginx-http-auth]
enabled  = true
filter   = nginx-http-auth
port     = http,https
logpath  = /var/log/nginx/error.log
EOF

sudo systemctl restart fail2ban

# Gestion des bans
sudo fail2ban-client status              # Vue globale
sudo fail2ban-client status sshd         # Détail sshd
sudo fail2ban-client set sshd unbanip 10.0.0.1   # Débannir une IP
sudo fail2ban-client banned              # IPs bannies
```

### 7.3 Hardening SSH

```bash
# /etc/ssh/sshd_config — paramètres recommandés
cat >> /etc/ssh/sshd_config <<'EOF'
# Désactiver l'authentification par mot de passe
PasswordAuthentication no
ChallengeResponseAuthentication no

# Désactiver le login root direct
PermitRootLogin no

# Limiter les utilisateurs autorisés
AllowUsers alice bob deployer

# Port non standard (security par l'obscurité, discutable)
# Port 2222

# Timeout d'inactivité
ClientAliveInterval 300
ClientAliveCountMax 2

# Limiter les tentatives d'auth
MaxAuthTries 3

# Désactiver les fonctionnalités inutiles
X11Forwarding no
AllowTcpForwarding no

EOF

# Tester la configuration avant redémarrage !
sudo sshd -t
sudo systemctl reload ssh

# Générer une paire de clés SSH (côté client)
ssh-keygen -t ed25519 -C "alice@laptop" -f ~/.ssh/id_ed25519

# Copier la clé publique sur le serveur
ssh-copy-id -i ~/.ssh/id_ed25519.pub alice@serveur

# Ou manuellement
cat ~/.ssh/id_ed25519.pub | ssh alice@serveur 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
```

> **Astuce pro** : Avant de désactiver `PasswordAuthentication`, testez que votre clé SSH fonctionne dans une session séparée. Sinon vous vous exposez à rester définitivement bloqué hors du serveur.

---

## Tableau récapitulatif

| Domaine | Commandes clés | Fichiers importants |
|---------|---------------|-------------------|
| **Utilisateurs** | `useradd` `usermod` `userdel` `passwd` | `/etc/passwd` `/etc/shadow` `/etc/group` |
| **Packages** | `apt install/update/upgrade/remove` | `/etc/apt/sources.list` |
| **Services** | `systemctl start/stop/enable/status` | `/etc/systemd/system/*.service` |
| **Logs** | `journalctl -u` `-f` `-p` `--since` | `/var/log/syslog` `/var/log/auth.log` |
| **Disques** | `lsblk` `df -h` `du -sh` `mount` | `/etc/fstab` |
| **Firewall** | `ufw allow/deny/status` | `/etc/ufw/` |
| **Sécurité** | `fail2ban-client status` `sshd -t` | `/etc/ssh/sshd_config` `/etc/fail2ban/` |
| **Perf** | `vmstat` `iostat` `free -h` `uptime` | `/proc/cpuinfo` `/proc/meminfo` |

## À retenir

- `usermod -aG groupe user` : toujours le `-a` pour éviter de perdre les groupes existants
- `apt-get` (pas `apt`) dans les scripts — plus stable pour l'automatisation
- `systemctl enable --now` active ET démarre en une seule commande
- `sshd -t` vérifie la configuration SSH avant de la recharger — indispensable pour éviter un lock-out
- `ufw default deny incoming` + règles explicites : approche firewall la plus sûre
- Activez `fail2ban` dès qu'un port SSH est exposé sur Internet

➡️ [Chapitre 16 — Automatisation et CI](../16_automatisation_ci/README.md)
