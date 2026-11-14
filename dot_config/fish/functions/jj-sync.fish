function jj-sync --description 'Local only: rebase my arm and every arm no workspace sits on onto main'
    # Single source of truth for `jj sync` (alias in ~/.config/jj/config.toml); `jj pull`
    # runs it after the fetch. Touches no remote. Moves my arm (chain(@)) and the arms no
    # workspace sits on (`orphan_arms()`); owned arms are their owners' to sync, and wip
    # is `jj deploy`'s. Named jj-sync so it does not shadow the system `sync` command.
    #
    # Rebasing drops a local commit whose divergent twin is already in the destination
    # (jj's default; see `jj rebase --keep-divergent`), which is how the copies of commits
    # the forge rebase-merged disappear after a fetch.
    set -l repo_args
    test -n "$JJ_WORKSPACE_ROOT"; and set repo_args -R "$JJ_WORKSPACE_ROOT"
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
    set -l failed 0

    if test -n "$(jj $repo_args log --no-graph -r 'mm_stale(@)' -T commit_id)"
        # Commits under a peer's working copy belong to its arm too (I stacked on it).
        # Working copies on or above wip (the legacy root) see every arm and are ignored.
        set -l shared (jj $repo_args log --no-graph -r 'chain(@) & ::(working_copies() ~ @ ~ present(wip)::)' -T $line)
        if set -q shared[1]
            echo "sync: my arm sits on another workspace's commits; its owner syncs them first:" >&2
            printf '  %s\n' $shared >&2
            set failed 1
        else
            # A forge merge that rewrites change ids (the stack merge does) leaves no
            # divergent twin to drop: my copy ends up empty after the rebase. Remember which
            # of my commits carry content now, to drop the ones that do not afterwards.
            set -l had_content (jj $repo_args log --no-graph -r 'chain(@) ~ empty()' -T 'change_id ++ "\n"')
            jj $repo_args rebase -s 'roots(chain(@))' -o main
            or return

            if set -q had_content[1]
                set -l emptied '('(string join ' | ' -- 'change_id('$had_content')')') & chain(@) & empty()'
                set -l dropped (jj $repo_args log --no-graph -r $emptied -T $line)
                if set -q dropped[1]
                    jj $repo_args abandon -r $emptied
                    or return
                    echo "sync: dropped commits whose changes are already on main:" >&2
                    printf '  %s\n' $dropped >&2
                end
            end
        end
    end

    set -l left (jj $repo_args log --no-graph -r 'superseded() & chain(@)' -T $line)
    if set -q left[1]
        echo "sync: local copies still divergent in my arm:" >&2
        printf '  %s\n' $left >&2
        set failed 1
    end

    # Arms no workspace sits on have no owner to catch them up: move them too.
    __jj_rebase_orphans $repo_args

    # Name the arms still behind main, so their owners know to sync.
    set -l behind (jj $repo_args log --no-graph -r 'stale_orphans() | (roots(arms() ~ chain(@) ~ orphan_arms()) & (::main ~ main)+)' -T $line)
    if set -q behind[1]
        echo "sync: arms still not on main (owned ones: their owners run jj sync):" >&2
        printf '  %s\n' $behind >&2
    end
    return $failed
end
