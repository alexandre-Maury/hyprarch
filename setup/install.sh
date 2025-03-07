#!/usr/bin/bash

set -e  # Quitte immédiatement en cas d'erreur.

# Définition du répertoire du script
# SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Inclusion des fichiers de configuration et fonctions
source $TARGET_DIR/hyprarch/env/system.sh 
source $TARGET_DIR/hyprarch/env/functions.sh

source $TARGET_DIR/hyprarch/config/config.sh 

source $TARGET_DIR/hyprarch/pkg-install/install_environnement.sh
source $TARGET_DIR/hyprarch/pkg-install/install_aur.sh
source $TARGET_DIR/hyprarch/pkg-install/install_packages.sh
source $TARGET_DIR/hyprarch/pkg-install/install_repo.sh
source $TARGET_DIR/hyprarch/pkg-install/install_impression.sh
source $TARGET_DIR/hyprarch/pkg-install/install_drivers.sh
source $TARGET_DIR/hyprarch/pkg-install/install_fonts.sh
source $TARGET_DIR/hyprarch/pkg-install/install_dotfiles.sh
source $TARGET_DIR/hyprarch/pkg-install/install_securite.sh
source $TARGET_DIR/hyprarch/pkg-install/install_services.sh

# Fonction pour afficher l'aide
usage() {
  echo "Usage : $0 [--install | --save]"
  echo
  echo "Options :"
  echo "  --install       Lance le processus d'installation."
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

    if [[ "$git" =~ ^[yY]$ ]]; then
        echo
        clear
        echo "Configuration des identifiants github..." | tee -a "$LOG_FILES_INSTALL"
        echo
        read -p " Entrez votre nom d'utilisateur [git] : " git_name
        read -p " Entrez votre adresse email [git] : " git_email	

        git config --global user.name "${git_name}"
        git config --global user.email "${git_email}"
      
    fi

    # Exécution des fonctions d'installation
    # install_environnement
    # install_aur_yay
    # install_aur_paru
    # install_full_packages
    # install_repo_autocpufreq
    # install_repo_ohmyzsh
    # install_repo_asdf
    # install_cups
    # install_all_drivers
    # install_all_fonts
    install_all_dotfiles
    # install_firewall
    # install_clam
    # install_vpn
    # activate_services
    ;;

  *)
    usage
    ;;
esac
