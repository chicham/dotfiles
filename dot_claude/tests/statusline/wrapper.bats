#!/usr/bin/env bats
# statusline.sh: cship passthrough plus a prompt-cache segment on the last line.

setup() {
  WRAP="$HOME/.claude/statusline.sh"
  FIX="$BATS_TEST_DIRNAME/fixtures"
  export TZ=Europe/Paris # 1795198166 -> 19:09 local
  export TMPDIR="$BATS_TEST_TMPDIR"
  # Fixtures point at ~/.claude (itself a repo): use a non-repo cwd so only cship's output remains.
  mkdir -p "$BATS_TEST_TMPDIR/plain"
  for f in real cold nomiss null unobserved absent; do
    jq --arg d "$BATS_TEST_TMPDIR/plain" '.workspace.current_dir=$d | .cwd=$d | .context_window.total_input_tokens=0' "$FIX/$f.json" > "$BATS_TEST_TMPDIR/$f.json"
  done
  FIX="$BATS_TEST_TMPDIR"
}

mkrepo() { # jj repo with main two commits behind @
  export JJ_CONFIG="$BATS_TEST_TMPDIR/cfg.toml"
  printf '[user]\nname = "t"\nemail = "t@example.com"\n' > "$JJ_CONFIG"
  REPO="$BATS_TEST_TMPDIR/repo"
  jj git init "$REPO" > /dev/null 2>&1
  jj -R "$REPO" describe -m c1 > /dev/null 2>&1
  jj -R "$REPO" new -m c2 > /dev/null 2>&1
  jj -R "$REPO" new -m c3 > /dev/null 2>&1
  jj -R "$REPO" bookmark create main -r @-- > /dev/null 2>&1
  jq --arg d "$REPO" '.workspace.current_dir=$d' "$FIX/real.json" > "$BATS_TEST_TMPDIR/repo.json"
}

@test "jj repo cwd: jj line with +2 is printed first, mauve, then cship" {
  mkrepo
  run bash "$WRAP" < "$BATS_TEST_TMPDIR/repo.json"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == $'\e[38;2;203;166;247m'*" +2"*$'\e[0m' ]]
  [[ "$output" == *"cache ● 1h"* ]]
  [ "${#lines[@]}" -ge 2 ]
}

@test "non-repo cwd: no jj line and no empty line" {
  run bash "$WRAP" < "$FIX/real.json"
  [[ "${lines[0]}" != "" ]]
  [[ "${lines[0]}" != *$'\e[38;2;203;166;247m'* ]]
}

@test "jj line cache: second call is fast and returns the cached line" {
  mkrepo
  run bash "$WRAP" < "$BATS_TEST_TMPDIR/repo.json"
  first="${lines[0]}"
  [ -f "$BATS_TEST_TMPDIR/cc-statusline-jj-e4eea103-729b-430c-813e-7b621c7e3b7d" ]
  rm -rf "$REPO/.jj" # a recompute would now print no jj line
  s=$(perl -MTime::HiRes=time -e 'print time')
  run bash "$WRAP" < "$BATS_TEST_TMPDIR/repo.json"
  e=$(perl -MTime::HiRes=time -e 'print time')
  [ "${lines[0]}" = "$first" ]
  # cship itself is part of the wrapper, so allow headroom; the jj call alone costs more.
  perl -e 'exit(($ARGV[1]-$ARGV[0]) < 0.25 ? 0 : 1)' "$s" "$e"
}

@test "no session_id: no cache file written" {
  mkrepo
  jq 'del(.session_id)' "$BATS_TEST_TMPDIR/repo.json" > "$BATS_TEST_TMPDIR/nosid.json"
  run bash "$WRAP" < "$BATS_TEST_TMPDIR/nosid.json"
  [[ "${lines[0]}" == *"+2"* ]]
  [ -z "$(ls "$BATS_TEST_TMPDIR" | grep cc-statusline-jj)" ]
}

@test "real payload: warm segment with local clock time and miss text" {
  run bash "$WRAP" < "$FIX/real.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[38;2;148;226;213mcache ● 1h ⏲ 19:09\e[0m'* ]]
  [[ "$output" == *$'\e[38;2;250;179;135m· 2 miss (ttl_expired_1h)\e[0m' ]]
}

