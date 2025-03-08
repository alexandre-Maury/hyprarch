#!/bin/bash

# script install_packages.sh

##############################################################################
## install_full_packages - Installation des utilitaires                                
##############################################################################
install_full_packages() {

    local pkg_base_hyprland="$TARGET_DIR/hyprarch/pkg-files/pkg_hyprland.txt"
    local pkg_utils_hyprland="$TARGET_DIR/hyprarch/pkg-files/pkg_utils_hyprland.txt"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DES APPLICATIONS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Installation des packages principaux
    echo "Installation des packages principaux..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        install_with_yay "$line"
    done < "$pkg_utils_hyprland"

    echo "" | tee -a "$LOG_FILES_INSTALL"

    echo "Installation des packages hypr principaux..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        install_with_yay "$line"
    done < "$pkg_base_hyprland"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES APPLICATIONS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}