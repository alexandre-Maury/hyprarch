#!/bin/bash

# script install_impression.sh

##############################################################################
## install_cups - Paramétrage de l'impression                              
##############################################################################
install_cups() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DU PARAMÉTRAGE DE L'IMPRESSION === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    cups_backup_file="${CUPS_CONF}.backup"

    # Création de la sauvegarde si elle n'existe pas
    if [ ! -f "$cups_backup_file" ]; then
        sudo cp "/etc/cups/cupsd.conf" "$cups_backup_file"
        echo "Sauvegarde créée : $cups_backup_file" | sudo tee -a "$LOG_FILES_INSTALL"
    fi

    # Vérifier si les groupes existent déjà
    if ! getent group lpadmin > /dev/null 2>&1; then
        echo "Création du groupe lpadmin..." | sudo tee -a "$LOG_FILES_INSTALL"
        sudo groupadd lpadmin
    else
        echo "Le groupe lpadmin existe déjà." | sudo tee -a "$LOG_FILES_INSTALL"
    fi

    if ! getent group lp > /dev/null 2>&1; then
        echo "Création du groupe lp..." | sudo tee -a "$LOG_FILES_INSTALL"
        sudo groupadd lp
    else
        echo "Le groupe lp existe déjà." | sudo tee -a "$LOG_FILES_INSTALL"
    fi

    # Vérifier si l'utilisateur est déjà dans les groupes
    if ! groups "$USER" | grep -q '\blpadmin\b'; then
        sudo usermod -aG lpadmin "$USER"
        echo "Utilisateur ajouté au groupe lpadmin." | sudo tee -a "$LOG_FILES_INSTALL"
    else
        echo "L'utilisateur est déjà membre du groupe lpadmin." | sudo tee -a "$LOG_FILES_INSTALL"
    fi

    if ! groups "$USER" | grep -q '\blp\b'; then
        sudo usermod -aG lp "$USER"
        echo "Utilisateur ajouté au groupe lp." | sudo tee -a "$LOG_FILES_INSTALL"
    else
        echo "L'utilisateur est déjà membre du groupe lp." | sudo tee -a "$LOG_FILES_INSTALL"
    fi

    
    # Suppression et ajout des directives d'écoute
    sudo sed -i '/^Listen/d' "/etc/cups/cupsd.conf"
    echo "Listen localhost:631" | sudo tee -a "/etc/cups/cupsd.conf" > /dev/null
    echo "Listen /var/run/cups/cups.sock" | sudo tee -a "/etc/cups/cupsd.conf" > /dev/null

    # Configuration des sections Location
    local config="
<Location />
  Order allow,deny
  Allow localhost
</Location>

<Location /admin>
  Order allow,deny
  Allow localhost
  AuthType Default
  Require valid-user
</Location>

<Location /admin/conf>
  Order allow,deny
  Allow localhost
  AuthType Default
  Require valid-user
</Location>"

    # Suppression des anciennes sections Location et ajout des nouvelles
    sudo sed -i '/<Location/,/<\/Location>/d' "/etc/cups/cupsd.conf"
    echo "$config" | sudo tee -a "/etc/cups/cupsd.conf" > /dev/null

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DU PARAMÉTRAGE DE L'IMPRESSION TERMINEE === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"


}
