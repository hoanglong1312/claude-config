@~/.claude/templates/shared-agent-rules.md

# CLAUDE.md — Code Project (reflex core)

Reflex mọi code task. Reference chi tiết → slash command (xem Pointer cuối file).
init stamp command vào project khi type = code.

## Plugin code — bật theo project

Global tắt superpowers/caveman/ponytail (giữ luồng sáng tạo sạch). Code project bật lại trong `.claude/settings.json` (merge, không replace):
```json
{ "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "caveman@caveman": true,
    "ponytail@ponytail": true
} }
```
Web/UI: KHÔNG bật `ui-ux-pro-max` mặc định (chỉ bật tạm khi dựng design system mới) · Supabase thêm `"supabase@claude-plugins-official": true`.

## Superpowers — bắt buộc trong code project

Trước mỗi response: classify intent. 1% chance skill áp dụng → invoke.

| Trigger | Skill bắt buộc |
|---|---|
| Bug / lỗi / không work / crash | `superpowers:systematic-debugging` TRƯỚC KHI đề xuất fix |
| Fix xong bất kỳ thứ gì | `superpowers:verification-before-completion` TRƯỚC KHI báo done |
| "merge" / "push" / "PR" / "xong rồi" | `superpowers:requesting-code-review` |
| Feature mới / "nên làm gì" | `superpowers:brainstorming` |
| UI mới / cần mockup | `wireframe` → xem design pipeline bên dưới |
| Auth / payment / RLS / Supabase security | `/review` (hook `security-gate.py` chặn commit) |

Không invoke khi: fix 1 dòng rõ ràng, task đã hoàn toàn rõ ràng.

## Trục 1 — AI nào viết code

| Vai | Tốn | Làm |
|---|---|---|
| **Opus = não** (main) | quota Claude, đắt | làm rõ yêu cầu, plan, quyết what/why, review diff, MCP-write, nói chuyện user |
| **Haiku = chân** (subagent `model: haiku`) | quota Claude, rẻ | dò `file:dòng`, chạy lại build/test/lint, sửa cơ học có spec rõ — trả **bằng chứng**, không kết luận |
| **Codex = tay** (`/codex-exec`) | quota OpenAI, không ăn Claude | viết/sửa code, test, build, commit; review chéo plan (agent `reviewer`) |
| **Sonnet = tay dự phòng** (subagent `model: sonnet`, `isolation: worktree`) | quota Claude, vừa | chỉ khi Codex lỗi hạ tầng (xem "Codex lỗi") |

**Mọi code change qua Codex.** Claude tự viết code CHỈ khi:
- Thao tác **MCP-write** (Supabase `apply_migration`, INSERT/UPDATE/DELETE + verify) — khó undo, Claude cầm.
- Codex lỗi theo mục "Codex lỗi" bên dưới (A: hạ tầng → Sonnet/Opus; C: lặp 3 lần → Opus).
- File **.md** (plan, spec, rule).

**Luồng chuẩn:** làm rõ (Opus) → dò vùng chưa biết (Haiku ×2–3 song song) → plan (Opus) → review chéo plan (Codex) → code từng task (Codex, tuần tự trên cùng thư mục; song song chỉ khi mỗi Codex có worktree riêng + không chung file) → chạy lại build/test độc lập (Haiku) → review diff (Opus) → `/ship` (Opus).

**Opus review diff — bảng kiểm:** (1) sửa file ngoài phạm vi task? (2) **test bị sửa/xoá/skip?** — cách "pass giả" phổ biến nhất (3) `ASSUMPTION:` mâu thuẫn `decisions.md`? (4) đụng auth/api/migration → `/review`.

Read MCP (nếu có) và Supabase SELECT → Codex tự làm được.

**Cách gọi Codex → `/codex-exec`.**

## Codex lỗi — phân loại trước, xử lý sau

