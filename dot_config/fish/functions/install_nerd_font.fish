# chezmoi:template:left-delimiter="# [[" right-delimiter="]] #"
function install_nerd_font --description "Install a Nerd Font" --argument font_name
    if test -z "$font_name"
        echo "Usage: install_nerd_font FONTNAME"
        echo "Example: install_nerd_font JetBrainsMono"
        echo "Available fonts: https://www.nerdfonts.com"
        return 1
    end

    # Define logging functions
    function log_task
        printf "\033[0;34m➔ %s\033[0m\n" $argv
    end

    function log_subtask
        printf "  \033[0;36m↪ %s\033[0m\n" $argv
    end

    function log_success
        printf "  \033[0;32m✓ %s\033[0m\n" $argv
    end

    function log_error
        printf "  \033[0;31m✗ %s\033[0m\n" $argv >&2
    end

    # Get the latest Nerd Fonts version from GitHub API
    function get_latest_version
        set -l latest_version
        if type -q curl
            set latest_version (curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        else if type -q wget
            set latest_version (wget -qO- "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        else
            # Default fallback version
            set latest_version "3.1.1"
        end

        # If version couldn't be retrieved, use fallback
        if test -z "$latest_version"
            set latest_version "3.1.1"
        end

        echo $latest_version
    end

    # Check if a font is already installed
    function font_installed
        set -l found 1 # Default to not found (return false)

        # [[ if eq .chezmoi.os "darwin" ]] #
        # On macOS, use system_profiler to list fonts
        if type -q system_profiler
            if system_profiler SPFontsDataType 2>/dev/null | grep -i "$font_name.*Nerd.*Font" >/dev/null 2>&1
                set found 0 # Font found
            end
        end
        # [[ else ]] #
        # On Linux, use fc-list to check for installed fonts
        if type -q fc-list
            if fc-list | grep -i "$font_name.*Nerd.*Font" >/dev/null 2>&1
                set found 0 # Font found
            end
        end
        # [[ end ]] #

        return $found
    end

    # Set font directory based on OS using chezmoi templating
    # [[ if eq .chezmoi.os "darwin" ]] #
    # macOS fonts directory
    set FONTS_DIR "$HOME/Library/Fonts"
    # [[ else ]] #
    # Linux fonts directory
    set FONTS_DIR "$HOME/.local/share/fonts"
    mkdir -p "$FONTS_DIR"
    # [[ end ]] #

    log_task "Installing $font_name Nerd Font"

    # Get the latest version
    set NERD_FONTS_VERSION (get_latest_version)
    log_subtask "Using Nerd Fonts version: $NERD_FONTS_VERSION"

    # Check if font is already installed
    if font_installed $font_name
        log_success "$font_name Nerd Font already installed, skipping"
        return 0
    end

    # Create temporary directory
    set DOWNLOAD_DIR (mktemp -d)
    pushd $DOWNLOAD_DIR

    # Construct download URL
    set font_url "https://github.com/ryanoasis/nerd-fonts/releases/download/v$NERD_FONTS_VERSION/$font_name.zip"

    log_subtask "Downloading $font_name Nerd Font..."

    # Download font
    if type -q curl
        curl -fsSL "$font_url" -o "$font_name.zip"
    else if type -q wget
        wget -q "$font_url" -O "$font_name.zip"
    else
        log_error "Neither curl nor wget found. Cannot download fonts."
        popd
        rm -rf "$DOWNLOAD_DIR"
        return 1
    end

    # Create temporary directory for extraction
    mkdir -p "$font_name"

    # Extract font files
    if type -q unzip
        unzip -q "$font_name.zip" -d "$font_name"
    else
        log_error "unzip not found. Cannot extract font files."
        popd
        rm -rf "$DOWNLOAD_DIR"
        return 1
    end

    # Copy font files to fonts directory - ignoring errors for files that don't exist
    cp "$font_name"/*.ttf "$FONTS_DIR/" 2>/dev/null; or true
    cp "$font_name"/*.otf "$FONTS_DIR/" 2>/dev/null; or true

    # Clean up
    popd
    rm -rf "$DOWNLOAD_DIR"

    # Update font cache on Linux
    # [[ if ne .chezmoi.os "darwin" ]] #
    if type -q fc-cache
        log_subtask "Updating font cache..."
        fc-cache -f
        log_success "Font cache updated"
    end
    # [[ end ]] #

    log_success "$font_name Nerd Font installed"
    echo "You can update your WezTerm configuration to use $font_name Nerd Font"
end
