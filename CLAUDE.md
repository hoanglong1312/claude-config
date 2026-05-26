@RTK.md

# Quy Tắc Ngôn Ngữ
- Luôn trả lời bằng Tiếng Việt — bất kể user viết tiếng gì.
- Thuật ngữ tiếng Anh / chuyên ngành: giải thích nghĩa tiếng Việt ở lần xuất hiện **đầu tiên**. Format: `technical term` (nghĩa ngắn). Lặp lại → không giải thích lại.
- Không dịch: tên lệnh, file path, API name, package name, biến code, model name, tên sản phẩm.
- Ký hiệu cố định giữ nguyên, giải thích lần đầu — `ASSUMPTION:` (giả định), `QA-FAIL:` (kiểm thử thất bại).

# Markitdown
PDF/Word/PPT/Excel/HTML/ảnh có text → bắt buộc chuyển trước khi đọc:
```bash
markitdown [file] > [file].md
```

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

**⚠️ Code project (có `code-project.md`):**
- Claude main dùng flow trong `code-project.md` thay cho việc tự code/debug full.
- Codex vẫn phải follow TDD/debug/verification discipline khi thực thi.
- Claude main vẫn giữ review, architecture, MCP, security, và decision logging.

# Khi Tự Sửa File / Code

*Áp dụng khi Claude trực tiếp dùng Edit/Write — không phải khi delegate Codex.*

- **Hỏi trước khi làm**: Nếu mơ hồ hoặc có nhiều cách hiểu → trình bày các hướng, không tự chọn im lặng.
- **Minimum code**: Không thêm abstraction, feature, error handling ngoài yêu cầu.
- **Chỉ touch file liên quan**: Không "cải thiện" code lân cận, không refactor không được yêu cầu.
- **Đề xuất đơn giản hơn**: Nếu có cách đơn giản hơn → nói ra, không im lặng follow yêu cầu.
- **Self-test trước khi lưu**:
  - "Senior engineer có nói cái này overcomplicated không?" → CÓ → viết lại
  - "Mỗi dòng thay đổi có trace trực tiếp về yêu cầu của user không?" → KHÔNG → xóa
- **Dead code**: Phát hiện code chết không liên quan → báo user, không tự xóa.

