#!/bin/sh

# Install starship (cross-shell prompt)
# https://starship.rs/guide/

set -eu

# Ensure ~/.local/bin exists
mkdir -p "${HOME}/.local/bin"

# Download and run the installer, specifying ~/.local/bin as the target directory
# Starship installer will update if already installed or install if not
echo "Installing/updating starship to user directory..."
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir="${HOME}/.local/bin" -y
