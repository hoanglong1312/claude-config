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
   - [ ] `ENV-REQUIRED:` (nếu có) đã được user set
   - [ ] `SECURITY-SENSITIVE:` (nếu có) đã qua security review — không có lỗ hổng
   - [ ] Không có package mới ngoài plan
   - [ ] git diff đã được Claude approve
   - [ ] User acceptance test pass
   - [ ] `docs/superpowers/debug-*.md` của feature này đã archive hoặc xóa

### Bug fix / small change

**Phân loại bug trước — bắt buộc:**

| Size | Dấu hiệu | Flow |
|------|----------|------|
| S | 1-2 file, triệu chứng rõ, error message cụ thể | Skip Phase 1 → giao Codex fix thẳng |
| M/L | Cross-file, unclear cause, nhiều suspect | 2-phase đầy đủ |

**Bug S — fast path:**
1. Claude đọc symptom → viết fix instruction ngắn (file + expected behavior)
2. Giao Codex fix thẳng, không cần investigation plan

**Bug M/L — Phase 1 — Investigation (Codex làm, không ăn main context)**

1. Claude đọc `git log` / `git diff` → hiểu symptom
2. Claude viết investigation plan vào `docs/superpowers/debug-[issue].md`:
   ```
   Symptom: [mô tả bug]
   Suspect files: [danh sách file/pattern cần kiểm tra]
   Questions: [những gì cần tìm — function nào, data flow nào, error nào]
   ```
3. Gọi Codex `read-only`: đọc file + grep theo plan → trả findings (không fix)

**Exception — Claude tự làm Phase 1 khi:**
- Cần cross-reference đồng thời nhiều nguồn khác loại (DB schema + RLS policy + code logic)
- Grep đơn thuần không đủ — cần judgment để biết đang đọc cái gì

**Phase 2 — Fix (Claude phán đoán, Codex thực thi)**

4. Claude đọc findings → xác định root cause → quyết định approach
5. Append root cause + approach vào `docs/superpowers/debug-[issue].md`
6. Gọi Codex `workspace-write` fix theo approach đã xác định
7. Review `git diff` sau khi Codex xong

**Fallback nếu Codex fix sai 3 lần:**
- Claude đọc `git diff` + commit log của 3 lần thử → update `debug-[issue].md`
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

**Parallel agents — chỉ khi thực sự độc lập:**
- Được parallel: file không share prop/type/interface với nhau
- KHÔNG parallel: agent A thêm prop → agent B dùng prop đó (race condition)
- Có dependency → gộp 1 agent hoặc chạy tuần tự

## DB / RLS Pattern

**Phân công cứng:**

| Việc | Ai làm |
|------|--------|
| Viết SQL migration file | Codex |
| Apply migration | Claude (`mcp__supabase__apply_migration`) |
| Verify kết quả | Claude (`mcp__supabase__execute_sql`) |
| Tra schema khi viết SQL | Codex (nếu có read-only MCP) |

**Codex read-only Supabase (tùy chọn, recommended):**

Thêm vào `~/.codex/config.yaml` của project:
```yaml
mcpServers:
  supabase-readonly:
    command: npx
    args: ["-y", "@supabase/mcp-server-supabase@latest",
           "--access-token", "${SUPABASE_ACCESS_TOKEN}",
           "--read-only"]
```

Cho phép Codex tự tra `list_tables`, `execute_sql` (SELECT) → ít ASSUMPTION hơn.
Write operations (`apply_migration`, INSERT/UPDATE/DELETE) vẫn do Claude thực thi.

---

## Token Discipline — Claude Main Session

**KHÔNG làm:**
- Đọc toàn bộ file source để lấy context (việc của Codex)
- Tự grep/trace source khi debug — viết investigation plan rồi giao Codex
- Paste nội dung file vào Codex prompt
- Dùng Edit/Write cho file .jsx/.js/.sql
- Dispatch Claude subagent làm middleman

**CHỈ làm:**
- Đọc `git log` / `git diff`
- Viết/sửa file .md (plan, spec, rules)
- Gọi Codex với goal + spec path + constraints
- Quyết định kiến trúc trước khi giao Codex

**CLAUDE.md project — cấu trúc @include chuẩn:**
```markdown
@~/.claude/templates/code-project.md
@context/architecture.md
@.claude/rules/supabase.md   ← nếu dùng Supabase
@.claude/rules/testing.md    ← nếu có test framework
```
Thứ tự bắt buộc: template → rules → context. Sai thứ tự → rules ghi đè template.

**Khi review plan Codex — checklist:**
- Plan có cover đủ spec không?
- Task có quá lớn không? (1 task = 1 commit reviewable)
- Có dependency nào bị bỏ sót không?

**Khi review output Codex — checklist adversarial:**
- Đọc `git diff` + commit message (bắt buộc)
- Grep `ASSUMPTION:` trong commit message ngay — nếu có → append vào `docs/superpowers/decisions.md` TRƯỚC KHI làm bất cứ gì khác (không để sang session sau)
- Kiểm tra: có `ASSUMPTION:` (giả định) nào cần xác nhận không?
  → Nếu có: quyết định + append vào `docs/superpowers/decisions.md`:
  ```
  ## [YYYY-MM-DD] — [feature]
  - ASSUMPTION: [Codex giả định gì]
  - Decision: [Claude quyết định gì]
  - Applies to: [task / file liên quan]
  ```
- Kiểm tra: có `ENV-REQUIRED:` không → nhắc user set trước khi deploy
- Kiểm tra: thay đổi đúng scope task, không thêm feature ngoài
- Kiểm tra: không có package mới ngoài plan (xem `package.json` diff)
- Kiểm tra: test pass, không regression
- Kiểm tra: logic nhất quán với spec — nếu lệch → cập nhật spec ngay

**Security Review — chạy khi commit có `SECURITY-SENSITIVE:` hoặc Claude tự detect:**

| Loại lỗ hổng | Kiểm tra gì trong diff |
|---|---|
| SQL Injection | Raw query có nối chuỗi user input? → phải dùng parameterized query |
| RLS hole | Bảng mới có RLS policy? Policy cover đủ roles (anon/authenticated/service_role)? |
| Auth bypass | Endpoint/route mới có auth middleware/guard? |
| IDOR | Query theo ID có filter `WHERE user_id = auth.uid()`? User A lấy được data user B? |
| XSS | User input render vào HTML không qua sanitize/escape? |
| Hardcoded secret | Có string literal trông như key/token/password trong code? |
| Input validation | User input từ `req.body`/`req.params`/`formData` có validate tại API boundary? |
| Privilege escalation | Endpoint admin có kiểm tra role trước khi xử lý? |

Nếu phát hiện lỗ hổng → KHÔNG approve → gọi Codex fix với mô tả lỗ hổng cụ thể.

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
