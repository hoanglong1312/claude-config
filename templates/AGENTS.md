# AGENTS.md — Universal AI Rules

*File này được đọc bởi: Claude Code, Codex CLI, Cursor, OpenCode*

---

## Project Context

- **Tên**: [tên project]
- **Type**: [code / research / finance / personal]
- **Stack**: [tech stack]
- **Mục tiêu**: [mô tả ngắn]

---

## Phân Công Vai Trò

| Tool | Vai trò |
|------|---------|
| **Superpowers** (Claude plugin) | Planning: brainstorming → spec |
| **Claude Code** | Orchestration + Review: quyết định kiến trúc, review plan + output |
| **Codex** | Planning chi tiết + Execution + QA: writing-plans, executing-plans, chạy test, commit |

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
3. Gọi Codex: `writing-plans` (Codex đọc codebase + spec → technical checklist)
4. Review plan → approve hoặc feedback cụ thể
5. Nếu vấn đề → Codex revise, tối đa **2 lần** → vẫn chưa ổn → Claude sửa thẳng file `.md`
6. Review output thực thi qua `git diff` + commit message

### Codex — nhận spec từ Claude
1. Dùng `writing-plans` + đường dẫn spec (`docs/superpowers/specs/YYYY-MM-DD-[feature]-design.md`) → đọc codebase + spec → tạo technical checklist → lưu vào `docs/superpowers/specs/YYYY-MM-DD-[feature]-plan.md` (file riêng, không append vào spec)

   **Format bắt buộc mỗi task trong checklist:**
   ```
   ## Task: [tên ngắn]
   - Files: [file cần đọc/sửa]
   - Test: [test case cần pass]
   - Depends on: [task khác hoặc "none"]
   - Size: S / M / L
   ```

2. Sau khi Claude approve → đọc `docs/superpowers/decisions.md` (nếu có) trước khi bắt đầu → dùng `executing-plans` → dùng `dispatching-parallel-agents` để parallelize task **chỉ khi `Depends on: none`** — task có dependency phải chờ task trước commit xong mới bắt đầu

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
4. Chạy Quality Gate trước khi commit:
   - Kiểm tra tĩnh (static audit): import đúng, prop match, logic nhất quán
   - Kiểm thử toàn trình (E2E test): chạy test suite
5. Nếu QA fail → tự fix, tối đa **3 lần thử lại (retry)**
6. Sau 3 lần vẫn fail → `QA-FAIL:` (kiểm thử thất bại) → báo lên (escalate) Claude
7. Pass → commit + báo Claude review

### Claude Code — review output Codex
1. Đọc `git diff` + commit message
2. Xác nhận (validate) `ASSUMPTION:` (giả định) nếu có → ghi quyết định vào `docs/superpowers/decisions.md`
3. Kiểm tra: đúng scope, test pass, không regression, nhất quán với spec
4. Nếu có vấn đề → gọi Codex lại với feedback cụ thể
5. **Definition of Done** trước khi bàn giao:
   - [ ] Tất cả tests pass, không regression
   - [ ] `ASSUMPTION:` (giả định) đã được xác nhận (validate)
   - [ ] `ENV-REQUIRED:` (nếu có) đã được user set
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass
   - [ ] `docs/superpowers/debug-*.md` của feature này đã archive hoặc xóa

### Resume sau khi session bị gián đoạn
1. Đọc `git log` → biết đang ở task nào
2. Đọc file plan trong `docs/superpowers/specs/` → biết còn task nào chưa làm
3. Đọc `docs/superpowers/decisions.md` (nếu có) → nắm các quyết định đã xác nhận
4. Gọi Codex tiếp từ task còn dở

### Fallback — Codex không giải quyết được sau 3 lần thử lại (retry)

**Feature flow:**
1. Claude đọc `git diff` + log `QA-FAIL:` (kiểm thử thất bại)
2. Claude viết analysis ngắn vào `docs/superpowers/debug-[feature].md`
3. Gọi Codex lại với file đó làm context bổ sung

**Bug fix flow:**
1. Claude đọc `git diff` của 3 lần thử
2. Claude viết analysis vào `docs/superpowers/debug-[issue].md`
3. Gọi Codex lại với file đó
4. Nếu vẫn fail → Claude tự fix bằng Edit/Write (ngoại lệ token discipline)

---

## Do NOT

- Push code chưa pass tests
- Thử lại (retry) QA quá 3 lần mà không báo lên (escalate)
- Tự thêm dependencies không có trong plan → ghi `ASSUMPTION:` báo Claude approve trước
- Bỏ qua step review nếu có code review skill
- Thêm project-specific rules vào file này → đặt vào `rules/[tool].md` trong project
- Âm thầm lệch spec — nếu implementation cần lệch → ghi `ASSUMPTION: [lý do lệch]` → dừng → báo Claude cập nhật spec trước khi continue

---

*Cập nhật: 2026-05-21 (rev2)*

<!-- template: 2026-05-21 -->
