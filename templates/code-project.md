# CLAUDE.md — Code Project

## Phân Công Vai Trò AI

| Phase | Công cụ | Việc làm |
|-------|---------|----------|
| Spec + Planning | Claude main (Superpowers skills) | brainstorming → spec → `writing-plans` → append vào `docs/plan-overview.md` → compile HTML |
| Execution + QA | Codex Plugin (`codex:codex-rescue` subagent) | executing-plans, TDD, commit |
| Orchestration + Review | Claude main | kiến trúc, approve plan, review git diff, code review, update HTML |

- Claude dùng `writing-plans` skill trực tiếp (Superpowers plugin) — Codex KHÔNG invoke được skill này
- `subagent-driven-development` của Claude main KHÔNG dùng → Codex thay thế cho execution
- Workflow chi tiết của Codex xem trong `AGENTS.md`

## Codex Delegation Rules

**Khi nào SKIP Codex — Claude tự làm:**
- Task < 5 phút (1-2 file, change rõ ràng) → Claude dùng Edit/Write trực tiếp
- Config change, rename, comment/doc update → không cần Codex
- Task cần MCP tools (Supabase, browser, external API) → Claude làm Phase 1, Codex làm code fix
- Sau Codex fail 3 lần → Claude direct fix (xem Fallback section)

**Delegate sớm, prompt cấp cao:**
- Chỉ cần: WHAT cần sửa + file/spec path + constraints ngắn gọn
- KHÔNG cần: line numbers, exact code, paste source dài
- Codex tự tìm HOW (đọc file, locate code, viết fix)

**Parallel agents chỉ khi thực sự độc lập:**
- Được parallel: các file không share prop/type/interface với nhau
- KHÔNG parallel: agent A thêm prop/type/interface mà agent B sẽ dùng
- Khi có dependency: gộp vào 1 agent hoặc chạy tuần tự

**Claude giữ lại:**
- MCP tools / external APIs / Supabase write + verify operations
- Architecture decisions + final review qua `git diff` và commit message
- Playwright/dev server chỉ khi Codex báo `EPERM`, lỗi bind port, sandbox, hoặc browser không khởi động được
- Root cause investigation khi cần đọc nhiều nguồn đồng thời (DB schema + code + RLS policies + React data flow)

**Codex đảm nhận:**
- Code changes, unit/integration tests, `npm run build`
- Playwright/dev server nếu môi trường cho phép
- Commit từng task hoàn chỉnh

## Project Bootstrap — Kiểm Tra Khi Bắt Đầu Project Mới

Khi nhận project mới hoặc bắt đầu session đầu tiên, Claude tự check (không cần user nhắc):

```bash
# 1. Unit test framework có chưa?
cat package.json | grep -E '"vitest|jest|mocha"'
# Nếu chưa có → hỏi user: "Cài Vitest để có feedback loop nhanh cho Codex không?"

# 2. E2E test có chưa?
ls e2e/ || ls tests/ || ls playwright.config.*
# Nếu chưa → không bắt buộc, nhưng note cho user

# 3. Build script có không?
cat package.json | grep '"build"'
```

**Nếu unit test chưa có → recommend cài Vitest (React/Vite projects):**
```bash
npm install -D vitest @vitest/ui
# Thêm vào package.json scripts:
# "test": "vitest run",
# "test:watch": "vitest"
```

**Lý do quan trọng:** Không có unit test → Codex không có feedback loop → phải chờ Claude chạy Playwright → chậm 10x.

---

## Quy Trình Execution

