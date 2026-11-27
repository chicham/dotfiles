#!/usr/bin/env bats
# One table of commit-footer lines, run against every consumer of the trailer vocabulary:
# the no_issue() revset, the `jj issues` alias, and the PR paragraph-sharing gate
# (__trailer_re --shared, used by pr.fish). Each consumer's verdict must equal the table.
# Throwaway jj repos only; the jj config is the chezmoi source with its templated head
# (user, signing) cut off, loaded through JJ_CONFIG.
# Usage: bats ~/.config/fish/tests/jj-megamerge/trailers.bats

# name | std | pr | line     std: no_issue() and `jj issues` count it as a trailer;
# pr: the PR gate sees it as a footer (differs from std only for Refs).
# Placeholders: UUID (valid), UPPER, SHORT, LONG; `~` ends the line (to keep blanks).
TABLE='
closes-colon-space|Y|Y|Closes: #12~
closes-colon-nospace|Y|Y|Closes:#12~
closes-nocolon|Y|Y|Closes #12~
fixes-colon|Y|Y|Fixes: #12~
fixes-nocolon|Y|Y|Fixes #12~
resolves-colon|Y|Y|Resolves: #12~
resolves-nocolon|Y|Y|Resolves #12~
lowercase-keyword|Y|Y|closes: #12~
uppercase-keyword|Y|Y|CLOSES: #12~
issue-colon|Y|Y|Issue: #12~
issue-colon-nospace|Y|Y|Issue:#12~
issue-nocolon|N|N|Issue #12~
org-closes|Y|Y|Closes: org:UUID~
org-closes-nospace|Y|Y|Closes:org:UUID~
org-fixes|Y|Y|Fixes: org:UUID~
org-resolves|Y|Y|Resolves: org:UUID~
org-issue|Y|Y|Issue: org:UUID~
org-nocolon|N|N|Closes org:UUID~
org-uppercase-uuid|N|N|Closes: org:UPPER~
org-short-uuid|N|N|Closes: org:SHORT~
org-long-uuid|N|N|Closes: org:LONG~
org-trailing-text|N|N|Closes: org:UUID and more~
org-indented|Y|Y|   Closes: org:UUID~
refs-colon|N|Y|Refs: #12~
refs-nocolon|N|Y|Refs #12~
refs-org|N|Y|Refs: org:UUID~
issue-none|N|N|Issue: none~
trailing-text|N|N|Closes: #12 and more~
trailing-blank|Y|Y|Closes: #12  ~
indented|Y|Y|  Closes: #12~
leading-text|N|N|See Closes: #12~
no-number|N|N|Closes: #~
word-number|N|N|Closes: #abc~
bare-number|N|N|Closes: 12~
other-keyword|N|N|Closed: #12~
two-numbers|N|N|Closes: #12, #13~
'

setup() {
  here=$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)
  FUNCS=$(cd "$here/../../functions" && pwd)
  command -v fish > /dev/null || skip "fish not available"
  T=$BATS_TEST_TMPDIR
  # Source tree: dot_config/jj/config.toml.tmpl. Installed tree: the rendered config.
  SRC=$here/../../../jj/config.toml.tmpl
  [ -f "$SRC" ] || SRC=$HOME/.config/jj/config.toml
  sed -n '/^\[git\]/,$p' "$SRC" > "$T/jj.toml"
  export JJ_CONFIG=$T/jj.toml JJ_USER=t JJ_EMAIL=t@example.com
  git init -q --bare "$T/origin.git"
  jj --config signing.behavior=drop git clone "$T/origin.git" "$T/r" > /dev/null 2>&1
  R=$T/r
  jj -R "$R" config set --repo signing.behavior drop
  jj -R "$R" config set --repo signing.sign-all false
  jj -R "$R" commit -m 'chore: init' > /dev/null 2>&1
  jj -R "$R" bookmark create main -r @- > /dev/null 2>&1
  jj -R "$R" git push --bookmark main --remote origin > /dev/null 2>&1
  UUID=0191e0a2-7b3c-7d4e-8f5a-6b7c8d9e0f1a
  ROWS=$(grep -c '|' <<< "$TABLE")
}

# Calls "$1 name std pr line" for every table row, with placeholders expanded.
each_row() {
  local name std pr line
  while IFS='|' read -r name std pr line; do
    [ -n "$name" ] || continue
    line=${line%\~}
    line=${line//UUID/$UUID}
    line=${line//UPPER/${UUID^^}}
    line=${line//SHORT/${UUID:0:35}}
    line=${line//LONG/${UUID}0}
    "$1" "$name" "$std" "$pr" "$line"
  done <<< "$TABLE"
}

# One sibling commit off main per row, titled "<shape>: <row>", whose body is the row's
# line alone (std), after a prose line (prose-before) or before one (prose-after).
add_rows() {
  shape=$1
  mk() {
    local body
    case $shape in
      std) body=$4 ;;
      prose-before) body=$(printf 'some prose\n%s' "$4") ;;
      prose-after) body=$(printf '%s\nsome prose' "$4") ;;
    esac
    jj -R "$R" new main -m "$(printf '%s: %s\n\n%s' "$shape" "$1" "$body")" > /dev/null 2>&1
  }
  each_row mk
  jj -R "$R" new main > /dev/null 2>&1
}

# Titles of the commits revset $1 selects, one per line.
titles() {
  jj -R "$R" log --no-graph -r "$1" -T 'description.first_line() ++ "\n"'
}

# Compare each row's verdict (Y: the consumer sees a trailer) with the table.
# $1 shape; $2 file of titles the consumer saw; $3 column: std or pr; $4 sense: seen or missed.
assert_rows() {
  fail=0 shape=$1 seen=$2 col=$3 sense=$4
  verdict() {
    local want=$2 got
    [ "$col" = pr ] && want=$3
    if grep -qxF -- "$shape: $1" "$seen"; then got=Y; else got=N; fi
    [ "$sense" = missed ] && { [ "$got" = Y ] && got=N || got=Y; }
    [ "$got" = "$want" ] || {
      echo "$shape row $1 ($4): want $want, got $got" >&2
      fail=1
    }
  }
  each_row verdict
  [ "$fail" = 0 ]
}

@test "every row is an arm commit (a row that never landed cannot pass as 'no trailer')" {
  add_rows std
  [ "$(titles 'arms()' | grep -c '^std: ')" = "$ROWS" ]
}

@test "no_issue(): a row is a trailer exactly when the table says so" {
  add_rows std
  titles 'no_issue()' > "$T/flagged"
  assert_rows std "$T/flagged" std missed
}

@test "jj issues: a row lists a trailer exactly when the table says so" {
  add_rows std
  # A row without trailer ends its line in "  -".
  jj -R "$R" issues 2>&1 | sed -nE 's/^[a-z]+ (std: [^ ]+)  -$/\1/p' > "$T/none"
  assert_rows std "$T/none" std missed
}

@test "PR paragraph gate: a footer is seen exactly when the table says so, in both positions" {
  re=$(fish -c "set fish_function_path $FUNCS \$fish_function_path; __trailer_re --shared")
  for shape in prose-before prose-after; do
    add_rows "$shape"
    titles "description(glob:\"$shape: *\") & description(regex:'$re')" > "$T/seen-$shape"
    assert_rows "$shape" "$T/seen-$shape" pr seen
  done
}
