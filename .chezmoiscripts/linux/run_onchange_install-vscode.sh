#!/bin/sh

# Install VSCode and Pylance extension for Linux
# https://code.visualstudio.com/docs/setup/linux

set -eu

if ! command -v code >/dev/null 2>&1; then
  echo "Installing Visual Studio Code..."

  # Determine Linux distribution and architecture
  if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    # Debian/Ubuntu based
    if ! command -v curl >/dev/null 2>&1; then
      apt-get update && apt-get install -y curl apt-transport-https
    fi

    # Install VS Code repository
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
    sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    # Install VS Code
    sudo apt-get update
    sudo apt-get install -y code

  elif [ -f /etc/redhat-release ] || [ -f /etc/fedora-release ]; then
    # RHEL/Fedora based
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

    # Install VS Code
    if command -v dnf >/dev/null 2>&1; then
      sudo dnf check-update
      sudo dnf install -y code
    else
      sudo yum check-update
      sudo yum install -y code
    fi
  else
    echo "Unsupported Linux distribution. Please install VS Code manually."
    exit 1
  fi

  echo "Visual Studio Code has been installed successfully."
else
  echo "Visual Studio Code is already installed."
fi

# Install Pylance extension
echo "Installing Pylance extension for VS Code..."
code --install-extension ms-python.vscode-pylance
echo "Pylance extension has been installed successfully."
