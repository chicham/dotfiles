function pr-clean --description 'Clean up a merged PR workspace'
    if test -z "$argv[1]"
        echo "usage: pr-clean <name>" >&2
        return 1
    end
    jj git fetch --remote origin --branch main
    jj bookmark forget $argv[1] 2>/dev/null
    jj workspace forget $argv[1] 2>/dev/null
    rm -rf ".workspaces/$argv[1]"
end
