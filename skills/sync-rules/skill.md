---
name: sync-rules
description: Sync cấu trúc rules của project với global template — dùng git để detect thay đổi, so sánh từng file với template, báo gaps và merge. Dùng khi user nói "sync rules" hoặc "audit rules".
---

# Sync Rules

<HARD-GATE>
**Bước đầu tiên bắt buộc: tạo TodoWrite với 6 tasks sau, TRƯỚC KHI làm bất cứ điều gì khác.**

Nếu không tạo todo → không được tiếp tục.

1. B0: chạy `git -C ~/.claude fetch` — check behind/ahead
2. B1: detect loại project (code / personal / research / finance)
3. B2: đọc `CLAUDE.md` project — check @include đúng template chưa, diff nếu copy, review trùng lặp
4. B3: đọc `AGENTS.md` project — marker date → git diff template → check conflict (bỏ qua nếu non-code và không có file)
5. B4: đọc từng file `rules/` — check ranh giới tool config vs workflow (CHỈ code project)
6. B5: xuất báo cáo đầy đủ + fix sau khi user OK

**`git status` KHÔNG phải cách detect gap.**
Gap chỉ xác định được sau khi ĐỌC FILE và SO SÁNH với template thực tế.
File không thay đổi trong git vẫn có thể outdated so với template.
</HARD-GATE>

## GIỚI HẠN PHẠM VI — BẮT BUỘC

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| Đọc `~/.claude/` (reference) | Ghi bất kỳ file nào vào `~/.claude/` |
| Tạo/sửa file trong project | Sửa global templates, skills, CLAUDE.md global |
| `git status`, `git log`, `git diff` (read-only) | `git add`, `git commit`, `git init` trong project |

Phát hiện vấn đề ở `~/.claude` → chỉ báo cáo, không sửa. User mở session `~/.claude` để xử lý.

---

## Quy Trình

### B0 — Kiểm tra ~/.claude up-to-date

```bash
git -C ~/.claude fetch --quiet
git -C ~/.claude status --short --branch
```

Output có `behind` → **dừng lại**:
```
⚠ ~/.claude chưa up-to-date ([N] commits behind).
  Chạy: git -C ~/.claude pull → gọi lại sync-rules.
```

Up-to-date hoặc không có remote → tiếp tục.

---

### B1 — Detect loại project

**Bước 1: check deps file**

```bash
ls package.json pyproject.toml go.mod 2>/dev/null
```

Có → **code project**. Ghi nhớ add-ons cần check:

| Phát hiện trong deps | Add-on cần có |
|---|---|
| `@supabase/supabase-js` | `rules/supabase.md` |
| `playwright` / `@playwright/test` | `rules/testing.md` |
| `vitest` / `jest` | `rules/testing.md` |

**Bước 2: nếu không có deps → đọc CLAUDE.md để xác định loại**

```bash
grep "@~/.claude/templates/" CLAUDE.md 2>/dev/null
```

| Tìm thấy | Loại project | Template so sánh |
|---|---|---|
| `@~/.claude/templates/personal.md` | personal | `~/.claude/templates/personal.md` |
| `@~/.claude/templates/research.md` | research | `~/.claude/templates/research.md` |
| `@~/.claude/templates/finance.md` | finance | `~/.claude/templates/finance.md` |
| `@~/.claude/templates/business.md` | business | `~/.claude/templates/business.md` |
| `@~/.claude/templates/code-project.md` | code (không có deps) | `~/.claude/templates/code-project.md` |

Không tìm thấy dòng nào → hỏi user:
```
Không detect được loại project. Đây là project loại gì?
  1. code  2. personal  3. research  4. finance
```

Sau khi biết loại → tiếp tục B2.

---

### B2 — Kiểm tra CLAUDE.md

**File tồn tại không?**
Không tồn tại → flag `✗ CLAUDE.md thiếu`, skip phần còn lại của B2.

**@include hay copy thủ công?**

Dùng `TEMPLATE` = tên template detect ở B1 (ví dụ: `personal.md`, `code-project.md`).

```bash
grep "@~/.claude/templates/$TEMPLATE" CLAUDE.md
```

**Nếu dùng @include:**

*Với code project* → kiểm tra thứ tự:
```
@~/.claude/templates/code-project.md   ← PHẢI đứng đầu
@rules/[tool].md                        ← sau
@context/architecture.md               ← sau cùng
```
Sai thứ tự → flag `✗ thứ tự @include sai`.

Kiểm tra add-on detect ở B1 → có `@rules/[tool].md` tương ứng chưa?

