function _fuzzy_complete_insert --description 'Replace the current token up to the cursor with a chosen candidate, matching native fish escaping and trailing-space rules'
    set -l cand $argv[1]
    # Part of the token left of the cursor, as the picker matched it:
    # already stripped of any opening quote the user typed. Falls back to
    # the raw text so the function stays callable on its own.
    set -l token $argv[2]
    if not set -q argv[2]
        set token (commandline -ct)
    end

    # fish appends a space after an unambiguous completion so the next arg
    # can be typed immediately, except when the candidate ends in '/' or '='
    # (a directory or a flag=value form), since those invite continuing the
    # same token rather than starting a new one. Decided on the raw
    # candidate, before escaping it for the command line.
    set -l suffix ' '
    set -l last_char (string sub -s -1 -- $cand)
    if test "$last_char" = / -o "$last_char" = =
        set suffix ''
    end

    # Backslash escaping, never quotes. `complete -C` is the only way back
    # into the completion engine for the *next* Tab, and a quoted token
    # suppresses tilde expansion, so an inserted '~/dir/' returns zero
    # candidates instead of that directory's contents. Backslash-escaped
    # text stays a live, re-completable token - and since it survives
    # spaces on its own, an opening quote the user typed is dropped rather
    # than rebuilt around the candidate.
    set -l escaped (string escape -n -- $cand)

    # `string escape -n` also escapes a leading tilde, which would kill
    # expansion just as quotes do. fish's own completion insertion leaves it
    # bare when the token being completed started with one, so mirror that.
    if string match -q '~*' -- $token
        and string match -q '\\~*' -- $escaped
        set escaped (string sub -s 2 -- $escaped)
    end

    # Same for '$': `complete -C` returns the variable references the user
    # typed unexpanded ('$HOME/Documents/', '$WANDB_API_KEY'), and '\$'
    # would make them literal. Only as many leading '\$' are restored as
    # the token holds unescaped '$', so a literal one in the completed part
    # of a filename ('$HOME/a$b.txt') stays escaped.
    set -l n_vars (string match -ar '(?<!\\\\)\$' -- $token | count)
    while test $n_vars -gt 0
        set escaped (string replace -- '\\$' '$' $escaped)
        set n_vars (math $n_vars - 1)
    end

    # Replace only what lies left of the cursor, as fish's own completion
    # does; text right of the cursor in the same token is kept after it.
    set -l before (commandline -ct)
    set -l after (string sub -s (math (string length -- "$before") + 1) -- (commandline -t))
    set -l start (math (commandline -C) - (string length -- "$before"))
    commandline -t -- $escaped$suffix$after
    commandline -C (math $start + (string length -- "$escaped$suffix"))
    commandline -f repaint
end
