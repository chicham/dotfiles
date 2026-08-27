# Send current commandline buffer to Claude without entering/exiting mode.
#
# Complementary to __claude_mode: use this for quick one-off queries
# (sgpt pattern). Bind it to a key if desired:
#   bind -M insert \e\cg __claude_oneshot  # example: Alt+Ctrl+G

function __claude_oneshot -d "Send current buffer to Claude (one-shot, no mode switch)"
    set -l input (commandline)

    if test -z (string trim -- "$input")
        return
    end

    commandline ''
    echo

    builtin history add -- "cc: $input" >/dev/null 2>&1
    __claude_send -- $input

    commandline -f repaint
end
