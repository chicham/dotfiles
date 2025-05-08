function ghce --description "GitHub Copilot explain command"
    set -l gh_debug $GH_DEBUG
    set -l gh_host $GH_HOST

    set -l options 'd/debug' 'h/help' 'hostname='
    argparse $options -- $argv

    if set -q _flag_help
        echo "Wrapper around \`gh copilot explain\` to explain a given input command in natural language."
        echo
        echo "USAGE"
        echo "  ghce [flags] <command>"
        echo
        echo "FLAGS"
        echo "  -d, --debug      Enable debugging"
        echo "  -h, --help       Display help usage"
        echo "      --hostname   The GitHub host to use for authentication"
        echo
        echo "EXAMPLES"
        echo
        echo "# View disk usage, sorted by size"
        echo "\$ ghce 'du -sh | sort -h'"
        echo
        echo "# View git repository history as text graphical representation"
        echo "\$ ghce 'git log --oneline --graph --decorate --all'"
        echo
        echo "# Remove binary objects larger than 50 megabytes from git history"
        echo "\$ ghce 'bfg --strip-blobs-bigger-than 50M'"
        return 0
    end

    if set -q _flag_debug
        set gh_debug "api"
    end

    if set -q _flag_hostname
        set gh_host $_flag_hostname
    end

    env GH_DEBUG=$gh_debug GH_HOST=$gh_host gh copilot explain $argv
end
