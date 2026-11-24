#!/usr/bin/env bash
# Regression suite for the megamerge workflow: the Claude Code guard
# (jj-megamerge-guard.fish), the mm_* revset aliases, and jj land/sync/deploy.
# Builds throwaway repos (a bare origin, a bare deploy, two workspaces) in a temp dir.
# Usage: ~/.config/fish/tests/jj-megamerge/run.sh   (exit 1 if any case fails)
set -u
here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# The chezmoi source names the scripts executable_<name>; the live tree has the plain name.
for f in setup cases flows; do
  src=$here/$f.sh
  [ -f "$src" ] || src=$here/executable_$f.sh
  cp "$src" "$work/$f.sh" || exit 1
done
# cases.sh runs $S/setup.sh directly; a source-tree copy may lack the exec bit.
chmod +x "$work"/setup.sh "$work"/cases.sh "$work"/flows.sh
status=0
for t in cases flows; do
  echo "### $t"
  out=$(bash "$work/$t.sh" "$work")
  printf '%s\n' "$out"
  grep -q '^pass=[0-9]* fail=0$' <<< "$out" || status=1
done
exit $status
