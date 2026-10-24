#!/usr/bin/env bats
# rex-session and rex-agent against a fake `rex` that logs its argv and
# replays canned JSON, so no Rex server is touched. The last test drives a
# real server and runs only with REX_LIVE=1.

bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/setup'
  command -v jq > /dev/null 2>&1 || skip "jq not available"
  BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$BIN"
  cp "$REPO_ROOT/dot_local/bin/executable_rex-session" "$BIN/rex-session"
  cp "$REPO_ROOT/dot_local/bin/executable_rex-agent" "$BIN/rex-agent"
  export REX_LOG="$BATS_TEST_TMPDIR/rex.log"
  export FAKE_SESSIONS='{"sessions":[]}'
  : > "$REX_LOG"
  cat > "$BIN/rex" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$REX_LOG"
case "$1 ${2:-}" in
  "ls --json") [ -n "${FAKE_DOWN:-}" ] && exit 1; printf '%s\n' "$FAKE_SESSIONS" ;;
  "new "*) echo '{"session_id":"session:new"}' ;;
  "window new") echo '{"window_id":"window:w1","block_ids":["block:b1"],"revision":1}' ;;
  "split "*) echo '{"block_id":"block:s1"}' ;;
  "block inspect") echo '{"block":{"window_id":"window:host"}}' ;;
esac
EOF
  cat > "$BIN/claude" <<'EOF'
