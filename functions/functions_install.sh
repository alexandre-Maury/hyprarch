#!/bin/bash

# script functions_install.sh

# https://hyprpanel.com/getting_started/hyprpanel.html

##############################################################################
## config_system - Configuration du systeme                                                 
##############################################################################
config_system() {

    local git=$1

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DÉBUT DE LA CONFIGURATION DU SYSTEME ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    clear && echo

    if [[ "$git" =~ ^[yY]$ ]]; then
        echo
        echo "Configuration des identifiants github..." | tee -a "$LOG_FILES_INSTALL"
        echo
        read -p " [git] Entrez votre nom d'utilisateur : " git_name
        read -p " [git] Entrez votre adresse email : " git_email	

        git config --global user.name "${git_name}"
        git config --global user.email "${git_email}"
      
    fi

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

##############################################################################
## install_yay - Installation de YAY                                               
##############################################################################
install_yay() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DE L'INSTALLATION DU PAQUET YAY ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Vérifier si le paquet est déjà installé
    if pacman -Qi yay 2>&1; then
        echo "Le paquets yay est déjà installé..." | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Installation du paquets yay..." | tee -a "$LOG_FILES_INSTALL"
        git clone https://aur.archlinux.org/yay-bin.git $HOME/.config/build/tmp/yay-bin
        cd $HOME/.config/build/tmp/yay-bin || exit
        makepkg -si --noconfirm && cd .. 
        echo "Installation du paquets yay terminé..." | tee -a "$LOG_FILES_INSTALL"
    fi

    yay -Syu --devel --noconfirm

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DU PAQUET YAY ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}

##############################################################################
## install_paru - Installation de PARU                                                 
##############################################################################
install_paru() {

    if [[ "$PARU" == "On" ]]; then

        echo "" | tee -a "$LOG_FILES_INSTALL"
        echo "=== RECHERCHE DE L'INSTALLATION DU PAQUET PARU ===" | tee -a "$LOG_FILES_INSTALL"
        echo "" | tee -a "$LOG_FILES_INSTALL"


        # Vérifier si le paquet est déjà installé
        if pacman -Qi paru 2>&1; then
            echo "Le paquets paru est déjà installé..." | tee -a "$LOG_FILES_INSTALL"
        else
            echo "Installation du paquets paru..." | tee -a "$LOG_FILES_INSTALL"
            git clone https://aur.archlinux.org/paru.git $HOME/.config/build/tmp/paru
            cd $HOME/.config/build/tmp/paru || exit
            makepkg -si --noconfirm && cd .. 
            echo "Installation du paquets paru terminé..." | tee -a "$LOG_FILES_INSTALL"
        fi

        echo "" | tee -a "$LOG_FILES_INSTALL"
        echo "=== FIN DE L'INSTALLATION DU PAQUET PARU ===" | tee -a "$LOG_FILES_INSTALL"
        echo "" | tee -a "$LOG_FILES_INSTALL"

    else
        echo "Le paquets paru n'est pas sélectionner dans le fichier config.sh..."

        echo "" | tee -a "$LOG_FILES_INSTALL"
        echo "=== FIN DE L'INSTALLATION DU PAQUET PARU ===" | tee -a "$LOG_FILES_INSTALL"
        echo "" | tee -a "$LOG_FILES_INSTALL"
    fi

}