### Feature mới
1. Claude: Superpowers `brainstorming` → spec → lưu `docs/superpowers/specs/YYYY-MM-DD-[feature]-design.md`
2. Claude: invoke `writing-plans` skill → đọc codebase + spec → tạo technical checklist → append section mới vào `docs/plan-overview.md` (hybrid) → chạy `html-eff` → compile HTML
3. Claude self-review plan → approve hoặc revise trực tiếp (optional: dispatch Codex review cho plan phức tạp)
4. User mở `docs/plan-overview.html` → review → confirm trước khi Codex chạy
5. Gọi Codex: `executing-plans` → Codex nhận task list do Claude extract từ `plan-overview.md`, tự parallelize task độc lập, implement + TDD + commit
6. Claude review qua `git diff` + commit message
7. Nếu có vấn đề → gọi Codex lại với feedback cụ thể
8. **Definition of Done** trước khi bàn giao:
   - [ ] `npm test` pass (unit tests) — nếu project có unit test framework
   - [ ] Tất cả tests pass, không regression
   - [ ] Nếu task có UI interaction → Playwright test pass (invoke `playwright-testing` skill)
   - [ ] `ASSUMPTION:` (giả định) đã được xác nhận (validate)
   - [ ] `ENV-REQUIRED:` (nếu có) đã được user set
   - [ ] `SECURITY-SENSITIVE:` (nếu có) đã qua security review — không có lỗ hổng
   - [ ] Không có package mới ngoài plan
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass
   - [ ] `docs/superpowers/debug-*.md` của feature này đã archive hoặc xóa

### Bug fix / small change

**Phân loại bug trước — bắt buộc:**

| Type | Dấu hiệu | Flow |
|------|----------|------|
| S | 1-2 file, triệu chứng rõ, error message cụ thể | Codex mini root-cause → fix |
| M/L | Cross-file, unclear cause, nhiều suspect | 2-phase đầy đủ |
| SYS | Silent failure: no error + 0 rows affected + data không đổi sau action | Claude Phase 1 trực tiếp |

**Bug S — fast path:**
1. Claude đọc symptom → viết fix instruction ngắn (file + expected behavior)
2. Giao Codex làm mini investigation trước khi fix:
   ```
   Symptom: [mô tả bug]
   Suspect file(s): [1-2 file/pattern]
   Root cause: [nguyên nhân ngắn]
   Verification: [test/build/check sẽ chạy]
   ```
3. Codex fix theo root cause đã tìm, chạy verification, commit


**Bug M/L — Phase 1 — Investigation (Codex làm, không ăn main context)**

1. Claude đọc `git log` / `git diff` → hiểu symptom
2. Claude viết investigation plan vào `docs/superpowers/debug-[issue].md`:
   ```
   Symptom: [mô tả bug]
   Suspect files: [danh sách file/pattern cần kiểm tra]
   Questions: [những gì cần tìm — function nào, data flow nào, error nào]
   ```
3. Gọi Codex (read-only task): `/codex:rescue Đọc file + grep theo plan sau, không fix, chỉ báo findings: [path debug file]`

**Exception — Claude tự làm Phase 1 khi (bao gồm bug SYS):**
- Silent failure (bug type SYS): no error nhưng action không có effect
- Cần cross-reference đồng thời nhiều nguồn khác loại (DB schema + RLS policy + code logic)
- Cần đọc đồng thời Supabase data/state, RLS, React state/data flow, logs, hoặc MCP-only context

⚠️ Trong exception: token discipline tạm suspended cho investigation phase — Claude được đọc code + grep + dùng MCP tools để trace root cause.

**Phase 2 — Fix (Claude phán đoán, Codex thực thi)**

4. Claude đọc findings → xác định root cause → quyết định approach
5. Append root cause + approach vào `docs/superpowers/debug-[issue].md`
6. Gọi Codex fix: `/codex:rescue Fix theo approach trong [path debug file]`
7. Review `git diff` sau khi Codex xong

