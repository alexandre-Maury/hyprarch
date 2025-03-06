#!/usr/bin/bash

set -e  # Quitte immédiatement en cas d'erreur.

# Définition du répertoire du script
# SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Inclusion des fichiers de configuration et fonctions
source $TARGET_DIR/env/system.sh 
source $TARGET_DIR/config/config.sh 
source $TARGET_DIR/functions/functions.sh
source $TARGET_DIR/functions/functions_install.sh

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

# Vérification de la connexion Internet
check_internet() {
  echo "Vérification de la connexion Internet..."
  if ! curl -s --head https://archlinux.org | head -n 1 | grep "200 OK" > /dev/null; then
    echo "⚠️ Avertissement : Pas de connexion Internet ! Certaines fonctionnalités peuvent ne pas fonctionner."
  fi
}

# Création des dossiers nécessaires
create_dirs() {

  local dirs=(
    "${HOME}/.local/share/themes"
    "${HOME}/.local/share/icons"
    "${HOME}/.local/share/fonts"
    "${HOME}/.local/share/music"
    "${HOME}/.local/bin"
  )

  for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
  done

}

# Gestion des options
case "$1" in

  --install)

    check_internet
    create_dirs

    # export PATH=~/.local/bin:$PATH
    export PATH="$HOME/.local/bin:$PATH"

    clear

    # Logging
    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DÉBUT DE L'EXECUTION DU SCRIPT D'INSTALLATION  ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    read -p "Souhaitez-vous configurer votre compte git ? (Y/n) " git

    # Exécution des fonctions d'installation
    #config_system "$git"
    #install_yay
    #install_paru
    #install_paquages
    #install_repo
    #install_cups
    #install_drivers
    #install_fonts
    #install_conf
    # install_cron
    #install_firewall
    #install_clam
    #install_vpn
    #Activate_services
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
