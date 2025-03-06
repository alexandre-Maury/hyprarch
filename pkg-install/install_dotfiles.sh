#!/bin/bash

# script install_dotfiles.sh

##############################################################################
## install_all_dotfiles - Configuration du systeme avec dotfiles                                               
##############################################################################
install_all_dotfiles() {

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