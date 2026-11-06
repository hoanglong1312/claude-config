---
description: Dispatch code task cho Codex — companion resume, Agent codex-rescue, foreground/background, review kết quả, prompt template. Dùng khi giao code change cho Codex.
---

# /codex-exec — Dispatch Codex

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
- Prompt CHỈ gồm: goal + file/spec path + constraints + verification. KHÔNG paste source (Codex tự đọc).
- Codex có agent riêng (`~/.codex/agents/`): `implementer` (ghi code), `reviewer` (đọc + soát bảo mật, dùng cho review chéo plan), `code_mapper` (dò code rẻ, read-only). Nêu agent trong brief khi cần.

## Khi Codex xong

`Agent` chạy nền → Claude Code tự báo khi xong (không poll bằng `ScheduleWakeup`). Nhận notification:
1. `git diff HEAD` — nếu Codex edit chưa commit: syntax check → `git add <files> && git commit -m "<task> (codex-autocommit)"`.
2. **Haiku** (`model: haiku`) chạy lại build + test độc lập — không tin Codex tự báo — trả output nguyên văn + pass/fail.
3. **Opus** đọc `git diff HEAD~1 HEAD` theo bảng kiểm trong `code-project.md` (ngoài phạm vi? test bị sửa/skip? ASSUMPTION? đụng auth/api/migration?).
4. Lỗi → phân loại A/B/C/D (mục Fallback).

## Prompt template — executing-plans

```
Tasks: [extract ### Task headings + steps từ docs/plan-overview.md]
Decisions: docs/superpowers/decisions.md  ← đọc trước
Constraints: [từ writing-plans]
Đã quyết / đã loại: [điều Opus + user đã chốt — KHÔNG để Codex tự đoán]
Ràng buộc: chỉ sửa [file/thư mục]; KHÔNG sửa/xoá/skip test để pass; không thêm dependency ngoài plan
Verify: [lệnh test/build cụ thể]
Goal: execute theo task list, tuần tự (song song chỉ khi worktree riêng + không chung file)
Start task: **Status:** pending → in_progress trong plan-overview.md
Done: → done + **Commit:** [hash]
Blocked: → blocked + **Reason:** QA-FAIL: [lý do]
Mơ hồ: ghi ASSUMPTION: vào commit message
```

## Codex capabilities (xem AGENTS.md)

- MCP/code search nếu có → tự kiểm tra symbol, callers/callees và blast radius.
- Browser tool sẵn có của môi trường, hoặc Playwright.

## Fallback

Phân loại trước — bảng đầy đủ trong `code-project.md` mục "Codex lỗi":
- **A. Hạ tầng** (không chạy được, hết quota OpenAI, timeout): thử lại 1 lần → Sonnet subagent (`model: sonnet`, `isolation: worktree`) làm **cùng brief** / task ≲20 dòng → Opus tự sửa. Không tính vào số lần fail.
- **B. Đầu ra sai** (không diff, lệch spec, `QA-FAIL:`): `SendMessage` lại chính agent đó kèm lỗi nguyên văn.
- **C. Lặp** (cùng triệu chứng lần 2): Opus chẩn đoán lại → spec mới → giao lại. Lần 3 → Opus sửa, ghi `<!-- claude-override: direct-fix after 3 Codex retries [date] -->`.
- **D. Âm thầm** (test bị sửa/skip, pass giả): như B + "không được sửa test để pass".

## Không dùng

- `Skill("codex:rescue")` để execute (chỉ wrapper).
- Codex MCP (`mcp__codex__*`) — đã gỡ khỏi Claude 2026-11-02.
- codex-rescue để tạo ảnh — không có `image_gen`; dùng skill `codex-image` (`codex exec`).
- `/codex:status` trong shell.