##############################################################################
## install_paquages - Installation des utilitaires                                
##############################################################################
install_paquages() {

    local deps="$SCRIPT_DIR/pkg-files/deps.txt"
    local packages="$SCRIPT_DIR/pkg-files/packages.txt"
    local packages_hypr="$SCRIPT_DIR/pkg-files/packages_hypr.txt"

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

##############################################################################
## install_repo - Installation des utilitaires                                
##############################################################################
install_repo() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DE L'INSTALLATION DES REPO GITHUB ET AUTRES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    ### REPO AUTOCPU-FREQ
    echo "Recherche de l'installation de auto-cpufreq..." | tee -a "$LOG_FILES_INSTALL"
    if ! command -v auto-cpufreq &> /dev/null
    then

        echo "Auto-cpufreq n'est pas installé, installation en cours..." | tee -a "$LOG_FILES_INSTALL"
        git clone "$AUTO_CPUFREQ" $HOME/.config/build/tmp/auto-cpufreq
        cd $HOME/.config/build/tmp/auto-cpufreq && echo "I" | sudo ./auto-cpufreq-installer
        sudo auto-cpufreq --install
        echo "Installation de auto-cpufreq avec succès..." | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Auto-cpufreq est déjà installé sur le systeme..." | tee -a "$LOG_FILES_INSTALL"
    fi

    ### REPO OH-MY-ZSH
    echo "Recherche de l'installation de oh-my-zsh et de ses composants..." | tee -a "$LOG_FILES_INSTALL"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then

        echo "Oh-my-zsh n'est pas installé, installation en cours..." | tee -a "$LOG_FILES_INSTALL"

        chsh --shell /bin/zsh
        git clone "$OHMYZSH_REPO" "$HOME/.oh-my-zsh"
        git clone "$POWERLEVEL10K_REPO" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

        echo "Création du fichier .zshrc à l'emplacement : $HOME/.zshrc..." | tee -a "$LOG_FILES_INSTALL"

        {
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\""

            echo "# Chemin vers votre installation Oh My Zsh."
            echo "export ZSH=\"\$HOME/.oh-my-zsh\""

            echo "# Définir le nom du thème à charger" 
            echo "ZSH_THEME=\"robbyrussell\""

            echo "# Décommentez la ligne suivante si le collage d'URL et d'autres textes est mal formaté."
            echo "DISABLE_MAGIC_FUNCTIONS=\"true\""

            echo "# Les plugins standard peuvent être trouvés dans \$ZSH/plugins/"
            echo "plugins=(git)"

            echo "source \$ZSH/oh-my-zsh.sh"

            echo "# Configuration utilisateur"

            echo "# Activer le support des couleurs pour la commande ls et ajouter également des alias pratiques"
            echo "if [ -x /usr/bin/dircolors ]; then"
            echo "    # Si le fichier ~/.dircolors existe et est lisible, appliquer les paramètres de couleurs depuis ce fichier,"
            echo "    # sinon, utiliser les paramètres par défaut de dircolors."
            echo "    test -r ~/.dircolors && eval \"\$(dircolors -b ~/.dircolors)\" || eval \"\$(dircolors -b)\""

            echo "    # Définir un alias pour ls avec support des couleurs activé automatiquement"
            echo "    alias ls='ls --color=auto'"

            echo "    # Les lignes suivantes sont commentées mais peuvent être décommentées pour activer le support des couleurs pour les commandes suivantes :"
            echo "    # Définir un alias pour dir avec support des couleurs activé automatiquement"
            echo "    # alias dir='dir --color=auto'"

            echo "    # Définir un alias pour vdir avec support des couleurs activé automatiquement"
            echo "    # alias vdir='vdir --color=auto'"

            echo "    # Définir des alias pour grep, fgrep et egrep avec support des couleurs activé automatiquement"
            echo "    alias grep='grep --color=auto'"
            echo "    alias fgrep='fgrep --color=auto'"
            echo "    alias egrep='egrep --color=auto'"
            echo "fi"

            echo "# Alias supplémentaires"
            echo "alias yt-dlp='pipx run yt-dlp'"
            echo "alias yt-dl-likes='yt-dlp --cookies www.youtube.com_cookies.txt -x --audio-format mp3 :ytfav'"
            echo "alias tmp='pushd \$(mktemp -d)'"
            echo "alias tree='exa -Tll'"
            echo "alias ls-detail='exa -ll --group-directories-first'"
            echo "alias ls-detail-all='exa -lla --group-directories-first'"
            echo "alias ls-all='ls -alF'"
            echo "alias ls-hidden='ls -A'"
            echo "alias ls-basic='ls -CF'"

            echo "# Ajouter ssh-agent et réutiliser celui qui a été créé"
            echo "if ! pgrep -u \$USER ssh-agent > /dev/null; then"
            echo "    ssh-agent > \$XDG_RUNTIME_DIR/ssh-agent.env"
            echo "fi"

            echo "if [[ ! \"\$SSH_AUTH_SOCK\" ]]; then"
            echo "    source \$XDG_RUNTIME_DIR/ssh-agent.env >/dev/null"
            echo "fi"

        } > "$ZSHRC_FILE"

        echo "Le fichier .zshrc a été créé avec succès à l'emplacement : $ZSHRC_FILE..." | tee -a "$LOG_FILES_INSTALL"

        echo "Activation du theme zsh powerlevel10k..." | tee -a "$LOG_FILES_INSTALL"
        sed -i 's#^ZSH_THEME=.*$#ZSH_THEME="powerlevel10k/powerlevel10k"#' "$ZSHRC_FILE"
        echo "Activation du theme powerlevel10k avec succès..." | tee -a "$LOG_FILES_INSTALL"

        echo "Installation de .fzf..." | tee -a "$LOG_FILES_INSTALL"
        git clone --depth 1 "$FZF_REPO" "$HOME/.fzf"
        "$HOME/.fzf/install" --all
        echo "Fin de l'installation de .fzf..." | tee -a "$LOG_FILES_INSTALL"

        echo "Installation des plugins oh-my-zsh..." | tee -a "$LOG_FILES_INSTALL"
        for plugin in "${OHMYZSH_PLUGINS_REPO[@]}"; do
            plugin_name=$(echo $plugin | awk '{print $1}')
            plugin_repo=$(echo $plugin | awk '{print $2}')
            
            plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
            git clone "$plugin_repo" "$plugin_dir"
        done

        plugin_list=()
        for plugin in "${OHMYZSH_PLUGINS_REPO[@]}"; do
            plugin_name=$(echo $plugin | awk '{print $1}')
            plugin_list+=("$plugin_name")
        done
        plugin_string=$(printf "%s " "${plugin_list[@]}")
        sed -i "s/^plugins=(.*)/plugins=($plugin_string)/" "$HOME/.zshrc"
        echo "Fin de l'installation des plugins oh-my-zsh..." | tee -a "$LOG_FILES_INSTALL"

        echo "Désactivation de certain plugin oh-my-zsh..."
        for plugin in "${OHMYZSH_PLUGINS_REMOVE[@]}"; do
            zsh -c "source $HOME/.zshrc && omz plugin disable $plugin || true"
        done
        echo "Fin de désactivation de certain plugin oh-my-zsh..." | tee -a "$LOG_FILES_INSTALL"

    else
        echo "Oh-my-zsh est déjà installé sur le systeme..." | tee -a "$LOG_FILES_INSTALL"
    fi

    # Repo asdf
    if [ ! -f "$HOME/.local/bin/asdf" ]; then

        echo "Installation de asdf..."

        wget -O "$HOME/.config/build/tmp/asdf.tar.gz" "$ASDF_URL"
        tar -xvzf $HOME/.config/build/tmp/asdf.tar.gz -C $HOME/.local/bin

        echo "Modification du fichier $HOME/.zshrc..." | tee -a "$LOG_FILES_INSTALL"
        {
            echo "# Configuration ASDF"

            echo "export ASDF_DATA_DIR=\"\$HOME/.config/asdf\""
            echo "export PATH=\"\$ASDF_DATA_DIR/shims:\$PATH\""

            echo "mkdir -p \"\${ASDF_DATA_DIR:-\$HOME/.config/asdf}/completions\""
            echo "asdf completion zsh > \"\${ASDF_DATA_DIR:-\$HOME/.config/asdf}/completions/_asdf\""

            echo "fpath=(\${ASDF_DIR}/completions \$fpath)"
            echo "autoload -Uz compinit && compinit"
        } >> "$ZSHRC_FILE"

        echo "Les lignes ont été ajoutées avec succès dans $ZSHRC_FILE..." | tee -a "$LOG_FILES_INSTALL"

    else
        echo "Le programe asdf existe déjà, aucune installation nécessaire..." | tee -a "$LOG_FILES_INSTALL"
    fi

    ### AUTRES INSTALLATION ICI

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES REPOS === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}

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


