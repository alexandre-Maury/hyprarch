#!/bin/bash

# script install_drivers.sh


##############################################################################
## install_drivers - Installation des drivers                                                 
##############################################################################
install_all_drivers() {

    local amd_driver="$TARGET_DIR/pkg-files/amd.txt"
    local nvidia_driver="$TARGET_DIR/pkg-files/nvidia.txt"
    local intel_driver="$TARGET_DIR/pkg-files/intel.txt"

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