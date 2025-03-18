#!/bin/sh
# Script to install pre-commit using uv and set up template directory

set -eu

# Check if uv is installed
if ! command -v uv >/dev/null 2>&1; then
  echo "Error: uv is not installed."
  echo "Please install uv first: https://github.com/astral-sh/uv"
  exit 1
fi

# Install pre-commit using uv
echo "Installing pre-commit globally using uv..."
uv pip install --system pre-commit

echo "pre-commit installed successfully"

# Initialize the git template directory with pre-commit hooks
echo "Setting up git template directory..."
GIT_TEMPLATE_DIR="${HOME}/.git_template"

# Create template directory if it doesn't exist
mkdir -p "${GIT_TEMPLATE_DIR}"

# Initialize the template directory with pre-commit hooks
pre-commit init-templatedir "${GIT_TEMPLATE_DIR}"

echo "Git template directory initialized with pre-commit hooks"
