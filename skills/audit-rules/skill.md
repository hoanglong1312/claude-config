---
name: audit-rules
description: Audit cấu trúc rules của project hiện tại — đọc ~/.claude/SETUP.md làm source of truth, so sánh với project hiện tại, báo gaps còn thiếu hoặc sắp xếp sai. Dùng khi user nói "audit rules".
---

# Audit Rules

So sánh project hiện tại với chuẩn được định nghĩa trong `~/.claude/SETUP.md`.  
Không maintain checklist riêng — SETUP.md là source of truth.  
Structure chuẩn của add-on files xem trong `~/.claude/CLAUDE.md` phần Add-On Rules.

## Quy Trình

### Bước 1 — Đọc global standard

Đọc `~/.claude/SETUP.md` để lấy cấu trúc skeleton bắt buộc cho từng loại project.  
(Global CLAUDE.md đã load sẵn trong context — không cần đọc lại.)

### Bước 2 — Đọc deps để detect stack

Tìm file deps của project:
- Node: `package.json`
- Python: `pyproject.toml` hoặc `requirements.txt`
- Go: `go.mod`

Nếu không có file deps → project chưa có code, báo ngay và dừng.

Detect stack + các tool có add-on template:

| Phát hiện trong deps | Add-on cần thêm |
|----------------------|-----------------|
| `@supabase/supabase-js` | `rules/supabase.md` |
| `playwright` / `@playwright/test` | `rules/testing.md` (Playwright) |
| `vitest` | `rules/testing.md` (Vitest) |
| `jest` | `rules/testing.md` (Jest) |

### Bước 3 — So sánh project với SETUP.md

Đọc SETUP.md để lấy danh sách files bắt buộc cho loại project tương ứng (code/research/finance/personal).  
Sau đó kiểm tra từng item có tồn tại trong project không.

Ví dụ với **code project**, SETUP.md yêu cầu skeleton:
```
CLAUDE.md  
AGENTS.md  
rules/  
context/architecture.md
```

Ngoài ra kiểm tra nội dung `CLAUDE.md`:
- Có `@~/.claude/templates/code-project.md` chưa?
- Có `@context/architecture.md` chưa?
- Các add-on detect được → có `@rules/[tool].md` tương ứng chưa?

### Bước 4 — Báo cáo gaps

Format báo cáo:

```
Phát hiện: [stack — ví dụ: Next.js + Supabase + Playwright]

So sánh với chuẩn SETUP.md:
  ✓ CLAUDE.md: có
  ✗ @code-project.md: chưa import trong CLAUDE.md
  ✗ AGENTS.md: chưa có
  ✗ rules/supabase.md: chưa có (nhưng dùng Supabase)
  ✗ rules/testing.md: chưa có (nhưng dùng Playwright)
  ✗ context/architecture.md: chưa có

Sẽ tạo / sửa:
  - Thêm @~/.claude/templates/code-project.md vào CLAUDE.md
  - Copy AGENTS.md từ ~/.claude/templates/AGENTS.md (điền Project Context tự động)
  - Tạo rules/supabase.md (blank, structure chuẩn từ CLAUDE.md)
  - Tạo rules/testing.md (blank, điền lệnh test từ deps)
  - Tạo context/architecture.md (blank)

Tạo hết không?
```

### Bước 5 — Tạo (sau khi user đồng ý)

Tạo đúng theo những gì SETUP.md yêu cầu:
- Copy files từ `~/.claude/templates/` về đúng vị trí trong project
- Thêm `@import` vào `CLAUDE.md` theo thứ tự: code-project → add-ons → context
- Khi tạo `AGENTS.md`: tự điền luôn phần Project Context từ những gì đã detect ở Bước 2 (tên project từ `package.json` → `name`, stack từ deps, loại project từ cấu trúc). Không để placeholder blank.

### Bước 6 — Xác nhận xong

Báo ngắn gọn: file nào đã tạo, @import nào đã thêm.
