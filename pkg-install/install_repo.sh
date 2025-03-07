#!/bin/bash

# script install_repo.sh


##############################################################################
## install_repo_autocpufreq - utilitaire                            
##############################################################################
install_repo_autocpufreq() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DE AUTOCPUFREQ ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    ### REPO AUTOCPU-FREQ
    echo "Recherche de l'installation de auto-cpufreq..." | tee -a "$LOG_FILES_INSTALL"
    if ! command -v auto-cpufreq &> /dev/null
    then

        echo "Auto-cpufreq n'est pas installé, installation en cours..." | tee -a "$LOG_FILES_INSTALL"
        git clone "$AUTO_CPUFREQ" $TARGET_DIR/tmp/auto-cpufreq
        cd $TARGET_DIR/tmp/auto-cpufreq && echo "I" | sudo ./auto-cpufreq-installer
        sudo auto-cpufreq --install
        echo "Installation de auto-cpufreq avec succès..." | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Auto-cpufreq est déjà installé sur le systeme..." | tee -a "$LOG_FILES_INSTALL"
    fi

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DE AUTOCPUFREQ ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}


##############################################################################
## install_repo_ohmyzsh - utilitaire                            
##############################################################################
install_repo_ohmyzsh() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION OH-MY-ZSH ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then

        echo "Oh-my-zsh n'est pas installé, installation en cours..." | tee -a "$LOG_FILES_INSTALL"

        chsh --shell /bin/zsh
        git clone "$OHMYZSH_REPO" "$HOME/.oh-my-zsh"
        git clone "$POWERLEVEL10K_REPO" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

        echo "Création du fichier .zshrc à l'emplacement : $HOME/.zshrc..." | tee -a "$LOG_FILES_INSTALL"

        {
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
            echo ""
            echo "# Chemin vers votre installation Oh My Zsh."
            echo "export ZSH=\"\$HOME/.oh-my-zsh\""
            echo ""
            echo "# Définir le nom du thème à charger" 
            echo "ZSH_THEME=\"robbyrussell\""
            echo ""
            echo "# Décommentez la ligne suivante si le collage d'URL et d'autres textes est mal formaté."
            echo "DISABLE_MAGIC_FUNCTIONS=\"true\""
            echo ""
            echo "# Les plugins standard peuvent être trouvés dans \$ZSH/plugins/"
            echo "plugins=(git)"
            echo ""
            echo "source \$ZSH/oh-my-zsh.sh"
            echo ""
            echo "# Configuration utilisateur"
            echo ""
            echo "# Activer le support des couleurs pour la commande ls et ajouter également des alias pratiques"
            echo ""
            echo "if [ -x /usr/bin/dircolors ]; then"
            echo "    # Si le fichier ~/.dircolors existe et est lisible, appliquer les paramètres de couleurs depuis ce fichier,"
            echo "    # sinon, utiliser les paramètres par défaut de dircolors."
            echo "    test -r ~/.dircolors && eval \"\$(dircolors -b ~/.dircolors)\" || eval \"\$(dircolors -b)\""
            echo ""
            echo "    # Définir un alias pour ls avec support des couleurs activé automatiquement"
            echo "    alias ls='ls --color=auto'"
            echo ""
            echo "    # Les lignes suivantes sont commentées mais peuvent être décommentées pour activer le support des couleurs pour les commandes suivantes :"
            echo "    # Définir un alias pour dir avec support des couleurs activé automatiquement"
            echo "    # alias dir='dir --color=auto'"
            echo ""
            echo "    # Définir un alias pour vdir avec support des couleurs activé automatiquement"
            echo "    # alias vdir='vdir --color=auto'"
            echo ""
            echo "    # Définir des alias pour grep, fgrep et egrep avec support des couleurs activé automatiquement"
            echo "    alias grep='grep --color=auto'"
            echo "    alias fgrep='fgrep --color=auto'"
            echo "    alias egrep='egrep --color=auto'"
            echo "fi"
            echo ""
            echo "# Alias supplémentaires"
            echo ""
            echo "alias yt-dlp='pipx run yt-dlp'"
            echo "alias yt-dl-likes='yt-dlp --cookies www.youtube.com_cookies.txt -x --audio-format mp3 :ytfav'"
            echo "alias tmp='pushd \$(mktemp -d)'"
            echo "alias tree='exa -Tll'"
            echo "alias ls-detail='exa -ll --group-directories-first'"
            echo "alias ls-detail-all='exa -lla --group-directories-first'"
            echo "alias ls-all='ls -alF'"
            echo "alias ls-hidden='ls -A'"
            echo "alias ls-basic='ls -CF'"
            echo "alias quit='deactivate'"
            echo ""
            echo "# Ajouter ssh-agent et réutiliser celui qui a été créé"
            echo "if ! pgrep -u \$USER ssh-agent > /dev/null; then"
            echo "    ssh-agent > \$XDG_RUNTIME_DIR/ssh-agent.env"
            echo "fi"
            echo ""
            echo "if [[ ! \"\$SSH_AUTH_SOCK\" ]]; then"
            echo "    source \$XDG_RUNTIME_DIR/ssh-agent.env >/dev/null"
            echo "fi"
            echo ""

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

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DE OH-MY-ZSH === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}


##############################################################################
## install_repo_asdf - utilitaire                            
##############################################################################
install_repo_asdf() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DE ASDF ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    if [ ! -f "$HOME/.local/bin/asdf" ]; then

        echo "Installation de asdf..."

        wget -O "$TARGET_DIR/tmp/asdf.tar.gz" "$ASDF_URL"
        tar -xvzf $TARGET_DIR/tmp/asdf.tar.gz -C $HOME/.local/bin

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

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DE ASDF === " | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}