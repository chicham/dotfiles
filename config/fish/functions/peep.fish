function peep --argument-names pattern
  test -n "$pattern";
  and set filepath (rg --vimgrep -u $pattern | awk -F: '{print sprintf("%s %d %d %d", $1, $2, $2-4, $2+4)}' \
  | fzf --sync --no-multi --ansi -n 4 --preview="sed -n {3},{4}p {1} | bat --force-colorization --style=snip --file-name={1} --highlight-line 5");
  or return 1

  if test -n "$pattern"
    set filename (echo $filepath | cut -d' ' -f1)
    set line (echo $filepath | cut -d' ' -f2)
    nvim $filename +$line
  end
end
