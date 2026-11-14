function pull --wraps 'jj git fetch' --description 'jj git fetch, fix a conflicted main, then jj-sync'
    # Single source of truth; the jj `pull` alias delegates here (see
    # ~/.config/jj/config.toml), so `jj pull [<fetch args>]` and `pull [<fetch args>]` are
    # equivalent. Arguments go to `jj git fetch` unchanged; then `jj-sync` (local only).
    #
    # A GitHub rebase-merge keeps jj's change-id header, so after the fetch a merged commit
    # exists twice under one change id: the forge's copy on main@origin and my local copy.
    # The rebase in jj-sync drops the local copy.
    set -l repo_args
    test -n "$JJ_WORKSPACE_ROOT"; and set repo_args -R "$JJ_WORKSPACE_ROOT"
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'

    jj $repo_args git fetch $argv
    or return

    # main conflicts when it moved both locally (a local land) and on the forge. It is
    # resolved to main@origin only when every local-only commit on it is a superseded copy;
    # a genuinely unpushed commit would be dropped, so that case is refused.
    set -l main_targets (jj $repo_args log --no-graph -r 'bookmarks(exact:"main")' -T 'commit_id ++ "\n"')
    if test (count $main_targets) -gt 1
        set -l unpushed (jj $repo_args log --no-graph -r '(::bookmarks(exact:"main") ~ ::main@origin) ~ superseded()' -T $line)
        if test -n "$unpushed"
            echo "pull: main is conflicted and holds commits that are not on main@origin:" >&2
            printf '  %s\n' $unpushed >&2
            echo "pull: rebase them onto main@origin, then 'jj bookmark set main -r <tip>'" >&2
            return 1
        end
        jj $repo_args bookmark set main -r main@origin
        or return
    end

    # Everything after the fetch is local: my arm and the orphan arms onto main.
    jj-sync
end
