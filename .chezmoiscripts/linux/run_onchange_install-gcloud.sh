#!/bin/sh

# This script installs Google Cloud SDK on Linux
# https://cloud.google.com/sdk/docs/install-sdk

# -e: exit on error
# -u: exit on unset variables
set -eu

# Check if Google Cloud SDK is already installed
if command -v gcloud >/dev/null 2>&1; then
  echo "Google Cloud SDK is already installed."
else
  echo "Installing Google Cloud SDK..."

  # Create temp directory for the download
  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  # Download and install the Google Cloud SDK
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
  tar -xf google-cloud-cli-linux-x86_64.tar.gz

  # Move to ~/.local
  mkdir -p "${HOME}/.local"
  mv google-cloud-sdk "${HOME}/.local/"

  # Install without prompting
  "${HOME}/.local/google-cloud-sdk/install.sh" --quiet --usage-reporting=false --command-completion=false --path-update=false

  # Clean up
  cd - > /dev/null
  rm -rf "${TEMP_DIR}"

  echo "Google Cloud SDK has been installed to ${HOME}/.local/google-cloud-sdk"
  echo "Use 'gcloud init' to initialize the SDK and authenticate."
fi

# Display installed components
if command -v gcloud >/dev/null 2>&1; then
  echo "Installed Google Cloud SDK components:"
  gcloud components list
fi
