#!/bin/sh

# Install fd-find (alternative to 'find')
# https://github.com/sharkdp/fd

set -eu

if ! command -v fd >/dev/null 2>&1; then
  echo "Installing fd-find..."

  # Define fallback version
  FALLBACK_VERSION="v10.2.0"

  # Try to get the latest release version
  GITHUB_RESPONSE=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest)

  # Check if the API rate limit was exceeded
  if echo "$GITHUB_RESPONSE" | grep -q "API rate limit exceeded"; then
    echo "GitHub API rate limit exceeded. Using fallback version."
    LATEST_RELEASE="$FALLBACK_VERSION"
  else
    LATEST_RELEASE=$(echo "$GITHUB_RESPONSE" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

    # If failed to get the latest version for any reason, use the fallback
    if [ -z "$LATEST_RELEASE" ]; then
      echo "Failed to determine latest version. Using fallback version."
      LATEST_RELEASE="$FALLBACK_VERSION"
    fi
  fi

  # Detect architecture
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    DOWNLOAD_URL="https://github.com/sharkdp/fd/releases/download/${LATEST_RELEASE}/fd-${LATEST_RELEASE}-x86_64-unknown-linux-gnu.tar.gz"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    DOWNLOAD_URL="https://github.com/sharkdp/fd/releases/download/${LATEST_RELEASE}/fd-${LATEST_RELEASE}-aarch64-unknown-linux-gnu.tar.gz"
  else
    echo "Error: Unsupported architecture: $ARCH"
    exit 1
  fi

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  echo "Downloading fd-find from ${DOWNLOAD_URL}..."
  curl -fsSLo fd.tar.gz "$DOWNLOAD_URL"

  # Check if download was successful
  if [ ! -s fd.tar.gz ]; then
    echo "Error: Failed to download fd from ${DOWNLOAD_URL}"
    exit 1
  fi
  echo "Extracting fd-find..."
  tar xf fd.tar.gz

  # Move to bin directory
  mkdir -p "${HOME}/.local/bin"
  find . -name "fd" -type f -executable -exec cp {} "${HOME}/.local/bin/" \;

  # Cleanup
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "fd-find installed to ${HOME}/.local/bin/fd"
else
  echo "fd-find already installed, skipping."
fi
