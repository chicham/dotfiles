#!/bin/sh

# Install Git, GitHub CLI, and Git LFS for Linux
# Designed for user-level installation without root privileges where possible

set -eu

# Install Git if not already installed (if not available, skip as it's likely system-provided)
if ! command -v git >/dev/null 2>&1; then
  echo "Git not found. On Linux systems, Git should be installed by the system administrator."
  echo "Skipping Git installation."
else
  echo "Git is already installed."
fi

# Install GitHub CLI if not already installed
if ! command -v gh >/dev/null 2>&1; then
  echo "Installing GitHub CLI..."

  # Set up directories
  INSTALL_DIR="${HOME}/.local"
  BIN_DIR="${INSTALL_DIR}/bin"
  mkdir -p "${BIN_DIR}"

  # Get latest release
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep "tag_name" | sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')

  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  # Download and extract
  echo "Downloading GitHub CLI ${LATEST_RELEASE}..."
  curl -Lo gh.tar.gz "https://github.com/cli/cli/releases/download/v${LATEST_RELEASE}/gh_${LATEST_RELEASE}_linux_amd64.tar.gz"
  tar -xzf gh.tar.gz

  # Install
  cp -f gh_*/bin/gh "${BIN_DIR}/"

  # Add completions if shell is detected
  if [ -d "${HOME}/.local/share/zsh/site-functions" ]; then
    mkdir -p "${HOME}/.local/share/zsh/site-functions"
    cp -f gh_*/share/zsh/site-functions/_gh "${HOME}/.local/share/zsh/site-functions/"
  fi

  if [ -d "${HOME}/.local/share/bash-completion/completions" ]; then
    mkdir -p "${HOME}/.local/share/bash-completion/completions"
    cp -f gh_*/share/bash-completion/completions/gh "${HOME}/.local/share/bash-completion/completions/"
  fi

  # Clean up
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "GitHub CLI has been installed to ${BIN_DIR}/gh"
else
  echo "GitHub CLI is already installed."
fi

# Install Git LFS if not already installed
if ! command -v git-lfs >/dev/null 2>&1; then
  echo "Installing Git LFS..."

  # Set up directories
  INSTALL_DIR="${HOME}/.local"
  BIN_DIR="${INSTALL_DIR}/bin"
  mkdir -p "${BIN_DIR}"

  # Get latest release
  LATEST_RELEASE=$(curl -s https://api.github.com/repos/git-lfs/git-lfs/releases/latest | grep "tag_name" | sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')

  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  # Download and extract
  echo "Downloading Git LFS ${LATEST_RELEASE}..."
  curl -Lo git-lfs.tar.gz "https://github.com/git-lfs/git-lfs/releases/download/v${LATEST_RELEASE}/git-lfs-linux-amd64-v${LATEST_RELEASE}.tar.gz"
  tar -xzf git-lfs.tar.gz

  # Install
  cp -f git-lfs-*/git-lfs "${BIN_DIR}/"

  # Clean up
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  # Install Git LFS hooks
  if command -v git >/dev/null 2>&1; then
    "${BIN_DIR}/git-lfs" install --skip-repo
  fi

  echo "Git LFS has been installed to ${BIN_DIR}/git-lfs"
else
  echo "Git LFS is already installed."
fi
