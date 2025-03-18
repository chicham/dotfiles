#!/bin/sh

# Install direnv (environment switcher)
# https://github.com/direnv/direnv

set -eu

if ! command -v direnv >/dev/null 2>&1; then
  echo "Installing direnv..."

  # Get latest release using a more portable approach
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep "tag_name" | sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')
  VERSION=${LATEST_RELEASE}

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  curl -Lo direnv "https://github.com/direnv/direnv/releases/download/v${VERSION}/direnv.linux-amd64"
  chmod +x direnv

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  mv direnv "${HOME}/.local/bin/"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "direnv installed to ${HOME}/.local/bin/direnv"
else
  echo "direnv already installed, skipping."
fi
