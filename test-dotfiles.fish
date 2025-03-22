#!/usr/bin/env fish

# Simple log function that outputs to console
function log
  echo $argv[1]
end

log "===== DOTFILES TEST REPORT ====="
log "Date: "(date)
log "User: "(whoami)
log "Home directory: $HOME"

# Check if the test variables file exists and display its contents
set test_vars_file "$HOME/.local/share/chezmoi-test-variables.txt"
if test -f $test_vars_file
  log "User details from chezmoi:"
  cat $test_vars_file | while read line
    log "  $line"
  end
else
  log "Chezmoi variables test file not found"
end

log "Python: "(command -v python 2>/dev/null || echo 'not found')
log "FUSE status: "(test -e /dev/fuse && ls -la /dev/fuse || echo 'not available')
log "PATH: $PATH"
log "Fish shell: "(command -v fish)
log "================================"

# Source fish config to ensure all PATH settings are loaded
log "Sourcing fish configuration..."
if test -f $HOME/.config/fish/config.fish
  source $HOME/.config/fish/config.fish
  log "Fish configuration sourced successfully"
else
  log "WARNING: Fish configuration file not found"
end

log "Updated PATH: $PATH"
log "STEP 1: Verifying installations..."

# Function to check tool installation
function check_tool
  set tool_name $argv[1]
  set check_cmd $argv[2]

  if test -z "$check_cmd"
    set check_cmd "$tool_name --version"
  end

  echo "TESTING: $tool_name"
  echo "---------------------"
  # Check if tool is installed and in PATH
  if command -v $tool_name >/dev/null 2>&1
    echo "✅ INSTALLED"
    echo "Location: "(command -v $tool_name)
    # Get and log the version
    set VERSION_INFO (eval $check_cmd 2>&1 | head -n 1)
    echo "Version: $VERSION_INFO"
    return 0
  else
    echo "❌ NOT INSTALLED or not in PATH"
    return 1
  end
end

# Check tools installed by chezmoi
echo ""
echo "===== CHEZMOI-INSTALLED TOOLS ====="

# Shell Tools
echo ""
echo "--- Shell Tools ---"
check_tool "fish"
echo ""
check_tool "starship"
echo ""
check_tool "wezterm"

# File Utilities
echo ""
echo "--- File Utilities ---"
check_tool "bat"
echo ""
check_tool "eza"
echo ""
check_tool "fd"
echo ""
check_tool "zoxide"
echo ""
check_tool "fzf"

# Git Tools
echo ""
echo "--- Git Tools ---"
check_tool "git-lfs"
echo ""
check_tool "difft"

# Development Tools
echo ""
echo "--- Development Tools ---"
check_tool "nvim"
echo ""
check_tool "direnv"
echo ""
check_tool "atuin"
echo ""
check_tool "uv"
echo ""
check_tool "rustc" "rustc --version"
echo ""
check_tool "cargo" "cargo --version"

# Cloud Tools
echo ""
echo "--- Cloud Tools ---"
check_tool "gcloud"
echo ""
check_tool "op"

# Check config files
echo ""
echo "===== CONFIG FILES ====="
for cfg in "$HOME/.config/fish/config.fish" "$HOME/.config/starship.toml" "$HOME/.config/nvim/init.lua"
  if test -f $cfg
    echo "✅ $cfg exists"
  else
    echo "❌ $cfg missing"
  end
end

# Theme Testing
echo ""
echo "===== THEME TESTING ====="

# ANSI color codes for displaying theme examples
set RESET "\033[0m"
set BOLD "\033[1m"
set BLUE "\033[34m"
set GREEN "\033[32m"
set YELLOW "\033[33m"
set RED "\033[31m"
set MAGENTA "\033[35m"
set CYAN "\033[36m"

# Check the USER_THEME environment variable
echo "Current USER_THEME: $USER_THEME"

# List available Catppuccin variants
echo ""
echo "Available Catppuccin variants:"
echo "- Catppuccin Mocha (default dark)"
echo "- Catppuccin Latte (light)"
echo "- Catppuccin Frappe (medium-dark)"
echo "- Catppuccin Macchiato (darker)"

# Provide theme switching instructions
echo ""
echo "Theme switching instructions:"
echo "  $CYAN set_theme \"Catppuccin Mocha\"   $RESET # Switch to default dark theme"
echo "  $CYAN set_theme \"Catppuccin Latte\"   $RESET # Switch to light theme"
echo "  $CYAN set_theme \"Catppuccin Frappe\"  $RESET # Switch to medium-dark theme"
echo "  $CYAN set_theme \"Catppuccin Macchiato\" $RESET # Switch to darker theme"

# Show bat preview with current theme
if command -v bat >/dev/null 2>&1
  echo ""
  echo "Theme preview with bat:"
  echo "-------------------"
  set -l sample_text "# Sample code with $USER_THEME theme
def hello_world():
    print('Hello, themed world!')
    return 42

# This demonstrates syntax highlighting
hello_world()  # Function call with comment
"
  echo $sample_text | bat --language python --theme="$USER_THEME" --style=full
end

echo ""
echo "===== TEST COMPLETE ====="
