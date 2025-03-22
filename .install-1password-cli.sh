#!/bin/sh
# Script to install 1Password CLI as a chezmoi pre-read-source-state hook
# Exit immediately if 1Password CLI is already installed
command -v op >/dev/null 2>&1 && exit 0

set -eu

echo "Installing 1Password CLI..."

# Function to get the latest 1Password CLI version
get_latest_cli_version() {
  CLI_URL="https://app-updates.agilebits.com/product_history/CLI2"

  if command -v curl >/dev/null 2>&1 && command -v awk >/dev/null 2>&1; then
    # Parse the HTML page to find the latest version (non-beta)
    VERSION=$(curl -s "$CLI_URL" | awk -v RS='<h3>|</h3>' 'NR % 2 == 0 {
      gsub(/[[:blank:]]+/, "");
      gsub(/<span[^>]*>|<\/span>|[\r\n]+/, "");
      gsub(/&nbsp;.*$/, "");
      if (!non_beta && !/beta/){
        print;
        non_beta=1;
      }
    }')

    # Remove any 'v' prefix if present and trailing period
    VERSION=$(echo "$VERSION" | sed 's/^v//;s/\.$//')

    # Fallback if parsing fails
    if [ -z "$VERSION" ]; then
      VERSION="2.24.0"
    fi
  else
    # Fallback to a specific version if curl or awk is not available
    VERSION="2.24.0"
  fi

  echo "$VERSION"
}

# Main installation logic
case "$(uname -s)" in
Darwin)
  # macOS: Install via Homebrew
  if command -v brew >/dev/null 2>&1; then
    brew install --cask 1password-cli
  else
    VERSION=$(get_latest_cli_version)
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    curl -sSfLo op.pkg "https://cache.agilebits.com/dist/1P/op2/pkg/v${VERSION}/op_apple_universal_v${VERSION}.pkg"

    # Extract package content without using installer (which requires sudo)
    if command -v pkgutil >/dev/null 2>&1; then
      pkgutil --expand op.pkg temp-pkg
      if [ -f temp-pkg/op.pkg/Payload ]; then
        mkdir -p "${HOME}/.local/bin"
        tar -xvf temp-pkg/op.pkg/Payload -C "$TEMP_DIR"
        mv "$TEMP_DIR/usr/local/bin/op" "${HOME}/.local/bin/"
        chmod +x "${HOME}/.local/bin/op"
        echo "1Password CLI installed to ${HOME}/.local/bin/op"
      else
        echo "Failed to extract 1Password CLI package"
      fi
      rm -rf temp-pkg
      rm op.pkg
    else
      echo "pkgutil not found, cannot extract package"
      exit 1
    fi

    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    # Create .1password directory and symlink for SSH agent
    mkdir -p "${HOME}/.1password"
    if [ -d "${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password" ]; then
      ln -sf "${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "${HOME}/.1password/agent.sock"
      echo "Created symlink for 1Password SSH agent socket at ${HOME}/.1password/agent.sock"
    fi
  fi
  ;;
Linux)
  # Linux: Direct installation without sudo
  VERSION=$(get_latest_cli_version)

  # Get architecture
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
  else
    echo "Error: Unsupported architecture: $ARCH"
    exit 0
  fi

  echo "Installing 1Password CLI version ${VERSION}..."

  # Create directories
  mkdir -p "${HOME}/.local/bin"

  # Download and install
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  curl -sSfLo op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${VERSION}/op_linux_${ARCH}_v${VERSION}.zip"
  unzip -q op.zip

  # Move binary to local bin
  mv op "${HOME}/.local/bin/"
  chmod +x "${HOME}/.local/bin/op"

  # Create the .1password directory for SSH agent
  mkdir -p "${HOME}/.1password"

  # Cleanup
  cd - > /dev/null
  rm -rf "$TEMP_DIR"

  echo "1Password CLI version ${VERSION} installed to ${HOME}/.local/bin/op"
  echo "Created directory ${HOME}/.1password for SSH agent socket"
  ;;
*)
  echo "Unsupported OS for 1Password CLI installation"
  exit 1
  ;;
esac
