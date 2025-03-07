#!/bin/bash

# script install_aur.sh


##############################################################################
## install_aur_yay - Installation de YAY                                               
##############################################################################
install_aur_yay() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DU PAQUET YAY ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Vérifier si le paquet est déjà installé
    if pacman -Qi yay 2>&1; then
        echo "Le paquets yay est déjà installé..." | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Installation du paquets yay..." | tee -a "$LOG_FILES_INSTALL"
        git clone https://aur.archlinux.org/yay-bin.git $TARGET_DIR/tmp/yay-bin
        cd $TARGET_DIR/tmp/yay-bin || exit
        makepkg -si --noconfirm && cd .. 
        echo "Installation du paquets yay terminé..." | tee -a "$LOG_FILES_INSTALL"
    fi

    yay -Syu --devel --noconfirm

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DU PAQUET YAY ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}

##############################################################################
## install_aur_paru - Installation de PARU                                                 
##############################################################################
install_aur_paru() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DU PAQUET PARU ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    if [[ "$PARU" == "On" ]]; then

        # Vérifier si le paquet est déjà installé
        if pacman -Qi paru 2>&1; then
            echo "Le paquets paru est déjà installé..." | tee -a "$LOG_FILES_INSTALL"
        else
            echo "Installation du paquets paru..." | tee -a "$LOG_FILES_INSTALL"
            git clone https://aur.archlinux.org/paru.git $TARGET_DIR/tmp/paru
            cd $TARGET_DIR/tmp/paru || exit
            makepkg -si --noconfirm && cd .. 
            echo "Installation du paquets paru terminé..." | tee -a "$LOG_FILES_INSTALL"
        fi
    else
        echo "Le paquets paru n'est pas sélectionner dans le fichier config.sh..."
    fi

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DU PAQUET PARU ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}