#!/bin/bash

# script config.sh

##############################################################################
## Config arch post-install                                                   
##############################################################################

REGION="Europe"
PAYS="France"
CITY="Paris"
LANG="fr_FR.UTF-8"
PARU="Off" # yay est installé par défault
GIT_USER=""
GIT_EMAIL=""


# https://github.com/ryanoasis/nerd-fonts/tree/300890327ae50ed08a0c2ba89e8bfd67425dd3b8
URL_FONTS=(
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L/Regular/MesloLGLNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L/Regular/MesloLGLNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L/Regular/MesloLGLNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L-DZ/Regular/MesloLGLDZNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L-DZ/Regular/MesloLGLDZNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L-DZ/Regular/MesloLGLDZNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M-DZ/Regular/MesloLGMDZNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M-DZ/Regular/MesloLGMDZNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M-DZ/Regular/MesloLGMDZNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S-DZ/Regular/MesloLGSDZNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S-DZ/Regular/MesloLGSDZNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S-DZ/Regular/MesloLGSDZNerdFontPropo-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFontMono-Regular.ttf"
  "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFontPropo-Regular.ttf"
)

URL_CURSORS=(
  "https://github.com/catppuccin/cursors/releases/download/v1.0.1/catppuccin-macchiato-dark-cursors.zip"
  "https://github.com/catppuccin/cursors/releases/download/v1.0.1/catppuccin-mocha-dark-cursors.zip"
  "https://github.com/catppuccin/cursors/releases/download/v1.0.1/catppuccin-macchiato-lavender-cursors.zip"
  "https://github.com/catppuccin/cursors/releases/download/v1.0.1/catppuccin-mocha-lavender-cursors.zip"
  "https://github.com/rose-pine/cursor/releases/download/v1.1.0/BreezeX-RosePine-Linux.tar.xz"
)

KITTY="Rosé Pine" # Catppuccin-Macchiato - Catppuccin-Mocha - Rosé Pine

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