#!/bin/sh

# Install zoxide (smarter cd command)
# https://github.com/ajeetdsouza/zoxide

set -eu

if ! command -v zoxide >/dev/null 2>&1; then
  echo "Installing zoxide..."
  # Using official install script
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
  echo "zoxide already installed, skipping."
fi
