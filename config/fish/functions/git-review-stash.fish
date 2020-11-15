function git-review-stash -d "Preview changes in a stash"
  set stash (__fish_git --no-pager stash list| cut -d: -f1 | fzf --no-hscroll --no-multi --ansi \
                              --preview-window=right:60% \
                              --preview="git --no-pager stash show -p --color {} \
                                        |delta --no-gitconfig --line-numbers --width 150")
  test -n "$stash"; and __fish_git stash apply -q $stasH; or return 1
end
