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
├── CLAUDE.md  (@~/.claude/templates/code-project.md + @context/architecture.md)
├── rules/     ← trống, add-ons thêm khi cần
└── context/
    └── architecture.md  ← blank
```

---

## Bước 3 — Kiểm tra Dependencies

| Tool | Kiểm tra | Cài nếu thiếu |
|------|----------|---------------|
| Superpowers | `/plugin list` | `/plugin install superpowers@claude-plugins-official` |
| Markitdown | `markitdown --version` | `pip install markitdown` |

---

## Bước 4 — Báo xong, bắt đầu làm việc
