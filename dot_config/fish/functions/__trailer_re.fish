function __trailer_re --description 'Print the regex of one commit-footer trailer line'
    # The vocabulary every consumer of commit footers agrees on: what orgtool closes or
    # links (`sweep`, `repo_trailers`), plus the GitHub `#N` forms. A line is a trailer when
    # it is exactly one of
    #   Closes|Fixes|Resolves[:] #N    (colon optional; after a colon, spaces optional)
    #   Issue: #N                      (a link that closes nothing; colon required)
    #   Closes|Fixes|Resolves|Issue: org:<UUID>   (colon required, UUID lowercase, 36 chars)
    # The keyword is case-insensitive and the line may be indented or end in blanks; any
    # other trailing text disqualifies it, as it does for orgtool.
    # The same regex is spelled in `no_issue()` and the `issues` alias of
    # ~/.config/jj/config.toml: tests/jj-megamerge/trailers.bats holds all consumers to one table.
    #   (no flag)  the line body, to be wrapped in ^ and $
    #   --refs     also accept `Refs` as a keyword (PR gates only: orgtool does not close on it)
    #   --shared   a revset regex matching a trailer line that shares its paragraph with
    #              another line (implies --refs)
    argparse refs shared -- $argv
    or return 2
    set -l kw 'closes|fixes|resolves'
    if set -q _flag_refs; or set -q _flag_shared
        set kw 'closes|fixes|resolves|refs'
    end
    set -l uuid '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    set -l body "[[:blank:]]*(?:(?i:$kw)(?::[[:blank:]]*| )#[0-9]+|(?i:issue):[[:blank:]]*#[0-9]+|(?i:$kw|issue):[[:blank:]]*org:$uuid)[[:blank:]]*"
    if set -q _flag_shared
        # jj-stack joins the lines of a paragraph into one line of the PR body.
        echo -- '(?m)^'$body'\n[^\n]|[^\n]\n'$body'$'
    else
        echo -- $body
    end
end
