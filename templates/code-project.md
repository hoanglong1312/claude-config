# CLAUDE.md — Code Project

## Phân Công Vai Trò AI

| Phase | Công cụ | Việc làm |
|-------|---------|----------|
| Planning | Superpowers (Claude plugin) | brainstorming → spec → writing-plans |
| Execution | Codex MCP | Viết/sửa code, commit, chạy lệnh |
| Orchestration + QA | Claude main | Quyết định kiến trúc, review output, quality gate |

**Lưu ý quan trọng:**
- Codex có Superpowers cài sẵn → tự follow TDD, brainstorming workflow của riêng nó
- `subagent-driven-development` của Claude main KHÔNG dùng → Codex thay thế hoàn toàn
- Fallback nếu Codex lỗi: dùng Claude subagent-driven-development, ghi chú lý do

## Quy Trình Execution

### Feature mới
1. Superpowers `brainstorming` → spec
2. Superpowers `writing-plans` → plan
3. Gọi Codex từng task → Codex tự đọc file, implement, commit
4. Claude main review (adversarial)
5. Nếu có vấn đề: gọi Codex lại với feedback cụ thể
6. Quality Gate: static audit + E2E test
7. Chỉ khi pass → bàn giao user test

### Bug fix / small change
1. Claude main phân tích nguyên nhân (git log, git diff)
2. Gọi Codex fix trực tiếp
3. Quality Gate rút gọn: build + test

## Cách Gọi Codex

```
Tool: mcp__codex__codex
sandbox: "workspace-write"
approval-policy: "never"
```

Prompt phải có:
- **Goal** rõ ràng (làm gì, tại sao)
- **Danh sách file** cần đọc / sửa
- **Constraints** (không break X, phải tương thích Y)
- **Lệnh git commit** cuối

Codex tự đọc file để lấy context — không cần paste code vào prompt.

## Token Discipline — Claude Main Session

**KHÔNG làm:**
- Đọc toàn bộ file source để lấy context (việc của Codex)
- Paste nội dung file vào Codex prompt
- Dùng Edit/Write cho file .jsx/.js/.sql
- Dispatch Claude subagent làm middleman

**CHỈ làm:**
- Đọc git log / git diff
- Viết/sửa file .md (plan, spec, rules)
- Gọi Codex: goal + file paths + constraints
- Quyết định kiến trúc trước khi giao Codex

**Khi review output Codex:**
- Ưu tiên đọc `git diff` — đủ cho hầu hết trường hợp
- Được đọc snippet nhỏ nếu diff tham chiếu code nằm ngoài phạm vi thay đổi
- Không đọc toàn bộ file chỉ để "hiểu context chung"

## Quality Gate — Bắt Buộc Trước Khi Bàn Giao User

1. **Static audit**: Codex tự rà soát output — import đúng, prop match, logic nhất quán
2. **E2E test**: chạy test suite của project

Chỉ khi pass cả 2 → báo user test.

## Quy Tắc Code
- Viết test trước khi implement (TDD) — Codex tự follow qua Superpowers
- Commit sau mỗi task hoàn thành
- Không thêm feature ngoài scope đã plan

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
