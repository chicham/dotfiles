#!/bin/sh
# Script to install uv (Python package manager)

set -eu

# Install uv if it's not already installed
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."

  # Use the generic install script from astral.sh
  curl -LsSf https://astral.sh/uv/install.sh | sh

  echo "uv installed successfully"
else
  echo "uv is already installed"
fi
