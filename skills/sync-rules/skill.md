---
name: sync-rules
description: Sync cấu trúc rules của project với global template — dùng git để detect thay đổi, so sánh từng file với template, báo gaps và merge. Dùng khi user nói "sync rules" hoặc "audit rules".
---

# Sync Rules

<HARD-GATE>
**Bước đầu tiên bắt buộc: tạo TodoWrite với 6 tasks sau, TRƯỚC KHI làm bất cứ điều gì khác.**

Nếu không tạo todo → không được tiếp tục.

1. B0: chạy `git -C ~/.claude fetch` — check behind/ahead
2. B1: detect loại project (code / personal / research / finance / business)
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
  1. code  2. personal  3. research  4. finance  5. business
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

*Với personal / research / finance / business* → kiểm tra dòng @include đúng template chưa:
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

**Non-code project (personal / research / finance / business):**
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

### B4 — Kiểm tra `.claude/rules/*.md`

**Chỉ chạy B4 với code project.** Personal / research / finance / business không có `.claude/rules/` → bỏ qua.

Rules đặt trong `.claude/rules/` (không phải root `rules/`). Nếu phát hiện `rules/` ở root → đề xuất di chuyển vào `.claude/rules/`.

`.claude/rules/*.md` chỉ được chứa tool config thuần túy — không chứa workflow.

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| MCP commands, lệnh test | Workflow, feature flow, bug fix flow |
| Quirk tool (EPERM, port) | TDD rules, commit rules, token discipline |
| Path-scoped convention (frontmatter `path:`) | Global workflow |

`rules/workflow.md` tồn tại → xóa toàn bộ (không nên tồn tại).  
File khác có workflow lẫn vào → xóa phần vi phạm, giữ tool config.  
Di chuyển nội dung project-specific sang `## Project-Specific Rules` trong CLAUDE.md trước khi xóa.  
File rỗng sau cleanup → xóa luôn.

---

### B5 — Báo cáo + Fix

**Báo cáo trước — adapt theo loại project:**

*Code project:*
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề]
  ✗ AGENTS.md: outdated (section X từ [date]) — [N] conflict
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
  ⚠ rules/workflow.md: xóa "[section]", giữ "[section]"
  ✗ rules/supabase.md: thiếu (dùng Supabase)
  ✗ context/architecture.md: thiếu
```

*Business project:*
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề]
  ✗ context/business-overview.md: thiếu
  ✗ context/decisions.md: thiếu
  ✗ data/raw/: thiếu
  ✗ reports/: thiếu
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
```

*Personal / research / finance:*
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề — @include sai template hoặc thiếu]
  ✗ [memory file/folder]: thiếu theo template project type
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
```

```
[GLOBAL — mở session ~/.claude để xử lý]
  ⚠ ...
```

Dù không có gap → vẫn liệt kê những gì đã check: `✓ đã check: CLAUDE.md, [danh sách phù hợp loại project]`.

Hỏi "Xử lý hết không?" → sau khi user OK, chỉ chạy bước phù hợp loại:

**Code:** Fix @include → Merge AGENTS.md → Cleanup rules/ → Xóa trùng lặp CLAUDE.md → Content cleanup
**Business:** Tạo memory structure thiếu → Fix @include → Xóa trùng lặp CLAUDE.md → Content cleanup
**Research:** Tạo `sources/`, `notes/`, `findings.md`, `open-questions.md`, `context/decisions.md` nếu thiếu → Fix @include → Content cleanup
**Finance:** Tạo `data/raw/`, `data/processed/`, `models/`, `reports/`, `assumptions.md`, `context/decisions.md` nếu thiếu → Fix @include → Content cleanup
**Personal:** Tạo `goals.md`, `weekly-review.md`, `notes.md`, `context/decisions.md` nếu thiếu → Fix @include → Content cleanup

**Content cleanup — chạy cuối cùng, sau tất cả fix:**

Đọc lại CLAUDE.md và AGENTS.md sau khi đã fix. Tìm và liệt kê:

| Loại | Ví dụ | Hành động |
|---|---|---|
| Placeholder chưa điền | `[tên project]`, `[link]`, `[mô tả]` | Flag — nhắc user điền |
| Section trùng với @include | Viết lại TDD rules đã có trong template | Đề xuất xóa |
| Override cũ không còn cần | Section dùng tool đã bỏ | Đề xuất xóa |
| Section rỗng | Heading không có nội dung | Đề xuất xóa |

Liệt kê tất cả, hỏi từng cái hoặc "Xóa hết không?" trước khi động vào file.

Báo: "Xong. Tự review + commit."
