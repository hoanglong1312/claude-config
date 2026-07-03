# Portable Global Agent Config Design

**Goal:** Refactor current global Claude config into a portable config repo that preserves the current working flow while making it reusable across macOS, Windows, Claude Code, and Codex.

**Status:** Approved design direction: curated shared workflows + tool-specific wrappers.

**Date:** 2026-06-06

---

## 1. Problem

Current global config is useful but too coupled to Claude Code and macOS. It includes Claude-specific mechanisms, local paths, plugin behavior, RTK caveats, statusline config, Obsidian behavior, and personal workflow rules in one global surface.

Target state:

- One shared source of truth for agent behavior.
- Claude Code keeps current flow: Superpowers, Caveman style, RTK notes, statusline, hooks, init behavior.
- Codex gets equivalent workflow behavior through materialized `AGENTS.md` text.
- Windows and macOS can use the same repo without hardcoded machine paths.
- Public repo does not contain provider secrets, API keys, base URLs, or local-only paths.
- Installers merge existing config safely instead of replacing it.

---

## 2. Design Decision

Use **curated shared workflows + tool-specific wrappers**.

Shared config captures portable behavior, not plugin runtime implementation. Claude Code uses plugin mechanisms where available. Codex receives materialized checklists and rules in `AGENTS.md`.

Rejected alternatives:

| Option | Reason rejected |
|---|---|
| Copy current global `CLAUDE.md` nearly verbatim into shared rules | Too much Claude-specific syntax and local behavior leaks into Codex. |
| Keep shared rules minimal and leave most behavior Claude-only | Codex would not follow the current working flow. |
| Let Codex fetch/plugin setup from GitHub at runtime | Non-deterministic, internet-dependent, hard to review, and likely to import Claude-only instructions. |

---

## 3. Target Repository Structure

```text
templates/
├─ shared-agent-rules.md
├─ shared-workflows/
│  ├─ intent-routing.md
│  ├─ planning.md
│  ├─ debugging.md
│  ├─ tdd.md
│  ├─ verification.md
│  ├─ review.md
│  ├─ response-style.md
│  └─ tool-output-discipline.md
├─ CLAUDE.global.md
├─ AGENTS.md
├─ code-project.md
├─ personal.md
├─ research.md
├─ finance.md
└─ business.md

scripts/
├─ install-global.ps1
├─ install-global.sh
├─ sync-agent-rules.ps1
└─ sync-agent-rules.sh

hooks/
├─ project-check.js
├─ session-resume.js
├─ caveman-activate.js
├─ caveman-mode-tracker.js
├─ caveman-statusline.ps1
└─ caveman-statusline.sh

references/
├─ plugins.md
└─ repos.md

docs/
├─ migration.md
└─ verification.md

settings.shared.json
settings.macos.json
settings.windows.json
settings.local.example.json

CLAUDE.md
AGENTS.md
README.md
.gitignore

skills/
└─ init/
   └─ skill.md
```

The repo root is the config repo root. Do not create a nested `claude-config/` directory inside the repo.

---

## 4. File Responsibilities

### `templates/shared-agent-rules.md`

Portable behavior shared by Claude Code and Codex.

Contains:

- Language rules.
- Context discipline.
- Worktree safety.
- Implementation discipline.
- Verification expectations.
- Review expectations.
- No hardcoded local paths.
- No provider/API/base URL.
- No Claude-only Claude include directive references.
- No plugin installation commands.

### `templates/shared-workflows/*.md`

Curated workflow checklists adapted from current global behavior and important plugins.

Files:

- `intent-routing.md`: classify task before action; route bug/planning/TDD/review/verification flows.
- `planning.md`: plan before non-trivial implementation; success criteria; task breakdown.
- `debugging.md`: reproduce, gather evidence, hypothesize, fix minimally, verify.
- `tdd.md`: write failing test, run fail, implement minimum, run pass, refactor only if needed.
- `verification.md`: verify by scoped tests/build/browser/manual checks; report residual risk.
- `review.md`: review diff across correctness, readability, architecture, security, performance.
- `response-style.md`: Caveman-inspired concise response style; keep code/commands/errors exact.
- `tool-output-discipline.md`: RTK-inspired output minimization; do not paste long output; summarize checks.

These files are the shared portable equivalent of plugin discipline. They must not require Claude Code plugin runtime.

### `templates/CLAUDE.global.md`

Claude Code global wrapper template.

Contains:

