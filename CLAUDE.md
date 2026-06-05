@RTK.md
@~/.claude/templates/shared-agent-rules.md

# Status Line Configuration

Compact status line command is configured in `~/.claude/settings.json`.

## Global Rule — Statusline Setup

Khi user yêu cầu setup / sửa / khôi phục statusline Claude Code:
- Dùng `update-config` skill trước vì đây là cấu hình `settings.json`.
- Target mặc định: `~/.claude/settings.json` nếu user nói global/statusline chung.
- Luôn Read file settings hiện tại trước khi Write/Edit; merge, không replace toàn bộ config.
- Giữ `statusLine.type = "command"` và command hiện tại nếu user chỉ muốn "như hiện tại".
- Nếu user yêu cầu comprehensive statusline: hiển thị, khi field có sẵn, model, session name, context %, output style, cwd/project, repo/branch/worktree, token usage current/total, rate limits, effort, extended thinking, vim mode, agent, PR state.
- Command phải parse stdin JSON bằng `jq`, build array parts, bỏ field rỗng, join bằng separator rõ ràng.
- Sau khi sửa: validate JSON bằng `jq` và báo user cần restart Claude Code hoặc reload `/hooks` nếu UI chưa nhận config.

---

# Superpowers — BẮT BUỘC

**Trước mỗi response: classify intent của user.**
Không đợi exact trigger word — dùng *ý nghĩa*, không dùng *từ khóa*.

**Nếu user muốn** tạo / thay đổi / cải thiện / tự động hóa / setup / test / fix / điều tra / so sánh / quyết định implementation → **check Superpowers trước**.
Nếu không chắc → assume skill áp dụng.
Announce skill trong 1 câu trước khi tiếp tục.

**Chỉ bỏ qua skill check khi:** task trivial rõ ràng (typo fix, one-liner, explain concept) — dùng judgment trực tiếp. Task có thể tạo code/file/plan → PHẢI check skill.
Nếu output có thể là code, file change, plan, hoặc config → PHẢI check skill trước.

| Intent | Skill |
|---|---|
| Muốn tạo / design feature mới | `brainstorming` |
| Có spec, cần plan implement | `writing-plans` |
| Bắt đầu code | `test-driven-development` *(code project: override bởi code-project.md → Codex thực thi TDD, Claude không tự code)* |
| 2+ task độc lập | `subagent-driven-development` *(code project: override bởi code-project.md → dùng Codex)* |
| Bug / lỗi / không hoạt động | `systematic-debugging` |
| Xong implement, muốn kiểm tra | `requesting-code-review` + `verification-before-completion` |
| Nhận review feedback | `receiving-code-review` |
| Kết thúc branch | `finishing-a-development-branch` |
| Feature cần isolate / song song | `using-git-worktrees` |
| Spec xong, có 3+ task hoặc động core logic | hỏi: "Feature này cần worktree riêng không?" → `using-git-worktrees` |
| Spec/plan phức tạp vừa xong (3+ subsystem, core logic mới) | Dispatch Codex review (xem "Codex Review Gate" trong HTML Visual Workflow) |
| Design / build UI component, landing page, redesign, portfolio | `taste-skill` — nếu brief có brand name cụ thể: fetch `~/.claude/references/repos.md` → lấy URL open-design/awesome-design-md → fetch brand tokens trước khi code |
| Hỏi về tool/repo/service/domain → tìm trong library | Đọc `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/raw/resources/repos/index.md` (Obsidian repo wiki — source of truth) |

**⚠️ Code project (có `code-project.md`):**
- Claude main dùng flow trong `code-project.md` thay cho việc tự code/debug full.
- Codex vẫn phải follow TDD/debug/verification discipline khi thực thi.
- Claude main vẫn giữ review, architecture, MCP, security, và decision logging.

# Quy Tắc Ngôn Ngữ
- Luôn trả lời bằng Tiếng Việt — bất kể user viết tiếng gì.
- Thuật ngữ tiếng Anh / chuyên ngành: giải thích nghĩa tiếng Việt ở lần xuất hiện **đầu tiên**. Format: `technical term` (nghĩa ngắn). Lặp lại → không giải thích lại.
- Không dịch: tên lệnh, file path, API name, package name, biến code, model name, tên sản phẩm.
- Ký hiệu cố định giữ nguyên, giải thích lần đầu — `ASSUMPTION:` (giả định), `QA-FAIL:` (kiểm thử thất bại).

# Execution Discipline

Áp dụng canonical rules trong `@~/.claude/templates/shared-agent-rules.md`.

Global additions:
- Trước khi implement: đổi task thành success criteria có thể verify.
- Sau implement: chạy verify steps; nếu fail → debug → fix → verify lại.
- Khi Claude trực tiếp Edit/Write: chỉ touch file liên quan, minimum code, research existing pattern trước, không refactor ngoài scope.
- Dead code không liên quan: báo user, không tự xóa.

# Khi Đề Xuất Nhiều Phương Án

Khi Claude đưa ra 2+ lựa chọn:
1. Đánh dấu phương án recommend — `✅ Recommended`
2. Mỗi phương án: ≥1 pros + ≥1 cons
3. 1 câu lý do recommend

