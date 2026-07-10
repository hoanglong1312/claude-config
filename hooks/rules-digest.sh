#!/usr/bin/env bash
# UserPromptSubmit hook: inject rule digest vào mỗi prompt để chống context decay.
# Sửa nội dung tại đây là đủ — không cần restart session.
cat <<'EOF'
GATES: bug/lỗi → superpowers:systematic-debugging TRƯỚC fix · xong việc → superpowers:verification-before-completion TRƯỚC báo done.
SKILL: ≥1% chance skill áp dụng → invoke (routing: using-superpowers).
MODEL: code project (có code-project.md) → mọi code change qua Codex. Ngoài code project: edit cơ học 1-2 file → cavecrew-builder (haiku) · explore 3+ file → subagent thay vì đọc thẳng.
EOF
