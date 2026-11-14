function jj-megamerge-guard --description 'Claude Code PreToolUse hook: block jj commands that break the megamerge workflow'
    # Exit 2 + stderr blocks; silence allows. The arm rules are revset aliases (mm_*) in
    # ~/.config/jj/config.toml; jj itself refuses to rewrite main (immutable_heads()).
    __jj_mm_scan (jq -r '.tool_input.command // ""' | string collect); or return 2
end

function __jj_mm_scan --argument-names cmd
    string match -qr '\bjj\b' -- $cmd; or return 0
    printf '%s' $cmd | read -lzat tokens
    set -l seg
    set -l skip 0
    for tok in $tokens ';'
        if test $skip -eq 1
            set skip 0 # the target of a bare redirection: `2>&` then `1`, `>` then a file
        else if string match -qr -- '^\d*[<>]{1,2}&?$' $tok
            set skip 1
        else if string match -qr -- '^\d*[<>]' $tok
            # redirection with its target attached: `2>/dev/null`
        else if contains -- $tok '&&' '||' ';' '|' '&' \n
            __jj_mm_check $seg; or return 1
            set seg
        else
            set -a seg $tok
        end
    end
end

function __jj_mm_block
    printf '%s\n' 'megamerge guard blocked this jj command:' $argv >&2
    return 1
end

function __jj_mm_revs --argument-names repo revset
    jj -R $repo --ignore-working-copy --no-pager --color never log --no-graph -r $revset \
        -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"' 2>&1
end

function __jj_mm_check
    set -l seg $argv
    while string match -qr '^[A-Za-z_]\w*=' -- "$seg[1]"
        set -e seg[1] # VAR=value prefix
    end
    set -q seg[1]; or return 0
    switch (path basename -- $seg[1])
        case bash sh zsh fish
            test "$seg[2]" = -c; or return 0
            __jj_mm_scan "$seg[3]"
            return
        case jj
        case '*'
            return 0
    end

    # cwd drifts between tool calls, so the workspace is always explicit.
    if test "$seg[2]" != -R; or not string match -q -- '/*' "$seg[3]"
        __jj_mm_block "start with jj -R /abs/workspace <command>; the guard cannot expand variables"
        return 1
    end
    set -l repo $seg[3]
    set -l args $seg[4..-1]
    while contains -- "$args[1]" --no-pager --ignore-working-copy --color
        test "$args[1]" = --color; and set -e args[1]
        set -e args[1]
    end
    set -l sub $args[1]
    contains -- --help $args; or contains -- -h $args; or test "$sub" = help; and return 0
    if contains -- "$sub" '' log diff show status st evolog interdiff issues
        or contains -- "$args[1..2]" 'op log' 'op show' 'file show' 'file list' \
            'workspace list' 'workspace root' 'workspace add' 'bookmark list' 'config list' 'config get'
        return 0
    end

    # Mutations below.
    if string match -qr -- '^(-A|-B|--insert-after|--insert-before|--after|--before|-i|--interactive|--tool|--ignore-immutable|--allow-backwards)($|=)|^-[AB].' $args
        __jj_mm_block "no -A/-B (on main it rebases every arm), -i/--tool (interactive) or --ignore-immutable/--allow-backwards"
        return 1
    end
    set -l root (jj -R $repo --ignore-working-copy workspace root 2>&1)
    or begin
        __jj_mm_block "no jj workspace at $repo:" $root
        return 1
    end
    if test -d $root/.jj/repo
        __jj_mm_root_ok $repo $args
        switch $status
            case 0
                return 0
            case 2
                return 1 # the command is allowed at the root, a rule refused it (already explained)
        end
        __jj_mm_block "$root is the repo root, a read-only reference checkout. Work in your own workspace:
  jj -R $root workspace add $root/.workspaces/<name> -r main
