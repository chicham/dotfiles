#!/bin/sh

# Install atuin (shell history manager)
# https://github.com/atuinsh/atuin

set -eu

if ! command -v atuin >/dev/null 2>&1; then
  echo "Installing atuin..."
  # Download the script to a temporary file instead of using process substitution
  TEMP_SCRIPT=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh > "${TEMP_SCRIPT}"
  bash "${TEMP_SCRIPT}"
  rm "${TEMP_SCRIPT}"
else
  echo "atuin already installed, skipping."
fi
