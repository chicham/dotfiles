#!/usr/bin/env bats
# __zoxide_cd_dominant_match (completions/cd.fish): when may Tab skip the
# picker and insert the top zoxide match directly?
# A stub `zoxide` prints $FAKE_ZOXIDE (the `query -l -s` output), so each
# case pins the scores instead of depending on the real database.

FISH_DIR=${FISH_DIR:-$(cd "$BATS_TEST_DIRNAME/../.." && pwd)}

setup() {
  bin=$(mktemp -d)
  cwd=$(mktemp -d)
  printf '#!/bin/sh\nprintf "%%s" "$FAKE_ZOXIDE"\n' >"$bin/zoxide"
  chmod +x "$bin/zoxide"
  export PATH="$bin:$PATH"
}

teardown() { rm -rf "$bin" "$cwd"; }

# $1 = token; prints the inserted path, exit 1 when the picker should open
match() {
  cd "$cwd"
  fish --no-config -c "source '$FISH_DIR/completions/cd.fish'; __zoxide_cd_dominant_match \$argv[1]" "$1"
}

@test "dominant full-word match jumps" {
  export FAKE_ZOXIDE=$' 84.5 /h/.local/share/chezmoi\n  0.8 /h/chezmoi-old/x\n'
  run match che
  [ "$status" -eq 0 ]
  [ "$output" = /h/.local/share/chezmoi ]
}

@test "match is case-insensitive on the basename" {
  export FAKE_ZOXIDE=$' 304.0 /h/Downloads\n   0.2 /h/x/download-cache\n'
  run match dow
  [ "$status" -eq 0 ]
  [ "$output" = /h/Downloads ]
}

@test "a word inside the basename counts as a start" {
  export FAKE_ZOXIDE=$' 23.5 /h/Work/demo_legal_rag\n  1.0 /h/legacy/x\n'
  run match leg
  [ "$status" -eq 0 ]
  [ "$output" = /h/Work/demo_legal_rag ]
}

@test "tokens under 3 characters open the picker" {
  export FAKE_ZOXIDE=$' 176.0 /h/Work/shared-task-spooler\n  1.0 /h/a\n'
  run match sh
  [ "$status" -eq 1 ]
}

@test "mid-word match opens the picker" {
  export FAKE_ZOXIDE=$' 23.2 /h/Work/task_tracker\n  1.5 /h/Work/keras-hub\n'
  run match ker
  [ "$status" -eq 1 ]
}

@test "a single mid-word match still opens the picker" {
  export FAKE_ZOXIDE=$' 50.0 /h/Work/task_tracker\n'
  run match ker
  [ "$status" -eq 1 ]
}

@test "ratio below 10x opens the picker" {
  export FAKE_ZOXIDE=$' 23.2 /h/Work/tracker\n  3.2 /h/Work/artitrack\n'
  run match tra
  [ "$status" -eq 1 ]
}

@test "score below 10 opens the picker" {
  export FAKE_ZOXIDE=$' 9.0 /h/Work/scripts\n 0.1 /h/x\n'
  run match scr
  [ "$status" -eq 1 ]
}

@test "a local directory with that prefix opens the picker" {
  mkdir "$cwd/Scripts"
  export FAKE_ZOXIDE=$' 500.0 /h/Work/scripts\n'
  run match scr
  [ "$status" -eq 1 ]
}

@test "path-like tokens open the picker" {
  export FAKE_ZOXIDE=$' 322.0 /h/.claude\n'
  for t in .cla '~/cla' 'cl/a' '$HOME'; do
    run match "$t"
    [ "$status" -eq 1 ]
  done
}

@test "regex metacharacters in the token are literal" {
  export FAKE_ZOXIDE=$' 40.0 /h/src/c++-tools\n'
  run match 'c++'
  [ "$status" -eq 0 ]
  [ "$output" = /h/src/c++-tools ]
  export FAKE_ZOXIDE=$' 40.0 /h/src/aac\n'
  run match 'a+c'
  [ "$status" -eq 1 ]
}

@test "no zoxide match opens the picker" {
  export FAKE_ZOXIDE=''
  run match zzz
  [ "$status" -eq 1 ]
}
