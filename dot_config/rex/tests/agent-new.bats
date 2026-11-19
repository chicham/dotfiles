#!/usr/bin/env bats

load helpers

setup() {
  setup_fakes
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/sub"
  echo "$REPO" > "$FIX/jj-root"
}

@test "creates the workspace off main and starts claude in a labelled tab, never uv" {
  touch "$FIX/pyproject"
  run "$SCRIPTS/agent-new" -r "$REPO/sub" fix-login
  [ "$status" -eq 0 ]
  run cat "$CALLS"
  [ "${lines[0]}" = "jj -R $REPO/sub root" ]
  [ "${lines[1]}" = "jj -R $REPO workspace add $REPO/.workspaces/fix-login --name fix-login -r main" ]
  [ "${lines[2]}" = "rex run --cwd $REPO/.workspaces/fix-login --label fix-login -- direnv exec $REPO/.workspaces/fix-login claude" ]
  [ "${#lines[@]}" -eq 3 ]
  [[ "$output" != *"uv "* ]]
}

@test "runs the command after -- instead of claude" {
  run "$SCRIPTS/agent-new" -r "$REPO" w1 -- codex --full-auto
  [ "$status" -eq 0 ]
  run tail -1 "$CALLS"
  [ "$output" = "rex run --cwd $REPO/.workspaces/w1 --label w1 -- direnv exec $REPO/.workspaces/w1 codex --full-auto" ]
}

@test "reads the name from stdin when omitted" {
  run bash -c "echo asked | '$SCRIPTS/agent-new' -r '$REPO'"
  [ "$status" -eq 0 ]
  run tail -1 "$CALLS"
  [ "$output" = "rex run --cwd $REPO/.workspaces/asked --label asked -- direnv exec $REPO/.workspaces/asked claude" ]
}

@test "rejects invalid names before creating anything" {
  for bad in "" "Upper" "-dash" "a/b" "a b" "../x"; do
    : > "$CALLS"
    run "$SCRIPTS/agent-new" -r "$REPO" -- claude <<< "$bad"
    [ "$status" -eq 2 ]
    run cat "$CALLS"
    [[ "$output" != *"workspace add"* ]]
    [[ "$output" != *"rex run"* ]]
  done
}

@test "fails without side effects when the workspace already exists" {
  mkdir -p "$REPO/.workspaces/taken"
  run "$SCRIPTS/agent-new" -r "$REPO" taken
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
  run cat "$CALLS"
  [[ "$output" != *"workspace add"* ]]
}

@test "fails outside a jj repo" {
  rm "$FIX/jj-root"
  run "$SCRIPTS/agent-new" -r "$BATS_TEST_TMPDIR" x
  [ "$status" -eq 1 ]
  [[ "$output" == *"not inside a jj repo"* ]]
}

@test "unknown flags are a usage error" {
  run "$SCRIPTS/agent-new" --bogus
  [ "$status" -eq 2 ]
}

@test "without direnv, runs the agent directly" {
  rm "$BIN/direnv"
  for t in bash cat mkdir touch; do [ -e "$BIN/$t" ] || ln -s "$(command -v "$t")" "$BIN/$t"; done
  PATH="$BIN" run "$SCRIPTS/agent-new" -r "$REPO" bare
  [ "$status" -eq 0 ]
  run tail -1 "$CALLS"
  [ "$output" = "rex run --cwd $REPO/.workspaces/bare --label bare -- claude" ]
}

@test "--popup asks for the name in a bordered fzf box" {
  FZF_QUERY=boxed run "$SCRIPTS/agent-new" --popup -r "$REPO"
  [ "$status" -eq 0 ]
  run cat "$CALLS"
  [[ "$output" == *"--border=rounded"* ]]
  [[ "$output" == *"--border-label= new agent in repo: workspace name "* ]]
  [[ "$output" == *"workspace add $REPO/.workspaces/boxed --name boxed"* ]]
}

@test "--popup cancel exits 130 without creating anything or pausing" {
  run bash -c "'$SCRIPTS/agent-new' --popup -r '$REPO' 2>&1 </dev/null"
  [ "$status" -eq 130 ]
  [[ "$output" != *"Press enter"* ]]
  run cat "$CALLS"
  [[ "$output" != *"workspace add"* ]]
}

@test "--popup with an empty name is rejected" {
  FZF_QUERY= run bash -c "'$SCRIPTS/agent-new' --popup -r '$REPO' 2>&1 <<<''"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Press enter"* ]]
}
