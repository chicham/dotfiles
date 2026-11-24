function __jj_org_close --description 'Close the org tasks named by `Closes: org:<UUID>` trailers on a revset'
    # Usage: __jj_org_close <revset> [<jj -R args>...]. Runs `orgtool close` for every
    # trailer on the commits of <revset> and records each commit in the task's :COMMITS:.
    # Idempotent: a task already DONE is left as is. Never fails its caller: the commit
    # has already landed, so a missing task, an open CLOCK or an absent orgtool only
    # prints a warning. Closing edits ~/.orgfiles, which is left uncommitted for review.
    set -l revset $argv[1]
    set -l repo_args $argv[2..-1]
    set -q ORGTOOL; or set -l ORGTOOL ~/.claude/skills/org/scripts/orgtool
    test -r "$ORGTOOL"; or return 0

    set -l root (jj $repo_args root 2>/dev/null)
    or return 0

    for commit in (jj $repo_args log --no-graph -r $revset -T 'commit_id ++ "\n"' 2>/dev/null)
        set -l desc (jj $repo_args log --no-graph -r $commit -T description)
        for id in (string replace --regex --filter --ignore-case '^\s*Closes:\s*org:([0-9a-f-]+)\s*$' '$1' -- $desc)
            bash $ORGTOOL close $id --commit $commit --repo $root 2>&1 | string match -rv '^already ' | string replace -r '^' 'org: ' >&2
            or true
        end
    end
    return 0
end
