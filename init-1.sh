#!/bin/bash

# Définir les couleurs pour les messages d'echo
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Fonction pour afficher les messages avec couleurs et emojis
function echo_step {
    echo -e "${YELLOW}🚀 $1${NC}"
}

function echo_success {
    echo -e "${GREEN}✅ $1${NC}"
}

function echo_error {
    echo -e "${RED}❌ $1${NC}"
}

# Définir le répertoire de base
BASE_DIR="$HOME"
BIN_DIR="$BASE_DIR/bin"

# Vérifier et créer le répertoire bin si nécessaire
echo_step "Vérification du répertoire $BIN_DIR..."
if [ ! -d "$BIN_DIR" ]; then
    echo_step "Le répertoire $BIN_DIR n'existe pas. Création..."
    mkdir -p "$BIN_DIR"
    if [ $? -eq 0 ]; then
        echo_success "Le répertoire $BIN_DIR a été créé."
    else
        echo_error "Échec de la création du répertoire $BIN_DIR."
        exit 1
    fi
else
    echo_success "Le répertoire $BIN_DIR existe déjà."
fi

# Ajouter le répertoire bin au PATH
echo_step "Ajout de $BIN_DIR au PATH..."
export PATH="$BIN_DIR:$PATH"
if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
    echo_success "$BIN_DIR ajouté au PATH."
else
    echo_error "Échec de l'ajout de $BIN_DIR au PATH."
    exit 1
fi

# Vérification et installation de curl et wget
echo_step "Vérification et installation des dépendances nécessaires..."

# Vérifier et installer curl
if ! command -v curl &> /dev/null; then
    echo_step "curl n'est pas installé. Installation de curl..."
    sudo apt update && sudo apt install -y curl
    if [ $? -eq 0 ]; then
        echo_success "curl installé."
    else
        echo_error "Échec de l'installation de curl."
        exit 1
    fi
else
    echo_success "curl est déjà installé."
fi

# Vérifier et installer wget
if ! command -v wget &> /dev/null; then
    echo_step "wget n'est pas installé. Installation de wget..."
    sudo apt update && sudo apt install -y wget
    if [ $? -eq 0 ]; then
        echo_success "wget installé."
    else
        echo_error "Échec de l'installation de wget."
        exit 1
    fi
else
    echo_success "wget est déjà installé."
fi

# Étape 1: Installer Oh My Posh
echo_step "Installation de Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$BIN_DIR"
if [ $? -eq 0 ]; then
    echo_success "Oh My Posh installé."
else
    echo_error "Échec de l'installation de Oh My Posh."
    exit 1
fi

# Étape 2: Télécharger le thème
echo_step "Téléchargement du thème..."
wget -O "$BIN_DIR/dev-remote.omp.yaml" https://raw.githubusercontent.com/f3lin/my-terminal/main/themes/dev-remote.omp.yaml
if [ $? -eq 0 ]; then
    echo_success "Thème téléchargé."
else
    echo_error "Échec du téléchargement du thème."
    exit 1
fi

# Étape 3: Mettre à jour le profil
echo_step "Mise à jour du profil..."
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(oh-my-posh init bash --config ~/bin/dev-remote.omp.yaml)"' >> ~/.bashrc
source ~/.bashrc
echo_success "Profil mis à jour."

# Étape 4: Installer la police Nerd Fonts
echo_step "Installation de la police Nerd Fonts..."
wget -O Lilex.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Lilex.zip
if [ $? -eq 0 ]; then
    unzip Lilex.zip -d ~/.fonts
    fc-cache -fv
    rm Lilex.zip
    echo_success "Police Nerd Fonts installée."
else
    echo_error "Échec de l'installation de la police Nerd Fonts."
    exit 1
fi

# Étape 5: Installer exa
echo_step "Installation de exa..."
sudo apt update && sudo apt install -y exa
if [ $? -eq 0 ]; then
    echo_success "exa installé."
else
    echo_error "Échec de l'installation de exa."
    echo_step "Installation de tree en remplacement de exa"
    sudo apt-get install -y tree
    if [ $? -eq 0 ]; then
        echo_success "tree installé à la place de exa."
    else
        echo_error "Échec de l'installation de tree."
        exit 1
    fi
fi

# Recharger le bash
echo_step "Rechargement du terminal..."
exec bash
