---
name: audit-rules
description: Audit cấu trúc rules của project hiện tại — đọc ~/.claude/SETUP.md làm source of truth, so sánh với project hiện tại, báo gaps còn thiếu hoặc sắp xếp sai. Dùng khi user nói "audit rules".
---

# Audit Rules

So sánh project hiện tại với chuẩn được định nghĩa trong `~/.claude/SETUP.md`.  
Không maintain checklist riêng — SETUP.md là source of truth.

## GIỚI HẠN PHẠM VI — BẮT BUỘC

**Skill này chỉ được đọc/ghi trong thư mục project hiện tại.**

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| Đọc `~/.claude/` (reference) | Ghi bất kỳ file nào vào `~/.claude/` |
| Tạo/sửa file trong project | Sửa global templates, skills, CLAUDE.md global |
| Merge nội dung vào project's AGENTS.md | Commit vào repo `~/.claude` |

Nếu audit phát hiện vấn đề ở global config (`~/.claude`) → **chỉ báo cáo**, không sửa. User tự mở session `~/.claude` để xử lý.

---

## Quy Trình

### Bước 1 — Đọc global standard

Đọc `~/.claude/SETUP.md` để lấy cấu trúc skeleton bắt buộc.  
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

Kiểm tra từng item của skeleton có tồn tại không:

```
CLAUDE.md  
AGENTS.md  
rules/  
context/architecture.md
```

Kiểm tra nội dung `CLAUDE.md` của project:
- Có `@~/.claude/templates/code-project.md` chưa?
- Có `@context/architecture.md` chưa?
- Các add-on detect được → có `@rules/[tool].md` tương ứng chưa?

Nếu `AGENTS.md` đã tồn tại, kiểm tra version marker:

```bash
grep "template:" AGENTS.md    # lấy date, ví dụ: <!-- template: 2026-05-20 -->
```

Nếu có marker → extract date (lấy 10 ký tự đầu sau "template: "), so sánh với template bằng git diff:

```bash
# Extract date từ marker (format: YYYY-MM-DD)
grep "template:" AGENTS.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}'

# Lấy commit hash tại thời điểm đó
git -C ~/.claude log --oneline --before="[YYYY-MM-DD] 23:59" -1 -- templates/AGENTS.md

# Xem chỉ những phần đã thay đổi kể từ đó
git -C ~/.claude diff [commit-hash]..HEAD -- templates/AGENTS.md
```

Từ diff output → chỉ báo **đúng những section thay đổi**, không list lại toàn bộ file.

Nếu không có marker → "AGENTS.md không có version marker" → đề xuất merge toàn bộ Workflow section từ template, giữ nguyên Project Context.

### Bước 4 — Báo cáo

Tách thành **2 nhóm rõ ràng**:

```
[PROJECT — có thể fix ngay]
  ✗ AGENTS.md: chưa có
  ✗ AGENTS.md: outdated (thiếu decisions.md, plan format)
  ✗ rules/supabase.md: chưa có (nhưng dùng Supabase)
  ✗ context/architecture.md: chưa có

[GLOBAL CONFIG — cần fix thủ công trong session ~/.claude]
  ⚠ (liệt kê nếu phát hiện, nhưng không sửa)
```

Chỉ hỏi "Tạo hết không?" cho nhóm PROJECT.

### Bước 5 — Tạo (sau khi user đồng ý)

Tạo/sửa chỉ trong project directory:
- Copy files từ `~/.claude/templates/` vào project
- Thêm `@import` vào `CLAUDE.md` project theo thứ tự: code-project → add-ons → context
- Khi tạo `AGENTS.md`: tự điền Project Context từ deps (tên từ `package.json name`, stack từ deps). Không để placeholder blank.
- Khi merge `AGENTS.md` outdated: chỉ cập nhật phần Workflow + Quy Tắc Chung, giữ nguyên Project Context.

### Bước 6 — Xác nhận xong

Báo ngắn gọn: file nào đã tạo/sửa trong project.  
Nếu có global config issues → nhắc user: "Mở session `~/.claude` để xử lý."
