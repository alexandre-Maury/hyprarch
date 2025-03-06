#!/bin/bash

# script install_packages.sh

##############################################################################
## install_full_packages - Installation des utilitaires                                
##############################################################################
install_full_packages() {

    local deps="$TARGET_DIR/pkg-files/deps.txt"
    local packages="$TARGET_DIR/pkg-files/packages.txt"
    local packages_hypr="$TARGET_DIR/pkg-files/packages_hypr.txt"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DE L'INSTALLATION DES APPLICATIONS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Installation des dépendances
    echo "Installation des dépendances..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        install_with_yay "$line"
    done < "$deps"

    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Installation des packages principaux
    echo "Installation des packages principaux..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        install_with_yay "$line"
    done < "$packages"

    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Installation des packages principaux hypr
    echo "Installation des packages hypr principaux..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        install_with_yay "$line"
    done < "$packages_hypr"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES APPLICATIONS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}