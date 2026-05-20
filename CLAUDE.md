@RTK.md

# Quy Tắc Ngôn Ngữ
- Trả lời bằng tiếng Việt
- Thuật ngữ kỹ thuật: Tiếng Việt (English term) — ví dụ: vòng lặp (loop)

# Superpowers — BẮT BUỘC, KHÔNG CÓ NGOẠI LỆ

Trước MỌI action, kiểm tra skill phù hợp và invoke ngay. Không cần user nhắc.

## Khi Nào Trigger Skill Nào

| Anh nói gì | Skill tự động trigger |
|---|---|
| "build X", "thêm tính năng", "tạo mới" | `brainstorming` trước, KHÔNG code ngay |
| Sau brainstorm xong, có spec | `writing-plans` |
| Có plan, bắt đầu code | `test-driven-development` |
| Plan có 2+ task độc lập | `subagent-driven-development` hoặc `dispatching-parallel-agents` |
| "fix bug", "lỗi", "không chạy" | `systematic-debugging` |
| Xong implementation | `requesting-code-review` + `verification-before-completion` |
| Nhận feedback về code | `receiving-code-review` |
| Merge / kết thúc branch | `finishing-a-development-branch` |
| Feature cần isolate | `using-git-worktrees` |

## Quy Tắc Cứng
- Nếu task là "build/tạo/thêm" mà KHÔNG qua `brainstorming` → SAI, phải làm lại
- Nếu sắp claim "xong rồi" mà chưa chạy `verification-before-completion` → SAI
- Nếu có 2+ task độc lập mà làm tuần tự → SAI, dùng parallel agents

# Obsidian Bridge — Lưu Kiến Thức Tự Động

Vault path: `~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Sau mỗi session, Claude CHỦ ĐỘNG nhắc nếu có 1 trong các trường hợp sau:

| Tình huống | Gợi ý lưu vào đâu |
|---|---|
| Nghiên cứu kỹ 1 topic mới | `raw/resources/YYYY-MM-DD-[topic].md` |
| Fix được bug khó / học được pattern mới | `raw/daily/YYYY-MM-DD.md` |
| Quyết định kiến trúc quan trọng | `raw/daily/YYYY-MM-DD.md` |
| Session nghiên cứu dài (research project) | Tạo wiki note luôn |

Cách nhắc: "Bạn vừa [học/fix/quyết định] X — có muốn lưu vào Obsidian không? (raw/daily/ hoặc raw/resources/)"

Không nhắc nếu: session ngắn, chỉ hỏi đáp thông thường, task lặp đi lặp lại.

# Kết Thúc Session — Checklist Tự Động

Trước khi session kết thúc (user nói "xong", "tạm dừng", "mai tiếp"), Claude tự nhắc:

1. **Git** — có commit chưa? Nếu chưa → nhắc commit
2. **Obsidian** — có insight đáng lưu không? → gợi ý (theo rule trên)
3. **Task dở** — liệt kê 1-3 việc còn lại để session sau tiếp tục ngay

Format nhắc ngắn gọn, không dài dòng:
```
✓ Git: [đã commit / chưa commit gì]
? Obsidian: [có muốn lưu X không?]
→ Còn lại: [task 1], [task 2]
```

# Khởi Tạo Project Mới

Nếu vào project KHÔNG có CLAUDE.md → đọc `~/.claude/SETUP.md` và làm theo.
