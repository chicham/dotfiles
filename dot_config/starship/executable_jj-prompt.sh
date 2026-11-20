#!/bin/sh
# Prompt segment for a jj repo, called by [custom.jj] in starship.toml. Prints nothing outside a
# repo or on any jj failure. --ignore-working-copy everywhere: no snapshot, no new jj operation,
# so a prompt render never mutates the repo (which is also why there is no "dirty" marker).

root=$PWD
while [ -n "$root" ] && [ ! -d "$root/.jj" ]; do root=${root%/*}; done
[ -n "$root" ] || exit 0

# Delimited fields in one call; `|` cannot occur in a change id or a bookmark name.
info=$(jj -R "$root" log -r @ --no-graph --ignore-working-copy -T \
  'change_id.shortest() ++ "|" ++ conflict ++ "|" ++ empty ++ "|" ++ if(description, "d", "n") ++ "|" ++ local_bookmarks.join(",") ++ "|" ++ working_copies' \
  2> /dev/null) || exit 0
[ -n "$info" ] || exit 0
cid=${info%%|*}
rest=${info#*|}
conflict=${rest%%|*}
rest=${rest#*|}
empty=${rest%%|*}
rest=${rest#*|}
hasdesc=${rest%%|*}
rest=${rest#*|}
bk=${rest%%|*}
wc=${rest#*|}

# Workspace name: the .workspaces/<name> path convention first, then the working-copy label
# (`name@`) jj itself reports; the default workspace is not worth a glyph.
ws=""
case "$root" in
  */.workspaces/*)
    ws=${root##*/.workspaces/}
    ws=${ws%%/*}
    ;;
  *)
    ws=${wc%%@*}
    ws=${ws%% *}
    ;;
esac
[ "$ws" = "default" ] && ws=""

# Commits ahead of main cost a second jj call, so only the Claude Code status line asks for it
# (--ahead or JJ_PROMPT_AHEAD=1); the shell prompt stays at one call. A repo without a `main`
# bookmark makes the revset fail, so no +N.
ahead=""
if [ "$1" = "--ahead" ] || [ "$JJ_PROMPT_AHEAD" = "1" ]; then
  n=$(jj -R "$root" log -r 'main..@' --no-graph --ignore-working-copy -T '"x"' 2> /dev/null) && {
    n=${#n}
    [ "$n" -gt 0 ] && ahead=" +$n"
  }
fi

out=""
[ -n "$ws" ] && out="⎇ $ws "
if [ "$conflict" = "true" ]; then
  out="${out}✖ "
elif [ "$empty" = "true" ]; then
  out="${out}○ "
else out="${out}● "; fi
out="${out}${cid}${ahead}"
[ "$hasdesc" = "n" ] && out="$out ✎"
[ -n "$bk" ] && out="$out $bk"
echo "$out"
