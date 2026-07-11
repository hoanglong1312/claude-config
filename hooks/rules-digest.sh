#!/usr/bin/env bash
# UserPromptSubmit hook: inject rule digest vào mỗi prompt để chống context decay.
# Sửa nội dung tại đây là đủ — không cần restart session.
cat <<'EOF'
GATES: bug/lỗi → superpowers:systematic-debugging TRƯỚC fix · xong việc → superpowers:verification-before-completion TRƯỚC báo done.
MƠ HỒ: prompt có ≥2 cách hiểu, hoặc goal/scope/tiêu chí done không rõ → AskUserQuestion gộp 1 lần (tối đa 3-4 câu) TRƯỚC khi làm. Không tự đoán rồi thực thi. Rõ ràng rồi → làm luôn, không hỏi thừa.
SKILL: ≥1% chance skill áp dụng → invoke (routing: using-superpowers).
MODEL: code project (có code-project.md) → mọi code change qua Codex. Ngoài code project: edit cơ học 1-2 file → cavecrew-builder (haiku) · explore 3+ file → subagent thay vì đọc thẳng.
EOF
