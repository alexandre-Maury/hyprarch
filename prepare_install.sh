set -e  # Quitte immédiatement en cas d'erreur.

# Variables
TARGET_DIR="/opt/build/hyprarch"
CURRENT_DIR=$(pwd)

# Vérification si le script est exécuté en tant que root
if [ "$EUID" -eq 0 ]; then
  echo
  echo "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
  exit 1
fi

# Crée le répertoire cible si nécessaire
echo "Création du répertoire cible : $TARGET_DIR"
sudo mkdir -p "$(dirname "$TARGET_DIR")"

# Déplacement du dépôt
if [ -d "$TARGET_DIR" ]; then
  echo "Le dépôt existe déjà dans $TARGET_DIR. Suppression de l'ancien répertoire..."
  sudo rm -rf "$TARGET_DIR"
fi

echo "Déplacement du dépôt dans $TARGET_DIR..."
sudo mv "$CURRENT_DIR" "$TARGET_DIR"

# Ajustement des permissions
echo "Ajustement des permissions pour l'utilisateur..."
sudo chown -R $USER:$USER "/opt/build"

# Change de répertoire pour éviter les problèmes liés au déplacement
cd "$TARGET_DIR"

chmod +x ./install.sh && ./install.sh --install

clear

echo "=== FIN DE L'INSTALLATION REDEMMARER VOTRE SYSTEME ===" 
echo
echo " === Configuration Post Installation ==="
echo
echo "[vim] Pluggins YouCompleteMe : Instructions d'installation :"
echo " cd ~/.vim/plugged/YouCompleteMe && python3 install.py --clangd-completer"
echo
