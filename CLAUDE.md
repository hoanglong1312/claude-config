@~/.claude/templates/shared-agent-rules.md

# Superpowers — BẮT BUỘC

Trước mỗi response: classify intent. 1% chance skill áp dụng → invoke ngay. Routing → xem `using-superpowers` skill.

# Auto-Invoke Rules — Không Cần User Nhắc

Tự động invoke skill — không đợi user gọi thủ công:

| Trigger | Skill bắt buộc |
|---|---|
| User báo bug / lỗi / không work / crash | `systematic-debugging` TRƯỚC KHI đề xuất bất kỳ fix nào |
| Fix xong bất kỳ thứ gì | `verify` TRƯỚC KHI báo done |
| User nói "merge" / "push" / "PR" / "xong rồi" | `code-review` |
| Implement feature có UI / form / navigation | `playwright-testing` sau khi xong |
| User hỏi "nên làm gì" / "bắt đầu từ đâu" / feature mới | `brainstorming` |
| User muốn hiểu sâu / "tại sao" / "explain" | `teach` |
| Auth / payment / RLS / Supabase security | `security-review` |

**KHÔNG invoke khi:** fix 1 dòng rõ ràng, code chưa compile, task đã hoàn toàn rõ ràng.

Hỏi về tool/repo → tìm library: đọc `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/raw/resources/repos/index.md`

**⚠️ Code project (có `code-project.md`):** Claude dùng flow trong `code-project.md` — Codex thực thi TDD/debug. Claude giữ review, architecture, MCP, security.

# Quy Tắc Ngôn Ngữ

- Luôn trả lời Tiếng Việt.
- Thuật ngữ tiếng Anh: giải thích lần đầu. Format: `technical term` (nghĩa ngắn). Lặp lại → không giải thích lại.
- Không dịch: tên lệnh, file path, API name, package name, model name, tên sản phẩm.

# Giải Thích Code — Behavior Flow

Khi giải thích bất kỳ luồng code nào (fix bug, explain feature, trace data, review change), luôn kèm mô tả bằng ngôn ngữ đơn giản — không dùng tên hàm, chỉ dùng từ mô tả hành vi người dùng thấy:

```
→ Khi [action người dùng làm]
   1. [Cái gì] xảy ra
   2. [Data/state] đi đâu / được lưu ở đâu
   3. [Kết quả] người dùng thấy / nhận được
```

Nếu có trước/sau (bug fix, refactor): ❌ hành vi sai trước đó, ✅ hành vi đúng sau fix. Luôn kèm theo, không đợi user hỏi.

# Model Selection — Khi Build AI Features

| Model | Dùng khi |
|---|---|
| `claude-haiku-4-5` | Lightweight agent, gọi thường xuyên, task đơn giản |
| `claude-sonnet-4-6` | Main coding work, phần lớn tasks |
| `claude-opus-4-8` | Architectural decisions, reasoning phức tạp |

# RTK — Token Proxy

Mọi Bash command tự động đi qua `rtk` hook (settings.json) — không cần làm gì thêm.

Meta commands (dùng trực tiếp):
- `rtk gain` — xem token savings analytics
- `rtk gain --history` — lịch sử command + savings
- `rtk discover` — phân tích Claude history tìm missed opportunities
- `rtk proxy <cmd>` — bypass RTK (debug)

`rtk find` không support `-exec`, `-o`, `\(…\)` → dùng `/usr/bin/find` thay thế.

# Markitdown

PDF/Word/PPT/Excel/HTML → `markitdown [file] > [file].md` trước khi đọc. Không dùng cho ảnh UI/screenshot.

# Repo Wiki

Khi install package/tool mới, clone repo, dùng service/API mới → hỏi: **"Thêm [tên] vào Obsidian repo wiki không?"**
File: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/raw/resources/repos/index.md`
Format: `| [tên] | [URL] | installed | [project/global] | [ghi chú ngắn] |`

# Kết Thúc Session

Khi user nói "xong" / "tạm dừng" / "mai tiếp":

1. Tự viết session note vào Obsidian (không hỏi):
   - Vault: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/`
   - Code/tech → `raw/projects/[tên-project]/YYYY-MM-DD-session.md`
   - Vault my-brain → skip. Không rõ → `raw/projects/misc/YYYY-MM-DD-session.md`
   - Nội dung: đã làm gì, quyết định nào, còn lại gì

2. Báo tóm tắt:
```
✓ Git: [đã commit / chưa]
✓ Obsidian: lưu → raw/projects/[project]/[date]-session.md
→ Còn lại: [task 1], [task 2]
```

@RTK.md
