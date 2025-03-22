#!/bin/sh

# Install fish shell for Linux without requiring root/sudo
# https://fishshell.com/

set -eu

# Function to compare major.minor versions
version_gt() {
  # Extract MAJOR.MINOR from versions ignoring patch
  local ver1_major_minor=$(echo "$1" | cut -d. -f1-2)
  local ver2_major_minor=$(echo "$2" | cut -d. -f1-2)

  # Compare using float comparison
  awk "BEGIN {exit !($ver1_major_minor > $ver2_major_minor)}"
}

# Get latest release version from GitHub
get_latest_fish_version() {
  API_RESPONSE=$(curl -s https://api.github.com/repos/fish-shell/fish-shell/releases/latest)

  # Check if we hit rate limit
  if echo "$API_RESPONSE" | grep -q "API rate limit exceeded"; then
    echo "GitHub API rate limit exceeded. Using fallback version."
    echo "3.6.1"  # Fallback to a known version
  else
    FISH_VERSION=$(echo "$API_RESPONSE" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    # Remove 'fish-' prefix if present
    FISH_VERSION=${FISH_VERSION#fish-}

    # Check if version was found
    if [ -z "$FISH_VERSION" ]; then
      echo "Failed to get latest version from GitHub API, using 3.6.1 as fallback."
      echo "3.6.1"
    else
      echo "$FISH_VERSION"
    fi
  fi
}

# Function to install or update fish
install_fish() {
  local FISH_VERSION="$1"
  local FISH_INSTALL_DIR="$HOME/.local"

  echo "Installing fish shell version $FISH_VERSION..."

  # Add Rust to PATH if available (needed for fish build dependencies)
  if [ -d "$HOME/.cargo/bin" ]; then
    echo "Adding Rust to PATH for fish build..."
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  # Create temp directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  # Download the source code
  curl -L "https://github.com/fish-shell/fish-shell/releases/download/${FISH_VERSION}/fish-${FISH_VERSION}.tar.xz" -o "fish.tar.xz"

  # Extract the tarball
  tar -xJf "fish.tar.xz"
  cd "fish-${FISH_VERSION}"

  # Make sure the destination directory exists
  mkdir -p "$FISH_INSTALL_DIR/bin"

  # Configure and build fish using cmake
  echo "Building fish with CMake..."
  cmake . -DCMAKE_INSTALL_PREFIX="$FISH_INSTALL_DIR"
  make -j$(nproc 2>/dev/null || echo 1)
  make install

  # Cleanup
  cd "$HOME"
  rm -rf "$TEMP_DIR"

  echo "fish shell installed to $FISH_INSTALL_DIR/bin/fish"
}

# Check if fish is already installed
if command -v fish >/dev/null 2>&1; then
  CURRENT_VERSION=$(fish --version | sed -E 's/.*version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
  echo "Fish shell is already installed (version $CURRENT_VERSION)."

  # Get latest version
  LATEST_VERSION=$(get_latest_fish_version)
  echo "Latest fish shell version: $LATEST_VERSION"

  # Compare versions ignoring patch
  if version_gt "$LATEST_VERSION" "$CURRENT_VERSION"; then
    echo "Newer version available. Updating fish from $CURRENT_VERSION to $LATEST_VERSION..."
    install_fish "$LATEST_VERSION"
  else
    echo "Current fish version is up to date (major.minor). Skipping update."
  fi
else
  echo "Fish shell is not installed. Installing now..."
  LATEST_VERSION=$(get_latest_fish_version)
  install_fish "$LATEST_VERSION"
fi

# Get the path to fish shell
FISH_PATH="$(command -v fish || echo "$HOME/.local/bin/fish")"

# Create a wrapper script in ~/.local/bin to launch fish
WRAPPER_SCRIPT="${HOME}/.local/bin/start-fish"
mkdir -p "${HOME}/.local/bin"

# Create a wrapper script that launches fish
cat > "${WRAPPER_SCRIPT}" << EOF
#!/bin/sh
exec "${FISH_PATH}" "\$@"
EOF
chmod +x "${WRAPPER_SCRIPT}"

# Add to shell config to auto-start fish for interactive shells
for RC_FILE in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
  if [ -f "${RC_FILE}" ] && ! grep -q "start-fish" "${RC_FILE}"; then
    {
      echo ""
      echo "# Auto-start fish shell for interactive sessions"
      echo "if [ -t 1 ] && [ -x ${WRAPPER_SCRIPT} ]; then"
      echo "  exec ${WRAPPER_SCRIPT}"
      echo "fi"
    } >> "${RC_FILE}"
  fi
done

echo "Fish shell installation/update complete."
