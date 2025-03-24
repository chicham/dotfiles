#!/bin/sh

# Install eza (a modern ls replacement)
# https://github.com/eza-community/eza

set -eu

if ! command -v eza > /dev/null 2>&1; then
  echo "Installing eza..."

  # Get latest release
  API_RESPONSE=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest)

  # Check if we hit rate limit
  if echo "$API_RESPONSE" | grep -q "API rate limit exceeded"; then
    echo "GitHub API rate limit exceeded. Using fallback version."
    LATEST_RELEASE="v0.20.24" # Fallback to a known version
  else
    LATEST_RELEASE=$(echo "$API_RESPONSE" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
  fi

  # Detect architecture
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    DOWNLOAD_URL="https://github.com/eza-community/eza/releases/download/${LATEST_RELEASE}/eza_x86_64-unknown-linux-gnu.zip"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    DOWNLOAD_URL="https://github.com/eza-community/eza/releases/download/${LATEST_RELEASE}/eza_aarch64-unknown-linux-gnu.zip"
  else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
  fi

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"
  echo "Downloading eza from ${DOWNLOAD_URL}..."
  curl -fLo eza.zip "$DOWNLOAD_URL" || {
    echo "Failed to download eza - check if version ${LATEST_RELEASE} exists"
    exit 1
  }

  # Extract zip file
  unzip eza.zip

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  cp eza "${HOME}/.local/bin/"

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "eza installed to ${HOME}/.local/bin/eza"
else
  echo "eza already installed, skipping."
fi