**Fallback nếu Codex fix sai 3 lần:**
1. Claude đọc `git diff` + commit log của 3 lần thử → update `debug-[issue].md`
2. Spawn Explore subagent: đọc files + grep + trace theo suspect list trong debug file → trả summary
3. Claude đọc summary → xác định root cause → update approach trong `debug-[issue].md`
4. Gọi lại Codex với file đó làm context bổ sung
5. Nếu vẫn fail → Claude direct fix bằng Edit/Write → thêm `<!-- claude-override: direct-fix after 3 Codex retries [YYYY-MM-DD] -->` vào đầu file sửa

### Resume sau khi session bị gián đoạn

**Nếu Codex đang chạy dở khi interrupt:**
1. Chạy resume helper trước (xem lệnh ở trên) → check `available: true`
2. Nếu có thread dở → hỏi user: tiếp tục thread cũ hay bỏ?
3. Tiếp tục → dùng `SendMessage` với thread ID cũ
4. Bỏ → ghi nhận task đó là `interrupted` trong plan file trước khi tạo thread mới

**Nếu Claude session bị interrupt (không phải Codex):**
1. Đọc `git log --oneline -10` → biết commit cuối là task nào
2. Đọc plan file trong `docs/superpowers/specs/` → xác định task nào `in_progress` chưa commit
3. Đọc `docs/superpowers/decisions.md` (nếu có) → nắm quyết định đã confirm
4. Nếu task dở chưa có code → resume từ đầu task đó
5. Nếu task dở đã có code nhưng chưa commit → đọc `git diff` → quyết định commit hay rollback

## Cách Gọi Codex

**Cơ chế chuẩn trong Claude main:** dùng `Agent` tool với `subagent_type: "codex:codex-rescue"`. Không gọi `Skill("codex:rescue")` để execute task, vì skill đó chỉ là wrapper/hướng dẫn và có thể làm lệch job state.

**Trước mỗi task Codex:**
1. Chạy helper resume:
   ```bash
   CODEX_COMPANION=$(ls -d "$HOME/.claude/plugins/cache/openai-codex/codex/"*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)
   node "$CODEX_COMPANION" task-resume-candidate --json
   ```
2. Nếu `available: true`, hỏi user tiếp tục thread hay tạo thread mới.
3. Nếu chạy mới, route bằng `Agent`:
   - `subagent_type`: `codex:codex-rescue`
   - **Default: foreground** — prompt bắt đầu bằng `--wait` (Claude chờ, nhận kết quả trực tiếp)
   - **⚠️ Agent tool luôn async:** dù có `--wait`, result vẫn trả về ngay với `agentId`. Sau khi dispatch, nếu result có `agentId` → **bắt buộc set `ScheduleWakeup(270s)` ngay trong cùng response đó** — không đợi user nhắc.
   - Wakeup prompt: `SendMessage` tới agentId hỏi status → nếu xong: `git diff + npm run build + npm test`; nếu chưa xong: `ScheduleWakeup(270s)` tiếp. Loop đến done hoặc fail.
   - Background chỉ dùng khi task ước tính >10 phút — prompt bắt đầu bằng `--background`. Cùng wakeup loop như foreground.
   - prompt chỉ gồm goal + file/spec path + constraints + verification.

**Không dùng:**
- `Skill("codex:rescue")` để execute task.
- `mcp__codex__codex` trừ khi OpenAI credential trực tiếp đã active; project này ưu tiên `codex-plugin-cc` qua 9Router.
- `/codex:status` trong shell (`! /codex:status` sai); slash command phải chạy trong Claude command layer.

**Fallback khi Agent route lỗi:**
1. Nếu subagent trả job ID nhưng `/codex:status` không thấy, coi là dispatch lỗi.
2. Thử direct companion task bằng Bash một lần:
   ```bash
   CODEX_COMPANION=$(ls -d "$HOME/.claude/plugins/cache/openai-codex/codex/"*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)
   node "$CODEX_COMPANION" task --wait "<task>"
   ```
3. Nếu Codex fail 2+ lần cùng symptom hoặc không tạo diff/commit, Claude được phép direct fix theo fallback, ghi rõ lý do trong response.


