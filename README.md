# Tutoriel Linux & Bash — Du débutant à l'expert

Parcours progressif en **3 niveaux** pour maîtriser la ligne de commande Linux, le traitement de texte, et l'écriture de scripts Bash robustes.

Cible : **Linux moderne** (Ubuntu 22.04+, Debian 12+, RHEL 9+), **Bash 5+**. Outils : `grep`, `sed`, `awk`, `find`, `curl`, `ssh`, `shellcheck`.

## Structure

- `cours/` — théorie commentée avec exemples exécutables
- `exercices/` — énoncés à compléter
- `solutions/` — corrigés commentés

Chaque niveau se termine par un **projet fil rouge** qui consolide les chapitres précédents.

## Sommaire

### Niveau 1 — Fondamentaux Linux
*Projet fil rouge : script d'audit et de rapport système*

1. Écosystème Linux (distributions, terminal, shell, `man`, `tldr`)
2. Navigation et système de fichiers (`pwd`, `ls`, `cd`, `find`, `tree`, `stat`)
3. Manipulation de fichiers (`cp`, `mv`, `rm`, `mkdir`, `cat`, `less`, `ln`)
4. Permissions et ownership (`chmod`, `chown`, `umask`, `sudo`)
5. Flux, redirections et pipes (`stdin`/`stdout`/`stderr`, `>`, `>>`, `|`, `tee`)
6. Recherche et filtrage (`grep`, `find`, `locate`, `xargs`) — **+ projet audit**

### Niveau 2 — Traitement de texte et shell
*Projet fil rouge : parseur de logs et rapport HTML*

7. Traitement de texte (`sed`, `awk`, `cut`, `sort`, `uniq`, `tr`, `wc`)
8. Bash : variables, conditions, boucles (`if`, `case`, `for`, `while`)
9. Bash : fonctions, scripts modulaires, `getopts`
10. Processus et jobs (`ps`, `top`, `kill`, signaux, `cron`, `systemd timers`)
11. Réseau (`curl`, `wget`, `ssh`, `scp`, `rsync`, `dig`, `ss`) — **+ projet parseur**

### Niveau 3 — Scripting avancé
*Projet fil rouge : toolkit de déploiement automatisé*

12. Regex avancées (ERE, PCRE, lookahead, groupes nommés, `grep`/`sed`/`awk`)
13. Robustesse et gestion d'erreurs (`set -euo pipefail`, `trap`, codes de sortie, `shellcheck`)
14. Bash avancé (tableaux, tableaux associatifs, here-docs, substitution de processus)
15. Administration système (utilisateurs, packages, `systemd`, journaux)
16. Automatisation et CI (`cron`, `Makefile`, GitHub Actions, conteneurs) — **+ projet déploiement**

### Annexes
- **A.** Aide-mémoire des commandes essentielles
- **B.** One-liners utiles (`grep`/`sed`/`awk` en une ligne)

## Prérequis

- Un terminal Linux ou macOS (ou WSL2 sous Windows)
- Bash 5+ : `bash --version`
- Optionnel : `shellcheck` pour la validation des scripts

## Comment étudier

1. Lire `cours/NN_.../README.md`
2. Faire les exercices dans `exercices/NN_.../`
3. Comparer avec `solutions/NN_.../` **après** avoir tenté
4. Ne pas sauter les encadrés "Piège courant" et "Astuce pro"

Commencez par [Chapitre 1 — Écosystème Linux](cours/01_ecosysteme/README.md).
