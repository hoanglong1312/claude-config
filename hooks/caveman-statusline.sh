#!/usr/bin/env bash
set -euo pipefail
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  model="$(printf '%s' "$input" | jq -r '.model.display_name // .model.name // empty')"
  perm="$(printf '%s' "$input" | jq -r '.permission_mode // empty')"
  cwd="$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')"
  ctx="$(printf '%s' "$input" | jq -r '.context.remaining_percent // empty')"
  parts=()
  [ -n "$model" ] && parts+=("$model")
  [ -n "$perm" ] && parts+=("$perm")
  [ -n "$ctx" ] && parts+=("ctx:${ctx}%")
  [ -n "$cwd" ] && parts+=("$(basename "$cwd")")
  (IFS=' | '; echo "${parts[*]}")
else
  echo "Claude Code"
fi
