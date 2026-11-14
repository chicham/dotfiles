function _fuzzy_complete_kind --description 'Classify a completion candidate for the picker preview'
    # Usage: _fuzzy_complete_kind <candidate> <prefix>
    # <prefix> is the command line before the token (FC_PREFIX).
    # Prints exactly one of: option dir file function command text.
    # Reads the filesystem and the function/command tables; no side effects.
    set -l cand $argv[1]
    set -l prefix $argv[2]

    if string match -q -- '-*' $cand
        echo option
        return
    end

    set -l path (_fuzzy_complete_expand $cand)
    if test -d "$path"
        echo dir
        return
    end
    if test -f "$path"
        echo file
        return
    end

    # A name is only a command when the word before it runs one; `git diff`
    # completes a subcommand that happens to share a name with /usr/bin/diff.
    set -l words (string split -n ' ' -- (string trim -- $prefix))
    if test (count $words) -eq 0
        or contains -- $words[-1] sudo doas command builtin exec env time nohup \
            which type man functions '|' ';' '&&' '||' and or not if while
        if functions -q -- $cand
            echo function
            return
        end
        if command -q -- $cand
            echo command
            return
        end
    end
    echo text
end
