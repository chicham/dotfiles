#!/bin/sh

# Helper script to install WezTerm on a remote Linux server
# Ensures that the remote and local versions match
# https://github.com/wez/wezterm

set -eu

# Print usage information
usage() {
  echo "Usage: $0 [options] <remote_host>"
  echo ""
  echo "Options:"
  echo "  -h, --help         Show this help message"
  echo "  -u, --user USER    Remote username (default: current user)"
  echo "  -p, --port PORT    SSH port (default: 22)"
  echo "  -i, --identity FILE  SSH identity file"
  echo "  -n, --nightly      Install nightly build instead of stable"
  echo ""
  echo "Examples:"
  echo "  $0 user@example.com"
  echo "  $0 --user admin --port 2222 example.com"
  echo "  $0 --nightly --identity ~/.ssh/id_ed25519 example.com"
}

# Default values
SSH_USER="$(whoami)"
SSH_PORT=22
SSH_IDENTITY=""
USE_NIGHTLY=false
SSH_OPTS=""

# Parse command-line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -u|--user)
      if [ -z "$2" ]; then
        echo "Error: --user requires an argument"
        exit 1
      fi
      SSH_USER="$2"
      shift 2
      ;;
    -p|--port)
      if [ -z "$2" ]; then
        echo "Error: --port requires an argument"
        exit 1
      fi
      SSH_PORT="$2"
      shift 2
      ;;
    -i|--identity)
      if [ -z "$2" ]; then
        echo "Error: --identity requires an argument"
        exit 1
      fi
      SSH_IDENTITY="$2"
      SSH_OPTS="${SSH_OPTS} -i ${SSH_IDENTITY}"
      shift 2
      ;;
    -n|--nightly)
      USE_NIGHTLY=true
      shift
      ;;
    -*)
      echo "Error: Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      # Last argument is the remote host
      REMOTE_HOST="$1"
      shift
      break
      ;;
  esac
done

# Check if remote host is provided
if [ -z "${REMOTE_HOST:-}" ]; then
  echo "Error: Remote host is required"
  usage
  exit 1
fi

# Build SSH command
SSH_CMD="ssh ${SSH_OPTS} -p ${SSH_PORT} ${SSH_USER}@${REMOTE_HOST}"

# Get local WezTerm version
if command -v wezterm >/dev/null 2>&1; then
  LOCAL_VERSION=$(wezterm --version | awk '{print $2}')
  echo "Local WezTerm version: ${LOCAL_VERSION}"
else
  echo "WezTerm is not installed locally. Installing on remote without version check."
  LOCAL_VERSION=""
fi

# Create a temporary installation script
TEMP_SCRIPT=$(mktemp)
chmod +x "${TEMP_SCRIPT}"

# Write the remote installation script
cat > "${TEMP_SCRIPT}" << 'EOF'
#!/bin/sh

set -eu

# Function to install WezTerm
install_wezterm() {
  VERSION="$1"
  NIGHTLY="$2"

  echo "Installing WezTerm on remote server..."

  # Set directory for binaries
  BIN_DIR="${HOME}/.local/bin"
  mkdir -p "${BIN_DIR}"

  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  # Determine download URL
  if [ "${NIGHTLY}" = "true" ]; then
    echo "Downloading WezTerm nightly build..."
    DOWNLOAD_URL="https://github.com/wez/wezterm/releases/download/nightly/wezterm-nightly-ubuntu20.04.tar.gz"
  else
    if [ -n "${VERSION}" ]; then
      echo "Downloading WezTerm version ${VERSION}..."
      DOWNLOAD_URL="https://github.com/wez/wezterm/releases/download/${VERSION}/wezterm-${VERSION}-ubuntu20.04.tar.gz"
    else
      echo "Downloading latest stable WezTerm version..."
      # Get latest release
      LATEST_RELEASE=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep "tag_name" | sed -E 's/.*"tag_name": "v?([^"]+)".*/\1/')
      DOWNLOAD_URL="https://github.com/wez/wezterm/releases/download/${LATEST_RELEASE}/wezterm-${LATEST_RELEASE}-ubuntu20.04.tar.gz"
    fi
  fi

  # Download the tarball
  echo "Downloading from: ${DOWNLOAD_URL}"
  curl -Lo wezterm.tar.gz "${DOWNLOAD_URL}"

  # Extract the tarball
  echo "Extracting WezTerm files..."
  tar -xzf wezterm.tar.gz
  cd wezterm*

  # Copy binaries to ~/.local/bin
  cp -f wezterm "${BIN_DIR}/"
  cp -f wezterm-gui "${BIN_DIR}/"
  cp -f wezterm-mux-server "${BIN_DIR}/"
  cp -f strip-ansi-escapes "${BIN_DIR}/"

  # Clean up
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "WezTerm installed to ${BIN_DIR}/wezterm"

  # Check installation
  if [ -x "${BIN_DIR}/wezterm" ]; then
    "${BIN_DIR}/wezterm" --version
    echo "Installation successful!"
  else
    echo "Installation failed. Please check for errors."
    exit 1
  fi
}

# Main execution
VERSION="$1"
NIGHTLY="$2"
install_wezterm "${VERSION}" "${NIGHTLY}"
EOF

# Copy the script to the remote server and execute it
echo "Connecting to ${SSH_USER}@${REMOTE_HOST}..."
scp "${SSH_OPTS}" -P "${SSH_PORT}" "${TEMP_SCRIPT}" "${SSH_USER}@${REMOTE_HOST}:wezterm-install.sh"
${SSH_CMD} "chmod +x ~/wezterm-install.sh && ./wezterm-install.sh '${LOCAL_VERSION}' '${USE_NIGHTLY}' && rm ~/wezterm-install.sh"

# Clean up
rm "${TEMP_SCRIPT}"

echo "Remote installation complete."
