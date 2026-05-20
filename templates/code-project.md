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

**Template prompt chuẩn — dùng mỗi lần gọi:**

```
Goal: [1-2 câu — làm gì, tại sao]

Files cần đọc: [list]
Files cần sửa: [list]

Constraints:
- Không break: [X]
- Phải tương thích: [Y]

Nếu gặp ambiguity: ghi assumption vào commit message dạng ASSUMPTION: ...

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

**Khi review output Codex:**
- Ưu tiên đọc `git diff` + commit message — đủ cho hầu hết trường hợp
- Được đọc snippet nhỏ nếu diff tham chiếu code nằm ngoài phạm vi thay đổi
- Không đọc toàn bộ file chỉ để "hiểu context chung"

## Quality Gate — Codex Tự Chạy

**Ownership: Codex chạy, không phải Claude.**

1. **Static audit**: Codex tự rà soát — import đúng, prop match, logic nhất quán
2. **E2E test**: Codex chạy lệnh test suite của project

**Nếu fail:**
- Codex tự fix trong cùng session → chạy lại test
- Nếu không fix được → báo lỗi cụ thể vào commit message: `QA-FAIL: [lý do]`
- Claude đọc → phân tích → gọi Codex lại với hướng xử lý rõ

Chỉ khi pass cả 2 → commit + báo Claude review.

## Fallback — Khi Codex Lỗi

Fallback **không phải** "Claude subagent đọc source". Thay vào đó:

1. Claude đọc `git diff` + error log Codex báo về
2. Claude viết analysis ngắn vào file `.md` tạm
3. Gọi Codex lại với file `.md` đó làm context bổ sung

## Quy Tắc Code
- Viết test trước khi implement (TDD) — Codex tự follow qua Superpowers
- Commit sau mỗi task hoàn thành
- Không thêm feature ngoài scope đã plan

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
