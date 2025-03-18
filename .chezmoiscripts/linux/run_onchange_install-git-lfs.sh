#!/bin/sh
# vim: set ft=bash:
set -eu

# Install Git LFS on Linux in user space if possible

echo "Installing Git LFS..."

# Check if git-lfs is already installed
if command -v git-lfs >/dev/null 2>&1; then
  echo "Git LFS is already installed."
  exit 0
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

# Determine system architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    LFS_ARCH="amd64"
    ;;
  aarch64|arm64)
    LFS_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Download the latest Git LFS
GIT_LFS_VERSION="3.4.0"  # Update this to the latest version as needed
LFS_URL="https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-${LFS_ARCH}-v${GIT_LFS_VERSION}.tar.gz"

echo "Downloading Git LFS from ${LFS_URL}..."
curl -sL "${LFS_URL}" -o git-lfs.tar.gz

# Extract the tarball
tar xzf git-lfs.tar.gz

# Install to user's .local/bin
mkdir -p "${HOME}/.local/bin"
install -m 755 git-lfs "${HOME}/.local/bin/git-lfs"

# Initialize Git LFS
"${HOME}/.local/bin/git-lfs" install --skip-repo

# Clean up
cd - > /dev/null
rm -rf "${TEMP_DIR}"

echo "Git LFS has been installed to ${HOME}/.local/bin/git-lfs"
echo "Please ensure ${HOME}/.local/bin is in your PATH."
