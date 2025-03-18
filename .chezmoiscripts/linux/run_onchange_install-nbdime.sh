#!/bin/bash
set -eu

echo "Installing nbdime for Jupyter notebook diff and merge..."

# Check if uv is installed
if ! command -v uv &>/dev/null; then
  echo "Error: uv is not installed. Please install uv first."
  exit 1
fi

# Install nbdime via uv
uv pip install --system nbdime

# Check if nbdime was installed successfully
if ! command -v nbdime &>/dev/null; then
  echo "Error: nbdime installation failed."
  exit 1
fi

# Configure nbdime with Git
nbdime config-git --enable --global

echo "nbdime installation and configuration complete"
