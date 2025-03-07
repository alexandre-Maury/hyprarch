#!/bin/bash

# script system.sh

##############################################################################
## Fichier de configuration interne, ne pas modifier       
# https://github.com/ChrisTitusTech/ArchTitus/blob/main/scripts/0-preinstall.sh                                                    
##############################################################################

GPU_VENDOR=$(lspci | grep -i "VGA\|3D" | awk '{print tolower($0)}')
CPU_VENDOR=$(grep -m1 "vendor_id" /proc/cpuinfo | awk '{print $3}')

LOG_FILES_INSTALL="$HOME/.config/build/installation/install."$(date +%d%m%Y.%H%M)".log"

mkdir -p "$HOME/.config/build/installation"
mkdir -p "$HOME/.config/build/curseur"
mkdir -p "$HOME/.config/build/tmp"

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

ZSHRC_FILE="$HOME/.zshrc"
OHMYZSH_REPO="https://github.com/robbyrussell/oh-my-zsh.git"

OHMYZSH_PLUGINS_REPO=(
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
    "fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    "zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete.git"
)

OHMYZSH_PLUGINS_REMOVE=(
    "rtx"
    "ssh-agent"
)

POWERLEVEL10K_REPO="https://github.com/romkatv/powerlevel10k.git"
FZF_REPO="https://github.com/junegunn/fzf.git"
AUTO_CPUFREQ="https://github.com/AdnanHodzic/auto-cpufreq.git"

ASDF_URL="https://github.com/asdf-vm/asdf/releases/download/v0.16.0/asdf-v0.16.0-linux-amd64.tar.gz"

declare -A ASDF_PLUGINS=(
    ["nodejs"]="https://github.com/asdf-vm/asdf-nodejs.git"
    ["python"]="https://github.com/danhper/asdf-python"
    ["ruby"]="https://github.com/asdf-vm/asdf-ruby.git"
    ["java"]="https://github.com/halcyon/asdf-java.git"
    ["golang"]="https://github.com/kennyp/asdf-golang.git"
    ["elixir"]="https://github.com/asdf-vm/asdf-elixir.git"
    ["php"]="https://github.com/asdf-community/asdf-php.git"
    ["rust"]="https://github.com/code-lever/asdf-rust.git"
    ["dotnet"]="https://github.com/hensou/asdf-dotnet.git"
)
    
HYPRDOTS="https://github.com/alexandre-Maury/hyprdots.git"


