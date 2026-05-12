# Tutoriel Linux & Bash — Du débutant à l'expert

Parcours progressif en **3 niveaux** pour maîtriser la ligne de commande Linux, le traitement de texte, et l'écriture de scripts Bash robustes.

Cible : **Linux moderne** (Ubuntu 22.04+, Debian 12+, RHEL 9+), **Bash 5+**. Outils : `grep`, `sed`, `awk`, `find`, `curl`, `ssh`, `shellcheck`.

## Structure du projet

```
linux-bash-tutorial/
├── cours/          # Leçons théoriques avec exemples exécutables
├── exercices/      # Exercices pratiques par chapitre
├── solutions/      # Corrections commentées
└── annexes/        # Références et ressources complémentaires
```

## Sommaire

### Niveau 1 — Fondamentaux Linux
*Projet fil rouge : script d'audit et de rapport système*

| # | Chapitre | Thèmes abordés |
|---|----------|----------------|
| 1 | [Écosystème Linux](cours/01_ecosysteme/README.md) | distributions, terminal, shell, `man`, `tldr` |
| 2 | [Navigation et système de fichiers](cours/02_navigation_filesystem/README.md) | `pwd`, `ls`, `cd`, `find`, `tree`, `stat` |
| 3 | [Manipulation de fichiers](cours/03_manipulation_fichiers/README.md) | `cp`, `mv`, `rm`, `mkdir`, `cat`, `less`, `ln` |
| 4 | [Permissions et ownership](cours/04_permissions_ownership/README.md) | `chmod`, `chown`, `umask`, `sudo` |
| 5 | [Flux, redirections et pipes](cours/05_flux_redirections/README.md) | `stdin`/`stdout`/`stderr`, `>`, `>>`, `\|`, `tee` |
| 6 | [Recherche et filtrage](cours/06_recherche_filtrage/README.md) | `grep`, `find`, `locate`, `xargs` — **Projet : audit système** |

### Niveau 2 — Traitement de texte et shell
*Projet fil rouge : parseur de logs et rapport HTML*

| # | Chapitre | Thèmes abordés |
|---|----------|----------------|
| 7 | [Traitement de texte](cours/07_traitement_texte/README.md) | `sed`, `awk`, `cut`, `sort`, `uniq`, `tr`, `wc` |
| 8 | [Bash : variables, conditions, boucles](cours/08_bash_variables_conditions/README.md) | `if`, `case`, `for`, `while` |
| 9 | [Bash : fonctions, scripts modulaires](cours/09_bash_fonctions_scripts/README.md) | fonctions, `getopts`, modularité |
| 10 | [Processus et jobs](cours/10_processus_jobs/README.md) | `ps`, `top`, `kill`, signaux, `cron`, `systemd timers` |
| 11 | [Réseau](cours/11_reseau/README.md) | `curl`, `wget`, `ssh`, `scp`, `rsync`, `dig`, `ss` — **Projet : parseur logs** |

### Niveau 3 — Scripting avancé
*Projet fil rouge : toolkit de déploiement automatisé*

| # | Chapitre | Thèmes abordés |
|---|----------|----------------|
| 12 | [Regex avancées](cours/12_regex_avancees/README.md) | ERE, PCRE, lookahead, groupes nommés, `grep`/`sed`/`awk` |
| 13 | [Robustesse et gestion d'erreurs](cours/13_robustesse_erreurs/README.md) | `set -euo pipefail`, `trap`, codes de sortie, `shellcheck` |
| 14 | [Bash avancé](cours/14_bash_avance/README.md) | tableaux, tableaux associatifs, here-docs, substitution de processus |
| 15 | [Administration système](cours/15_administration_systeme/README.md) | utilisateurs, packages, `systemd`, journaux |
| 16 | [Automatisation et CI](cours/16_automatisation_ci/README.md) | `cron`, `Makefile`, GitHub Actions, conteneurs — **Projet : déploiement automatisé** |

### Annexes

| | Annexe | Contenu |
|--|--------|---------|
| A | [Aide-mémoire des commandes essentielles](annexes/A_aide_memoire.md) | Référence rapide des commandes clés |
| B | [One-liners utiles](annexes/B_one_liners.md) | `grep`/`sed`/`awk` en une ligne |

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

## Licence

MIT — Clifford