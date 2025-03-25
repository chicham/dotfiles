# chezmoi:template:left-delimiter="# [[" right-delimiter="]] #"
# Check and install FiraCode Nerd Font if needed
# This runs once when fish starts

# Check if the font installation has been checked this session
if not set -q __firacode_check_done
    set -g __firacode_check_done 1

    # Function to check if FiraCode is installed
    function __is_firacode_installed
        set -l found 1 # Default to not found (return false)

        # [[ if eq .chezmoi.os "darwin" ]] #
        # macOS font check
        if type -q system_profiler
            if system_profiler SPFontsDataType 2>/dev/null | grep -i "FiraCode.*Nerd.*Font" >/dev/null 2>&1
                set found 0 # Font found
            end
        end
        # [[ else ]] #
        # Linux font check
        if type -q fc-list
            if fc-list | grep -i "FiraCode.*Nerd.*Font" >/dev/null 2>&1
                set found 0 # Font found
            end
        end
        # [[ end ]] #

        return $found
    end

    # Check if FiraCode Nerd Font is installed
    if not __is_firacode_installed
        # Only show message if interactive
        if status is-interactive
            echo "FiraCode Nerd Font not found. Installing..."
        end

        # Install FiraCode
        install_nerd_font "FiraCode"
    end

    # Clean up temporary function
    functions -e __is_firacode_installed
end
