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

## Khi Codex xong

`Agent` chạy nền → Claude Code tự báo khi xong (không poll bằng `ScheduleWakeup`). Nhận notification:
1. `git diff HEAD` — nếu Codex edit chưa commit: syntax check → `git add <files> && git commit -m "<task> (codex-autocommit)"`.
2. `git diff HEAD~1 HEAD` — Claude review committed diff.
3. `npm run build` + test nếu có.
Fail → `SendMessage` tới agent đó với lỗi cụ thể, lặp tới done/fail.

## Prompt template — executing-plans

```
Tasks: [extract ### Task headings + steps từ docs/plan-overview.md]
Decisions: docs/superpowers/decisions.md  ← đọc trước
Constraints: [từ writing-plans]
Goal: execute theo task list, parallelize task độc lập
Start task: **Status:** pending → in_progress trong plan-overview.md
Done: → done + **Commit:** [hash]
Blocked: → blocked + **Reason:** QA-FAIL: [lý do]
Mơ hồ: ghi ASSUMPTION: vào commit message
```

## Codex capabilities (xem AGENTS.md)

- MCP/code search nếu có → tự kiểm tra symbol, callers/callees và blast radius.
- Browser tool sẵn có của môi trường, hoặc Playwright.
- `detect_changes` trước mỗi commit (self blast-radius check).

## Fallback

Codex fail 2+ lần cùng symptom / không tạo diff → Claude direct fix, ghi rõ lý do. Sau 3 lần: `<!-- claude-override: direct-fix after 3 Codex retries [date] -->`.

## Không dùng

- `Skill("codex:rescue")` để execute (chỉ wrapper).
- `mcp__codex__codex` trừ khi OpenAI credential active.
- `/codex:status` trong shell.
