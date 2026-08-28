# Send a prompt to Claude Code via ACPX and pipe output through the pager.
#
# Session lifecycle:
#   `sessions ensure` is called before every prompt to guarantee a session
#   exists. It's idempotent — returns the existing session or creates one.
#
# ACPX invocation:
#   --format is a GLOBAL option (before agent name):
#     acpx --format text claude prompt "text"
#
# Pager selection:
#   1. $claude_pager_cmd (fish list — handles complex args correctly)
#   2. $CLAUDE_PAGER (string fallback — simple pager commands only)
#   3. Raw output if neither set or stdout is not a TTY
#
# stderr passes to terminal directly (not through the pager).

function __claude_send -d "Send prompt to Claude via ACPX"
    if not type -q acpx
        echo "acpx not found — install with: npm i -g acpx" >&2
        return 1
    end

    # Ensure a session exists (idempotent: reuses existing or creates new)
    acpx claude sessions ensure >/dev/null 2>&1
    if test $status -ne 0
        echo "acpx: failed to ensure session" >&2
        return 1
    end

    # Visual feedback while waiting for response
    echo (set_color brblack)"thinking..."(set_color normal) >&2

    # Build global options (--format is a global option, before agent name)
    set -l global_opts
    if test -n "$CLAUDE_FORMAT"
        set global_opts --format $CLAUDE_FORMAT
    end

    if isatty stdout; and test (count $claude_pager_cmd) -gt 0
        # Primary: fish list variable (handles args with spaces correctly)
        acpx $global_opts claude prompt $argv | $claude_pager_cmd
    else if isatty stdout; and test -n "$CLAUDE_PAGER"
        # Fallback: env var string split (simple pager commands only)
        set -l parts (string split ' ' -- $CLAUDE_PAGER)
        acpx $global_opts claude prompt $argv | $parts
    else
        # Non-TTY: raw output (piped or redirected)
        acpx $global_opts claude prompt $argv
    end
end
