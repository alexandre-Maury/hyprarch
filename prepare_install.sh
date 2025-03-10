#!/usr/bin/env bash

set -e  # Quitte immédiatement en cas d'erreur.

# Variables
REPO_URL="https://github.com/alexandre-Maury/hyprarch.git"
export TARGET_DIR="/opt/build"

# Définition du répertoire du script pour le clean system
export SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Vérification si le script est exécuté en tant que root
if [ "$EUID" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
  exit 1
fi

# Vérification si git est installé
if ! command -v git &> /dev/null; then
  echo "Erreur : git n'est pas installé. Installez-le et réessayez."
  exit 1
fi

# Création du répertoire cible
echo "Création du répertoire cible : $TARGET_DIR/hyprarch"
sudo mkdir -p "$(dirname "$TARGET_DIR/hyprarch")"

# Mise à jour ou clonage du dépôt
if [ -d "$TARGET_DIR/hyprarch/.git" ]; then
  echo "Mise à jour du dépôt existant..."
  sudo git -C "$TARGET_DIR/hyprarch" pull
else
  echo "Clonage du dépôt dans $TARGET_DIR/hyprarch..."
  sudo git clone "$REPO_URL" "$TARGET_DIR/hyprarch"
fi

# Ajustement des permissions
echo "Ajustement des permissions..."
sudo chown -R $(id -u):$(id -g) "$TARGET_DIR"

# Définition du chemin du script d'installation
INSTALL_SCRIPT="$TARGET_DIR/hyprarch/setup/install.sh"

# Vérification de l'existence du script d'installation
if [ ! -f "$INSTALL_SCRIPT" ]; then
  echo "Erreur : Le script d'installation n'a pas été trouvé à l'emplacement attendu ($INSTALL_SCRIPT)."
  exit 1
fi

# Exécution du script d'installation
chmod +x "$INSTALL_SCRIPT"
"$INSTALL_SCRIPT" --install

echo "=== FIN DE L'INSTALLATION - REDÉMARREZ VOTRE SYSTÈME ==="
