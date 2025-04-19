#!/bin/sh
# Installs and configures Python development tools using uv package manager:
# - nbdime for Jupyter notebook diffing (--force flag handles existing installs)
# - pre-commit for git hooks with template directory setup
# Runs last (zzzzz prefix) to ensure dependencies are available

set -eu

# Function to check if a command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Function to check if git hook template exists
template_exists() {
  _hook_type="$1"
  _template_dir="$HOME/.git_template/hooks"
  if [ -f "$_template_dir/$_hook_type" ]; then
    return 0 # File exists
  fi
  return 1 # File doesn't exist
}

# Function to check if nbdime is already configured in git
nbdime_configured() {
  # Check specifically for the jupyter notebook diff command configuration
  if git config --global --get diff.jupyternotebook.command > /dev/null 2>&1; then
    return 0 # Already configured
  fi
  return 1 # Not configured
}

# Ensure local bin directory is in PATH
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"
# Add to PATH for this script execution
PATH="$LOCAL_BIN_DIR:$PATH"
export PATH

# Ensure uv is installed first - check both PATH and ~/.local/bin
UV_CMD="uv"
if ! command_exists uv; then
  if [ -x "$LOCAL_BIN_DIR/uv" ]; then
    UV_CMD="$LOCAL_BIN_DIR/uv"
    echo "Using uv from $LOCAL_BIN_DIR"
  else
    echo "uv is required but not installed. Install uv first."
    exit 1
  fi
fi

# Install/upgrade Python tools with proper error handling
echo "Installing/upgrading Python development tools..."

# Install or upgrade nbdime to handle existing installations
"$UV_CMD" tool install --upgrade nbdime || echo "Error: Failed to install/upgrade nbdime"

# Install or upgrade pre-commit
"$UV_CMD" tool install --upgrade pre-commit || echo "Error: Failed to install/upgrade pre-commit"

echo "Python development tools installation complete."

# Initialize pre-commit git template directory
echo "Checking pre-commit git templates..."

# Create template directory if it doesn't exist
mkdir -p "$HOME/.git_template/hooks"

# Check for existing templates and only install missing ones
TEMPLATES="commit-msg pre-commit pre-push"
MISSING_TEMPLATES=""

for template in $TEMPLATES; do
  if ! template_exists "$template"; then
    MISSING_TEMPLATES="$MISSING_TEMPLATES -t $template"
  else
    echo "Git hook template '$template' already exists, skipping"
  fi
done

# Only run init-templatedir if there are missing templates
if [ -n "$MISSING_TEMPLATES" ]; then
  echo "Setting up missing git templates..."
  # Since we added LOCAL_BIN_DIR to PATH earlier, pre-commit should be available
  # but let's add a fallback just in case
  PRE_COMMIT_CMD="pre-commit"
  if ! command_exists pre-commit && [ -x "$LOCAL_BIN_DIR/pre-commit" ]; then
    PRE_COMMIT_CMD="$LOCAL_BIN_DIR/pre-commit"
    echo "Using pre-commit from $LOCAL_BIN_DIR"
  fi

  # Use eval to properly handle the constructed command with multiple -t flags
  eval "$PRE_COMMIT_CMD init-templatedir $MISSING_TEMPLATES $HOME/.git_template"
else
  echo "All git hook templates already exist, skipping installation"
fi

# Set up nbdime git integration only if not already configured
if ! nbdime_configured; then
  echo "Setting up nbdime git integration..."
  # Similar fallback for nbdime
  NBDIME_CMD="nbdime"
  if ! command_exists nbdime && [ -x "$LOCAL_BIN_DIR/nbdime" ]; then
    NBDIME_CMD="$LOCAL_BIN_DIR/nbdime"
    echo "Using nbdime from $LOCAL_BIN_DIR"
  fi

  # Run nbdime config-git with --global flag first to ensure it affects global gitconfig
  "$NBDIME_CMD" config-git --global --enable

  # Verify configuration was successful
  if nbdime_configured; then
    echo "Successfully configured nbdime git integration"
  else
    echo "Warning: Failed to configure nbdime git integration"
  fi
else
  echo "nbdime git integration already configured, skipping"
fi

echo "Python development tools setup complete."

# Note: We intentionally avoid running 'uv tool update-shell' here, as that would modify
# shell configuration files like config.fish directly, bypassing chezmoi's management.
# Instead, chezmoi should manage the PATH updates through its own templates.
