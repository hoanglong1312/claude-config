---
description: Giao code cho Codex NGOÀI Orca (qua agent codex:codex-rescue) — resume thread, dispatch, nhận kết quả. Trong Orca dùng skill orchestrating-agents (Codex worker), không dùng lệnh này.
---

# /codex-exec — Giao Codex ngoài Orca

**Trong Orca → KHÔNG dùng lệnh này:** skill `orchestrating-agents` (mục "Orca worker (Codex)") là nguồn duy nhất. Lệnh này chỉ cho phiên Claude Code ngoài Orca, việc LỚN đã chốt spec, Codex đã cài + login. Đề bài, kiểm đầu vào, review, leo thang khi lỗi → đều theo skill; file này chỉ giữ cơ chế kỹ thuật.

## Trước mỗi task

1. Chạy helper resume:
   ```bash
   CODEX_COMPANION=$(ls -d "$HOME/.claude/plugins/cache/openai-codex/codex/"*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)
   node "$CODEX_COMPANION" task-resume-candidate --json
   ```
2. `available: true` → hỏi user tiếp thread cũ hay tạo mới.

## Dispatch

- `Agent` tool, `subagent_type: codex:codex-rescue`.
- **Default foreground:** prompt bắt đầu `--wait`. Background (>10 phút): `--background`.
- Prompt = đề bài theo "Brief contract" + "Worker brief" của skill (yêu cầu đánh số, danh sách file được phép sửa, lệnh kiểm, bằng chứng test fail rồi pass, cấm sửa/skip test, không commit). KHÔNG paste source (Codex tự đọc).
- Codex có agent riêng (`~/.codex/agents/`): `implementer` (ghi code), `code_mapper` (dò code rẻ, read-only). Nêu agent trong brief khi cần.

## Khi Codex xong

`Agent` chạy nền → Claude Code tự báo khi xong (không poll bằng `ScheduleWakeup`). Nhận notification → làm đúng bước "Intake" rồi review theo bảng cỡ việc trong skill (LỚN: `architect` đã viết spec review, SendMessage agent cũ). Không tin Codex tự báo — chạy lại kiểm tra.

## Codex lỗi

Theo skill: không chạy được / hết quota → `builder` (`isolation: worktree`) làm cùng đề bài, báo user 1 dòng, không chờ. Đầu ra sai lần đầu → `SendMessage` lại chính agent đó kèm lỗi nguyên văn + `file:dòng`. Cùng triệu chứng lần 2 → mục "Escalation" của skill.

## Không dùng

- `Skill("codex:rescue")` để execute (chỉ wrapper).
- Codex MCP (`mcp__codex__*`) — đã gỡ khỏi Claude 2026-11-02.
- codex-rescue để tạo ảnh — không có `image_gen`; dùng skill `codex-image` (`codex exec`).
- Codex review diff do chính Codex viết — dùng `code-reviewer`.
- `/codex:status` trong shell.
