# AGENTS.md — Code / Multi-Agent AI Rules

*File này dành cho code project hoặc project có nhiều agent cùng sửa artifact. Non-code project không bắt buộc có `AGENTS.md` trừ khi cần phối hợp nhiều tool.*

---

## Project Context

- **Tên**: [tên project]
- **Type**: code / multi-agent
- **Stack**: [tech stack]
- **Mục tiêu**: [mô tả ngắn]

---

## Phân Công Vai Trò

| Tool | Vai trò |
|------|---------|
| **Superpowers** (Claude plugin) | Planning: brainstorming → spec → writing-plans |
| **Claude Code** | Orchestration + Review: brainstorming, writing-plans (Superpowers), quyết định kiến trúc, review plan + output |
| **Codex** (`codex:codex-rescue` subagent / `/codex:rescue`) | Execution + QA: executing-plans, TDD, chạy test, commit |

---

## Quy Tắc Chung (Mọi AI đều phải follow)

### Code Quality
- TDD bắt buộc: RED → GREEN → REFACTOR
- Commit sau mỗi task hoàn thành
- 1 task = 1 commit có thể review độc lập (không quá lớn, không quá nhỏ)
- Không thêm feature ngoài scope đã plan
- Không comment giải thích WHAT — chỉ comment WHY nếu không rõ

### Scope Control
- Không tự refactor code ngoài task
- Không thêm error handling cho cases không thể xảy ra
- Không tạo abstraction nếu chỉ dùng 1-2 lần

### Context Management
- Compact / pause / dừng session **chỉ tại task boundary** (sau commit), không dừng giữa chừng implementation
- Dừng mid-task → context mất state → risk implement sai hoặc duplicate ở lần tiếp theo

---

## Workflow

### Claude Code — nhận task mới
1. Check Superpowers skill có apply không
2. Task phức tạp → `brainstorming` trước → spec
3. Invoke Superpowers `writing-plans` skill trực tiếp (Claude làm, không giao Codex — Codex không invoke được skill này)
4. Append plan vào `docs/plan-overview.html` (tạo mới nếu chưa có) → hỏi user xác nhận
5. User mở `docs/plan-overview.html` → review → confirm "OK, triển khai"
6. Nếu plan cần chỉnh → Claude sửa thẳng `design.md` hoặc HTML (Claude là chủ plan, không giao Codex revise)
7. Extract task list từ HTML section → truyền vào Codex prompt dạng text
8. Review output thực thi qua `git diff` + commit message → update checkbox trong HTML

### Codex — nhận task list từ Claude
1. Nhận task list dạng text do Claude extract từ `docs/plan-overview.html` — Claude đã review và user đã confirm. Codex KHÔNG tự tạo plan, KHÔNG đọc HTML trực tiếp.

2. Đọc `docs/superpowers/decisions.md` (nếu có) trước khi bắt đầu → dùng `executing-plans` → dùng `dispatching-parallel-agents` để parallelize task **chỉ khi `Depends on: none`** — task có dependency phải chờ task trước commit xong mới bắt đầu

   **Task Size gate — bắt buộc trước executing-plans:**
   - Task `Size: L` → PHẢI chia thành 2-3 sub-task trước khi execute
   - List sub-task trong plan file → báo Claude approve → mới chạy
   - Task `Size: S / M` → execute bình thường

   **Parallel safety rule — kiểm tra trước khi dispatch:**
   KHÔNG parallel nếu agent A thêm prop/type/interface mà agent B sẽ dùng — race condition, agent B break khi A chưa commit. Gộp vào 1 agent hoặc chạy tuần tự.

   **Parallel safety check — chạy trước khi dispatch:**
   ```bash
   # Tìm file nào export type/interface được import bởi file khác trong task list
   grep -r "export type\|export interface" [files-in-task-A] 2>/dev/null
   grep -r "import.*from.*[files-in-task-A]" [files-in-task-B] 2>/dev/null
   ```
   Nếu task B import từ file task A đang sửa → gộp 1 agent, không parallel.
