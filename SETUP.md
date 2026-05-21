# SETUP.md — Project Master Reference

*Đọc file này khi: (1) init project mới, (2) mở rộng project hiện tại, (3) tìm template component.*

---

## PHẦN 1 — Init Project Mới

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
| `.claude/rules/` | có / chưa → sẽ tạo |
| `context/architecture.md` | có / chưa → tạo blank |
| `@supabase/supabase-js` trong deps | → hỏi load `supabase.md` |
| `playwright` trong deps | → hỏi load `testing.md` |
| `vitest` / `jest` trong deps | → hỏi load `testing.md` |

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
```markdown
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
│   ├── raw/               ← KHÔNG sửa file gốc
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
```markdown
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
├── AGENTS.md              ← copy từ ~/.claude/templates/AGENTS.md
├── .claude/               ← chỉ tạo component cần thiết
│   ├── rules/
│   │   ├── supabase.md    ← nếu dùng Supabase
│   │   └── testing.md     ← nếu có test framework
│   └── settings.json      ← nếu cần permission riêng
├── context/
│   └── architecture.md
└── docs/superpowers/
    ├── specs/
    └── decisions.md
```

CLAUDE.md:
```markdown
@~/.claude/templates/code-project.md
@context/architecture.md
@.claude/rules/supabase.md
@.claude/rules/testing.md

