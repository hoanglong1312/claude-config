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
| `rules/` folder | có / chưa → sẽ tạo |
| `context/architecture.md` | có / chưa → tạo blank |
| `@supabase/supabase-js` trong deps | → hỏi load `rules/supabase.md` |
| `playwright` trong deps | → hỏi load `rules/testing.md` (Playwright) |
| `vitest` / `jest` trong deps | → hỏi load `rules/testing.md` |

3. Báo cáo + xác nhận 1 lần → tạo hết.

Nếu project trống → tiếp tục Bước 1.

---

## Bước 1 — Hỏi loại project

> "Project này thuộc loại nào: code / research / finance / personal?"

---

## Bước 2 — Tạo theo loại

| Loại | Làm gì |
|------|--------|
| research | Tạo `CLAUDE.md` từ `~/.claude/templates/research.md` |
| finance | Tạo `CLAUDE.md` từ `~/.claude/templates/finance.md` |
| personal | Tạo `CLAUDE.md` từ `~/.claude/templates/personal.md` |
| code | Tạo skeleton — xem chi tiết trong `~/.claude/templates/code-project.md` |

**Skeleton code project:**
```
[project]/
├── CLAUDE.md   (@~/.claude/templates/code-project.md + @context/architecture.md)
├── AGENTS.md   ← copy từ ~/.claude/templates/AGENTS.md, tự điền Project Context từ package.json
├── rules/      ← tạo khi detect tool tương ứng trong deps
└── context/
    └── architecture.md  ← blank
```

**Blank structure khi tạo add-on files:**

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

## Quy Tắc
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
