function _fuzzy_complete_preview --description 'Render the Tab picker preview for one completion candidate'
    # Usage: _fuzzy_complete_preview <candidate> [description]
    # Reads FC_PREFIX (the command line before the token) and, when set,
    # FZF_PREVIEW_COLUMNS / FZF_PREVIEW_LINES. Writes the preview to stdout
    # and nothing else. Optional tools (bat, eza, chafa, hexyl, pdftotext)
    # fall back to plain ones (cat, ls, file, xxd) when missing.
    set -l cand $argv[1]
    set -l desc (string replace -ra '\e\[[0-9;]*m' '' -- "$argv[2]")
    set -l path (_fuzzy_complete_expand $cand)

    if test -n "$desc"
        set_color --bold
        printf '%s\n\n' $desc
        set_color normal
    end

    switch (_fuzzy_complete_kind $cand "$FC_PREFIX")
        case option
            _fuzzy_complete_preview_option $cand "$FC_PREFIX"
        case dir
            if command -q eza
                eza -1a --color=always --group-directories-first -- $path
            else
                ls -1A -- $path
            end
        case file
            _fuzzy_complete_preview_file $path
        case function
            if command -q bat
                functions -- $cand | bat -l fish --color=always --style=plain
            else
                functions -- $cand
            end
        case command
            man $cand 2>/dev/null | col -bx | head -n 80
    end
end
