# Chapitre 4 — Permissions et ownership

Le modèle de permissions Unix garantit que chaque fichier appartient à un utilisateur et un groupe, et que les droits d'accès sont explicitement définis pour trois niveaux : propriétaire, groupe, autres. Ce chapitre couvre ce modèle de fond en comble, de `chmod` aux ACL.

---

## 1. Le modèle de permissions Unix

### 1.1 Structure des permissions

Chaque fichier ou répertoire possède trois catégories d'utilisateurs :

| Catégorie | Symbole | Description |
|-----------|---------|-------------|
| **User** | `u` | Propriétaire du fichier |
| **Group** | `g` | Membres du groupe propriétaire |
| **Other** | `o` | Tous les autres utilisateurs |
| **All** | `a` | Les trois catégories à la fois |

Et trois types de droits :

| Droit | Symbole | Valeur octale | Sur un fichier | Sur un répertoire |
|-------|---------|---------------|----------------|-------------------|
| **Read** | `r` | 4 | Lire le contenu | Lister le contenu (`ls`) |
| **Write** | `w` | 2 | Modifier le contenu | Créer/supprimer des fichiers |
| **Execute** | `x` | 1 | Exécuter le fichier | Entrer dans le répertoire (`cd`) |

### 1.2 Décrypter `ls -l`

```bash
ls -l /etc/passwd /bin/ls /home/alice
# -rw-r--r-- 1 root  root   2847 jan  5 10:23 /etc/passwd
# -rwxr-xr-x 1 root  root 142144 jan  1 00:00 /bin/ls
# drwxr-x--- 1 alice alice   4096 jan  5 09:00 /home/alice

# Décomposition de "-rw-r--r--" :
# Position : [type][u:rwx][g:rwx][o:rwx]
#             -     rw-    r--    r--
# type = - (fichier régulier)
# user : r=oui w=oui x=non  → 6
# group: r=oui w=non x=non  → 4
# other: r=oui w=non x=non  → 4
# Permission octale : 644
```

```bash
# Lecture complète d'une ligne ls -l
# -rwxr-xr-x  2    root  root   142144  jan  1  /bin/ls
#  ││││││││││  │      │     │       │      │
#  │││││││││└─ x : other peut exécuter
#  ││││││││└── - : other ne peut pas écrire
#  │││││││└─── r : other peut lire
#  ││││││└──── x : group peut exécuter
#  │││││└───── - : group ne peut pas écrire
#  ││││└────── r : group peut lire
#  │││└─────── x : user peut exécuter
#  ││└──────── w : user peut écrire
#  │└───────── r : user peut lire
#  └────────── - : fichier régulier (d=dossier, l=lien...)
#               └─ 2 liens durs
#                      └─ propriétaire
#                            └─ groupe
#                                  └─ taille
#                                         └─ date
```

---

## 2. `chmod` — Modifier les permissions

### 2.1 Notation symbolique

```bash
# Syntaxe : chmod [qui][+/-/=][droits] fichier
# qui    : u (user), g (group), o (other), a (all)
# action : + ajoute, - retire, = fixe exactement

chmod u+x script.sh         # ajouter exécution pour le propriétaire
chmod g-w fichier.txt       # retirer écriture pour le groupe
chmod o-r privé.conf        # retirer lecture pour les autres
chmod a+r public.txt        # ajouter lecture pour tous
chmod u=rwx,g=rx,o= prog    # définir exactement : u=rwx, g=r-x, o=---

chmod +x script.sh           # raccourci : ajoute x pour u,g,o
chmod -x,+r fichier          # combiner plusieurs actions
```

### 2.2 Notation octale

```bash
# Valeurs : r=4, w=2, x=1
# Additionner pour chaque catégorie : rwx = 4+2+1 = 7

# Permissions courantes
chmod 755 script.sh      # rwxr-xr-x : exécutable public
chmod 644 document.txt   # rw-r--r-- : fichier texte standard
chmod 600 ~/.ssh/id_rsa  # rw------- : clé privée SSH
chmod 700 ~/.ssh         # rwx------ : répertoire privé
chmod 777 /tmp/partage   # rwxrwxrwx : accès total (à éviter !)
chmod 400 secret.key     # r-------- : lecture seule propriétaire

# Récursif
chmod -R 755 public/     # tous les fichiers/dossiers récursivement

# Tableau des valeurs octales
# 0 = ---    4 = r--
# 1 = --x    5 = r-x
# 2 = -w-    6 = rw-
# 3 = -wx    7 = rwx
```

```bash
# Afficher les permissions en octal
stat -c "%a %n" fichier.txt    # ex : 644 fichier.txt
stat -c "%a" /etc/passwd       # 644
```

> **Piège courant** : `chmod -R 777 .` dans un projet web expose tous vos fichiers. Utilisez `chmod -R u=rwX,g=rX,o=rX .` — le `X` majuscule active l'exécution seulement si c'est un répertoire ou si le fichier était déjà exécutable.

---

## 3. `chown` et `chgrp` — Changer le propriétaire

