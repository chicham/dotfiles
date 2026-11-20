function jj-push --description 'Push named bookmarks once prek passes on their tips'
    # Usage: jj-push [-R <workspace>] [--remote <name>] -b <bookmark> [-b <bookmark>...]
    #   alias: jj push -b NAME
    #
    # Gates, in order; the first that fails pushes nothing:
    #   - bookmarks are named (-b), exactly as the megamerge guard requires of `jj git push`;
    #   - `wip` is refused: it ships through `jj deploy`, which gates it against every arm;
    #   - `main` is refused while mm_unpushed_forks() is non-empty (arms forking from unpushed
    #     main commits would be left on old copies), the guard's rule for pushing main;
    #   - jj-prek passes on each bookmark tip not yet on <remote>: the tree the remote ends up
    #     with, as a git pre-push hook checks. Commits below a tip are not checked: once
    #     immutable, a commit that failed a hook could never be fixed, and its push would stay
    #     blocked for good.
    # Then runs `jj git push --remote <remote> -b <bookmark>...`.
    #
    # The guard checks the command an agent types; this function runs `jj git push` itself, so
    # it carries the guard's push rules rather than relying on them.
    #
    # Returns 0 when pushed, 1 when a gate or the push failed, 2 on a usage error.
    argparse 'R=' 'remote=' 'b/bookmark=+' -- $argv
    or return 2
    if not set -q _flag_bookmark[1]
        echo 'jj push: name the bookmarks: jj push -b NAME' >&2
        return 2
    end
    set -l repo_args
    if set -q _flag_R
        set repo_args -R $_flag_R
    else if test -n "$JJ_WORKSPACE_ROOT"
        # `jj util exec` does not chdir into the -R target; this is how the alias knows it.
        set repo_args -R "$JJ_WORKSPACE_ROOT"
    end
    set -l remote origin
    set -q _flag_remote; and set remote $_flag_remote

    if contains -- wip $_flag_bookmark
        echo 'jj push: wip ships through jj deploy, which gates it against every arm' >&2
        return 2
    end
    if contains -- main $_flag_bookmark
        set -l hits (jj $repo_args --ignore-working-copy --no-pager --color never log --no-graph \
            -r 'mm_unpushed_forks()' -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"' 2>&1)
        or begin
            printf '%s\n' 'jj push: could not evaluate mm_unpushed_forks():' $hits >&2
            return 1
        end
        if set -q hits[1]
            printf '%s\n' 'jj push: arms fork from unpushed main commits; pushing main leaves them on old copies:' \
                (string replace -r '^' '    ' -- $hits) '  fix: jj -R <ws> sync in each owning workspace' >&2
            return 1
        end
    end

    set -l heads (string join ' | ' 'bookmarks(exact:"'$_flag_bookmark'")')
    set -l publish "($heads) ~ ::remote_bookmarks(remote=exact:\"$remote\")"
    if not jj-prek $repo_args -- $publish
        echo "jj push: prek failed on a bookmark tip; nothing pushed" >&2
        return 1
    end
    # fish expands a list inside a word per element: one --bookmark=NAME for each bookmark.
    jj $repo_args git push --remote $remote --bookmark=$_flag_bookmark
    or return 1
    # jj can exit 0 without pushing a bookmark: a tip still outside the remote's history
    # means the push did not publish it.
    set -l left (jj $repo_args --ignore-working-copy --no-pager --color never log --no-graph \
        -r $publish -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"')
    or begin
        # jj's own error already went to stderr; stdout alone holds tips, so a warning is never one.
        echo 'jj push: could not verify the push' >&2
        return 1
    end
    if set -q left[1]
        printf '%s\n' 'jj push: pushed, but these bookmark tips are still not on the remote:' \
            (string replace -r '^' '    ' -- $left) >&2
        return 1
    end
end
