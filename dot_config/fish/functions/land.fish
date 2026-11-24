function land --wraps 'jj log -r' --description 'Land my arm: rebase it onto the destination bookmark (main by default) when stale, advance that bookmark to its tip'
    # Single source of truth for the land logic; the jj `land` alias delegates here
    # (see ~/.config/jj/config.toml) so `jj land [-b <bookmark>] [<rev>]` and `land ...` are
    # equivalent. The destination is main unless -b/--bookmark names `landing`; every other
    # name (main and wip included) is refused.
    # Lands `tip(<rev>)`, rev defaulting to @: everything in `<dest>..tip` goes onto the
    # destination. For main, the arms no workspace sits on then follow main, and the
    # `Closes: org:<UUID>` trailers close their org tasks. Another bookmark has none of that:
    # the megamerge rules, the PR requirement and org tasks are about main only.
    # Never rewrites an owned arm or wip; the next `jj deploy` drops the landed arm from wip.
    # On a conflict in the arm it runs `automerge` (mergiraf) and stops either way: a clean
    # merge is untested, so the rerun lands it.
    #
    # `jj util exec` does NOT chdir into the -R target; $JJ_WORKSPACE_ROOT is how it
    # tells us which workspace we were invoked for.
    argparse --name=land 'b/bookmark=' -- $argv
    or return

    set -l bm main
    set -q _flag_bookmark; and set bm $_flag_bookmark
    # Only `landing` (the landing() revset) may be advanced besides main: any other
    # bookmark would become an orphan arm and be rebased by every later land/sync/pull,
    # and advancing wip would move the deploy merge.
    switch $bm
        case main
            # the default; -b main is not a second spelling of it
            if set -q _flag_bookmark
                echo "land: -b main is refused; run jj land without -b to land on main" >&2
                return 1
            end
        case wip
            echo "land: -b wip is refused: only jj deploy moves wip" >&2
            return 1
        case landing
        case '*'
            echo "land: -b accepts only the bookmark landing (got $bm)" >&2
            return 1
    end
    if test (count $argv) -gt 1
        echo "land: at most one <rev>; got $argv" >&2
        return 1
    end
    set -l rev @
    test -n "$argv[1]"; and set rev $argv[1]
    set -l repo_args
    test -n "$JJ_WORKSPACE_ROOT"; and set repo_args -R "$JJ_WORKSPACE_ROOT"
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'

    # `dest` is the revset of the destination; for main it is the bare alias-compatible name.
    set -l dest main
    if test "$bm" != main
        set dest 'bookmarks(exact:"'$bm'")'
        if test (count (jj $repo_args log --no-graph -r $dest -T 'commit_id ++ "\n"')) -ne 1
            echo "land: bookmark $bm does not name exactly one commit (missing or conflicted)" >&2
            return 1
        end
    end
    # Pinned by change id: the rebase below gives the tip a new commit id.
    set -l tip (jj $repo_args log --no-graph -r "tip($rev)" -T 'change_id ++ "\n"')
    or return
    if test (count $tip) -ne 1
        echo "land: tip($rev) resolves to "(count $tip)" revisions; name a single arm commit" >&2
        return 1
    end
    # Everything the arm adds on top of the destination.
    set -l chain "($dest)..$tip"

    # A peer's working copy on one of these commits means they belong to its arm too
    # (I stacked on it): landing them is the owner's call, and rebasing them stales it.
    # Working copies on or above wip (the legacy root) see every arm and are ignored.
    set -l shared (jj $repo_args log --no-graph -r "$chain & ::(working_copies() ~ @ ~ present(wip)::)" -T $line)
    if set -q shared[1]
        echo "land: these commits are under another workspace; land that arm first:" >&2
        printf '    %s\n' $shared >&2
        return 1
    end

    # A landed commit cannot become a PR afterwards (it is on local main, so it is no arm tip),
    # and the forge refuses the push of main. Such a repo takes the PR path from the start.
    if test "$bm" = main; and test -z "$JJ_LAND_LOCAL"; and __jj_repo_requires_pr $repo_args
        echo "land: GitHub requires a pull request for main, so a local land cannot be pushed." >&2
        echo "land: open the PR instead: jj pr "(string sub -l 12 -- $tip)" --push   (override: JJ_LAND_LOCAL=1 jj land)" >&2
        return 1
    end

    # Stale: the arm's first commit does not sit on the destination (same rule as
    # mm_stale, which is about main).
    if test -n "$(jj $repo_args log --no-graph -r "roots($chain)- ~ ($dest)" -T commit_id)"
        jj $repo_args rebase -s "roots($chain)" -o $dest
        or return
    end
    if test -n "$(jj $repo_args log --no-graph -r "$chain & conflicts()" -T commit_id)"
        # A merge mergiraf made is untested, so land stops even when the arm is now clean:
        # the rerun lands it, after review and tests.
        if automerge $repo_args -- $chain
            echo "land: mergiraf resolved every conflict in the arm; review it and run the tests, then rerun jj land" >&2
            return 1
        end
        echo "land: resolve these conflicts in the arm, then land again:" >&2
        printf '    %s\n' (jj $repo_args log --no-graph -r "$chain & conflicts()" -T $line) >&2
        return 1
    end
    # Sweep (or seed the watermark of) main as it is now, so that the sweep after the
    # advance covers exactly what this land brings. Main only: another bookmark closes nothing.
    test "$bm" = main; and __jj_org_close $JJ_WORKSPACE_ROOT
    # Forward-only: refuses if the destination moved since the rebase; rerun `jj land`.
    jj $repo_args bookmark advance $bm --to $tip
    or return

    # Only a land on main closes org tasks and moves the other arms; another bookmark is
    # not where work counts as done.
    test "$bm" = main; or return 0

    # `Closes: org:<UUID>` trailers close their org tasks as the commits reach main, so no
    # agent has to.
    __jj_org_close $JJ_WORKSPACE_ROOT

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
