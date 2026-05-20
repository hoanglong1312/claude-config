# CLAUDE.md — Code Project

## Phân Công Vai Trò AI

| Phase | Công cụ | Việc làm |
|-------|---------|----------|
| Spec | Superpowers (Claude plugin) | brainstorming → spec → lưu `docs/superpowers/specs/` |
| Planning chi tiết + Execution | Codex MCP | writing-plans, executing-plans, TDD, commit |
| Orchestration + Review | Claude main | kiến trúc, review plan, review git diff |

- `subagent-driven-development` của Claude main KHÔNG dùng → Codex thay thế hoàn toàn
- Workflow chi tiết của Codex xem trong `AGENTS.md`

## Quy Trình Execution

### Feature mới
1. Superpowers `brainstorming` → spec → lưu `docs/superpowers/specs/YYYY-MM-DD-[feature]-design.md`
2. Gọi Codex: `writing-plans` + đường dẫn spec → Codex đọc codebase + spec → technical checklist
3. Claude review plan → approve hoặc feedback cụ thể
4. Nếu có vấn đề → Codex revise plan, tối đa **2 lần** → vẫn chưa ổn → Claude sửa thẳng file `.md`
5. Gọi Codex: `executing-plans` → Codex tự parallelize task độc lập, implement + TDD + commit
6. Claude review qua `git diff` + commit message
7. Nếu có vấn đề → gọi Codex lại với feedback cụ thể
8. **Definition of Done** trước khi bàn giao:
   - [ ] Tất cả tests pass, không regression
   - [ ] `ASSUMPTION:` (giả định) đã được xác nhận (validate)
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass

### Bug fix / small change
1. Claude main phân tích nguyên nhân (`git log`, `git diff`)
2. Nếu cần trace source → gọi Codex `read-only` đọc file + báo cáo root cause (không fix)
3. Claude đánh giá root cause → quyết định approach
4. Gọi Codex `workspace-write` fix
5. Review `git diff` sau khi Codex xong

**Fallback nếu Codex fix sai 3 lần:**
- Claude đọc `git diff` + commit log của 3 lần thử
- Viết analysis ngắn vào file `.md` tạm (`docs/superpowers/debug-[issue].md`)
- Gọi lại Codex với file đó làm context bổ sung
- Nếu vẫn fail → Claude tự fix bằng Edit/Write (ngoại lệ token discipline)

### Resume sau khi session bị gián đoạn
1. Đọc `git log` → biết đang ở task nào
2. Đọc file plan trong `docs/superpowers/specs/` → biết còn task nào chưa làm
3. Đọc `docs/superpowers/decisions.md` (nếu có) → nắm các quyết định đã xác nhận
4. Gọi Codex tiếp từ task còn dở

## Cách Gọi Codex

```
Tool: mcp__codex__codex
sandbox: "workspace-write"
approval-policy: "never"
```

**Template prompt — writing-plans:**
```
Spec: docs/superpowers/specs/[file].md
Constraints: [những gì không được break — DB schema, API contract, existing pattern]
Goal: tạo technical checklist từ spec + codebase hiện tại
Output: lưu vào docs/superpowers/specs/[same-date]-[feature]-plan.md (tách khỏi spec)

Format mỗi task:
## Task: [tên ngắn]
- Files: [file cần đọc/sửa]
- Test: [test case cần pass]
- Depends on: [task khác nếu có, hoặc "none"]
- Size: S / M / L
```

**Template prompt — executing-plans:**
```
Plan: docs/superpowers/specs/[file].md  ← đã được Claude review và approve
Decisions: docs/superpowers/decisions.md  ← đọc trước khi bắt đầu
Constraints: [copy từ writing-plans prompt]
Goal: execute theo plan, dùng dispatching-parallel-agents cho task không có dependency
Nếu gặp mơ hồ: ghi ASSUMPTION: (giả định) vào commit message
```

Nếu Claude đã sửa trực tiếp file plan (fallback): thêm note `Plan đã được Claude chỉnh sửa — follow file, không cần revise thêm.`

Codex tự đọc file để lấy context — không paste code vào prompt.

## Token Discipline — Claude Main Session

**KHÔNG làm:**
- Đọc toàn bộ file source để lấy context (việc của Codex)
- Paste nội dung file vào Codex prompt
- Dùng Edit/Write cho file .jsx/.js/.sql
- Dispatch Claude subagent làm middleman

**CHỈ làm:**
- Đọc `git log` / `git diff`
- Viết/sửa file .md (plan, spec, rules)
- Gọi Codex với goal + spec path + constraints
- Quyết định kiến trúc trước khi giao Codex

**Khi review plan Codex — checklist:**
- Plan có cover đủ spec không?
- Task có quá lớn không? (1 task = 1 commit reviewable)
- Có dependency nào bị bỏ sót không?

**Khi review output Codex — checklist adversarial:**
- Đọc `git diff` + commit message (bắt buộc)
- Kiểm tra: có `ASSUMPTION:` (giả định) nào cần xác nhận không?
  → Nếu có: quyết định + append vào `docs/superpowers/decisions.md`:
  ```
  ## [YYYY-MM-DD] — [feature]
  - ASSUMPTION: [Codex giả định gì]
  - Decision: [Claude quyết định gì]
  - Applies to: [task / file liên quan]
  ```
- Kiểm tra: thay đổi đúng scope task, không thêm feature ngoài
- Kiểm tra: test pass, không regression
- Kiểm tra: logic nhất quán với spec

## Cấu Trúc `docs/superpowers/`

```
docs/superpowers/
├── specs/
│   └── YYYY-MM-DD-[feature]-design.md   ← spec + plan (Codex ghi)
└── decisions.md                          ← quyết định từ ASSUMPTION: (Claude ghi)
```

`decisions.md` tích lũy theo thời gian — Codex đọc trước mỗi lần executing-plans để tránh lặp lại câu hỏi đã có đáp án.

## Đồng Bộ CLAUDE.md ↔ AGENTS.md

| Thay đổi | Cập nhật |
|----------|----------|
| Workflow, quy trình mới | `CLAUDE.md` + `AGENTS.md` |
| Ký hiệu mới (`ASSUMPTION:`, `QA-FAIL:`...) | `CLAUDE.md` + `AGENTS.md` |
| Thêm/bỏ tool, stack | `AGENTS.md` Project Context + `context/architecture.md` |
| Rule chỉ liên quan Claude main | `CLAUDE.md` hoặc `rules/*.md` |
| Rule chỉ liên quan Codex | `AGENTS.md` |
| Sửa template `AGENTS.md` | Cập nhật `<!-- template: YYYY-MM-DD -->` ở cuối file |

## Quy Tắc Mở Rộng

**Project-specific rules → `rules/[tool].md` trong project, KHÔNG sửa file global.**

| Loại rule | Đặt ở đâu |
|-----------|-----------|
| Quirk của tool (EPERM, bind port, timeout) | `rules/[tool].md` trong project |
| Pattern riêng của codebase | `context/architecture.md` |
| Convention riêng team | `rules/workflow.md` trong project |
| Rule áp dụng mọi code project | `~/.claude/templates/code-project.md` |

**⚠️ Local rules KHÔNG được restate global workflow.**  
`rules/*.md` chỉ chứa những gì template KHÔNG có — DB schema, lệnh test cụ thể, quirk tool, pattern codebase.  
Nếu thấy mình đang copy workflow từ template vào local rules → đặt sai chỗ, xóa đi.

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
