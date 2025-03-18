#!/bin/sh

# Install WezTerm CLI components for remote Linux servers (non-GUI)
# https://github.com/wez/wezterm

set -eu

echo "Installing WezTerm CLI components..."

# Set directories
INSTALL_DIR="${HOME}/.local"
BIN_DIR="${INSTALL_DIR}/bin"
SHARE_DIR="${INSTALL_DIR}/share"
mkdir -p "${BIN_DIR}" "${SHARE_DIR}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

# Download the latest nightly Linux binary tarball
echo "Downloading latest WezTerm nightly tarball..."
curl -Lo wezterm.tar.gz "https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly-ubuntu20.04.tar.gz"

# Extract the tarball
echo "Extracting WezTerm files..."
tar -xzf wezterm.tar.gz
cd wezterm

# Copy only CLI components (skip GUI components)
cp -f wezterm "${BIN_DIR}/"
cp -f wezterm-mux-server "${BIN_DIR}/"
cp -f strip-ansi-escapes "${BIN_DIR}/"

# Copy shell integration assets for terminal integration
mkdir -p "${SHARE_DIR}/wezterm"
cp -f shell-integration/* "${SHARE_DIR}/wezterm/"

# Copy terminfo for proper terminal behavior
if [ -d terminfo ]; then
  mkdir -p "${SHARE_DIR}/terminfo"
  cp -rf terminfo/* "${SHARE_DIR}/terminfo/"
fi

# Clean up
cd - > /dev/null
rm -rf "${TEMP_DIR}"

echo "WezTerm CLI components installed to ${BIN_DIR}/wezterm"
echo "These components can be used for multiplexing and remote integration."
echo "Make sure ${BIN_DIR} is in your PATH."
