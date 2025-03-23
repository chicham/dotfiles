function dotfiles_doctor --description "Check the health of your dotfiles installation and tools"
  set -l tools_to_check \
    "chezmoi" "fish" "starship" "wezterm" "direnv" \
    "nvim" "code" \
    "bat" "eza" "fd" "fzf" "zoxide" "atuin" \
    "git" "git-lfs" "gh" "difft" "git-cliff" "pre-commit" \
    "gcloud" "uv"

  # Add platform-specific tools
  if test (uname) = "Darwin" # macOS
    set -a tools_to_check "brew"
  end

  # Print header
  printf "%-10s %-30s %s\n" "RESULT" "CHECK" "MESSAGE"

  # Check for each tool
  for tool in $tools_to_check
    set -l cmd_name $tool
    set -l display_name $tool

    # Special cases for command names that differ from tool names
    switch $tool
      case "nvim"
        set display_name "neovim"
      case "gh"
        set display_name "github-cli"
      case "difft"
        set display_name "difftastic"
      case "code"
        set display_name "vscode"
      case "eza"
        # Handle potential exa to eza transition
        if not command -q eza; and command -q exa
          set cmd_name "exa"
          set display_name "exa (eza)"
        end
    end

    # Check if tool exists
    if command -q $cmd_name
      set -l version ""

      # Try to get version info using different approaches
      switch $cmd_name
        case "chezmoi" "fish" "starship" "bat" "fd" "fzf" "zoxide" "atuin" "git" "git-lfs" "gh" "git-cliff" "pre-commit" "gcloud" "brew" "uv"
          set version (command $cmd_name --version 2>/dev/null | head -n 1)
        case "nvim"
          set version (command nvim --version 2>/dev/null | head -n 1)
        case "wezterm"
          set version (command wezterm --version 2>/dev/null)
        case "direnv"
          set version (command direnv --version 2>/dev/null)
        case "code"
          set version (command code --version 2>/dev/null | head -n 1)
        case "eza" "exa"
          set version (command $cmd_name --version 2>/dev/null | head -n 1)
        case "difft"
          set version (command difft --version 2>/dev/null | head -n 1)
      end

      # Display result
      printf "%-10s %-30s %s\n" "ok" $display_name $version
    else
      # Tool not found
      printf "%-10s %-30s %s\n" "warning" $display_name "not found"
    end
  end

  # Check for fonts
  set -l fonts_to_check "FiraCode" "SourceCodePro" "Monaspace"

  echo ""
  echo "Font Check:"

  # Check fonts based on OS
  if test (uname) = "Darwin" # macOS
    for font in $fonts_to_check
      if command -q system_profiler
        if system_profiler SPFontsDataType 2>/dev/null | grep -i "$font" >/dev/null
          printf "%-10s %-30s %s\n" "ok" "$font Nerd Font" "installed"
        else
          printf "%-10s %-30s %s\n" "info" "$font Nerd Font" "not found"
        end
      else
        printf "%-10s %-30s %s\n" "info" "$font Nerd Font" "cannot check (system_profiler not available)"
      end
    end
  else # Linux
    if test -d "$HOME/.local/share/fonts" -o -d "/usr/share/fonts"
      for font in $fonts_to_check
        if fc-list | grep -i "$font" >/dev/null
          printf "%-10s %-30s %s\n" "ok" "$font Nerd Font" "installed"
        else
          printf "%-10s %-30s %s\n" "info" "$font Nerd Font" "not found"
        end
      end
    else
      printf "%-10s %-30s %s\n" "info" "Fonts" "cannot check font directories"
    end
  end

  # Additional environment checks
  echo ""
  echo "Environment Check:"

  # Check if running in WezTerm
  if set -q WEZTERM_EXECUTABLE
    printf "%-10s %-30s %s\n" "ok" "WezTerm" "running in WezTerm"
  else
    printf "%-10s %-30s %s\n" "info" "WezTerm" "not running in WezTerm"
  end

  # Check if Git is properly configured
  if command -q git
    set -l git_user (git config --global user.name)
    set -l git_email (git config --global user.email)

    if test -n "$git_user" -a -n "$git_email"
      printf "%-10s %-30s %s\n" "ok" "Git Config" "user.name and user.email are set"
    else
      printf "%-10s %-30s %s\n" "warning" "Git Config" "user.name or user.email not set"
    end
  end

  # Check if GitHub CLI is authenticated
  if command -q gh
    if gh auth status 2>/dev/null >/dev/null
      printf "%-10s %-30s %s\n" "ok" "GitHub Authentication" "authenticated"
    else
      printf "%-10s %-30s %s\n" "info" "GitHub Authentication" "not authenticated (run 'gh auth login')"
    end
  end

  # Check if Atuin is syncing
  if command -q atuin
    if atuin status 2>/dev/null | grep -i "Sync:" | grep -i "enabled" >/dev/null
      printf "%-10s %-30s %s\n" "ok" "Atuin Sync" "enabled"
    else
      printf "%-10s %-30s %s\n" "info" "Atuin Sync" "not enabled (run 'atuin login')"
    end
  end
end
