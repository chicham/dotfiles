#!/bin/sh

# Install eza (a modern ls replacement)
# https://github.com/eza-community/eza

set -eu

if ! command -v eza >/dev/null 2>&1; then
  echo "Installing eza..."

  # Get latest release
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"
  curl -Lo eza.tar.gz "https://github.com/eza-community/eza/releases/download/${LATEST_RELEASE}/eza_x86_64-unknown-linux-musl.tar.gz"
  tar xf eza.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  cp eza "${HOME}/.local/bin/"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "eza installed to ${HOME}/.local/bin/eza"
else
  echo "eza already installed, skipping."
fi