Only these run at the root, because they touch no working copy: rebase/abandon of orphan arms,
bookmark create/set/delete (not main, wip), workspace forget of an idle workspace."
        return 1
    end

    switch $sub
        # `new` is never checked against the arm rules: it only adds an empty commit, undone by
        # `jj abandon @`, and `commit`, `jj deploy` and `jj land` check the arm before it ships.
        # Blocking it also blocked recovery (`jj new <conflicted>`) and work on a stale arm.
        case commit ci describe desc
            set -l revs
            set -l rest $args[2..-1]
            while set -q rest[1]
                switch $rest[1]
                    case -r --revision
                        set -a revs $rest[2]
                        set -e rest[1..2]
                    case -m --message
                        set -e rest[1..2]
                    case '-*'
                        set -e rest[1]
                    case '*'
                        # commit always acts on @: its positionals are filesets, not revisions
                        contains -- $sub commit ci; or set -a revs $rest[1]
                        set -e rest[1]
                end
            end
            set -q revs[1]; or set revs @
            set -l rules mm_on_wip mm_merges mm_stale mm_conflicts mm_stacked_on mm_forked
            # describe-then-new is the everyday loop, so describe carries the arm rules that `new`
            # does not. mm_dangling stays commit-only: another arm missing from wip is not this
            # arm's fault, and blocking the first describe on it would stall every workspace.
            if contains -- $sub describe desc
                set rules mm_not_mine $rules
            else
                set -a rules mm_dangling
            end
            __jj_mm_rules $repo $revs[1] $rules
        case git
            test "$args[2]" = push; or return 0
            if not contains -- -b $args; and not contains -- --bookmark $args
                __jj_mm_block "push named bookmarks only: jj -R <ws> git push -b NAME"
                return 1
            end
            if contains -- wip $args
                # Only wip reaches the deploy remote: a push that leaves an arm out never runs it.
                set -l hits (__jj_mm_revs $repo "$__jj_mm_wip_gate")
                or begin
                    __jj_mm_block "could not evaluate the wip gate:" $hits
                    return 1
                end
                if set -q hits[1]
                    __jj_mm_block "wip does not hold every arm (or holds a divergent copy); the deploy remote would run without:" \
                        (string replace -r '^' '    ' -- $hits) "  fix: jj -R $repo deploy (it rebuilds wip from every arm tip, then pushes)"
                    return 1
                end
            end
            contains -- main $args; or return 0
            set -l hits (__jj_mm_revs $repo 'mm_unpushed_forks()')
            or begin
                __jj_mm_block "could not evaluate mm_unpushed_forks():" $hits
                return 1
            end
            if set -q hits[1]
                __jj_mm_block "arms fork from unpushed main commits; pushing main leaves them on old copies:" \
                    (string replace -r '^' '    ' -- $hits) "  fix: jj -R <ws> sync in each owning workspace"
                return 1
            end
    end
end

function __jj_mm_root_ok --argument-names repo
    # Commands that may run at the repo root because they touch no working copy. Returns 0
    # (allowed), 1 (not such a command: the caller explains the root rule), 2 (such a
    # command that breaks its rule: already explained here).
    set -l args $argv[2..-1]
    switch "$args[1]"
        case rebase abandon
            set -l revs
            set -l dest 0
            set -l rest $args[2..-1]
            while set -q rest[1]
                switch $rest[1]
                    case -s --source -r --revision --revisions
                        set -q rest[2]; or break
                        set -a revs $rest[2]
                        set -e rest[1..2]
                    case -o --onto -d --destination
                        set dest 1
                        set -e rest[1..2]
                    case -b --branch
                        __jj_mm_block "at the root, rebase takes -s or -r: -b picks its roots implicitly, so they cannot be checked"
                        return 2
                    case '-*'
                        set -e rest[1]
                    case '*'
                        test "$args[1]" = abandon; and set -a revs $rest[1]
                        set -e rest[1]
                end
            end
            if not set -q revs[1]
                __jj_mm_block "name the revisions to $args[1] (-s/-r, or positional for abandon): the default is the root's working copy"
                return 2
            end
            if test "$args[1]" = rebase; and test $dest -eq 0
                __jj_mm_block "rebase needs a destination: -o main"
                return 2
            end
            set -l union (string join ' | ' -- '('$revs')')
            set -l found (__jj_mm_revs $repo "$union")
            or begin
                __jj_mm_block "could not evaluate the revisions; pass literal revsets:" $found
                return 2
            end
            if not set -q found[1]
                __jj_mm_block "no revision matches "(string join ' ' -- $revs)
                return 2
            end
            # The named revisions must be orphan arms. Rewriting one also rewrites its
            # descendants; wip and what sits above it carry no content of their own (the next
            # `jj deploy` rebuilds them), so only those descendants are exempt.
            set -l hits (__jj_mm_revs $repo "(($union) ~ orphan_arms()) | (($union):: ~ orphan_arms() ~ present(wip)::)")
            or begin
                __jj_mm_block "could not evaluate orphan_arms():" $hits
                return 2
            end
            if set -q hits[1]
                __jj_mm_block "at the root only orphan arms (no workspace sits on them) may be rewritten; these are not:" \
                    (string replace -r '^' '    ' -- $hits)
                return 2
            end
            return 0
        case bookmark
            contains -- "$args[2]" create set delete; or return 1
            set -l names
            set -l rest $args[3..-1]
            while set -q rest[1]
                switch $rest[1]
                    case -r --revision
                        set -e rest[1..2]
                    case '-*'
                        set -e rest[1]
                    case '*'
                        set -a names $rest[1]
                        set -e rest[1]
                end
            end
            if not set -q names[1]
                __jj_mm_block "name the bookmark"
                return 2
            end
            for n in $names
                if contains -- $n main wip; or string match -qr -- '[*:?\[]' $n
                    __jj_mm_block "at the root, bookmarks other than main and wip, by exact name: $n"
                    return 2
                end
            end
            return 0
        case workspace
            test "$args[2]" = forget; or return 1
            set -l names (string match -v -- '-*' $args[3..-1])
            if not set -q names[1]
                __jj_mm_block "name the workspace to forget (the default is the root itself)"
                return 2
            end
            for n in $names
                if test "$n" = default
                    __jj_mm_block "default is the repo root workspace"
                    return 2
                end
                # A workspace with uncommitted edits would lose them.
                set -l idle (__jj_mm_revs $repo "\"$n\"@ & empty()")
                if not set -q idle[1]
                    __jj_mm_block "workspace $n is unknown or has uncommitted edits; commit or discard them there first"
                    return 2
                end
            end
            return 0
    end
    return 1
