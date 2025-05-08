function ghcs --description "GitHub Copilot suggest command"
    set -l target "shell"
    set -l gh_debug $GH_DEBUG
    set -l gh_host $GH_HOST

    set -l options 'd/debug' 'h/help' 't/target=' 'hostname='
    argparse $options -- $argv

    if set -q _flag_help
        echo "Wrapper around \`gh copilot suggest\` to suggest a command based on a natural language description."
        echo "Supports executing suggested commands if applicable."
        echo
        echo "USAGE"
        echo "  ghcs [flags] <prompt>"
        echo
        echo "FLAGS"
        echo "  -d, --debug           Enable debugging"
        echo "  -h, --help            Display help usage"
        echo "      --hostname        The GitHub host to use for authentication"
        echo "  -t, --target target   Target for suggestion; must be shell, gh, git"
        echo "                        default: \"$target\""
        echo
        echo "EXAMPLES"
        echo
        echo "- Guided experience"
        echo "  \$ ghcs"
        echo
        echo "- Git use cases"
        echo "  \$ ghcs -t git \"Undo the most recent local commits\""
        echo "  \$ ghcs -t git \"Clean up local branches\""
        echo "  \$ ghcs -t git \"Setup LFS for images\""
        echo
        echo "- Working with the GitHub CLI in the terminal"
        echo "  \$ ghcs -t gh \"Create pull request\""
        echo "  \$ ghcs -t gh \"List pull requests waiting for my review\""
        echo "  \$ ghcs -t gh \"Summarize work I have done in issues and pull requests for promotion\""
        echo
        echo "- General use cases"
        echo "  \$ ghcs \"Kill processes holding onto deleted files\""
        echo "  \$ ghcs \"Test whether there are SSL/TLS issues with github.com\""
        echo "  \$ ghcs \"Convert SVG to PNG and resize\""
        echo "  \$ ghcs \"Convert MOV to animated PNG\""
        return 0
    end

    if set -q _flag_debug
        set gh_debug "api"
    end

    if set -q _flag_hostname
        set gh_host $_flag_hostname
    end

    if set -q _flag_target
        set target $_flag_target
    end

    set -l tmpfile (mktemp -t gh-copilotXXXXXX)
    trap 'rm -f "$tmpfile"' EXIT

    if env GH_DEBUG=$gh_debug GH_HOST=$gh_host gh copilot suggest -t $target $argv --shell-out $tmpfile
        if test -s $tmpfile
            set -l fixed_cmd (cat $tmpfile)
            # Add to history if fish_add_history is available, otherwise just use the command
            if type -q fish_add_history
                echo $fixed_cmd | fish_add_history
            else
                # Fallback: Just run the command without adding to history
                # (Fish will add the eval command to history automatically)
            end
            echo
            eval $fixed_cmd
        end
    else
        return 1
    end
end
