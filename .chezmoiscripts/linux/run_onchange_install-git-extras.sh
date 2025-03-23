#!/bin/sh
# vim: set ft=bash:
set -eu

# Install git-extras on Linux in user space if possible

echo "Installing git-extras..."

# Check if git-extras is already installed
if command -v git-extras > /dev/null 2>&1; then
  echo "git-extras is already installed."
  exit 0
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

# Clone the git-extras repository
echo "Cloning git-extras repository..."
git clone --depth 1 https://github.com/tj/git-extras.git
cd git-extras

# Install to user's .local directory
PREFIX="${HOME}/.local" make install

# Clean up
cd - > /dev/null
rm -rf "${TEMP_DIR}"

echo "git-extras has been installed to ${HOME}/.local/bin"
echo "Please ensure ${HOME}/.local/bin is in your PATH."
