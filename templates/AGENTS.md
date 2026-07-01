# AGENTS.md — Code / Multi-Agent AI Rules

<!--
Generated project AGENTS.md must materialize shared rules above this template body.
Do not rely on @include for Codex unless Codex include expansion is verified.
Source: ~/.claude/templates/shared-agent-rules.md
-->

*File này dành cho code project hoặc project có nhiều agent cùng sửa artifact. Non-code project không bắt buộc có `AGENTS.md` trừ khi cần phối hợp nhiều tool.*

---

## Project Context

- **Tên**: [tên project]
- **Type**: code / multi-agent
- **Stack**: [tech stack]
- **Mục tiêu**: [mô tả ngắn]

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

Use this when user opens Codex directly instead of dispatching through Claude:

1. Read `AGENTS.md` first, then `context/architecture.md` if present.
2. If no task plan exists, create a short implementation plan before editing.
3. Use project commands from `rules/*.md`, `package.json`, `pyproject.toml`, `go.mod`, or README.
4. Keep changes surgical and verify after each meaningful step.
5. End with summary: files changed, verification run, remaining risks, next step.

---

## Phân Công Vai Trò

| Tool | Vai trò |
|------|---------|
| **Claude Code** | Orchestration + Review: plan, quyết kiến trúc, review output |
| **Codex** (`codex:codex-rescue`) | Execution + QA: viết code, test, commit |

---

## Codex — Workflow

1. Nhận task list từ Claude (extract từ `docs/plan-overview.md`). Không tự tạo plan.
2. Đọc `docs/superpowers/decisions.md` trước khi bắt đầu.
3. Nếu mơ hồ → ghi `ASSUMPTION:` vào commit message, tiếp tục.
4. Chạy Quality Gate trước commit: static audit + test suite + build.
5. QA fail → tự fix tối đa 3 retry → sau đó `QA-FAIL:` + escalate.
6. Pass → commit + báo Claude review.

**Commit signals bắt buộc:**

| Signal | Khi nào |
|---|---|
| `ASSUMPTION:` | Giả định cần Claude xác nhận |
| `ENV-REQUIRED: VAR_NAME` | Env var mới cần set trước deploy |
| `QA-FAIL:` | Test fail sau 3 retry, cần Claude |
| `SECURITY-SENSITIVE:` | Động vào auth/middleware/migration/token/session/password/api route/input handling |

---

## Code Intelligence — GitNexus MCP

Dự án dùng GitNexus (MCP `npx gitnexus mcp`) để index toàn bộ codebase. Codex gọi tools qua MCP được cấu hình trong `.codex/config.toml` (init tự tạo nếu project có gitnexus):

```toml
[mcp_servers.gitnexus]
command = "npx"
args = ["gitnexus", "mcp"]
```

**Bắt buộc trước khi sửa code:**

| Câu hỏi | Tool | Khi nào dùng |
|---------|------|-------------|
| Feature/area liên quan file/flow nào? | `query({search_query: "concept"})` | Trước khi bắt đầu bất kỳ task nào |
| Symbol X là gì, callers/callees? | `context({name: "symbolName"})` | Hiểu function trước khi sửa |
| Sửa X sẽ ảnh hưởng gì? | `impact({target: "symbolName", direction: "upstream"})` | Trước khi sửa function quan trọng |
| Trace path từ A → B | `trace({from: "A", to: "B"})` | Debug data flow |
| Thay đổi này ảnh hưởng symbol nào? | `detect_changes()` | Trước khi commit |

**Quy tắc:**
- `query` TRƯỚC khi đọc file source — trả về execution flows, process-grouped, tiết kiệm token.
- `impact` bắt buộc trước khi sửa bất kỳ function nào — biết blast radius.
- `detect_changes()` trước commit — verify chỉ sửa đúng scope (self blast-radius check).
- Index stale? Chạy `node .gitnexus/run.cjs analyze` từ project root.

## Browser Automation (Codex)

Codex dùng `cmux browser` qua bash cho UI verification và debugging:

```bash
cmux browser goto http://localhost:5173
cmux browser snapshot          # đọc accessibility tree
cmux browser screenshot        # capture visual
cmux browser console list      # JS errors + logs
cmux browser eval "<js>"       # execute JS in page
cmux browser click "<selector>"
cmux browser fill "<selector>" "<value>"
```

Dùng `cmux browser` khi: cần verify UI sau code change, debug DOM/console error, confirm layout. Không dùng cho E2E flow phức tạp (→ Playwright).

---

## Do NOT

- Push code chưa pass tests.
- Retry QA quá 3 lần mà không escalate.
- Tự thêm dependencies không có trong plan. Ghi `ASSUMPTION:` và báo Claude approve trước.
- Bỏ qua code review khi có code review skill.
- Thêm project-specific rules vào file này. Đặt vào `rules/[tool].md` trong project.
- Âm thầm lệch spec. Nếu implementation cần lệch → ghi `ASSUMPTION:` → dừng → báo Claude cập nhật spec trước.

---

*Cập nhật: 2026-07-01 (rev13: trim Claude-side workflow; Codex-only content)*

<!-- template: 2026-07-01 -->
