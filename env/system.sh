#!/bin/bash

# script system.sh

##############################################################################
## Fichier de configuration interne, ne pas modifier       
# https://github.com/ChrisTitusTech/ArchTitus/blob/main/scripts/0-preinstall.sh                                                    
##############################################################################

GPU_VENDOR=$(lspci | grep -i "VGA\|3D" | awk '{print tolower($0)}')
CPU_VENDOR=$(grep -m1 "vendor_id" /proc/cpuinfo | awk '{print $3}')

LOG_FILES_INSTALL="$TARGET_DIR/installation/install."$(date +%d%m%Y.%H%M)".log"

mkdir -p "${HOME}/.local/share/themes"
mkdir -p "${HOME}/.local/share/icons"
mkdir -p "${HOME}/.local/share/fonts"
mkdir -p "${HOME}/.local/share/music"
mkdir -p "${HOME}/.local/bin"
mkdir -p "$TARGET_DIR/installation"
mkdir -p "$TARGET_DIR/tmp"

# Détection du type de processeur
case "$CPU_VENDOR" in
    "GenuineIntel")
        PROC_UCODE="intel-ucode.img"
        microcode="intel-ucode"
        ;;
    "AuthenticAMD")
        PROC_UCODE="amd-ucode.img"
        ;;
    *)
        PROC_UCODE=""
        ;;
esac

PROC_UCODE_TYPE=$(basename "$PROC_UCODE" .img)




