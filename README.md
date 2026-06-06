# Portable Global Agent Config

Portable config for Claude Code and Codex across macOS and Windows.

## Architecture

- `templates/shared-agent-rules.md`: shared portable agent behavior.
- `templates/shared-workflows/`: curated workflow checklists adapted from current Superpowers/Caveman/RTK discipline.
- `templates/CLAUDE.global.md`: Claude Code wrapper with plugin-specific mechanisms.
- `templates/AGENTS.md`: Codex appendix.
- `AGENTS.md`: generated materialized Codex rules.

Claude Code can use includes and plugins. Codex receives plain text in `AGENTS.md`.

## Windows Setup

Prerequisites:

- Node.js
- Python + pip
- Claude Code CLI
- Codex CLI
- RTK
- Markitdown

Install:

```powershell
git clone https://github.com/hoanglong1312/claude-config.git
cd claude-config
.\scripts\install-global.ps1
.\scripts\sync-agent-rules.ps1
```

Optional plugin setup:

```powershell
claude plugin marketplace add openai/codex-plugin-cc
claude plugin marketplace add JuliusBrussee/caveman
claude plugin marketplace add obra/superpowers-marketplace
claude plugin marketplace update
claude plugin install codex@openai-codex
claude plugin install caveman@caveman
claude plugin install superpowers@superpowers-marketplace
```

`superpowers@claude-plugins-official` may not exist in every marketplace. Current fallback is `superpowers@superpowers-marketplace` if that marketplace is installed.

## macOS Setup

```bash
git clone https://github.com/hoanglong1312/claude-config.git
cd claude-config
bash scripts/install-global.sh
bash scripts/sync-agent-rules.sh
```

## Settings Layers

- `settings.shared.json`: safe portable config.
- `settings.macos.json`: macOS/Linux hooks and statusline.
- `settings.windows.json`: Windows hooks and statusline.
- `settings.local.example.json`: local config example.
- `settings.local.json`: private local override, gitignored.

Installers merge settings and preserve existing user values. They do not copy secret-looking keys such as `ANTHROPIC_*`, `OPENAI_*`, `*_API_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`, `BASE_URL`, or `*_BASE_URL`.

## Generated Files

`AGENTS.md` is generated from shared rules, shared workflows, and the Codex appendix. Edit project-specific Codex notes inside the project notes block only.

## Safety

Installers create a timestamped backup under the active Claude config directory before writing. They merge config instead of replacing the whole settings file.

## Verification

```bash
jq empty settings.shared.json settings.macos.json settings.windows.json settings.local.example.json
bash -n scripts/install-global.sh scripts/sync-agent-rules.sh
node --check hooks/project-check.js hooks/session-resume.js hooks/caveman-activate.js hooks/caveman-mode-tracker.js
```

Then test install using a temporary config directory before touching live config:

```bash
CLAUDE_CONFIG_DIR="$(mktemp -d)" bash scripts/install-global.sh
```
