function pr-push --description 'Create or update bookmark at branch tip and push to origin'
    if test -z "$argv[1]"
        echo "usage: pr-push <name>" >&2
        return 1
    end
    jj bookmark set $argv[1] -r 'my_tip()' --allow-backwards
    or return
    jj git push --remote origin -b $argv[1] --allow-new
end
