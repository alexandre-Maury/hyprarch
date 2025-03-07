#!/bin/bash

# script install_fonts.sh

##############################################################################
## install_fonts - Installation des fonts                                
##############################################################################
install_all_fonts() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DES FONTS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    for url in "${URL_FONTS[@]}"; do

        file_name=$(basename "$url")

        if [[ -f "$HOME/.local/share/fonts/$file_name" ]]; then
            echo "La fonts $file_name est déjà installée, passage au suivant..." | tee -a "$LOG_FILES_INSTALL"
            continue
        fi

        echo "Installation de la fonts : $file_name..." | tee -a "$LOG_FILES_INSTALL"
        curl -LsS "$url" -o "$HOME/.local/share/fonts/$file_name"
    done    


    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES FONTS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}