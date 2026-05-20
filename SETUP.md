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
Tạo cấu trúc skeleton — không hỏi về stack, add-ons load sau khi cần:

```
[project]/
├── CLAUDE.md
├── rules/              ← trống, add-ons thêm dần khi cần
└── context/
    └── architecture.md
```

**`CLAUDE.md`** — chỉ @import base template + context:
```markdown
# CLAUDE.md — [Tên Project]

@~/.claude/templates/code-project.md
@context/architecture.md
```

Add-ons (`rules/supabase.md`, `rules/testing.md`...) **KHÔNG tạo lúc init**.
Claude tự nhận ra khi project dùng tool nào → hỏi user → copy từ template global về → thêm @import vào CLAUDE.md.

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