@test "cold: bold red with tokens to re-write in k" {
  run bash "$WRAP" < "$FIX/cold.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\e[1m\e[38;2;243;139;168mcache ○ cold +120k\e[0m'* ]]
}

@test "misses=0: no miss text" {
  run bash "$WRAP" < "$FIX/nomiss.json"
  [ "$status" -eq 0 ]
  [[ "$output" == *"cache ● 1h ⏲ 19:09"* ]]
  [[ "$output" != *miss* ]]
}

@test "caching_observed=false: output equals cship" {
  run bash "$WRAP" < "$FIX/unobserved.json"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cship < "$FIX/unobserved.json")" ]
}

@test "prompt_cache null: output equals cship exactly" {
  run bash "$WRAP" < "$FIX/null.json"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cship < "$FIX/null.json")" ]
}

@test "prompt_cache absent: output equals cship" {
  run bash "$WRAP" < "$FIX/absent.json"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cship < "$FIX/absent.json")" ]
}

@test "null field inside prompt_cache: output equals cship" {
  jq '.prompt_cache.expires_at=null' "$FIX/real.json" > "$BATS_TEST_TMPDIR/n.json"
  run bash "$WRAP" < "$BATS_TEST_TMPDIR/n.json"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cship < "$BATS_TEST_TMPDIR/n.json")" ]
}

@test "segment lands on the last line of multi-line cship output" {
  mkdir "$BATS_TEST_TMPDIR/bin"
  printf '#!/bin/sh\ncat >/dev/null\nprintf "line1\\nline2\\n"\n' > "$BATS_TEST_TMPDIR/bin/cship"
  chmod +x "$BATS_TEST_TMPDIR/bin/cship"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run bash "$WRAP" < "$FIX/real.json"
  [ "${lines[0]}" = "line1" ]
  [[ "${lines[1]}" == "line2 "*"cache ● 1h"* ]]
}

@test "jq absent: output equals cship, exit 0" {
  expected=$(cship < "$FIX/real.json")
  # PATH holds only bash, cat and cship: no jq.
  mkdir "$BATS_TEST_TMPDIR/nojq"
  for t in bash cat cship; do ln -s "$(command -v $t)" "$BATS_TEST_TMPDIR/nojq/$t"; done
  PATH="$BATS_TEST_TMPDIR/nojq" run /bin/bash "$WRAP" < "$FIX/real.json"
  [ "$status" -eq 0 ]
  [ "$output" = "$expected" ]
}

@test "garbage stdin: exit 0" {
  run bash "$WRAP" <<< 'not json'
  [ "$status" -eq 0 ]
}

# Growth segment: +Nk since the session's first non-zero context size.
grow_json() { jq --argjson t "$1" '.context_window.total_input_tokens=$t' "$FIX/real.json"; }
DIM=$'\e[38;2;147;153;178m'
YEL=$'\e[38;2;249;226;175m'
RED=$'\e[1m\e[38;2;243;139;168m'

@test "growth: dim below warn, yellow in warn, bold red in crit" {
  rm -f "$TMPDIR"/cc-statusline-start-*
  run bash "$WRAP" <<< "$(grow_json 70000)"
  [[ "$output" == *"${DIM}+0k"* ]]
  run bash "$WRAP" <<< "$(grow_json 130000)"
  [[ "$output" == *"${YEL}+60k"* ]]
  run bash "$WRAP" <<< "$(grow_json 170000)"
  [ "$status" -eq 0 ]
  [[ "$output" == *"${RED}+100k"* ]]
  [[ "$output" == *"cache ●"*"+100k"* ]]
}

@test "growth: omitted when total_input_tokens is 0 or absent" {
  rm -f "$TMPDIR"/cc-statusline-start-*
  run bash "$WRAP" <<< "$(grow_json 0)"
  [[ "$output" != *"+0k"* ]]
  [ ! -e "$TMPDIR/cc-statusline-start-e4eea103-729b-430c-813e-7b621c7e3b7d" ]
  run bash "$WRAP" <<< "$(jq 'del(.context_window.total_input_tokens)' "$FIX/real.json")"
  [ "$status" -eq 0 ]
  [[ "$output" != *$'\e[38;2;147;153;178m+'* ]]
}

