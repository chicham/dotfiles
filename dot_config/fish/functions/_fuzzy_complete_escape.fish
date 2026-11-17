function _fuzzy_complete_escape --description 'Escape a completion candidate for the command line or the picker query'
    # Usage: _fuzzy_complete_escape <candidate> <token>
    # <token> is the text being completed, as typed. Prints <candidate>
    # backslash-escaped, with a leading '~' and the '$' references the token
    # holds left bare so they still expand. Pure: prints only.
    # Backslash escaping, never quotes. `complete -C` is the only way back
    # into the completion engine for the *next* Tab, and a quoted token
    # suppresses tilde expansion, so an inserted '~/dir/' returns zero
    # candidates instead of that directory's contents. Backslash-escaped
    # text stays a live, re-completable token - and since it survives
    # spaces on its own, an opening quote the user typed is dropped rather
    # than rebuilt around the candidate.
    set -l escaped (string escape -n -- $argv[1])

    # `string escape -n` also escapes a leading tilde, which would kill
    # expansion just as quotes do. fish's own completion insertion leaves it
    # bare when the token being completed started with one, so mirror that.
    if string match -q '~*' -- $argv[2]
        and string match -q '\\~*' -- $escaped
        set escaped (string sub -s 2 -- $escaped)
    end

    # Same for '$': `complete -C` returns the variable references the user
    # typed unexpanded ('$HOME/Documents/', '$WANDB_API_KEY'), and '\$'
    # would make them literal. Only as many leading '\$' are restored as
    # the token holds unescaped '$', so a literal one in the completed part
    # of a filename ('$HOME/a$b.txt') stays escaped.
    set -l n_vars (string match -ar '(?<!\\\\)\$' -- $argv[2] | count)
    while test $n_vars -gt 0
        set escaped (string replace -- '\\$' '$' $escaped)
        set n_vars (math $n_vars - 1)
    end
    printf '%s\n' $escaped
end
