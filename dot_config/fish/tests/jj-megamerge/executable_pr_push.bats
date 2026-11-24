#!/usr/bin/env bats
# `pr-push`: refuses the bookmarks main and wip before any jj call, so nothing is moved or pushed.
# jj is a fish function stub (a PATH stub loses to fish's own PATH order) that records its calls: no repo, no network, no real push.
# Usage: bats ~/.config/fish/tests/jj-megamerge/pr_push.bats

setup() {
  here=$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)
  FUNCS=$(cd "$here/../../functions" && pwd)
  command -v fish > /dev/null || skip "fish not available"
  T=$BATS_TEST_TMPDIR
  : > "$T/calls"
}

pp() {
  fish -c "set fish_function_path $FUNCS \$fish_function_path; function jj; echo \$argv >> $T/calls; end; pr-push $*" 2>&1
}

@test "pr-push main and wip are refused, nonzero, with no jj call" {
  for name in main wip; do
    run pp "$name"
    [ "$status" -ne 0 ]
    [[ "$output" == *"refusing"* ]]
  done
  [ ! -s "$T/calls" ]
}

@test "pr-push of another name still sets the bookmark and pushes it" {
  run pp feature-x
  [ "$status" -eq 0 ]
  rg -q 'bookmark set feature-x' "$T/calls"
  rg -q 'git push --remote origin -b feature-x' "$T/calls"
}

@test "pr-push without a name still prints the usage" {
  run pp
  [ "$status" -ne 0 ]
  [[ "$output" == *"usage"* ]]
  [ ! -s "$T/calls" ]
}
