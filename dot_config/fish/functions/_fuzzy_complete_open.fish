function _fuzzy_complete_open --description 'Open a Tab picker candidate: text files in $EDITOR, commands in man, the rest in a pager'
    # Usage: _fuzzy_complete_open <candidate> [description]
    # Run by fzf's execute(), which hands it the terminal; returns to the
    # picker when the editor or pager exits. Reads FC_PREFIX and EDITOR.
    set -l cand $argv[1]
    set -l path (_fuzzy_complete_expand $cand)
    switch (_fuzzy_complete_kind $cand "$FC_PREFIX")
        case file
            set -l mime (file --brief --mime-type -- $path)
            if string match -q 'text/*' -- $mime[1]
                set -l editor (string split -n ' ' -- "$EDITOR")
                set -q editor[1]; or set editor nvim
                $editor -- $path
                return
            end
        case command
            man $cand
            return
    end
    _fuzzy_complete_preview $argv | less -R
end
