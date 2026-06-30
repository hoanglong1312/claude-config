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
| **Superpowers** (Claude plugin) | Planning: brainstorming → spec → writing-plans |
| **Claude Code** | Orchestration + Review: brainstorming, writing-plans, quyết định kiến trúc, review plan + output |
| **Codex** (`codex:codex-rescue` subagent / `/codex:rescue`) | Execution + QA: executing-plans, TDD, chạy test, commit |

---

## Workflow

### Claude Code — nhận task mới
1. Check Superpowers skill có apply không.
2. Task phức tạp → `brainstorming` trước → spec.
3. Invoke Superpowers `writing-plans` skill trực tiếp. Codex không invoke skill này.
4. Append plan vào `docs/plan-overview.md` (source of truth) → compile `docs/plan-overview.html` bằng `html-eff`.
5. User mở `docs/plan-overview.html` → review → confirm "OK, triển khai".
6. Nếu plan cần chỉnh → Claude sửa `docs/plan-overview.md` hoặc spec `.md`, rồi compile HTML lại. Không edit `.html` tay.
7. Extract task list từ `docs/plan-overview.md` → truyền vào Codex prompt dạng text.
8. Review output thực thi qua `git diff` + commit message → verify status trong `docs/plan-overview.md`.

### Codex — nhận task list từ Claude
1. Nhận task list dạng text do Claude extract từ `docs/plan-overview.md`. Codex không tự tạo plan, không đọc HTML trực tiếp.
2. Đọc `docs/superpowers/decisions.md` nếu có trước khi bắt đầu.
3. Với UI task, đọc các handoff artifacts trước khi sửa code:
   ```text
   UI_PREVIEW.html
   UI_SPEC.md
   UI_STYLE_GUIDE.md
   UI_ACCEPTANCE_CHECKLIST.md
   UI_DO_NOT_CHANGE.md
   ```
   Nếu thiếu file, mâu thuẫn, hoặc spec không ghi rõ màu/font/sizes/spacing/layout/states/responsive/do-not-change → ghi `ASSUMPTION:` và dừng để Claude/user bổ sung.
4. Dùng `executing-plans`; parallelize task chỉ khi `Depends on: none` và không share prop/type/interface.

   **Task Size gate — bắt buộc trước executing-plans:**
   - Task `Size: L` → chia thành 2-3 sub-task trước khi execute.
   - List sub-task trong plan file → báo Claude approve → mới chạy.
   - Task `Size: S / M` → execute bình thường.

   **Parallel safety check:**
   ```bash
   grep -r "export type\|export interface" [files-in-task-A] 2>/dev/null
   grep -r "import.*from.*[files-in-task-A]" [files-in-task-B] 2>/dev/null
   ```
   Nếu task B import từ file task A đang sửa → gộp 1 agent, không parallel.

5. Nếu gặp mơ hồ → đọc `docs/superpowers/decisions.md` trước. Nếu chưa có quyết định → ghi `ASSUMPTION:` (giả định) vào commit message.

   **Signals bắt buộc trong commit message:**
   - `ASSUMPTION:` — giả định cần Claude xác nhận
   - `ENV-REQUIRED: VAR_NAME — [dùng cho gì]` — env var mới cần set trước khi deploy
   - `QA-FAIL:` — test fail sau 3 lần retry, cần Claude can thiệp
   - `SECURITY-SENSITIVE:` — bắt buộc nếu commit động vào auth, middleware, policy, rls, migration, permission, role, token, session, password, secret, api route, hoặc input handling (`req.body`, `req.params`, `formData`)

6. Chạy Quality Gate trước khi commit:
   - static audit: import đúng, prop match, logic nhất quán
   - test suite hoặc build phù hợp
   - Playwright/dev server nếu môi trường cho phép
   - UI task: verify against `UI_ACCEPTANCE_CHECKLIST.md` and `UI_DO_NOT_CHANGE.md`
   - nếu gặp `EPERM`, bind port, sandbox, browser không khởi động → ghi `QA-FAIL:` với command + lỗi chính
7. Nếu QA fail → tự fix tối đa 3 retry.
8. Sau 3 retry vẫn fail → `QA-FAIL:` → escalate Claude.
9. Pass → commit + báo Claude review.

### Claude Code — review output Codex
1. Đọc `git diff` + commit message.
2. Validate `ASSUMPTION:` nếu có → ghi quyết định vào `docs/superpowers/decisions.md`.
3. Kiểm tra: đúng scope, test pass, không regression, nhất quán với spec.
4. Nếu commit có `SECURITY-SENSITIVE:` → chạy security review theo checklist trong `CLAUDE.md`.
5. Nếu có vấn đề → gọi Codex lại với feedback cụ thể.
6. **Definition of Done** trước khi bàn giao:
   - [ ] Tất cả tests pass, không regression
   - [ ] `ASSUMPTION:` đã được xác nhận
   - [ ] `ENV-REQUIRED:` nếu có đã được user set
   - [ ] `SECURITY-SENSITIVE:` nếu có đã qua security review
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass; nếu Codex bị sandbox khi chạy Playwright/dev server thì Claude đã chạy trực tiếp
   - [ ] `docs/superpowers/debug-*.md` của feature này đã archive hoặc xóa

### Resume sau khi session bị gián đoạn
1. Đọc `git log` → biết đang ở task nào.
2. Đọc `docs/plan-overview.md` → biết task nào chưa done.
3. Đọc `docs/superpowers/decisions.md` nếu có → nắm quyết định đã xác nhận.
4. Extract task list còn lại → gọi Codex tiếp.

### Fallback — Codex không giải quyết được sau 3 retry

**Feature flow:**
1. Claude đọc `git diff` + log `QA-FAIL:`.
2. Claude viết analysis ngắn vào `docs/superpowers/debug-[feature].md`.
3. Gọi Codex lại với file đó làm context bổ sung.

**Bug fix flow:**
1. Claude đọc `git diff` của 3 lần thử.
2. Claude viết analysis vào `docs/superpowers/debug-[issue].md`.
3. Gọi Codex lại với file đó.
4. Nếu vẫn fail → Claude tự fix bằng Edit/Write ngoại lệ token discipline → thêm `<!-- claude-override: direct-fix after 3 Codex retries [YYYY-MM-DD] -->` vào đầu file sửa.

---

## Code Intelligence — GitNexus MCP

Dự án dùng GitNexus (MCP `npx gitnexus mcp`) để index toàn bộ codebase. Codex có thể gọi các tools sau trực tiếp.

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
- `detect_changes()` trước commit — verify chỉ sửa đúng scope.
- Index stale? Chạy `node .gitnexus/run.cjs analyze` từ project root.

---

## Do NOT

- Push code chưa pass tests.
- Retry QA quá 3 lần mà không escalate.
- Tự thêm dependencies không có trong plan. Ghi `ASSUMPTION:` và báo Claude approve trước.
- Bỏ qua code review khi có code review skill.
- Thêm project-specific rules vào file này. Đặt vào `rules/[tool].md` trong project.
- Âm thầm lệch spec. Nếu implementation cần lệch → ghi `ASSUMPTION:` → dừng → báo Claude cập nhật spec trước.

---

*Cập nhật: 2026-06-06 (rev11: direct Codex operating contract + materialized shared rules)*

<!-- template: 2026-06-06 -->
