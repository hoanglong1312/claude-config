# Project Init

*Claude đọc file này khi vào project không có CLAUDE.md.*

---

## Bước 0 — Audit project hiện tại

Trước khi hỏi bất cứ gì, kiểm tra project có code chưa:

**Nếu project có sẵn code** (có `package.json`, `*.py`, `*.go`... hoặc các file source):

1. Đọc `package.json` (hoặc file deps tương đương) → detect stack
2. Kiểm tra những gì đã có / chưa có:

| Kiểm tra | Kết quả |
|----------|---------|
| `CLAUDE.md` | chưa có → sẽ tạo |
| `rules/` folder | chưa có → sẽ tạo |
| `context/architecture.md` | chưa có → tạo blank |
| `@supabase/supabase-js` trong deps | → hỏi load `rules/supabase.md` |
| `playwright` trong deps | → hỏi load `rules/testing.md` (Playwright) |
| `vitest` / `jest` trong deps | → hỏi load `rules/testing.md` (điền lệnh tương ứng) |

3. Báo cáo ngắn gọn rồi hỏi xác nhận 1 lần:
   ```
   Phát hiện: Next.js + Supabase + Playwright
   Sẽ tạo:
   ✓ CLAUDE.md (@imports: code-project + supabase + testing + context)
   ✓ rules/supabase.md (copy từ template global)
   ✓ rules/testing.md (Playwright)
   ✓ context/architecture.md (blank)
   
   Tạo hết không?
   ```
4. User đồng ý → tạo hết, xong.

**Nếu project trống** (chưa có code) → tiếp tục Bước 1.

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
