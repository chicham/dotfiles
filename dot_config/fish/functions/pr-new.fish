function pr-new --description 'Start a PR workspace from latest origin/main'
    if test -z "$argv[1]"
        echo "usage: pr-new <name>" >&2
        return 1
    end
    jj git fetch --remote origin --branch main
    or return
    jj workspace add ".workspaces/$argv[1]" -r main
end
