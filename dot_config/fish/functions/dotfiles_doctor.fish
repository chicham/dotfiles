function dotfiles_doctor --description "Check dotfiles health and tool installations"
    set -l success_icon "✓"
    set -l warning_icon "!"
    set -l error_icon "✗"

    echo "Dotfiles Health Check"
    echo ""
    echo "System information:"
    echo "  $success_icon hostname:       "(hostname)
    echo "  $success_icon os:             # [[ .chezmoi.os ]] #
    echo "  $success_icon arch:           # [[ .chezmoi.arch ]] #
    echo -n "  $success_icon chezmoi version: "
    command -v chezmoi >/dev/null 2>&1 && chezmoi --version 2>/dev/null || echo "not installed"
    echo ""

    # Get managed files from chezmoi
    set -l managed_files (chezmoi managed)

    echo "Tools and Configuration:"
    echo ""

    # Shell Tools
    echo "## Shell Tools"
    __check_tool_with_configs "fish" ".config/fish/config.fish:.config/fish/aliases.fish" "$managed_files"
    __check_tool_with_configs "starship" ".config/starship.toml" "$managed_files"
    __check_tool_with_configs "wezterm" ".wezterm.lua" "$managed_files"

    echo ""
    echo "## File Utilities"
    __check_tool_with_configs "bat" ".config/bat/config" "$managed_files"
    __check_tool_with_configs "eza" "" "$managed_files"
    __check_tool_with_configs "fd" "" "$managed_files"
    __check_tool_with_configs "zoxide" "" "$managed_files"
    __check_tool_with_configs "fzf" "" "$managed_files"

    echo ""
    echo "## Git Tools"
    __check_tool_with_configs "git" ".gitconfig:.git_template/hooks/pre-commit" "$managed_files"
    __check_tool_with_configs "git-lfs" "" "$managed_files"
    __check_tool_with_configs "difft" "" "$managed_files"
    __check_tool_with_configs "gh" "" "$managed_files"
    # [[ if gt (len (glob ".config/glab-cli")) 0 -]] #
    __check_tool_with_configs "glab" ".config/glab-cli/config.yml:.config/glab-cli/aliases.yml" "$managed_files"
    # [[ end ]] #

    echo ""
    echo "## Development Tools"
    __check_tool_with_configs "nvim" ".config/nvim/init.lua" "$managed_files"
    __check_tool_with_configs "direnv" ".config/direnv/direnvrc" "$managed_files"
    __check_tool_with_configs "atuin" ".config/atuin/config.toml" "$managed_files"
    __check_tool_with_configs "uv" "" "$managed_files"
    __check_tool_with_configs "rustc" "" "$managed_files" "rustc --version"
    __check_tool_with_configs "cargo" "" "$managed_files" "cargo --version"

    echo ""
    echo "## Cloud Tools"
    __check_tool_with_configs "gcloud" "" "$managed_files"
    __check_tool_with_configs "op" "" "$managed_files"
    # [[ if eq .chezmoi.os "darwin" -]] #
    __check_tool_with_configs "aerospace" ".config/aerospace/aerospace.toml" "$managed_files"
    # [[ end ]] #

    echo ""
    echo "Environment Variables:"
    # Get current fish theme
    set -l current_theme "Unknown"
    if type -q fish_config
        # Try to get the current theme
        set -l theme_output (fish_config theme show 2>/dev/null)
        if test $status -eq 0
            # Extract theme name from output
            set current_theme (string match -r 'theme: (.*)' -- "$theme_output" | string replace -r 'theme: (.*)' '$1')
        end
    end

    echo "  $success_icon EDITOR:         $EDITOR"
    echo "  $success_icon TERM:           $TERM"

    if command -v chezmoi >/dev/null 2>&1
        echo ""
        echo "Chezmoi Status:"
        chezmoi doctor
    end
end
