# Claude Code Global Config — Setup Guide

Đọc khi setup máy mới. KHÔNG load tự động.

---

## 1. Cài Tools

```bash
# Superpowers plugin (trong Claude Code)
/plugin install superpowers@claude-plugins-official

# Codex plugin (thay thế MCP Codex cũ)
/plugin install codex@openai-codex

# Caveman mode
/plugin install caveman@caveman

# RTK — token optimizer
curl -fsSL https://rtk.dev/install.sh | sh

# Markitdown — chuyển file sang .md
pip install markitdown

# Codex CLI
npm install -g @openai/codex
```

---

## 2. Claude Code — settings.json

Tạo hoặc merge vào `~/.claude/settings.json`:

```json
{
  "effortLevel": "medium",
  "theme": "dark",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "75",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "caveman@caveman": true,
    "codex@openai-codex": true
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

## 3. Codex — config.toml + 9Router

Tạo hoặc merge vào `~/.codex/config.toml`:

```toml
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
model_provider = "9router"
approval_policy = "on-request"

[features]
multi_agent = true

[model_providers.9router]
name = "9Router"
base_url = "https://r5833ge.abc-tunnel.us/v1"
wire_api = "responses"
env_key = "NINEROUTER_API_KEY"

[agents.subagent]
model = "gpt-5.5"
```

Set API key vào environment (`~/.zshrc` hoặc `~/.zprofile`):

```bash
export NINEROUTER_API_KEY=your_key_here
```

---

## 4. Obsidian Vault

`~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Sync qua iCloud — không cần setup thêm nếu đã đăng nhập iCloud.
