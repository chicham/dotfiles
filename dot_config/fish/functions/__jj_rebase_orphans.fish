function __jj_rebase_orphans --description 'Rebase every stale arm no workspace sits on onto main; keep an arm in place if mergiraf cannot clear its conflicts'
    # Shared by pull.fish and land.fish. $argv is the `-R <workspace>` pair (or nothing).
    # One arm per rebase, so a conflicting arm can be reverted alone: jj never refuses a
    # rebase on conflict, it records the conflict in the commits. A conflicting arm moves only
    # when `automerge --strict` clears every conflict; otherwise its rebase is reverted.
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
    set -l moved
    set -l kept
    for root in (jj $argv log --no-graph -r 'stale_orphans()' -T 'change_id ++ "\n"')
        set -l name (jj $argv log --no-graph -r $root -T $line)
        jj $argv rebase -s $root -o main >/dev/null 2>&1
        or begin
            set -a kept "$name (rebase failed)"
            continue
        end
        # Pin this rebase's own operation: a peer may write before the revert, and a bare
        # `jj op revert` would revert whatever operation is newest, possibly theirs.
        set -l op (jj $argv --ignore-working-copy op log -n 1 --no-graph -T 'id ++ " " ++ attributes')
        if test -n "$(jj $argv --ignore-working-copy log --no-graph -r "($root:: ~ present(wip)::) & conflicts()" -T commit_id)"
            # mergiraf first, all or nothing (--strict applies nothing unless every conflict
            # goes), so the rebase revert below still restores the arm exactly.
            if automerge $argv --strict -- "$root:: ~ present(wip)::"
                set -a moved "$name (conflicts resolved by mergiraf: review it)"
                continue
            end
            if string match -q -- "* rebase -s $root -o main*" "$op"
                jj $argv op revert (string split -f1 ' ' -- $op[1]) >/dev/null 2>&1
                set -a kept "$name (conflicts with main, rebase reverted)"
            else
                set -a kept "$name (conflicts with main; NOT reverted, another operation came first: check jj op log)"
            end
        else
            set -a moved $name
        end
    end
    if set -q moved[1]
        echo "rebased onto main, arms no workspace sits on:" >&2
        printf '  %s\n' $moved >&2
    end
    if set -q kept[1]
        echo "left on their old base (mergiraf could not clear them; resolve by hand, ask-first):" >&2
        printf '  %s\n' $kept >&2
    end
end
