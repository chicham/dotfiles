#!/bin/sh

# Install fzf using git method
# https://github.com/junegunn/fzf#using-git

set -eu

FZF_DIR="${HOME}/.fzf"

if [ -d "$FZF_DIR" ]; then
  echo "fzf directory exists, updating..."
  cd "$FZF_DIR"
  git pull
  ./install --bin
else
  echo "Installing fzf using git clone method..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR"
  "$FZF_DIR/install" --bin
fi