**Format multi-step task khi viết plan (step → verify):**
```
1. [Bước] → verify: [check cụ thể]
2. [Bước] → verify: [check cụ thể]
3. [Bước] → verify: [check cụ thể]
```
Mỗi bước có verify riêng → Codex loop độc lập đến khi pass, không cần hỏi lại.

**Template prompt — executing-plans:**
```
Tasks: [Claude extract ### Task headings + steps từ docs/plan-overview.md]
Decisions: docs/superpowers/decisions.md  ← đọc trước khi bắt đầu
Constraints: [copy từ writing-plans prompt]
Goal: execute theo task list, dùng dispatching-parallel-agents cho task không có dependency
Khi start task: update `**Status:** pending` → `**Status:** in_progress` trong plan-overview.md
Khi done task: update → `**Status:** done` + `**Commit:** [hash]`
Khi blocked: update → `**Status:** blocked` + `**Reason:** QA-FAIL: [lý do]`
Nếu gặp mơ hồ: ghi ASSUMPTION: (giả định) vào commit message
```

Codex tự đọc source file để lấy context — không paste code vào prompt.

## DB / RLS Pattern

**Phân công cứng:**

| Việc | Ai làm |
|------|--------|
| Viết SQL migration file | Codex |
| Apply migration | Claude (`mcp__supabase__apply_migration`) |
| Verify kết quả | Claude (`mcp__supabase__execute_sql`) |
| Tra schema khi viết SQL | Codex (nếu có read-only MCP) |

**Codex read-only Supabase (tùy chọn, recommended):**

Thêm vào `.codex/config.toml` trong project root:
```toml
[mcp_servers.supabase-readonly]
command = "npx"
args = ["-y", "@supabase/mcp-server-supabase@latest", "--access-token", "${SUPABASE_ACCESS_TOKEN}", "--read-only"]
```

Cho phép Codex tự tra `list_tables`, `execute_sql` (SELECT) → ít ASSUMPTION hơn.
Write operations (`apply_migration`, INSERT/UPDATE/DELETE) vẫn do Claude thực thi.

---

## Token Discipline — Claude Main Session

**KHÔNG làm:**
- Đọc toàn bộ file source để lấy context khi Codex có thể tự đọc
- Tự grep/trace source lan man khi debug — mặc định viết investigation plan rồi giao Codex
- Paste nội dung file vào Codex prompt
- Dùng Edit/Write cho file .jsx/.js/.sql
- Dispatch Claude subagent làm middleman

**CHỈ làm:**
- Đọc `git log` / `git diff`
- Viết/sửa file .md (plan, spec, rules) + chạy `html-eff` ngay sau để sync HTML
- Gọi Codex với goal + spec path + constraints
- Quyết định kiến trúc trước khi giao Codex
- Đọc/grep source trực tiếp CHỈ KHI có ít nhất 1 trong các signal sau:
  - Bug type **SYS** (silent failure: no error, 0 rows affected, action không có effect)
  - Cần cross-reference đồng thời: DB schema + RLS policy + code logic (grep đơn thuần không đủ)
  - Cần đối chiếu MCP data với code (Supabase state + React data flow + logs)
  - Codex đã báo `QA-FAIL:` 2+ lần cùng symptom → root cause chưa rõ
  - Không có signal nào trên → viết investigation plan → giao Codex

**CLAUDE.md project — cấu trúc @include chuẩn:**
```markdown
@~/.claude/templates/code-project.md
@rules/supabase.md           ← nếu dùng Supabase
@rules/testing.md            ← nếu có test framework
@context/architecture.md
```
Thứ tự bắt buộc: template → rules → context. Sai thứ tự → rules ghi đè template.

`rules/*.md` nằm ở project root. Không dùng `.claude/rules/` cho project rules mới.

**Khi review plan Codex — checklist:**
- Plan có cover đủ spec không?
- Task có quá lớn không? (1 task = 1 commit reviewable)
- Có dependency nào bị bỏ sót không?

