#!/bin/sh
# Script to install uv (Python package manager)

set -eu

# Make sure ~/.local/bin exists and is in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Install uv if it's not already installed
if ! command -v uv > /dev/null 2>&1; then
  echo "Installing uv..."

  # Use the generic install script from astral.sh
  curl -LsSf https://astral.sh/uv/install.sh | sh

  echo "uv installed successfully"
else
  echo "uv is already installed, skipping update..."
  # Check if we can safely update
  if uv self update --check 2> /dev/null; then
    echo "Updating uv..."
    uv self update
  else
    echo "Cannot update uv - likely installed via package manager"
  fi
fi
