# CLAUDE.md — Code Project

## Phân Công Vai Trò AI

| Phase | Công cụ | Việc làm |
|-------|---------|----------|
| Planning | Superpowers (Claude plugin) | brainstorming → spec → writing-plans |
| Execution + QA | Codex MCP | Viết/sửa code, chạy test, commit |
| Orchestration + Review | Claude main | Quyết định kiến trúc, review output, điều phối |

- `subagent-driven-development` của Claude main KHÔNG dùng → Codex thay thế hoàn toàn
- Codex có Superpowers cài sẵn → tự follow TDD, brainstorming workflow, không cần Claude embed
- Workflow chi tiết của Codex xem trong `AGENTS.md`

## Quy Trình Execution

### Feature mới
1. Superpowers `brainstorming` → spec
2. Gọi Codex: `writing-plans` (Codex đọc codebase + spec → technical checklist)
3. Claude review plan → approve hoặc feedback cụ thể
4. Nếu có vấn đề → Codex revise plan, tối đa **2 lần**
5. Sau 2 lần vẫn chưa ổn → Claude sửa thẳng file plan `.md`
6. Gọi Codex: `executing-plans` → implement + TDD + commit
7. Claude review qua `git diff` + commit message
8. Nếu có vấn đề: gọi Codex lại với feedback cụ thể
9. Pass → bàn giao user test

### Bug fix / small change
1. Claude main phân tích nguyên nhân (`git log`, `git diff`)
2. Gọi Codex fix trực tiếp
3. Review `git diff` sau khi Codex xong

## Cách Gọi Codex

```
Tool: mcp__codex__codex
sandbox: "workspace-write"
approval-policy: "never"
```

**Heuristic chia task — trước khi gọi Codex:**

> 1 task = 1 commit có thể review độc lập

- Quá lớn (span nhiều file không liên quan) → chia nhỏ hơn
- Quá nhỏ (chỉ đổi 1 biến) → gộp với task liền kề
- Mục tiêu: mỗi `git diff` Claude đọc được trong 1 lần, không cần context từ task khác

**Template prompt chuẩn — dùng mỗi lần gọi:**

```
Goal: [1-2 câu — làm gì, tại sao]

Files cần đọc: [list]
Files cần sửa: [list]

Constraints:
- Không break: [X]
- Phải tương thích: [Y]

Nếu gặp mơ hồ (ambiguity): ghi `ASSUMPTION:` (giả định) vào commit message

Git commit: [format message]
```

Codex tự đọc file để lấy context — không paste code vào prompt.

## Token Discipline — Claude Main Session

**KHÔNG làm:**
- Đọc toàn bộ file source để lấy context (việc của Codex)
- Paste nội dung file vào Codex prompt
- Dùng Edit/Write cho file .jsx/.js/.sql
- Dispatch Claude subagent làm middleman

**CHỈ làm:**
- Đọc `git log` / `git diff`
- Viết/sửa file .md (plan, spec, rules)
- Gọi Codex: goal + file paths + constraints
- Quyết định kiến trúc trước khi giao Codex

**Khi review output Codex — checklist adversarial:**
- Đọc `git diff` + commit message (bắt buộc)
- Kiểm tra: có `ASSUMPTION:` (giả định) nào cần xác nhận (validate) không?
- Kiểm tra: thay đổi có nằm đúng scope task không?
- Kiểm tra: test pass, không có regression
- Kiểm tra: logic thay đổi có nhất quán với spec không?
- Được đọc snippet nhỏ nếu diff tham chiếu code ngoài phạm vi thay đổi

## Đồng Bộ CLAUDE.md ↔ AGENTS.md

Mọi thay đổi ảnh hưởng đến cả Claude lẫn Codex phải cập nhật **cả 2 file cùng lúc**:

| Thay đổi | Cập nhật |
|----------|----------|
| Workflow, quy trình mới | `CLAUDE.md` + `AGENTS.md` |
| Ký hiệu mới (`ASSUMPTION:`, `QA-FAIL:`...) | `CLAUDE.md` + `AGENTS.md` |
| Thêm/bỏ tool, stack | `AGENTS.md` Project Context + `context/architecture.md` |
| Rule chỉ liên quan Claude main | `CLAUDE.md` hoặc `rules/*.md` |
| Rule chỉ liên quan Codex | `AGENTS.md` |

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
