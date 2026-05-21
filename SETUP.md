# Project Init

*Claude đọc file này khi vào project không có CLAUDE.md.*

---

## Bước 0 — Audit project hiện tại

Nếu project có sẵn code (`package.json`, `*.py`, `*.go`...):

1. Đọc file deps → detect stack
2. Kiểm tra gaps:

| Kiểm tra | Kết quả |
|----------|---------|
| `CLAUDE.md` | có / chưa → sẽ tạo |
| `CLAUDE.local.md` | có / chưa → sẽ tạo + gitignore |
| `.gitignore` | có / chưa → tạo hoặc append |
| `.mcp.json` | có / chưa → hỏi (code project) |
| `rules/` folder | có / chưa → sẽ tạo |
| `context/architecture.md` | có / chưa → tạo blank |
| `@supabase/supabase-js` trong deps | → hỏi load `rules/supabase.md` |
| `playwright` trong deps | → hỏi load `rules/testing.md` (Playwright) |
| `vitest` / `jest` trong deps | → hỏi load `rules/testing.md` |

3. Báo cáo + xác nhận 1 lần → tạo hết.

Nếu project trống → tiếp tục Bước 1.

---

## Bước 1 — Hỏi loại project

> "Project này thuộc loại nào: code / research / finance / personal / business?"

---

## Bước 2 — Tạo theo loại

| Loại | Làm gì |
|------|--------|
| research | Tạo `CLAUDE.md` từ `~/.claude/templates/research.md` |
| finance | Tạo `CLAUDE.md` từ `~/.claude/templates/finance.md` |
| personal | Tạo `CLAUDE.md` từ `~/.claude/templates/personal.md` |
| business | Tạo skeleton — xem chi tiết bên dưới |
| code | Tạo skeleton — xem chi tiết bên dưới |

---

### Skeleton — Personal / Research / Finance

```
[project]/
├── CLAUDE.md              ← @include template tương ứng
├── CLAUDE.local.md        ← gitignored, override cá nhân
└── .gitignore
```

`.gitignore` tối thiểu:
```
CLAUDE.local.md
.env
*.local.*
```

---

### Skeleton — Business Project

```
[project]/
├── CLAUDE.md              ← @include business.md + khai báo specialization
├── CLAUDE.local.md        ← gitignored
├── .gitignore
├── data/
│   ├── raw/               ← file gốc KHÔNG sửa
│   └── processed/         ← đã clean, sẵn phân tích
├── reports/
│   ├── weekly/
│   └── monthly/
├── sop/                   ← blank, viết dần
└── context/
    ├── business-overview.md   ← blank, điền thông tin doanh nghiệp
    └── decisions.md           ← blank
```

Nếu specialization = F&B → thêm:
```
├── menu/
│   ├── current/
│   └── costing/
└── hr/
    ├── schedules/
    └── onboarding/
```

**Cấu trúc CLAUDE.md chuẩn cho business:**
```markdown
@~/.claude/templates/business.md

## Project-Specific Rules
- Specialization: [F&B / retail / dịch vụ / khác]
- Scale: [số cơ sở, số nhân viên]
- Phần mềm POS: [tên hoặc "chưa có"]
- Đơn vị tiền tệ: VND
```

---

### Skeleton — Code Project

```
[project]/
├── CLAUDE.md              ← xem cấu trúc bên dưới
├── CLAUDE.local.md        ← gitignored, override cá nhân
├── .gitignore
├── .mcp.json              ← MCP servers (Codex bắt buộc, Supabase nếu dùng)
├── AGENTS.md              ← copy từ ~/.claude/templates/AGENTS.md
├── .claude/               ← tạo component nào khi cần, không bắt buộc tất cả
│   ├── settings.json      ← khi cần permission / hook riêng
│   ├── hooks/             ← khi cần automation
│   ├── agents/            ← khi cần sub-agent context riêng
│   └── commands/          ← khi cần /slash command riêng
├── rules/                 ← CHỈ tool config, KHÔNG chứa workflow
│   ├── supabase.md        ← nếu dùng Supabase
│   └── testing.md         ← nếu có test framework
├── context/
│   └── architecture.md    ← blank
└── docs/superpowers/
    ├── specs/
    └── decisions.md       ← blank
```

