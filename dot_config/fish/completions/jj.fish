# jj dynamic shell completion. Autoloaded by fish on first `jj <Tab>`.
#
# Uses jj's dynamic completion engine (env-var driven) rather than the static
# `jj util completion fish` script: the dynamic form auto-includes user-defined
# aliases (land, mine, stack, tip-add, …) and gives contextual revset completion
# for real subcommands. The static script omits aliases entirely.
# Docs: https://jj-vcs.github.io/jj/latest/install-and-setup/#command-line-completion
COMPLETE=fish jj | source
