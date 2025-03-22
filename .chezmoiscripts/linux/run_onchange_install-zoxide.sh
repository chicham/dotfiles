#!/bin/sh

# Install zoxide (smarter cd command)
# https://github.com/ajeetdsouza/zoxide

set -eu

# Use the recommended installation method directly
echo "Installing/updating zoxide..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
