---
name: audit-rules
description: Audit cấu trúc rules của project hiện tại — đọc ~/.claude/SETUP.md làm source of truth, dùng git để xem tổng thể thay đổi, so sánh với template, báo gaps còn thiếu hoặc sắp xếp sai. Dùng khi user nói "audit rules".
---

# Audit Rules

So sánh project hiện tại với chuẩn được định nghĩa trong `~/.claude/SETUP.md`.  
Dùng git làm nguồn chính để detect thay đổi — không grep từng file lẻ.

## GIỚI HẠN PHẠM VI — BẮT BUỘC

**Skill này chỉ được đọc/ghi trong thư mục project hiện tại.**

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| Đọc `~/.claude/` (reference) | Ghi bất kỳ file nào vào `~/.claude/` |
| Tạo/sửa file trong project | Sửa global templates, skills, CLAUDE.md global |
| `git status`, `git log`, `git diff` (read-only) | `git add`, `git commit`, `git init` trong project |
| Merge nội dung vào project's AGENTS.md | Commit vào repo `~/.claude` |

**Git trong project = chỉ đọc.** Skill không commit, không stage, không init repo project. Sau khi tạo file xong → báo user tự commit.

Nếu audit phát hiện vấn đề ở global config (`~/.claude`) → **chỉ báo cáo**, không sửa. User tự mở session `~/.claude` để xử lý.

---

## Quy Trình

### Bước 0 — Kiểm tra ~/.claude có up-to-date không

```bash
git -C ~/.claude fetch --quiet
git -C ~/.claude status --short --branch
```

Nếu output có `behind` → **dừng lại**, báo user:
```
⚠ ~/.claude chưa up-to-date với remote ([N] commits behind).
  Chạy: git -C ~/.claude pull
  Sau đó gọi lại audit rules.
```

Nếu up-to-date hoặc không có remote → tiếp tục.

---

### Bước 1 — Snapshot toàn project bằng git

Dùng 2 lệnh để có cái nhìn tổng thể — tracked + untracked + history:

```bash
git status --short        # tất cả thay đổi: staged, unstaged, untracked
git log --oneline -5      # 5 commit gần nhất (không filter theo path)
```

Nếu project **không có git** → skip bước này, tiếp tục Bước 2.

Từ `git status --short` → nhận dạng:
- `??` = file mới chưa commit (rules/, context/ thường rơi vào đây)
- `M` = file đã sửa
- `A` = file đã stage để commit

Từ `git log` → biết project đang ở giai đoạn nào (mới init, đang dev, hay ổn định).

Không cần filter theo path — mục tiêu là thấy toàn cảnh trước khi đi sâu.

---

### Bước 2 — Đọc global standard + detect stack

Đọc `~/.claude/SETUP.md` để lấy cấu trúc skeleton bắt buộc.

Tìm file deps của project để detect stack:
- Node: `package.json`
- Python: `pyproject.toml` hoặc `requirements.txt`
- Go: `go.mod`

Nếu không có file deps → project chưa có code, báo ngay và dừng.

Detect add-on cần thêm:

| Phát hiện trong deps | Add-on cần thêm |
|----------------------|-----------------|
| `@supabase/supabase-js` | `rules/supabase.md` |
| `playwright` / `@playwright/test` | `rules/testing.md` (Playwright) |
| `vitest` | `rules/testing.md` (Vitest) |
| `jest` | `rules/testing.md` (Jest) |

---

### Bước 3 — So sánh project với template

#### 3a. Kiểm tra CLAUDE.md

Kiểm tra `CLAUDE.md` trong project có `@~/.claude/templates/code-project.md` không:

```bash
grep "@~/.claude/templates/code-project.md" CLAUDE.md
```

- **Có** → CLAUDE.md dùng @include, tự nhận template mới → không cần sync thủ công
- **Không có** → CLAUDE.md là bản copy thủ công → flag là outdated nếu đã sửa template
- **File không tồn tại** → flag là thiếu

Nếu CLAUDE.md là copy thủ công → kiểm tra ngày sửa cuối vs ngày template update:

```bash
# Ngày CLAUDE.md được commit lần cuối trong project
git log --oneline -1 -- CLAUDE.md

# Ngày code-project.md được sửa lần cuối trong ~/.claude
git -C ~/.claude log --oneline -1 -- templates/code-project.md
```

Nếu template mới hơn CLAUDE.md → flag "CLAUDE.md outdated (dùng @include thay copy thủ công)".

Kiểm tra thêm:
- Có `@context/architecture.md` không?
- Các add-on detect được → có `@rules/[tool].md` tương ứng không?

#### 3b. Kiểm tra AGENTS.md

Nếu `AGENTS.md` chưa tồn tại → flag thiếu, kết thúc bước này.

Nếu tồn tại → kiểm tra version marker:

```bash
grep "template:" AGENTS.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}'
```

**Nếu có marker** → extract date, so sánh với template bằng git diff:

```bash
# Lấy commit hash tại thời điểm marker date
git -C ~/.claude log --oneline --before="[YYYY-MM-DD] 23:59" -1 -- templates/AGENTS.md

# Xem chỉ những phần đã thay đổi kể từ đó
git -C ~/.claude diff [commit-hash]..HEAD -- templates/AGENTS.md
```

Từ diff output → chỉ báo **đúng những section thay đổi**, không list lại toàn bộ file.

**Nếu không có marker** → "AGENTS.md không có version marker" → đề xuất merge toàn bộ Workflow section từ template, giữ nguyên Project Context.

#### 3c. Kiểm tra các file còn lại

```bash
# Check sự tồn tại
ls rules/ context/architecture.md 2>/dev/null
```

---

### Bước 4 — Báo cáo

Tách thành **2 nhóm rõ ràng**:

```
[PROJECT — có thể fix ngay]
  ✗ CLAUDE.md: dùng copy thủ công thay @include (template mới hơn [N] ngày)
  ✗ AGENTS.md: chưa có
  ✗ AGENTS.md: outdated (thiếu section X, Y từ [date])
  ✗ rules/supabase.md: chưa có (nhưng dùng Supabase)
  ✗ context/architecture.md: chưa có

[GLOBAL CONFIG — cần fix thủ công trong session ~/.claude]
  ⚠ (liệt kê nếu phát hiện, nhưng không sửa)
```

Nếu git log ở Bước 1 cho thấy file đã được sửa gần đây → nhắc context đó khi báo cáo:
```
  ℹ CLAUDE.md được sửa lần cuối: [date] (git log)
```

Chỉ hỏi "Tạo hết không?" cho nhóm PROJECT.

---

### Bước 5 — Tạo (sau khi user đồng ý)

Tạo/sửa chỉ trong project directory:
- Copy files từ `~/.claude/templates/` vào project
- Thêm `@import` vào `CLAUDE.md` project theo thứ tự: code-project → add-ons → context
- Khi tạo `AGENTS.md`: tự điền Project Context từ deps (tên từ `package.json name`, stack từ deps). Không để placeholder blank.
- Khi merge `AGENTS.md` outdated: chỉ cập nhật phần Workflow + Quy Tắc Chung, giữ nguyên Project Context.
- Ưu tiên chuyển CLAUDE.md từ copy thủ công sang `@~/.claude/templates/code-project.md` nếu user đồng ý.

---

### Bước 6 — Xác nhận xong

Báo ngắn gọn: file nào đã tạo/sửa trong project.  
Nếu có global config issues → nhắc user: "Mở session `~/.claude` để xử lý."
