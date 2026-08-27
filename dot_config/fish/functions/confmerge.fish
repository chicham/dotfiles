# Merge chezmoi-managed config files with auto-apply by default
function confmerge --description "Merge config files with chezmoi (--apply by default, use --no-apply to disable)"
    # Show help if requested
    if contains -- --help $argv; or contains -- -h $argv
        echo "confmerge - Merge chezmoi-managed config files"
        echo ""
        echo "Usage: confmerge [OPTIONS] FILE..."
        echo ""
        echo "Description:"
        echo "  Merge config files using chezmoi with automatic apply by default."
        echo "  This resolves conflicts and applies changes to your system."
        echo ""
        echo "Options:"
        echo "  --no-apply    Merge without applying changes (manual 'chezmoi apply' needed)"
        echo "  -h, --help    Show this help message"
        echo ""
        echo "Examples:"
        echo "  confmerge ~/.config/fish/config.fish    # Merge and auto-apply"
        echo "  confmerge --no-apply ~/.gitconfig       # Merge only, no apply"
        echo ""
        echo "Note: All other options are passed directly to 'chezmoi merge'"
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
        chezmoi merge $filtered_args
    else
        chezmoi merge --apply $argv
    end
end