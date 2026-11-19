function automerge --description 'Resolve the 2-sided conflicts of an arm with mergiraf; print what it merged'
    # Usage: automerge [-R <workspace>] [--strict] [--] [<revset>]
    #   alias: jj automerge [<revset>]; land.fish, jj-sync.fish and __jj_rebase_orphans call it.
    #
    # Scope: the conflicted commits of <revset> (default chain(@)) that are mutable, off main,
    # not on or above wip, and under no other workspace's working copy. Nothing else is touched.
    #
    # Effect: for each commit in scope, oldest first, runs `jj resolve --tool mergiraf` on its
    # 2-sided conflicted files. Multi-sided conflicts (3+ sides) are left as they are: mergiraf
    # is a 3-way tool. Resolving a commit rebases its descendants, which often clears their
    # conflicts, so each commit is re-checked first.
    #
    # Transaction: the resolves run as a chain of unintegrated jj operations
    # (--no-integrate-operation, each on top of the previous with --at-op), and the last one is
    # integrated with `jj op integrate` only at the end: one visible result, undone by one
    # `jj op revert`, and never interleaved with a peer's write.
    #
    # --strict: all or nothing. When a conflict remains in scope, nothing is integrated, so the
    # repo is exactly as before the call.
    #
    # Output (stderr): per commit, the files mergiraf merged and the files left; then the
    # integrated operation id with the commands to inspect and undo it.
    #
    # Returns 0 when the scope is conflict-free afterwards (also when it already was),
    # 1 when conflicts remain, 2 on a usage or jj error.
    argparse 'R=' strict -- $argv
    or return 2
    set -l repo_args
    if set -q _flag_R
        set repo_args -R $_flag_R
    else if test -n "$JJ_WORKSPACE_ROOT"
        # `jj util exec` does not chdir into the -R target; this is how the alias knows it.
        set repo_args -R "$JJ_WORKSPACE_ROOT"
    end
    set -l rev 'chain(@)'
    test -n "$argv[1]"; and set rev $argv[1]
    # `jj resolve --list` prints paths relative to the cwd: run from the workspace root so
    # they read as repo paths and round-trip as `root-file:` patterns.
    set -l ws (jj $repo_args --ignore-working-copy workspace root)
    or return 2
    set -l old $PWD
    cd $ws
    __automerge_in $_flag_strict -- $rev $repo_args
    set -l ret $status
    cd $old
    return $ret
end

function __automerge_in --description 'Body of automerge, run from the workspace root'
    argparse strict -- $argv
    or return 2
    set -l rev $argv[1]
    set -l repo_args $argv[2..]
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
    set -l scope "(($rev) & mutable()) ~ ::main ~ present(wip):: ~ ::(working_copies() ~ @ ~ present(wip)::)"

    # The one snapshotting read: every later step works on unintegrated operations, which
    # would otherwise lose edits in @ that no jj command has recorded yet.
    set -l todo (jj $repo_args log --no-graph --reversed -r "($scope) & conflicts()" -T 'change_id ++ "\n"')
    or return 2
    set -q todo[1]; or return 0

    # $at is the head of the unintegrated chain: every read and write goes through it.
    set -l at --ignore-working-copy
    set -l op
    for id in $todo
        test -n "$(jj $repo_args $at log --no-graph -r "change_id($id) & conflicts()" -T commit_id)"; or continue
        set -l name (jj $repo_args $at log --no-graph -r "change_id($id)" -T $line)
        set -l two (jj $repo_args $at resolve --list -r "change_id($id)" 2>/dev/null | string match -rg '^(.+?)\s+2-sided conflict')
        if not set -q two[1]
            echo "automerge: $name: only multi-sided conflicts, left as they are" >&2
            continue
        end
        set -l out (jj $repo_args $at resolve -r "change_id($id)" --tool mergiraf --no-integrate-operation -- (printf 'root-file:"%s"\n' $two) 2>&1)
        set -l next (string match -rg 'was requested: ([0-9a-f]+)' -- $out)
        if not set -q next[1]
            echo "automerge: $name: jj resolve failed:" >&2
            printf '  %s\n' $out >&2
            continue
        end
        set op $next[1]
        set at --at-op $op
        set -l left (jj $repo_args $at resolve --list -r "change_id($id)" 2>/dev/null | string match -rg '^(.+?)\s+\d+-sided conflict')
        set -l merged
        for f in $two
            contains -- $f $left; or set -a merged $f
        end
        set -q merged[1]; and echo "automerge: $name: mergiraf merged: $merged" >&2
        set -q left[1]; and echo "automerge: $name: still conflicted: $left" >&2
    end

    set -l remaining (jj $repo_args $at log --no-graph -r "($scope) & conflicts()" -T $line)
    if test -n "$op"
        if set -q remaining[1]; and set -q _flag_strict
            echo "automerge: conflicts remain; nothing applied (all or nothing)" >&2
            return 1
        end
        jj $repo_args op integrate $op >/dev/null 2>&1
        or begin
            echo "automerge: jj op integrate $op failed" >&2
            return 2
        end
        # Integration does not touch the working copy; bring this workspace's files up to
        # date in case @ was one of the resolved commits.
        jj $repo_args workspace update-stale >/dev/null 2>&1
        set -l head (jj $repo_args --ignore-working-copy op log -n 1 --no-graph -T 'id.short()')
        echo "automerge: inspect: jj $repo_args op show -p --git $head; undo: jj $repo_args op revert $head" >&2
    end
    if set -q remaining[1]
        echo "automerge: still conflicted:" >&2
        printf '  %s\n' $remaining >&2
        return 1
    end
    return 0
end
