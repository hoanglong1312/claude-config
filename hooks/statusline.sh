#!/bin/bash
# Combined statusline: model + rate limits (or context) + caveman badge
# Receives Claude Code session JSON via stdin, outputs single line plain text.

input=$(cat)

# ── Helpers ─────────────────────────────────────────────────────────────────

bar() {
  local pct="${1:-0}" width=15 filled empty i out=""
  filled=$(( pct * width / 100 ))
  [ $filled -gt $width ] && filled=$width
  empty=$(( width - filled ))
  for ((i=0; i<filled; i++)); do out+="█"; done
  for ((i=0; i<empty; i++)); do out+="░"; done
  printf '%s' "$out"
}

fmt_reset() {
  local ts="$1"
  [ -z "$ts" ] && return
  local today reset_date
  today=$(TZ="Asia/Ho_Chi_Minh" date "+%Y-%m-%d")
  reset_date=$(TZ="Asia/Ho_Chi_Minh" date -r "$ts" "+%Y-%m-%d" 2>/dev/null)
  if [ "$reset_date" = "$today" ]; then
    TZ="Asia/Ho_Chi_Minh" date -r "$ts" "+%-I%p" 2>/dev/null | sed 's/AM/am/; s/PM/pm/'
  else
    TZ="Asia/Ho_Chi_Minh" date -r "$ts" "+%b %-d %-I%p" 2>/dev/null | sed 's/AM/am/; s/PM/pm/'
  fi
}

# ── Model ────────────────────────────────────────────────────────────────────

model=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
if [ -z "$model" ]; then
  model="${CLAUDE_MODEL:-}"
  [ -n "$model" ] && model=$(printf '%s' "$model" | sed 's/^us\.anthropic\.//' | sed 's/^claude-//')
fi

# ── Rate limits (5h session + 7d week) ──────────────────────────────────────

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
reset_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
reset_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

# Fallback: context window usage if no rate limits
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)

# ── Build output ─────────────────────────────────────────────────────────────

out=()

[ -n "$model" ] && out+=("🤖 $model")

if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  reset_str=$(fmt_reset "$reset_5h")
  entry="⏱ $(bar $five_int) ${five_int}%"
  [ -n "$reset_str" ] && entry+=" → ${reset_str}"
  out+=("$entry")
fi

if [ -n "$seven_pct" ]; then
  seven_int=$(printf '%.0f' "$seven_pct")
  reset_str=$(fmt_reset "$reset_7d")
  entry="📅 $(bar $seven_int) ${seven_int}%"
  [ -n "$reset_str" ] && entry+=" → ${reset_str}"
  out+=("$entry")
fi

# Show context window if no rate limits available
if [ -z "$five_pct" ] && [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
  [ "$ctx_int" -gt 0 ] && out+=("💬 ctx $(bar $ctx_int) ${ctx_int}%")
fi

# ── Caveman badge ────────────────────────────────────────────────────────────

FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
[ ! -L "$FLAG" ] && [ -f "$FLAG" ] && {
  MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | sed 's/AM/am/; s/PM/pm/')
  MODE=$(printf '%s' "$MODE" | tr -cd 'a-z0-9-')
  case "$MODE" in
    off|lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      if [ -z "$MODE" ] || [ "$MODE" = "full" ]; then
        out+=("🪨 CAVEMAN")
      else
        out+=("🪨 CAVEMAN:$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')")
      fi
      ;;
  esac
}

[ ${#out[@]} -eq 0 ] && exit 0
printf '%s' "${out[0]}"
for ((i=1; i<${#out[@]}; i++)); do printf ' | %s' "${out[i]}"; done
printf '\n'