##############################################################################
## install_drivers - Installation des drivers                                                 
##############################################################################
install_drivers() {

    local amd_driver="$SCRIPT_DIR/pkg-files/amd.txt"
    local nvidia_driver="$SCRIPT_DIR/pkg-files/nvidia.txt"
    local intel_driver="$SCRIPT_DIR/pkg-files/intel.txt"

    local gpu_modules=""
    local has_multiple_gpus=false

    sudo mkdir -p "/etc/modprobe.d"
    sudo mkdir -p "/etc/pacman.d/hooks"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DE L'INSTALLATION DES DRIVERS === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    if [[ -n "$PROC_UCODE_TYPE" ]]; then
        echo "Recherche du paquet $PROC_UCODE_TYPE pour la configuration du microcode..." | tee -a "$LOG_FILES_INSTALL"
        install_with_pac "$PROC_UCODE_TYPE"
    else
        echo "Microcode manquant, installation impossible..." | tee -a "$LOG_FILES_INSTALL"
    fi

    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Configuration pour Intel
    if echo "$GPU_VENDOR" | grep -q "intel"; then

        has_multiple_gpus=true
        gpu_modules="${gpu_modules:+$gpu_modules }i915"

        echo "Recherche des paquets Intel pour la configuration de la carte graphique..." | tee -a "$LOG_FILES_INSTALL"

        while IFS= read -r line; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            install_with_pac "$line"
        done < "$intel_driver"

        echo "" | tee -a "$LOG_FILES_INSTALL"

        echo "Recherche des fichiers de configuration pour Intel..." | tee -a "$LOG_FILES_INSTALL"
            
        # Gestion de la configuration de i915.conf
        configure_modprobe_file "i915.conf" \
            "options i915 modeset=1" \
            "options i915 enable_guc=3" \
            "options i915 enable_fbc=1" \
            "options i915 fastboot=1" \
            "options i915 enable_psr=1" \
            "options i915 enable_dc=1"

        if ! grep -qE '^[^#]*HOOKS=.*\bkms\b' "/etc/mkinitcpio.conf"; then
            echo "Ajout de 'kms' dans HOOKS de /etc/mkinitcpio.conf..." | tee -a "$LOG_FILES_INSTALL"
            sudo sed -i '/^[^#]*HOOKS=/s/^HOOKS=(\(.*\))/HOOKS=(\1 kms)/' "/etc/mkinitcpio.conf"
        else
            echo " 'kms' est déjà présent dans le HOOKS du fichier /etc/mkinitcpio.conf..." | tee -a "$LOG_FILES_INSTALL"
        fi

        echo "" | tee -a "$LOG_FILES_INSTALL"

    fi

    # Configuration pour AMD
    if echo "$GPU_VENDOR" | grep -q "amd\|radeon"; then

        has_multiple_gpus=true
        gpu_modules="${gpu_modules:+$gpu_modules }amdgpu radeon"

        echo "Recherche des paquets Amd pour la configuration de la carte graphique..." | tee -a "$LOG_FILES_INSTALL"

        while IFS= read -r line; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            install_with_pac "$line"
        done < "$amd_driver"

        echo "" | tee -a "$LOG_FILES_INSTALL"

        echo "Recherche des fichiers de configuration pour Amd..." | tee -a "$LOG_FILES_INSTALL"

        # Gestion de la configuration de amdgpu.conf
        configure_modprobe_file "amdgpu.conf" \
            "options amdgpu si_support=1" \
            "options amdgpu cik_support=1" \
            "options amdgpu deep_color=1" \
            "options amdgpu dc=1" \
            "options amdgpu modeset=1" \
            "options amdgpu powerplay=1" \
            "options amdgpu enable_dpm=1" \
            "options amdgpu temperature_unit=0"

        if ! grep -qE '^[^#]*HOOKS=.*\bkms\b' "/etc/mkinitcpio.conf"; then
            echo "Ajout de 'kms' dans HOOKS de /etc/mkinitcpio.conf..." | tee -a "$LOG_FILES_INSTALL"
            sudo sed -i '/^[^#]*HOOKS=/s/^HOOKS=(\(.*\))/HOOKS=(\1 kms)/' "/etc/mkinitcpio.conf"
        else
            echo " 'kms' est déjà présent dans le HOOKS du fichier /etc/mkinitcpio.conf..." | tee -a "$LOG_FILES_INSTALL"
        fi

        echo "" | tee -a "$LOG_FILES_INSTALL"
    fi

    # Configuration pour NVIDIA
    if echo "$GPU_VENDOR" | grep -q "nvidia"; then

        has_multiple_gpus=true
        gpu_modules="${gpu_modules:+$gpu_modules }nvidia nvidia_modeset nvidia_uvm nvidia_drm"

        echo "Recherche des paquets Nvidia pour la configuration de la carte graphique..." | tee -a "$LOG_FILES_INSTALL"
            
        while IFS= read -r line; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            install_with_pac "$line"
        done < "$nvidia_driver"

        echo "" | tee -a "$LOG_FILES_INSTALL"

        echo "Recherche des fichiers de configuration pour Nvidia..." | tee -a "$LOG_FILES_INSTALL"

        if [[ -f "/etc/pacman.d/hooks/nvidia.hook" ]]; then
            echo "Le Hook nvidia est déja créer dans /etc/pacman.d/hooks/nvidia.hook..." | tee -a "$LOG_FILES_INSTALL"
        else

            echo "Création du Hook nvidia dans /etc/pacman.d/hooks/nvidia.hook..." | tee -a "$LOG_FILES_INSTALL"

            # Création du hook pacman
            {
                echo "[Trigger]" 
                echo "Operation=Install" 
                echo "Operation=Upgrade" 
                echo "Operation=Remove" 
                echo "Type=Package" 
                echo "Target=nvidia" 
                echo "Target=linux" 
                    
                # Adjust line(6) above to match your driver, e.g. Target=nvidia-470xx-dkms
                # Change line(7) above, if you are not using the regular kernel For example, Target=linux-lts
                    
                echo 
                echo "[Action]"
                echo "Description=Mise à jour du module nvidia dans initramfs"
                echo "Depends=mkinitcpio" 
                echo "When=PostTransaction"
                echo "NeedsTargets"
                echo "Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'" 

            } | sudo tee /etc/pacman.d/hooks/nvidia.hook

            echo "Hook créer avec succés dans /etc/pacman.d/hooks/nvidia.hook..." | tee -a "$LOG_FILES_INSTALL"
        fi

        # Gestion de la configuration de nvidia.conf
        configure_modprobe_file "nvidia.conf" \
            "options nvidia_drm modeset=1 fbdev=1" \
            "options nvidia NVreg_RegistryDwords=\"PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3\"" \
            "options nvidia NVreg_RegisterPCIDriverOnEarlyBoot=1" \
            "options nvidia NVreg_EnablePCIeGen3=1" \
            "options nouveau modeset=0" \
            "blacklist nouveau" 

        echo "Suppression de 'kms' dans HOOKS de /etc/mkinitcpio.conf..." | tee -a "$LOG_FILES_INSTALL"
        # sudo sed -i 's/ kms / /g' "/etc/mkinitcpio.conf"
        sudo sed -i '/^HOOKS/ s/ kms / /' "/etc/mkinitcpio.conf"

        sudo systemctl enable nvidia-suspend.service 
        sudo systemctl enable nvidia-hibernate.service 
        sudo systemctl enable nvidia-resume.service

        echo "" | tee -a "$LOG_FILES_INSTALL"
    fi



    # Si aucun GPU spécifique n'est détecté
    if [ -z "$gpu_modules" ]; then
        echo "GPU non reconnu, installation des drivers impossible." | tee -a "$LOG_FILES_INSTALL"
        echo "" | tee -a "$LOG_FILES_INSTALL"
    fi

    # Configuration pour systèmes multi-GPU
    if $has_multiple_gpus; then

        echo "Recherche de la configuration multi-gpu" | tee -a "$LOG_FILES_INSTALL"

        if [[ -f "/etc/modprobe.d/gpu-multi.conf" ]]; then
            echo "Configuration multi-gpu déja créer dans /etc/modprobe.d/gpu-multi.conf..." | tee -a "$LOG_FILES_INSTALL"
        else

            echo "Création de la configuration multi-gpu dans /etc/modprobe.d/gpu-multi.conf..." | tee -a "$LOG_FILES_INSTALL"

            # Crée ou modifie le fichier gpu-multi.conf
            {
                if check_module_exists "nvidia"; then
                    echo "softdep nvidia pre: i915 amdgpu radeon"
                fi

                if check_module_exists "nouveau"; then
                    echo "softdep nouveau pre: i915 amdgpu radeon"
                fi

                if check_module_exists "amdgpu"; then
                    echo "softdep amdgpu pre: i915 radeon"
                fi

            } | sudo tee /etc/modprobe.d/gpu-multi.conf

        fi

        echo "" | tee -a "$LOG_FILES_INSTALL"
    fi

    echo "Mise à jour du fichier mkinitcpio.conf..." | tee -a "$LOG_FILES_INSTALL"

    # Mise à jour de mkinitcpio.conf
    sudo sed -i "s/^#\?MODULES=.*/MODULES=($gpu_modules)/" "/etc/mkinitcpio.conf"
    sudo sed -i 's/^#\?COMPRESSION="xz"/COMPRESSION="xz"/' "/etc/mkinitcpio.conf"
    sudo sed -i 's/^#\?COMPRESSION_OPTIONS=(.*)/COMPRESSION_OPTIONS=(-9e)/' "/etc/mkinitcpio.conf"
    sudo sed -i 's/^#\?MODULES_DECOMPRESS=".*"/MODULES_DECOMPRESS="yes"/' "/etc/mkinitcpio.conf"

    if ! grep -q "^FILES=" "/etc/mkinitcpio.conf"; then
        echo "FILES=(/etc/modprobe.d/*.conf /boot/$PROC_UCODE)" | sudo tee /etc/mkinitcpio.conf
    else
        sudo sed -i "s|^FILES=.*|FILES=(/etc/modprobe.d/*.conf /boot/$PROC_UCODE)|" "/etc/mkinitcpio.conf"
    fi

    echo "" | tee -a "$LOG_FILES_INSTALL"

    # sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img;

    echo "Régénération des initramfs pour tous les kernels installés..." | tee -a "$LOG_FILES_INSTALL"

    kernels=("/boot/vmlinuz-"*) 

    if [ -e "${kernels[0]}" ]; then

        for kernel in "${kernels[@]}"; do

            if [ -f "$kernel" ]; then

                # Extrait le nom du preset depuis le nom du fichier kernel
                kernel_name=$(basename "$kernel" | sed 's/vmlinuz-//')
                echo "" | tee -a "$LOG_FILES_INSTALL"
                echo " Traitement du kernel $kernel_name" | tee -a "$LOG_FILES_INSTALL"
                echo "" | tee -a "$LOG_FILES_INSTALL"

                # Génère l'initramfs pour ce kernel et capture la sortie
                sudo mkinitcpio -p "$kernel_name" | while IFS= read -r line; do
                    echo "[$kernel_name] $line"
                done
            fi

        done

    else
        echo "Aucun fichier vmlinuz-* trouvé dans /boot" | tee -a "$LOG_FILES_INSTALL"
    fi

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES DRIVERS === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}