**Khi review output Codex — checklist adversarial:**
- **Auto-trigger:** Sau mỗi task Codex báo done → Claude tự chạy `git diff` ngay, không đợi user nhắc
- Đọc `git diff` + commit message (bắt buộc)
- Grep `ASSUMPTION:` trong commit message ngay — nếu có → append vào `docs/superpowers/decisions.md` TRƯỚC KHI làm bất cứ gì khác (không để sang session sau)
- Kiểm tra: có `ASSUMPTION:` (giả định) nào cần xác nhận không?
  → Nếu có: quyết định + append vào `docs/superpowers/decisions.md`:
  ```
  ## [YYYY-MM-DD] — [feature]
  - ASSUMPTION: [Codex giả định gì]
  - Decision: [Claude quyết định gì]
  - Applies to: [task / file liên quan]
  ```
- Kiểm tra: có `ENV-REQUIRED:` không → nhắc user set trước khi deploy
- Kiểm tra: thay đổi đúng scope task, không thêm feature ngoài
- Kiểm tra: không có package mới ngoài plan (xem `package.json` diff)
- Kiểm tra: test pass, không regression
- Kiểm tra: logic nhất quán với spec — nếu lệch → cập nhật spec ngay

**Security Review — chạy khi:**
- Commit có tag `SECURITY-SENSITIVE:`, HOẶC
- Diff động vào file/path match bất kỳ pattern sau (dù Codex không gắn tag):
  `**/auth/**`, `**/middleware/**`, `**/*policy*`, `**/*rls*`, `**/*migration*`,
  `**/api/**`, file có `req.body` / `req.params` / `formData` trong thay đổi mới

| Loại lỗ hổng | Kiểm tra gì trong diff |
|---|---|
| SQL Injection | Raw query có nối chuỗi user input? → phải dùng parameterized query |
| RLS hole | Bảng mới có RLS policy? Policy cover đủ roles (anon/authenticated/service_role)? |
| Auth bypass | Endpoint/route mới có auth middleware/guard? |
| IDOR | Query theo ID có filter `WHERE user_id = auth.uid()`? User A lấy được data user B? |
| XSS | User input render vào HTML không qua sanitize/escape? |
| Hardcoded secret | Có string literal trông như key/token/password trong code? |
| Input validation | User input từ `req.body`/`req.params`/`formData` có validate tại API boundary? |
| Privilege escalation | Endpoint admin có kiểm tra role trước khi xử lý? |
| CSRF | Form POST/PUT/DELETE có CSRF token hoặc SameSite cookie không? |
| Rate limiting | Endpoint public/auth mới có rate limit không? |
| Error leakage | Error message trả về client có expose schema/stack trace/internal path không? |

Nếu phát hiện lỗ hổng → KHÔNG approve → gọi Codex fix với mô tả lỗ hổng cụ thể.

# HTML Visual Workflow

## Nguyên tắc
- `.md` = source of truth (spec, plan, status) — git-friendly, diffable
- `.html` = rendered view, KHÔNG edit trực tiếp — generate từ `.md` bằng `html-eff` CLI
- Claude viết `.md` content (hybrid Markdown + YAML component blocks) + chạy `html-eff` ngay sau (1 Bash command)
- Codex: code changes + update `**Status:**` field trong `plan-overview.md` + commit

## Tool Setup (nếu `html-eff` chưa có)

```bash
git clone https://github.com/luisoncpp/html-effectiveness-scripts.git ~/.local/share/html-effectiveness-scripts
cd ~/.local/share/html-effectiveness-scripts && cargo build --release
mkdir -p ~/.local/bin
ln -sf ~/.local/share/html-effectiveness-scripts/target/release/html-effectiveness ~/.local/bin/html-eff
# Thêm vào ~/.zshrc nếu chưa có: export PATH="$HOME/.local/bin:$PATH"
```

