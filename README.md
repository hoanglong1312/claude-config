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

## 3. Codex

Codex setup phụ thuộc tài khoản/provider cá nhân. Không lưu API endpoint, API key, hoặc provider riêng trong global README.

Tối thiểu cần:

```bash
npm install -g @openai/codex
```

Cấu hình chi tiết đặt ở `~/.codex/config.toml` hoặc tài liệu private riêng.

---

## 4. Obsidian Vault

`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain/`

Sync qua iCloud — không cần setup thêm nếu đã đăng nhập iCloud.

---

## 5. Rule Architecture

Shared Claude + Codex rules live in one source file:

```text
~/.claude/templates/shared-agent-rules.md
```

Load paths:

```text
~/.claude/CLAUDE.md             # Claude global includes shared rules via @include
~/.claude/templates/AGENTS.md   # template body only; project AGENTS.md materializes shared rules
~/.claude/templates/code-project.md  # code workflow only, no shared include to avoid duplicate Claude context
```

Claude can consume `@include`. Codex should get a rendered/materialized `AGENTS.md` that contains shared rules as real text, unless Codex include expansion has been verified.

Project-specific tool rules go in project root `rules/*.md`, not `.claude/rules/`.

Generated/cache/local files ignored in this repo include `image-cache/`, `paste-cache/`, `session-env/`, `stats-cache.json`, `.last-update-result.json`, `.update.lock`, `settings.local.json`.

---

## 6. Maintenance Checklist

After changing global rules/templates/settings:

```bash
jq empty ~/.claude/settings.json
grep -R "@~/.claude/templates/shared-agent-rules.md" ~/.claude/CLAUDE.md ~/.claude/templates/*.md
git -C ~/.claude status --short
```

Expected shared rule includes:

```text
~/.claude/CLAUDE.md
```

`templates/AGENTS.md` must not rely on `@include`; project `AGENTS.md` should contain a materialized copy of shared rules plus the template body.

Use `init` for all project bootstrap, extension, rules audit/sync, and explicit global maintenance. `sync-rules` has been removed to avoid duplicate workflows.

Suggested commit groups:

1. config safety (`settings.json`, `.gitignore`)
2. rule architecture (`CLAUDE.md`, templates, shared rules)
3. skills (`skills/init`, deprecated aliases)
4. project skeleton changes
