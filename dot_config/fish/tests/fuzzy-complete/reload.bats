#!/usr/bin/env bats
# The picker's live reload runs `fish --no-config` with the parent's search
# paths (fuzzy_complete: FC_FUNCTION_PATH / FC_COMPLETE_PATH). It must list
# the same candidates as a fully configured fish.

FISH_DIR=${FISH_DIR:-$(cd "$BATS_TEST_DIRNAME/../.." && pwd)}

setup() {
  export FC_FUNCTION_PATH FC_COMPLETE_PATH
  FC_FUNCTION_PATH=$(fish -c "set -p fish_function_path '$FISH_DIR/functions'; string join : \$fish_function_path")
  FC_COMPLETE_PATH=$(fish -c "set -p fish_complete_path '$FISH_DIR/completions'; string join : \$fish_complete_path")
}

full() {
  fish -c "set -p fish_function_path '$FISH_DIR/functions'; set -p fish_complete_path '$FISH_DIR/completions'; _fuzzy_complete_render \$argv[1]" "$1"
}

bare() {
  fish --no-config -c 'set fish_function_path $FC_FUNCTION_PATH; set fish_complete_path $FC_COMPLETE_PATH; _fuzzy_complete_render $argv[1]' "$1"
}

@test "bare reload lists the same candidates as a configured fish" {
  cd "$HOME"
  for line in 'git ch' 'jj ' 'bat --th' 'brew inst' 'jq --a' 'ls D'; do
    expected=$(full "$line")
    [ -n "$expected" ]
    [ "$(bare "$line")" = "$expected" ] || { echo "differs: $line"; return 1; }
  done
}