Reference gallery (20 demos): https://github.com/ThariqS/html-effectiveness

## Phân Chia File Spec

- `docs/superpowers/specs/YYYY-MM-DD-[feature]-design.md` — text spec, Codex đọc khi implement
- `docs/superpowers/specs/YYYY-MM-DD-[feature]-design.html` — generated visual, KHÔNG edit trực tiếp

Spec đơn giản: plain Markdown. Spec phức tạp: Claude viết hybrid (Markdown + YAML components) → compile.

## Wireframe → Mockup Process

**Thứ tự cố định khi brainstorm UI/layout:**
1. **ASCII wireframe trong chat** — chốt structure, layout, zones. Nhanh, sửa tự do trong brainstorm loop.
2. **HTML mockup** (html-eff hoặc standalone) — chỉ sau khi layout đã được approve.

Không gen HTML mockup trước khi layout ASCII đã confirmed. ASCII wireframe = lo-fi, đủ để chốt structure.

## UI Design Handoff Artifacts

Khi task là design UI mới, redesign, landing page, portfolio, hoặc component có visual direction rõ ràng, Claude/ChatGPT phải tạo đủ artifact trước khi Codex implement:

```text
UI_PREVIEW.html
UI_SPEC.md
UI_STYLE_GUIDE.md
UI_ACCEPTANCE_CHECKLIST.md
UI_DO_NOT_CHANGE.md
```

Nội dung bắt buộc:

| File | Nội dung |
|---|---|
| `UI_PREVIEW.html` | Preview visual có layout thật để user xem trước. Generated/rendered artifact; không sửa tay nếu source `.md`/component có thể render lại. |
| `UI_SPEC.md` | Mục tiêu UI, user flow, layout từng màn hình, states, responsive behavior. |
| `UI_STYLE_GUIDE.md` | Màu chủ đạo, font, button/card/input sizes, spacing scale, radius, shadows, icon style. |
| `UI_ACCEPTANCE_CHECKLIST.md` | Checklist để Claude/Codex verify trước khi xong: visual, states, responsive, a11y, no regressions. |
| `UI_DO_NOT_CHANGE.md` | Những thứ Codex không được tự ý đổi: brand colors, copy đã chốt, layout constraints, component behavior, routes/API/contracts. |

`UI_SPEC.md` phải ghi rõ:
- Màu chủ đạo.
- Font.
- Kích thước button/card/input.
- Khoảng cách giữa các khối.
- Layout từng màn hình.
- Trạng thái loading/error/empty.
- Responsive.
- Những thứ Codex không được tự ý đổi.

Codex nhận task UI phải đọc 5 file này trước khi sửa code. Nếu thiếu file hoặc mâu thuẫn, Codex ghi `ASSUMPTION:` và dừng hỏi/đợi Claude cập nhật spec.

## Spec Visual (trước writing-plans)

Sau brainstorming/spec xong, Claude hỏi: "Tạo HTML visual spec không?"
Nếu Có:
1. Claude viết (hoặc convert) `docs/superpowers/specs/[spec]-design.md` sang hybrid format
2. Claude chạy: `html-eff -i docs/superpowers/specs/[spec]-design.md -o docs/superpowers/specs/[spec]-design.html`
   - Nếu html-eff lỗi: báo error ngay, KHÔNG edit .html tay
3. Claude chạy: `open docs/superpowers/specs/[spec]-design.html`
4. User review HTML, confirm rồi mới chạy writing-plans
5. Với UI task, sync nội dung đã chốt vào `UI_PREVIEW.html`, `UI_SPEC.md`, `UI_STYLE_GUIDE.md`, `UI_ACCEPTANCE_CHECKLIST.md`, `UI_DO_NOT_CHANGE.md` trước khi giao Codex.

## Codex Review Gate (Optional)

