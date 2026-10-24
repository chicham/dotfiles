#!/usr/bin/env bats
# rex-attach and direnv's use_rex against a fake `rex`. Each pane's foreground
# program and cwd come from files under $FAKE, so every decision rex-attach
# makes is driven from the test. The last test drives a real server and runs
# only with REX_LIVE=1.

bats_require_minimum_version 1.5.0

setup() {
  load 'helpers/setup'
  command -v jq > /dev/null 2>&1 || skip "jq not available"
  BIN="$BATS_TEST_TMPDIR/bin"
  export FAKE="$BATS_TEST_TMPDIR/fake" REX_LOG="$BATS_TEST_TMPDIR/rex.log"
  mkdir -p "$BIN" "$FAKE"
  for s in session attach; do
    cp "$REPO_ROOT/dot_local/bin/executable_rex-$s" "$BIN/rex-$s"
  done
  cat > "$BIN/rex" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$REX_LOG"
[ "$1" = -C ] && shift 2
case "$1 ${2:-}" in
  "ls --json") cat "$FAKE/sessions.json" ;;
  "new "*) echo '{"session_id":"session:proj"}' ;;
  "window ls") cat "$FAKE/windows.json" ;;
  "window new") echo '{"window_id":"window:new","block_ids":["block:new"]}' ;;
  "client ls") cat "$FAKE/clients.json" ;;
  "do "*) [ -z "${FAKE_DO_FAIL:-}" ] || { echo "Error: not accepting actions" >&2; exit 1; } ;;
  "block call")
    b=$6
    case "$7" in
      process) printf '{"foreground":{"name":"%s"}}\n' "$(cat "$FAKE/$b.fg")" ;;
      pwd) printf '{"pwd":"file://host%s"}\n' "$(cat "$FAKE/$b.pwd")" ;;
    esac ;;
