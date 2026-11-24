#!/usr/bin/env bats
# __jj_org_close and its callers: the org tasks of `Closes: org:<UUID>` trailers close
# once the commit is on main. Throwaway jj repos, a throwaway ORGFILES and a throwaway
# state dir; ORGTOOL must name an orgtool that has `sweep --rev`.
# Usage: ORGTOOL=<path to orgtool> bats ~/.config/fish/tests/jj-megamerge/org_close.bats

setup() {
  here=$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)
  FUNCS=$(cd "$here/../../functions" && pwd)
  : "${ORGTOOL:=$HOME/.claude/skills/org/scripts/orgtool}"
  export ORGTOOL
  command -v fish > /dev/null || skip "fish not available"
  bash "$ORGTOOL" sweep -h 2>&1 | grep -q -- '--rev' || skip "orgtool has no sweep --rev"
  T=$BATS_TEST_TMPDIR
  export ORGFILES=$T/org XDG_STATE_HOME=$T/state HOME_REAL=$HOME
  mkdir -p "$ORGFILES/gtd"
  echo '* Tasks' > "$ORGFILES/gtd/inbox.org"
  INBOX=$ORGFILES/gtd/inbox.org
  # Signing off from the first commit: the user's signer would prompt and stall the run.
  git init -q --bare "$T/origin.git"
  jj --config signing.behavior=drop git clone "$T/origin.git" "$T/r1" > /dev/null 2>&1
  R=$T/r1
  jj -R "$R" config set --repo signing.behavior drop
  jj -R "$R" config set --repo signing.sign-all false
  jj -R "$R" commit -m 'chore: init' > /dev/null 2>&1
  jj -R "$R" bookmark create main -r @- > /dev/null 2>&1
  jj -R "$R" git push --bookmark main --remote origin > /dev/null 2>&1
  UUID=$(bash "$ORGTOOL" new 'task under test' | sed -E 's/^org:([^\t]*)\t.*/\1/')
}

# Run a fish snippet with the repo's functions on the path.
fx() {
  fish -c "set fish_function_path $FUNCS \$fish_function_path; $*"
}

# Add a commit with a trailer on main, in repo $1 (message body from $2).
land_msg() {
  jj -R "$1" new main -m "$2" > /dev/null 2>&1
  echo "$RANDOM" > "$1/f.txt"
  jj -R "$1" bookmark set main -r @ > /dev/null 2>&1
  jj -R "$1" new main > /dev/null 2>&1
}

trailer() { printf 'feat: x\n\nCloses: org:%s\n' "$UUID"; }

@test "seed, land a closing commit: DONE, one CLOSED, one COMMITS token, rerun adds nothing" {
  fx "__jj_org_close $R"
  land_msg "$R" "$(trailer)"
  fx "__jj_org_close $R" 2>&1
  grep -q "^\*\* DONE task under test" "$INBOX"
  [ "$(grep -c 'CLOSED:' "$INBOX")" = 1 ]
  [ "$(grep -c ':COMMITS:' "$INBOX")" = 1 ]
  before=$(cat "$INBOX")
  fx "__jj_org_close $R"
  fx "__jj_org_close $R"
  [ "$(cat "$INBOX")" = "$before" ]
}

@test "plain jj git fetch then jj pull closes a merge made on the forge" {
  fx "__jj_org_close $R"
  jj --config signing.behavior=drop git clone "$T/origin.git" "$T/r2" > /dev/null 2>&1
  jj -R "$T/r2" config set --repo signing.behavior drop
  jj -R "$T/r2" config set --repo signing.sign-all false
  land_msg "$T/r2" "$(trailer)"
  jj -R "$T/r2" git push --bookmark main --remote origin > /dev/null 2>&1
  # The fetch alone must not close; pull (with the sync it ends in stubbed out) does.
  jj -R "$R" git fetch > /dev/null 2>&1
  grep -q "^\*\* TODO task under test" "$INBOX"
  JJ_WORKSPACE_ROOT=$R fx "function jj-sync; end; pull" 2>&1
  grep -q "^\*\* DONE task under test" "$INBOX"
  [ "$(grep -c 'CLOSED:' "$INBOX")" = 1 ]
}

@test "a task reopened after the close is not closed again" {
  fx "__jj_org_close $R"
  land_msg "$R" "$(trailer)"
  fx "__jj_org_close $R"
  sed -i.bak 's/^\*\* DONE task/** TODO task/' "$INBOX"
  fx "__jj_org_close $R"
  grep -q "^\*\* TODO task under test" "$INBOX"
}

@test "an open CLOCK leaves the task open and reported" {
  fx "__jj_org_close $R"
  printf '   :LOGBOOK:\n   CLOCK: [2026-11-24 Tue 10:00]\n   :END:\n' > "$T/clock"
  sed -i.bak "/^   :END:/r $T/clock" "$INBOX"
  land_msg "$R" "$(trailer)"
  run fx "__jj_org_close $R" 2>&1
  [[ "$output" == *"open CLOCK"* ]]
  grep -q "^\*\* TODO task under test" "$INBOX"
}

@test "an unresolved watermark reseeds to main without closing" {
  land_msg "$R" "$(trailer)"
  mkdir -p "$XDG_STATE_HOME/jj-org-close"
  fx "__jj_org_close $R"
  grep -q "^\*\* TODO task under test" "$INBOX"
  mark=$(ls "$XDG_STATE_HOME"/jj-org-close/*)
  [ "$(cat "$mark")" = "$(jj -R "$R" log --no-graph -r main -T commit_id)" ]
  # A watermark that names nothing is treated the same way.
  echo 0123456789abcdef0123456789abcdef01234567 > "$mark"
  fx "__jj_org_close $R"
  grep -q "^\*\* TODO task under test" "$INBOX"
  [ "$(cat "$mark")" = "$(jj -R "$R" log --no-graph -r main -T commit_id)" ]
}
