#!/bin/bash
# Project structure check on session start
# Runs once per project per day (marker in /tmp)

PROJECT_DIR="$(pwd)"

# Skip global ~/.claude session
if [ "$PROJECT_DIR" = "$HOME/.claude" ]; then
  exit 0
fi

# Skip if no meaningful project indicators
if [ "$PROJECT_DIR" = "$HOME" ]; then
  exit 0
fi

# Daily marker — ask once per day per project, not every session
PROJECT_HASH=$(echo "$PROJECT_DIR" | md5)
TODAY=$(date +%Y-%m-%d)
MARKER="/tmp/.claude-project-check-${PROJECT_HASH}-${TODAY}"

if [ -f "$MARKER" ]; then
  exit 0
fi

touch "$MARKER"

# === Check 1: No CLAUDE.md → needs init ===
if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
  echo "PROJECT-INIT-NEEDED: Project chưa có CLAUDE.md. Hỏi user: 'Project này chưa được setup. Muốn init theo khung tiêu chuẩn không?' → nếu có: invoke Skill('init')"
  exit 0
fi

# === Check 2: Has CLAUDE.md → check basic gaps ===
GAPS=""

[ ! -f "$PROJECT_DIR/.gitignore" ] && GAPS="$GAPS .gitignore"
[ ! -f "$PROJECT_DIR/CLAUDE.local.md" ] && GAPS="$GAPS CLAUDE.local.md"

# Code project check
if [ -f "$PROJECT_DIR/package.json" ] || [ -f "$PROJECT_DIR/go.mod" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
  [ ! -f "$PROJECT_DIR/.mcp.json" ] && GAPS="$GAPS .mcp.json"
  [ ! -f "$PROJECT_DIR/AGENTS.md" ] && GAPS="$GAPS AGENTS.md"
fi

if [ -n "$GAPS" ]; then
  GAP_COUNT=$(echo "$GAPS" | wc -w | tr -d ' ')
  if [ "$GAP_COUNT" -ge 3 ]; then
    echo "PROJECT-GAPS-DETECTED: Thiếu:$GAPS — Hỏi user: 'Phát hiện project thiếu $GAP_COUNT file chuẩn ($GAPS). Muốn tạo không?' → nếu có: invoke Skill('init'). Nhiều gap → đề xuất thêm: 'Hoặc chạy sync-rules để audit toàn bộ?'"
  else
    echo "PROJECT-GAPS-DETECTED: Thiếu:$GAPS — Hỏi user: 'Phát hiện project thiếu một số file chuẩn ($GAPS). Muốn tạo không?' → nếu có: invoke Skill('init')"
  fi
fi

# Nếu không có gap → im lặng, không output gì
