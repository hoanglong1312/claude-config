---
name: audit-rules
description: Audit cấu trúc rules của project hiện tại — kiểm tra gaps so với chuẩn 3-layer, detect stack từ deps, đề xuất add-ons còn thiếu. Dùng khi user nói "audit rules" hoặc muốn check project có sẵn.
---

# Audit Rules

Kiểm tra project hiện tại có đúng cấu trúc chuẩn chưa, detect stack, đề xuất add-ons còn thiếu.

## Checklist

1. **Đọc deps** — tìm `package.json` (hoặc `pyproject.toml`, `go.mod`...) để detect stack
2. **Kiểm tra cấu trúc** — so sánh với chuẩn 3-layer
3. **Detect add-ons cần thiết** — dựa trên deps đã đọc
4. **Báo cáo gaps** — liệt kê rõ có / thiếu / cần thêm
5. **Xác nhận 1 lần** — hỏi user trước khi tạo
6. **Tạo files còn thiếu** — copy từ template global, thêm @import vào CLAUDE.md

## Cấu Trúc Chuẩn

```
[project]/
├── CLAUDE.md                        ← @imports: code-project.md + add-ons + context
├── rules/
│   ├── supabase.md                  ← chỉ nếu dùng Supabase
│   └── testing.md                   ← chỉ nếu có test tool
└── context/
    └── architecture.md              ← mô tả stack, file quan trọng, decisions
```

## Bảng Detect Add-Ons

| Phát hiện trong deps | Add-on cần thêm |
|----------------------|-----------------|
| `@supabase/supabase-js` | `rules/supabase.md` (copy từ `~/.claude/templates/rules/supabase.md`) |
| `playwright` / `@playwright/test` | `rules/testing.md` — điền: `npx playwright test --reporter=line` |
| `vitest` | `rules/testing.md` — điền: `npx vitest run` |
| `jest` | `rules/testing.md` — điền: `npx jest` |

## Quy Trình

### Bước 1 — Đọc deps

Tìm và đọc file deps của project:
- Node: `package.json`
- Python: `pyproject.toml` hoặc `requirements.txt`
- Go: `go.mod`

Nếu không có file deps → project chưa có code, báo ngay và dừng.

### Bước 2 — Kiểm tra cấu trúc

Kiểm tra từng item:

| Item | Có? |
|------|-----|
| `CLAUDE.md` | ✓ / ✗ |
| `@~/.claude/templates/code-project.md` trong CLAUDE.md | ✓ / ✗ |
| `rules/` folder | ✓ / ✗ |
| `context/architecture.md` | ✓ / ✗ |

### Bước 3 — Báo cáo

Format báo cáo:

```
Phát hiện: [stack, ví dụ: Next.js + Supabase + Playwright]

Cấu trúc hiện tại:
  ✓ CLAUDE.md: có
  ✗ @code-project.md: chưa import
  ✗ rules/supabase.md: chưa có (nhưng dùng Supabase)
  ✗ rules/testing.md: chưa có (nhưng dùng Playwright)
  ✗ context/architecture.md: chưa có

Sẽ tạo / sửa:
  - Thêm @~/.claude/templates/code-project.md vào CLAUDE.md
  - Copy rules/supabase.md từ template global
  - Copy rules/testing.md từ template global (Playwright)
  - Tạo context/architecture.md (blank)

Tạo hết không?
```

### Bước 4 — Tạo (sau khi user đồng ý)

- Với mỗi file thiếu: copy từ `~/.claude/templates/rules/[tool].md` → `[project]/rules/[tool].md`
- Thêm `@rules/[tool].md` vào CLAUDE.md (đúng thứ tự: code-project → add-ons → context)
- Tạo `context/architecture.md` blank nếu chưa có

### Bước 5 — Xác nhận xong

Báo ngắn gọn: file nào đã tạo, @import nào đã thêm.
Nhắc user điền `context/architecture.md` để Claude hiểu project sâu hơn.
