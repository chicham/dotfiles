function pr --description 'Check a stack against the PR gates, preview its PRs, and with --push submit them as drafts'
    # Single source of truth for `jj pr` (see the alias in ~/.config/jj/config.toml).
    # Usage: jj pr <arm-tip> [--push [--open]]
    #   no flag        read-only: gates + `jj-stack submit --dry-run`
    #   --push         submit; new PRs are drafts
    #   --push --open  submit and mark every PR in the stack ready for review
    # One PR is one commit, so every level of the stack is checked. <arm-tip> is
    # always named: jj-stack's own default resolves to the empty scratch commit.
    argparse push open -- $argv
    or return 2
    if test (count $argv) -ne 1; or begin; set -q _flag_open; and not set -q _flag_push; end
        echo "usage: jj pr <arm-tip> [--push [--open]]" >&2
        return 2
    end

    # `jj util exec` does not chdir into the -R target; $JJ_WORKSPACE_ROOT does.
    set -l repo_args
    test -n "$JJ_WORKSPACE_ROOT"; and set repo_args -R "$JJ_WORKSPACE_ROOT"

    set -l tip (jj $repo_args log --no-graph -r "arm_tips() & ($argv[1])" -T 'change_id.short(12) ++ "\n"')
    or return
    if test (count $tip) -ne 1
        if test -n "$(jj $repo_args log --no-graph -r "($argv[1]) & unpushed()" -T commit_id)"
            echo "pr: $argv[1] is on local main (landed with jj land) but not on main@origin, so it is no arm." >&2
            echo "pr: to open a PR for it, a person must move main back (agents are blocked from this); this also un-lands everything in 'jj log -r unpushed()':" >&2
            echo "pr:   jj -R <root> bookmark set main -r main@origin --allow-backwards" >&2
            return 2
        end
        echo "pr: $argv[1] must be one arm tip (see: jj log -r 'arm_tips()')" >&2
        return 2
    end

    set -l stack "chain($tip)"
    # Same trailer vocabulary as no_issue() (plus `Refs`, which a PR may carry but never closes).
    set -l shared_footer (__trailer_re --shared)
    set -l failed 0
    # name -> revset that must be empty
    set -l gates \
        "a level with no content:$stack & empty()" \
        "a level with a conflict:$stack & conflicts()" \
        "a level with no issue footer:$stack & no_issue()" \
        "a session link in a message:$stack & description(glob:'*claude.ai/code/session*')" \
        "an issue footer sharing its paragraph (jj-stack joins the lines of a paragraph into one line of the PR body; put a blank line around each footer):$stack & description(regex:'$shared_footer')" \
        "unpushed commits on local main:unpushed()"
    for gate in $gates
        set -l parts (string split -m 1 ':' -- $gate)
        set -l hits (jj $repo_args log --no-graph -r $parts[2] -T 'change_id.shortest(8) ++ " "')
        if test -n "$hits"
            echo "pr: gate failed, $parts[1]: $hits" >&2
            set failed 1
        end
    end

    set -l depth (jj $repo_args log --no-graph -r $stack -T '"x\n"' | count)
    echo "pr: $depth PR(s) in this stack"
    test $depth -ge 4; and echo "pr: warning, a stack this deep is slow to review and every edit to a lower level force-pushes the levels above it" >&2
    test $failed -ne 0; and return 1

    set -l root (jj $repo_args workspace root)
    set -l mode --draft
    set -q _flag_open; and set mode --open
    set -q _flag_push; or set mode --dry-run
    set -l out (jj-stack submit $mode --repository $root $tip 2>&1)
    set -l status_code $status
    printf '%s\n' $out
    if string match -q -r 'updated outside this repo|GitHub updated PR' -- "$out"
        # A stack merge makes GitHub rebase the PR branches above the merged PR, so jj-stack
        # sees them as foreign. `jj-stack sync` is banned (it abandons local arms); once the
        # files on GitHub match the local commits, relink and resubmit instead.
        echo "pr: GitHub rebased these PR branches. Compare each PR's files with the local commit, then" >&2
        echo "pr:   jj-stack relink --replace-remote <pr> <change-id>   (per PR, ask first), and rerun" >&2
        echo "pr: never jj-stack sync" >&2
    end
    return $status_code
end