```bash
# Changer le propriétaire
chown alice fichier.txt
chown alice:developers fichier.txt   # propriétaire ET groupe

# Changer seulement le groupe
chown :developers fichier.txt
chgrp developers fichier.txt         # équivalent

# Récursif
chown -R alice:alice /home/alice/
chgrp -R www-data /var/www/html/

# Verbose
chown -v alice fichier.txt

# Copier l'ownership d'un autre fichier
chown --reference=reference.txt cible.txt
```

> **Astuce pro** : Lors d'un déploiement web, `chown -R www-data:www-data /var/www/` + `chmod -R 755 /var/www/` est la configuration de base pour Apache/Nginx.

---

## 4. `umask` — Permissions par défaut

`umask` définit les permissions **retirées** lors de la création d'un fichier ou répertoire.

```bash
# Afficher le umask courant
umask         # 0022
umask -S      # u=rwx,g=rx,o=rx (notation symbolique)

# Calcul :
# Fichier  : 666 - umask = 666 - 022 = 644  (rw-r--r--)
# Répertoire: 777 - umask = 777 - 022 = 755  (rwxr-xr-x)

# Changer le umask temporairement
umask 027     # 666-027=640, 777-027=750

# umask courants
# 022 : standard serveur (fichiers 644, dossiers 755)
# 027 : plus restrictif (fichiers 640, dossiers 750)
# 077 : très restrictif (fichiers 600, dossiers 700)
# 002 : dev collaboratif (fichiers 664, dossiers 775)

# Rendre permanent (dans .bashrc)
echo "umask 022" >> ~/.bashrc
```

---

## 5. Bits spéciaux : SUID, SGID, Sticky bit

### 5.1 SUID (Set User ID) — bit 4

Quand un fichier exécutable avec SUID est lancé, il s'exécute **avec les droits du propriétaire**, pas de l'appelant.

```bash
# Exemple : /usr/bin/passwd (doit écrire dans /etc/shadow en tant que root)
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 59976 ... /usr/bin/passwd
#    ^ s = SUID activé

# Activer SUID
chmod u+s programme
chmod 4755 programme   # 4 = SUID

# Le s minuscule = SUID + x, le S majuscule = SUID sans x (bizarre)
```

### 5.2 SGID (Set Group ID) — bit 2

Sur un **fichier** : s'exécute avec le groupe du fichier.
Sur un **répertoire** : les nouveaux fichiers créés héritent du groupe du répertoire.

```bash
ls -l /usr/bin/write
# -rwxr-sr-x 1 root tty 19024 ... /usr/bin/write
#       ^ s = SGID sur fichier

# SGID sur un répertoire partagé
chmod g+s /projets/equipe/
ls -ld /projets/equipe/
# drwxrwsr-x 2 root developers 4096 ... /projets/equipe/

# Tout nouveau fichier dans ce dossier aura le groupe "developers"
```

### 5.3 Sticky bit — bit 1

Sur un **répertoire** : seul le propriétaire d'un fichier peut le supprimer (même si le groupe ou autres ont les droits d'écriture).

```bash
# Exemple : /tmp (tout le monde peut écrire, mais pas supprimer les fichiers des autres)
ls -ld /tmp
# drwxrwxrwt 15 root root 4096 ... /tmp
#          ^ t = sticky bit

chmod +t /repertoire/partage
chmod 1777 /repertoire/partage   # 1 = sticky bit

# T majuscule = sticky sans x, t minuscule = sticky avec x
```

```bash
# Récapitulatif des bits spéciaux en octal
# 4XXX : SUID
# 2XXX : SGID
# 1XXX : Sticky bit

chmod 4755 /usr/local/bin/monprog   # SUID + rwxr-xr-x
chmod 2775 /projets/equipe/         # SGID + rwxrwxr-x
chmod 1777 /tmp/partage/            # Sticky + rwxrwxrwx
```

> **Piège courant** : Les fichiers SUID root sont des vecteurs d'attaque. Vérifiez régulièrement avec `find / -perm -4000 -type f 2>/dev/null` les exécutables SUID root non attendus.

---

## 6. `sudo` et `su` — Élévation de privilèges

### 6.1 `sudo` — Superuser Do

```bash
# Exécuter une commande en root
sudo apt update
sudo systemctl restart nginx

# Shell root temporaire
sudo -i          # shell de login root
sudo -s          # shell non-login root
sudo su          # alternative

# Exécuter en tant qu'un autre utilisateur
sudo -u alice commande
sudo -u www-data bash

# Lister ses privilèges sudo
sudo -l

# Exécuter la dernière commande avec sudo
sudo !!

# Mémorisation du mot de passe (15 min par défaut)
sudo -v   # rafraîchir le cache
sudo -k   # invalider le cache immédiatement
```

### 6.2 Le fichier sudoers

