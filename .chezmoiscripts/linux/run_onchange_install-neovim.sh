#!/bin/sh
# vim: set ft=bash:
set -eu

# Install neovim on Linux in user space
if ! command -v nvim >/dev/null 2>&1; then
  echo "Installing neovim..."

  # Create directories
  mkdir -p "${HOME}/.local/bin"
  mkdir -p "${HOME}/.local/share/nvim"
  mkdir -p "${HOME}/.config/nvim"

  # Determine system architecture
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)
      NVIM_ARCH="linux64"
      ;;
    aarch64|arm64)
      NVIM_ARCH="linux-arm64"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  # Download and extract neovim
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"
  TMP_DIR=$(mktemp -d)

  echo "Downloading from ${NVIM_URL}..."
  curl -sL "${NVIM_URL}" | tar xz -C "${TMP_DIR}"

  # Copy neovim to user bin directory
  cp -r "${TMP_DIR}/nvim-${NVIM_ARCH}"/* "${HOME}/.local/"

  # Clean up
  rm -rf "${TMP_DIR}"

  echo "Neovim installed to ${HOME}/.local/bin/nvim"
else
  echo "neovim is already installed."
fi
