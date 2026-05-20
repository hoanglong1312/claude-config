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
| **Cursor** | Quick fix trong editor |

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
1. Dùng `writing-plans` + đường dẫn spec (`docs/superpowers/specs/YYYY-MM-DD-[feature]-design.md`) → đọc codebase + spec → tạo technical checklist
2. Sau khi Claude approve → dùng `executing-plans` → dùng `dispatching-parallel-agents` để parallelize task độc lập → implement + TDD + commit
3. Nếu gặp mơ hồ (ambiguity) → ghi `ASSUMPTION:` (giả định) vào commit message
4. Chạy Quality Gate trước khi commit:
   - Kiểm tra tĩnh (static audit): import đúng, prop match, logic nhất quán
   - Kiểm thử toàn trình (E2E test): chạy test suite
5. Nếu QA fail → tự fix, tối đa **3 lần thử lại (retry)**
6. Sau 3 lần vẫn fail → `QA-FAIL:` (kiểm thử thất bại) → báo lên (escalate) Claude
7. Pass → commit + báo Claude review

### Claude Code — review output Codex
1. Đọc `git diff` + commit message
2. Xác nhận (validate) `ASSUMPTION:` (giả định) nếu có
3. Kiểm tra: đúng scope, test pass, không regression, nhất quán với spec
4. Nếu có vấn đề → gọi Codex lại với feedback cụ thể
5. **Definition of Done** trước khi bàn giao:
   - [ ] Tất cả tests pass, không regression
   - [ ] `ASSUMPTION:` (giả định) đã được xác nhận (validate)
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass

### Resume sau khi session bị gián đoạn
1. Đọc `git log` → biết đang ở task nào
2. Đọc file plan trong `docs/superpowers/specs/` → biết còn task nào chưa làm
3. Gọi Codex tiếp từ task còn dở

### Fallback — Codex không giải quyết được sau 3 lần thử lại (retry)
1. Claude đọc `git diff` + log `QA-FAIL:` (kiểm thử thất bại)
2. Claude viết analysis ngắn vào file `.md` tạm
3. Gọi Codex lại với file `.md` đó làm context bổ sung

---

## Do NOT

- Push code chưa pass tests
- Thử lại (retry) QA quá 3 lần mà không báo lên (escalate)
- Tự thêm dependencies không có trong plan
- Bỏ qua step review nếu có code review skill

---

*Cập nhật: 2026-05-20*
