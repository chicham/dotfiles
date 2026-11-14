function _fuzzy_complete_preview_option --description 'Print the man page entry of an option'
    # Usage: _fuzzy_complete_preview_option <option> <prefix>
    # Looks up the page of the subcommand first (`git commit --am` reads
    # git-commit(1)), then of the command. Prints the entry's first 15
    # lines; prints nothing when no page documents the option.
    set -l opt (string replace -r -- '=.*$' '' $argv[1])
    set -l words (string match -rv -- '^-' (string split -n ' ' -- $argv[2]))
    test (count $words) -gt 0; or return 0

    set -l pages $words[1]
    if test (count $words) -gt 1
        set pages $words[1]-$words[2] $pages
    end

    for page in $pages
        man -w $page &>/dev/null; or continue
        # An entry starts on a line whose first non-blank text is a flag
        # list holding the option as a whole word ("-f, --force",
        # "--force=<x>", "[--force]"). The list ends at the first run of two
        # spaces, so "-h   When used with the -l option" is not -l's entry.
        # index() keeps the option literal.
        set -l entry (man $page 2>/dev/null | col -bx | awk -v opt="$opt" '
            found { if (n++ >= 14) exit; print; next }
            {
                t = $0; sub(/^[ \t]+/, "", t); sub(/  .*$/, "", t)
                if (substr(t, 1, 1) != "-" && substr(t, 1, 1) != "[") next
                i = index(t, opt); if (!i) next
                pre = (i == 1) ? " " : substr(t, i - 1, 1)
                post = substr(t, i + length(opt), 1)
                if (pre ~ /[ ,[]/ && (post == "" || post ~ /[ ,=[\]]/)) { found = 1; print }
            }')
        if test -n "$entry"
            printf '%s\n' $entry
            return 0
        end
    end
end
