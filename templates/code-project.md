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

→ Sau dispatch có `agentId`: **BẮT BUỘC `ScheduleWakeup` ngay cùng response** (hook PostToolUse:Agent sẽ nhắc). Delay theo task: nhỏ 60–120s · vừa/dài 270s. Không chọn 300s+ khi poll Codex — cache TTL 5 phút, ≤270s giữ cache ấm.
```
wake → SendMessage hỏi status
  xong → git diff (so khớp plan/spec) → build/test → UI diff? /frontend-verify → migration diff? verify DB
  chưa → ScheduleWakeup(cùng delay) lại
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

**GitNexus-first (câu hỏi structural):** project có index + câu hỏi dạng symbol/call-graph ("X định nghĩa đâu", "ai gọi Y", "sửa Z vỡ gì", trace flow) → `query→context→trace` TRƯỚC grep/Read (xem `rules/gitnexus.md`). Grep/Read thẳng là ĐÚNG tool khi: tìm chuỗi text literal · file đã biết tên · file .md/config · repo không phải code.

Repo code nhiều file chưa có `.gitnexus/` → đề xuất index 1 lần (`npx gitnexus analyze`); user từ chối hoặc task chỉ cần literal search → grep bình thường, không dừng cứng.

## Definition of Done

Trước khi báo "xong"/commit → chạy **`/ship`** (verify + review + diff scope + ASSUMPTION + migration version + quiz-gate). Fail-loud: chưa qua /ship = chưa done.

## Security trigger

Diff đụng `**/auth/**` · `**/middleware/**` · `**/api/**` · `**/*migration*` · `**/*rls*` → chạy **`/review`** (security checklist). Enforce bằng hook thật: `~/.claude/hooks/security-gate.py` chặn `git commit` khi staged diff đụng path nhạy cảm mà `.claude/.security-reviewed` chưa được /review touch trong 30 phút.

## ASSUMPTION / decisions

Codex commit có `ASSUMPTION:` → Claude quyết + append `docs/superpowers/decisions.md` NGAY (không để session sau). Codex đọc file này trước mỗi executing-plans.

## Blindspot scout (trước plan)

Task đụng vùng code chưa quen / feature mới nhiều file → TRƯỚC khi viết plan, scout tìm unknown unknowns: GitNexus `query/context` + `git log` vùng liên quan + docs/architecture.md. Output = **unknown map** ngắn (3-5 dòng: đã biết gì, chưa biết gì, rủi ro ở đâu) đặt đầu plan. Unknown chỉ user trả lời được → gộp vào câu hỏi CLARIFY, không đoán. Task nhỏ vùng quen → skip, không cần ghi.

Khác Plan cross-review bên dưới: scout chạy TRƯỚC plan (định hình plan), cross-review chạy SAU plan (bắt lỗi plan). Không thay nhau.

## Plan cross-review (trước execute)

Plan xong, TRƯỚC khi dispatch execute → giao Codex **review chéo plan** (1 dispatch riêng, read-only): Codex dùng GitNexus `query/context/impact` đối chiếu plan với codebase thật — file/symbol nêu trong plan có tồn tại không, impact đủ blast radius chưa, thiếu bước nào. Codex trả `PLAN-OK` hoặc `PLAN-GAP: [vấn đề]`. Có PLAN-GAP → Claude sửa plan trước, không execute plan chưa qua review. Plan nhỏ (≤2 task, 1 file) → skip được, ghi rõ skip.

## Plan tracking

Feature mới / execute plan nhiều task → `docs/plan-overview.md` (task + status). Format + workflow → **`/plan-track`**.

`TaskCreate`/`TaskUpdate` nội bộ Claude không persist ra ngoài session — Codex không đọc được. Việc nhiều bước có khả năng cần Codex làm tiếp khi Claude hết quota/session ngắt giữa chừng → mirror status sang `docs/plan-overview.md` song song với `TaskCreate`/`TaskUpdate`, không chỉ dùng task nội bộ.

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
