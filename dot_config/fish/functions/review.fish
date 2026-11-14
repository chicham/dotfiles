function __review_nvim --description "Run nvim for review: no intro screen, error shown after it quits"
    set -l err (mktemp)
    env REVIEW=1 REVIEW_ERR=$err $argv[1..-2] nvim --cmd 'set shortmess+=I' $argv[-1]
    set -l code $status
    if test -s $err
        string trim -- (cat $err) >&2
    end
    rm -f $err
    return $code
end

function __review_help
    printf '%s\n' \
        'Review a diff in nvim (difftastic), with comments in .review.org.' \
        '' \
        'Usage: review [-p | -r] [TARGET]' \
        '       review -w NAME' \
        '' \
        TARGET \
        '  (none)        this workspace\'s arm: chain(@)' \
        '  REVSET        any jj revset: one commit, a range A..B, an alias' \
        '  N | PR-URL    a GitHub PR (digits or a pull URL)' \
        '' \
        Options \
        '  -p, --pr          read TARGET as a PR (number, URL or branch); no TARGET lists open PRs' \
        '  -r, --revision    read TARGET as a revset, even when it is all digits' \
        '  -w, --workspace NAME  review that workspace\'s arm, from that workspace' \
        '  -h, --help        show this help' \
        '' \
        Examples \
        '  review                  my arm' \
        '  review @-               the parent commit' \
        '  review main..feat       a range' \
        '  review 247              PR #247' \
        '  review -p fix-login     the PR whose head branch is fix-login' \
        '  review -w other         the arm of workspace "other"'
end

function __review_usage_error
    echo "review: $argv" >&2
    echo "Try 'review --help'." >&2
    return 2
end

# Runs jj with stdout passed through. stderr is shown only on failure, so a
# warning never ends up in a caller's captured output.
function __review_jj
    set -l err (mktemp)
    command jj $argv 2>$err
    set -l code $status
    if test $code -ne 0
        string trim -- (cat $err) >&2
    end
    rm -f $err
    return $code
end

# Snapshots the working copy. Fails with jj's message (and its update-stale
# hint) when the working copy is stale, before anything else runs against it.
function __review_wc_ok
    __review_jj log --no-graph -r @ -T '' >/dev/null
end

# Runs before nvim so a bad target fails here with jj's own message (unknown
# revision, revset with gaps) instead of inside the editor, and so an empty
# diff does not open a blank view.
function __review_check --argument-names revset
    set -l files (__review_jj diff --name-only -r $revset)
    or return 1
    if test (count $files) -eq 0
        echo "review: nothing to review in $revset" >&2
        return 1
    end
end

function __review_has --argument-names revset
    jj log --ignore-working-copy --no-graph -r "present($revset)" -T commit_id 2>/dev/null | string length -q
end

# Prints `number<TAB>head<TAB>revset` for a PR given as gh accepts it (number,
# URL or branch). Fetches so the head exists locally; a fork PR's head is on
# none of this repo's remotes, so it is reported missing rather than diffed.
function __review_pr_target --argument-names pr
    set -l meta (gh pr view $pr --json number,headRefOid,baseRefName,isCrossRepository \
        -q '[.number, .headRefOid, .baseRefName, .isCrossRepository] | @tsv' | string split \t)
    if test (count $meta) -ne 4
        echo "review: gh could not read PR '$pr'" >&2
        return 1
    end
    set -l number $meta[1]
    set -l head $meta[2]
    set -l base $meta[3]
    set -l fork $meta[4]

    set -l fetch (jj git fetch 2>&1)
    or printf 'review: jj git fetch failed, using local state:\n%s\n' $fetch >&2

    if not __review_has $head
        echo "review: PR head $head is not in this repo" >&2
        if test "$fork" = true
            echo "review: the PR comes from a fork; add it as a remote, then: jj git fetch --remote <fork>" >&2
        end
        return 1
    end

    # One remote's base, not the union over remotes: `X..head` drops the
    # ancestors of every member of X, so a remote whose base is ahead (or a
    # fork PR made from the fork's own base) would silently shrink the diff.
    set -l with
    for r in (__review_jj git remote list | string replace -r '\s.*$' '')
        __review_has "$base@$r"; and set -a with $r
    end
    set -l remote
    if contains origin $with
        set remote origin
    else if test (count $with) -eq 1
        set remote $with[1]
    else if test (count $with) -eq 0
        echo "review: base branch '$base' is on no remote here" >&2
        return 1
    else
        echo "review: base branch '$base' is on several remotes ($with); pick one: review $base@<remote>..$head" >&2
        return 1
    end

    printf '%s\t%s\t%s\n' $number $head "$base@$remote..$head"
