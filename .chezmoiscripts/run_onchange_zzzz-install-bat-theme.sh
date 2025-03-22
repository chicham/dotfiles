#!/bin/bash
set -e

echo "Installing Catppuccin themes for bat..."

# Check if bat is installed
if ! command -v bat &>/dev/null; then
  echo "Warning: bat is not installed. Skipping theme installation."
  exit 0
fi

# Get bat themes directory
BAT_THEMES_DIR="$(bat --config-dir)/themes"
mkdir -p "$BAT_THEMES_DIR"

# Function to download themes
download_themes() {
  local method=$1
  
  echo "Downloading Catppuccin themes using $method..."
  
  if [ "$method" = "curl" ]; then
    # Download with curl
    curl -o "$BAT_THEMES_DIR/Catppuccin Latte.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"
    curl -o "$BAT_THEMES_DIR/Catppuccin Frappe.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme"
    curl -o "$BAT_THEMES_DIR/Catppuccin Macchiato.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"
    curl -o "$BAT_THEMES_DIR/Catppuccin Mocha.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
  elif [ "$method" = "wget" ]; then
    # Download with wget
    wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"
    wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme"
    wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"
    wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
  else
    echo "Error: Unknown download method: $method"
    return 1
  fi
  
  return 0
}

# Try to download themes with wget first, then fall back to curl
if command -v wget &>/dev/null; then
  download_themes "wget"
elif command -v curl &>/dev/null; then
  download_themes "curl"
else
  echo "Error: Neither wget nor curl is available. Please install one of them first."
  exit 1
fi

# Build bat cache
bat cache --build

echo "Catppuccin themes for bat installed successfully"