```bash
# Éditer sudoers (TOUJOURS via visudo, jamais directement)
sudo visudo

# Structure du fichier /etc/sudoers :
# utilisateur  hôte=(utilisateur_cible)  commandes
alice    ALL=(ALL:ALL) ALL             # alice peut tout faire avec sudo
bob      ALL=(ALL) /usr/bin/apt       # bob peut seulement utiliser apt
www-data ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx  # sans mdp

# Fichiers inclus
/etc/sudoers.d/alice   # un fichier par utilisateur (meilleure pratique)
```

### 6.3 `su` — Switch User

```bash
su alice          # devenir alice (shell non-login)
su - alice        # devenir alice (shell de login, charge l'env)
su -              # devenir root (shell de login)
su -c "commande" alice  # exécuter une commande en tant qu'alice
```

---

## 7. Gestion des groupes et utilisateurs

```bash
# Afficher ses informations
id                 # uid=1000(alice) gid=1000(alice) groups=...
id alice           # infos d'un autre utilisateur
whoami             # nom d'utilisateur courant
groups             # groupes de l'utilisateur courant
groups alice       # groupes d'alice

# Ajouter un utilisateur à un groupe
sudo usermod -aG docker alice      # -a = append, -G = groupes supplémentaires
sudo usermod -aG sudo,adm alice    # plusieurs groupes

# IMPORTANT : se déconnecter et reconnecter pour que ça prenne effet
# Ou dans la session courante :
newgrp docker      # ouvrir un sous-shell avec le nouveau groupe

# Créer un groupe
sudo groupadd developers

# Supprimer du groupe
sudo gpasswd -d alice developers

# Voir les membres d'un groupe
getent group docker
cat /etc/group | grep docker
```

> **Astuce pro** : Après `usermod -aG`, le changement ne prend effet que dans les nouvelles sessions. Pour l'appliquer immédiatement sans se déconnecter, utilisez `newgrp nom_groupe` ou `exec su -l $USER`.

---

## 8. ACL — Listes de contrôle d'accès

Les ACL permettent des permissions plus fines que le modèle Unix de base (plusieurs utilisateurs/groupes avec des droits différents).

```bash
# Installer si nécessaire
sudo apt install acl   # Debian/Ubuntu

# Lire les ACL d'un fichier
getfacl fichier.txt
# file: fichier.txt
# owner: alice
# group: alice
# user::rw-
# group::r--
# other::r--

# Ajouter une ACL pour un utilisateur spécifique
setfacl -m u:bob:rw fichier.txt          # bob peut lire et écrire
setfacl -m g:developers:rx dossier/     # le groupe developers peut lire et exécuter

# ACL par défaut (héritées par les nouveaux fichiers dans un répertoire)
setfacl -d -m u:bob:rw /projets/partage/

# Supprimer une ACL
setfacl -x u:bob fichier.txt    # supprimer l'ACL de bob
setfacl -b fichier.txt          # supprimer toutes les ACL

# Copier les ACL
getfacl source.txt | setfacl --set-file=- destination.txt

# Vérifier : ls -l montre un + si des ACL sont présentes
ls -l fichier.txt
# -rw-rw-r--+ 1 alice alice ... fichier.txt
#           ^ le + indique des ACL supplémentaires
```

---

## Tableau récapitulatif

| Commande | Description | Exemple |
|----------|-------------|---------|
| `ls -l` | Voir les permissions | `ls -l /etc/passwd` |
| `chmod 755 f` | Permissions en octal | `chmod 644 fichier.txt` |
| `chmod u+x f` | Permissions symboliques | `chmod a+r public.html` |
| `chmod -R` | Récursif | `chmod -R 755 www/` |
| `chown u:g f` | Changer propriétaire + groupe | `chown alice:alice f` |
| `chgrp g f` | Changer le groupe | `chgrp www-data /var/www` |
| `umask` | Voir/définir le masque par défaut | `umask 022` |
| `chmod u+s` | Activer SUID | `chmod 4755 prog` |
| `chmod g+s` | Activer SGID | `chmod 2775 dossier/` |
| `chmod +t` | Sticky bit | `chmod 1777 /tmp/` |
| `sudo cmd` | Exécuter en root | `sudo apt update` |
| `sudo -u user` | Exécuter en tant qu'autre | `sudo -u www-data bash` |
| `id` | Infos utilisateur/groupes | `id alice` |
| `usermod -aG` | Ajouter au groupe | `usermod -aG docker alice` |
| `getfacl` | Lire les ACL | `getfacl fichier` |
| `setfacl -m` | Modifier une ACL | `setfacl -m u:bob:rw f` |

---

## À retenir

- Le modèle Unix : **user/group/other** × **read/write/execute** — chaque fichier appartient à un utilisateur et un groupe
- `chmod 755` (exécutable public) et `chmod 644` (fichier texte) sont les deux permissions les plus courantes
- Le **SUID** sur `/usr/bin/passwd` permet aux utilisateurs de changer leur mot de passe sans être root
- Le **sticky bit** sur `/tmp` empêche de supprimer les fichiers des autres
- Éditez toujours sudoers via `visudo` — jamais directement
- `usermod -aG` nécessite une reconnexion pour prendre effet

➡️ [Chapitre 5 — Flux, redirections et pipes](../05_flux_redirections/README.md)
