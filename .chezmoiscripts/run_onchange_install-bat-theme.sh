#!/bin/bash
set -eu

echo "Installing Catppuccin themes for bat..."

# Check if bat is installed
if ! command -v bat &>/dev/null; then
  echo "Error: bat is not installed. Please install bat first."
  exit 1
fi

# Check if wget is installed
if ! command -v wget &>/dev/null; then
  echo "Error: wget is not installed. Please install wget first."

  # Try using curl as an alternative if available
  if command -v curl &>/dev/null; then
    echo "Using curl instead of wget..."

    # Create bat themes directory if it doesn't exist
    BAT_THEMES_DIR="$(bat --config-dir)/themes"
    mkdir -p "$BAT_THEMES_DIR"

    # Download all Catppuccin themes using curl
    curl -o "$BAT_THEMES_DIR/Catppuccin Latte.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"
    curl -o "$BAT_THEMES_DIR/Catppuccin Frappe.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme"
    curl -o "$BAT_THEMES_DIR/Catppuccin Macchiato.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"
    curl -o "$BAT_THEMES_DIR/Catppuccin Mocha.tmTheme" -sL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
  else
    echo "Neither wget nor curl is available. Please install one of them first."
    exit 1
  fi
else
  # Create bat themes directory if it doesn't exist
  BAT_THEMES_DIR="$(bat --config-dir)/themes"
  mkdir -p "$BAT_THEMES_DIR"

  # Download all Catppuccin themes using wget
  wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"
  wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme"
  wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme"
  wget -P "$BAT_THEMES_DIR" "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
fi

# Build bat cache
bat cache --build

echo "Catppuccin themes for bat installed successfully"
