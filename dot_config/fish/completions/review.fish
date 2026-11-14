# review [-p | -r] [TARGET] | review -w NAME
#
# TARGET is a jj revset (passed to nvim's `:Difft`) or a PR. The diff view
# needs a jj repo, so no revset is offered elsewhere.

function __review_workspaces
    jj workspace list --ignore-working-copy -T 'name ++ "\tworkspace\n"' 2>/dev/null
end

function __review_in_jj
    jj root >/dev/null 2>&1
end

function __review_pr_numbers
    gh pr list --json number,title --jq '.[] | "\(.number)\t\(.title)"' 2>/dev/null
end

# Names a revset can start from and recent commits, one per line as
# `candidate<TAB>description`.
function __review_targets
    __review_in_jj; or return
    printf '%s\t%s\n' '@' 'working copy' '@-' parent 'chain(@)' 'this arm' 'main..@' 'since main'
    jj bookmark list -T 'name ++ "\tbookmark\n"' 2>/dev/null
    # A revset alias is listed once per arity; the name is what gets typed.
    jj config list --include-defaults revset-aliases 2>/dev/null \
        | string replace -rf '^revset-aliases\.["\']?(\w+).*' '$1()\talias' | sort -u
    jj log --no-graph -r 'ancestors(@, 40)' \
        -T 'change_id.shortest(8) ++ "\t" ++ description.first_line() ++ "\n"' 2>/dev/null
end

# Complete the word after `A..` or `A::` with `A..` kept in front, since fish
# replaces the whole token.
function __review_range_targets
    set -l token (commandline -ct)
    set -l lead (string match -r '^.*(?:\.\.|::)' -- $token)
    # Keep only `candidate<TAB>text` rows: a description wrapped over two lines
    # would otherwise leave its tail behind as a bogus candidate.
    for line in (__review_targets | string match -r '^[^\t]+\t.*')
        if test -z "$lead"
            echo $line
        else if not string match -qr '^[^\t]*(\.\.|::)' -- $line
            # Behind a range operator only a single revision makes sense.
            printf '%s%s\n' "$lead" $line
        end
    end
end

# What the next positional word can be, from the words typed so far:
# `pr`, `rev`, `any`, or nothing once the one TARGET is given (or -w/-h used).
function __review_slot
    set -l words (commandline -opc)[2..]
    # `pr N` is the legacy spelling of `-p N`.
    test "$words[1]" = pr; and set words[1] --pr
    argparse -i h/help p/pr r/revision 'w/workspace=' -- $words 2>/dev/null; or return 1
    set -q _flag_help; and return 1
    set -q _flag_workspace; and return 1
    set -q argv[1]; and return 1
    if set -q _flag_pr
        echo pr
    else if set -q _flag_revision
        echo rev
    else
        echo any
    end
end

complete -c review -f
complete -c review -s h -l help -d 'Show help'
complete -c review -s p -l pr -n 'not __fish_seen_argument -s r -l revision -s w -l workspace' -d 'Read TARGET as a PR; alone, list open PRs'
complete -c review -s r -l revision -n 'not __fish_seen_argument -s p -l pr -s w -l workspace' -d 'Read TARGET as a revset'
complete -c review -s w -l workspace -x -n 'not __fish_seen_argument -s p -l pr -s r -l revision' -a '(__review_workspaces)' -d "Review a workspace's arm"
complete -c review -n 'contains -- (__review_slot) any rev' -a '(__review_range_targets)'
complete -c review -n 'contains -- (__review_slot) any pr' -a '(__review_pr_numbers)'