3. Nếu gặp mơ hồ (ambiguity) → **ưu tiên đọc `docs/superpowers/decisions.md` trước** — nếu đã có quyết định thì follow, không cần ghi ASSUMPTION: thêm. Nếu chưa có → ghi `ASSUMPTION:` (giả định) vào commit message

   **Signals bắt buộc trong commit message:**
   - `ASSUMPTION:` — giả định cần Claude xác nhận
   - `ENV-REQUIRED: VAR_NAME — [dùng cho gì]` — env var mới cần set trước khi deploy
   - `QA-FAIL:` — test fail sau 3 lần retry, cần Claude can thiệp
   - `SECURITY-SENSITIVE:` — bắt buộc ghi nếu commit động vào bất kỳ file nào liên quan:
     auth, middleware, policy, rls, migration, permission, role, token, session, password, secret, api route, input handling (`req.body`, `req.params`, `formData`)
4. Chạy Quality Gate trước khi commit:
   - Kiểm tra tĩnh (static audit): import đúng, prop match, logic nhất quán
   - Kiểm thử toàn trình (E2E test): chạy test suite
   - Playwright / dev server: Codex được chạy nếu môi trường cho phép. Nếu gặp `EPERM`, lỗi bind port, sandbox, hoặc browser không khởi động được → ghi `QA-FAIL:` với command + lỗi chính, rồi để Claude chạy trực tiếp.
5. Nếu QA fail → tự fix, tối đa **3 lần thử lại (retry)**
6. Sau 3 lần vẫn fail → `QA-FAIL:` (kiểm thử thất bại) → báo lên (escalate) Claude
7. Pass → commit + báo Claude review

### Claude Code — review output Codex
1. Đọc `git diff` + commit message
2. Xác nhận (validate) `ASSUMPTION:` (giả định) nếu có → ghi quyết định vào `docs/superpowers/decisions.md`
3. Kiểm tra: đúng scope, test pass, không regression, nhất quán với spec
4. Nếu commit có `SECURITY-SENSITIVE:` → chạy security review (xem checklist trong CLAUDE.md)
5. Nếu có vấn đề → gọi Codex lại với feedback cụ thể
6. **Definition of Done** trước khi bàn giao:
   - [ ] Tất cả tests pass, không regression
   - [ ] `ASSUMPTION:` (giả định) đã được xác nhận (validate)
   - [ ] `ENV-REQUIRED:` (nếu có) đã được user set
   - [ ] `SECURITY-SENSITIVE:` (nếu có) đã qua security review — không có lỗ hổng
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass; nếu Codex bị sandbox khi chạy Playwright/dev server thì Claude đã chạy trực tiếp
   - [ ] `docs/superpowers/debug-*.md` của feature này đã archive hoặc xóa

### Resume sau khi session bị gián đoạn
1. Đọc `git log` → biết đang ở task nào
2. Đọc `docs/plan-overview.html` → biết còn task nào chưa done (checkbox chưa ✅)
3. Đọc `docs/superpowers/decisions.md` (nếu có) → nắm các quyết định đã xác nhận
4. Extract task list còn lại → gọi Codex tiếp

### Fallback — Codex không giải quyết được sau 3 lần thử lại (retry)

**Feature flow:**
1. Claude đọc `git diff` + log `QA-FAIL:` (kiểm thử thất bại)
2. Claude viết analysis ngắn vào `docs/superpowers/debug-[feature].md`
3. Gọi Codex lại với file đó làm context bổ sung

**Bug fix flow:**
1. Claude đọc `git diff` của 3 lần thử
2. Claude viết analysis vào `docs/superpowers/debug-[issue].md`
3. Gọi Codex lại với file đó
4. Nếu vẫn fail → Claude tự fix bằng Edit/Write (ngoại lệ token discipline) → thêm `<!-- claude-override: direct-fix after 3 Codex retries [YYYY-MM-DD] -->` vào đầu file sửa

---

## Do NOT

- Push code chưa pass tests
- Thử lại (retry) QA quá 3 lần mà không báo lên (escalate)
- Tự thêm dependencies không có trong plan → ghi `ASSUMPTION:` báo Claude approve trước
- Bỏ qua step review nếu có code review skill
- Thêm project-specific rules vào file này → đặt vào `rules/[tool].md` trong project
- Âm thầm lệch spec — nếu implementation cần lệch → ghi `ASSUMPTION: [lý do lệch]` → dừng → báo Claude cập nhật spec trước khi continue

---

*Cập nhật: 2026-05-25 (rev8: HTML plan overview — Codex nhận task list từ Claude extract, resume đọc HTML thay plan.md)*

<!-- template: 2026-05-22 -->
