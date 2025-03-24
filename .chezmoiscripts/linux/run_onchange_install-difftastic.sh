#!/bin/sh
# Install difftastic (modern structural diff tool)
# https://github.com/Wilfred/difftastic

set -eu

if ! command -v difft > /dev/null 2>&1; then
  echo "Installing difft..."

  # Get the latest release version using GitHub API
  API_RESPONSE=$(curl -s https://api.github.com/repos/Wilfred/difftastic/releases/latest)

  # Check if we hit rate limit
  if echo "$API_RESPONSE" | grep -q "API rate limit exceeded"; then
    echo "GitHub API rate limit exceeded. Using fallback version."
    LATEST_RELEASE="0.63.0" # Fallback to a known version
  else
    LATEST_RELEASE=$(echo "$API_RESPONSE" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
  fi

  # Detect architecture
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    DOWNLOAD_URL="https://github.com/Wilfred/difftastic/releases/download/${LATEST_RELEASE}/difft-x86_64-unknown-linux-gnu.tar.gz"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    DOWNLOAD_URL="https://github.com/Wilfred/difftastic/releases/download/${LATEST_RELEASE}/difft-aarch64-unknown-linux-gnu.tar.gz"
  else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
  fi

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  echo "Downloading difftastic from ${DOWNLOAD_URL}..."
  curl -fsSLo difft.tar.gz "$DOWNLOAD_URL" || {
    echo "Failed to download difftastic - check if version ${LATEST_RELEASE} exists"
    exit 1
  }

  # Check if download was successful
  if [ ! -s difft.tar.gz ]; then
    echo "Error: Failed to download difftastic from ${DOWNLOAD_URL}"
    exit 1
  fi

  echo "Extracting difftastic..."
  tar xf difft.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  find . -name "difft" -type f -executable -exec cp {} "${HOME}/.local/bin/" \;

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "difftastic installed to ${HOME}/.local/bin/difft"
else
  echo "difftastic already installed, skipping."
fi