## Project-Specific Rules
```

Thứ tự @include: `code-project.md` → `.claude/rules/*` → `context/`

`.gitignore` tối thiểu:
```
CLAUDE.local.md
.claude/settings.local.json
.env
*.local.*
```

---

### Bước 3 — Kiểm tra Dependencies

| Tool | Kiểm tra |
|------|----------|
| Superpowers | `/plugin list` |
| Markitdown | `markitdown --version` |

Nếu thiếu → xem `~/.claude/README.md`.

### Bước 4 — Báo xong, bắt đầu làm việc

---

## PHẦN 2 — Mở Rộng Project Hiện Tại

Khi user nói muốn thêm gì → đọc PHẦN 3 để lấy template, tạo component tương ứng.

| User muốn | Component cần tạo |
|---|---|
| Auto-commit sau khi edit | `.claude/hooks/PostToolUse.sh` |
| Load context khi mở session | `.claude/hooks/SessionStart.sh` |
| Lưu state trước compact | `.claude/hooks/PreCompact.sh` |
| Sub-agent review code | `.claude/agents/code-reviewer.md` |
| Sub-agent tìm web | `.claude/agents/researcher.md` |
| Sub-agent phân tích log | `.claude/agents/log-analyzer.md` |
| Sub-agent security review | `.claude/agents/security-reviewer.md` |
| /ship command | `.claude/commands/ship.md` |
| /test command | `.claude/commands/test.md` |
| Rules cho Supabase | `.claude/rules/supabase.md` |
| Rules cho testing | `.claude/rules/testing.md` |
| Rules riêng cho API layer | `.claude/rules/api.md` (path-scoped) |
| Format output đặc thù | `.claude/output-styles/[name].md` |
| MCP server mới | `.mcp.json` |

Sau khi tạo component → thêm vào `.claude/settings.json` nếu là hook.

---

## PHẦN 3 — Component Library

### `.mcp.json`

```json
{
  "mcpServers": {
    "codex": {
      "command": "npx",
      "args": ["-y", "@openai/codex-mcp"]
    }
  }
}
```

Thêm Supabase:
```json
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest",
               "--access-token", "${SUPABASE_ACCESS_TOKEN}"]
    }
```

---

### `.claude/hooks/SessionStart.sh`

```bash
#!/bin/bash
# Load project context khi khởi động
if [ -f "docs/superpowers/decisions.md" ]; then
  echo "decisions.md: $(wc -l < docs/superpowers/decisions.md) entries"
fi
SPEC_COUNT=$(ls docs/superpowers/specs/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$SPEC_COUNT" -gt 0 ] && echo "Active specs: $SPEC_COUNT"
```

### `.claude/hooks/PostToolUse.sh`

```bash
#!/bin/bash
# Auto-commit sau khi edit file (chỉ khi có staged changes)
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
# Lưu trạng thái trước khi compact context
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
TODO_FILE=".claude/pre-compact-state-$TIMESTAMP.md"
echo "# Pre-compact state: $TIMESTAMP" > "$TODO_FILE"
echo "" >> "$TODO_FILE"
echo "## Git status" >> "$TODO_FILE"
git status --short >> "$TODO_FILE" 2>/dev/null
echo "" >> "$TODO_FILE"
echo "## Recent commits" >> "$TODO_FILE"
git log --oneline -5 >> "$TODO_FILE" 2>/dev/null
echo "State saved: $TODO_FILE"
```

Đăng ký hook trong `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{"hooks": [{"type": "command", "command": "bash .claude/hooks/PostToolUse.sh"}]}],
    "PreCompact": [{"hooks": [{"type": "command", "command": "bash .claude/hooks/PreCompact.sh"}]}]
  }
}
```

---

### `.claude/agents/code-reviewer.md`

```markdown
# Agent: Code Reviewer

Review code diff và báo cáo kết quả ngắn gọn.

## Nhiệm vụ
Đọc git diff được cung cấp → báo cáo:
1. Thay đổi đúng scope task chưa?
2. Có ASSUMPTION: nào cần xác nhận?
3. Có vấn đề logic hoặc regression không?
4. Test cover đủ chưa?

## Output format
```
SCOPE: [đúng / lệch — giải thích]
ASSUMPTION: [có / không — liệt kê nếu có]
ISSUES: [có / không — liệt kê nếu có]
TEST: [đủ / thiếu — giải thích]
VERDICT: APPROVE / REQUEST_CHANGES
```

## Constraints
- Chỉ đọc diff được cung cấp, không tự đọc thêm file
- Không sửa code, chỉ báo cáo
```

### `.claude/agents/security-reviewer.md`

```markdown
# Agent: Security Reviewer

Chạy khi commit có SECURITY-SENSITIVE: signal.

## Checklist
Đọc git diff → kiểm tra từng điểm:

| # | Loại | Kiểm tra |
|---|------|----------|
| 1 | SQL Injection | Raw query nối chuỗi user input? |
| 2 | RLS hole | Bảng mới có policy? Cover đủ roles? |
| 3 | Auth bypass | Endpoint mới có guard? |
| 4 | IDOR | Query có filter by user_id? |
| 5 | XSS | User input render HTML không sanitize? |
| 6 | Hardcoded secret | String literal trông như key/token? |
| 7 | Input validation | Validate tại API boundary? |
| 8 | Privilege escalation | Role check trước khi xử lý? |

## Output format
```
PASS: [danh sách điểm pass]
FAIL: [điểm fail — mô tả lỗ hổng cụ thể]
VERDICT: SECURE / VULNERABLE
```
```

### `.claude/agents/researcher.md`

```markdown
# Agent: Researcher

Tìm kiếm web và tổng hợp thông tin theo yêu cầu.

## Nhiệm vụ
Nhận câu hỏi / topic → tìm kiếm → tổng hợp → trả về:
1. Tóm tắt 3-5 điểm chính
2. Nguồn (URL)
3. Mức độ tin cậy (official doc / blog / forum)

## Constraints
- Không suy luận ngoài nguồn tìm được
- Đánh dấu [chưa kiểm chứng] với thông tin từ blog/forum
- Ưu tiên official docs
```

### `.claude/agents/log-analyzer.md`

```markdown
# Agent: Log Analyzer

Phân tích log, error stack trace, crash report.

## Nhiệm vụ
Nhận log → phân tích → báo cáo:
1. Error type + root cause
2. File:line gây ra
3. Context (request, user action nào trigger)
4. Đề xuất fix hướng (không tự fix)

## Output format
```
ERROR: [loại lỗi]
ROOT CAUSE: [nguyên nhân]
LOCATION: [file:line]
CONTEXT: [điều kiện trigger]
FIX DIRECTION: [hướng fix ngắn gọn]
```
```

---

### `.claude/commands/ship.md`

```markdown
# /ship

Chạy quality gate trước khi push:
1. Lint: `[điền lệnh]`
2. Test: `[điền lệnh]`
3. `git diff --stat` → xác nhận scope
4. Báo kết quả — KHÔNG tự push nếu có lỗi
```

### `.claude/commands/test.md`

```markdown
# /test

Chạy test suite và báo cáo kết quả:
1. `[điền lệnh test]`
2. Nếu fail → liệt kê test nào fail + error message
3. Nếu pass → báo coverage nếu có
```

---

### `.claude/rules/supabase.md`

```markdown
# Supabase Rules

## MCP Tools
| Việc | Tool |
|------|------|
| Apply migration | `mcp__supabase__apply_migration` |
| Query / debug | `mcp__supabase__execute_sql` |
| Kiểm tra schema | `mcp__supabase__list_tables` |

## Quy Tắc
- Tự apply migration, không bảo user vào dashboard
- Codex viết SQL file → Claude apply → Claude verify
```

### `.claude/rules/testing.md`

```markdown
# Testing Rules

## Lệnh chạy test
[npx playwright test / npx vitest run / npx jest]

## Quy Tắc
- Chạy test trước khi commit
- Không commit khi test fail
```

### `.claude/rules/api.md` (path-scoped)

```markdown
---
path: src/api/**
---
# API Layer Rules

- Mọi endpoint phải có auth middleware
- Response format chuẩn: `{ data, error, meta }`
- Validate input tại đây, không để lọt vào service layer
- Không return raw DB object
```

---

## PHẦN 4 — Global vs Per-Project

**Quy tắc:** *"Rule này có apply cho MỌI project không?"*
- YES → `~/.claude/` (global)
- NO → `[project]/.claude/` (per-project)

| Loại dữ liệu | Global `~/.claude/` | Per-project `.claude/` |
|---|---|---|
| Ngôn ngữ trả lời | ✓ CLAUDE.md | |
| Superpowers triggers | ✓ CLAUDE.md | |
| Codex delegation rules | ✓ CLAUDE.md | |
| Workflow Claude+Codex | ✓ templates/ | @include template |
| Hook chạy mọi project | ✓ settings.json | |
| Hook riêng project | | ✓ .claude/hooks/ |
| MCP server | | ✓ .mcp.json |
| Lệnh test cụ thể | | ✓ .claude/rules/ |
| DB schema convention | | ✓ .claude/rules/ |
| API layer rules | | ✓ .claude/rules/api.md |
| Sub-agent chung | | ✓ .claude/agents/ |
| /slash command | | ✓ .claude/commands/ |
| Output style chung | ✓ CLAUDE.md | |
| Output style đặc thù | | ✓ .claude/output-styles/ |
| Override cá nhân | | ✓ CLAUDE.local.md / settings.local.json |

**Khi không chắc:** đặt per-project trước, nếu thấy dùng ở 3+ project → move lên global template.
