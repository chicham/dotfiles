# Toggle Claude Code prompt mode on/off.
#
# When ON: Enter sends input to Claude via ACPX. Alt+Enter inserts newline.
# When OFF: Enter executes shell commands normally.
#
# Defines fish_mode_prompt dynamically to avoid Starship load order race
# (Starship lazy-loads and blanks fish_mode_prompt — a static file would be overwritten).

function __claude_mode -d "Toggle Claude Code prompt mode"
    if set -q __claude_active
        # --- OFF ---
        set -e __claude_active

        # Restore Enter to normal shell execute
        bind -M insert  \r execute
        bind -M insert  \n execute
        bind -M default \r execute

        # Remove multiline binding (suppress error if not bound)
        bind -M insert -e \e\r 2>/dev/null

        # Restore Starship's empty fish_mode_prompt
        function fish_mode_prompt; end
    else
        # --- ON ---
        if not type -q acpx
            echo "claude mode: acpx not found — install with: npm i -g acpx" >&2
            return 1
        end

        set -g __claude_active 1

        # Rebind Enter → claude submit (both vi modes)
        bind -M insert  \r __claude_submit
        bind -M insert  \n __claude_submit
        bind -M default \r __claude_submit

        # Alt+Enter → literal newline for multiline prompts
        bind -M insert \e\r 'commandline -i \n'

        # Dynamic fish_mode_prompt — survives Starship init
        function fish_mode_prompt
            set_color --bold brmagenta
            echo -n '[claude] '
            set_color normal
        end
    end

    commandline -f repaint
end
