#!/usr/bin/env bats
# Tab picker preview: _fuzzy_complete_kind picks the kind of candidate,
# _fuzzy_complete_preview renders it, with fallbacks for missing tools.

FISH_DIR=${FISH_DIR:-$(cd "$BATS_TEST_DIRNAME/../.." && pwd)}
FISH=$(command -v fish)

setup() {
  tmp=$(mktemp -d)
  printf 'hello preview\n' >"$tmp/note.txt"
  printf '\x00\x01\x02binary' >"$tmp/blob.bin"
  # 1x1 PNG
  printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N\x00\x00\x00\x00IEND\xaeB`\x82' >"$tmp/dot.png"
  mkdir "$tmp/sub"
}

teardown() { rm -rf "$tmp"; }

# $1 = FC_PREFIX, $2 = fish code; PATH can be narrowed by the caller
in_fish() {
  "$FISH" --no-config -c "set -p fish_function_path '$FISH_DIR/functions'; set -x FC_PREFIX \$argv[1]; $2" "$1"
}

kind() { in_fish "$1" "_fuzzy_complete_kind '$2' \$FC_PREFIX"; }

@test "kind: options, dirs and files" {
  [ "$(kind 'ls ' -l)" = option ]
  [ "$(kind 'ls ' "$tmp/sub")" = dir ]
  [ "$(kind 'cat ' "$tmp/note.txt")" = file ]
}

@test "kind: ~ and \$VAR prefixes are expanded before testing paths" {
  [ "$(HOME=$tmp kind 'cat ' '~/note.txt')" = file ]
  [ "$(HOME=$tmp kind 'ls ' '$HOME/sub')" = dir ]
}

@test "kind: a subcommand sharing a command's name is text" {
  [ "$(kind 'git ' diff)" = text ]
  [ "$(kind 'sudo ' cat)" = command ]
}

@test "option preview reads the man entry of the option itself" {
  run in_fish 'ls ' '_fuzzy_complete_preview -l'
  [[ "${lines[0]}" =~ ^[[:space:]]*-l ]]
  [[ "$output" == *"long format"* ]]
}

@test "option preview prefers the subcommand page" {
  command -v git || skip "git not installed"
  run in_fish 'git commit ' '_fuzzy_complete_preview --amend'
  [[ "$output" == *"--amend"* ]]
  [[ "$output" == *"tip of the current branch"* ]]
}

@test "description is shown first, without its ANSI codes" {
  run "$FISH" --no-config -c "set -p fish_function_path '$FISH_DIR/functions'; set -x FC_PREFIX 'git '; _fuzzy_complete_preview diff \$argv[1]" $'\e[2mShow changes\e[0m'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Show changes"* ]]
  [[ "$output" != *"[2m"* ]]
}

@test "text files are shown" {
  run in_fish 'cat ' "_fuzzy_complete_preview '$tmp/note.txt'"
  [[ "$output" == *"hello preview"* ]]
}

@test "directories are listed" {
  touch "$tmp/sub/inner"
  run in_fish 'ls ' "_fuzzy_complete_preview '$tmp/sub'"
  [[ "$output" == *inner* ]]
}

@test "binaries fall back to xxd without hexyl" {
  run env PATH=/usr/bin:/bin "$FISH" --no-config -c "set -p fish_function_path '$FISH_DIR/functions'; _fuzzy_complete_preview '$tmp/blob.bin'"
  [[ "$output" == *"00000000:"* ]]
}

@test "images fall back to the file summary without chafa" {
  run env PATH=/usr/bin:/bin "$FISH" --no-config -c "set -p fish_function_path '$FISH_DIR/functions'; _fuzzy_complete_preview '$tmp/dot.png'"
  [[ "$output" == *"PNG image"* ]]
}

@test "images render through chafa when installed" {
  command -v chafa || skip "chafa not installed"
  run in_fish 'open ' "_fuzzy_complete_preview '$tmp/dot.png'"
  [ "$status" -eq 0 ]
  [[ "$output" != *"PNG image"* ]]
  [[ "$output" != *$'\e[?25l'* ]]
}
