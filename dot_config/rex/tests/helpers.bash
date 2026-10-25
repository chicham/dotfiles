# Fake rex/jj/direnv/fzf on PATH. Each records its argv to $CALLS and answers
# from $FIX (fixture dir) so the scripts run without a Rex server or a repo.

SCRIPTS_SRC="$BATS_TEST_DIRNAME/../scripts"

setup_fakes() {
  BIN="$BATS_TEST_TMPDIR/bin"
  FIX="$BATS_TEST_TMPDIR/fix"
  CALLS="$BATS_TEST_TMPDIR/calls"
  mkdir -p "$BIN" "$FIX"

  # The chezmoi source names the script executable_agent-new without an exec
  # bit; stage it as chezmoi deploys it so the tests run what ~/.config/rex gets.
  SCRIPTS="$BATS_TEST_TMPDIR/scripts"
  mkdir -p "$SCRIPTS"
  cp "$SCRIPTS_SRC/popup.bash" "$SCRIPTS/popup.bash"
  cp "$SCRIPTS_SRC/executable_agent-new" "$SCRIPTS/agent-new"
  chmod +x "$SCRIPTS/agent-new"
  : >"$CALLS"
  export FIX CALLS
  export PATH="$BIN:$PATH"

  cat >"$BIN/rex" <<'EOF'
#!/usr/bin/env bash
echo "rex $*" >>"$CALLS"
case "$1 $2" in
  "ls --json") cat "$FIX/sessions.json" ;;
  "block ls") cat "$FIX/blocks-$4.json" ;;
  "block call")
    # Blocks resolve only within a session, so -s must name the right one.
    [[ $3 == -s && $5 == -b ]] || exit 1
    f="$FIX/status-$6.json"
    [[ -f $f && $(cat "$FIX/session-of-$6" 2>/dev/null) == "$4" ]] && cat "$f" || exit 1 ;;
esac
EOF

  cat >"$BIN/jj" <<'EOF'
#!/usr/bin/env bash
echo "jj $*" >>"$CALLS"
if [[ $3 == root ]]; then
  [[ -f $FIX/jj-root ]] || { echo "Error: There is no jj repo" >&2; exit 1; }
  cat "$FIX/jj-root"
elif [[ $3 == workspace && $4 == add ]]; then
  mkdir -p "$5"
  [[ ! -f $FIX/pyproject ]] || touch "$5/pyproject.toml"
fi
EOF

  # Only recorded, so tests can assert agent-new leaves uv to direnv.
  cat >"$BIN/uv" <<'EOF'
#!/usr/bin/env bash
echo "uv $*" >>"$CALLS"
EOF

  cat >"$BIN/direnv" <<'EOF'
#!/usr/bin/env bash
# direnv exec DIR CMD...: record, then run CMD in the caller's cwd as direnv does.
echo "direnv $1 $2" >>"$CALLS"
shift 2
exec "$@"
EOF

  cat >"$BIN/fzf" <<'EOF'
#!/usr/bin/env bash
# Picks the line given by $FZF_PICK (1-based), or cancels when unset.
echo "fzf $*" >>"$CALLS"
# Prompt mode (--print-query, no items): print $FZF_QUERY, exit 1 like real
# fzf with no match; cancel when it is unset.
if [[ " $* " == *" --print-query "* ]]; then
  [[ -n ${FZF_QUERY+x} ]] || exit 130
  echo "$FZF_QUERY"
  exit 1
fi
[[ -n ${FZF_PICK:-} ]] || exit 130
sed -n "${FZF_PICK}p"
EOF

  chmod +x "$BIN"/*
}
