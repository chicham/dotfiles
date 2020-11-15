function git-review-checkout --description="Checkout a remote branch"
  set branch = (git for-each-ref refs/remotes/ \
                           --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%(refname:strip=2)%(end)%(end)" \
                           2>/dev/null | sed '/^$/d' \
               | fzf --no-hscroll --no-multi -n 2 \
                     --reverse --preview="git diff --numstat {1} master |  sort -rn -k1,1 -k2,2 | awk '{ print $1 $2 $3 }'")

  test -n "$branch"; and set remote (string split '/' $branch); or return 1
  set current_branch (git branch --show-current)

  if test "$remote[3]" != "$current_branch"
    git fetch -qfu $remote[2] $remote[3]; or return 1
    git checkout $remote[3]
  end
end
