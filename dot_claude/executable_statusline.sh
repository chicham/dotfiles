#!/usr/bin/env bash
# Claude Code statusLine wrapper around cship.
# Contract: reads the statusline JSON on stdin, prints cship's output for it, always exits 0, so a
# failure in any extra segment can never blank the status line.
# Capture: while ~/.claude/statusline.dump-on exists, the last payload is written to
# ~/.claude/statusline-payload.json (used to build tests from real data).

in=$(cat)

if [[ -e "$HOME/.claude/statusline.dump-on" ]]; then
  printf '%s' "$in" > "$HOME/.claude/statusline-payload.json" 2> /dev/null
fi

# jj line (first line): the prompt segment with +N ahead of main, run in the session's directory.
# Cached 5 s per session so a refresh burst costs one jj call; any failure leaves it empty.
jjline=""
if command -v jq > /dev/null 2>&1; then
  sid=$(printf '%s' "$in" | jq -r '.session_id // empty' 2> /dev/null)
  cache=""
  [[ "$sid" =~ ^[A-Za-z0-9_-]+$ ]] && cache="${TMPDIR:-/tmp}/cc-statusline-jj-$sid"
  now=$(date +%s)
  if [[ -n "$cache" && -f "$cache" ]] && mt=$(stat -f %m "$cache" 2> /dev/null || stat -c %Y "$cache" 2> /dev/null) \
    && ((now - mt < 5)); then
    jjline=$(< "$cache")
  else
    dir=$(printf '%s' "$in" | jq -r '.workspace.current_dir // .cwd // empty' 2> /dev/null)
    if [[ -n "$dir" && -d "$dir" ]]; then
      raw=$(cd "$dir" 2> /dev/null && sh "$HOME/.config/starship/jj-prompt.sh" --ahead 2> /dev/null)
      [[ -n "$raw" ]] && jjline=$'\e[38;2;203;166;247m'"$raw"$'\e[0m'
    fi
    # An empty result is cached too, so a non-repo directory is not re-probed every refresh.
    [[ -n "$cache" ]] && printf '%s' "$jjline" > "$cache" 2> /dev/null
  fi
fi

# The sentinel keeps cship's trailing newline through the command substitution.
out=$(
  printf '%s' "$in" | cship 2> /dev/null
  printf x
)
out=${out%x}

