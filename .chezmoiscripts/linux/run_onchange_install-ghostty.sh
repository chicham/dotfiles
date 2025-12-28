#!/bin/sh

# Install Ghostty for Linux using AppImage
# https://github.com/pkgforge-dev/ghostty-appimage

set -eu

# Check if Ghostty is already installed
if command -v ghostty > /dev/null 2>&1; then
  echo "Ghostty is already installed."
  exit 0
fi

echo "Installing Ghostty (AppImage)..."

# Create ~/.local/bin if it doesn't exist
mkdir -p "${HOME}/.local/bin"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

# Determine architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH_NAME="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_NAME="arm64"
else
  echo "Unsupported architecture: $ARCH"
  rm -rf "${TEMP_DIR}"
  exit 1
fi

# Fetch latest release info to get the version
echo "Fetching latest release version..."
# We use the 'tag_name' which usually includes 'v' prefix, e.g., 'v1.0.1-0'
LATEST_TAG=$(curl -s https://api.github.com/repos/pkgforge-dev/ghostty-appimage/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
  echo "Error: Could not determine latest version."
  rm -rf "${TEMP_DIR}"
  exit 1
fi

# Remove 'v' prefix for the filename construction if necessary,
# but looking at the example: v${VERSION}/Ghostty-${VERSION}...
# The repo tags are like 'v1.0.1-0'. The files are 'Ghostty-1.0.1-0-x86_64.AppImage'.
# So we need to strip the leading 'v' for the filename part.
VERSION=${LATEST_TAG#v}

echo "Latest version: ${VERSION}"

# Construct download URL
# URL Format: https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v${VERSION}/Ghostty-${VERSION}-${ARCH}.AppImage
DOWNLOAD_URL="https://github.com/pkgforge-dev/ghostty-appimage/releases/download/${LATEST_TAG}/Ghostty-${VERSION}-${ARCH_NAME}.AppImage"

echo "Downloading from ${DOWNLOAD_URL}..."
curl -L "$DOWNLOAD_URL" -o "ghostty.AppImage"

# Make executable and install to ~/.local/bin
chmod +x ghostty.AppImage
install ghostty.AppImage "${HOME}/.local/bin/ghostty"

# Cleanup
cd - > /dev/null
rm -rf "${TEMP_DIR}"

echo "Ghostty installed successfully to ${HOME}/.local/bin/ghostty"
