# Edit chezmoi-managed config files with auto-apply by default
function confedit --description "Edit config files with chezmoi (--apply by default, use --no-apply to disable)"
    # Show help if requested
    if contains -- --help $argv; or contains -- -h $argv
        echo "confedit - Edit chezmoi-managed config files"
        echo ""
        echo "Usage: confedit [OPTIONS] FILE..."
        echo ""
        echo "Description:"
        echo "  Edit config files using chezmoi with automatic apply by default."
        echo "  This ensures changes are immediately applied to your system."
        echo ""
        echo "Options:"
        echo "  --no-apply    Edit without applying changes (manual 'chezmoi apply' needed)"
        echo "  -h, --help    Show this help message"
        echo ""
        echo "Examples:"
        echo "  confedit ~/.config/fish/config.fish    # Edit and auto-apply"
        echo "  confedit --no-apply ~/.gitconfig       # Edit only, no apply"
        echo ""
        echo "Note: All other options are passed directly to 'chezmoi edit'"
        return 0
    end

    # Check if chezmoi is available
    if not type -q chezmoi
        echo "Error: chezmoi is not installed or not in PATH"
        return 1
    end

    # Handle --no-apply flag
    if contains -- --no-apply $argv
        set -l filtered_args
        for arg in $argv
            if test "$arg" != "--no-apply"
                set -a filtered_args $arg
            end
        end
        chezmoi edit $filtered_args
    else
        chezmoi edit --apply $argv
    end
end