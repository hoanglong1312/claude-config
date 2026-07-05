# Portable Global Agent Config

Portable config for Claude Code and Codex across macOS and Windows.

## Architecture

- `templates/shared-agent-rules.md`: shared portable agent behavior.
- `templates/shared-workflows/`: curated workflow checklists adapted from current Superpowers/Caveman/RTK discipline.
- `templates/CLAUDE.global.md`: Claude Code wrapper with plugin-specific mechanisms.
- `templates/AGENTS.md`: Codex appendix.
- `AGENTS.md`: generated materialized Codex rules.

Claude Code can use includes and plugins. Codex receives plain text in `AGENTS.md`.

## Fresh Machine Setup

No install script — Claude Code itself is the prerequisite to even use this repo, so just clone it and ask Claude Code to set it up:

```bash
git clone https://github.com/hoanglong1312/claude-config.git
cd claude-config
claude
```

Then tell Claude: "set up this claude-config repo as my global ~/.claude config, following this README." Claude reads this file and copies `templates/`, `hooks/`, `skills/`, `references/`, `docs/` into `~/.claude/`, merges `settings.json` (preserving existing values, skipping secret-looking env keys), and writes `~/.claude/CLAUDE.md` from `templates/CLAUDE.global.md`.

Prerequisites (ask Claude to check/install as needed): Node.js, Python + pip, Codex CLI, RTK, Markitdown.

Optional plugin setup:

```
claude plugin marketplace add openai/codex-plugin-cc
claude plugin marketplace add JuliusBrussee/caveman
claude plugin marketplace add obra/superpowers-marketplace
claude plugin marketplace update
claude plugin install codex@openai-codex
claude plugin install caveman@caveman
claude plugin install superpowers@superpowers-marketplace
```

`superpowers@claude-plugins-official` may not exist in every marketplace. Current fallback is `superpowers@superpowers-marketplace` if that marketplace is installed.

To render `AGENTS.md` from shared rules (Codex-side), run `bash scripts/sync-agent-rules.sh` (or `.ps1` on Windows) after the config is in place.

## Settings Layers

- `settings.local.example.json`: local config example.
- `settings.local.json`: private local override, gitignored.

Platform-specific settings (`settings.macos.json`/`settings.windows.json`/`settings.shared.json`) were dropped — single-machine setup doesn't need them. When Claude merges `settings.json` during setup, it must preserve existing user values and skip secret-looking keys such as `ANTHROPIC_*`, `OPENAI_*`, `*_API_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`, `BASE_URL`, or `*_BASE_URL`.

Hook wiring (statusline, SessionStart, etc.) is opt-in — ask via the `init` skill's Global Maintenance phase after install, don't hardcode into a settings file.

## Generated Files

`AGENTS.md` is generated from shared rules, shared workflows, and the Codex appendix. Edit project-specific Codex notes inside the project notes block only.

## Safety

Setup should back up `~/.claude` (timestamped copy) before writing, and merge `settings.json` instead of replacing it wholesale. Existing hook files (e.g. a personalized `caveman-activate.js`) must not be silently overwritten by this repo's thinner generic versions — check for meaningful differences before copying over an existing file.

## Verification

```bash
jq empty settings.local.example.json
bash -n scripts/sync-agent-rules.sh
node --check hooks/project-check.js hooks/session-resume.js hooks/caveman-activate.js hooks/caveman-mode-tracker.js
```
