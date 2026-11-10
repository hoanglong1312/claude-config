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

## Trục 1 — Phân vai theo cỡ việc (bộ điều phối agent)

Chi tiết + brief + QA-QC + leo thang → skill **`orchestrating-agents`** (nạp ở mọi code task). Phân vai theo **cỡ việc + độ nhạy cảm** (sửa 2026-11-10, đo token kho đợt A/C/D ~57M: builder 32%, architect 22%, general-purpose 13%, phiên chính ~25%, security-reviewer 6%, scout+scribe <2% → mục tiêu giảm ~30%).

| Cỡ | Định nghĩa | Ai code | Review |
|---|---|---|---|
| **NHỎ** | ≤50 dòng, ≤3 file, không đụng tiền/auth/DB/migration/RLS | **phiên chính sửa trực tiếp**, `scout` chạy test | phiên chính đọc diff + output test nguyên văn. Không spec, không architect, không worktree |
| **VỪA** | tính năng 1 màn, không đụng tiền/bảo mật | `builder` (Sonnet), worktree | diff >50 dòng → `architect` review mức medium; ≤50 → phiên chính QC. Không cần spec riêng nếu brief đủ |
| **LỚN** / đụng tiền·auth·DB·RLS | còn lại | `builder` (Sonnet), worktree | đủ quy trình: spec (`architect`) → `security-reviewer` rà spec → builder → `architect` + `security-reviewer` rà diff song song |

| Vai | Model · quota | Làm | Không bao giờ |
|---|---|---|---|
| **Phiên chính** | Opus · Claude | nói chuyện user, chia việc theo cỡ, viết brief, quyết, nghiệm thu, MCP-write; **tự sửa việc NHỎ; sửa luôn lỗi UI vừa thấy trên trình duyệt** | code việc VỪA/LỚN, đọc hàng loạt |
| `builder` | Sonnet · Claude | code + test việc VỪA/LỚN | quyết thiết kế, đoán khi brief mơ hồ |
| `architect` | Opus · Claude | spec/plan, nguyên nhân gốc, review diff — **chỉ việc LỚN hoặc diff >50 dòng**; review spec và review diff là **cùng 1 agent** (SendMessage, không spawn mới) | sửa code |
| `scout` | Haiku · Claude, rẻ | dò `file:dòng`, đọc log/web, chạy build/test/lint — trả **output nguyên văn** | sửa file, quyết đạt/không |
| `scribe` | Haiku · Claude, rẻ | tiến độ, bàn giao, báo cáo, changelog, HDSD | đụng code/config, bịa |
| `security-reviewer` | Opus (ngữ cảnh mới) · Claude | rà bảo mật chỉ đọc, spec TRƯỚC + diff SAU khi đụng auth/api/migration/RLS/bí mật/thanh toán/đầu vào ngoài/installer — **mọi cỡ việc** | sửa bất cứ gì |
| Codex | GPT · OpenAI | ý kiến thứ 2 (`/codex:review`), tạo ảnh (`codex-image`) | code mặc định |

- **Cấm `general-purpose`** trong code project (13% token, không có vai). Tìm/đọc/chạy → `scout`; cần phán đoán → `architect`.
- Fable cần usage credits trên 2 tài khoản Pro (kiểm 2026-11-09, 2026-11-10) → vai rà bảo mật dùng Opus.
- MCP-write (Supabase `apply_migration`, INSERT/UPDATE/DELETE) — khó undo, phiên chính cầm, `scout` verify bằng truy vấn đọc.

**Cổng kiểm màn thật (bắt buộc, TRƯỚC merge):** diff đụng UI → mở app thật trên trình duyệt ở **1440px + 375px**, chặn ghi (dữ liệu chỉ đọc hoặc chặn request ghi), đi đúng luồng đã sửa kể cả trạng thái lỗi/rỗng. Test xanh chưa đủ (đợt kho: test xanh vẫn ra 4 lỗi UI). Lỗi UI thấy trên trình duyệt → phiên đang có ngữ cảnh sửa luôn, không viết brief giao lại.

**Worktree builder:** tạo từ **đúng commit nhánh làm việc** (ghi hash vào brief), không từ `main` (main có thể thiếu `app/`). Builder sửa nhiều file JSX → chạy script kiểm tên chưa khai báo `undef.cjs` (**chưa có — cần tạo**; tạm thời `scout` chạy build và tìm `is not defined` / `no-undef`).

