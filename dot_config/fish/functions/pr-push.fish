function pr-push --description 'Create or update bookmark at branch tip and push to origin'
    if test -z "$argv[1]"
        echo "usage: pr-push <name>" >&2
        return 1
    end
    # main and wip move only through jj land and jj deploy; a PR branch must never take their name.
    if contains -- $argv[1] main wip
        echo "pr-push: refusing to push '$argv[1]': main moves by jj land, wip by jj deploy" >&2
        return 1
    end
    jj bookmark set $argv[1] -r 'tip(@)' --allow-backwards
    or return
    jj git push --remote origin -b $argv[1]
end