##############################################################################
## install_fonts - Installation des fonts                                
##############################################################################
install_fonts() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== RECHERCHE DE L'INSTALLATION DES FONTS ===" | tee -a "$LOG_FILES_INSTALL"
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


##############################################################################
## save_conf - Sauvegarde de l'ancienne configuration                                               
##############################################################################
save_conf() {

    echo "Sauvegarde de l'ancienne configuration" && echo ""


    save_dir="$HOME/.config/build/sauvegarde/sauvegarde.$(date +%d%m%Y.%H%M)"
    log_files="$save_dir/log/"$(date +%d%m%Y.%H%M)".log"
    archive_file="sauvegarde.$(date +%d%m%Y.%H%M).zip"

    # Création des répertoires de sauvegarde
    mkdir -p "$save_dir" && mkdir -p "$save_dir/log"
    mkdir -p "$HOME/.config/build/archives"

    # Liste des fichiers et dossiers à sauvegarder
    fichiers_a_sauvegarder=(
        "$HOME/.config/hypr"
        "$HOME/.config/kitty"
        "$HOME/.config/rofi"
        "$HOME/.config/waybar"
        "$HOME/.config/qt5ct"
        "$HOME/.config/qt6ct"
        "$HOME/.config/mpd"
        "$HOME/.config/dunst"
        "$HOME/.config/gtk-3.0"
        "$HOME/.config/swaync"
        "/etc/sddm.conf.d"
        "/usr/share/sddm/scripts/Xsetup"
    )

    # Pour chaque fichier ou dossier dans la liste, effectuer la sauvegarde
    for fichier in "${fichiers_a_sauvegarder[@]}"; do
        if [ -e "$fichier" ]; then

            sudo cp -rf "$fichier" "$save_dir"
            
            # Message pour le terminal avec couleur
            terminal_message="\033[0;32m[ Succès ]\033[0m $(date) - Sauvegarde réussie de $fichier"
            
            # Message sans couleur pour le fichier log
            log_message="[ Succès ] $(date) - Sauvegarde réussie de $fichier"
            
            # Affichage dans le terminal avec couleur
            echo -e "$terminal_message"
            
            # Écriture dans le fichier log sans couleur
            echo "$log_message" | tee -a "$log_files" > /dev/null
        else
            # Message pour le terminal avec couleur
            terminal_message="\033[0;31m[ Échec  ]\033[0m $(date) - Échec de la sauvegarde de $fichier : fichier ou dossier non trouvé"
            
            # Message sans couleur pour le fichier log
            log_message="[ Échec  ] $(date) - Échec de la sauvegarde de $fichier : fichier ou dossier non trouvé"
            
            # Affichage dans le terminal avec couleur
            echo -e "$terminal_message"
            
            # Écriture dans le fichier log sans couleur
            echo "$log_message" | tee -a "$log_files" > /dev/null
        fi
    done

    # Création de l'archive ZIP du dossier de sauvegarde
    cd $save_dir && zip -r "$archive_file" *

    cp -rf "$archive_file" "$HOME/.config/build/archives/$archive_file"

    sudo rm -rf "$HOME/.config/build/sauvegarde"

    clear

    # Message pour confirmer l'archivage 
    echo -e "\033[0;32m[ Succès ]\033[0m $(date) - Archive ZIP de la sauvegarde créée : $HOME/.config/build/archives/$archive_file"

}

