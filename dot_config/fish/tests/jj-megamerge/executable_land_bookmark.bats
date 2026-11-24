#!/usr/bin/env bats
# `jj land -b`: only the bookmark `landing` may be advanced besides main, and the
# `landing()` revset keeps it out of the arms that sync, pull and land rebase.
# Throwaway jj repos with the repo's own revset aliases: config.toml.tmpl is rendered
# by `chezmoi execute-template` (read-only, applies nothing) into a throwaway JJ_CONFIG.
# Usage: bats ~/.config/fish/tests/jj-megamerge/land_bookmark.bats

setup() {
  here=$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)
  FUNCS=$(cd "$here/../../functions" && pwd)
  command -v fish > /dev/null || skip "fish not available"
  T=$BATS_TEST_TMPDIR
  command -v chezmoi > /dev/null || skip "chezmoi not available"
  # Source tree: the template sits beside the tests' ancestor dirs. Live tree: only the
  # rendered config.toml exists, so ask chezmoi where its source is.
  JJDIR=$(cd "$here/../../../jj" 2>/dev/null && pwd)
  CFG=$JJDIR/config.toml.tmpl
  if [ ! -f "$CFG" ]; then
    CFG=$(chezmoi source-path "$JJDIR/config.toml" 2>/dev/null) || CFG=
  fi
  [ -f "$CFG" ] || skip "config.toml.tmpl not found"
  chezmoi execute-template < "$CFG" > "$T/config.toml"
  export JJ_CONFIG=$T/config.toml
  export ORGFILES=$T/org XDG_STATE_HOME=$T/state
  mkdir -p "$ORGFILES/gtd"
  echo '* Tasks' > "$ORGFILES/gtd/inbox.org"
  git init -q --bare "$T/origin.git"
  # Signing off from the first commit: the user's signer would prompt and stall the run.
  jj --config signing.behavior=drop git clone "$T/origin.git" "$T/r1" > /dev/null 2>&1
  R=$T/r1
  jj -R "$R" config set --repo signing.behavior drop
  jj -R "$R" config set --repo signing.sign-all false
  jj -R "$R" commit -m 'chore: init' > /dev/null 2>&1
  jj -R "$R" bookmark create main -r @- > /dev/null 2>&1
  jj -R "$R" git push --bookmark main --remote origin > /dev/null 2>&1
}

# Run a fish snippet with the repo's functions on the path, as jj-land would.
fx() {
  JJ_WORKSPACE_ROOT=$R fish -c "set fish_function_path $FUNCS \$fish_function_path; $*"
}

d() { jj -R "$R" log --no-graph -r "$1" -T 'description.first_line() ++ "\n"' 2>&1; }
id() { jj -R "$R" log --no-graph -r "$1" -T 'commit_id' 2>&1; }

# A described commit with one file, off main, left behind @ (an empty child of it).
arm() {
  jj -R "$R" new main > /dev/null 2>&1
  echo "$1" > "$R/$1.txt"
  jj -R "$R" commit -m "$2" > /dev/null 2>&1
}

@test "a land on main leaves the landing bookmark in place" {
  jj -R "$R" new main -m 'feat: held' > /dev/null 2>&1
  echo held > "$R/held.txt"
  jj -R "$R" bookmark create landing -r @ > /dev/null 2>&1
  before=$(id 'bookmarks(exact:"landing")')
  arm a 'feat: a'
  run fx "land"
  [ "$status" -eq 0 ]
  [ "$(d main)" = "feat: a" ]
  [ "$(id 'bookmarks(exact:"landing")')" = "$before" ]
  [ -z "$(d 'landing() & arms()')" ]
  [ -z "$(d 'conflicts() & mutable()')" ]
}

@test "land -b wip, -b main and -b other are refused with a nonzero exit" {
  jj -R "$R" bookmark create wip -r main > /dev/null 2>&1
  jj -R "$R" bookmark create other -r main > /dev/null 2>&1
  arm a 'feat: a'
  main_before=$(id main)
  wip_before=$(id 'bookmarks(exact:"wip")')
  for b in wip main other; do
    run fx "land -b $b"
    [ "$status" -ne 0 ]
  done
  run fx "land -b wip"
  [[ "$output" == *"wip"* ]]
  [ "$(id main)" = "$main_before" ]
  [ "$(id 'bookmarks(exact:"wip")')" = "$wip_before" ]
  [ "$(id 'bookmarks(exact:"other")')" = "$main_before" ]
}

@test "after land -b landing and a move of main, the workspace passes the arm rules" {
  jj -R "$R" bookmark create landing -r main > /dev/null 2>&1
  arm a 'feat: a'
  run fx "land -b landing"
  [ "$status" -eq 0 ]
  [ "$(d 'bookmarks(exact:"landing")')" = "feat: a" ]
  # main moves on, as when another arm lands.
  jj -R "$R" new main > /dev/null 2>&1
  echo b > "$R/b.txt"
  jj -R "$R" commit -m 'feat: b' > /dev/null 2>&1
  jj -R "$R" bookmark set main -r '@-' > /dev/null 2>&1
  jj -R "$R" new 'bookmarks(exact:"landing")' > /dev/null 2>&1
  [ -z "$(d 'mm_arm_violations(@)')" ]
  [ -z "$(d 'arms() & ::landing()')" ]
  [ -z "$(d 'orphan_arms() & ::landing()')" ]
  echo c > "$R/c.txt"
  run jj -R "$R" commit -m 'feat: c'
  [ "$status" -eq 0 ]
}

@test "an arm stacked on the landing commits lands on main" {
  jj -R "$R" new main -m 'feat: held' > /dev/null 2>&1
  echo held > "$R/held.txt"
  jj -R "$R" bookmark create landing -r @ > /dev/null 2>&1
  jj -R "$R" new 'bookmarks(exact:"landing")' > /dev/null 2>&1
  echo s > "$R/s.txt"
  jj -R "$R" commit -m 'feat: stacked' > /dev/null 2>&1
  stacked=$(jj -R "$R" log --no-graph -r '@-' -T 'change_id')
  # main moved on since landing was cut: the arm is behind main by the landing commit too.
  jj -R "$R" new main > /dev/null 2>&1
  echo m > "$R/m.txt"
  jj -R "$R" commit -m 'feat: moved' > /dev/null 2>&1
  jj -R "$R" bookmark set main -r '@-' > /dev/null 2>&1
  before=$(id 'bookmarks(exact:"landing")')
  run fx "land $stacked"
  [ "$status" -eq 0 ]
  [ "$(d main)" = "feat: stacked" ]
  [ "$(id 'bookmarks(exact:"landing")')" = "$before" ]
  [ -z "$(d 'conflicts() & mutable()')" ]
}

@test "an arm stacked on the landing commits lands when main has not moved" {
  jj -R "$R" new main -m 'feat: held' > /dev/null 2>&1
  echo held > "$R/held.txt"
  jj -R "$R" bookmark create landing -r @ > /dev/null 2>&1
  jj -R "$R" new 'bookmarks(exact:"landing")' > /dev/null 2>&1
  echo s > "$R/s.txt"
  jj -R "$R" commit -m 'feat: stacked' > /dev/null 2>&1
  run fx "land"
  [ "$status" -eq 0 ]
  [ "$(d main)" = "feat: stacked" ]
  [ -z "$(d 'conflicts() & mutable()')" ]
}
