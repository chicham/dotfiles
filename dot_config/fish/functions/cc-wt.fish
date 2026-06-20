function cc-wt --description 'claude --worktree as a jj workspace in a zellij floating pane'
    # Launches `claude --worktree <name> --tmux=classic` with the cc-zellij shims
    # prepended to PATH for THIS process only. The shims translate:
    #   git worktree add  -> jj workspace add ~/.claude/workspaces/<name>
    #   tmux new-session   -> zellij floating pane pinned to the invoking tab
    # See ~/.local/share/cc-zellij/bin/{git,tmux}.
    if test (count $argv) -lt 1
        echo "usage: cc-wt <name> [extra claude args...]" >&2
        return 1
    end

    set -l shim_dir "$HOME/.local/share/cc-zellij/bin"
    if not test -x "$shim_dir/tmux"
        echo "cc-wt: shims missing at $shim_dir (run `chezmoi apply`)" >&2
        return 1
    end

    set -l name $argv[1]
    set -l rest $argv[2..-1]
    env PATH="$shim_dir:$PATH" claude --worktree $name --tmux=classic $rest
end
