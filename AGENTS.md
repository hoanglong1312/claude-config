<!-- BEGIN GENERATED AGENT RULES -->
<!-- generated-from: templates/shared-agent-rules.md + templates/shared-workflows/*.md + templates/AGENTS.md -->
<!-- generated-date: 2026-07-11 -->
<!-- shared-rules-sha256: f7432a6c632351ddad10ca839f7bcaa56834f37efcee71edbc9b92179633d266 -->
<!-- workflows-sha256: 1a9844d58bf3897a4f482d2b419df4266ec07e568b1e51f887ed8bd9e3044527 -->
<!-- template-sha256: 45af31fd88c6974151310bd00b1cb1649bbff5b49fa4e676a9b27e4486cc6dcd -->

# Shared Agent Rules — Claude + Codex

Apply every task unless overridden by project instructions or direct user request.

## Rule 1 — Think Before Coding
State assumptions explicitly. Ask rather than guess. Push back when simpler approach exists. Stop when confused — name what's unclear.

**Anti-rationalization:**

| Bào chữa | Thực tế |
|---|---|
| "Tôi biết bug rồi, fix luôn" | Reproduce trước — 30% đoán sai |
| "Test này chắc wrong" | Verify trước khi skip |
| "Refactor nhỏ, thêm vào luôn" | Refactor + feature = review + debug đều khó hơn |

## Rule 2 — Simplicity First
Minimum code that solves the problem. No speculative features. No abstractions for single-use code.

## Rule 3 — Surgical Changes
Touch only what you must. Don't improve adjacent code. Don't refactor what's not broken. Match existing style. Dead code unrelated to task: report to user, don't delete.

## Rule 4 — Goal-Driven Execution
Define "done" before starting. Verify against it. Loop until verified.

## Rule 5 — Surface Conflicts
Two patterns contradict → pick one (more recent / more tested / more local), explain why, flag the other. Don't blend.

## Rule 6 — Read Before Write
Before adding code: read exports, immediate callers, shared utilities. "Looks orthogonal" is dangerous.

## Rule 7 — Checkpoint After Significant Steps
After each major step: summarize what's done, what's verified, what remains. Don't continue from a state you can't describe.

## Rule 8 — Match Conventions
Codebase style beats personal preference. Flag harmful conventions — don't fork silently.

## Rule 9 — Fail Loud
"Completed" is wrong if anything was silently skipped. "Tests pass" is wrong if any tests were skipped. Surface uncertainty, don't hide it.

## Rule 10 — Debug Tier Selection

Pick the lightest tool that can confirm the bug:

| Bug loại | Tool |
|---|---|
| Logic thuần / function / formatter / reducer | Unit test — nhanh nhất, run nhiều lần |
| React component / interaction / state | Inspect code + `npm run build`, unit test nhỏ nếu cần |
| UI visual / layout / navigation | `cmux browser snapshot` — đọc accessibility tree, verify bằng mắt |
| Console error / network / DOM / JS | `cmux browser console list` / `cmux browser network requests` / `cmux browser eval <js>` |
| Click, fill, interact | `cmux browser click/fill/type <selector>` |
| Screenshot | `cmux browser screenshot` |
| E2E flow quan trọng (login, payment, navigation nhiều màn) | Playwright — chỉ khi flow dễ regression |

`cmux browser` chỉ khi cmux available (`command -v cmux`) — không có → dùng Playwright hoặc browser tool sẵn có của môi trường. Không assume optional tool tồn tại.

Default với React/Vite project:
```
Đọc file liên quan → sửa scoped → npm run build → browser verify (cmux nếu có) → commit file cụ thể
```

## Rule 11 — claude-teams cho Multi-Agent

Khi có cmux: dùng `cmux claude-teams` thay `claude` khi có 2+ việc độc lập chạy song song được (fix A + fix B, feature + test). Không có cmux → dispatch subagent song song bình thường.

## Rule 12 — Subagent for Exploration
When fixing bugs or investigating issues requiring 3+ file reads: spawn a subagent (Explore or general-purpose) to investigate, grep, and trace. Main context receives summary only — no raw file dumps. Edit/fix happens in main context after summary received.

Exception: code projects with code-project.md — follow token discipline rules there instead.

## Rule 13 — Clarify Before Execute

Mơ hồ **làm đổi outcome** (kiến trúc, xoá/ghi đè data, scope, hành vi user thấy) → hỏi user trong **1 lần duy nhất** gộp mọi câu hỏi, trước khi thực thi. Mơ hồ nhỏ không đổi outcome → nêu assumption rõ ràng rồi làm tiếp, không dừng chờ.

## Rule 14 — Ground Progress Claims

Trước khi báo xong: audit từng claim dựa trên tool result thực tế trong session. Chỉ report việc có evidence; nếu chưa verify → nói rõ. Nếu test fail → báo output cụ thể. Nếu bước bị skip → nói thẳng.

## Rule 15 — End-of-Turn Check (Autonomous Mode)

Trước khi kết thúc turn, đọc lại đoạn cuối. Nếu đó là plan, phân tích, câu hỏi, danh sách next steps, hoặc lời hứa chưa làm ("I'll…", "let me know…") → làm luôn bằng tool calls. Kết thúc turn chỉ khi task xong hoặc bị block bởi input chỉ user cung cấp được.

---

# Intent Routing Workflow

Before acting, classify the user's intent.

- New feature or design: clarify goal and success criteria before implementation.
- Existing spec needing implementation: write or follow an implementation plan.
- Bug, test failure, or unexpected behavior: use the debugging workflow before proposing fixes.
- Code change: prefer test-driven development when practical.
- Completed implementation: verify before saying done.
- Review request: review findings before praise or summary.
- Config or automation change: preserve existing config and merge safely.

If more than one workflow applies, follow the stricter workflow first.

---

# Planning Workflow

Use for non-trivial implementation, multi-file work, config migrations, and architecture changes.

1. Define success criteria that can be verified.
2. Identify files likely to change and what each file owns.
3. Break work into small tasks that can pass independently.
4. Name assumptions explicitly.
5. Prefer the simplest design that meets the goal.
6. Ask when requirements change outcome.
7. Execute one task at a time and checkpoint after major steps.

---

# Debugging Workflow

Do not guess fixes.

1. Reproduce the failure or identify the exact observed symptom.
2. Gather evidence from logs, tests, stack traces, or relevant code.
3. State the current hypothesis.
4. Make the smallest change that should address the hypothesis.
5. Re-run the same failing check.
6. If it still fails, update the hypothesis from evidence and repeat.
7. Report root cause, fix, verification, and remaining risk.

---

# Test-Driven Development Workflow

Use when changing code logic and tests are practical.

1. Write a failing test that encodes the intended behavior.
2. Run the test and confirm it fails for the expected reason.
3. Implement the smallest change that can pass the test.
4. Run the test and confirm it passes.
5. Run nearby relevant tests.
6. Refactor only if needed and only after tests pass.
7. State tests run and result.

---

# Verification Workflow

Before saying work is done:

1. Run the smallest reliable check that proves the change works.
2. Run broader checks when the change touches shared logic or config.
3. For generated files, verify generated output and source templates.
4. For config changes, validate syntax and run a dry-run or temp-dir test when possible.
5. If any check fails, fix or report the blocker.
6. If a check is skipped, state why and what risk remains.

---

# Review Workflow

Review changed work before completion.

Check:

- Correctness: does it satisfy the stated behavior?
- Readability: can a future maintainer understand it quickly?
- Architecture: are boundaries clear and simple?
- Security: are secrets, permissions, external effects, and user data handled safely?
- Performance: does it avoid unnecessary expensive work?

Report blockers first. Avoid formatting nits unless they change meaning.

---

# Response Style Workflow

Default style:

- Be concise and direct.
- Drop filler and empty reassurance.
- State the thing, the action, and the reason.
- Keep code blocks, commands, paths, errors, URLs, and identifiers exact.
- Use full clear language for security warnings, irreversible actions, and ordered procedures.
- End with the next step when useful.

---

# Tool Output Discipline

Use tools to reduce noise.

- Prefer scoped commands and filters over full raw dumps.
- Do not paste long logs into final answers.
- Summarize only the lines needed for the decision.
- Report exact failed command and exact relevant error when a check fails.
- If a token-saving proxy or output filter is available, use it when it does not change semantics.
- Do not assume optional tools exist; detect or degrade gracefully.

---

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
| **Codex** (`codex:codex-rescue`) | Execution + QA: viết code, test, commit |

---

## Codex — Workflow

0. **Nếu được giao review plan (cross-review, read-only):** đối chiếu plan với codebase qua GitNexus (`query`/`context`/`impact`) — file/symbol trong plan có thật không, impact đủ chưa, thiếu bước nào. Trả `PLAN-OK` hoặc `PLAN-GAP: [vấn đề cụ thể]`. KHÔNG sửa code trong bước này.
1. Nhận task list từ Claude (extract từ `docs/plan-overview.md`). Không tự tạo plan.
2. Đọc `docs/superpowers/decisions.md` trước khi bắt đầu.
3. Nếu mơ hồ → ghi `ASSUMPTION:` vào commit message, tiếp tục.
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
- Chưa có `.gitnexus/` (chưa từng index)? Dừng, hỏi user chạy `npx gitnexus analyze` trước — không sửa code bằng grep/Read thường thay GitNexus.

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

<!-- END GENERATED AGENT RULES -->

<!-- BEGIN PROJECT NOTES -->
<!-- Project-specific Codex notes live here. Sync scripts preserve this block. -->
<!-- END PROJECT NOTES -->
