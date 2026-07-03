# Portable Global Agent Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build repo artifacts for a portable global Claude/Codex config that preserves current workflow through shared workflows and tool-specific wrappers.

**Architecture:** Shared rules and curated workflows live under `templates/` and are rendered into Claude Code global wrapper or Codex materialized `AGENTS.md`. Install/sync scripts copy and merge safely, preserving existing global config through backups and non-destructive merge rules. Hooks are portable Node where possible, with OS-specific statusline scripts.

**Tech Stack:** Markdown templates, Bash, PowerShell, Node.js hook scripts, JSON settings, generated `AGENTS.md` markers.

---

## File Map

- Create `templates/shared-agent-rules.md`: portable shared behavior.
- Create `templates/shared-workflows/*.md`: portable workflows adapted from current Superpowers/Caveman/RTK discipline.
- Create `templates/CLAUDE.global.md`: Claude Code wrapper template with plugin mechanisms.
- Create `templates/AGENTS.md`: Codex appendix template.
- Create root `AGENTS.md`: generated Codex rules materialized from templates.
- Create `settings.shared.json`, `settings.macos.json`, `settings.windows.json`, `settings.local.example.json`: layered safe settings.
- Create `scripts/sync-agent-rules.sh`, `scripts/sync-agent-rules.ps1`: render/copy rules safely.
- Create `scripts/install-global.sh`, `scripts/install-global.ps1`: backup/copy/merge settings safely.
- Create `hooks/*.js`, `hooks/caveman-statusline.sh`, `hooks/caveman-statusline.ps1`: portable hooks/statusline.
- Create `skills/init/skill.md`: init skill aligned with new architecture.
- Create `references/plugins.md`, `references/repos.md`: plugin/source references.
- Create `docs/migration.md`, `docs/verification.md`: migration and test checklists.
- Create/update `README.md`: setup runbook.
- Update `.gitignore`: local/secrets/cache safety.

---

### Task 1: Shared Rules and Workflows

**Files:**
- Create: `templates/shared-agent-rules.md`
- Create: `templates/shared-workflows/intent-routing.md`
- Create: `templates/shared-workflows/planning.md`
- Create: `templates/shared-workflows/debugging.md`
- Create: `templates/shared-workflows/tdd.md`
- Create: `templates/shared-workflows/verification.md`
- Create: `templates/shared-workflows/review.md`
- Create: `templates/shared-workflows/response-style.md`
- Create: `templates/shared-workflows/tool-output-discipline.md`

- [ ] Write concise portable shared rules with no Claude-only syntax or local paths.
- [ ] Write workflow files as materialized checklists usable by Claude Code and Codex.
- [ ] Verify no Claude include directive, provider secret, or machine path appears in shared files.

### Task 2: Tool-Specific Templates and Generated Codex Output

**Files:**
- Create: `templates/CLAUDE.global.md`
- Create: `templates/AGENTS.md`
- Create: `AGENTS.md`

- [ ] Write Claude wrapper with shared includes and `Claude Code Only` mechanisms.
- [ ] Write Codex appendix with materialized-checklist rule and no Claude include directive.
- [ ] Generate root `AGENTS.md` with generated block and project notes block.
- [ ] Verify generated `AGENTS.md` has no Claude include directive.

### Task 3: Settings Layers

**Files:**
- Create: `settings.shared.json`
- Create: `settings.macos.json`
- Create: `settings.windows.json`
- Create: `settings.local.example.json`

- [ ] Add safe shared settings with no secrets/providers.
- [ ] Add OS-specific hook/statusline commands.
- [ ] Validate all JSON files.

### Task 4: Sync Scripts

**Files:**
- Create: `scripts/sync-agent-rules.sh`
- Create: `scripts/sync-agent-rules.ps1`

- [ ] Implement Bash renderer for shared templates and project `AGENTS.md`.
- [ ] Implement PowerShell renderer with same behavior.
- [ ] Preserve project notes block when replacing generated block.
- [ ] Verify scripts with temp output.

### Task 5: Installers

**Files:**
- Create: `scripts/install-global.sh`
- Create: `scripts/install-global.ps1`

- [ ] Implement backup/copy/render/merge flow.
- [ ] Merge settings without overwriting user values.
- [ ] Skip secret-looking env keys.
- [ ] Validate JSON after merge.
- [ ] Test installer against temp `CLAUDE_CONFIG_DIR`, not live `~/.claude`.

### Task 6: Hooks and Statusline

**Files:**
- Create: `hooks/project-check.js`
- Create: `hooks/session-resume.js`
- Create: `hooks/caveman-activate.js`
- Create: `hooks/caveman-mode-tracker.js`
- Create: `hooks/caveman-statusline.sh`
- Create: `hooks/caveman-statusline.ps1`

- [ ] Write portable hooks using Node and environment variables.
- [ ] Keep Obsidian hook silent when `OBSIDIAN_VAULT_PATH` is absent.
- [ ] Write OS-specific statusline scripts that parse stdin JSON.
- [ ] Run Node syntax checks and statusline smoke tests.

### Task 7: Init Skill and Docs

**Files:**
- Create: `skills/init/skill.md`
- Create: `references/plugins.md`
- Create: `references/repos.md`
- Create: `docs/migration.md`
- Create: `docs/verification.md`
- Create: `README.md`
- Modify: `.gitignore`

- [ ] Write init skill instructions for new architecture.
- [ ] Document plugin adaptations and setup steps.
- [ ] Document migration, rollback, and verification.
- [ ] Update `.gitignore` for local/secrets/cache files.

### Task 8: Verification and Conflict Check

**Files:**
- Validate all created files.

- [ ] Run JSON validation.
- [ ] Run shell syntax check.
- [ ] Run PowerShell parser if available.
- [ ] Run Node syntax checks.
- [ ] Run sync script into temp directory.
- [ ] Run installer into temp `CLAUDE_CONFIG_DIR`.
- [ ] Grep for forbidden secrets/path/includes.
- [ ] Review generated files for workflow preservation.

---

## Self-Review

- Spec coverage: covers shared rules, workflows, Claude wrapper, Codex materialized output, settings, scripts, hooks, init skill, docs, gitignore, verification.
- Placeholder scan: no placeholders remain.
- Type consistency: filenames and paths match design spec.