**Review diff — bảng kiểm** (`architect` khi được gọi, còn lại phiên chính): (1) sửa file ngoài phạm vi? (2) **test bị sửa/xoá/skip?** — cách "pass giả" phổ biến nhất (3) `ASSUMPTION:` mâu thuẫn `decisions.md`? (4) đụng auth/api/migration → `/review` + `security-reviewer`.

## Codex lỗi — phân loại trước, xử lý sau

> Chỉ áp khi chủ động giao Codex code (không còn mặc định). Với `builder`: B/C/D giữ nguyên, thay "Codex" bằng "builder".

| Loại | Dấu hiệu | Xử lý | Tính vào số lần fail? |
|---|---|---|---|
| **A. Hạ tầng** | codex không có / chưa login / hết quota OpenAI / timeout / mạng / companion crash | `scout` lấy nguyên văn lỗi → lỗi tạm thì thử lại **1 lần** → vẫn lỗi: `builder` (`isolation: worktree`) làm **cùng brief**, kể cả task nhỏ. Báo user 1 dòng: "Codex lỗi [lý do], đang dùng builder (Sonnet)" | Không |
| **B. Đầu ra sai** | không diff / lệch spec / `QA-FAIL:` / sửa lan file khác | `SendMessage` lại **chính agent đó** kèm output lỗi nguyên văn + `file:dòng` (không giao lại từ đầu) | Có |
| **C. Lặp** | cùng triệu chứng lần 2 | Đổi executor vô ích — lỗi ở chẩn đoán/spec. `architect` `systematic-debugging` → viết lại spec / chia nhỏ task → giao lại Codex. Lần 3 cùng triệu chứng → `builder` áp spec của architect trực tiếp, ghi `<!-- claude-override: direct-fix after 3 Codex retries [date] -->`. architect fail 2 lần → `security-reviewer` phân tích chỉ đọc, viết spec | Có |
| **D. Âm thầm** | báo xong nhưng test bị sửa/skip, catch nuốt lỗi, tính năng không chạy | Chỉ bắt được ở bước `scout` chạy lại + `architect` đọc riêng diff test. Xử lý như B, ghi rõ "không được sửa test để pass" | Có |

Hết quota OpenAI → A. Hết quota Claude giữa chừng → Codex làm tiếp độc lập theo `AGENTS.md` ("When Working Without Claude") — nên trạng thái task **luôn** phải nằm trong `docs/plan-overview.md`. Hết cả hai → ghi trạng thái vào plan, dừng, báo user.

## Trục 2 — Điều tra trước khi fix

Bug / lỗi / không work → **`superpowers:systematic-debugging`** (reproduce trước, không đoán). Không tự chế phân loại ở đây.

## Async loop (builder / Codex)

`Agent` tool chạy nền — Claude Code tự báo khi agent xong, KHÔNG poll bằng `ScheduleWakeup`. Nhận notification xong:
```
`scout` chạy lại build/test (output nguyên văn) → review diff theo bảng kiểm (`architect` nếu LỚN hoặc >50 dòng, SendMessage agent cũ; ∥ `security-reviewer` nếu nhạy cảm) → UI diff? cổng kiểm màn thật 1440/375 TRƯỚC merge → migration diff? verify DB → lỗi? phân loại theo "Codex lỗi"
```
Mechanics đầy đủ (companion resume, autocommit) → `/codex-exec`.

## Token Discipline — Claude main

**KHÔNG:**
- Đọc full source để lấy context khi agent tự đọc được.
- Grep/trace lan man khi debug. Dò vị trí/thu bằng chứng → `scout`; điều tra sâu việc VỪA/LỚN → `architect`.
- Paste nội dung file vào brief.
- Edit/Write file code cho việc VỪA/LỚN — giao `builder`. (Việc NHỎ và lỗi UI vừa thấy → phiên chính sửa thẳng.)
- Gọi `general-purpose`.

**CHỈ:**
- Đọc `git log` / `git diff`, output nguyên văn agent trả.
- Quyết nội dung plan/spec (`architect` viết file cho việc LỚN) · tài liệu/tiến độ → `scribe`.
- Giao `builder` với goal + brief/spec path + "Đã quyết / đã loại" + commit gốc worktree.

**Structural-first:** với câu hỏi về symbol/call-graph ("X định nghĩa đâu", "ai gọi Y", "sửa Z vỡ gì", trace flow) → xác định file và đọc callers/callees trước khi grep lan man. Grep/Read thẳng là ĐÚNG tool khi: tìm chuỗi text literal · file đã biết tên · file .md/config · repo không phải code.

## Definition of Done

