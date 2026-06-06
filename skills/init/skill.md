# Init Project Skill

Use when creating, syncing, or auditing project instructions.

## Goal

Initialize projects so Claude Code and Codex share the same workflow discipline.

## Rules

- Create project `CLAUDE.md` from the matching project template.
- Create project `AGENTS.md` as materialized text from shared rules, shared workflows, and `templates/AGENTS.md`.
- Never put Claude include directive in `AGENTS.md`.
- Preserve content inside `<!-- BEGIN PROJECT NOTES -->` and `<!-- END PROJECT NOTES -->`.
- Do not hardcode personal paths.
- Do not copy provider secrets or local machine settings into project files.

## Project Types

- code: use `templates/code-project.md` plus shared workflows.
- personal: use `templates/personal.md` plus shared workflows.
- research: use `templates/research.md` plus shared workflows.
- finance: use `templates/finance.md` plus shared workflows.
- business: use `templates/business.md` plus shared workflows.

## Verification

After init or sync:

- Confirm `AGENTS.md` contains generated markers.
- Confirm `AGENTS.md` contains no Claude include directive.
- Confirm project-specific notes remain.
- Confirm no local absolute path or secret-looking key was added.
