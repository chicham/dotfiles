# jj dynamic shell completion. Autoloaded by fish on first `jj <Tab>`.
#
# Uses jj's dynamic completion engine (env-var driven) rather than the static
# `jj util completion fish` script: the dynamic form auto-includes user-defined
# aliases (start, land, pull, park, …) and gives contextual revset completion
# for real subcommands. The static script omits aliases entirely.
# Docs: https://jj-vcs.github.io/jj/latest/install-and-setup/#command-line-completion
#
# The registration below is what `COMPLETE=fish jj` emits, routed through
# __jj_complete so that `jj land` completes revisions: the alias expands to
# `util exec -- fish -c land`, which the engine would complete as file paths.
# `land` takes the same revision argument as `jj log -r`, so it borrows that
# completion — the same one the `land` function gets through `--wraps`. `jj pull`
# forwards to `jj git fetch` the same way.

function __jj_complete
    set -l tokens (commandline --current-process --tokenize --cut-at-cursor)
    set -l current (commandline --current-token)
    # The subcommand is the first token after `jj` that is neither a flag nor the
    # value of a global option that takes one.
    set -l subcommand
    set -l skip_next 0
    for token in $tokens[2..-1]
        if test $skip_next = 1
            set skip_next 0
            continue
        end
        switch $token
            case -R --repository --at-op --at-operation --config --config-file --color
                set skip_next 1
            case '-*'
            case '*'
                set subcommand $token
                break
        end
    end
    if contains -- "$subcommand" land issue-new
        complete -C "jj log -r $current"
    else if test "$subcommand" = pull
        # `pull` passes its arguments to `jj git fetch`, so it completes as that command line.
        set -l rest $tokens[(math (contains --index -- pull $tokens) + 1)..-1]
        complete -C "jj git fetch $rest $current"
    else
        COMPLETE=fish jj -- $tokens $current
    end
end

complete --keep-order --exclusive --command jj --arguments "(__jj_complete)"
