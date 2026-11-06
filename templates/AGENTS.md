# AGENTS.md — Code / Multi-Agent AI Rules

<!--
Generated project AGENTS.md must materialize shared rules above this template body.
Do not rely on @include for Codex unless Codex include expansion is verified.
Source: ~/.claude/templates/shared-agent-rules.md
-->

*File này dành cho MỌI executor agent không phải Claude (Codex, Gemini CLI, agent khác) làm việc trên code project. Non-code project không bắt buộc có `AGENTS.md` trừ khi cần phối hợp nhiều tool. Chỗ nào ghi "Codex" = executor agent đang đọc file này.*

---

## Project Context

- **Tên**: [tên project]
- **Type**: code / multi-agent
- **Stack**: [tech stack]
- **Lý do / đầu ra**: [tạo ra gì, phục vụ ai]
- **Mục tiêu**: [kết quả — khi nào coi là thành công]
- **Không làm**: [scope loại trừ, nếu có]

---

## Upstream Claude Context

- Superpowers is Claude-only. Codex does not invoke Superpowers skills directly.
- Claude may create specs/plans via brainstorming → writing-plans; Codex consumes generated `.md` files.
- Caveman mode, RTK hooks, statusline, and Claude memory rules are Claude-side behavior. Ignore them for code behavior unless task explicitly mentions them.
- If Claude is orchestrating, follow task list extracted from `docs/plan-overview.md` and report back for Claude review.

---

## Operating Contract

- Start by reading the current task/spec and relevant project context.
- Define success criteria before editing.
- Make minimal scoped changes; do not refactor adjacent code.
- Run verification before declaring done.
- Report changed files, exact commands run, and pass/fail results.
- If blocked, write `QA-FAIL:` with command, error, and attempted fixes.

---

## When Working Without Claude

Use this when user opens Codex (or another executor agent) directly instead of dispatching through Claude — e.g. Claude hit usage limit mid-project:

1. Read in order: `docs/plan-overview.md` (what's in progress), `docs/superpowers/decisions.md` (settled decisions — do not relitigate), `context/architecture.md` (codebase map + entry points). Start from the map, not from guessing/grepping around.
2. If no task plan exists, create a short implementation plan before editing.
3. Use project commands from `rules/*.md`, `package.json`, `pyproject.toml`, `go.mod`, or README.
4. Keep changes surgical and verify after each meaningful step.
5. End with summary: files changed, verification run, remaining risks, next step.

---

## Phân Công Vai Trò

| Tool | Vai trò |
|------|---------|
| **Claude Code** | Orchestration + Review: plan, quyết kiến trúc, review output |
| **Executor** (Codex qua `codex:codex-rescue`, hoặc agent khác chạy standalone) | Execution + QA: viết code, test, commit |

---

## Executor Workflow (Codex / agent khác)

0. **Nếu được giao review plan (cross-review, read-only):** đối chiếu plan với codebase — file/symbol trong plan có thật không, impact đủ chưa, thiếu bước nào. Trả `PLAN-OK` hoặc `PLAN-GAP: [vấn đề cụ thể]`. KHÔNG sửa code trong bước này.
1. Nhận task list từ Claude (extract từ `docs/plan-overview.md`). Không tự tạo plan.
2. Đọc `docs/superpowers/decisions.md` trước khi bắt đầu.
3. Nếu mơ hồ → ghi `ASSUMPTION:` vào commit message, tiếp tục.
3b. Task UI: bám wireframe đã duyệt (path Claude đưa trong task) + design token trong `rules/design-system.md` nếu file tồn tại — không tự chế style/màu/font mới ngoài token.
4. Chạy Quality Gate trước commit: static audit + test suite + build.
5. QA fail → tự fix tối đa 3 retry → sau đó `QA-FAIL:` + escalate.
6. Thêm file/module/bảng DB mới → update map trong `context/architecture.md` (chỉ map, không ghi tiến độ) + status task trong `docs/plan-overview.md`.
7. Pass → commit + báo Claude review.

**Commit signals bắt buộc:**

| Signal | Khi nào |
|---|---|
| `ASSUMPTION:` | Giả định cần Claude xác nhận |
| `ENV-REQUIRED: VAR_NAME` | Env var mới cần set trước deploy |
| `QA-FAIL:` | Test fail sau 3 retry, cần Claude |
| `SECURITY-SENSITIVE:` | Động vào auth/middleware/migration/token/session/password/api route/input handling |

---

## Browser Automation (executor)

UI verification/debugging: dùng browser tool sẵn có của môi trường agent; không có → Playwright script. Verify UI sau code change, debug DOM/console error, confirm layout. E2E flow phức tạp → Playwright.

---

## Do NOT

- Push code chưa pass tests.
- Sửa / xoá / skip test để cho pass. Test sai thật → ghi `ASSUMPTION:` + lý do, để Claude quyết.
- Retry QA quá 3 lần mà không escalate.
- Tự thêm dependencies không có trong plan. Ghi `ASSUMPTION:` và báo Claude approve trước.
- Bỏ qua code review khi có code review skill.
- Thêm project-specific rules vào file này. Đặt vào `rules/[tool].md` trong project.
- Âm thầm lệch spec. Nếu implementation cần lệch → ghi `ASSUMPTION:` → dừng → báo Claude cập nhật spec trước.

---

*Cập nhật: 2026-07-01 (rev13: trim Claude-side workflow; Codex-only content)*

<!-- template: 2026-07-01 -->
