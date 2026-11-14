if type -q zoxide
    function __zoxide_cd_complete
        set -l token (commandline -ct)
        if test -z "$token"
            zoxide query -l
        else
            zoxide query -l -- $token
        end
    end
    complete -c cd -k -a '(__zoxide_cd_complete)' -d 'zoxide'

    # Print the top zoxide match for $argv[1] iff it is an unambiguous jump,
    # else print nothing and fail. Lets fuzzy_complete skip the fzf picker
    # (same target `cd <token><enter>` would reach) while still only
    # inserting text, never running the command.
    #
    # A wrong insert costs noticing it, deleting and retyping; the picker
    # costs one Enter. So every guard below errs towards the picker:
    # - the token names no local directory (the picker lists those too);
    # - it is a bare name: '/', '~', '.' or '$' mean a path, not a query;
    # - it has 3+ characters: shorter tokens matched almost anything;
    # - it starts the top match's basename or a word in it, since zoxide
    #   also matches mid-word ('ker' -> task_tracker over keras-hub);
    # - the top score is >= 10 and >= 10x the runner-up: either alone
    #   admits a big ratio between noise-level scores, or a big score with
    #   a close runner-up. 6x let ambiguous queries ('in', 'tra') through.
    function __zoxide_cd_dominant_match
        set -l token $argv[1]
        test (string length -- "$token") -ge 3; or return 1
        string match -qr '[/~.$]' -- $token; and return 1
        if string match -qi -- "$token*" (path filter -d -- *)
            return 1
        end

        set -l scored (zoxide query -l -s -- $token 2>/dev/null)
        test (count $scored) -gt 0; or return 1

        set -l top (string match -rg '^\s*(\S+)\s+(.*)$' -- $scored[1])
        set -l word_start '(^|[-_. ])'(string escape --style=regex -- $token)
        string match -qir -- $word_start (path basename -- $top[2]); or return 1

        if test (count $scored) -eq 1
            echo $top[2]
            return 0
        end

        set -l second (string match -rg '^\s*(\S+)\s+(.*)$' -- $scored[2])
        # fish's `test` only compares integers, and `math` has no
        # comparison operators - scale both scores by 10x (truncated to an
        # integer via --scale=0) so `test -ge` can compare them directly
        # while keeping one decimal place of precision.
        set -l top_i (math --scale=0 -- "$top[1] * 10")
        set -l second_i (math --scale=0 -- "$second[1] * 10")
        if test $top_i -ge 100
            and test $top_i -ge (math --scale=0 -- "10 * $second_i")
            echo $top[2]
            return 0
        end
        return 1
    end
end
