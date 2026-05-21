@RTK.md

# Quy Tắc Ngôn Ngữ
- **Luôn trả lời bằng Tiếng Việt** — bất kể user viết tiếng gì (Anh, Việt, hay mix)
- Thuật ngữ kỹ thuật: Tiếng Việt (English) — vòng lặp (loop)
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
- `systematic-debugging` → không trigger — dùng 2-phase flow trong `code-project.md` (Codex investigation, Claude fix)

# Codex Delegation Rules

Khi dùng Codex để sửa code:

**Delegate sớm, prompt cấp cao:**
- Chỉ cần: WHAT cần sửa + file path + context ngắn gọn
- KHÔNG cần: line numbers, exact code, Claude tự research thay Codex
- Codex tự tìm HOW (đọc file, locate code, viết fix)

**Parallel agents chỉ khi thực sự độc lập:**
- Được parallel: các file không share prop/type/interface với nhau
- KHÔNG parallel: agent A thêm prop → agent B nhận prop (race condition, nếu 1 agent fail thì agent kia break)
- Khi có dependency: gộp vào 1 agent hoặc chạy tuần tự

**Claude giữ lại:**
- Mọi thứ cần MCP tools (Supabase, external APIs)
- Build + test runner (EPERM trong Codex sandbox)
- Root cause investigation khi cần đọc nhiều nguồn đồng thời (DB schema + code + RLS policies)

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
| Tool config cụ thể của project (MCP, lệnh test, quirk) | `[project]/.claude/rules/[name].md` |
| Chỉ chạy khi init / setup project | `~/.claude/SETUP.md` |
| Chỉ chạy khi skill được invoke | `~/.claude/skills/[skill]/skill.md` |
| Chỉ Codex đọc | `[project]/AGENTS.md` |

README chỉ chứa lệnh cài tools — không thêm rule vào đó.

# Khởi Tạo Project Mới
Không có CLAUDE.md → đọc `~/.claude/SETUP.md`.

# Mở Rộng Project Hiện Tại

Khi user muốn thêm component vào project đang làm → đọc `~/.claude/SETUP.md` section tương ứng:

| User muốn | Section cần đọc |
|---|---|
| Thêm hook (auto-commit, session start...) | `Hướng Dẫn .claude/` |
| Thêm sub-agent | `Hướng Dẫn .claude/` |
| Thêm /slash command | `Hướng Dẫn .claude/` |
| Thêm MCP server | `Hướng Dẫn .mcp.json` |
| Thêm rules/ mới | `Hướng Dẫn rules/*.md` |
| Init project mới vào folder có sẵn code | `Bước 0 — Audit` |

Trigger nhận diện: "thêm hook", "tạo agent", "thêm command", "cần MCP", "tạo rules", "setup .claude".

# Sync Rules
User nói "sync rules" hoặc "audit rules" → invoke `Skill("sync-rules")`.

