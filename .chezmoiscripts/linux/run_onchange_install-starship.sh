#!/bin/sh

# Install starship (cross-shell prompt)
# https://github.com/starship/starship

set -eu

if ! command -v starship >/dev/null 2>&1; then
  echo "Installing starship..."
  # Using official install script
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
else
  echo "starship already installed, skipping."
fi
