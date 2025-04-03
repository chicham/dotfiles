#!/bin/sh
# Install or update pixi package manager for Linux

set -eu

# Check if pixi is already installed
if command -v pixi > /dev/null 2>&1; then
  echo "pixi is already installed, updating..."
  pixi self-update
else
  echo "Installing pixi package manager..."

  # Set directories
  INSTALL_DIR="${HOME}/.local"
  BIN_DIR="${INSTALL_DIR}/bin"
  mkdir -p "${BIN_DIR}"

  # Install with the official install script
  if command -v curl > /dev/null 2>&1; then
    curl -fsSL https://pixi.sh/install.sh | sh
  else
    echo "ERROR: curl is required to install pixi. Please install curl first."
    exit 1
  fi
fi

echo "pixi operation completed. Run 'pixi --help' to get started."
