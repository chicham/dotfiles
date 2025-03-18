#!/bin/sh

# Install atuin (shell history manager)
# https://github.com/atuinsh/atuin

set -eu

if ! command -v atuin >/dev/null 2>&1; then
  echo "Installing atuin..."
  bash <(curl -fsSL https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
else
  echo "atuin already installed, skipping."
fi
