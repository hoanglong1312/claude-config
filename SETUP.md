# Project Init — Workflow Chuẩn

*File này được Claude đọc tự động khi init code project mới.*
*Claude hỏi user 1 câu duy nhất rồi tự làm hết.*

---

## Claude: Hỏi user câu này

> "Project này anh muốn dùng workflow chuẩn (Superpowers + Codex + rules/) không?
> Nếu có em sẽ hỏi thêm 2 câu về stack rồi tự setup hết."

---

## Nếu user đồng ý → Hỏi thêm 2 câu (lần lượt, không hỏi cùng lúc)

1. "Project dùng Supabase không?" (có / không)
2. "Testing tool là gì?" (Playwright / Vitest / Jest / chưa có)

---

## Sau khi có đủ thông tin → Tự tạo cấu trúc này

```
[project]/
├── CLAUDE.md
├── rules/
│   ├── workflow.md
│   ├── supabase.md     ← chỉ tạo nếu dùng Supabase
│   └── testing.md
└── context/
    └── architecture.md
```

### Nội dung từng file

**`CLAUDE.md`** — lean, chỉ @imports:
```markdown
# CLAUDE.md — [Tên Project]

@context/architecture.md
@rules/workflow.md
@rules/supabase.md
@rules/testing.md
```

**`rules/workflow.md`** — copy từ `~/.claude/templates/rules/workflow-template.md`

**`rules/supabase.md`** — copy từ `~/.claude/templates/rules/supabase.md` (nếu dùng Supabase)

**`rules/testing.md`** — copy từ `~/.claude/templates/rules/testing.md`, sau đó điền lệnh test cụ thể:
```
# Bổ sung lệnh E2E test của project này:
# Playwright: npx playwright test --reporter=line
# Vitest: npx vitest run
# Jest: npx jest
```

**`context/architecture.md`** — tạo blank template, hỏi user điền dần:
```markdown
# Architecture — [Tên Project]

## Stack
- Frontend:
- Backend:
- Database:

## File quan trọng
(điền sau)

## Constraints & Decisions
(điền sau)
```

---

## Nếu user không đồng ý → Tạo CLAUDE.md đơn giản

Chỉ tạo `CLAUDE.md` từ `~/.claude/templates/code-project.md`, không tạo rules/ hay context/.

---

## Sau khi xong → Kiểm tra Superpowers

Nếu Superpowers chưa cài → nhắc: `Chạy /plugin install superpowers@claude-plugins-official`
