#!/usr/bin/env bash
# Exercices — Chapitre 1 : Écosystème Linux
# Exécutez : bash exercices.sh
#
# Objectifs :
#   - Identifier la distribution et la version du noyau
#   - Manipuler les variables d'environnement
#   - Utiliser type, which, alias
#   - Maîtriser les raccourcis de l'historique
#   - Configurer un alias permanent

main() {
    ex_1
    ex_2
    ex_3
    ex_4
    ex_5
    echo ""
    echo "Tous les exercices terminés ✅"
}

# 1.1 — Identifier l'environnement système
ex_1() {
    echo "=== Exercice 1.1 : Identifier l'environnement ==="
    echo ""

    # TODO : Affichez les informations suivantes en utilisant les bonnes commandes.
    # Pour chaque point, remplacez la commande TODO par la commande appropriée.

    echo "--- Distribution Linux ---"
    # TODO : Affichez le contenu de /etc/os-release (utilisez cat)
    echo "[TODO : remplacez cette ligne par : cat /etc/os-release]"

    echo ""
    echo "--- Version du noyau ---"
    # TODO : Affichez la version du noyau avec uname -r
    echo "[TODO : remplacez cette ligne par : uname -r]"

    echo ""
    echo "--- Architecture ---"
    # TODO : Affichez l'architecture avec uname -m
    echo "[TODO : remplacez cette ligne par : uname -m]"

    # Vérification automatique
    if [ -f /etc/os-release ]; then
        echo ""
        echo "✓ /etc/os-release existe — vérification OK"
    else
        echo "⚠ /etc/os-release introuvable (système non-Linux ?)"
    fi
}

# 1.2 — Manipuler les variables d'environnement
ex_2() {
    echo ""
    echo "=== Exercice 1.2 : Variables d'environnement ==="
    echo ""

    # TODO : Affichez les variables d'environnement suivantes
    echo "Shell courant    : [TODO : echo \$SHELL]"
    echo "Répertoire home  : [TODO : echo \$HOME]"
    echo "Nom utilisateur  : [TODO : echo \$USER]"

    echo ""
    # TODO : Créez une variable MA_VAR avec votre prénom, puis affichez-la
    # MA_VAR="VotrePrénom"
    # echo "MA_VAR = $MA_VAR"
    echo "[TODO : définissez MA_VAR et affichez-la]"

    echo ""
    # TODO : Affichez le PATH formaté (un répertoire par ligne)
    # Indice : echo $PATH | tr ':' '\n'
    echo "--- Contenu de \$PATH (un répertoire par ligne) ---"
    echo "[TODO : echo \$PATH | tr ':' '\\n']"

    # Vérification
    echo ""
    if [ -n "$HOME" ] && [ -n "$USER" ]; then
        echo "✓ Variables HOME et USER définies : HOME=$HOME, USER=$USER"
    else
        echo "✗ Variables HOME ou USER manquantes"
    fi
}

# 1.3 — Utiliser type, which, alias
ex_3() {
    echo ""
    echo "=== Exercice 1.3 : type, which, alias ==="
    echo ""

    # TODO : Utilisez 'type' pour identifier la nature de chaque commande :
    # cd, ls, echo, grep, python3 (ou python)
    # Indice : type cd
    echo "--- Nature des commandes ---"
    echo "[TODO : type cd]"
    echo "[TODO : type ls]"
    echo "[TODO : type echo]"

    echo ""
    # TODO : Trouvez le chemin absolu de grep et bash avec 'which'
    echo "--- Chemins des commandes ---"
    echo "[TODO : which grep]"
    echo "[TODO : which bash]"

    echo ""
    # TODO : Créez un alias 'lsl' pour 'ls -la --color=auto'
    # puis utilisez-le pour lister /tmp
    echo "--- Alias ---"
    echo "[TODO : alias lsl='ls -la --color=auto' puis lsl /tmp]"

    # Vérification automatique
    BASH_PATH=$(which bash 2>/dev/null)
    if [ -n "$BASH_PATH" ]; then
        echo ""
        echo "✓ bash trouvé à : $BASH_PATH"
    fi
}

# 1.4 — Historique et raccourcis
ex_4() {
    echo ""
    echo "=== Exercice 1.4 : Historique des commandes ==="
    echo ""

    # TODO : Affichez les 10 dernières commandes de l'historique
    echo "--- 10 dernières commandes ---"
    echo "[TODO : history 10]"

    echo ""
    # TODO : Cherchez dans l'historique toutes les commandes contenant 'ls'
    # Indice : history | grep "ls"
    echo "--- Commandes 'ls' dans l'historique ---"
    echo "[TODO : history | grep 'ls']"

    echo ""
    # TODO : Comptez le nombre total de commandes dans l'historique
    # Indice : history | wc -l
    echo "--- Nombre de commandes dans l'historique ---"
    echo "[TODO : history | wc -l]"

    # Vérification
    NB=$(history 2>/dev/null | wc -l)
    if [ "$NB" -gt 0 ] 2>/dev/null; then
        echo ""
        echo "✓ Historique disponible ($NB entrées)"
    else
        echo "⚠ Historique non accessible depuis ce script (normal)"
        echo "  Testez ces commandes directement dans votre terminal"
    fi
}

# 1.5 — Configuration du shell
ex_5() {
    echo ""
    echo "=== Exercice 1.5 : Configuration du shell ==="
    echo ""

    # TODO : Identifiez votre fichier de configuration shell
    # Si SHELL contient bash → ~/.bashrc
    # Si SHELL contient zsh  → ~/.zshrc
    SHELL_NAME=$(basename "$SHELL")
    echo "Votre shell : $SHELL_NAME"

    # TODO : Affichez les 20 dernières lignes de votre fichier de config
    # Indice : tail -20 ~/.bashrc  (ou ~/.zshrc)
    echo ""
    echo "--- Fin de votre fichier de configuration ---"
    if [ "$SHELL_NAME" = "bash" ] && [ -f "$HOME/.bashrc" ]; then
        echo "[TODO : tail -20 ~/.bashrc]"
    elif [ "$SHELL_NAME" = "zsh" ] && [ -f "$HOME/.zshrc" ]; then
        echo "[TODO : tail -20 ~/.zshrc]"
    else
        echo "[TODO : identifiez et affichez votre fichier de config]"
    fi

    echo ""
    # TODO : Ajoutez un alias utile dans votre .bashrc/.zshrc
    # Exemple : alias gs='git status'
    # N'oubliez pas de recharger avec : source ~/.bashrc
    echo "--- Action manuelle requise ---"
    echo "1. Ouvrez votre ~/.bashrc (ou ~/.zshrc)"
    echo "2. Ajoutez : alias gs='git status'"
    echo "3. Rechargez : source ~/.bashrc"
    echo "4. Testez : type gs"

    # Vérification
    CONFIG_FILE=""
    if [ "$SHELL_NAME" = "bash" ]; then
        CONFIG_FILE="$HOME/.bashrc"
    elif [ "$SHELL_NAME" = "zsh" ]; then
        CONFIG_FILE="$HOME/.zshrc"
    fi

    echo ""
    if [ -f "$CONFIG_FILE" ]; then
        NB_LIGNES=$(wc -l < "$CONFIG_FILE")
        echo "✓ Fichier de config trouvé : $CONFIG_FILE ($NB_LIGNES lignes)"
    else
        echo "⚠ Fichier de config non trouvé à : $CONFIG_FILE"
    fi
}

main