##############################################################################
## install_conf - Configuration du systeme avec dotfiles                                               
##############################################################################
install_conf() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DE HYPRDOTS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    git clone --recursive $HYPRDOTS /opt/build/hyprdots
    cd /opt/build/hyprdots

    rsync -av --delete config/hypr/ $HOME/.config/hypr
    rsync -av --delete config/kitty/ $HOME/.config/kitty
    rsync -av --delete config/rofi/ $HOME/.config/rofi
    rsync -av --delete config/waybar/ $HOME/.config/waybar
    rsync -av --delete config/qt5ct/ $HOME/.config/qt5ct
    rsync -av --delete config/qt6ct/ $HOME/.config/qt6ct
    rsync -av --delete config/nvim/ $HOME/.config/nvim
    rsync -av --delete config/dunst/ $HOME/.config/dunst
    rsync -av --delete config/gtk-3.0/ $HOME/.config/gtk-3.0
    rsync -av --delete config/settings.ini $HOME/.config/settings.ini

    rsync -av --delete home/scripts/ $HOME/scripts
    rsync -av --delete home/vimrc $HOME/.vimrc

    unzip themes/decay-green.zip -d $HOME/.local/share/themes
    unzip themes/mocha.zip -d $HOME/.local/share/themes
    unzip themes/rose-pine.zip -d $HOME/.local/share/themes

    unzip icons/catppuccin-macchiato-lavender-cursors.zip -d $HOME/.local/share/icons
    unzip icons/catppuccin-mocha-lavender-cursors.zip -d $HOME/.local/share/icons
    unzip icons/rose-pine-cursor.zip -d $HOME/.local/share/icons
    unzip icons/icon-tela-purple.zip -d $HOME/.local/share/icons
    unzip icons/rose-pine-icon.zip -d $HOME/.local/share/icons

    sudo rsync -av etc/sddm/rose-pine-sddm /usr/share/sddm/themes
    sudo rsync -av etc/sddm/catppuccin-macchiato /usr/share/sddm/themes
    sudo rsync -av etc/sddm/catppuccin-mocha /usr/share/sddm/themes

    sudo mkdir -p /etc/sddm.conf.d

    sudo rsync -av --delete etc/sddm/sddm.conf /etc/sddm.conf.d/sddm.conf
    sudo rsync -av --delete etc/sddm/Xsetup /usr/share/sddm/scripts/Xsetup

    chmod +x $HOME/.config/waybar/scripts/*
    chmod +x $HOME/.config/hypr/scripts/*
    chmod +x $HOME/scripts/*
    sudo chmod +x /usr/share/sddm/scripts/Xsetup

    kitty +kitten themes --reload-in=all $KITTY

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DE HYPRDOTS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}

##############################################################################
## install_cron - a tester                                              
##############################################################################
install_cron() {
    # Variables
    service_name="sync_hypr.service"
    timer_name="sync_hypr.timer"
    script_path="$HOME/scripts/sync_hypr.sh"
    systemd_user_dir="$HOME/.config/systemd/user"

    # Vérifie si le script sync_hypr.sh existe
    if [ ! -f "$script_path" ]; then
    echo "Erreur : Le script $script_path n'existe pas."
    exit 1
    fi

    # Créer le répertoire systemd/user si nécessaire
    mkdir -p "$systemd_user_dir"

    # Crée le fichier service
    echo "Création du fichier $service_name..."

    {
    echo "[Unit]"
    echo "Description=Synchronisation des fichiers Hyprdots"

    echo "[Service]"
    echo "ExecStart=$script_path"

    } | tee $systemd_user_dir/$service_name

    # Crée le fichier timer
    echo "Création du fichier $timer_name..."

    {
    echo "[Unit]"
    echo "Description=Lance la synchronisation Hyprdots tous les jours à 20:00"

    echo "[Timer]"
    echo "OnCalendar=20:00"
    echo "Persistent=true"

    echo "[Install]"
    echo "WantedBy=timers.target"

    } | tee $systemd_user_dir/$timer_name

    sudo chmod +x $script_path

    # Recharge systemd et active le timer
    echo "Activation du timer systemd..."
    systemctl --user enable $timer_name


    # Confirmation
    echo "Le service et le timer ont été configurés avec succès."
    echo "Vérifiez le statut avec : systemctl --user status $timer_name"
}

##############################################################################
## install_firewall - Activation du Firewall                                              
##############################################################################
install_firewall() {

    # Définition des variables
    NFTABLES_CONF="/etc/nftables.conf"
    NFTABLES_LOG="/var/log/nftables.log"
    # JOURNALD_CONF="/etc/systemd/journald.conf"
    # SERVICE_FILE="/etc/systemd/system/nftables-journald.service"

    # Fonction pour gérer les erreurs
    handle_error() {
        echo "Erreur : $1" >&2
        exit 1
    }


    # Configuration des règles nftables
    temp_rules=$(mktemp)
    trap 'rm -f "$temp_rules"' EXIT

    {
        echo "#!/usr/sbin/nft -f"
        echo "flush ruleset"

        echo "# Création de la table et des chaînes"
        echo "add table inet firewall"
        echo "add chain inet firewall input { type filter hook input priority 0 ; policy drop ; }"
        echo "add chain inet firewall output { type filter hook output priority 0 ; policy accept ; }"
        echo "add chain inet firewall forward { type filter hook forward priority 0 ; policy drop ; }"

        echo "# Règles de base pour la chaîne input"
        echo "add rule inet firewall input ct state established,related accept"
        echo "add rule inet firewall input ct state invalid drop"
        echo "add rule inet firewall input iif lo accept"

        echo "# Protection contre les attaques TCP de base"
        echo "add rule inet firewall input tcp flags & (fin|syn) == fin|syn drop"
        echo "add rule inet firewall input tcp flags & (syn|rst) == syn|rst drop"
        echo "add rule inet firewall input tcp flags & (fin|syn|rst|psh|ack|urg) < fin drop"
        echo "add rule inet firewall input tcp flags & fin != 0 ct state new drop"

        echo "# Protection DoS/DDoS"
        echo "add rule inet firewall input tcp flags syn tcp dport {80, 443} limit rate 30/minute accept"
        echo "add rule inet firewall input tcp flags syn limit rate 20/second burst 50 packets accept"
        echo "add rule inet firewall input udp dport 0-65535 limit rate 100/second burst 100 packets accept"
        echo "add rule inet firewall input icmp type echo-request limit rate 10/second accept"

        echo "# Protection contre le scan de ports"
        echo "add rule inet firewall input tcp flags syn tcp dport 0-19 drop"
        echo "add rule inet firewall input tcp flags syn tcp dport 137-139 drop"
        echo "add rule inet firewall input tcp flags syn ct state new limit rate 10/second accept"

        echo "# Protection contre les paquets fragmentés"
        echo "# Bloque tous les paquets fragmentés"
        echo "# add rule inet firewall input ip frag-off & 1 == 1 drop"
        echo "# add rule inet firewall input ip frag-off & 8191 != 0 drop"
        echo "# Bloque les paquets fragmentés sauf ceux venant de l'interface VPN (tun0) :"
        echo "# add rule inet firewall input iif != \"tun0\" ip frag-off & 1 == 1 drop"
        echo "# add rule inet firewall input iif != \"tun0\" ip frag-off & 8191 != 0 drop"
        echo "# Accepte les fragments de paquets, mais limite le taux"
        echo "add rule inet firewall input ip frag-off & 1 == 1 limit rate 10/second accept"
        echo "add rule inet firewall input ip frag-off & 8191 != 0 limit rate 10/second accept"

        echo "# Protection anti-spoofing"
        echo "add rule inet firewall input ip saddr 127.0.0.0/8 iif != \"lo\" drop"
        echo "add rule inet firewall input ip saddr 0.0.0.0/8 drop"
        echo "add rule inet firewall input ip saddr 169.254.0.0/16 drop"
        echo "add rule inet firewall input ip saddr 224.0.0.0/4 drop"

        echo "# Protection contre les scans furtifs"
        echo "add rule inet firewall input tcp flags & (fin|syn|rst|ack) == 0 drop"
        echo "add rule inet firewall input tcp flags & (fin|syn|rst|psh|ack|urg) == fin|psh|urg drop"

        echo "# Protection contre les attaques par amplification"
        echo "add rule inet firewall input udp dport 17 drop"
        echo "add rule inet firewall input udp dport 19 drop"
        echo "add rule inet firewall input udp dport 123 drop"
        echo "add rule inet firewall input udp dport 161 drop"
        echo "add rule inet firewall input udp dport 1900 drop"
        echo "add rule inet firewall input udp dport 11211 drop"

        echo "# Protection des services sensibles"
        echo "add rule inet firewall input tcp dport 22 ct state new limit rate 5/minute accept"
        echo "add rule inet firewall input tcp dport { 3306, 5432 } drop"

        echo "# Logging et rejet final"
        echo "add rule inet firewall input log prefix \"nft-drop: \" level debug flags all"
        echo "add rule inet firewall input counter drop"

    } > "$temp_rules"

    # Application des règles avec sudo
    echo "Application des règles nftables..."
    if ! sudo nft -f "$temp_rules"; then
        handle_error "Application des règles nftables échouée"
    fi

    # Vérification de l'application des règles
    if ! sudo nft list ruleset | grep -q "nft-drop:"; then
        handle_error "Les règles n'ont pas été appliquées correctement"
    fi

    # Sauvegarde de la configuration
    sudo nft list ruleset | sudo tee "$NFTABLES_CONF" > /dev/null

    sudo groupadd nftables
    sudo usermod -aG nftables $USER
    sudo touch $NFTABLES_LOG
    sudo chown root:nftables $NFTABLES_LOG
    sudo chmod 640 $NFTABLES_LOG

    # Configuration de journald
    #echo "Configuration de journald..."
    #{
        #echo "[Journal]"
        #echo "SystemMaxUse=100M"
        #echo "SystemMaxFileSize=100M"
        #echo "SystemMaxFiles=4"
        #echo "Storage=persistent"
        #echo "Compress=yes"
        #echo "ForwardToSyslog=yes"

    #} | sudo tee "$JOURNALD_CONF" > /dev/null

    ## Configuration du service systemd
    #echo "Configuration du service systemd..."
    #{
        #echo "[Unit]"
        #echo "Description=Règles de pare-feu nftables avec journald"
        #echo "After=network.target"
        #echo "Wants=network.target"
        #echo ""
        #echo "[Service]"
        #echo "Type=simple"
        #echo "ExecStartPre=/usr/sbin/nft -f /etc/nftables.conf"
        #echo "ExecStart=/bin/bash -c /usr/bin/journalctl -f -o cat -t kernel | /usr/bin/grep \"nft-drop:\""
        #echo "Restart=always"
        #echo "RestartSec=30"
        #echo "StandardOutput=journal"
        #echo "StandardError=journal"
        #echo "SyslogIdentifier=nftables-log"
        #echo ""
        #echo "[Install]"
        #echo "WantedBy=multi-user.target"

    #} | sudo tee "$SERVICE_FILE" > /dev/null

    # Ajout de la tâche cron pour journaliser périodiquement
    #echo "Création de la tâche cron pour la collecte des logs toutes les 5 minutes..."
    #(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/journalctl -n 100 -o short -t nftables-log > $NFTABLES_LOG") | sudo crontab -

    echo "Configuration du pare-feu terminée avec succès"

}

##############################################################################
## Activate_services - Activation des services                                              
##############################################################################
Activate_services() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== ACTIVATION DES SERVICES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager.service
    sudo systemctl enable bluetooth.service
    sudo systemctl enable mpd.service 

    systemctl --user enable pipewire 
    systemctl --user enable pipewire-pulse
    systemctl --user enable wireplumber

    sudo systemctl enable --now cups

    sudo usermod -aG libvirt $(whoami)
    sudo systemctl enable --now libvirtd

    sudo usermod -aG docker $(id -u -n)
    sudo systemctl enable docker.service

    # sudo systemctl daemon-reload      
    sudo systemctl enable --now nftables.service
    # sudo systemctl enable --now cronie.service
    # sudo systemctl enable --now nftables-journald.service

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'ACTIVATION DES SERVICES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}

##############################################################################
## clean                                              
##############################################################################
clean_system() {
    echo "en cours de réalisation"
}




