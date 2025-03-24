#!/bin/sh
# Script to install Python development tools using uv
# Installs pre-commit and nbdime on both macOS and Linux
# This script runs last due to "zzzzz" in the name

set -eu

# Function to check if a command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Ensure uv is installed first
if ! command_exists uv; then
  echo "uv is required but not installed. Install uv first."
  exit 1
fi

# Install or update Python tools with a single command
echo "Installing/updating Python development tools..."
uv tool install --upgrade nbdime
uv tool install --upgrade pre-commit
echo "Python tools installed/updated successfully."

# Initialize pre-commit git template directory
echo "Setting up pre-commit git templates..."
pre-commit init-templatedir -t commit-msg -t pre-commit -t pre-push ~/.git_template

# Set up nbdime git integration
echo "Setting up nbdime git integration..."
nbdime config-git --enable --global

echo "Python development tools setup complete."
