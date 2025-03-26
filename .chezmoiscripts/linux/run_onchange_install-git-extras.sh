#!/bin/sh
# vim: set ft=bash:
set -eu

# Install git-extras on Linux in user space if possible

echo "Installing git-extras..."

# Check if git-extras is already installed
if command -v git-extras > /dev/null 2>&1; then
  echo "git-extras is already installed."
  exit 0
fi

# Use the official network installation script instead of building from source
# This avoids the dependency on bsdmainutils and the 'column' command
curl -sSL https://raw.githubusercontent.com/tj/git-extras/main/install.sh | bash /dev/stdin --prefix="${HOME}/.local"

echo "git-extras has been installed to ${HOME}/.local/bin"
echo "Please ensure ${HOME}/.local/bin is in your PATH."
