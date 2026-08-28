function land --description 'Rebase sibling chains onto the current chain tip (advance main manually)'
    # Single source of truth for the land logic; the jj `land` alias delegates here
    # (see ~/.config/jj/config.toml) so `jj land [<rev>]` and `land [<rev>]` are equivalent.
    # Rev defaults to @ when omitted.
    set -l rev @
    test -n "$argv[1]"; and set rev $argv[1]
    jj rebase -s "roots(pending() ~ chain(my_tip($rev)))" -d "my_tip($rev)" --skip-emptied
end
