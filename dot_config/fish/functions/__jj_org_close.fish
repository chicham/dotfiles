function __jj_org_close --description 'Close the org tasks of the commits that reached main since the last sweep'
    # Usage: __jj_org_close [<repo path>]   (default: the current directory's repo)
    # Keeps one watermark per repo (a commit id of main last swept, shared by every
    # workspace of the repo) and runs `orgtool sweep --repo --rev <watermark>..main`, so a
    # `Closes: org:<UUID>` trailer closes its task once the commit is on main, however it got
    # there (`jj land`, or a forge merge fetched by `jj pull`). The trailer parsing is orgtool's.
    # When the watermark is absent or no longer an ancestor of main (first run, rewritten
    # history) it is reseeded to main without sweeping: closing an unbounded history by guess
    # would close tasks of work that landed long ago. Callers that move main call this first,
    # so a first run seeds before the move and the move itself is swept.
    # Never fails its caller: the commit has already landed, so a missing task, an open CLOCK
    # or an absent orgtool only prints a warning (the watermark then stays, and the next
    # call retries). Closing edits ~/.orgfiles, which is left uncommitted for review.
    # ORGTOOL overrides the orgtool path (tests point it at a checkout).
    set -l repo $argv[1]
    test -n "$repo"; or set repo (pwd)
    set -l ORGTOOL_PATH ~/.claude/skills/org/scripts/orgtool
    set -q ORGTOOL; and set ORGTOOL_PATH $ORGTOOL
    test -r "$ORGTOOL_PATH"; or return 0

    set -l root (jj -R $repo workspace root 2>/dev/null)
    or return 0
    # main must name one commit: a conflicted or absent main has nothing to sweep.
    set -l main (jj -R $root log --no-graph -r main -T 'commit_id ++ "\n"' 2>/dev/null)
    test (count $main) -eq 1; or return 0

    # Secondary workspaces point at the main repo through `.jj/repo`; one repo, one watermark.
    set -l store $root/.jj/repo
    test -f $store; and set store (path resolve $root/.jj/(cat $store))
    set -l state ~/.local/state
    set -q XDG_STATE_HOME; and set state $XDG_STATE_HOME
    set -l mark $state/jj-org-close/(printf %s (path resolve $store) | shasum | string sub -l 16)

    set -l wm
    test -r $mark; and set wm (string trim (cat $mark))
    if test -n "$wm"; and test (count (jj -R $root log --no-graph -r "$wm & ::main" -T 'commit_id ++ "\n"' 2>/dev/null)) -eq 1
        set -l out (bash $ORGTOOL_PATH sweep --repo $root --rev "$wm..main" 2>&1)
        set -l rc $status
        test -z "$out"; or printf '%s\n' $out | string replace -r '^' 'org: ' >&2
        # A repo error or a failed run keeps the watermark, so the next call retries.
        if test $rc -ne 0; or string match -q 'repo error*' -- $out
            return 0
        end
    end
    mkdir -p (dirname $mark)
    and printf '%s\n' $main[1] >$mark
    return 0
end
