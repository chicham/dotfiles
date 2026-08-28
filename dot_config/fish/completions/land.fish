# Completion for the `land` function (and `jj land`, which delegates to it).
# Complete the optional <rev> arg with mutable change-ids + their descriptions.
complete -c land -f -a "(jj log --no-graph -T 'change_id.shortest(4) ++ \"\t\" ++ description.first_line() ++ \"\n\"' -r 'mutable()' 2>/dev/null)"
