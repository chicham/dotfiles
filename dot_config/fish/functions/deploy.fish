function deploy --description 'Rewire wip onto every arm tip, gate it, push it to the deploy remote'
    # Single source of truth; the jj `deploy` alias delegates here (see
    # ~/.config/jj/config.toml). The only command that rewires wip.
    # Usage: deploy [--no-push] [--remote NAME]   (default remote: $JJ_DEPLOY_REMOTE, else "deploy")
    # Every gate is a revset alias: mm_arm_violations(<tip>) per arm before the rewire,
    # mm_wip_violations() after it.
    argparse no-push 'remote=' -- $argv; or return
    set -l remote deploy
    set -q JJ_DEPLOY_REMOTE; and set remote $JJ_DEPLOY_REMOTE
    set -q _flag_remote; and set remote $_flag_remote

    set -l repo_args
    test -n "$JJ_WORKSPACE_ROOT"; and set repo_args -R "$JJ_WORKSPACE_ROOT"
    set -l line 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'

    set -l wip (jj $repo_args log --no-graph -r 'bookmarks(exact:"wip")' -T 'commit_id ++ "\n"'); or return
    if test (count $wip) -eq 0
        echo "deploy: no wip bookmark. Create it once:" >&2
        echo "  jj new --no-edit -m 'chore: wip megamerge' 'arm_tips() | (main ~ ::arm_tips())'" >&2
        echo "  jj bookmark create wip -r <that commit>" >&2
        return 1
    else if test (count $wip) -gt 1
        echo "deploy: the wip bookmark is conflicted; pick one: jj bookmark set wip -r <commit>" >&2
        return 1
    end

    # Nothing with content sits above wip: arms branch from main, never from wip. wip itself
    # is checked after the rebuild, because a stale wip may be conflicted, and on a
    # conflicted merge (or a commit on top of one) the `empty()` revset can disagree with
    # the commit's real emptiness; the `empty` template keyword does not, so it is used here.
    set -l with_content 'if(!empty, ' $line ')'
    set -l bad (jj $repo_args log --no-graph -r 'wip:: ~ wip' -T (string join '' $with_content))
    if set -q bad[1]
        echo "deploy: commits above wip carry content. Move them into an arm off main:" >&2
        printf '    %s\n' $bad >&2
        return 1
    end

    # Two visible copies of one change are both arm tips, so the rebuild would merge both into
    # wip and the deploy remote would run the change twice. Same rule as the guard's wip push gate.
    set -l copies (jj $repo_args log --no-graph -r 'divergent() & mutable()' \
        -T 'change_id.short() ++ " " ++ commit_id.short() ++ " " ++ description.first_line() ++ "\n"')
    if set -q copies[1]
        echo "deploy: divergent copies; keep one per change (jj abandon <commit id> of the others), then deploy again:" >&2
        printf '    %s\n' $copies >&2
        return 1
    end

    set -l failed 0
    for tip in (jj $repo_args log --no-graph -r 'arm_tips()' -T 'commit_id ++ "\n"')
        set -l hits (jj $repo_args log --no-graph -r "mm_arm_violations($tip)" -T $line)
        if set -q hits[1]
            set failed 1
            echo "deploy: arm "(jj $repo_args log --no-graph -r $tip -T $line)" breaks the megamerge rules at:" >&2
            printf '    %s\n' $hits >&2
        end
    end
    if test $failed -ne 0
        echo "deploy: see which rule each commit breaks: jj -R <ws> log -r 'mm_arm_violations(@)' (the guard names the rule on commit)" >&2
        return 1
    end

    # `main ~ ::arm_tips()` is main only when there is no arm, so wip never loses its parent.
    jj $repo_args rebase -s wip -o 'arm_tips() | (main ~ ::arm_tips())'; or return

    set -l hits (jj $repo_args log --no-graph -r 'mm_wip_violations()' -T $line)
    if set -q hits[1]
        echo "deploy: wip fails its gate (parents must be exactly arm_tips(), no other merge, no conflict):" >&2
        printf '    %s\n' $hits >&2
        if test -n "$(jj $repo_args log --no-graph -r 'wip & conflicts()' -T commit_id)"
            echo "deploy: two arms change the same lines. Conflicted files:" >&2
            jj $repo_args resolve --list -r wip >&2
            echo "deploy: stack one arm on the other (jj new <tip>), or split the shared change into its own arm." >&2
        end
        return 1
    end
    set -l own (jj $repo_args log --no-graph -r wip -T (string join '' $with_content))
    if set -q own[1]
        echo "deploy: wip carries content of its own; move it into an arm off main:" >&2
        printf '    %s\n' $own >&2
        return 1
    end

    echo "deploy: wip = main + "(count (jj $repo_args log --no-graph -r 'arm_tips()' -T 'commit_id ++ "\n"'))" arm(s), conflict-free" >&2
    # Undescribed work cannot be pushed, so it is not deployed: say so, with its workspace.
    set -l left (jj $repo_args log --no-graph -r 'left_out()' -T 'change_id.short() ++ " " ++ coalesce(working_copies, "(no workspace)") ++ " on " ++ coalesce(parents.map(|p| p.description().first_line()).join(", "), "-") ++ "\n"')
    if set -q left[1]
        echo "deploy: NOT deployed, undescribed work (describe it, then deploy again):" >&2
        printf '    %s\n' $left >&2
    end
    set -q _flag_no_push; and return 0
    jj $repo_args git push --bookmark wip --remote $remote
end