end

function review --description "Review a jj revset, a GitHub PR or a workspace's arm in nvim"
    # `pr N` predates the flags; kept so existing muscle memory and docs work.
    if test "$argv[1]" = pr
        set argv[1] --pr
    end

    set -l err (mktemp)
    argparse --name=review --exclusive p,r,w h/help p/pr r/revision 'w/workspace=' -- $argv 2>$err
    set -l code $status
    set -l msg (string replace -r '^review: ' '' -- (cat $err))
    rm -f $err
    if test $code -ne 0
        __review_usage_error $msg[1]
        return 2
    end

    if set -q _flag_help
        __review_help
        return 0
    end
    if set -q argv[2]
        __review_usage_error "one TARGET at most, got: $argv"
        return 2
    end
    if set -q _flag_workspace; and set -q argv[1]
        __review_usage_error "-w takes no TARGET"
        return 2
    end

    set -l target $argv[1]
    # Bare digits or a pull URL mean a PR unless -r says otherwise.
    set -l is_pr 0
    if set -q _flag_pr
        set is_pr 1
    else if not set -q _flag_revision
        string match -qr '^\d+$|^https?://\S+/pull/\d+' -- "$target"; and set is_pr 2
    end

    if test $is_pr -ne 0; and test -z "$target"
        __review_nvim "+Octo pr list"
        return
    end

    # The diff view is built on jj; a git-only repo has nothing it can open.
    if not jj root >/dev/null 2>&1
        echo "review: not inside a jj repo" >&2
        return 1
    end
    __review_wc_ok; or return 1

    # Digits are also a valid commit-id prefix: refuse to guess.
    if test $is_pr -eq 2; and string match -qr '^\d+$' -- $target; and __review_has $target
        __review_usage_error "'$target' is both a PR number and a commit; use -p or -r"
        return 2
    end

    set -l revset 'chain(@)'
    set -l envs
    set -l dir
    if set -q _flag_workspace
        # nvim resolves diff paths, `gf` and .review.org from its cwd, so it
        # starts in the reviewed workspace, where @ is that workspace's copy.
        set dir (__review_jj workspace root --ignore-working-copy --name $_flag_workspace)
        or return 1
    else if test $is_pr -ne 0
        set -l pr (__review_pr_target $target | string split \t)
        or return 1
        set revset $pr[3]
        # Comment lines are the PR head's, but signs, anchors and the
        # resolution check read the working copy; say so when they differ.
        set -l note
        set -l wc (jj log --ignore-working-copy --no-graph -r @ -T commit_id 2>/dev/null)
        if test "$wc" != "$pr[2]"
            set note "Working copy is not the PR head: .review.org anchors and signs follow the working copy; :ReviewPublish still sends the PR's own lines."
        end
        # Publishing (:ReviewPublish) defaults to this PR.
        set envs REVIEW_PR=$pr[1] "REVIEW_NOTE=$note"
    else if test -n "$target"
        set revset $target
    end

    if test -n "$dir"
        pushd $dir; or return 1
    end
    __review_check $revset
    and __review_nvim $envs "+Difft $revset"
    set -l code $status
    if test -n "$dir"
        popd
    end
    return $code
end
