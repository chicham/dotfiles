#!/bin/sh

# Install 1Password CLI on Linux without sudo
# https://developer.1password.com/docs/cli/get-started/#install

set -eu

if ! command -v op >/dev/null 2>&1; then
  echo "Installing 1Password CLI directly..."

  # Detect architecture
  ARCH=$(uname -m)

  # Choose the appropriate package based on architecture
  if [ "$ARCH" = "x86_64" ]; then
    DOWNLOAD_URL="https://cache.agilebits.com/dist/1P/op2/pkg/v2.24.0/op_linux_amd64_v2.24.0.zip"
    DOWNLOAD_FILE="op_linux_amd64.zip"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    DOWNLOAD_URL="https://cache.agilebits.com/dist/1P/op2/pkg/v2.24.0/op_linux_arm64_v2.24.0.zip"
    DOWNLOAD_FILE="op_linux_arm64.zip"
  else
    echo "Error: Unsupported architecture: $ARCH"
    echo "Skipping 1Password CLI installation."
    exit 0
  fi

  # Create directories
  mkdir -p "${HOME}/.local/bin"

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  curl -Lo "${DOWNLOAD_FILE}" "${DOWNLOAD_URL}"
  unzip -q "${DOWNLOAD_FILE}"

  # Move binary to local bin
  mv op "${HOME}/.local/bin/"
  chmod +x "${HOME}/.local/bin/op"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "1Password CLI installed to ${HOME}/.local/bin/op"
  echo "Make sure ${HOME}/.local/bin is in your PATH"
else
  echo "1Password CLI is already installed."
fi
