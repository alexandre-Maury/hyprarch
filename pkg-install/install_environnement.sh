#!/bin/bash

# script install_environnement.sh

##############################################################################
## install_environnement - Configuration du systeme                                                 
##############################################################################
install_environnement() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DÉBUT DE LA CONFIGURATION DU SYSTEME ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    clear && echo

    echo "Activation de la synchronisation de l'heure via NTP..." | tee -a "$LOG_FILES_INSTALL"
    sudo timedatectl set-ntp true

    echo "Configuration du fuseau horaire : ${REGION}/${CITY}..." | tee -a "$LOG_FILES_INSTALL"
    sudo timedatectl set-timezone ${REGION}/${CITY}

    echo "Configuration des locales : LANG=${LANG}, LC_TIME=${LANG}..." | tee -a "$LOG_FILES_INSTALL"
    sudo localectl set-locale LANG="${LANG}" LC_TIME="${LANG}"

    echo "Synchronisation de l'horloge matérielle avec l'heure UTC..." | tee -a "$LOG_FILES_INSTALL"
    sudo hwclock --systohc --utc

    echo "Vérification de l'état du service de gestion du temps..." | tee -a "$LOG_FILES_INSTALL"
    timedatectl status | tee -a "$LOG_FILES_INSTALL"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE LA CONFIGURATION DU SYSTEME ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}