# Obsidian Bridge
Vault: `~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Cuối session nhắc lưu nếu: nghiên cứu topic mới, fix bug khó, quyết định kiến trúc quan trọng.
→ `raw/daily/YYYY-MM-DD.md` hoặc `raw/resources/YYYY-MM-DD-[topic].md`

# Kết Thúc Session
Khi user nói "xong" / "tạm dừng" / "mai tiếp":
```
✓ Git: [đã commit / chưa]
? Obsidian: [có muốn lưu X không?]
→ Còn lại: [task 1], [task 2]
```

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

# HTML Visual Workflow

## Nguyên tắc
- `.md` = source of truth (spec, plan, status) — git-friendly, diffable
- `.html` = rendered view, KHÔNG edit trực tiếp — generate từ `.md` bằng `html-eff` CLI
- Claude viết `.md` content (hybrid Markdown + YAML component blocks) + chạy `html-eff` ngay sau (1 Bash command)
- Codex: code changes + update `**Status:**` field trong `plan-overview.md` + commit

## Tool Setup (nếu `html-eff` chưa có)

```bash
git clone https://github.com/luisoncpp/html-effectiveness-scripts.git ~/.local/share/html-effectiveness-scripts
cd ~/.local/share/html-effectiveness-scripts && cargo build --release
mkdir -p ~/.local/bin
ln -sf ~/.local/share/html-effectiveness-scripts/target/release/html-effectiveness ~/.local/bin/html-eff
# Thêm vào ~/.zshrc nếu chưa có: export PATH="$HOME/.local/bin:$PATH"
```

Reference gallery (20 demos): https://github.com/ThariqS/html-effectiveness

## Phân Chia File Spec

- `docs/superpowers/specs/YYYY-MM-DD-[feature]-design.md` — text spec, Codex đọc khi implement
- `docs/superpowers/specs/YYYY-MM-DD-[feature]-design.html` — generated visual, KHÔNG edit trực tiếp

Spec đơn giản: plain Markdown. Spec phức tạp: Claude viết hybrid (Markdown + YAML components) → compile.

## Spec Visual (trước writing-plans)

Sau brainstorming/spec xong, Claude hỏi: "Tạo HTML visual spec không?"
Nếu Có:
1. Claude viết (hoặc convert) `docs/superpowers/specs/[spec]-design.md` sang hybrid format
2. Claude chạy: `html-eff -i docs/superpowers/specs/[spec]-design.md -o docs/superpowers/specs/[spec]-design.html`
   - Nếu html-eff lỗi: báo error ngay, KHÔNG edit .html tay
3. Claude chạy: `open docs/superpowers/specs/[spec]-design.html`
4. User review HTML, confirm rồi mới chạy writing-plans

## Codex Review Gate (Optional)

Sau khi Claude viết spec hoặc plan xong — nếu phức tạp (3+ subsystem, core logic mới, user yêu cầu):
- Dispatch Codex review trước khi tiếp tục
- Claude fix issues từ Codex report → rồi mới generate HTML / execute plan

Prompt template Codex review spec:
```
Review [spec file path]. Check: logical gaps, contradictions, ambiguous requirements, missing error handling. Report: numbered issues, severity (minor/major/blocker), fix. Concise.
```

Prompt template Codex review plan:
```
Review [plan file path]. Check: missing steps, type/method name consistency, placeholder text, wrong commands, untested assumptions. Report: numbered issues, severity, fix. Concise.
```

## Plan Tracker (sau writing-plans)

Sau `writing-plans` hoàn thành:
1. Claude hỏi: "Thêm plan này vào HTML overview không?"
2. Nếu Có: Claude append section vào `docs/plan-overview.md` (hybrid format)
3. Claude chạy: `html-eff -i docs/plan-overview.md -o docs/plan-overview.html` (nếu lỗi: báo error, giữ .html cũ)
4. Claude chạy: `open docs/plan-overview.html`

### Format Task trong plan-overview.md

```markdown
### Task N: [Tên Task]

**Status:** pending
**Commit:** —

Steps:
- [ ] Step 1...
```

Codex update bằng string replace:
- Start: `**Status:** pending` → `**Status:** in_progress`
- Done: `**Status:** in_progress` → `**Status:** done` + `**Commit:** [hash]`
- Blocked: → `**Status:** blocked` + dòng `**Reason:** QA-FAIL: [lý do]`

Codex commit `.md` status cùng code changes, 1 commit per task. Khi dispatch Codex: Claude extract task list từ `.md` → truyền text vào prompt, không truyền HTML.

# Quản Lý Config

## Đặt Rule Ở Đâu

| Rule thuộc loại nào | Đặt ở đâu |
|---|---|
| Hành vi mọi session, mọi project | `~/.claude/CLAUDE.md` |
| Hành vi mọi session, theo loại project | `~/.claude/templates/[type].md` |
| Tool config cụ thể của project (MCP, lệnh test, quirk) | `[project]/.claude/rules/[name].md` |
| Chỉ chạy khi init / setup project | `~/.claude/SETUP.md` |
| Chỉ chạy khi skill được invoke | `~/.claude/skills/[skill]/skill.md` |
| Chỉ Codex đọc | `[project]/AGENTS.md` |

> **Boundary test trước khi thêm vào CLAUDE.md:** "Rule này có áp dụng khi đang làm dự án business / finance / personal không?" Nếu KHÔNG → đặt vào template tương ứng.

README chỉ chứa lệnh cài tools — không thêm rule vào đó.

## Khởi Tạo / Mở Rộng Project

Project mới hoặc mở rộng → `/init`

## Sync Rules
User nói "sync rules" hoặc "audit rules" → invoke `Skill("sync-rules")`.
