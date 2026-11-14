#!/usr/bin/env bash

# Statusline: color-as-signal, progressive visibility, no emoji clutter
# Layout: ⎇ workspace  ● change_id bookmarks ← parents  │  ◉ ctx%  │  model

input=$(cat)

# --- ANSI colors ---
BOLD='\033[1m'    DIM='\033[2m'     RESET='\033[0m'
RED='\033[31m'    GREEN='\033[32m'  YELLOW='\033[33m'  CYAN='\033[36m'

# --- Extract Claude Code context ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | sed 's/[^0-9.]//g')
pct_num=${used_pct%.*}  # integer part
pct_num=${pct_num:-0}

# Shorten model name: "Claude Opus 4.6" → "opus-4.6", "Claude Sonnet 4.6" → "sonnet-4.6"
model_short=$(echo "$model" | sed -E 's/^Claude //i; s/ /-/g' | tr '[:upper:]' '[:lower:]')

# --- Context color ---
if [ "$pct_num" -ge 80 ] 2>/dev/null; then
    ctx_color="${RED}"
elif [ "$pct_num" -ge 50 ] 2>/dev/null; then
    ctx_color="${YELLOW}"
else
    ctx_color="${GREEN}"
fi

# --- jj data extraction (all with --ignore-working-copy) ---
in_jj=false
if jj root --ignore-working-copy &>/dev/null; then
    in_jj=true

    # Workspace (filter out "default")
    workspace=$(jj workspace list --ignore-working-copy 2>/dev/null | awk '/^\*/{print $2}')
    [ "$workspace" = "default" ] && workspace=""

    # Change ID (shortest unique prefix)
    change_id=$(jj log -r @ --no-graph -T 'change_id.shortest()' --ignore-working-copy 2>/dev/null)

    # Bookmarks (comma-separated)
    bookmarks=$(jj log -r @ --no-graph -T 'bookmarks.join(", ")' --ignore-working-copy 2>/dev/null)

    # Parents (comma-separated short change IDs)
    parents=$(jj log -r 'parents(@)' --no-graph -T 'change_id.shortest() ++ ","' --ignore-working-copy 2>/dev/null | sed 's/,$//')

    # State detection
    has_conflict=$(jj log -r @ --no-graph -T 'conflict' --ignore-working-copy 2>/dev/null)
    is_empty=$(jj log -r @ --no-graph -T 'empty' --ignore-working-copy 2>/dev/null)
fi

# --- Build output ---
out=""

if [ "$in_jj" = true ]; then
    # Workspace (bold, only if non-default)
    [ -n "$workspace" ] && out+="${BOLD}⎇ ${workspace}${RESET}  "

    # Change state glyph
    if [ "$has_conflict" = "true" ]; then
        out+="${RED}${BOLD}✖${RESET} "
    elif [ "$is_empty" = "true" ]; then
        out+="${DIM}○${RESET} "
    else
        out+="${GREEN}●${RESET} "
    fi

    # Change ID
    out+="${change_id}"

    # Bookmarks (cyan, hidden if none)
    [ -n "$bookmarks" ] && out+=" ${CYAN}${bookmarks}${RESET}"

    # Parents (dim)
    [ -n "$parents" ] && out+=" ${DIM}← ${parents}${RESET}"

    # Separator before context
    out+="  ${DIM}│${RESET}  "
fi

# Context usage (with compact hint at >=80%)
if [ "$pct_num" -ge 80 ] 2>/dev/null; then
    out+="${RED}◉ ${used_pct}% compact?${RESET}"
else
    out+="${ctx_color}◉ ${used_pct}%${RESET}"
fi

# Separator + model (dim)
out+="  ${DIM}│  ${model_short}${RESET}"

# --- Session & weekly usage from ccusage (cached 5 min) ---
cache_file="/tmp/.ccusage-statusline-cache"
cache_max_age=300

if command -v ccusage &>/dev/null; then
    if [ -f "$cache_file" ] && [ "$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))" -lt "$cache_max_age" ]; then
        usage_data=$(cat "$cache_file")
    else
        active=$(ccusage blocks --active --json 2>/dev/null)

        sess_remaining=$(echo "$active" | jq -r '.blocks[0].projection.remainingMinutes // empty')
        today=$(date +%Y%m%d)
        daily_raw=$(ccusage daily --since "$today" --json 2>/dev/null)
        daily_cost=$(echo "$daily_raw" | jq -r '.totals.totalCost // 0' | awk '{printf "%.0f", $1}')

        usage_data="${sess_remaining}|${daily_cost}"
        echo "$usage_data" > "$cache_file"
    fi

    sess_remaining=$(echo "$usage_data" | cut -d'|' -f1)
    daily_cost=$(echo "$usage_data" | cut -d'|' -f2)

    # Session: time remaining in 5h window (neutral — it's just a countdown)
    if [ -n "$sess_remaining" ]; then
        sess_h=$(( sess_remaining / 60 ))
        sess_m=$(( sess_remaining % 60 ))
        out+="  ${DIM}│  ${sess_h}h${sess_m}m left${RESET}"
    fi

    # Daily spend
    [ -n "$daily_cost" ] && [ "$daily_cost" != "0" ] && out+="  ${DIM}│  \$${daily_cost} today${RESET}"
fi

printf "%b" "$out"
