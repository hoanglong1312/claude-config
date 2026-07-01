---
description: Format task plan-overview.md, status transition, decisions.md, AGENTS sync. Dùng khi execute plan nhiều task.
---

# /plan-track — Plan tracking

## docs/ layout

```
docs/plan-overview.md                       ← source of truth: task + tiến độ (Claude)
docs/superpowers/specs/YYYY-MM-DD-*.md       ← spec (Claude)
docs/superpowers/decisions.md                ← từ ASSUMPTION: (Claude)
```

## Task format

```markdown
### Task N: [Tên]
**Status:** pending
**Commit:** —
Steps:
- [ ] Step 1...
```

Codex update bằng string replace:
- Start: `**Status:** pending` → `in_progress`
- Done: → `done` + `**Commit:** [hash]`
- Blocked: → `blocked` + `**Reason:** QA-FAIL: [lý do]`

1 commit / task. Codex commit `.md` status cùng code.

## decisions.md

Tích lũy. Codex đọc trước mỗi executing-plans (tránh lặp câu hỏi).
```
## [YYYY-MM-DD] — [feature]
- ASSUMPTION: [Codex giả định gì]
- Decision: [Claude quyết]
- Applies to: [task/file]
```

## AGENTS.md sync

| Thay đổi | Cập nhật |
|---|---|
| Workflow / ký hiệu mới | CLAUDE.md + AGENTS.md |
| Thêm/bỏ tool, stack | AGENTS.md + context/architecture.md |
| Rule chỉ Codex | AGENTS.md |
| Sửa template AGENTS.md | bump `<!-- template: YYYY-MM-DD -->` |

## Review gate (optional)

Spec/plan phức tạp (3+ subsystem) → dispatch Codex review trước execute:
```
Review [path]. Check: gaps, contradictions, ambiguous req, missing error handling. Report: numbered issues + severity + fix. Concise.
```