- Includes for shared rules and shared workflows.
- `## Claude Code Only` section.
- Superpowers mechanism: use `Skill` tool when a matching skill exists.
- Caveman mechanism: honor plugin/hook mode when active.
- RTK mechanism and caveats.
- Statusline settings policy.
- Claude Code config management rules.
- Obsidian Bridge rules if kept for current personal workflow.

This file may reference Claude Code features. It must not contain provider secrets or machine-specific private paths in public repo.

### `templates/AGENTS.md`

Codex appendix template.

Contains:

- `## Codex Only` section.
- Codex reads materialized `AGENTS.md` text.
- Codex must not rely on Claude include directive.
- Codex follows shared workflow checklists instead of invoking Claude Code skills.
- Codex reviews diff after executor changes and verifies with test/build/browser/manual checks.

This file is not the generated root `AGENTS.md`; it is an input template.

### Root `AGENTS.md`

Generated materialized output for Codex.

Generated from:

1. `templates/shared-agent-rules.md`
2. all `templates/shared-workflows/*.md` in fixed order
3. `templates/AGENTS.md`

Must contain no Claude include directive.

### Settings files

- `settings.shared.json`: portable safe config only.
- `settings.macos.json`: macOS hook/statusline commands.
- `settings.windows.json`: Windows hook/statusline commands.
- `settings.local.example.json`: documented local override example.
- `settings.local.json`: user-created, gitignored, private values only.

### Scripts

- `install-global.ps1`: Windows global installer.
- `install-global.sh`: macOS/Linux global installer.
- `sync-agent-rules.ps1`: sync shared rules and render `AGENTS.md` from Windows.
- `sync-agent-rules.sh`: sync shared rules and render `AGENTS.md` from macOS/Linux.

### Hooks

Use Node for portable hooks where possible:

- `project-check.js`
- `session-resume.js`
- `caveman-activate.js`
- `caveman-mode-tracker.js`

Use OS-specific statusline scripts:

- `caveman-statusline.ps1`
- `caveman-statusline.sh`

### `references/plugins.md`

Registry of upstream plugin inspiration:

- Superpowers: planning, debugging, TDD, verification, review workflow discipline.
- Caveman: concise response style.
- RTK: token/output discipline and CLI caveats.

GitHub links live here as references. Runtime should not fetch upstream plugin docs automatically.

### `skills/init/skill.md`

Project initialization skill.

Contains:

- New project routing for code, personal, research, finance, and business projects.
- Rendering rules for project `CLAUDE.md` and materialized project `AGENTS.md`.
- Generated marker preservation rules.
- No hardcoded personal paths.

### `README.md`

Human setup and migration entrypoint.

Must document:

- Architecture.
- Windows setup.
- macOS setup.
- Settings layering.
- Plugin marketplace caveats.
- No-secrets policy.
- Generated files policy.
- Verification commands.
- Rollback approach.

### `docs/migration.md`

Migration guide from current global config.

Must cover:

- Backup current `~/.claude`.
- Classify current global rules into shared, Claude-only, and private-local.
- Apply installer.
- Compare generated files.
- Validate Claude Code behavior.
- Validate Codex `AGENTS.md` behavior.
- Roll back from backup.

### `docs/verification.md`

Verification checklist for both platforms and both agents.

---

## 5. Render Flow

### Claude Code global render

Installer writes `~/.claude/CLAUDE.md` from `templates/CLAUDE.global.md`. The render target is always the active Claude config directory, not a hardcoded machine path. Default target is `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` on macOS/Linux and `$env:CLAUDE_CONFIG_DIR` or `$HOME/.claude` on Windows.

The generated Claude file uses includes:

```md
@~/.claude/templates/shared-agent-rules.md
@~/.claude/templates/shared-workflows/intent-routing.md
@~/.claude/templates/shared-workflows/planning.md
@~/.claude/templates/shared-workflows/debugging.md
@~/.claude/templates/shared-workflows/tdd.md
@~/.claude/templates/shared-workflows/verification.md
@~/.claude/templates/shared-workflows/review.md
@~/.claude/templates/shared-workflows/response-style.md
@~/.claude/templates/shared-workflows/tool-output-discipline.md

# Claude Code Only
...
```

Claude Code keeps plugin-aware behavior here. If `~/.claude` include syntax is not portable on a target platform, installer must render equivalent includes using the resolved Claude config directory path for that platform.

### Codex `AGENTS.md` render

Sync scripts generate materialized text:

