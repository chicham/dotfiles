#!/bin/sh

# Install Zellij for Linux
# https://zellij.dev/

set -eu

# Check if Zellij is already installed
if command -v zellij > /dev/null 2>&1; then
  echo "Zellij is already installed."
  # Optional: Check version and update if needed
  exit 0
fi

echo "Installing Zellij..."

# Create ~/.local/bin if it doesn't exist
mkdir -p "${HOME}/.local/bin"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH_NAME="x86_64-unknown-linux-musl"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  ARCH_NAME="aarch64-unknown-linux-musl"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Download latest release
echo "Downloading Zellij..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/${LATEST_VERSION}/zellij-${ARCH_NAME}.tar.gz"

curl -L "$DOWNLOAD_URL" -o zellij.tar.gz

# Extract and install
tar -xzf zellij.tar.gz
chmod +x zellij
mv zellij "${HOME}/.local/bin/"

# Cleanup
cd - > /dev/null
rm -rf "${TEMP_DIR}"

echo "Zellij installed successfully to ${HOME}/.local/bin/zellij"
