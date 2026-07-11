#!/usr/bin/env bash
# PostToolUse:Agent — nhắc set ScheduleWakeup ngay sau khi dispatch agent.
# Bước forget-prone nhất của Codex async loop (xem code-project.md).
cat <<'EOF'
REMINDER: vừa dispatch agent. Nếu là Codex/background dispatch → set ScheduleWakeup NGAY trong response này, đừng đợi. Delay theo task: nhỏ 60-120s · vừa/dài 270s rồi lặp (giữ ≤270s để cache ấm — không chọn 300s+).
EOF