end

# What a wip push must not leave out: an arm tip outside wip, a wip failing its deploy gate,
# undescribed work, a divergent copy.
set -g __jj_mm_wip_gate '(arm_tips() ~ ::present(wip)) | mm_wip_violations() | left_out() | (divergent() & mutable())'

function __jj_mm_rules --argument-names repo rev
    set -l failed
    for rule in $argv[3..-1]
        set -l expr "$rule($rev)"
        # Arm tips outside wip, other than the arm being extended: work the deploy remote would never run.
        test $rule = mm_dangling; and set expr "(arm_tips() ~ ::present(wip)) ~ ::($rev) ~ (($rev) ~ ::main)::"
        set -l hits (__jj_mm_revs $repo "$expr")
        or begin
            __jj_mm_block "could not evaluate $rule($rev); pass literal revisions:" $hits
            return 1
        end
        set -q hits[1]; and set -a failed "- $rule: "(__jj_mm_explain $rule $repo | string collect) \
            (string replace -r '^' '    ' -- $hits)
    end
    set -q failed[1]; or return 0
    __jj_mm_block "$rev breaks the megamerge rules:" $failed
end

function __jj_mm_explain --argument-names rule repo
    switch $rule
        case mm_on_wip
            echo "on or above wip. Only a scratch `jj new wip` may sit there, uncommitted; move its edit into the arms
  (jj -R $repo absorb --into 'chain(<my tip>) | orphan_arms()', or squash --into <tip>), then jj -R $repo new <my tip>.
  New arms start from main: jj -R $repo new main"
        case mm_merges
            echo "a merge inside the arm. An arm is one linear chain off main."
        case mm_stale
            echo "the arm does not start on the current main. fix: jj -R $repo sync"
        case mm_conflicts
            echo "conflicted commits in the arm. Resolve them in the arm first."
        case mm_stacked_on
            echo "other arms' tips sit above this commit. Continue on the arm tip (jj new <tip>) or start a new arm (jj new main)."
        case mm_forked
            echo "the arm shares commits with another arm that is not its base. A deliberate stack sits on the other arm's TIP (jj new <tip>)."
        case mm_not_mine
            echo "not a commit of my arm. Describe only your own commits: @ or chain(@)."
        case mm_dangling
            echo "other arms are not in wip, so the deploy remote never runs them. Merge every arm into wip first:
  jj -R $repo deploy --no-push   (an arm it refuses is fixed in its own workspace: jj sync there)"
    end
end
