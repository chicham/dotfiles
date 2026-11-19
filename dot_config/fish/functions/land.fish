function land --wraps 'jj log -r' --description 'Land my arm: rebase it onto main when stale, advance main to its tip'
    # Single source of truth for the land logic; the jj `land` alias delegates here
    # (see ~/.config/jj/config.toml) so `jj land [<rev>]` and `land [<rev>]` are equivalent.
    # Lands `tip(<rev>)`, rev defaulting to @: everything in chain(tip) goes onto main, then
    # the arms no workspace sits on follow main. Never rewrites an owned arm or wip; the next
    # `jj deploy` drops the landed arm from wip. On a conflict in the arm it runs `automerge`
    # (mergiraf) and stops either way: a clean merge is untested, so the rerun lands it.
    #
    # `jj util exec` does NOT chdir into the -R target; $JJ_WORKSPACE_ROOT is how it
    # tells us which workspace we were invoked for.
    set -l rev @
    test -n "$argv[1]"; and set rev $argv[1]
    set -l repo_args
    test -n "$JJ_WORKSPACE_ROOT"; and set repo_args -R "$JJ_WORKSPACE_ROOT"
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'

    # Pinned by change id: the rebase below gives the tip a new commit id.
    set -l tip (jj $repo_args log --no-graph -r "tip($rev)" -T 'change_id ++ "\n"')
    or return
    if test (count $tip) -ne 1
        echo "land: tip($rev) resolves to "(count $tip)" revisions; name a single arm commit" >&2
        return 1
    end

    # A peer's working copy on one of these commits means they belong to its arm too
    # (I stacked on it): landing them is the owner's call, and rebasing them stales it.
    # Working copies on or above wip (the legacy root) see every arm and are ignored.
    set -l shared (jj $repo_args log --no-graph -r "chain($tip) & ::(working_copies() ~ @ ~ present(wip)::)" -T $line)
    if set -q shared[1]
        echo "land: these commits are under another workspace; land that arm first:" >&2
        printf '    %s\n' $shared >&2
        return 1
    end

    # A landed commit cannot become a PR afterwards (it is on local main, so it is no arm tip),
    # and the forge refuses the push of main. Such a repo takes the PR path from the start.
    if test -z "$JJ_LAND_LOCAL"; and __jj_repo_requires_pr $repo_args
        echo "land: GitHub requires a pull request for main, so a local land cannot be pushed." >&2
        echo "land: open the PR instead: jj pr "(string sub -l 12 -- $tip)" --push   (override: JJ_LAND_LOCAL=1 jj land)" >&2
        return 1
    end

    if test -n "$(jj $repo_args log --no-graph -r "mm_stale($tip)" -T commit_id)"
        jj $repo_args rebase -s "roots(chain($tip))" -o main
        or return
    end
    if test -n "$(jj $repo_args log --no-graph -r "mm_conflicts($tip)" -T commit_id)"
        # A merge mergiraf made is untested, so land stops even when the arm is now clean:
        # the rerun lands it, after review and tests.
        if automerge $repo_args -- "chain($tip)"
            echo "land: mergiraf resolved every conflict in the arm; review it and run the tests, then rerun jj land" >&2
            return 1
        end
        echo "land: resolve these conflicts in the arm, then land again:" >&2
        printf '    %s\n' (jj $repo_args log --no-graph -r "mm_conflicts($tip)" -T $line) >&2
        return 1
    end
    # Forward-only: refuses if main moved since the rebase; rerun `jj land`.
    jj $repo_args bookmark advance main --to $tip
    or return

    # The old main is now an unpushed commit below the new one, and every arm still on it
    # forks from there (`mm_unpushed_forks()`), which blocks pushing main. Move the arms no
    # workspace sits on; name the owned ones.
    __jj_rebase_orphans $repo_args
    set -l forks (jj $repo_args log --no-graph -r 'mm_unpushed_forks()' -T $line)
    if set -q forks[1]
        echo "land: arms still fork from unpushed main commits; their owners run jj sync before main is pushed:" >&2
        printf '    %s\n' (jj $repo_args log --no-graph -r 'roots(arms()) & mm_unpushed_forks()+' -T $line) >&2
    end
end