*Với personal / research / finance* → kiểm tra dòng @include đúng template chưa:
```
@~/.claude/templates/[type].md   ← phải có và đứng đầu
```

**Nếu là copy thủ công** → so sánh với template đúng loại:

```bash
PROJECT_DATE=$(git log --format="%ai" -1 -- CLAUDE.md | cut -c1-10)
# Nếu CLAUDE.md chưa commit → dùng ngày hôm nay làm mốc
TEMPLATE_FILE="templates/$TEMPLATE"
TEMPLATE_HASH=$(git -C ~/.claude log --oneline --before="$PROJECT_DATE 23:59" -1 -- $TEMPLATE_FILE | cut -d' ' -f1)
git -C ~/.claude diff $TEMPLATE_HASH..HEAD -- $TEMPLATE_FILE
```

Diff rỗng → không cần làm gì.  
Diff có nội dung → hiện section thay đổi, hỏi:
```
Template đã cập nhật [N] section. Muốn merge không?
  1. Merge (giữ override của project)
  2. Bỏ qua
  3. Chuyển sang @include
```
Option 3 → xác nhận "Override sẽ mất. Xác nhận?" trước khi xóa.

**Review nội dung local — tìm trùng lặp:**

Đọc toàn bộ CLAUDE.md. Với mỗi nội dung nằm ngoài các dòng `@include`:

- Đã có trong template tương ứng → **trùng lặp, đề xuất xóa**
- Chỉ có trong local (constraints, convention riêng) → **giữ**

---

### B3 — Kiểm tra AGENTS.md

**Non-code project (personal / research / finance):**
Không có file AGENTS.md → bình thường, bỏ qua B3.
Có file → vẫn check như code project bên dưới.

**Code project:**
Không tồn tại → flag `✗ AGENTS.md thiếu`, dừng.

**Phát hiện thay đổi template:**

```bash
MARKER_DATE=$(grep "template:" AGENTS.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
TEMPLATE_HASH=$(git -C ~/.claude log --oneline --before="$MARKER_DATE 23:59" -1 -- templates/AGENTS.md | cut -d' ' -f1)
git -C ~/.claude diff $TEMPLATE_HASH..HEAD -- templates/AGENTS.md
```

Không có marker → đề xuất merge toàn bộ Workflow section, giữ Project Context.

Diff rỗng → AGENTS.md up-to-date ✓

**Xử lý từng section thay đổi:**

Với mỗi section trong diff:
- Project chưa sửa section đó → merge tự động
- Project đã override → **hỏi user**:

```
Section "[tên]" bị conflict:
  Template mới:     [nội dung]
  Project hiện tại: [nội dung]

  1. Lấy template  2. Giữ project  3. Merge thủ công
```

---

### B4 — Kiểm tra rules/*.md

**Chỉ chạy B4 với code project.** Personal / research / finance không có `rules/` → bỏ qua.

`rules/*.md` chỉ được chứa tool config thuần túy — không chứa workflow.

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| MCP commands, lệnh test | Workflow, feature flow, bug fix flow |
| Quirk tool (EPERM, port) | TDD rules, commit rules, token discipline |

`rules/workflow.md` tồn tại → xóa toàn bộ (không nên tồn tại).  
File khác có workflow lẫn vào → xóa phần vi phạm, giữ tool config.  
Di chuyển nội dung project-specific sang `## Project-Specific Rules` trong CLAUDE.md trước khi xóa.  
File rỗng sau cleanup → xóa luôn.

---

### B5 — Báo cáo + Fix

**Báo cáo trước:**
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề]
  ✗ AGENTS.md: outdated (section X từ [date]) — [N] conflict
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
  ⚠ rules/workflow.md: xóa "[section]", giữ "[section]"
  ✗ rules/supabase.md: thiếu (dùng Supabase)
  ✗ context/architecture.md: thiếu

[GLOBAL — mở session ~/.claude để xử lý]
  ⚠ ...
```

Dù không có gap → vẫn liệt kê "✓ đã check: CLAUDE.md, AGENTS.md, rules/, context/".

Hỏi "Xử lý hết không?" → sau khi user OK:

1. Tạo file thiếu từ template
2. Fix thứ tự @include CLAUDE.md
3. Merge AGENTS.md — hỏi từng conflict
4. Cleanup rules/*.md — di chuyển project-specific → CLAUDE.md trước khi xóa
5. Xóa trùng lặp trong CLAUDE.md
6. Báo: "Xong. Tự review + commit."
