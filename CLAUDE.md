@RTK.md

# Quy Tắc Ngôn Ngữ
- Luôn trả lời bằng Tiếng Việt — bất kể user viết tiếng gì.
- Thuật ngữ tiếng Anh / chuyên ngành: giải thích nghĩa tiếng Việt ở lần xuất hiện **đầu tiên**. Format: `technical term` (nghĩa ngắn). Lặp lại → không giải thích lại.
- Không dịch: tên lệnh, file path, API name, package name, biến code, model name, tên sản phẩm.
- Ký hiệu cố định giữ nguyên, giải thích lần đầu — `ASSUMPTION:` (giả định), `QA-FAIL:` (kiểm thử thất bại).

# Markitdown
PDF/Word/PPT/Excel/HTML/ảnh có text → bắt buộc chuyển trước khi đọc:
```bash
markitdown [file] > [file].md
```

# Superpowers — BẮT BUỘC

**Trước mỗi response: classify intent của user.**
Không đợi exact trigger word — dùng *ý nghĩa*, không dùng *từ khóa*.

**Nếu user muốn** tạo / thay đổi / cải thiện / tự động hóa / setup / test / fix / điều tra / so sánh / quyết định implementation → **check Superpowers trước**.
Nếu không chắc → assume skill áp dụng.
Announce skill trong 1 câu trước khi tiếp tục.

**Chỉ bỏ qua skill check khi:** output KHÔNG có dạng code/file/plan — tức là giải thích khái niệm, đọc file để hỏi đáp, confirm fact thuần túy.
Nếu output có thể là code, file change, plan, hoặc config → PHẢI check skill trước.

| Intent | Skill |
|---|---|
| Muốn tạo / design feature mới | `brainstorming` |
| Có spec, cần plan implement | `writing-plans` |
| Bắt đầu code | `test-driven-development` *(code project: override bởi code-project.md → Codex thực thi TDD, Claude không tự code)* |
| 2+ task độc lập | `subagent-driven-development` *(code project: override bởi code-project.md → dùng Codex)* |
| Bug / lỗi / không hoạt động | `systematic-debugging` |
| Xong implement, muốn kiểm tra | `requesting-code-review` + `verification-before-completion` |
| Nhận review feedback | `receiving-code-review` |
| Kết thúc branch | `finishing-a-development-branch` |
| Feature cần isolate / song song | `using-git-worktrees` |
| Spec xong, có 3+ task hoặc động core logic | hỏi: "Feature này cần worktree riêng không?" → `using-git-worktrees` |

**⚠️ Code project (có `code-project.md`):**
- Claude main dùng flow trong `code-project.md` thay cho việc tự code/debug full.
- Codex vẫn phải follow TDD/debug/verification discipline khi thực thi.
- Claude main vẫn giữ review, architecture, MCP, security, và decision logging.

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

# Quản Lý Config

## Đặt Rule Ở Đâu

| Rule thuộc loại nào | Đặt ở đâu |
|---|---|
| Hành vi mọi session, mọi project | `~/.claude/CLAUDE.md` |
| Hành vi mọi session, theo loại project | `~/.claude/templates/[type].md` |
| Tool config cụ thể của project (MCP, lệnh test, quirk) | `[project]/.claude/rules/[name].md` |
| Chỉ chạy khi init / setup project | `~/.claude/SETUP.md` |
| Chỉ chạy khi skill được invoke | `~/.claude/skills/[skill]/skill.md` |
| Chỉ Codex đọc | `[project]/AGENTS.md` |

> **Boundary test trước khi thêm vào CLAUDE.md:** "Rule này có áp dụng khi đang làm dự án business / finance / personal không?" Nếu KHÔNG → đặt vào template tương ứng.

README chỉ chứa lệnh cài tools — không thêm rule vào đó.

## Khởi Tạo / Mở Rộng Project

Project mới hoặc mở rộng → `/init`

## Sync Rules
User nói "sync rules" hoặc "audit rules" → invoke `Skill("sync-rules")`.