**Cấu trúc CLAUDE.md chuẩn:**
```markdown
@~/.claude/templates/code-project.md
@context/architecture.md
@rules/supabase.md        ← thêm nếu dùng Supabase
@rules/testing.md         ← thêm nếu có test framework

## Project-Specific Rules   ← thêm ở đây nếu cần override nhỏ
```

**Thứ tự @include bắt buộc:** `code-project.md` → `rules/*` → `context/`
Sai thứ tự → rules ghi đè template thay vì extend.

---

## Hướng Dẫn `.claude/` — Tạo Khi Nào

Không tạo folder `.claude/` mặc định. Chỉ tạo component nào khi project thực sự cần:

| Component | Tạo khi nào | Ví dụ dùng |
|---|---|---|
| `settings.json` | Cần permission hoặc hook riêng cho project | Allowlist lệnh test cụ thể |
| `hooks/SessionStart.sh` | Muốn auto-load context khi khởi động session | Đọc `decisions.md` tự động |
| `hooks/PreCompact.sh` | Muốn lưu state trước khi compact context | Ghi todo còn dở |
| `hooks/PostToolUse.sh` | Muốn auto-commit sau mỗi lần edit file | CI workflow |
| `agents/` | Cần sub-agent chạy với context window riêng | Security reviewer, researcher |
| `commands/` | Muốn `/slash` command riêng cho project | `/ship`, `/deploy`, `/test` |

**Template `hooks/SessionStart.sh`:**
```bash
#!/bin/bash
# Load project context khi khởi động
if [ -f "docs/superpowers/decisions.md" ]; then
  echo "decisions.md: $(wc -l < docs/superpowers/decisions.md) entries"
fi
if [ -f "docs/superpowers/specs" ]; then
  echo "Active specs: $(ls docs/superpowers/specs/*.md 2>/dev/null | wc -l)"
fi
```

**Template `commands/ship.md`:**
```markdown
# /ship

Chạy toàn bộ quality gate trước khi push:
1. `npm run lint` (hoặc tương đương)
2. `npm test` (hoặc tương đương)
3. `git diff --stat` → xác nhận scope
4. Báo kết quả — KHÔNG tự push
```

---

## Hướng Dẫn `.mcp.json`

Đặt ở root project. Tạo khi project dùng MCP server.

**Code project với Codex:**
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

**Thêm Supabase (nếu dùng):**
```json
{
  "mcpServers": {
    "codex": {
      "command": "npx",
      "args": ["-y", "@openai/codex-mcp"]
    },
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest",
               "--access-token", "${SUPABASE_ACCESS_TOKEN}"]
    }
  }
}
```

---

## Hướng Dẫn `rules/*.md`

**Ranh giới bắt buộc:**

| Được phép trong rules/*.md | KHÔNG được phép |
|---|---|
| MCP tool names, commands | Workflow, quy trình Claude/Codex |
| Lệnh chạy test cụ thể | TDD rules, commit rules |
| Quirk tool (EPERM, port, timeout) | Token discipline |
| Pattern codebase (folder structure) | Feature flow, bug fix flow |

Workflow nhỏ project-specific → thêm vào `## Project-Specific Rules` trong `CLAUDE.md`, không tạo `rules/workflow.md`.

**Blank structure khi tạo:**

`rules/supabase.md`:
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
```

`rules/testing.md`:
```markdown
# Testing Rules

## Lệnh chạy test
[tự điền từ deps: npx playwright test / npx vitest run / npx jest]
```

---

## Bước 3 — Kiểm tra Dependencies

| Tool | Kiểm tra |
|------|----------|
| Superpowers | `/plugin list` |
| Markitdown | `markitdown --version` |

Nếu thiếu → xem `~/.claude/README.md` để cài.

---

## Bước 4 — Báo xong, bắt đầu làm việc