@test "growth: start is kept across calls" {
  rm -f "$TMPDIR"/cc-statusline-start-*
  bash "$WRAP" <<< "$(grow_json 70000)" > /dev/null
  [ "$(cat "$TMPDIR/cc-statusline-start-e4eea103-729b-430c-813e-7b621c7e3b7d")" = 70000 ]
  run bash "$WRAP" <<< "$(grow_json 125000)"
  [[ "$output" == *"${YEL}+55k"* ]]
  [ "$(cat "$TMPDIR/cc-statusline-start-e4eea103-729b-430c-813e-7b621c7e3b7d")" = 70000 ]
}

# Context bar: used / auto-compaction window, at the start of cship's line.
bar_json() { jq --argjson t "$1" --argjson s "${2:-1000000}" --arg m "${3:-claude-opus-5-5}" \
  '.context_window.total_input_tokens=$t | .context_window.context_window_size=$s | .model.id=$m' "$FIX/real.json"; }
plain() { sed $'s/\e\\[[0-9;]*m//g'; }
mksettings() {
  printf '{"modelSettings":{"claude-opus-5-5":{"autoCompactWindow":300000}},"autoCompactWindow":200000}' > "$BATS_TEST_TMPDIR/settings.json"
  export CC_SETTINGS="$BATS_TEST_TMPDIR/settings.json"
  unset CLAUDE_CODE_AUTO_COMPACT_WINDOW
}

@test "bar: Opus override (300k) for claude-opus-5-5" {
  mksettings
  run bash "$WRAP" <<< "$(bar_json 150000)"
  [[ "$(plain <<< "$output")" == "󱞇 █████░░░░░ 50%  "* ]]
}

@test "bar: top-level 200k for other models" {
  mksettings
  run bash "$WRAP" <<< "$(bar_json 150000 1000000 claude-sonnet-5-5)"
  [[ "$(plain <<< "$output")" == "󱞇 ████████░░ 75%  "* ]]
}

@test "bar: env var override wins" {
  mksettings
  CLAUDE_CODE_AUTO_COMPACT_WINDOW=600000 run bash "$WRAP" <<< "$(bar_json 150000)"
  [[ "$(plain <<< "$output")" == "󱞇 ███░░░░░░░ 25%  "* ]]
  CLAUDE_CODE_AUTO_COMPACT_WINDOW=abc run bash "$WRAP" <<< "$(bar_json 150000)"
  [[ "$(plain <<< "$output")" == *" 50%  "* ]]
}

@test "bar: max capped at context_window_size" {
  mksettings
  run bash "$WRAP" <<< "$(bar_json 50000 100000)"
  [[ "$(plain <<< "$output")" == *" 50%  "* ]]
}

@test "bar: falls back to context_window_size without settings" {
  export CC_SETTINGS="$BATS_TEST_TMPDIR/missing.json"
  unset CLAUDE_CODE_AUTO_COMPACT_WINDOW
  run bash "$WRAP" <<< "$(bar_json 250000)"
  [[ "$(plain <<< "$output")" == *" 25%  "* ]]
}

@test "bar: colour by fill of the compaction window (teal <60%, yellow >=60%, bold red >=80%); omitted at 0 or absent" {
  mksettings
  rm -f "$TMPDIR"/cc-statusline-start-*
  # start at 170k so growth stays in the ok band: the colour must come from the fill alone
  run bash "$WRAP" <<< "$(bar_json 170000)"
  [[ "$output" == $'\e[38;2;148;226;213m󱞇 '* ]]
  run bash "$WRAP" <<< "$(bar_json 190000)"
  [[ "$output" == $'\e[38;2;249;226;175m󱞇 '* ]]
  run bash "$WRAP" <<< "$(bar_json 250000)"
  [[ "$output" == $'\e[1m\e[38;2;243;139;168m󱞇 '* ]]
  CTX_BAR_WARN_PCT=50 run bash "$WRAP" <<< "$(bar_json 160000)"
  [[ "$output" == $'\e[38;2;249;226;175m󱞇 '* ]]
  run bash "$WRAP" <<< "$(bar_json 0)"
  [[ "$output" != *"󱞇"* ]]
  run bash "$WRAP" <<< "$(jq 'del(.context_window.total_input_tokens)' "$FIX/real.json")"
  [[ "$output" != *"󱞇"* ]]
}

@test "bar: used_tokens text is gone from the line" {
  mksettings
  run bash "$WRAP" <<< "$(bar_json 236818)"
  [[ "$output" != *"236k"* && "$output" != *"236818"* && "$output" != *"/1000k"* ]]
}
