# CLAUDE.md — Code Project (reflex core)

Reflex mọi code task. Reference chi tiết → slash command (xem Pointer cuối file).
init stamp command vào project khi type = code.

## Trục 1 — AI nào viết code

| Vai | Làm |
|---|---|
| **Claude = não** | plan, review, architecture, quyết what/why, MCP-write |
| **Codex = tay** | viết/sửa code, unit/integration test, build, commit |

**Mọi code change qua Codex.** Claude tự viết code CHỈ khi:
- Thao tác **MCP-write** (Supabase `apply_migration`, INSERT/UPDATE/DELETE + verify) — khó undo, Claude cầm.
- Codex fail **3 lần** cùng symptom → Claude direct-fix (ghi lý do trong response).
- File **.md** (plan, spec, rule).

Read MCP (GitNexus `query/context/impact`, Supabase SELECT) → Codex tự làm được.

**Cách gọi Codex → `/codex-exec`.**

## Trục 2 — Điều tra trước khi fix

Bug / lỗi / không work → **`superpowers:systematic-debugging`** (reproduce trước, không đoán). Không tự chế phân loại ở đây.

## Codex async loop (BẮT BUỘC — forget-prone)

`Agent` tool **LUÔN async** — dispatch Codex trả `agentId` ngay dù có `--wait`. Không set wakeup → Codex chạy nhưng Claude **không bao giờ check kết quả**.

→ Sau dispatch có `agentId`: **BẮT BUỘC `ScheduleWakeup(120s)` ngay cùng response.**
```
wake → SendMessage hỏi status
  xong → git diff → review → build/test
  chưa → ScheduleWakeup(120s) lại
loop tới done/fail
```
Mechanics đầy đủ (companion resume, autocommit) → `/codex-exec`.

## Token Discipline — Claude main

**KHÔNG:**
- Đọc full source để lấy context khi Codex tự đọc được.
- Grep/trace lan man khi debug — viết investigation plan → giao Codex (trừ signal dưới).
- Paste nội dung file vào Codex prompt.
- Dùng Edit/Write cho file code (.js/.jsx/.py/.sql) — giao Codex.
- Dispatch Claude subagent làm middleman.

**CHỈ:**
- Đọc `git log` / `git diff`.
- Viết/sửa file .md (plan, spec, rule).
- Gọi Codex với goal + spec path + constraints.
- Quyết kiến trúc trước khi giao Codex.
- Đọc/grep source trực tiếp CHỈ khi ≥1 signal: silent-failure (no error, 0 rows affected) · cần cross-ref đồng thời DB schema+RLS+code · đối chiếu MCP data với code · Codex QA-FAIL 2+ lần cùng symptom. Không signal → viết investigation plan → giao Codex.

**GitNexus-first:** project có index → `query→context→trace` TRƯỚC grep/Read (xem `rules/gitnexus.md`).

## Definition of Done

Trước khi báo "xong"/commit → chạy **`/ship`** (verify + review + diff scope + ASSUMPTION + migration version). Fail-loud: chưa qua /ship = chưa done.

## Security trigger

Diff đụng `**/auth/**` · `**/middleware/**` · `**/api/**` · `**/*migration*` · `**/*rls*` · file có `req.body`/`req.params`/`formData` mới → chạy **`/review`** (security checklist). Enforce bằng hook, không đợi nhớ.

## ASSUMPTION / decisions

Codex commit có `ASSUMPTION:` → Claude quyết + append `docs/superpowers/decisions.md` NGAY (không để session sau). Codex đọc file này trước mỗi executing-plans.

## Plan tracking

Feature mới / execute plan nhiều task → `docs/plan-overview.md` (task + status). Format + workflow → **`/plan-track`**.

## Pointer — command / skill on-demand

| Cần | Dùng |
|---|---|
| Dispatch Codex (script, template, wakeup loop) | `/codex-exec` |
| Code review + security 11-loại | `/review` |
| Chạy test suite | `/verify` |
| Gate trước commit (= DoD) | `/ship` |
| DB migration (ai viết/apply/verify) | `/db-migrate` |
| UI verify (Vite build, browser, Playwright) | `/frontend-verify` |
| Plan task format + status | `/plan-track` |
| Debug có phương pháp | `superpowers:systematic-debugging` |
| Viết plan | `superpowers:writing-plans` |
| GitNexus reflex | `rules/gitnexus.md` |

## Cấu trúc CLAUDE.md project

Thứ tự @include bắt buộc: template → rules → context.
```
@~/.claude/templates/code-project.md
@rules/*.md          ← DB schema, quirk tool, gitnexus — thứ template KHÔNG có
@context/architecture.md
```
`rules/*.md` KHÔNG restate global workflow — chỉ thứ project-specific.
