# fish-claude-mode: Bootstrap configuration
# Loaded automatically by fish from conf.d/

# Pager: fish list variable (correct expansion for args with spaces)
# Override: set -g claude_pager_cmd your-pager --flag1 --flag2
set -q claude_pager_cmd; or set -g claude_pager_cmd bat -l md --plain

# Env var fallback for simple pager commands (no quoted args)
# Override: set -gx CLAUDE_PAGER "your-pager --simple-flags"
set -q CLAUDE_PAGER; or set -gx CLAUDE_PAGER "bat -l md --plain"

# Output format: text (default) | json | quiet
# This is passed as a global option: acpx --format $CLAUDE_FORMAT claude ...
# Override: set -gx CLAUDE_FORMAT json
set -q CLAUDE_FORMAT; or set -gx CLAUDE_FORMAT text

# Toggle keybinding (default: Ctrl+G)
# Override: set -g CLAUDE_BIND \co  # for Ctrl+O
set -q CLAUDE_BIND; or set -g CLAUDE_BIND \cg

# Register keybinding in both vi insert and normal modes
if status is-interactive
    bind -M insert  $CLAUDE_BIND __claude_mode
    bind -M default $CLAUDE_BIND __claude_mode
end
