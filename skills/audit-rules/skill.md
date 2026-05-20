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

#### 3a. Kiểm tra CLAUDE.md — nội dung + thứ tự @include

Kiểm tra `CLAUDE.md` trong project có `@~/.claude/templates/code-project.md` không:

```bash
grep "@~/.claude/templates/code-project.md" CLAUDE.md
```

- **File không tồn tại** → flag là thiếu, dừng bước này
- **Có** → CLAUDE.md dùng @include, tự nhận template mới → kiểm tra thứ tự (xem bên dưới)
- **Không có** → CLAUDE.md là bản copy thủ công → tiến hành so sánh với template

**Kiểm tra thứ tự @include (nếu dùng @include):**

Thứ tự đúng bắt buộc:
```
@~/.claude/templates/code-project.md   ← phải đứng ĐẦU TIÊN
@rules/[tool].md                        ← add-ons sau
@context/architecture.md               ← context sau cùng
```

Nếu sai thứ tự → `rules/` load trước template → rules ghi đè template thay vì extend → flag:
```
  ✗ CLAUDE.md: thứ tự @include sai — code-project.md phải đứng trước rules/
```

**Nếu CLAUDE.md là copy thủ công:**

```bash
PROJECT_DATE=$(git log --format="%ai" -1 -- CLAUDE.md | cut -c1-10)
TEMPLATE_HASH=$(git -C ~/.claude log --oneline --before="$PROJECT_DATE 23:59" -1 -- templates/code-project.md | cut -d' ' -f1)
git -C ~/.claude diff $TEMPLATE_HASH..HEAD -- templates/code-project.md
```

Nếu diff **rỗng** → không cần làm gì.

Nếu diff **có nội dung** → hiện section thay đổi, hỏi:
```
Template code-project.md đã cập nhật [N] section kể từ lần cuối sync:
  + [tóm tắt section thay đổi]

Project CLAUDE.md có phần override riêng. Muốn merge không?
  1. Merge (giữ override của project, cập nhật phần template thay đổi)
  2. Bỏ qua lần này
  3. Chuyển sang @include (xóa copy, để template tự propagate)
```

Chờ user chọn. Nếu chọn **3**: xác nhận lại "Phần override sẽ mất. Xác nhận?" trước khi xóa.

Kiểm tra thêm: các add-on detect được → có `@rules/[tool].md` tương ứng chưa?

---

#### 3b. Kiểm tra AGENTS.md — workflow + conflict + Project Context

Nếu `AGENTS.md` chưa tồn tại → flag thiếu, dừng bước này.

**Bước 3b-i: Kiểm tra workflow có outdated không**

```bash
MARKER_DATE=$(grep "template:" AGENTS.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
TEMPLATE_HASH=$(git -C ~/.claude log --oneline --before="$MARKER_DATE 23:59" -1 -- templates/AGENTS.md | cut -d' ' -f1)
git -C ~/.claude diff $TEMPLATE_HASH..HEAD -- templates/AGENTS.md
```

Nếu không có marker → đề xuất merge toàn bộ Workflow section, giữ Project Context.

**Bước 3b-ii: Với mỗi section thay đổi trong diff — kiểm tra conflict**

Với mỗi section template thay đổi, so sánh với nội dung section đó trong project AGENTS.md:
- **Giống nhau** (project chưa sửa) → merge tự động, không hỏi
- **Khác nhau** (project đã override) → **dừng, hỏi user**:

```
Section "[tên section]" trong AGENTS.md đã được project sửa:

  Template mới:    [nội dung từ template]
  Project hiện tại: [nội dung project đang có]

Chọn:
  1. Lấy version template mới
  2. Giữ version của project
  3. Tự merge thủ công (skill dừng lại, user sửa file)
```

Chờ user chọn từng conflict trước khi tiếp tục.

**Bước 3b-iii: Kiểm tra Project Context có stale không**

Đọc section Project Context trong AGENTS.md (tên, stack, mục tiêu).  
So sánh stack liệt kê với deps thực tế từ `package.json`:

- Có lib mới trong deps nhưng không có trong stack → flag:
  ```
    ⚠ AGENTS.md Project Context: stack outdated (thiếu [lib mới])
  ```
- Tên project khác `package.json name` → flag tương tự

Nếu phát hiện → hỏi user xác nhận stack mới trước khi update.

---

#### 3c. Kiểm tra rules/*.md có restate global workflow không

```bash
ls rules/ 2>/dev/null
```

Với mỗi file trong `rules/`, kiểm tra có chứa nội dung đã có trong `~/.claude/templates/code-project.md` không.

Dấu hiệu restate:
- Mô tả lại cách gọi Codex
- Liệt kê lại các bước feature flow / bug fix flow
- Viết lại token discipline, TDD rules, commit rules

Nếu phát hiện → **đánh dấu xóa ngay trong Bước 5** (restate là sai chắc chắn, không cần confirm riêng):
```
  ⚠ rules/workflow.md: sẽ xóa "[tên section]" (restate template)
                        giữ lại: [những gì project-specific]
```

Khi cleanup: xóa phần restate, giữ project-specific. File rỗng sau khi xóa → xóa luôn file.

---

#### 3d. Kiểm tra context/architecture.md

```bash
ls context/architecture.md 2>/dev/null
```

Không có → flag thiếu.

---

### Bước 4 — Báo cáo

Tách thành **2 nhóm rõ ràng**, liệt kê đủ để user biết sẽ mất/giữ gì:

```
[PROJECT — có thể fix ngay]
  ✗ CLAUDE.md: thiếu
  ✗ CLAUDE.md: thứ tự @include sai (rules/ đứng trước code-project)
  ✗ CLAUDE.md: copy thủ công, template mới hơn [N] ngày
  ✗ AGENTS.md: thiếu
  ✗ AGENTS.md: outdated (section X, Y từ [date]) — [N] conflict cần xác nhận
  ✗ AGENTS.md: Project Context stale (thiếu [lib])
  ✗ rules/supabase.md: thiếu (dùng Supabase)
  ⚠ rules/workflow.md: sẽ xóa "[section]", giữ "[section]"
  ✗ context/architecture.md: thiếu

[GLOBAL CONFIG — cần fix thủ công trong session ~/.claude]
  ⚠ (liệt kê nếu phát hiện, không sửa)
```

Hỏi "Xử lý hết không?" — sau khi user đồng ý mới bắt đầu Bước 5.  
Conflict trong AGENTS.md sẽ được hỏi từng cái trong lúc merge (Bước 5).

---

### Bước 5 — Tạo / Merge (sau khi user đồng ý)

Thứ tự xử lý:
1. Tạo file thiếu (`AGENTS.md`, `rules/`, `context/`) từ template
2. Fix thứ tự @include trong `CLAUDE.md` nếu sai
3. Merge `AGENTS.md` — hỏi từng conflict theo Bước 3b-ii
4. Update Project Context `AGENTS.md` nếu stale
5. Cleanup `rules/*.md` — xóa restate, giữ project-specific
6. Merge `CLAUDE.md` copy thủ công nếu user chọn option 1

Không commit — báo user tự review rồi commit.

---

### Bước 6 — Xác nhận xong

Báo ngắn gọn: file nào đã tạo/sửa.  
Nếu có global config issues → nhắc: "Mở session `~/.claude` để xử lý."
