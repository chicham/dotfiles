#!/usr/bin/env bats
# jj-prompt.sh: the segment behind [custom.jj] in starship.toml.

setup() {
  P="$HOME/.config/starship/jj-prompt.sh"
  T=$(mktemp -d)
  # Isolated config: the user's makes main immutable, which would hide the N=0 case.
  printf '[user]\nname = "t"\nemail = "t@example.com"\n' > "$T/cfg.toml"
  export JJ_CONFIG="$T/cfg.toml"
  R="$T/repo"
  jj git init "$R" > /dev/null 2>&1
}

teardown() { rm -rf "$T"; }

prompt() { (cd "$1" && sh "$P" "${@:2}"); }

@test "default workspace, described change with content" {
  echo x > "$R/f"
  jj -R "$R" describe -m hi > /dev/null 2>&1
  run prompt "$R"
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^●\ [a-z]+$ ]]
}

@test "empty change shows the empty marker" {
  jj -R "$R" describe -m hi > /dev/null 2>&1
  run prompt "$R"
  [[ "$output" =~ ^○\ [a-z]+$ ]]
}

@test "no description shows the pencil marker" {
  echo x > "$R/f"
  jj -R "$R" status > /dev/null 2>&1 # snapshot so the change is non-empty
  run prompt "$R"
  [[ "$output" =~ ^●\ [a-z]+\ ✎$ ]]
}

@test "new empty undescribed change shows both markers" {
  run prompt "$R"
  [[ "$output" =~ ^○\ [a-z]+\ ✎$ ]]
}

@test "workspace under .workspaces/ shows its name" {
  jj -R "$R" describe -m hi > /dev/null 2>&1
  mkdir -p "$R/.workspaces"
  jj -R "$R" workspace add "$T/repo/.workspaces/arm1" > /dev/null 2>&1
  run prompt "$T/repo/.workspaces/arm1"
  [[ "$output" == "⎇ arm1 "* ]]
  run prompt "$R"
  [[ "$output" != *⎇* ]]
}

@test "workspace elsewhere falls back to the jj working-copy name" {
  jj -R "$R" workspace add "$T/other" --name side > /dev/null 2>&1
  run prompt "$T/other"
  [[ "$output" == "⎇ side "* ]]
}

@test "main two commits behind @ shows +2" {
  # main is created last: the user's config makes it immutable, which would add commits.
  jj -R "$R" describe -m c1 > /dev/null 2>&1
  jj -R "$R" new -m c2 > /dev/null 2>&1
  jj -R "$R" new -m c3 > /dev/null 2>&1
  jj -R "$R" bookmark create main -r @-- > /dev/null 2>&1
  run prompt "$R" --ahead
  [[ "$output" == *" +2"* ]]
  run prompt "$R"
  [[ "$output" != *+* ]]
  JJ_PROMPT_AHEAD=1 run prompt "$R"
  [[ "$output" == *" +2"* ]]
}

@test "main at @ shows no +N" {
  jj -R "$R" describe -m c1 > /dev/null 2>&1
  jj -R "$R" bookmark create main -r @ > /dev/null 2>&1
  run prompt "$R" --ahead
  [[ "$output" != *+* ]]
  [[ "$output" == *main ]]
}

@test "repo without main shows no +N" {
  jj -R "$R" describe -m c1 > /dev/null 2>&1
  jj -R "$R" new -m c2 > /dev/null 2>&1
  run prompt "$R" --ahead
  [[ "$output" != *+* ]]
}

@test "subdirectory of a repo works" {
  mkdir "$R/sub"
  run prompt "$R/sub"
  [[ "$output" =~ ^○ ]]
}

@test "non-repo directory prints nothing" {
  mkdir "$T/plain"
  run prompt "$T/plain"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "prompt does not create a jj operation" {
  before=$(jj -R "$R" op log --ignore-working-copy --no-graph -T 'id.short()' 2> /dev/null | wc -l)
  prompt "$R" > /dev/null
  after=$(jj -R "$R" op log --ignore-working-copy --no-graph -T 'id.short()' 2> /dev/null | wc -l)
  [ "$before" -eq "$after" ]
}

@test "starship module custom.jj renders the script output" {
  jj -R "$R" describe -m hi > /dev/null 2>&1
  cd "$R"
  run env STARSHIP_CONFIG="$HOME/.config/starship.toml" starship module custom.jj
  [[ "$output" == *○* ]]
}
