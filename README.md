# Claude Code Global Config — Setup Guide

Đọc khi setup máy mới. KHÔNG load tự động.

---

## Tools cần cài

```bash
# Superpowers plugin (trong Claude Code)
/plugin install superpowers@claude-plugins-official

# RTK — token optimizer
curl -fsSL https://rtk.dev/install.sh | sh

# Markitdown — chuyển file sang .md
pip install markitdown

# MCP Codex
claude mcp add codex
```

---

## settings.json

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

---

## Obsidian Vault

`~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Sync qua iCloud — không cần setup thêm nếu đã đăng nhập iCloud.
