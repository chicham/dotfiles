#!/bin/sh

# Install bat (a cat clone with syntax highlighting)
# https://github.com/sharkdp/bat

set -eu

if ! command -v bat >/dev/null 2>&1; then
  echo "Installing bat..."

  # Get the latest release version using compatible grep and sed
  API_RESPONSE=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest)

  # Check if we hit rate limit
  if echo "$API_RESPONSE" | grep -q "API rate limit exceeded"; then
    echo "GitHub API rate limit exceeded. Using fallback version."
    LATEST_RELEASE="v0.24.0"  # Fallback to a known version
  else
    LATEST_RELEASE=$(echo "$API_RESPONSE" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
  fi

  # Detect architecture
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/download/${LATEST_RELEASE}/bat-${LATEST_RELEASE}-x86_64-unknown-linux-gnu.tar.gz"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    DOWNLOAD_URL="https://github.com/sharkdp/bat/releases/download/${LATEST_RELEASE}/bat-${LATEST_RELEASE}-aarch64-unknown-linux-gnu.tar.gz"
  else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
  fi

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  echo "Downloading bat from ${DOWNLOAD_URL}..."
  curl -fsSLo bat.tar.gz "$DOWNLOAD_URL" || { echo "Failed to download bat - check if version ${LATEST_RELEASE} exists"; exit 1; }

  # Check if download was successful
  if [ ! -s bat.tar.gz ]; then
    echo "Error: Failed to download bat from ${DOWNLOAD_URL}"
    exit 1
  fi

  echo "Extracting bat..."
  tar xf bat.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  find . -name "bat" -type f -executable -exec cp {} "${HOME}/.local/bin/" \;

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "bat installed to ${HOME}/.local/bin/bat"
else
  echo "bat already installed, skipping."
fi
