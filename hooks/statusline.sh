#!/bin/bash
# Combined statusline: model + rate limits + caveman badge
# Claude Code sends JSON via stdin; outputs plain text (no ANSI — desktop app strips it)

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
if [ -z "$model" ]; then
  model="${CLAUDE_MODEL:-}"
  [ -n "$model" ] && model=$(printf '%s' "$model" | sed 's/^us\.anthropic\.//' | sed 's/^claude-//')
fi

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
seven=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)

out=()
[ -n "$model" ] && out+=("$model")

if [ -n "$five" ] || [ -n "$seven" ]; then
  rate_str=""
  [ -n "$five" ] && rate_str="5h:$(printf '%.0f' "$five")%"
  [ -n "$seven" ] && rate_str="${rate_str} 7d:$(printf '%.0f' "$seven")%"
  out+=("⚡${rate_str# }")
fi

FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
[ ! -L "$FLAG" ] && [ -f "$FLAG" ] && {
  MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
  MODE=$(printf '%s' "$MODE" | tr -cd 'a-z0-9-')
  case "$MODE" in
    off|lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      if [ -z "$MODE" ] || [ "$MODE" = "full" ]; then
        out+=("[CAVEMAN]")
      else
        out+=("[CAVEMAN:$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')]")
      fi
      ;;
  esac
}

[ ${#out[@]} -eq 0 ] && exit 0
printf '%s' "${out[0]}"
for ((i=1; i<${#out[@]}; i++)); do printf ' | %s' "${out[i]}"; done
printf '\n'
