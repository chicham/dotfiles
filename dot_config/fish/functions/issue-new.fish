function issue-new --wraps 'jj log -r' --description 'Open a GitHub issue from a commit that has none, and add a Closes: #N footer to it'
    # `jj issue-new <rev> [--parent <N>]` ≡ `issue-new <rev> [--parent <N>]`.
    # The commit's subject becomes the issue title and its body the issue description;
    # `--parent N` files it as a sub-issue of N. A commit that already carries an issue
    # footer (Closes/Fixes/Resolves[:] #N or org:<uuid>, Issue: #N or org:<uuid>) is left alone. An `Issue: none` line (the
    # body stood in for an issue) is left out of the issue and replaced by `Closes: #N` in the
    # commit, so the other trailers of its paragraph (Fixes: …) stay one trailer block.
    argparse --min-args 1 --max-args 1 'parent=' -- $argv
    or begin
        echo "usage: issue-new <rev> [--parent <issue-number>]" >&2
        return 2
    end
    set -l rev $argv[1]
    set -l repo_args
    if test -n "$JJ_WORKSPACE_ROOT"
        set repo_args -R "$JJ_WORKSPACE_ROOT"
        # gh resolves the GitHub repository from the git remote of its cwd.
        cd "$JJ_WORKSPACE_ROOT"; or return
    end

    set -l ids (jj $repo_args log --no-graph -r "$rev" -T 'commit_id ++ "\n"')
    or return
    if test (count $ids) -ne 1
        echo "issue-new: $rev resolves to "(count $ids)" commits; name one" >&2
        return 1
    end
    set -l description (jj $repo_args log --no-graph -r $ids[1] -T 'description' | string collect)
    if test -z "$description"
        echo "issue-new: $rev has no description; describe it first" >&2
        return 1
    end
    set -l existing (string match -r -- '(?m)^'(__trailer_re)'$' $description)
    if test -n "$existing"
        echo "issue-new: $rev already tracks an issue: $existing[1]"
        return 0
    end
    set -l issue_text (string split \n -- $description | string match -v -r -- '^Issue: none$' | string join \n | string collect)

    set -l lines (string split \n -- (string trim -- $issue_text))
    set -l title $lines[1]
    set -l body (string trim -- (string join \n -- $lines[2..-1] | string collect) | string collect)
    test -n "$body"; or set body "Tracked by the commit \"$title\"."

    set -l gh_args --title "$title" --body "$body"
    set -q _flag_parent; and set -a gh_args --parent $_flag_parent
    set -l url (gh issue create $gh_args)
    or return
    set -l number (string match -r -- '\d+$' $url)
    if test -z "$number"
        echo "issue-new: could not read the issue number from '$url'" >&2
        return 1
    end

    set -l message (string trim -- $description | string collect)
    if string match -q -r -- '(?m)^Issue: none$' $message
        set message (string replace -r -- '(?m)^Issue: none$' "Closes: #$number" $message | string collect)
    else
        set message "$message

Closes: #$number"
    end
    jj $repo_args describe -r $ids[1] -m "$message"
    or return
    echo "issue-new: $url → Closes: #$number added to $rev"
end
