#!/bin/bash

# Check for required argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 [fedora|sway]"
    exit 1
fi

INSTALL_LEVEL=$1

# Validate argument
if [ "$INSTALL_LEVEL" != "fedora" ] && [ "$INSTALL_LEVEL" != "sway" ]; then
    echo "Error: Invalid argument. Use 'fedora' or 'sway'"
    exit 1
fi

# Install deps 
sudo dnf install -y wget git ansible 

# Download playbooks
wget -O $HOME/Downloads/base-repos.yml https://github.com/tomncooper/dotfiles/raw/refs/heads/master/tools/playbooks/base-repos.yml
wget -O $HOME/Downloads/flatpak-base.yml https://github.com/tomncooper/dotfiles/raw/refs/heads/master/tools/playbooks/flatpak-base.yml
wget -O $HOME/Downloads/fedora.yml https://github.com/tomncooper/dotfiles/raw/refs/heads/master/tools/playbooks/fedora.yml

# Run appropriate playbook based on argument
if [ "$INSTALL_LEVEL" == "sway" ]; then
    wget -O $HOME/Downloads/sway.yml https://github.com/tomncooper/dotfiles/raw/refs/heads/master/tools/playbooks/sway.yml
    sudo ansible-playbook $HOME/Downloads/sway.yml -K
else
    sudo ansible-playbook $HOME/Downloads/fedora.yml -K
fi