```md
<!-- BEGIN GENERATED AGENT RULES -->
<!-- generated-from: templates/shared-agent-rules.md + templates/shared-workflows/*.md + templates/AGENTS.md -->
<!-- generated-date: YYYY-MM-DD -->
<!-- shared-rules-sha256: <hash> -->
<!-- workflows-sha256: <hash> -->
<!-- template-sha256: <hash> -->

# Shared Agent Rules
...

---

# Intent Routing Workflow
...

---

# Codex Only
...

<!-- END GENERATED AGENT RULES -->

<!-- BEGIN PROJECT NOTES -->
<!-- Project-specific Codex notes live here. Sync scripts preserve this block. -->
<!-- END PROJECT NOTES -->
```

Sync scripts replace only the generated block and preserve project notes.

---

## 6. Settings Merge Policy

Installers must merge settings, not replace existing `~/.claude/settings.json`.

Required behavior:

1. Detect Claude config directory:
   - Windows: `$env:CLAUDE_CONFIG_DIR` or `$HOME/.claude` / `$env:USERPROFILE/.claude`.
   - macOS/Linux: `${CLAUDE_CONFIG_DIR:-$HOME/.claude}`.
2. Create timestamped backup before writing.
3. Copy templates, hooks, skills, references, and docs.
4. Render `~/.claude/CLAUDE.md` from `templates/CLAUDE.global.md`.
5. Merge settings from:
   - existing `~/.claude/settings.json`
   - `settings.shared.json`
   - OS-specific settings file
   - optional local settings if user created one
6. Preserve existing values unless explicit safe merge is required.
7. Merge arrays/maps with deterministic rules:
   - `enabledPlugins`: union by plugin name, preserve existing order first.
   - `marketplaces`: union by marketplace identifier or URL, preserve existing order first.
   - `permissions`: union list values, preserve existing permissions and append missing safe defaults.
   - `hooks`: merge by event name; append repo-managed hooks without deleting unknown existing hooks.
   - safe `env`: add only non-secret keys that do not already exist.
   - scalar values: existing user value wins unless the key is absent.
8. Skip secret-looking keys:
   - `ANTHROPIC_*`
   - `OPENAI_*`
   - `*_API_KEY`
   - `*_TOKEN`
   - `*_SECRET`
   - `*_PASSWORD`
   - `BASE_URL`
   - `*_BASE_URL`
9. Validate JSON after write.
10. Print summary of files changed, skipped secrets, tool checks, and backup path.

Installers should not automatically install plugins or marketplaces unless a future explicit flag is added. README may list plugin commands for manual setup.

If an existing settings value conflicts with a repo default, installer must preserve the existing value, report the conflict, and avoid silent overwrite.

---

## 7. Current Workflow Preservation

### Superpowers

Shared layer captures workflow discipline:

- Intent classification before action.
- Plan before non-trivial implementation.
- Systematic debugging before fixes.
- TDD for code implementation where applicable.
- Verification before completion.
- Review after large changes or sub-agent/executor changes.

Claude Code Only layer captures mechanism:

- Invoke relevant Superpowers skill with `Skill` tool when available.
- Use actual plugin/slash-command behavior where applicable.

Codex Only layer captures equivalent behavior:

- Follow materialized checklists in `AGENTS.md`.
- Do not try to call Claude Code skills.

### Caveman

Shared layer captures response style:

- Terse, direct responses.
- No filler.
- Keep code, commands, paths, errors, URLs exact.
- Use fuller language for security warnings, irreversible actions, and multi-step procedures.

Claude Code Only layer may reference Caveman plugin/hook runtime.

Codex follows style rules from materialized text.

### RTK

Shared layer captures output discipline:

- Prefer concise tool output.
- Do not paste long logs.
- Summarize relevant result, tests, and residual risk.

Claude Code Only layer captures RTK-specific commands and caveats:

- `rtk gain`
- `rtk discover`
- `rtk proxy <cmd>`
- known `rtk find` limitations

Codex may use RTK only if available. It must not assume RTK exists.

### Statusline

Claude Code Only.

Rules:

- Use `update-config` before statusline/settings changes.
- Read current settings before edit.
- Preserve `statusLine.type = "command"`.
- Merge config, do not replace.
- Validate JSON.
- Tell user to restart Claude Code or reload `/hooks` if UI does not update.

### Obsidian Bridge

Private workflow behavior can remain Claude Code Only if used on this machine.

Portable rule:

- Do not hardcode vault path in public config.
- Use `OBSIDIAN_VAULT_PATH` env when needed.
- If env is missing, hooks silently skip.

---

## 8. `init` Skill Changes

The `init` skill must be updated so new projects follow the new architecture.

Required behavior:

1. Detect project type: code, personal, research, finance, business.
2. Create or update project `CLAUDE.md` from the correct template.
3. Generate project `AGENTS.md` as materialized text from shared rules, shared workflows, Codex appendix, and project notes.
4. Never use Claude include directive inside generated `AGENTS.md`.
5. Preserve project-specific notes with markers.
6. Avoid hardcoded personal paths.
7. For code projects, ensure Claude and Codex receive equivalent core workflow discipline.

Without this change, newly initialized projects will drift back to the old architecture.

---

## 9. README Changes

README must become the setup runbook for new machines.

Required sections:

- Overview: what the repo manages.
- Architecture: shared source, Claude wrapper, Codex materialized output.
- Windows Setup:
  - prerequisites: Node.js, Python + pip, Claude Code CLI, Codex CLI, RTK, Markitdown.
  - commands: clone, run installer, sync rules.
  - optional plugin marketplace commands.
- macOS Setup:
  - prerequisites.
  - commands: clone, run installer, sync rules.
- Plugin marketplace caveat:
  - `superpowers@claude-plugins-official` may not exist depending on marketplace.
  - fallback is `superpowers@superpowers-marketplace` if that is the current working source.
  - add marketplace before install.
- Settings layering.
- No secrets/provider/base URL in public config.
- Generated files policy.
- Backup and rollback.
- Verification checklist.

---

## 10. `.gitignore` Safety

Required entries:

```gitignore
settings.local.json
*.local.json
.env
.env.*
stats-cache.json
session-env/
image-cache/
paste-cache/
.last-update-result.json
.update.lock
```

Private local state must not be committed.

---

## 11. Verification Requirements

### JSON validation

Windows:

```powershell
Get-Content $ClaudeDir/settings.json -Raw | ConvertFrom-Json
```

macOS/Linux:

```bash
jq empty "$ClaudeDir/settings.json" || python -m json.tool "$ClaudeDir/settings.json" >/dev/null
```

### Include policy

Checks:

- Only Claude-facing files may use Claude include directive.
- `templates/AGENTS.md` must not use Claude include directive.
- Generated `AGENTS.md` must not use Claude include directive.
- Project `AGENTS.md` must be materialized.

### Secret/path policy

Grep/check for forbidden public content:

- `ANTHROPIC base URL env key`
- `OPENAI API key env key`
- `ANTHROPIC API key env key`
- `/Users/<name>`
- `C:\Users\<name>`
- other machine-specific absolute paths

### Tool checks

Run where available:

```bash
claude --version
codex --version
rtk --version
markitdown --version
claude plugin list
claude plugin marketplace list
```

Missing tools are reported, not treated as installer failure unless required for the current OS-specific operation.

### Behavior checks

Claude Code:

- Skill routing still triggers for planning/debugging/config tasks.
- Statusline still renders.
- RTK commands still work if installed.
- Hooks still load.

Codex:

- `AGENTS.md` contains shared rules and workflow checklists as text.
- Codex instructions do not mention invoking Claude Code `Skill` tool.
- Codex behavior mirrors current workflow discipline through checklists.

---

## 12. Migration Strategy

Implementation should proceed in logic groups:

1. Config safety and `.gitignore`.
2. Shared rules and curated shared workflows.
3. Claude wrapper and Codex materialized template.
4. Sync scripts and generated markers.
5. Windows/macOS installers.
6. Portable hooks and statusline split.
7. `init` skill update.
8. README and docs.
9. Verification pass.

Do not commit during implementation unless explicitly asked.

---

## 13. Non-Goals

- Do not publish provider secrets.
- Do not hardcode local machine paths.
- Do not auto-install plugins during base installer flow.
- Do not rely on Codex fetching GitHub plugin docs at runtime.
- Do not convert every upstream plugin doc into `AGENTS.md` verbatim.
- Do not replace existing global settings without backup and merge.

---

## 14. Open Implementation Notes

- Hash markers should be included if practical in both PowerShell and Bash scripts.
- Dry-run mode is recommended for installers, but can be implemented after safe merge if time is constrained.
- Plugin upstream audits should be manual or explicitly invoked, not automatic during install.
- If current global private rules contain personal paths or vault locations, migrate them to local/private config or env-driven hooks.

---

## 15. Self-Review

- Placeholder scan: no `TBD`, `TODO`, or intentionally incomplete section remains.
- Scope check: focused on global agent config portability, not app code.
- Consistency check: shared workflows are portable; Claude-specific mechanisms stay in `CLAUDE.global.md`; Codex-specific mechanisms stay in `templates/AGENTS.md`.
- Safety check: settings merge, backup, generated markers, and no-secrets policy are explicit.