| Phương án | Pros | Cons |
|---|---|---|
| **A** ✅ Recommended | ... | ... |
| B | ... | ... |
> Recommend A vì [lý do].

# Markitdown
PDF/Word/PPT/Excel/HTML → bắt buộc chuyển trước khi đọc:
```bash
markitdown [file] > [file].md
```

**KHÔNG dùng markitdown cho:** ảnh UI/screenshot → gửi thẳng cho Claude (mất visual context nếu convert).

**Dùng markitdown cho ảnh khi:** ảnh chứa text đặc (hóa đơn scan, bảng số, screenshot terminal) → dùng OCR plugin:
```bash
markitdown image.png --llm-client openai --llm-model gpt-4o
# hoặc plugin OCR riêng: pip install markitdown-ocr
```

# Model Selection — Khi Build AI Features

Dùng khi viết code gọi Claude API hoặc chọn model cho agent:

| Model | Dùng khi | Lý do |
|---|---|---|
| `claude-haiku-4-5` | Lightweight agent, gọi thường xuyên, task đơn giản | 3x rẻ hơn Sonnet |
| `claude-sonnet-4-6` | Main coding work, phần lớn tasks | Best coding model |
| `claude-opus-4-8` | Architectural decisions, reasoning phức tạp | Deepest reasoning |

# Repo Wiki — Cập Nhật Tự Động

Khi có bất kỳ hành động nào sau đây trong session:
- Install package/tool mới (`npm install`, `pip install`, `brew install`, thêm MCP server, cài plugin)
- Clone repo mới về máy
- Quyết định dùng service/API mới

→ Hỏi user: **"Thêm [tên repo] vào Obsidian repo wiki không?"**

Nếu đồng ý → append vào đúng section trong:
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/raw/resources/repos/index.md`

Format dòng mới:
```
| [tên] | [URL nếu có] | installed | [tên project / global] | [ghi chú ngắn — lý do chọn, quirk quan trọng] |
```

Không tự thêm mà không hỏi. Không hỏi cho deps hiển nhiên/transitive (ví dụ: react-dom khi đã có react).

# Obsidian Bridge
Vault: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/`

Cuối session nhắc lưu nếu: nghiên cứu topic mới, fix bug khó, quyết định kiến trúc quan trọng.
- Session code/tech → `raw/projects/[tên-project]/YYYY-MM-DD-session.md`
- Research/article → `raw/resources/[topic]/YYYY-MM-DD-[slug].md`
- Quyết định cá nhân → `raw/daily/YYYY-MM-DD.md`

# Kết Thúc Session
Khi user nói "xong" / "tạm dừng" / "mai tiếp":

1. **Tự động viết session note vào Obsidian** (không hỏi):
   - Detect project từ working directory
   - Nếu là code/tech project → tạo `raw/projects/[tên-project]/YYYY-MM-DD-session.md`
   - Nếu là vault my-brain → skip (đã ở trong Obsidian)
   - Nếu không rõ project → tạo `raw/projects/misc/YYYY-MM-DD-session.md`
   - Nội dung: đã làm gì, quyết định nào, còn lại gì

2. **Báo tóm tắt:**
```
✓ Git: [đã commit / chưa]
✓ Obsidian: lưu → raw/projects/[project]/[date]-session.md
→ Còn lại: [task 1], [task 2]
```

# Quản Lý Config

## Đặt Rule Ở Đâu

| Rule thuộc loại nào | Đặt ở đâu |
|---|---|
| Hành vi mọi session, mọi project | `~/.claude/CLAUDE.md` |
| Hành vi mọi session, theo loại project | `~/.claude/templates/[type].md` |
| Tool config cụ thể của project (MCP, lệnh test, quirk) | `[project]/rules/[name].md` |
| Chỉ chạy khi init / setup / sync project | `~/.claude/skills/init/skill.md` |
| Chỉ chạy khi skill được invoke | `~/.claude/skills/[skill]/skill.md` |
| Chỉ Codex đọc | `[project]/AGENTS.md` |

> **Boundary test trước khi thêm vào CLAUDE.md:** "Rule này có áp dụng khi đang làm dự án business / finance / personal không?" Nếu KHÔNG → đặt vào template tương ứng.

README chỉ chứa lệnh cài tools — không thêm rule vào đó.

## Khởi Tạo / Mở Rộng Project

Project mới hoặc mở rộng → `/init`

## Init / Sync Rules
User nói "init", "sync rules", hoặc "audit rules" → invoke `Skill("init")`. Với sync/audit, chạy phần Audit / Sync Rules.

---

# Settings.json Configuration

File: `~/.claude/settings.json`

Actual statusLine hiện tại là compact command, hiển thị:
- model compact
- permission mode
- 5h / 7d rate limit nếu có
- context remaining % nếu có

Rule khi sửa statusline:
- Dùng `update-config` skill trước.
- Luôn Read `~/.claude/settings.json` trước khi Edit/Write.
- Merge config, không replace toàn bộ file.
- Giữ `statusLine.type = "command"`.
- Validate JSON bằng `jq`.
- Báo user restart Claude Code hoặc reload `/hooks` nếu UI chưa nhận config.
