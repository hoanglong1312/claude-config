# Project Init

*Claude đọc file này khi vào project không có CLAUDE.md.*

---

## Bước 1 — Hỏi loại project

> "Project này thuộc loại nào: code / research / finance / personal?"

---

## Bước 2 — Tạo theo loại

### research / finance / personal
Tạo `CLAUDE.md` trong project root với nội dung từ template tương ứng:
- research → `~/.claude/templates/research.md`
- finance → `~/.claude/templates/finance.md`
- personal → `~/.claude/templates/personal.md`

Xong. Không cần làm thêm gì.

---

### code-project
Tạo cấu trúc 3 tầng:

```
[project]/
├── CLAUDE.md
├── rules/              ← add-ons tùy chọn
└── context/
    └── architecture.md
```

**`CLAUDE.md`** — @import base template + add-ons:
```markdown
# CLAUDE.md — [Tên Project]

@~/.claude/templates/code-project.md

@rules/supabase.md
@rules/testing.md
@context/architecture.md
```

**Add-ons — hỏi trước khi tạo:**

| Hỏi | Nếu có → tạo file |
|-----|-------------------|
| "Dùng Supabase không?" | `rules/supabase.md` (copy từ `~/.claude/templates/rules/supabase.md`) |
| "Testing tool là gì?" | `rules/testing.md` (copy từ `~/.claude/templates/rules/testing.md`, điền lệnh test) |

Nếu không dùng thì không tạo, không @import vào CLAUDE.md.

**`context/architecture.md`** — tạo blank, user điền dần:
```markdown
# Architecture — [Tên Project]

## Stack
-

## File quan trọng
-

## Constraints & Decisions
-
```

---

## Bước 3 — Kiểm tra Superpowers

Nếu chưa cài → nhắc: `/plugin install superpowers@claude-plugins-official`

---

## Bước 4 — Báo xong, bắt đầu làm việc
