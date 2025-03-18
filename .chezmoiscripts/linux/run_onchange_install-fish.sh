#!/bin/sh

# Install fish shell for Linux without root privileges
# https://fishshell.com/

set -eu

if ! command -v fish >/dev/null 2>&1; then
  echo "Installing fish shell from source to ~/.local/..."

  # Set directories
  INSTALL_DIR="${HOME}/.local"
  BUILD_DIR="$(mktemp -d)"

  # Get latest release version using a more portable approach
  VERSION=$(curl -s https://api.github.com/repos/fish-shell/fish-shell/releases/latest | grep "tag_name" | sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')

  cd "${BUILD_DIR}"

  # Download source
  echo "Downloading fish ${VERSION}..."
  curl -Lo fish.tar.gz "https://github.com/fish-shell/fish-shell/releases/download/${VERSION}/fish-${VERSION}.tar.xz"
  tar -xf fish.tar.gz
  cd "fish-${VERSION}"

  # Configure and build without root privileges
  echo "Configuring and building fish..."
  ./configure --prefix="${INSTALL_DIR}"
  make -j4
  make install

  # Clean up
  cd "${HOME}"
  rm -rf "${BUILD_DIR}"

  # Add fish to PATH if not already there
  if ! echo "${PATH}" | grep -q "${INSTALL_DIR}/bin"; then
    echo "export PATH=\"${INSTALL_DIR}/bin:\${PATH}\"" >> "${HOME}/.profile"
    export PATH="${INSTALL_DIR}/bin:${PATH}"
  fi

  echo "fish shell has been installed to ${INSTALL_DIR}/bin/fish"
else
  echo "fish shell is already installed."
fi

# Get the path to fish shell
FISH_PATH="$(command -v fish)"

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
    echo "" >> "${RC_FILE}"
    echo "# Auto-start fish shell for interactive sessions" >> "${RC_FILE}"
    echo "if [ -t 1 ] && [ -x ${WRAPPER_SCRIPT} ]; then" >> "${RC_FILE}"
    echo "  exec ${WRAPPER_SCRIPT}" >> "${RC_FILE}"
    echo "fi" >> "${RC_FILE}"
    echo "Added fish auto-start to ${RC_FILE}"
  fi
done

echo "Fish shell installed successfully."
echo "When you open a new terminal session, fish will automatically start."
