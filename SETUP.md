# Claude Code Workflow Setup

*Gửi file này cho Claude Code và nói: "Đọc file này và tự setup cho tôi"*
*Claude sẽ tự hỏi thêm nếu cần, rồi cài hết tự động.*

---

## Hướng Dẫn Cho Claude

Nếu bạn đang đọc file này, hãy làm theo các bước sau **theo thứ tự**, hỏi user khi cần:

### Bước 0 — Xác nhận môi trường
Hỏi user:
1. "Bạn dùng Mac hay Windows?"
2. "Bạn đã cài Claude Code chưa? (claude --version)"
3. "Bạn muốn dùng Obsidian second brain không?"

### Bước 1 — Cài Superpowers Plugin
Chạy lệnh trong Claude Code:
```
/plugin install superpowers@claude-plugins-official
```
Verify: kiểm tra plugin đã xuất hiện trong `/plugins`

### Bước 2 — Tạo settings.json

**Mac:** `~/.claude/settings.json`
**Windows:** `%APPDATA%\Claude\settings.json`

Nội dung:
```json
{
  "model": "sonnet",
  "effortLevel": "medium",
  "theme": "dark",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
```

Nếu user muốn dùng RTK (token optimizer), hỏi trước rồi thêm hook:
```json
"hooks": {
  "PreToolUse": [
    { "matcher": "Bash", "hooks": [{ "type": "command", "command": "rtk hook claude" }] }
  ]
}
```

### Bước 3 — Tạo CLAUDE.md Global

**Mac:** `~/.claude/CLAUDE.md`
**Windows:** `%APPDATA%\Claude\CLAUDE.md`

```markdown
# Quy Tắc Ngôn Ngữ
- Trả lời bằng tiếng Việt
- Thuật ngữ kỹ thuật: Tiếng Việt (English term)

# Superpowers — BẮT BUỘC, KHÔNG CÓ NGOẠI LỆ

Trước MỌI action, kiểm tra skill phù hợp và invoke ngay.

## Khi Nào Trigger Skill Nào

| Anh nói gì | Skill tự động trigger |
|---|---|
| "build X", "thêm tính năng", "tạo mới" | brainstorming trước, KHÔNG code ngay |
| Sau brainstorm xong, có spec | writing-plans |
| Có plan, bắt đầu code | test-driven-development |
| Plan có 2+ task độc lập | subagent-driven-development hoặc dispatching-parallel-agents |
| "fix bug", "lỗi", "không chạy" | systematic-debugging |
| Xong implementation | requesting-code-review + verification-before-completion |
| Nhận feedback về code | receiving-code-review |
| Merge / kết thúc branch | finishing-a-development-branch |

## Quy Tắc Cứng
- Nếu task là "build/tạo/thêm" mà KHÔNG qua brainstorming → SAI
- Nếu sắp claim "xong rồi" mà chưa verify → SAI
- Nếu có 2+ task độc lập mà làm tuần tự → SAI

# Kết Thúc Session — Checklist Tự Động
Trước khi kết thúc, nhắc:
1. Git commit chưa?
2. Có insight đáng lưu vào Obsidian không?
3. Task nào còn dở?

# Khởi Tạo Project Mới
Nếu vào project KHÔNG có CLAUDE.md:
1. Hỏi: "Project này thuộc loại nào?" (code / research / finance / personal)
2. Tạo CLAUDE.md phù hợp từ template
```

### Bước 4 — Tạo Templates

Tạo folder `~/.claude/templates/` (Mac) hoặc `%APPDATA%\Claude\templates\` (Windows).

Tải 4 template files từ repo gốc:
- `code-project.md` — project code có Git
- `research.md` — nghiên cứu, phân tích
- `finance.md` — tài chính, trading
- `personal.md` — dự án cá nhân

### Bước 5 — Cài RTK (Optional, Mac only)

Hỏi user có muốn cài RTK không (token optimizer ~50% savings):
```bash
curl -fsSL https://rtk.dev/install.sh | sh
rtk --version
```

Nếu Windows → bỏ qua bước này, RTK chưa có bản Windows.

### Bước 6 — Setup MCP Codex (Optional)

Nếu user muốn dùng Codex để implement:
```bash
claude mcp add codex
```

### Bước 7 — Cấu Trúc Project Chuẩn (Code Projects)

Mỗi code project mới cần cấu trúc 3 tầng. Claude sẽ tự tạo khi vào project không có CLAUDE.md, nhưng bạn cần biết để kiểm tra:

```
[project]/
├── CLAUDE.md                ← lean, chỉ dùng @imports
├── rules/
│   ├── workflow.md          ← copy từ ~/.claude/templates/rules/workflow-template.md
│   ├── supabase.md          ← chỉ có nếu dùng Supabase
│   └── testing.md           ← điền lệnh test cụ thể của project
└── context/
    └── architecture.md      ← stack, file quan trọng, constraints
```

**CLAUDE.md chuẩn:**
```markdown
# CLAUDE.md — [Tên Project]

@context/architecture.md
@rules/workflow.md
@rules/supabase.md
@rules/testing.md
```

Các template rule files nằm tại `~/.claude/templates/rules/` — copy vào project và customize.

### Bước 8 — Verify

Kiểm tra mọi thứ hoạt động:
```bash
claude --version
# Trong Claude Code:
# /plugins → thấy superpowers
# Hỏi Claude: "Superpowers có active không?"
```

---

## Obsidian Second Brain (Optional)

Nếu user chọn dùng Obsidian:
1. Cài Obsidian từ https://obsidian.md
2. Tạo vault mới tại vị trí sync cloud (iCloud/OneDrive/Dropbox)
3. Vault chỉ là **knowledge layer** — KHÔNG lưu code, KHÔNG lưu source files
4. Cấu trúc cơ bản:
   ```
   vault/
   ├── raw/          ← input thô (bài viết, note, voice)
   ├── wiki/         ← knowledge đã xử lý
   └── CLAUDE.md     ← rules cho AI khi làm việc trong vault
   ```

---

*Workflow gốc: Claude Code + Superpowers + MCP Codex*
*Token optimization: ~50% savings với RTK + Haiku subagents*
