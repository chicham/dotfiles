#!/usr/bin/env bats

load helpers

# s1: a default-labelled tab whose focused pane b2 has a terminal title, and
# a tab the user renamed. s2: a default-labelled tab whose focused pane has an
# empty title, and one whose title call fails.
setup() {
  setup_fakes
  cat >"$FIX/sessions.json" <<'EOF'
{"sessions":[{"session_id":"s1","label":"alpha"},{"session_id":"s2","label":"beta"}]}
EOF
  cat >"$FIX/windows-s1.json" <<'EOF'
{"session_id":"s1","label":"alpha","windows":[
 {"window_id":"w1","label":"Window 0123abcd","focused_block_id":"b2","layers":[
   {"kind":"tiled","blocks":[{"block_id":"b1","label":"nvim"},{"block_id":"b2","label":"claude"}]}]},
 {"window_id":"w2","label":"logs","focused_block_id":"b4","layers":[
   {"kind":"tiled","blocks":[{"block_id":"b4","label":"tail"}]}]}]}
EOF
  cat >"$FIX/windows-s2.json" <<'EOF'
{"session_id":"s2","label":"beta","windows":[
 {"window_id":"w3","label":"Window 89abcdef","focused_block_id":"b5","layers":[
   {"kind":"tiled","blocks":[{"block_id":"b5","label":"shell"}]}]},
 {"window_id":"w4","label":"Window 01234567","focused_block_id":"b6","layers":[
   {"kind":"tiled","blocks":[{"block_id":"b6"}]}]}]}
EOF
  echo '{"title":"Fix login redirect"}' >"$FIX/title-b2.json"
  echo '{"title":"ignored"}' >"$FIX/title-b4.json"
  echo '{"title":""}' >"$FIX/title-b5.json"
}

@test "--list names tabs like the sidebar: own label, else focused pane's title, else its label" {
  run "$SCRIPTS/tab-pick" --list
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Fix login redirect" ]
  [ "${lines[1]}" = "logs" ]
  [ "${lines[2]}" = "shell" ]
  [ "${lines[3]}" = "-" ]
  [ "${#lines[@]}" -eq 4 ]
}

@test "titles are read from the focused pane in its own session" {
  run "$SCRIPTS/tab-pick" --list
  run cat "$CALLS"
  [[ "$output" == *"rex do -s s1 -b b2 com.superlogical.terminal.title"* ]]
  [[ "$output" != *"-b b4 "* ]]
}

@test "picking a tab asks the given app to show it" {
  FZF_PICK=3 run "$SCRIPTS/tab-pick" -C client:x
  [ "$status" -eq 0 ]
  run tail -1 "$CALLS"
  [ "$output" = "rex -C client:x do session.select session_id=s2 window_id=w3" ]
}

@test "a vanished client falls back to rex's own app choice" {
  FZF_PICK=2 run "$SCRIPTS/tab-pick" -C client:gone
  [ "$status" -eq 0 ]
  run tail -2 "$CALLS"
  [ "${lines[0]}" = "rex -C client:gone do session.select session_id=s1 window_id=w2" ]
  [ "${lines[1]}" = "rex do session.select session_id=s1 window_id=w2" ]
}

@test "fzf searches the names only, never the ids" {
  FZF_PICK=1 run "$SCRIPTS/tab-pick"
  [ "$status" -eq 0 ]
  run cat "$CALLS"
  [[ "$output" == *"--with-nth=3"* ]]
  run tail -1 "$CALLS"
  [ "$output" = "rex do session.select session_id=s1 window_id=w1" ]
}

@test "cancel exits 130 without switching" {
  run "$SCRIPTS/tab-pick" -C client:x
  [ "$status" -eq 130 ]
  run cat "$CALLS"
  [[ "$output" != *"session.select"* ]]
}

@test "--popup cancel does not pause for enter" {
  run bash -c "'$SCRIPTS/tab-pick' --popup 2>&1 </dev/null"
  [ "$status" -eq 130 ]
  [[ "$output" != *"Press enter"* ]]
  run cat "$CALLS"
  [[ "$output" == *"--border=rounded"* ]]
}

@test "--menu reads the lines from a file, deletes it, and asks rex nothing" {
  printf 's9\tw9\t● Ready-made\n' >"$BATS_TEST_TMPDIR/menu"
  FZF_PICK=1 run "$SCRIPTS/tab-pick" --menu "$BATS_TEST_TMPDIR/menu" -C client:x
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/menu" ]
  run cat "$CALLS"
  [[ "$output" != *"rex ls"* && "$output" != *"window ls"* ]]
  run tail -1 "$CALLS"
  [ "$output" = "rex -C client:x do session.select session_id=s9 window_id=w9" ]
}

@test "unknown flags are a usage error" {
  run "$SCRIPTS/tab-pick" --bogus
  [ "$status" -eq 2 ]
}