Trước khi báo "xong"/commit → chạy **`/ship`** (verify + review + diff scope + ASSUMPTION + migration version + quiz-gate). Fail-loud: chưa qua /ship = chưa done.

## Security trigger

Diff đụng `**/auth/**` · `**/middleware/**` · `**/api/**` · `**/*migration*` · `**/*rls*` → chạy **`/review`** (security checklist). Enforce bằng hook thật: `~/.claude/hooks/security-gate.py` chặn `git commit` khi staged diff đụng path nhạy cảm mà `.claude/.security-reviewed` chưa được /review touch trong 30 phút.

## ASSUMPTION / decisions

Commit (builder/Codex) có `ASSUMPTION:` → Claude quyết + append `docs/superpowers/decisions.md` NGAY (không để session sau). Brief builder trỏ tới file này.

## Blindspot scout (trước plan)

Task đụng vùng code chưa quen / feature mới nhiều file → TRƯỚC khi viết plan, scout tìm unknown unknowns: code search/callers-callees + `git log` vùng liên quan + docs/architecture.md. Output = **unknown map** ngắn (3-5 dòng: đã biết gì, chưa biết gì, rủi ro ở đâu) đặt đầu plan. Unknown chỉ user trả lời được → gộp vào câu hỏi CLARIFY, không đoán. Task nhỏ vùng quen → skip, không cần ghi.

Khác Plan cross-review bên dưới: scout chạy TRƯỚC plan (định hình plan), cross-review chạy SAU plan (bắt lỗi plan). Không thay nhau.

## Plan cross-review (trước execute)

Chỉ việc LỚN. Plan xong, TRƯỚC khi giao builder → `architect` (cùng agent viết plan thì dùng `/codex:review` hoặc `scout` kiểm file/symbol tồn tại) đối chiếu plan với codebase thật — file/symbol có tồn tại không, impact đủ blast radius chưa, thiếu bước nào. Trả `PLAN-OK` hoặc `PLAN-GAP: [vấn đề]`. Có PLAN-GAP → sửa plan trước. Việc NHỎ/VỪA → skip.

## UI feature mới — design pipeline

Thứ tự: `/wireframe` (user flow + spec table, user duyệt) → design token theo `rules/design-system.md` (chưa có file → sinh 1 lần, có thể bật tạm `ui-ux-pro-max` cho riêng bước này rồi tắt; chốt token vào file, không sinh lại mỗi màn) → mockup 2–3 bản bằng Stitch MCP (Claude gọi trực tiếp; project chưa nối Stitch thì dùng `frontend-design` direction), user chọn bản, Claude không tự chọn → `builder` code theo `projectId`/`screenId` đã duyệt + token → `/frontend-verify` + cổng kiểm màn thật 1440/375. Plan link tới wireframe/mockup đã duyệt thay vì tả UI bằng chữ. Sửa UI nhỏ trên màn có sẵn → skip wireframe + mockup, vào thẳng build.

Nối Stitch cho project: `.mcp.json` → `{"mcpServers":{"stitch":{"type":"stdio","command":"/Users/giinlow./.codex/stitch-mcp-proxy.zsh"}}}` + `.claude/settings.local.json` → `{"enabledMcpjsonServers":["stitch"]}`.

## Design system (UI kit) — project có giao diện

Áp khi project có UI từ 2–3 màn trở lên. Tool 1 màn, script, project business → bỏ qua.

- Cần có **1 file design system** (tên/chỗ tuỳ project; mặc định `rules/design-system.md`). Format tự do, tối thiểu trả lời 3 câu: **(1) Tokens** — màu, chữ, khoảng cách, bo góc dùng giá trị nào, tên biến gì · **(2) Thành phần chung** — mỗi thành phần trông/hoạt động ra sao (kích thước, trạng thái) · **(3) Code ở đâu** — thư mục component library mà mọi màn gọi lại.
- Thành phần mới → ghi vào design system trước, rồi mới dùng ở màn. Không viết lại nút/ô nhập/menu riêng cho từng màn.
- Quyết định riêng từng màn (mockup đã duyệt, annotation) để file khác — design system chỉ giữ thứ dùng chung.
- Nên có khi thành phần nhiều lên: trang mẫu trực quan (component gallery — 1 file HTML hoặc Storybook) hiện mọi thành phần + trạng thái.
- File khởi đầu (không bắt buộc): `~/.claude/templates/design-system.starter.md`. Cần bàn giao thiết kế đầy đủ → module `modules/ui-design-handoff.md`.

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
