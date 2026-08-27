# Route commandline input to Claude or shell.
#
# Called when Enter is pressed in claude mode.
# Empty input → noop.
# "!" prefix → strip ! and execute as shell command (escape hatch).
# Anything else → send to Claude via __claude_send.

function __claude_submit -d "Submit commandline to Claude or shell"
    set -l input (commandline)

    # Empty → noop
    if test -z (string trim -- "$input")
        return
    end

    # Shell escape: "!" prefix strips ! and executes normally
    if string match -qr '^!' -- "$input"
        commandline (string sub -s 2 -- "$input")
        commandline -f execute
        return
    end

    # Clear line and dispatch to Claude
    commandline ''
    echo

    # Prefixed history entry for filtering: `history search --prefix 'cc:'`
    # Redirect all output: Atuin may dump history to stdout
    builtin history add -- "cc: $input" >/dev/null 2>&1

    __claude_send -- $input

    commandline -f repaint
end
