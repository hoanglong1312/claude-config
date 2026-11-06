# Toolkit — dùng gì cho việc gì (Claude + Codex)

> Bản đồ duy nhất. KHÔNG nạp tự động — `/init` đọc khi dựng/sync project, Claude đọc khi cần chọn tool.
> Cập nhật ở đây khi cài/gỡ plugin, skill, agent. Cập nhật lần cuối: 2026-11-02.

## Nguyên tắc

- Global (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`) chỉ giữ thứ MỌI project cần. Luật code, plugin code → chỉ bật trong code project. Business/content không nạp gì của code.
- Skill riêng 1 dự án → để trong dự án (Claude: `.claude/skills/`, Codex: `.agents/skills/`), không để global.
- Agent mới chỉ tạo khi khác thật về quyền (đọc/ghi), model, hoặc cần cách ly ngữ cảnh. Việc "làm X theo các bước Y" → slash command/skill có checklist.

## Theo loại project

| Loại | Claude plugin bật (`.claude/settings.json`) | Claude skill / lệnh | Codex |
|---|---|---|---|
| **Code web** | superpowers, caveman, ponytail (+ supabase nếu dùng) | `/wireframe` → Stitch MCP (mockup) → `/codex-exec` → `/frontend-verify`; `/review`, `/verify`, `/ship`, `/db-migrate`, `/plan-track`; `frontend-design`, `playwright-testing` | agent `implementer` (ghi), `reviewer` (đọc + soát bảo mật), `code_mapper` (dò code rẻ); `AGENTS.md` project chứa 15 rule |
| **Code không UI** (CLI, pipeline) | superpowers, caveman, ponytail | `/codex-exec`, `/review`, `/verify`, `/ship` | như trên |
| **Business / vận hành** | không plugin code | template `business.md`; `chom` (soi tool/hype), `teach` | skill riêng dự án (vd Long Cafe: `checkpoint`, `cogs-calculator`) |
| **Content** (reel, caption, script) | không plugin code | — | skill Codex global: `dumbify`, `viral-hooks`, `storytelling`, `anti-ai-writing` |
| **Mọi loại — ảnh bitmap** | — | skill `codex-image` — BẮT BUỘC, không đường khác (Claude soạn prompt + kiểm) | `codex exec` CLI ≥0.166, `gpt-image-2.5` qua Cockpit Tools (`localhost:54726`) |

## Phân vai model (Claude)

Opus main giữ phán đoán · `model: haiku` dò/verify/sửa cơ học, trả bằng chứng · Codex viết code · `model: sonnet` + worktree khi Codex lỗi hạ tầng. Bảng đầy đủ: `CLAUDE.md` mục "Phân Vai Model", Codex lỗi A/B/C/D: `code-project.md`. Không set `CLAUDE_CODE_SUBAGENT_MODEL` (ép mọi subagent 1 model).

## Chỉ bật khi cần

| Thứ | Khi nào |
|---|---|
| `ui-ux-pro-max` | Dựng design system MỚI (1 lần) → chốt `rules/design-system.md` → tắt |
| Stitch MCP | Code web có UI: nối theo `code-project.md` mục "UI feature mới" (`.mcp.json` + `settings.local.json`) |
| Codex `superpowers` | Chỉ khi owner mở Codex làm độc lập (Claude hết quota). Khi Claude giao task → không dùng |

## Không dùng

| Thứ | Lý do |
|---|---|
| Codex MCP trong Claude (`mcp__codex__*`) | Đã gỡ 2026-11-02 — gọi Codex qua `/codex-exec` (codex-rescue) |
| codex-rescue để tạo ảnh | Không có `image_gen` → dùng `codex-image` |
| Codex skill `/save` trong repo có luật "không push" | Skill tự push lên origin |

## Lưu trữ (lấy lại được)

- Codex agents cũ (tester, security_reviewer, ui_designer, requirements_analyst) + AGENTS.md global bản đủ: `~/.codex/agents-archive/2026-11-02/`
- Codex skill `ui-ux-pro-max`: `~/.codex/skills-archive/2026-11-02/`
- Template Claude trước khi sửa: `~/.claude/backups/2026-11-02/`
