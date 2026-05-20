# Project Init

*Claude đọc file này khi vào project không có CLAUDE.md.*

---

## Bước 0 — Audit project hiện tại

Nếu project có sẵn code (`package.json`, `*.py`, `*.go`...):

1. Đọc file deps → detect stack
2. Kiểm tra gaps:

| Kiểm tra | Kết quả |
|----------|---------|
| `CLAUDE.md` | có / chưa → sẽ tạo |
| `rules/` folder | có / chưa → sẽ tạo |
| `context/architecture.md` | có / chưa → tạo blank |
| `@supabase/supabase-js` trong deps | → hỏi load `rules/supabase.md` |
| `playwright` trong deps | → hỏi load `rules/testing.md` (Playwright) |
| `vitest` / `jest` trong deps | → hỏi load `rules/testing.md` |

3. Báo cáo + xác nhận 1 lần → tạo hết.

Nếu project trống → tiếp tục Bước 1.

---

## Bước 1 — Hỏi loại project

> "Project này thuộc loại nào: code / research / finance / personal / business?"

---

## Bước 2 — Tạo theo loại

| Loại | Làm gì |
|------|--------|
| research | Tạo `CLAUDE.md` từ `~/.claude/templates/research.md` |
| finance | Tạo `CLAUDE.md` từ `~/.claude/templates/finance.md` |
| personal | Tạo `CLAUDE.md` từ `~/.claude/templates/personal.md` |
| business | Tạo skeleton — xem chi tiết bên dưới |
| code | Tạo skeleton — xem chi tiết trong `~/.claude/templates/code-project.md` |

**Skeleton business project:**
```
[project]/
├── CLAUDE.md              ← @include business.md + khai báo specialization
├── data/
│   ├── raw/               ← file gốc KHÔNG sửa
│   └── processed/         ← đã clean, sẵn phân tích
├── reports/
│   ├── weekly/
│   └── monthly/
├── sop/                   ← blank, viết dần
└── context/
    ├── business-overview.md   ← blank, điền thông tin doanh nghiệp
    └── decisions.md           ← blank
```

Nếu specialization = F&B → thêm:
```
├── menu/
│   ├── current/
│   └── costing/
└── hr/
    ├── schedules/
    └── onboarding/
```

**Cấu trúc CLAUDE.md chuẩn cho business:**
```markdown
@~/.claude/templates/business.md

## Project-Specific Rules
- Specialization: [F&B / retail / dịch vụ / khác]
- Scale: [số cơ sở, số nhân viên]
- Phần mềm POS: [tên hoặc "chưa có"]
- Đơn vị tiền tệ: VND
```

---

**Skeleton code project:**
```
[project]/
├── CLAUDE.md   ← xem cấu trúc bên dưới
├── AGENTS.md   ← copy từ ~/.claude/templates/AGENTS.md, tự điền Project Context từ package.json
├── rules/      ← CHỈ tool config (Supabase, testing...), KHÔNG chứa workflow
└── context/
    └── architecture.md  ← blank
```

**Cấu trúc CLAUDE.md chuẩn:**
```markdown
@~/.claude/templates/code-project.md
@context/architecture.md
@rules/supabase.md        ← thêm nếu dùng Supabase
@rules/testing.md         ← thêm nếu có test framework

## Project-Specific Rules   ← thêm ở đây nếu cần override nhỏ
```

**Thứ tự @include bắt buộc:** `code-project.md` → `rules/*` → `context/`  
Sai thứ tự → rules ghi đè template thay vì extend.

**Ranh giới rules/*.md — bắt buộc:**

| Được phép trong rules/*.md | KHÔNG được phép |
|---------------------------|-----------------|
| MCP tool names, commands | Workflow, quy trình Claude/Codex |
| Lệnh chạy test cụ thể | TDD rules, commit rules |
| Quirk tool (EPERM, port, timeout) | Token discipline |
| Pattern codebase (folder structure) | Feature flow, bug fix flow |

Workflow nhỏ project-specific → thêm vào section `## Project-Specific Rules` trong `CLAUDE.md`, không tạo `rules/workflow.md`.

**Blank structure khi tạo add-on files:**

`rules/supabase.md`:
```markdown
# Supabase Rules

## MCP Tools
| Việc | Tool |
|------|------|
| Apply migration | `mcp__supabase__apply_migration` |
| Query / debug | `mcp__supabase__execute_sql` |
| Kiểm tra schema | `mcp__supabase__list_tables` |

## Quy Tắc
- Tự apply migration, không bảo user vào dashboard
```

`rules/testing.md`:
```markdown
# Testing Rules

## Lệnh chạy test
[tự điền từ deps: npx playwright test / npx vitest run / npx jest]
```

---

## Bước 3 — Kiểm tra Dependencies

| Tool | Kiểm tra |
|------|----------|
| Superpowers | `/plugin list` |
| Markitdown | `markitdown --version` |

Nếu thiếu → xem `~/.claude/README.md` để cài.

---

## Bước 4 — Báo xong, bắt đầu làm việc