| Loại | Dấu hiệu | Xử lý | Tính vào số lần fail? |
|---|---|---|---|
| **A. Hạ tầng** | codex không có / chưa login / hết quota OpenAI / timeout / mạng / companion crash | Haiku lấy nguyên văn lỗi → lỗi tạm thì thử lại **1 lần** → vẫn lỗi: Sonnet subagent (`isolation: worktree`) làm **cùng brief**; task nhỏ (≲20 dòng, 1 file) → Opus tự sửa. Báo user 1 dòng: "Codex lỗi [lý do], đang dùng Sonnet" | Không |
| **B. Đầu ra sai** | không diff / lệch spec / `QA-FAIL:` / sửa lan file khác | `SendMessage` lại **chính agent đó** kèm output lỗi nguyên văn + `file:dòng` (không giao lại từ đầu) | Có |
| **C. Lặp** | cùng triệu chứng lần 2 | Đổi executor vô ích — lỗi ở chẩn đoán/spec. Opus `systematic-debugging` → viết lại spec / chia nhỏ task → giao lại Codex. Lần 3 cùng triệu chứng → Opus sửa trực tiếp, ghi `<!-- claude-override: direct-fix after 3 Codex retries [date] -->` | Có |
| **D. Âm thầm** | báo xong nhưng test bị sửa/skip, catch nuốt lỗi, tính năng không chạy | Chỉ bắt được ở bước Haiku chạy lại + Opus đọc riêng diff test. Xử lý như B, ghi rõ "không được sửa test để pass" | Có |

Hết quota OpenAI → A. Hết quota Claude giữa chừng → Codex làm tiếp độc lập theo `AGENTS.md` ("When Working Without Claude") — nên trạng thái task **luôn** phải nằm trong `docs/plan-overview.md`. Hết cả hai → ghi trạng thái vào plan, dừng, báo user.

## Trục 2 — Điều tra trước khi fix

Bug / lỗi / không work → **`superpowers:systematic-debugging`** (reproduce trước, không đoán). Không tự chế phân loại ở đây.

## Codex async loop

`Agent` tool chạy nền — Claude Code tự báo khi agent xong, KHÔNG poll bằng `ScheduleWakeup`. Nhận notification xong:
```
Haiku chạy lại build/test (output nguyên văn) → Opus đọc git diff theo bảng kiểm → UI diff? /frontend-verify → migration diff? verify DB → lỗi? phân loại theo "Codex lỗi"
```
Mechanics đầy đủ (companion resume, autocommit) → `/codex-exec`.

## Token Discipline — Claude main

**KHÔNG:**
- Đọc full source để lấy context khi Codex tự đọc được.
- Grep/trace lan man khi debug. Dò vị trí/thu bằng chứng nhanh → Haiku; điều tra sâu (repro, trace runtime) → viết investigation plan → giao Codex (trừ signal dưới).
- Paste nội dung file vào Codex prompt.
- Dùng Edit/Write cho file code (.js/.jsx/.py/.sql) — giao Codex.
- Dispatch Claude subagent làm middleman chuyển lời cho Codex (Haiku chỉ dò + verify, không chuyển tiếp task).

**CHỈ:**
- Đọc `git log` / `git diff`.
- Viết/sửa file .md (plan, spec, rule).
- Gọi Codex với goal + spec path + constraints.
- Quyết kiến trúc trước khi giao Codex.
- Đọc/grep source trực tiếp CHỈ khi ≥1 signal: silent-failure (no error, 0 rows affected) · cần cross-ref đồng thời DB schema+RLS+code · đối chiếu MCP data với code · Codex QA-FAIL 2+ lần cùng symptom. Không signal → viết investigation plan → giao Codex.

**Structural-first:** với câu hỏi về symbol/call-graph ("X định nghĩa đâu", "ai gọi Y", "sửa Z vỡ gì", trace flow) → xác định file và đọc callers/callees trước khi grep lan man. Grep/Read thẳng là ĐÚNG tool khi: tìm chuỗi text literal · file đã biết tên · file .md/config · repo không phải code.

## Definition of Done

Trước khi báo "xong"/commit → chạy **`/ship`** (verify + review + diff scope + ASSUMPTION + migration version + quiz-gate). Fail-loud: chưa qua /ship = chưa done.

## Security trigger

Diff đụng `**/auth/**` · `**/middleware/**` · `**/api/**` · `**/*migration*` · `**/*rls*` → chạy **`/review`** (security checklist). Enforce bằng hook thật: `~/.claude/hooks/security-gate.py` chặn `git commit` khi staged diff đụng path nhạy cảm mà `.claude/.security-reviewed` chưa được /review touch trong 30 phút.

## ASSUMPTION / decisions

Codex commit có `ASSUMPTION:` → Claude quyết + append `docs/superpowers/decisions.md` NGAY (không để session sau). Codex đọc file này trước mỗi executing-plans.

## Blindspot scout (trước plan)

