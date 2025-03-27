#!/bin/sh

# Install fzf using direct source tarball download instead of git
# https://github.com/junegunn/fzf/releases

set -eu

FZF_DIR="${HOME}/.fzf"

# Get the latest release version
echo "Checking for the latest fzf release..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Latest fzf version: $LATEST_VERSION"

# Check if fzf is already installed with correct version (if we can determine it)
if [ -d "$FZF_DIR" ] && [ -f "$FZF_DIR/bin/fzf" ]; then
  if "$FZF_DIR/bin/fzf" --version 2> /dev/null | grep -q "$LATEST_VERSION"; then
    echo "fzf is already at the latest version $LATEST_VERSION"
    exit 0
  fi
fi

echo "Installing fzf $LATEST_VERSION from source..."

# Create a temporary directory for download
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download the source tarball
DOWNLOAD_URL="https://github.com/junegunn/fzf/archive/refs/tags/${LATEST_VERSION}.tar.gz"
echo "Downloading from $DOWNLOAD_URL"
curl -L "$DOWNLOAD_URL" -o "fzf-${LATEST_VERSION}.tar.gz"

# Extract the source
tar -xzf "fzf-${LATEST_VERSION}.tar.gz"
cd "fzf-${LATEST_VERSION#v}"

# Move the source to the destination directory
rm -rf "$FZF_DIR" # Remove existing directory if it exists
mkdir -p "$FZF_DIR"
cp -r . "$FZF_DIR"

# Run the installer script (--bin installs only the binary)
cd "$FZF_DIR"
./install --bin

# Clean up
cd - > /dev/null
rm -rf "$TMP_DIR"

echo "fzf $LATEST_VERSION installed successfully to $FZF_DIR/bin/fzf"
