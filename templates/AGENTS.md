# AGENTS.md — Universal AI Rules

*File này được đọc bởi: Claude Code, Codex CLI, Cursor, OpenCode*
*Thay thế cho CLAUDE.md khi cần cross-tool compatibility*

---

## Project Context

- **Tên**: [tên project]
- **Type**: [code / research / finance / personal]
- **Stack**: [tech stack]
- **Mục tiêu**: [mô tả ngắn]

---

## Vai Trò Phân Công

| Tool | Vai Trò |
|------|---------|
| **Claude Code** | Planning, analysis, code review, git ops |
| **Codex** | Implementation — viết code từ plan |
| **Cursor** | In-editor edits, quick fixes |

---

## Quy Tắc Chung (Mọi AI đều phải follow)

### Code Quality
- Test trước khi implement (TDD): RED → GREEN → REFACTOR
- Commit sau mỗi task hoàn thành
- Không thêm feature ngoài scope đã plan
- Không comment giải thích WHAT — chỉ comment WHY nếu không rõ

### Communication
- Báo cáo ngắn gọn: file nào thay đổi, tại sao
- Nếu blocked → nêu blocker cụ thể, không tự ý skip
- Nếu có nhiều cách → đề xuất 1 cách tốt nhất với lý do

### Scope Control
- Không tự refactor code ngoài task
- Không thêm error handling cho cases không thể xảy ra
- Không tạo abstraction nếu chỉ dùng 1-2 lần

---

## Workflow

### Claude Code nhận task mới
1. Check skills có apply không (Superpowers)
2. Nếu task phức tạp → brainstorm trước
3. Viết plan → dispatch sang Codex qua MCP
4. Review output của Codex

### Codex nhận task từ Claude
1. Đọc plan và implement theo đúng spec
2. Viết test trước khi viết code
3. Báo lại khi xong hoặc khi blocked

### Fallback
- Nếu Codex không phản hồi → Claude dùng subagent thay thế
- Ghi chú lý do fallback trong commit message

---

## Do NOT

- Sửa file gốc trong `raw/` (nếu có Obsidian vault)
- Push code chưa pass tests
- Tự thêm dependencies không có trong plan
- Bỏ qua step review nếu có code review skill

---

*Tạo bởi: Claude Code | Cập nhật: [date]*