Sau khi Claude viết spec hoặc plan xong — nếu phức tạp (3+ subsystem, core logic mới, user yêu cầu):
- Dispatch Codex review trước khi tiếp tục
- Claude fix issues từ Codex report → rồi mới generate HTML / execute plan

Prompt template Codex review spec:
```
Review [spec file path]. Check: logical gaps, contradictions, ambiguous requirements, missing error handling. Report: numbered issues, severity (minor/major/blocker), fix. Concise.
```

Prompt template Codex review plan:
```
Review [plan file path]. Check: missing steps, type/method name consistency, placeholder text, wrong commands, untested assumptions. Report: numbered issues, severity, fix. Concise.
```

## Plan Tracker (sau writing-plans)

Sau `writing-plans` hoàn thành:
1. Claude hỏi: "Thêm plan này vào HTML overview không?"
2. Nếu Có: Claude append section vào `docs/plan-overview.md` (hybrid format)
3. Claude chạy: `html-eff -i docs/plan-overview.md -o docs/plan-overview.html` (nếu lỗi: báo error, giữ .html cũ)
4. Claude chạy: `open docs/plan-overview.html`

### Format Task trong plan-overview.md

```markdown
### Task N: [Tên Task]

**Status:** pending
**Commit:** —

Steps:
- [ ] Step 1...
```

Codex update bằng string replace:
- Start: `**Status:** pending` → `**Status:** in_progress`
- Done: `**Status:** in_progress` → `**Status:** done` + `**Commit:** [hash]`
- Blocked: → `**Status:** blocked` + dòng `**Reason:** QA-FAIL: [lý do]`

Codex commit `.md` status cùng code changes, 1 commit per task. Khi dispatch Codex: Claude extract task list từ `.md` → truyền text vào prompt, không truyền HTML.

## Cấu Trúc `docs/`

```
docs/
├── plan-overview.md                      ← source of truth: task list + tiến độ (Claude maintain)
├── plan-overview.html                    ← generated từ .md, KHÔNG edit trực tiếp
└── superpowers/
    ├── specs/
    │   ├── YYYY-MM-DD-[feature]-design.md    ← text/hybrid spec (Claude ghi)
    │   └── YYYY-MM-DD-[feature]-design.html  ← generated visual, KHÔNG edit trực tiếp
    └── decisions.md                          ← quyết định từ ASSUMPTION: (Claude ghi)

UI task artifacts (tạo khi task có UI design/handoff):
├── UI_PREVIEW.html
├── UI_SPEC.md
├── UI_STYLE_GUIDE.md
├── UI_ACCEPTANCE_CHECKLIST.md
└── UI_DO_NOT_CHANGE.md
```

`plan-overview.md` — Claude append section mới sau mỗi `writing-plans`, Codex update `**Status:**` field sau mỗi task xong.
Sau mỗi lần edit `.md`: Claude chạy `html-eff -i docs/plan-overview.md -o docs/plan-overview.html` để sync HTML.
`decisions.md` tích lũy theo thời gian — Codex đọc trước mỗi lần executing-plans để tránh lặp lại câu hỏi đã có đáp án.

## Đồng Bộ CLAUDE.md ↔ AGENTS.md

| Thay đổi | Cập nhật |
|----------|----------|
| Workflow, quy trình mới | `CLAUDE.md` + `AGENTS.md` |
| Ký hiệu mới (`ASSUMPTION:`, `QA-FAIL:`...) | `CLAUDE.md` + `AGENTS.md` |
| Thêm/bỏ tool, stack | `AGENTS.md` Project Context + `context/architecture.md` |
| Rule chỉ liên quan Claude main | `CLAUDE.md` hoặc `rules/*.md` |
| Rule chỉ liên quan Codex | `AGENTS.md` |
| Sửa template `AGENTS.md` | Cập nhật `<!-- template: YYYY-MM-DD -->` ở cuối file |

## Quy Tắc Mở Rộng

