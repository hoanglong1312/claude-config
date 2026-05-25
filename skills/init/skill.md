---
name: init
description: Init project mới hoặc mở rộng project hiện tại — scaffold, template, component library
---

# Project Init / Extend

## Auto-detect

Kiểm tra ngay khi skill được invoke:

```bash
[ -f "CLAUDE.md" ] || [ -f ".claude/CLAUDE.md" ]
```

- Không tìm thấy → chạy **PHẦN 1: Init mới**
- Tìm thấy → chạy **PHẦN 2: Mở rộng**

---

## PHẦN 1: Init Mới

### Bước 0 — Audit project có sẵn code

Nếu project có `package.json`, `*.py`, `*.go`:

1. Đọc file deps → detect stack
2. Kiểm tra gaps:

| Kiểm tra | Kết quả |
|----------|---------|
| `CLAUDE.md` | có / chưa → sẽ tạo |
| `CLAUDE.local.md` | có / chưa → tạo + gitignore |
| `.gitignore` | có / chưa → tạo hoặc append |
| `.mcp.json` | có / chưa → hỏi |
| `.claude/rules/` | có / chưa → sẽ tạo (trống) |
| `context/architecture.md` | có / chưa → tạo blank |

3. Báo cáo + xác nhận 1 lần → tạo hết.

Nếu project trống → Bước 1.

---

### Bước 1 — Hỏi loại project

> "Project này thuộc loại nào: code / research / finance / personal / business?"

---

### Bước 2 — Skeleton theo loại

**Personal / Research / Finance:**
```
[project]/
├── CLAUDE.md              ← @include template tương ứng
├── CLAUDE.local.md        ← gitignored
└── .gitignore
```

CLAUDE.md:
```
@~/.claude/templates/[personal|research|finance].md

## Project-Specific Rules
[thêm nếu cần]
```

---

**Business:**
```
[project]/
├── CLAUDE.md
├── CLAUDE.local.md
├── .gitignore
├── data/
│   ├── raw/
│   └── processed/
├── reports/
│   ├── weekly/
│   └── monthly/
├── sop/
└── context/
    ├── business-overview.md
    └── decisions.md
```

F&B thêm: `menu/current/`, `menu/costing/`, `hr/schedules/`, `hr/onboarding/`

CLAUDE.md:
```
@~/.claude/templates/business.md

## Project-Specific Rules
- Specialization: [F&B / retail / dịch vụ / khác]
- Scale: [số cơ sở, số nhân viên]
- Phần mềm POS: [tên hoặc "chưa có"]
- Đơn vị tiền tệ: VND
```

---

**Code:**
```
[project]/
├── CLAUDE.md
├── CLAUDE.local.md
├── .gitignore
├── .mcp.json
├── AGENTS.md              ← chỉ tạo nếu user dùng Codex (xác nhận ở Bước 3e)
├── .claude/
│   ├── rules/             ← trống ban đầu, thêm file khi project cần
│   └── settings.json
├── context/
│   └── architecture.md
└── docs/superpowers/
    ├── specs/
    └── decisions.md       ← pre-created blank
```

CLAUDE.md:
```
@~/.claude/templates/code-project.md
@context/architecture.md

## Thông Tin Project
- Tên: [điền]
- Git repo: [điền hoặc N/A]
- Tech stack: [điền]
- Mục tiêu: [điền]

## Project-Specific Rules
```

Thứ tự @include: `code-project.md` → `context/` (bắt buộc). Rules project-specific @include thêm khi cần.

`.gitignore` tối thiểu:
```
CLAUDE.local.md
.claude/settings.local.json
.env
*.local.*
```

---

### Bước 3 — Kiểm tra tools universal (MỌI loại project)

Check trước, chỉ hỏi install khi chưa có:

**3a. Superpowers:**
```bash
# Claude Code: /plugin list → tìm superpowers
# Nếu chưa → hỏi: "Muốn cài Superpowers không?"
#              → /plugin install superpowers@latest
```

**3b. RTK — Rust Token Killer:**
```bash
rtk --version 2>/dev/null && echo "installed" || echo "missing"
# Nếu missing → hỏi: "Muốn cài RTK không?"
#               → hướng dẫn user xem ~/.claude/README.md
```

**3c. Markitdown:**
```bash
markitdown --version 2>/dev/null && echo "installed" || echo "missing"
# Nếu missing → hỏi: "Muốn cài Markitdown không?"
#               → pip install markitdown
```

**3d. Caveman mode:**
> Không detect được tự động. Hỏi 1 lần: "Muốn bật Caveman mode không? Claude trả lời ngắn hơn. Bật: `/caveman full`. Tắt: `stop caveman`."

**3e. Codex plugin (CHỈ hỏi nếu là code project):**
```bash
# Claude Code: /plugin list → tìm codex@openai-codex
# Nếu chưa → hỏi: "Dự án này dùng Codex không?"
#   Có → /plugin install codex@openai-codex && /codex:setup
#   Không → bỏ qua AGENTS.md ở Bước 2
```

---

### Bước 4 — One-time setup (CHỈ cho code project)

**4a. Tạo `docs/superpowers/decisions.md`:**

```bash
mkdir -p docs/superpowers/specs
touch docs/superpowers/decisions.md
```

**4b. Điền thông tin project:**

Auto-detect trước, hỏi chỉ khi không detect được:

```
1. "Tên project là gì?"
2. "Mục tiêu chính? (1-2 câu)"
3. "Tech stack?" → detect từ package.json / requirements.txt / go.mod trước
4. "Git remote URL?" (tùy chọn)
```

Với project có sẵn code: đọc deps → auto-fill stack; đọc README nếu có → gợi ý mục tiêu → hỏi user confirm.

Điền vào 2 nơi:

**CLAUDE.md** — section `## Thông Tin Project` (Claude đọc → behavior):
```markdown
## Thông Tin Project
- Tên: [điền]
- Git repo: [điền hoặc N/A]
- Tech stack: [điền]
- Mục tiêu: [điền]
```

**AGENTS.md** — section `## Project Context` (Codex đọc — CHỈ nếu user dùng Codex):
```markdown
## Project Context
- **Tên**: [điền]
- **Type**: code / multi-agent
- **Stack**: [điền]
- **Mục tiêu**: [điền]
```
Phần còn lại copy từ `~/.claude/templates/AGENTS.md`.

---

### Bước 5 — Báo xong

---

## PHẦN 2: Mở Rộng Project Hiện Tại

Detect cấu trúc hiện tại trước:

```bash
ls .claude/hooks/ .claude/agents/ .claude/commands/ 2>/dev/null
```

Báo: "Project đã có: [X]. Muốn thêm gì?" — User nói → tạo tương ứng.

**Hooks** (thêm khi user muốn tự động hóa):

| Hook | Tác dụng | File |
|---|---|---|
| PostToolUse | Auto-commit sau Edit/Write | `.claude/hooks/PostToolUse.sh` |
| SessionStart | Show stats khi mở session | `.claude/hooks/SessionStart.sh` |
| PreCompact | Lưu git status trước context compact | `.claude/hooks/PreCompact.sh` |

Hooks phải đăng ký trong `.claude/settings.json`.

**Các component khác** (tạo khi project thực sự cần):

| User muốn | Component |
|---|---|
| Sub-agent review code | `.claude/agents/code-reviewer.md` |
| Sub-agent tìm web | `.claude/agents/researcher.md` |
| /ship, /test command | `.claude/commands/[name].md` |
| Rules cho Supabase | `.claude/rules/supabase.md` |
| Rules cho testing | `.claude/rules/testing.md` |
| Rules cho API layer | `.claude/rules/api.md` (path-scoped) |
| MCP server mới | `.mcp.json` |

---

## Component Templates

### `.claude/hooks/SessionStart.sh`

```bash
#!/bin/bash
if [ -f "docs/superpowers/decisions.md" ]; then
  echo "decisions.md: $(wc -l < docs/superpowers/decisions.md) entries"
fi
SPEC_COUNT=$(ls docs/superpowers/specs/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$SPEC_COUNT" -gt 0 ] && echo "Active specs: $SPEC_COUNT"
```

### `.claude/hooks/PostToolUse.sh`

```bash
#!/bin/bash
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "auto: $(git diff --cached --name-only | head -3 | tr '\n' ' ')" 2>/dev/null
  fi
fi
```

### `.claude/hooks/PreCompact.sh`

```bash
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
TODO_FILE=".claude/pre-compact-state-$TIMESTAMP.md"
echo "# Pre-compact state: $TIMESTAMP" > "$TODO_FILE"
echo "## Git status" >> "$TODO_FILE"
git status --short >> "$TODO_FILE" 2>/dev/null
echo "## Recent commits" >> "$TODO_FILE"
git log --oneline -5 >> "$TODO_FILE" 2>/dev/null
echo "State saved: $TODO_FILE"
```

Hook registration trong `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{"hooks": [{"type": "command", "command": "bash .claude/hooks/PostToolUse.sh"}]}],
    "PreCompact": [{"hooks": [{"type": "command", "command": "bash .claude/hooks/PreCompact.sh"}]}]
  }
}
```

### `.claude/agents/code-reviewer.md`

```markdown
# Agent: Code Reviewer

## Nhiệm vụ
Đọc git diff → báo cáo:
1. Thay đổi đúng scope task chưa?
2. Có ASSUMPTION: nào cần xác nhận?
3. Có vấn đề logic hoặc regression không?
4. Test cover đủ chưa?

## Output
SCOPE: [đúng / lệch]
ASSUMPTION: [có / không]
ISSUES: [có / không]
TEST: [đủ / thiếu]
VERDICT: APPROVE / REQUEST_CHANGES

## Constraints
- Chỉ đọc diff được cung cấp
- Không sửa code, chỉ báo cáo
```

### `.claude/rules/api.md` (path-scoped)

```markdown
---
path: src/api/**
---
# API Layer Rules
- Mọi endpoint phải có auth middleware
- Response format: `{ data, error, meta }`
- Validate input tại đây
- Không return raw DB object
```

---

## Global vs Per-Project

| Loại | Global `~/.claude/` | Per-project `.claude/` |
|---|---|---|
| Ngôn ngữ, Superpowers triggers | ✓ CLAUDE.md | |
| Hook mọi project | ✓ settings.json | |
| Hook riêng project | | ✓ .claude/hooks/ |
| MCP server | | ✓ .mcp.json |
| Rules cụ thể | | ✓ .claude/rules/ |
| Sub-agent | | ✓ .claude/agents/ |
| /slash command | | ✓ .claude/commands/ |

Khi không chắc: đặt per-project trước, 3+ project dùng → move lên global template.
