#!/bin/sh
# Script to install or update GitHub CLI (gh) on Linux using binary releases

set -eu

echo "Checking GitHub CLI (gh) installation..."

# Create bin directory if it doesn't exist
bin_dir="${HOME}/.local/bin"
mkdir -p "${bin_dir}"

# Get the latest release version
latest_version=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
echo "Latest GitHub CLI version: ${latest_version}"

# Check if gh is already installed and get current version
needs_install=true
if command -v gh > /dev/null 2>&1; then
  current_version=$(gh --version | head -n 1 | cut -d' ' -f3)
  echo "Current GitHub CLI version: ${current_version}"

  # Compare versions (simple string comparison)
  if [ "${current_version}" = "${latest_version}" ]; then
    echo "GitHub CLI is already at the latest version"
    needs_install=false
  else
    echo "Updating GitHub CLI from ${current_version} to ${latest_version}"
  fi
else
  echo "GitHub CLI is not installed, installing version ${latest_version}"
fi

# Install only if needed
if [ "${needs_install}" = "true" ]; then
  # Define temporary directory
  tmp_dir=$(mktemp -d)
  trap 'rm -rf ${tmp_dir}' EXIT

  # Use architecture from chezmoi
  arch="{{ .chezmoi.arch }}"

  # Set download URL
  download_url="https://github.com/cli/cli/releases/download/v${latest_version}/gh_${latest_version}_linux_${arch}.tar.gz"

  # Download and extract
  echo "Downloading from ${download_url}..."
  curl -sSL "${download_url}" -o "${tmp_dir}/gh.tar.gz"
  echo "Extracting archive..."
  tar -xzf "${tmp_dir}/gh.tar.gz" -C "${tmp_dir}"

  # Find extracted directory (naming may vary)
  extracted_dir=$(find "${tmp_dir}" -type d -name "gh_*" | head -n 1)
  if [ -z "${extracted_dir}" ]; then
    # Try another pattern if the first one fails
    extracted_dir=$(find "${tmp_dir}" -type d -mindepth 1 -maxdepth 1 | head -n 1)
  fi

  # Install binary
  if [ -d "${extracted_dir}" ]; then
    echo "Installing GitHub CLI to ${bin_dir}/gh..."
    cp "${extracted_dir}/bin/gh" "${bin_dir}/"
    chmod +x "${bin_dir}/gh"
  else
    echo "Error: Could not find extracted directory"
    exit 1
  fi
fi
