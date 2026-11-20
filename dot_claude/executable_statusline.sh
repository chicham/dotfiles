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
            if ($p.ttl|type) == "string" and ($p.expires_at|type) == "number"
            then c(148;226;213) + "cache ● \($p.ttl) ⏲ \($p.expires_at|strflocaltime("%H:%M"))" + rst
            else empty end
          else
            if ($p.recache_tokens_if_cold|type) == "number"
            then "\u001b[1m" + c(243;139;168) + "cache ○ cold +\(($p.recache_tokens_if_cold/1000|round))k" + rst
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

# Context bar at the start of cship's line: used / auto-compaction window. Omitted when tok is 0.
if ((tok > 0)) && [[ "$max" =~ ^[0-9]+$ ]] && ((max > 0)); then
  pct=$(((tok * 100 + max / 2) / max))
  fill=$(((pct + 5) / 10))
  ((fill > 10)) && fill=10
  # Colour by fill of the compaction window (the growth bands colour +Nk and drive the hooks).
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
  b=""
  for ((i = 0; i < 10; i++)); do ((i < fill)) && b+="█" || b+="░"; done
  out="${barcol}󱞇 ${b} ${pct}%"$'\e[0m'"  $out"
fi

[[ -n "$jjline" ]] && printf '%s\n' "$jjline"

if [[ -n "$seg" ]]; then
  nl=""
  [[ "$out" == *$'\n' ]] && nl=$'\n'
  while [[ "$out" == *$'\n' ]]; do out=${out%$'\n'}; done
  printf '%s %s%s' "$out" "$seg" "$nl"
else
  printf '%s' "$out"
fi
exit 0
