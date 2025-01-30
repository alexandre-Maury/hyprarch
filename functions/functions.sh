#!/usr/bin/env bash

# script functions.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHT_CYAN='\033[0;96m'
RESET='\033[0m'

log_prompt() {
    local log_level="$1" # INFO - WARNING - ERROR - SUCCESS
    local log_date="$(date +"%Y-%m-%d %H:%M:%S")"

    case "${log_level}" in

        "SUCCESS")
            log_color="${GREEN}"
            log_status='SUCCESS'
            ;;
        "WARNING")
            log_color="${YELLOW}"
            log_status='WARNING'
            ;;
        "ERROR")
            log_color="${RED}"
            log_status='ERROR'
            ;;
        "INFO")
            log_color="${LIGHT_CYAN}"
            log_status='INFO'
            ;;
        *)
            log_color="${RESET}" # Au cas où un niveau inconnu est utilisé
            log_status='UNKNOWN'
            ;;
    esac

    echo -ne "${log_color} [ ${log_status} ] "${log_date}" ==> ${RESET}"

}

# Fonction pour installer un paquet avec yay
install_with_yay() {

    local package="$1"

    # Vérifier si le paquet est déjà installé
    if yay -Qi $package 2>&1; then
        echo "Le paquets $package est déjà installé" | tee -a "$LOG_FILES_INSTALL"
        return 0
    else

        echo "Installation du paquets $package" | tee -a "$LOG_FILES_INSTALL"
        if yay -S --needed --noconfirm --ask=4 $package 2>&1; then
            echo "Installation réussie : $package" | tee -a "$LOG_FILES_INSTALL"
        else
            echo "Erreur d'installation : $package" | tee -a "$LOG_FILES_INSTALL"
            return 1
        fi
    fi
}

# Fonction pour installer un paquet avec pacman
install_with_pac() {

    local package="$1"

    # Vérifier si le paquet est déjà installé
    if pacman -Qi $package 2>&1; then
        echo "Le paquets $package est déjà installé" | tee -a "$LOG_FILES_INSTALL"
        return 0
    else

        echo "Installation du paquets $package" | tee -a "$LOG_FILES_INSTALL"
        if sudo pacman -S --needed --noconfirm $package 2>&1; then
            echo "Installation réussie : $package" | tee -a "$LOG_FILES_INSTALL"
        else
            echo "Erreur d'installation : $package" | tee -a "$LOG_FILES_INSTALL"
            return 1
        fi
    fi
}

# Vérifie si les modules sont présents dans le système
check_module_exists() {
    modprobe -n -v "$1" &>/dev/null
}

# Fonction pour gérer les fichiers de configuration modprobe
configure_modprobe_file() {
    
    local file_name="$1"
    shift
    local options=("$@")

    # Vérifier si le fichier existe déjà
    if [[ -f "/etc/modprobe.d/${file_name}" ]]; then
        echo "Le fichier /etc/modprobe.d/${file_name} existe déjà. Aucune modification nécessaire." | tee -a "$LOG_FILES_INSTALL"
        echo "" | tee -a "$LOG_FILES_INSTALL"  
    else
        # Création du fichier et ajout des options
        echo "Création du fichier /etc/modprobe.d/$file_name avec les options suivantes :" | tee -a "$LOG_FILES_INSTALL"
        for option in "${options[@]}"; do
            echo "$option" | sudo tee -a "/etc/modprobe.d/$file_name"
        done
        echo "Fichier $file_name configuré avec succès." | tee -a "$LOG_FILES_INSTALL"
    fi
}


















