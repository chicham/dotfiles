#!/bin/sh

# Install difft (structural diff tool)
# https://github.com/Wilfred/difftastic

set -eu

if ! command -v difft >/dev/null 2>&1; then
  echo "Installing difft..."

  # Get latest release
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/Wilfred/difftastic/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
  VERSION=${LATEST_RELEASE#v}

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"
  curl -Lo difft.tar.gz "https://github.com/Wilfred/difftastic/releases/download/${LATEST_RELEASE}/difft-x86_64-unknown-linux-gnu.tar.gz"
  tar xf difft.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  cp difft "${HOME}/.local/bin/"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "difft installed to ${HOME}/.local/bin/difft"
else
  echo "difft already installed, skipping."
fi
