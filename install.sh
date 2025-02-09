#!/usr/bin/bash

set -e  # Quitte immédiatement en cas d'erreur.

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $SCRIPT_DIR/env/system.sh 
source $SCRIPT_DIR/config/config.sh 
source $SCRIPT_DIR/functions/functions.sh
source $SCRIPT_DIR/functions/functions_install.sh

# Fonction pour afficher l'aide
usage() {
  echo "Usage : $0 [--install | --save]"
  echo
  echo "Options :"
  echo "  --install       Lance le processus d'installation."
  echo "  --save          Sauvegarde la configuration."
  exit 1
}

# Vérifie les arguments passés
if [ "$#" -ne 1 ]; then
  usage
fi

# Vérification si le script est exécuté en tant que root
if [ "$EUID" -eq 0 ]; then
  echo
  echo "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
  exit 1
fi

# Vérification de la connexion Internet pour --install
check_internet() {
  echo
  echo "Vérification de la connexion Internet"
  if ! ping -c 3 archlinux.org &>/dev/null; then
    echo "Pas de connexion Internet"
    exit 1
  fi
  sleep 2
}

# Gestion des options
case "$1" in

  --install)

    check_internet

    # Création des dossiers nécessaires
    mkdir -p "${HOME}/.local/share/themes"
    mkdir -p "${HOME}/.local/share/icons"
    mkdir -p "${HOME}/.local/share/fonts"
    mkdir -p "${HOME}/.local/share/music"
    mkdir -p "${HOME}/.local/bin"

    export PATH=~/.local/bin:$PATH

    clear

    # Logging
    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DÉBUT DE L'EXECUTION DU SCRIPT D'INSTALLATION  ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    read -p "Souhaitez-vous configurer votre compte git ? (Y/n) " git

    # Exécution des fonctions d'installation
    config_system "$git"
    install_yay
    install_paru
    install_paquages
    install_repo
    install_cups
    install_drivers
    install_fonts
    install_conf
    # install_cron
    install_firewall
    Activate_services
    ;;

  --save)
    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== SAUVEGARDE DE LA CONFIGURATION ===" | tee -a "$LOG_FILES_INSTALL"
    save_conf
    echo "Sauvegarde terminée." 
    ;;

  *)
    usage
    ;;
esac