Task đụng vùng code chưa quen / feature mới nhiều file → TRƯỚC khi viết plan, scout tìm unknown unknowns: code search/callers-callees + `git log` vùng liên quan + docs/architecture.md. Output = **unknown map** ngắn (3-5 dòng: đã biết gì, chưa biết gì, rủi ro ở đâu) đặt đầu plan. Unknown chỉ user trả lời được → gộp vào câu hỏi CLARIFY, không đoán. Task nhỏ vùng quen → skip, không cần ghi.

Khác Plan cross-review bên dưới: scout chạy TRƯỚC plan (định hình plan), cross-review chạy SAU plan (bắt lỗi plan). Không thay nhau.

## Plan cross-review (trước execute)

Plan xong, TRƯỚC khi dispatch execute → giao Codex **review chéo plan** (1 dispatch riêng, read-only, brief yêu cầu agent `reviewer`; Codex lỗi hạ tầng → Sonnet subagent review thay): đối chiếu plan với codebase thật — file/symbol nêu trong plan có tồn tại không, impact đủ blast radius chưa, thiếu bước nào. Codex trả `PLAN-OK` hoặc `PLAN-GAP: [vấn đề]`. Có PLAN-GAP → Claude sửa plan trước, không execute plan chưa qua review. Plan nhỏ (≤2 task, 1 file) → skip được, ghi rõ skip.

## UI feature mới — design pipeline

Thứ tự: `/wireframe` (user flow + spec table, user duyệt) → design token theo `rules/design-system.md` (chưa có file → sinh 1 lần, có thể bật tạm `ui-ux-pro-max` cho riêng bước này rồi tắt; chốt token vào file, không sinh lại mỗi màn) → mockup 2–3 bản bằng Stitch MCP (Claude gọi trực tiếp — Codex exec không thấy Stitch; project chưa nối Stitch thì dùng `frontend-design` direction), user chọn bản, Claude không tự chọn → Codex code theo `projectId`/`screenId` đã duyệt + token → `/frontend-verify`. Plan link tới wireframe/mockup đã duyệt thay vì tả UI bằng chữ. Sửa UI nhỏ trên màn có sẵn → skip wireframe + mockup, vào thẳng build.

Nối Stitch cho project: `.mcp.json` → `{"mcpServers":{"stitch":{"type":"stdio","command":"/Users/giinlow./.codex/stitch-mcp-proxy.zsh"}}}` + `.claude/settings.local.json` → `{"enabledMcpjsonServers":["stitch"]}`.

## Plan tracking

Feature mới / execute plan nhiều task → `docs/plan-overview.md` (task + status). Format + workflow → **`/plan-track`**.

`TaskCreate`/`TaskUpdate` nội bộ Claude không persist ra ngoài session — Codex không đọc được. Việc nhiều bước có khả năng cần Codex làm tiếp khi Claude hết quota/session ngắt giữa chừng → mirror status sang `docs/plan-overview.md` song song với `TaskCreate`/`TaskUpdate`, không chỉ dùng task nội bộ.

## Pointer — command / skill on-demand

| Cần | Dùng |
|---|---|
| Dispatch Codex (script, template, review kết quả) | `/codex-exec` |
| Wireframe + spec màn hình trước khi code UI | `wireframe` skill |
| Design system (style/palette/typography, 1 lần) | bật tạm `ui-ux-pro-max` → chốt `rules/design-system.md` → tắt |
| Mockup UI 2–3 bản | Stitch MCP (Claude gọi) |
| Tạo/sửa ảnh bitmap | skill `codex-image` — BẮT BUỘC (Cockpit + `gpt-image-2.5`), không đường khác |
| Bản đồ plugin/skill theo loại project | `~/.claude/templates/toolkit.md` |
| Code review + security 11-loại | `/review` |
| Chạy test suite | `/verify` |
| Gate trước commit (= DoD) | `/ship` |
| DB migration (ai viết/apply/verify) | `/db-migrate` |
| UI verify (Vite build, browser, Playwright) | `/frontend-verify` |
| Plan task format + status | `/plan-track` |
| Debug có phương pháp | `superpowers:systematic-debugging` |
| Viết plan | `superpowers:writing-plans` |

## Cấu trúc CLAUDE.md project

Thứ tự @include bắt buộc: template → rules → context.
```
@~/.claude/templates/code-project.md
@rules/*.md          ← DB schema, quirk tool — thứ template KHÔNG có
@context/architecture.md
```
`rules/*.md` KHÔNG restate global workflow — chỉ thứ project-specific.
