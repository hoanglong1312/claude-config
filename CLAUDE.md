@RTK.md

# Quy Tắc Ngôn Ngữ
- Tiếng Việt. Thuật ngữ kỹ thuật: Tiếng Việt (English) — vòng lặp (loop)
- Ký hiệu cố định: giữ nguyên, thêm nghĩa trong () — `ASSUMPTION:` (giả định), `QA-FAIL:` (kiểm thử thất bại)

# Markitdown
PDF/Word/PPT/Excel/HTML/ảnh có text → bắt buộc chuyển trước khi đọc:
```bash
markitdown [file] > [file].md
```

# Superpowers — BẮT BUỘC

| Trigger | Skill |
|---|---|
| "build X", "thêm tính năng", "tạo mới" | `brainstorming` |
| Có spec xong | `writing-plans` |
| Bắt đầu code | `test-driven-development` |
| 2+ task độc lập | `subagent-driven-development` |
| "fix bug", "lỗi" | `systematic-debugging` |
| Xong implementation | `requesting-code-review` + `verification-before-completion` |
| Nhận feedback | `receiving-code-review` |
| Kết thúc branch | `finishing-a-development-branch` |
| Feature cần isolate | `using-git-worktrees` |
| Xong brainstorming, spec có 3+ task hoặc động vào core logic | hỏi user: "Feature này có cần worktree riêng không?" → nếu có → `using-git-worktrees` |

**⚠️ Ngoại lệ trong code project (có `code-project.md`):**
- `test-driven-development` → không trigger — Codex tự follow
- `subagent-driven-development` → không trigger — Codex thay thế
- `requesting-code-review` → không trigger — dùng adversarial checklist trong `code-project.md`

# Obsidian Bridge
Vault: `~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Cuối session nhắc lưu nếu: nghiên cứu topic mới, fix bug khó, quyết định kiến trúc quan trọng.
→ `raw/daily/YYYY-MM-DD.md` hoặc `raw/resources/YYYY-MM-DD-[topic].md`

# Kết Thúc Session
Khi user nói "xong" / "tạm dừng" / "mai tiếp":
```
✓ Git: [đã commit / chưa]
? Obsidian: [có muốn lưu X không?]
→ Còn lại: [task 1], [task 2]
```

# Routing — Trước Khi Thêm Rule Mới

| Rule thuộc loại nào | Đặt ở đâu |
|---|---|
| Hành vi mọi session, mọi project | `~/.claude/CLAUDE.md` |
| Hành vi mọi session, theo loại project | `~/.claude/templates/[type].md` |
| Hành vi mọi session, project cụ thể | `[project]/rules/[name].md` |
| Chỉ chạy khi init / setup project | `~/.claude/SETUP.md` |
| Chỉ chạy khi skill được invoke | `~/.claude/skills/[skill]/skill.md` |
| Chỉ Codex đọc | `[project]/AGENTS.md` |

README chỉ chứa lệnh cài tools — không thêm rule vào đó.

# Khởi Tạo Project Mới
Không có CLAUDE.md → đọc `~/.claude/SETUP.md`.

# Audit Rules
User nói "audit rules" → invoke `Skill("audit-rules")`.

# Add-On Rules
Phát hiện tool chưa có rules trong code project → hỏi user tạo `rules/[tool].md`:

| Tool phát hiện | File |
|---|---|
| Supabase | `rules/supabase.md` |
| Playwright / Vitest / Jest | `rules/testing.md` |

Tạo theo structure chuẩn trong `~/.claude/SETUP.md`, thêm `@rules/[tool].md` vào CLAUDE.md project.
