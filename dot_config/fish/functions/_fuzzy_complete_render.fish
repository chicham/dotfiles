function _fuzzy_complete_render --description 'Render complete -C candidates as fzf rows: candidate + dimmed description'
    # `--comps <line>...` renders candidates the caller already has, so the
    # first draw does not run `complete -C` a second time (slow completers
    # would double the Tab latency); a bare command line is what fzf's
    # change:reload passes.
    set -l comps
    if test "$argv[1]" = --comps
        set comps $argv[2..]
    else
        set comps (complete -C $argv[1])
    end

    if test (count $comps) -eq 0
        return 0
    end

    set -l cands (string replace -r '\t.*$' '' -- $comps)
    set -l descs (string replace -r '^[^\t]*\t?' '' -- $comps)

    # No manual truncation/padding here: fzf can only search fields it also
    # displays (--nth cannot see a field hidden by --with-nth), so pre-cutting
    # the candidate for column alignment would silently hide real matches
    # whenever the query text falls in the cut portion. fzf truncates long
    # lines itself at render time without touching the underlying searchable
    # text, so overflow is left to it.
    for i in (seq (count $comps))
        printf '%s\t\x1b[2m%s\x1b[0m\n' $cands[$i] $descs[$i]
    end
end
