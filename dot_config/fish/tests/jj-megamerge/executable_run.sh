#!/usr/bin/env bash
# Regression suite for the megamerge workflow: the Claude Code guard
# (jj-megamerge-guard.fish), the mm_* revset aliases, and jj land/sync/deploy.
# Builds throwaway repos (a bare origin, a bare deploy, two workspaces) in a temp dir.
# Usage: ~/.config/fish/tests/jj-megamerge/run.sh   (exit 1 if any case fails)
set -u
here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$here"/setup.sh "$here"/cases.sh "$here"/flows.sh "$work"/
status=0
for t in cases flows; do
  echo "### $t"
  out=$(bash "$work/$t.sh" "$work")
  printf '%s\n' "$out"
  grep -q '^pass=[0-9]* fail=0$' <<<"$out" || status=1
done
exit $status
