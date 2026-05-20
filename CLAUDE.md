@RTK.md

# Quy Tắc Ngôn Ngữ
- Trả lời bằng tiếng Việt
- Thuật ngữ kỹ thuật: Tiếng Việt (English term) — ví dụ: vòng lặp (loop)
- Ký hiệu cố định (commit convention, code): giữ nguyên ký hiệu, thêm nghĩa tiếng Việt trong () — ví dụ: `ASSUMPTION:` (giả định), `QA-FAIL:` (kiểm thử thất bại)

# Markitdown — Chuyển File Trước Khi Đọc

Trước khi đọc bất kỳ file nào thuộc định dạng dưới đây, **bắt buộc chuyển sang .md trước**:

| Định dạng | Extension |
|-----------|-----------|
| PDF | `.pdf` |
| Word | `.docx`, `.doc` |
| PowerPoint | `.pptx`, `.ppt` |
| Excel | `.xlsx`, `.xls` |
| HTML | `.html`, `.htm` |
| Hình ảnh có text | `.png`, `.jpg`, `.jpeg` |

```bash
markitdown [file] > [file].md
```

# Superpowers — BẮT BUỘC, KHÔNG CÓ NGOẠI LỆ

Trước MỌI action, kiểm tra skill phù hợp và invoke ngay. Không cần user nhắc.

## Khi Nào Trigger Skill Nào

| Anh nói gì | Skill tự động trigger |
|---|---|
| "build X", "thêm tính năng", "tạo mới" | `brainstorming` trước, KHÔNG code ngay |
| Sau brainstorm xong, có spec | `writing-plans` |
| Có plan, bắt đầu code | `test-driven-development` ⚠️ xem ngoại lệ bên dưới |
| Plan có 2+ task độc lập | `subagent-driven-development` ⚠️ xem ngoại lệ bên dưới |
| "fix bug", "lỗi", "không chạy" | `systematic-debugging` |
| Xong implementation | `requesting-code-review` + `verification-before-completion` |
| Nhận feedback về code | `receiving-code-review` |
| Merge / kết thúc branch | `finishing-a-development-branch` |
| Feature cần isolate | `using-git-worktrees` |

**⚠️ Ngoại lệ khi đang trong code project (có `code-project.md`):**
- `test-driven-development` → **không trigger** — Codex tự follow TDD qua Superpowers của nó
- `subagent-driven-development` → **không trigger** — Codex thay thế hoàn toàn
- `requesting-code-review` → **không trigger** — Claude review qua adversarial checklist trong `code-project.md`

## Quy Tắc Cứng
- Nếu task là "build/tạo/thêm" mà KHÔNG qua `brainstorming` → SAI, phải làm lại
- Nếu sắp claim "xong rồi" mà chưa chạy `verification-before-completion` → SAI
- Nếu có 2+ task độc lập mà làm tuần tự (ngoài code project) → SAI, dùng parallel agents

# Obsidian Bridge — Lưu Kiến Thức Tự Động

Vault path: `~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Sau mỗi session, Claude CHỦ ĐỘNG nhắc nếu có 1 trong các trường hợp sau:

| Tình huống | Gợi ý lưu vào đâu |
|---|---|
| Nghiên cứu kỹ 1 topic mới | `raw/resources/YYYY-MM-DD-[topic].md` |
| Fix được bug khó / học được pattern mới | `raw/daily/YYYY-MM-DD.md` |
| Quyết định kiến trúc quan trọng | `raw/daily/YYYY-MM-DD.md` |
| Session nghiên cứu dài (research project) | Tạo wiki note luôn |

Cách nhắc: "Bạn vừa [học/fix/quyết định] X — có muốn lưu vào Obsidian không? (raw/daily/ hoặc raw/resources/)"

Không nhắc nếu: session ngắn, chỉ hỏi đáp thông thường, task lặp đi lặp lại.

# Kết Thúc Session — Checklist Tự Động

Trước khi session kết thúc (user nói "xong", "tạm dừng", "mai tiếp"), Claude tự nhắc:

1. **Git** — có commit chưa? Nếu chưa → nhắc commit
2. **Obsidian** — có insight đáng lưu không? → gợi ý (theo rule trên)
3. **Task dở** — liệt kê 1-3 việc còn lại để session sau tiếp tục ngay

```
✓ Git: [đã commit / chưa commit gì]
? Obsidian: [có muốn lưu X không?]
→ Còn lại: [task 1], [task 2]
```

# Thêm Rule Mới — Routing

Trước khi thêm rule, xác định layer phù hợp:

| Rule áp dụng cho | Đặt ở đâu |
|---|---|
| Mọi project, mọi loại (toàn cục / universal) | `~/.claude/CLAUDE.md` |
| Loại project cụ thể (theo loại / type-specific): code/finance/research/personal | `~/.claude/templates/[type].md` |
| Một project duy nhất (theo dự án / project-specific) | `[project]/rules/[name].md` |

Không thêm rule vào README — README chỉ chứa lệnh cài tools cho máy mới.

# Khởi Tạo Project Mới

Nếu vào project KHÔNG có CLAUDE.md → đọc `~/.claude/SETUP.md` và làm theo.

# Audit Rules

Khi user nói "audit rules" → invoke `Skill("audit-rules")` (dù đã có CLAUDE.md hay chưa).

# Add-On Rules — Load Khi Cần

Khi đang làm việc trong code project, nếu phát hiện project dùng tool chưa có rules → hỏi user:
> "Project đang dùng [Supabase / Playwright / ...] — có muốn tạo rules sẵn có không? Em tạo `rules/[tool].md` và thêm vào CLAUDE.md."

Nếu đồng ý — tạo file blank với structure chuẩn:

**`rules/supabase.md`:**
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
- [thêm rule project-specific]
```

**`rules/testing.md`:**
```markdown
# Testing Rules

## Lệnh chạy test
[điền: npx playwright test / npx vitest run / npx jest]

## Quy Tắc
- [thêm rule project-specific]
```

Sau khi tạo: thêm `@rules/[tool].md` vào CLAUDE.md của project.

| Tool phát hiện | File tạo |
|---|---|
| Supabase (import, MCP call) | `rules/supabase.md` |
| Playwright (import, config) | `rules/testing.md` |
| Vitest / Jest | `rules/testing.md` |
