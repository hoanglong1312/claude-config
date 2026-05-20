# CLAUDE.md — Code Project

## Phân Công Vai Trò AI

| Phase | Công cụ | Việc làm |
|-------|---------|----------|
| Planning | Superpowers (Claude plugin) | brainstorming → spec → writing-plans |
| Execution | Codex MCP | Viết/sửa code, commit, chạy lệnh, quality gate |
| Orchestration + Review | Claude main | Quyết định kiến trúc, review output, điều phối |

**Lưu ý quan trọng:**
- Codex có Superpowers cài sẵn → tự follow TDD, brainstorming workflow của riêng nó
- `subagent-driven-development` của Claude main KHÔNG dùng → Codex thay thế hoàn toàn

## Quy Trình Execution

### Feature mới
1. Superpowers `brainstorming` → spec
2. Superpowers `writing-plans` → plan
3. Gọi Codex từng task → Codex tự đọc file, implement, chạy quality gate, commit
4. Claude main review qua `git diff` + commit message
5. Nếu có vấn đề: gọi Codex lại với feedback cụ thể
6. Pass → bàn giao user test

### Bug fix / small change
1. Claude main phân tích nguyên nhân (`git log`, `git diff`)
2. Gọi Codex fix trực tiếp
3. Codex chạy quality gate rút gọn: build + test

## Cách Gọi Codex

```
Tool: mcp__codex__codex
sandbox: "workspace-write"
approval-policy: "never"
```

**Heuristic chia task — trước khi gọi Codex:**

> 1 task = 1 commit có thể review độc lập

- Quá lớn (span nhiều file không liên quan) → chia nhỏ hơn
- Quá nhỏ (chỉ đổi 1 biến) → gộp với task liền kề
- Mục tiêu: mỗi `git diff` Claude đọc được trong 1 lần, không cần context từ task khác

**Template prompt chuẩn — dùng mỗi lần gọi:**

```
Goal: [1-2 câu — làm gì, tại sao]

Files cần đọc: [list]
Files cần sửa: [list]

Constraints:
- Không break: [X]
- Phải tương thích: [Y]

Nếu gặp ambiguity: ghi ASSUMPTION: ... vào commit message

Git commit: [format message]
```

Codex tự đọc file để lấy context — không paste code vào prompt.

## Xử Lý Ambiguity — Khi Codex Không Chắc

Codex không thể interrupt hỏi lại Claude giữa chừng. Thay vào đó:

- Codex ghi assumption vào commit message: `ASSUMPTION: dùng X thay vì Y vì...`
- Claude đọc commit message khi review → validate assumption
- Nếu assumption sai → gọi Codex lại với correction cụ thể

## Token Discipline — Claude Main Session

**KHÔNG làm:**
- Đọc toàn bộ file source để lấy context (việc của Codex)
- Paste nội dung file vào Codex prompt
- Dùng Edit/Write cho file .jsx/.js/.sql
- Dispatch Claude subagent làm middleman

**CHỈ làm:**
- Đọc `git log` / `git diff`
- Viết/sửa file .md (plan, spec, rules)
- Gọi Codex: goal + file paths + constraints
- Quyết định kiến trúc trước khi giao Codex

**Khi review output Codex — checklist adversarial:**
- Đọc `git diff` + commit message (bắt buộc)
- Kiểm tra: có `ASSUMPTION:` nào cần validate không?
- Kiểm tra: thay đổi có nằm đúng scope task không? (không thêm feature ngoài)
- Kiểm tra: test pass, không có regression
- Kiểm tra: logic thay đổi có nhất quán với spec không?
- Được đọc snippet nhỏ nếu diff tham chiếu code ngoài phạm vi thay đổi
- Không đọc toàn bộ file chỉ để "hiểu context chung"

## Quality Gate — Codex Tự Chạy

**Ownership: Codex chạy, không phải Claude.**

1. **Static audit**: Codex tự rà soát — import đúng, prop match, logic nhất quán
2. **E2E test**: Codex chạy lệnh test suite của project

**Nếu fail — tối đa 3 lần retry:**
1. Codex tự fix → chạy lại test (lần 1)
2. Vẫn fail → phân tích khác → fix lại (lần 2)
3. Vẫn fail → thử hướng khác (lần 3)
4. Sau 3 lần vẫn fail → dừng, ghi `QA-FAIL: [lý do + những gì đã thử]` → escalate Claude

Không retry vô hạn. Claude đọc `QA-FAIL` → viết analysis `.md` → gọi Codex lại.

Chỉ khi pass cả 2 → commit + báo Claude review.

## Fallback — Khi Codex Lỗi

Fallback **không phải** "Claude subagent đọc source". Thay vào đó:

1. Claude đọc `git diff` + error log Codex báo về
2. Claude viết analysis ngắn vào file `.md` tạm
3. Gọi Codex lại với file `.md` đó làm context bổ sung

## Đồng Bộ CLAUDE.md ↔ AGENTS.md

Mọi thay đổi ảnh hưởng đến cả Claude lẫn Codex phải cập nhật **cả 2 file cùng lúc**:

| Thay đổi | Cập nhật |
|----------|----------|
| Workflow, quy trình mới | `CLAUDE.md` + `AGENTS.md` |
| Convention mới (ASSUMPTION:, QA-FAIL:...) | `CLAUDE.md` + `AGENTS.md` |
| Thêm/bỏ tool, stack | `AGENTS.md` Project Context + `context/architecture.md` |
| Rule chỉ liên quan Claude main | `CLAUDE.md` hoặc `rules/*.md` |
| Rule chỉ liên quan Codex | `AGENTS.md` |

Không cập nhật 1 file mà bỏ quên file kia.

## Quy Tắc Code
- Viết test trước khi implement (TDD) — Codex tự follow qua Superpowers
- Commit sau mỗi task hoàn thành
- Không thêm feature ngoài scope đã plan

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
