#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# Check if this is a terminal session
if [ -t 1 ]; then
  TTY_FLAG="-it"
else
  # No TTY available
  echo "Warning: No TTY detected. Container will run without interactive terminal."
  TTY_FLAG="-i"
fi

# We're now using the dotfiles_doctor function for testing

# Build Docker image with progress=plain to show more verbose output
docker build --progress=plain -t artefiles-test-linux -f Dockerfile.linux .

# Run container with appropriate terminal settings
echo "Starting Docker container to test dotfiles on Linux..."
docker run $TTY_FLAG --rm artefiles-test-linux
