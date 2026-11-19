# Sourced by the agent-* scripts for --popup, when they run in a Rex floating
# layer. Rex leaves cells a program does not paint transparent in floating
# layers and draws no frame around them, so the popup paints its own
# background and fzf draws the border. REX_POPUP_BG (#rrggbb) overrides the
# colour.
POPUP_BG=${REX_POPUP_BG:-#1e1e2e}
POPUP_FZF_OPTS=(--color="bg:$POPUP_BG" --border=rounded --padding=0,1)

# Set POPUP_BG as the current background and clear the screen with it; output
# printed afterwards keeps that background.
popup_paint() {
  local hex=${POPUP_BG#\#}
  printf '\e[48;2;%d;%d;%dm\e[2J\e[H' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# popup_prompt LABEL: ask for one line of text in a bordered fzf box titled
# LABEL and print it. Returns 130 when cancelled with Esc or Ctrl-C.
popup_prompt() {
  local out rc=0
  # No items, so fzf exits 1 ("no match") on Enter; the query is still printed.
  out=$(fzf "${POPUP_FZF_OPTS[@]}" --border-label=" $1 " --print-query \
    --disabled --no-info --prompt='> ' < /dev/null) || rc=$?
  ((rc == 0 || rc == 1)) || return 130
  printf '%s\n' "${out%%$'\n'*}"
}
