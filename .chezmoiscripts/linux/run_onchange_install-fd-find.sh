#!/bin/sh

# Install fd-find (alternative to 'find')
# https://github.com/sharkdp/fd

set -eu

if ! command -v fd >/dev/null 2>&1; then
  echo "Installing fd-find..."

  # Get latest release
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  VERSION=${LATEST_RELEASE#v}

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"
  curl -Lo fd.tar.gz "https://github.com/sharkdp/fd/releases/download/${LATEST_RELEASE}/fd-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
  tar xf fd.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  cp fd-*/fd "${HOME}/.local/bin/"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "fd-find installed to ${HOME}/.local/bin/fd"
else
  echo "fd-find already installed, skipping."
fi
