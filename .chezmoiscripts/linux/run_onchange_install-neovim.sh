#!/bin/bash
set -eu

# Install neovim on Linux in user space
if ! command -v nvim > /dev/null 2>&1; then
  echo "Installing neovim..."

  # Create directories
  mkdir -p "${HOME}/.local/bin"
  mkdir -p "${HOME}/.local/share/nvim"
  mkdir -p "${HOME}/.config/nvim"

  # Get latest release from GitHub
  echo "Getting latest Neovim release version..."
  API_RESPONSE=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest)

  # Check if we hit API rate limit
  if echo "$API_RESPONSE" | grep -q "API rate limit exceeded"; then
    echo "GitHub API rate limit exceeded, using v0.10.4 as fallback."
    NVIM_VERSION="v0.10.4"
  else
    # Extract version from API response
    NVIM_VERSION=$(echo "$API_RESPONSE" | grep -o '"tag_name": "v[^"]*"' | grep -o 'v[0-9.]*')

    # Check if version was found
    if [ -z "$NVIM_VERSION" ]; then
      echo "Failed to get latest version from GitHub API, using v0.10.4 as fallback."
      NVIM_VERSION="v0.10.4"
    else
      echo "Latest Neovim version: $NVIM_VERSION"
    fi
  fi

  # Detect system architecture
  ARCH=$(uname -m)
  TMP_DIR=$(mktemp -d)

  echo "Detected architecture: $ARCH"

  # Choose the appropriate download based on architecture
  if [ "$ARCH" = "x86_64" ]; then
    # Use tar.gz instead of AppImage to avoid FUSE dependencies
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/nvim.tar.gz"

    echo "Downloading Neovim tar.gz for x86_64..."
    curl -L "${NVIM_URL}" -o "$ARCHIVE_PATH"

    echo "Extracting archive..."
    cd "$TMP_DIR"
    tar xzf "$ARCHIVE_PATH"

    # Create the expected directory structure
    mkdir -p squashfs-root/usr/bin
    mkdir -p squashfs-root/usr/share/nvim

    # Move files to match the expected structure
    if [ -d "nvim-linux-x86_64" ]; then
      cp nvim-linux-x86_64/bin/nvim squashfs-root/usr/bin/
      cp -r nvim-linux-x86_64/share/nvim/runtime squashfs-root/usr/share/nvim/
    else
      echo "Unexpected structure in tarball. Using files as is."
      find . -name "nvim" -type f -executable -exec cp {} squashfs-root/usr/bin/ \;
      find . -path "*/share/nvim/runtime" -type d -exec cp -r {} squashfs-root/usr/share/nvim/ \;
    fi
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    # Use tar.gz for ARM64
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-arm64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/nvim.tar.gz"

    echo "Downloading Neovim tar.gz for ARM64..."
    curl -L "${NVIM_URL}" -o "$ARCHIVE_PATH"

    echo "Extracting archive..."
    cd "$TMP_DIR"
    tar xzf "$ARCHIVE_PATH"

    # Create the expected directory structure
    mkdir -p squashfs-root/usr/bin
    mkdir -p squashfs-root/usr/share/nvim

    # Move files to match the expected structure
    if [ -d "nvim-linux-arm64" ]; then
      cp nvim-linux-arm64/bin/nvim squashfs-root/usr/bin/
      cp -r nvim-linux-arm64/share/nvim/runtime squashfs-root/usr/share/nvim/
    else
      echo "Unexpected structure in tarball. Using files as is."
      find . -name "nvim" -type f -executable -exec cp {} squashfs-root/usr/bin/ \;
      find . -path "*/share/nvim/runtime" -type d -exec cp -r {} squashfs-root/usr/share/nvim/ \;
    fi
  else
    echo "Unsupported architecture: $ARCH. Trying tar.gz for x86_64 as fallback..."
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    ARCHIVE_PATH="${TMP_DIR}/nvim.tar.gz"

    echo "Downloading Neovim tar.gz..."
    curl -L "${NVIM_URL}" -o "$ARCHIVE_PATH"

    echo "Extracting archive..."
    cd "$TMP_DIR"
    tar xzf "$ARCHIVE_PATH"

    # Create the expected directory structure
    mkdir -p squashfs-root/usr/bin
    mkdir -p squashfs-root/usr/share/nvim

    # Move files to match the expected structure
    if [ -d "nvim-linux-x86_64" ]; then
      cp nvim-linux-x86_64/bin/nvim squashfs-root/usr/bin/
      cp -r nvim-linux-x86_64/share/nvim/runtime squashfs-root/usr/share/nvim/
    else
      echo "Unexpected structure in tarball. Using files as is."
      find . -name "nvim" -type f -executable -exec cp {} squashfs-root/usr/bin/ \;
      find . -path "*/share/nvim/runtime" -type d -exec cp -r {} squashfs-root/usr/share/nvim/ \;
    fi
  fi

  echo "Installing Neovim..."
  cp squashfs-root/usr/bin/nvim "${HOME}/.local/bin/"

  if [ -d "squashfs-root/usr/share/nvim/runtime" ]; then
    cp -r squashfs-root/usr/share/nvim/runtime "${HOME}/.local/share/nvim/"
  fi

  # Clean up
  rm -rf "${TMP_DIR}"

  echo "Neovim ${NVIM_VERSION} installed to ${HOME}/.local/bin/nvim"
else
  echo "neovim is already installed."
fi
