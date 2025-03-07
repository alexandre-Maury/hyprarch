#!/bin/bash

# script install_services.sh

##############################################################################
## activate_services - Activation des services                                              
##############################################################################
activate_services() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== ACTIVATION DES SERVICES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Fonction pour loguer le succès ou l'échec
    log_status() {
        if [ $? -eq 0 ]; then
            echo "$1 - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
        else
            echo "$1 - ERREUR" | tee -a "$LOG_FILES_INSTALL"
        fi
    }

    # Activation des services
    sudo systemctl enable --now mpd.service
    log_status "Activation de mpd.service"

    systemctl --user enable --now pipewire
    log_status "Activation de pipewire"

    systemctl --user enable --now pipewire-pulse
    log_status "Activation de pipewire-pulse"

    systemctl --user enable --now wireplumber
    log_status "Activation de wireplumber"

    sudo systemctl enable --now cups
    log_status "Activation de cups"

    sudo usermod -aG libvirt $(whoami)
    sudo systemctl enable --now libvirtd
    log_status "Activation de libvirtd"

    sudo usermod -aG docker $(whoami)
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    log_status "Activation de docker.service"

    sudo systemctl enable --now systemd-journald.service
    log_status "Activation de systemd-journald.service"

    sudo systemctl enable --now nftables.service
    log_status "Activation de nftables.service"

    # Activation optionnelle (commentée dans votre script original)
    # sudo systemctl enable --now logrotate.service
    # log_status "Activation de logrotate.service"

    # sudo systemctl enable --now rsyslog.service
    # log_status "Activation de rsyslog.service"

    sudo systemctl enable --now cronie
    log_status "Activation de cronie"

    sudo systemctl enable --now clamav-daemon.service
    log_status "Activation de clamav-daemon.service"

    sudo systemctl enable --now sddm.service
    log_status "Activation de sddm"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'ACTIVATION DES SERVICES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}