#!/bin/sh
echo "claude in $(pwd -P): $*"
EOF
  chmod +x "$BIN"/*
  export PATH="$BIN:$PATH"
  PROJ=$(cd "$BATS_TEST_TMPDIR" && pwd -P)/proj
  mkdir -p "$PROJ/.git" "$PROJ/src/deep"
  export TMPDIR="$BATS_TEST_TMPDIR"
  unset REX_BLOCK REX_SESSION
}

@test "both scripts pass shellcheck" {
  command -v shellcheck > /dev/null 2>&1 || skip "shellcheck not available"
  shellcheck -S warning "$BIN/rex-session" "$BIN/rex-agent"
}

@test "--root finds the nearest .git ancestor" {
  run rex-session --root "$PROJ/src/deep"
  [ "$status" -eq 0 ]
  [ "$output" = "$PROJ" ]
}

@test "--root maps a jj workspace to its repo" {
  mkdir -p "$PROJ/.workspaces/arm/.jj" "$PROJ/.workspaces/arm/lib"
  run rex-session --root "$PROJ/.workspaces/arm/lib"
  [ "$output" = "$PROJ" ]
}

@test "--root falls back to the directory itself" {
  d=$(cd "$BATS_TEST_TMPDIR" && pwd -P)/loose
  mkdir -p "$d"
  run rex-session --root "$d"
  [ "$output" = "$d" ]
}

@test "reuses the session whose label is the project name" {
  FAKE_SESSIONS='{"sessions":[{"session_id":"session:a","label":"other"},{"session_id":"session:p","label":"proj"}]}'
  run rex-session "$PROJ/src"
  [ "$status" -eq 0 ]
  [ "$output" = "session:p" ]
  ! grep -q '^new' "$REX_LOG"
}

@test "creates a missing session at the project root" {
  run rex-session "$PROJ/src"
  [ "$output" = "session:new" ]
  grep -qx "new proj --cwd $PROJ --json" "$REX_LOG"
}

@test "warns and picks the first of duplicate sessions" {
  FAKE_SESSIONS='{"sessions":[{"session_id":"session:1","label":"proj"},{"session_id":"session:2","label":"proj"}]}'
  run --separate-stderr rex-session "$PROJ"
  [ "$output" = "session:1" ]
  [[ "$stderr" == *"2 sessions named 'proj'"* ]]
}

@test "releases its lock so the next call does not wait" {
  rex-session "$PROJ" > /dev/null
  ! ls -d "$TMPDIR"/rex-session.*.lock 2> /dev/null
}

@test "agent opens a kept-open window labelled agent:NAME and prints JSON" {
  FAKE_SESSIONS='{"sessions":[{"session_id":"session:p","label":"proj"}]}'
  cd "$PROJ/src"
  run --separate-stderr rex-agent --name a1 -- -p hi
  [ "$status" -eq 0 ]
  grep -qx "window new -s session:p agent:a1 --cwd $PROJ/src --focus=true --keep-open --json -- claude -p hi" "$REX_LOG"
  [ "$(jq -r .session_id <<< "$output")" = "session:p" ]
  [ "$(jq -r .window_id <<< "$output")" = "window:w1" ]
  [ "$(jq -r .block_id <<< "$output")" = "block:b1" ]
  [ "$(jq -r .name <<< "$output")" = "a1" ]
}

@test "two agents in one directory get two windows" {
  cd "$PROJ"
  rex-agent > /dev/null
  rex-agent > /dev/null
  [ "$(grep -c '^window new' "$REX_LOG")" -eq 2 ]
  [ "$(grep '^window new' "$REX_LOG" | awk '{print $5}' | sort -u | wc -l)" -eq 2 ]
}

@test "--no-focus and --close reach rex" {
  cd "$PROJ"
  rex-agent --no-focus --close > /dev/null
  line=$(grep '^window new' "$REX_LOG")
  [[ "$line" == *"--focus=false"* ]]
  [[ "$line" != *"--keep-open"* ]]
}

@test "--split anchors on the caller's pane" {
  cd "$PROJ"
  REX_SESSION=session:here REX_BLOCK=block:me run --separate-stderr rex-agent --split below --name s
  [ "$status" -eq 0 ]
  grep -q "^split -b block:me --split below --label agent:s --cwd $PROJ " "$REX_LOG"
  [ "$(jq -r .block_id <<< "$output")" = "block:s1" ]
  [ "$(jq -r .window_id <<< "$output")" = "window:host" ]
  [ "$(jq -r .session_id <<< "$output")" = "session:here" ]
}

@test "--split without REX_BLOCK fails" {
  cd "$PROJ"
  run rex-agent --split
  [ "$status" -eq 1 ]
  [[ "$output" == *"needs REX_BLOCK"* ]]
}

@test "--workspace refuses a repo without .jj" {
  cd "$PROJ"
  run rex-agent --workspace w
  [ "$status" -eq 1 ]
  [[ "$output" == *"needs a jj repo"* ]]
}

@test "--workspace reuses an existing workspace without jj" {
  mkdir -p "$PROJ/.jj" "$PROJ/.workspaces/w"
  cd "$PROJ"
  run --separate-stderr rex-agent --workspace w
  [ "$status" -eq 0 ]
  [ "$(jq -r .cwd <<< "$output")" = "$PROJ/.workspaces/w" ]
  grep -q -- "--cwd $PROJ/.workspaces/w " "$REX_LOG"
}

@test "without a Rex server claude runs in the foreground" {
  export FAKE_DOWN=1
  cd "$PROJ/src"
  run rex-agent -- --version
  [ "$status" -eq 0 ]
  [ "$output" = "claude in $PROJ/src: --version" ]
}

@test "unknown option exits 2" {
  run rex-agent --bogus
  [ "$status" -eq 2 ]
}

@test "live: an agent window runs claude and is capturable" {
  [ "${REX_LIVE:-}" = 1 ] || skip "set REX_LIVE=1 to drive a real Rex server"
  rm "$BIN/rex" "$BIN/claude"
  command -v rex > /dev/null || skip "rex not installed"
  live=$(cd "$BATS_TEST_TMPDIR" && pwd -P)/rexlive$$
  mkdir -p "$live/.git"
  cd "$live"
  out=$(rex-agent --name live --no-focus -- --version)
  sid=$(jq -r .session_id <<< "$out")
  bid=$(jq -r .block_id <<< "$out")
  sleep 3
  text=$(rex capture -s "$sid" -b "$bid")
  rex kill "$sid" > /dev/null
  [[ "$text" == *"Claude Code"* ]]
}
