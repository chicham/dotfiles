#!/bin/sh

# Install bat (a cat clone with syntax highlighting)
# https://github.com/sharkdp/bat

set -eu

if ! command -v bat >/dev/null 2>&1; then
  echo "Installing bat..."

  # Get latest release
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  VERSION=${LATEST_RELEASE#v}

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"
  curl -Lo bat.tar.gz "https://github.com/sharkdp/bat/releases/download/${LATEST_RELEASE}/bat-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
  tar xf bat.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  cp bat-*/bat "${HOME}/.local/bin/"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "bat installed to ${HOME}/.local/bin/bat"
else
  echo "bat already installed, skipping."
fi
