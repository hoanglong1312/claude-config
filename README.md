# Claude Code Global Config — Setup Guide

Đọc file này khi setup máy mới. KHÔNG load tự động — chỉ đọc thủ công khi cần.

---

## 1. Superpowers Plugin

```bash
/plugin install superpowers@claude-plugins-official
```

Cài trên Codex CLI: mở Codex → `/plugins` → search "superpowers" → Install.

---

## 2. settings.json — Các giá trị cần set

Tạo hoặc merge vào `~/.claude/settings.json`:

```json
{
  "model": "sonnet",
  "effortLevel": "medium",
  "theme": "dark",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "rtk hook claude" }]
      }
    ]
  }
}
```

**Giải thích từng env:**
- `MAX_THINKING_TOKENS=10000` — giới hạn extended thinking, tránh tốn token
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` — compact khi context 70% full (không để tràn)
- `CLAUDE_CODE_SUBAGENT_MODEL=haiku` — subagent dùng model rẻ hơn 10x

---

## 3. RTK (Token Optimizer)

```bash
# Cài RTK
curl -fsSL https://rtk.dev/install.sh | sh

# Verify
rtk --version
rtk gain
```

Hook đã config sẵn trong settings.json — RTK tự chạy với mọi Bash command.

---

## 4. MCP Codex

```bash
claude mcp add codex
```

Workflow: Claude (planning) → `mcp__codex__codex` (implementation) → Claude (review)

---

## 5. Templates

Các template project nằm tại `~/.claude/templates/`:
- `code-project.md` — project có Git, source code
- `research.md` — nghiên cứu, phân tích
- `finance.md` — tài chính, trading
- `personal.md` — dự án cá nhân
- `AGENTS.md` — universal cross-tool template

---

## 6. Obsidian Vault

Vault path: `~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Sync qua iCloud — không cần setup thêm trên máy mới nếu đã đăng nhập iCloud.