esac
EOF
  chmod +x "$BIN"/*
  export PATH="$BIN:$PATH" TMPDIR="$BATS_TEST_TMPDIR"
  PROJ=$(cd "$BATS_TEST_TMPDIR" && pwd -P)/proj
  mkdir -p "$PROJ/.git" "$PROJ/sub dir"
  export REX_SESSION=session:home REX_BLOCK=block:me
  echo '{"sessions":[{"session_id":"session:home","label":"home"},{"session_id":"session:proj","label":"proj"}]}' > "$FAKE/sessions.json"
  echo '{"clients":[{"client_id":"client:cli","info":{"kind":"cli"}},{"client_id":"client:app","info":{"kind":"app"}}]}' > "$FAKE/clients.json"
  echo '{"windows":[]}' > "$FAKE/windows.json"
  pane block:me fish "$PROJ"
}

# pane BLOCK FOREGROUND CWD — the fake state of one pane.
pane() {
  printf '%s' "$2" > "$FAKE/$1.fg"
  printf '%s' "$3" | sed 's/ /%20/g' > "$FAKE/$1.pwd"
}

# window ID LABEL BLOCK... — append a window to the project's session.
window() {
  local id=$1 label=$2
  shift 2
  jq --arg w "$id" --arg l "$label" --argjson b "$(printf '%s\n' "$@" | jq -R . | jq -sc .)" \
    '.windows += [{window_id: $w, label: $l, layers: [{blocks: [$b[] | {block_id: .}]}]}]' \
    "$FAKE/windows.json" > "$FAKE/w.tmp" && mv "$FAKE/w.tmp" "$FAKE/windows.json"
}

@test "rex-attach passes shellcheck" {
  command -v shellcheck > /dev/null 2>&1 || skip "shellcheck not available"
  shellcheck -S warning "$BIN/rex-attach"
}

@test "outside Rex it does nothing" {
  unset REX_BLOCK
  run rex-attach "$PROJ"
  [ "$status" -eq 0 ]
  [ ! -s "$REX_LOG" ]
}

@test "a pane running a program is never moved" {
  pane block:me claude "$PROJ"
  run rex-attach "$PROJ"
  [ "$status" -eq 0 ]
  ! grep -qE '^(window new|block close)' "$REX_LOG"
}

@test "a pane already in the project's session stays" {
  REX_SESSION=session:proj run rex-attach "$PROJ"
  [ "$status" -eq 0 ]
  ! grep -qE '^(window new|block close)' "$REX_LOG"
}

@test "opens a window at the pane's cwd, switches the app, closes the pane" {
  pane block:me fish "$PROJ/sub dir"
  run rex-attach "$PROJ"
  [ "$status" -eq 0 ]
  grep -qx "window new -s session:proj --cwd $PROJ/sub dir --json" "$REX_LOG"
  grep -qxF -- "-C client:app do session.select session_id=session:proj window_id=window:new" "$REX_LOG"
  [ "$(tail -n 1 "$REX_LOG")" = "block close -s session:home block:me" ]
}

@test "the hook's own direnv foreground counts as a shell" {
  pane block:me direnv "$PROJ"
  run rex-attach "$PROJ"
  grep -q '^block close' "$REX_LOG"
}

@test "reuses an idle shell window already at that directory" {
  pane block:b2 fish "$PROJ"
  window window:w2 proj block:b2
  run rex-attach "$PROJ"
  ! grep -q '^window new' "$REX_LOG"
  grep -q "window_id=window:w2" "$REX_LOG"
}

@test "never reuses agent windows, busy shells or split windows" {
  pane block:a fish "$PROJ"
  window window:agent agent:x block:a
  pane block:busy nvim "$PROJ"
  window window:busy proj block:busy
  pane block:s1 fish "$PROJ"
  pane block:s2 fish "$PROJ"
  window window:split proj block:s1 block:s2
  run rex-attach "$PROJ"
  grep -q '^window new' "$REX_LOG"
  grep -q "window_id=window:new" "$REX_LOG"
}

@test "creates the project session when missing" {
  echo '{"sessions":[{"session_id":"session:home","label":"home"}]}' > "$FAKE/sessions.json"
  run rex-attach "$PROJ"
  grep -qx "new proj --cwd $PROJ --json" "$REX_LOG"
  grep -q '^block close' "$REX_LOG"
}

@test "keeps the pane and hints when the app refuses actions" {
  export FAKE_DO_FAIL=1
  run --separate-stderr rex-attach "$PROJ"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"turn on Remote Control"* ]]
  ! grep -q '^block close' "$REX_LOG"
}

@test "keeps the pane when no app is connected" {
  echo '{"clients":[{"client_id":"client:cli","info":{"kind":"cli"}}]}' > "$FAKE/clients.json"
  run rex-attach "$PROJ"
  [ "$status" -eq 0 ]
  ! grep -qE '^(-C|block close)' "$REX_LOG"
}

@test "use_rex calls rex-attach with the .envrc directory" {
  command -v direnv > /dev/null 2>&1 || skip "direnv not available"
  cat > "$BIN/rex-attach" <<'EOF'
#!/bin/sh
echo "attach $1" >> "$REX_LOG"
EOF
  export DIRENV_CONFIG="$BATS_TEST_TMPDIR/direnv" XDG_DATA_HOME="$BATS_TEST_TMPDIR/data"
  mkdir -p "$DIRENV_CONFIG/lib"
  cp "$REPO_ROOT/dot_config/direnv/lib/rex.sh" "$DIRENV_CONFIG/lib/"
  echo 'use rex' > "$PROJ/.envrc"
  direnv allow "$PROJ"
  cd "$PROJ/sub dir"
  direnv exec . true
  grep -qx "attach $PROJ" "$REX_LOG"
}

@test "live: a shell pane cd-ing into a project moves to its session" {
  [ "${REX_LIVE:-}" = 1 ] || skip "set REX_LIVE=1 to drive a real Rex server"
  rm "$BIN/rex"
  command -v rex > /dev/null && command -v direnv > /dev/null || skip "rex or direnv missing"
  live=$(cd "$BATS_TEST_TMPDIR" && pwd -P)
  name=rexlive$$
  mkdir -p "$live/$name/.git" "$live/dcfg/lib"
  cp "$REPO_ROOT/dot_config/direnv/lib/rex.sh" "$live/dcfg/lib/"
  echo 'use rex' > "$live/$name/.envrc"
  DIRENV_CONFIG="$live/dcfg" direnv allow "$live/$name"
  src=$(rex new "src$$" --cwd "$live" --json)
  sid=$(jq -r .session_id <<< "$src")
  bid=$(jq -r '.initial_windows[0].block_ids[0]' <<< "$src")
  sleep 2
  rex send -s "$sid" -b "$bid" "set -x DIRENV_CONFIG $live/dcfg; set -x PATH $BIN \$PATH; cd $live/$name
"
  sleep 5
  target=$(rex ls --json | jq -r --arg l "$name" '.sessions[] | select(.label == $l) | .session_id')
  src_left=$(rex block ls -s "$sid" 2> /dev/null | grep -c "${bid: -6}" || true)
  [ -n "$target" ] && rex kill "$target" > /dev/null
  rex kill "$sid" > /dev/null 2>&1 || true
  [ -n "$target" ]
  [ "$src_left" -eq 0 ]
}