**Project-specific tool rules → `rules/[tool].md` trong project root, KHÔNG sửa file global.**

| Loại rule | Đặt ở đâu |
|-----------|-----------|
| Quirk của tool (EPERM, bind port, timeout) | `rules/[tool].md` trong project |
| Pattern riêng của codebase | `context/architecture.md` |
| Convention riêng team | `CLAUDE.md` → `## Project-Specific Rules` |
| Rule áp dụng mọi code project | `~/.claude/templates/code-project.md` |

**⚠️ Local rules KHÔNG được restate global workflow.**  
`rules/*.md` chỉ chứa những gì template KHÔNG có — DB schema, lệnh test cụ thể, quirk tool, pattern codebase.  
Nếu thấy mình đang copy workflow từ template vào local rules → đặt sai chỗ, xóa đi.

## Frontend Build Tool — Vite (standard)

Mọi frontend project mới dùng Vite. Không dùng Create React App (deprecated), không dùng Webpack trừ khi project cũ đã có.

```bash
# Tạo project mới
npm create vite@latest <tên-project> -- --template react-ts

# Templates phổ biến: react-ts, vue-ts, vanilla-ts, svelte-ts
```

Vite ≠ framework. Layer: React/Vue (framework) → Vite (build tool) → Node (runtime).
Dev server mặc định: `http://localhost:5173`. Prod build: `npm run build` → `dist/`.

## UI Verification — Localhost trước, deploy sau

Với bất kỳ thay đổi UI nào, verify trên localhost trước khi deploy:

1. Chạy dev server: `npm run dev` (background)
2. Dùng `cmux browser goto http://localhost:5173` → `cmux browser snapshot` hoặc `cmux browser screenshot` → confirm visual đúng (layout, rendering)
3. Nếu task có user interaction (form submit, click, navigation, auth flow) → invoke `playwright-testing` skill → Claude viết test → chạy → confirm pass
4. Chỉ deploy khi localhost pass

**cmux browser vs Playwright — subagent rule:**
| Tool | Dùng khi | Subagent? |
|------|----------|-----------|
| `cmux browser snapshot/eval` | Tìm lỗi (DOM, network, console) | ✅ Spawn subagent — output nặng |
| Playwright verify | Confirm fix pass | ❌ Main context — output là text |
| Playwright `--headed` debug | Playwright fail, cần xem browser | ✅ Spawn subagent — có screenshot |

**Không mở Chrome hay browser mới.** Dùng cmux in-app browser:
- `⌘⇧L` — mở browser split pane
- `⌥⌘I` — toggle DevTools
- `⌥⌘C` — JS Console
- Agent tương tác CLI: `cmux browser <snapshot|screenshot|click|eval|goto|wait|...>`

**Lợi ích:** Không tốn thời gian deploy vòng, không bị PIN gate hoặc auth chặn như production.

## Deploy Fallback — Vercel webhook broken

Nếu `git push origin main` không trigger Vercel auto-deploy sau 2 phút:

```bash
# Kiểm tra bundle hash
curl -s <production-url> | grep -o 'assets/index-[^"]*\.js'
# Nếu hash cũ → dùng CLI
vercel --prod
```

Root cause: Vercel-GitHub webhook broken → fix bằng disconnect/reconnect GitHub integration trong Vercel dashboard.

## UI/UX Design Reference

Khi thiết kế / implement UI component hoặc cần brand style → fetch:

| Nguồn | Raw URL pattern | Số brands |
|-------|----------------|-----------|
| **awesome-design-md** | `https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/[brand].md` | 73+ |
| **open-design** | `https://raw.githubusercontent.com/nexu-io/open-design/main/design-systems/[brand]/DESIGN.md` | 150 |

Mỗi file có: color palette, typography, spacing, component styling, design tokens.
Brands phổ biến: stripe, linear, vercel, notion, airbnb, shopify, claude, openai.

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
