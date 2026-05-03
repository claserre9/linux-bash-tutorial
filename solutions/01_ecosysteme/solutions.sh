#!/usr/bin/env bash
# Solutions — Chapitre 1 : Écosystème Linux
# Exécutez : bash solutions.sh

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

    echo "--- Distribution Linux ---"
    if [ -f /etc/os-release ]; then
        cat /etc/os-release
    else
        echo "(fichier /etc/os-release non disponible sur ce système)"
    fi

    echo ""
    echo "--- Version du noyau ---"
    uname -r

    echo ""
    echo "--- Architecture ---"
    uname -m

    echo ""
    echo "--- Toutes les infos uname ---"
    uname -a

    if [ -f /etc/os-release ]; then
        echo "✓ /etc/os-release existe — vérification OK"
    else
        echo "⚠ /etc/os-release introuvable (macOS ou BSD ?)"
    fi
}

# 1.2 — Manipuler les variables d'environnement
ex_2() {
    echo ""
    echo "=== Exercice 1.2 : Variables d'environnement ==="
    echo ""

    echo "Shell courant    : $SHELL"
    echo "Répertoire home  : $HOME"
    echo "Nom utilisateur  : $USER"

    echo ""
    MA_VAR="Alice"
    echo "MA_VAR = $MA_VAR"

    echo ""
    echo "--- Contenu de \$PATH (un répertoire par ligne) ---"
    echo "$PATH" | tr ':' '\n'

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

    echo "--- Nature des commandes ---"
    type cd
    type ls
    type echo
    # type grep (commande externe)
    type grep 2>/dev/null || echo "grep : non trouvé (normal hors Linux)"

    echo ""
    echo "--- Chemins des commandes ---"
    which grep
    which bash

    echo ""
    echo "--- Alias défini et utilisé ---"
    alias lsl='ls -la --color=auto' 2>/dev/null || true
    # L'alias n'est utilisable que dans un shell interactif
    # On utilise directement ls ici pour la démonstration
    ls -la /tmp | head -5
    echo "(alias lsl='ls -la --color=auto' créé pour la session)"

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

    echo "--- 10 dernières commandes ---"
    history 10 2>/dev/null || echo "(historique non accessible dans ce contexte non-interactif)"

    echo ""
    echo "--- Commandes 'ls' dans l'historique ---"
    history 2>/dev/null | grep "ls" | head -5 || echo "(non accessible hors shell interactif)"

    echo ""
    echo "--- Nombre de commandes dans l'historique ---"
    NB=$(history 2>/dev/null | wc -l)
    if [ "$NB" -gt 0 ]; then
        echo "$NB entrées dans l'historique"
    else
        echo "(historique non accessible dans les scripts — normal)"
        echo "Testez directement dans votre terminal : history | wc -l"
    fi

    echo ""
    echo "--- Rappel des raccourcis d'historique ---"
    echo "  !!         → répéter la dernière commande"
    echo "  !42        → répéter la commande n°42"
    echo "  !git       → dernière commande commençant par 'git'"
    echo "  Ctrl+R     → recherche incrémentale dans l'historique"
    echo "  Alt+.      → insérer le dernier argument"
}

# 1.5 — Configuration du shell
ex_5() {
    echo ""
    echo "=== Exercice 1.5 : Configuration du shell ==="
    echo ""

    SHELL_NAME=$(basename "$SHELL")
    echo "Votre shell : $SHELL_NAME"

    # Identifier le fichier de configuration
    CONFIG_FILE=""
    if [ "$SHELL_NAME" = "bash" ]; then
        CONFIG_FILE="$HOME/.bashrc"
    elif [ "$SHELL_NAME" = "zsh" ]; then
        CONFIG_FILE="$HOME/.zshrc"
    fi

    echo ""
    echo "--- Fin de votre fichier de configuration ---"
    if [ -f "$CONFIG_FILE" ]; then
        echo "Fichier : $CONFIG_FILE"
        echo "Dernières 20 lignes :"
        tail -20 "$CONFIG_FILE"
    else
        echo "Fichier $CONFIG_FILE non trouvé"
        echo "Fichiers de config existants dans \$HOME :"
        ls -la "$HOME"/.*rc "$HOME"/.*_profile 2>/dev/null | head -10
    fi

    echo ""
    echo "--- Alias recommandés à ajouter dans $CONFIG_FILE ---"
    echo "  alias ll='ls -alF --color=auto'"
    echo "  alias la='ls -A'"
    echo "  alias l='ls -CF'"
    echo "  alias ..='cd ..'"
    echo "  alias ...='cd ../..'"
    echo "  alias gs='git status'"
    echo "  alias gd='git diff'"
    echo "  alias grep='grep --color=auto'"
    echo ""
    echo "Pour ajouter et activer :"
    echo "  echo \"alias gs='git status'\" >> $CONFIG_FILE"
    echo "  source $CONFIG_FILE"

    echo ""
    if [ -f "$CONFIG_FILE" ]; then
        NB_LIGNES=$(wc -l < "$CONFIG_FILE")
        echo "✓ Fichier de config trouvé : $CONFIG_FILE ($NB_LIGNES lignes)"
    fi
}

main