# Cache segment: one jq call, empty output whenever anything is missing, so cship's output
# passes through unchanged. Clock time (not a countdown) because the line is not refreshed
# every second. Colours are Catppuccin Mocha as 24-bit ANSI.
seg=""
if command -v jq > /dev/null 2>&1; then
  seg=$(printf '%s' "$in" | jq -r '
    def c($r;$g;$b): "\u001b[38;2;\($r);\($g);\($b)m";
    def rst: "\u001b[0m";
    .prompt_cache as $p
    | if ($p|type) != "object" or $p.caching_observed != true or ($p.warm|type) != "boolean"
         or ($p.misses|type) != "number" then empty
      else
        ( if $p.warm then
            if ($p.expires_at|type) == "number"
            then c(148;226;213) + "● \($p.expires_at|strflocaltime("%H:%M"))" + rst
            else empty end
          else
            if ($p.recache_tokens_if_cold|type) == "number"
            then "\u001b[1m" + c(243;139;168) + "○ cold +\(($p.recache_tokens_if_cold/1000|round))k" + rst
            else empty end
          end ) as $base
        | ( if $p.misses > 0 and (($p.last_miss_cause.causes[0]) | type) == "string"
            then " " + c(250;179;135) + "· \($p.misses) miss (\($p.last_miss_cause.causes[0]))" + rst
            else "" end ) as $miss
        | $base + $miss
      end' 2> /dev/null) || seg=""
fi

# Context reads, one jq call: used tokens and the bar's maximum, tab-separated.
# Maximum = the auto-compaction window (env CLAUDE_CODE_AUTO_COMPACT_WINDOW, then the model's
# modelSettings entry, then the top-level autoCompactWindow in settings.json), else the model's window;
# never above the model's window. Empty when jq is missing.
tok=0
max=""
if command -v jq > /dev/null 2>&1; then
  settings="${CC_SETTINGS:-$HOME/.claude/settings.json}"
  # jq -n with file arguments ignores stdin, so the payload is read as /dev/stdin, first.
  sargs=(/dev/stdin)
  [[ -r "$settings" ]] && sargs+=("$settings")
  IFS=$'\t' read -r tok max < <(printf '%s' "$in" | jq -n -r --arg e "${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-}" '
    def num: select(type == "number" and . > 0);
    input as $p | (try input catch {}) as $s
    | ($p.context_window.total_input_tokens // 0 | if type == "number" then floor else 0 end) as $t
    | ($p.context_window.context_window_size | num) as $size
    | ( (($e | tonumber?) | num)
        // (try ($s.modelSettings[$p.model.id].autoCompactWindow | num) catch null)
        // (try ($s.autoCompactWindow | num) catch null)
        // $size ) as $m
    | "\($t)\t\(if $size != null and $m != null and $m > $size then $size else $m end // "")"' "${sargs[@]}" 2> /dev/null)
  [[ "$tok" =~ ^[0-9]+$ ]] || tok=0
fi

# Growth segment: +Nk since the session's first non-zero context size, kept in a per-session file.
# Bands match the context-hygiene hooks (warn +50k, crit +90k; CTX_WARN_GROWTH / CTX_CRIT_GROWTH).
# Omitted when the size is 0 or absent, there is no valid session_id, or jq is missing.
# The context bar takes the same band colour so the two agree.
grow=""
barcol=$'\e[38;2;148;226;213m'
if [[ "$sid" =~ ^[A-Za-z0-9_-]+$ ]] && ((tok > 0)); then
  sf="${TMPDIR:-/tmp}/cc-statusline-start-$sid"
  start=""
  [[ -r "$sf" ]] && read -r start < "$sf"
  if [[ ! "$start" =~ ^[0-9]+$ ]] || ((start == 0)); then
    start=$tok
    printf '%s' "$start" > "$sf" 2> /dev/null
  fi
  gw=${CTX_WARN_GROWTH:-50000}
  gc=${CTX_CRIT_GROWTH:-90000}
  [[ "$gw$gc" =~ ^[0-9]+$ ]] || {
    gw=50000
    gc=90000
  }
  d=$((tok - start))
  label="+$((d / 1000))k"
  if ((d >= gc)); then
    grow=$'\e[1m\e[38;2;243;139;168m'"$label"$'\e[0m'
  elif ((d >= gw)); then
    grow=$'\e[38;2;249;226;175m'"$label"$'\e[0m'
  else grow=$'\e[38;2;147;153;178m'"$label"$'\e[0m'; fi
fi
[[ -n "$grow" ]] && seg="${seg:+$seg }$grow"

# Context bar at the start of cship's line: 20 cells, each 5% of the auto-compaction window.
# Fixed segments (system prompt, tools, MCP, memory, skills) always keep their colour, messages come
# after them, free space is dim. The split is an estimate: the payload carries only the total, so the
# fixed parts are constants (override with CTX_EST_SYS/TOOLS/MCP/SKILLS, calibrate from /context),
# memory is the CLAUDE.md byte size / 4, cached once per session. Omitted when tok is 0.
if ((tok > 0)) && [[ "$max" =~ ^[0-9]+$ ]] && ((max > 0)); then
  pct=$(((tok * 100 + max / 2) / max))
  # Colour of the total % by fill of the compaction window (the growth bands colour +Nk and drive the hooks).
  bw=${CTX_BAR_WARN_PCT:-60}
  bc=${CTX_BAR_CRIT_PCT:-80}
  [[ "$bw$bc" =~ ^[0-9]+$ ]] || {
    bw=60
    bc=80
  }
  if ((pct >= bc)); then
    barcol=$'\e[1m\e[38;2;243;139;168m'
  elif ((pct >= bw)); then
    barcol=$'\e[38;2;249;226;175m'
  else barcol=$'\e[38;2;148;226;213m'; fi

  est=""
  ff=""
  [[ "$sid" =~ ^[A-Za-z0-9_-]+$ ]] && ff="${TMPDIR:-/tmp}/cc-statusline-fixed-$sid"
  [[ -n "$ff" && -r "$ff" ]] && read -r est < "$ff"
  if [[ ! "$est" =~ ^[0-9]+\ [0-9]+\ [0-9]+\ [0-9]+\ [0-9]+$ ]]; then
    cdir=$(printf '%s' "$in" | jq -r '.workspace.current_dir // .cwd // empty' 2> /dev/null)
    memb=$(cat "$HOME/.claude/CLAUDE.md" "${cdir:-.}/CLAUDE.md" 2> /dev/null | wc -c | tr -d ' ')
    est="${CTX_EST_SYS:-3500} ${CTX_EST_TOOLS:-11000} ${CTX_EST_MCP:-9000} $((${memb:-0} / 4)) ${CTX_EST_SKILLS:-5000}"
    [[ "$est" =~ ^[0-9]+\ [0-9]+\ [0-9]+\ [0-9]+\ [0-9]+$ ]] || est="3500 11000 9000 0 5000"
    [[ -n "$ff" ]] && printf '%s' "$est" > "$ff" 2> /dev/null
  fi
  b=$(awk -v tok="$tok" -v max="$max" -v est="$est" 'BEGIN {
    n = split(est, f, " "); fixed = 0
    for (i = 1; i <= n; i++) fixed += f[i]
    if (fixed > tok) { for (i = 1; i <= n; i++) f[i] = f[i] * tok / fixed; fixed = tok }
    f[6] = tok - fixed
    split("180;190;254 116;199;236 203;166;247 148;226;213 242;205;205 137;180;250", col, " ")
    cells = 20; used = int(tok * cells / max + 0.5); if (used < 1) used = 1; if (used > cells) used = cells
    for (i = 1; i <= 6; i++) { raw[i] = f[i] * used / tok; c[i] = int(raw[i]); left += raw[i] - c[i] }
    left = used; for (i = 1; i <= 6; i++) left -= c[i]
    while (left-- > 0) { best = 0; bv = -1
      for (i = 1; i <= 6; i++) if (raw[i] - c[i] > bv) { bv = raw[i] - c[i]; best = i }
      c[best]++; raw[best] = c[best] }
    out = ""
    for (i = 1; i <= 6; i++) { s = ""; for (k = 0; k < c[i]; k++) s = s "█"; if (s != "") out = out "\033[38;2;" col[i] "m" s }
    s = ""; for (k = used; k < cells; k++) s = s "░"
    printf "%s\033[38;2;69;71;90m%s\033[0m", out, s }' 2> /dev/null)
  out="${b} ${barcol}${pct}%"$'\e[0m'" $out"
fi

[[ -n "$jjline" ]] && printf '%s\n' "$jjline"

if [[ -n "$seg" ]]; then
  nl=""
  [[ "$out" == *$'\n' ]] && nl=$'\n'
  while [[ "$out" == *$'\n' ]]; do out=${out%$'\n'}; done
  while [[ "$out" == *' ' ]]; do out=${out% }; done
  printf '%s %s%s' "$out" "$seg" "$nl" | sed -E 's/ {2,}/ /g'
else
  printf '%s' "$out" | sed -E 's/ {2,}/ /g'
fi
exit 0
