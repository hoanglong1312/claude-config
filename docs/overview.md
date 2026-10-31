# Claude — Global Overview

Cập nhật: 2026-10-31 (tái cấu trúc: global trung tính, luật code chỉ nạp trong code project).

## Nguyên tắc tầng

| Tầng | Ở đâu | Nạp khi |
|---|---|---|
| Global trung tính | `~/.claude/CLAUDE.md` | Mọi session (content, business, ghi chú, code) |
| Luật code (15 Rule + Superpowers mandate) | `templates/code-project.md` → `@include shared-agent-rules.md` | Project có `@~/.claude/templates/code-project.md` trong CLAUDE.md |
| Plugin code | `[project]/.claude/settings.json` → `enabledPlugins` | Chỉ code project |
| Luật riêng project | `[project]/rules/*.md` | Project đó |
| Codex | `[project]/AGENTS.md` (sinh bằng `scripts/sync-agent-rules.sh` chạy trong project) · `~/.codex/AGENTS.md` | Codex session |

## Plugin

| Plugin | Global | Bật ở |
|---|---|---|
| codex | ✅ | mọi nơi (chỉ chạy khi gọi) |
| superpowers | ❌ | code project |
| caveman | ❌ | code project (nơi khác gõ `/caveman` khi muốn) |
| ponytail | ❌ | code project |
| ui-ux-pro-max | ❌ | project web/UI |
| supabase | ❌ | project dùng Supabase |
| claude-mem | gỡ | — (thay bằng Obsidian session note + memory có sẵn) |

## Hook (`settings.json`)

| Event | Hook | Tác dụng |
|---|---|---|
| PreToolUse · Bash | `rtk hook claude` | Nén output, tiết kiệm token |
| PreToolUse · Bash | `hooks/security-gate.py` | Chặn commit đụng auth/api/migration/rls khi chưa `/review` (chỉ code project có stamp) |
| Stop | `afplay Ping.aiff` | Âm báo xong |
| statusLine | `hooks/statusline.sh` | Model + rate limit |

## Skill tự viết

| Skill | Khi dùng |
|---|---|
| `init` | Init / mở rộng project (code project → bật plugin code) |
| `chom` | Fact-check tool/repo đang được quảng cáo |
| `teach` | Muốn hiểu sâu |
| `wireframe` | Wireframe + spec màn hình trước khi code UI |
| `frontend-design` | Build UI bám design token |
| `playwright-testing` | E2E flow dễ regression |

## Template project

`code-project.md` · `business.md` · `research.md` · `finance.md` · `personal.md`. Command stamp vào code project: `/codex-exec` `/plan-track` `/review` `/ship` `/verify` `/frontend-verify` `/db-migrate`. Module: frontend-web, db-supabase, web-security, browser-automation, ui-design-handoff, codex-html-workflow.

## Luồng code project

brainstorming → spec → blindspot scout → plan → Codex cross-review plan → Codex code/test/commit (Claude được báo khi xong) → Claude review diff + verify → `/ship`.
