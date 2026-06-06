# Migration Guide

## Goal

Move an existing global Claude config to portable shared rules without losing current workflow.

## Steps

1. Back up current config.
   - Installer creates `~/.claude/backups/install-YYYYMMDD-HHMMSS`.
2. Classify current rules.
   - Shared: language, context, planning, debugging, verification, review, response style.
   - Claude Code Only: `Skill`, slash commands, plugin runtime, statusline, Claude hooks.
   - Private local: machine paths, provider env, vault paths, base URLs.
3. Run installer for the current OS.
4. Review generated `~/.claude/CLAUDE.md`.
5. Render Codex `AGENTS.md` using sync script.
6. Validate settings JSON.
7. Check Claude Code behavior.
8. Check Codex materialized rules.
9. Roll back by copying files from backup if needed.

## Rollback

Copy backed-up files from the backup directory into the Claude config directory. Do not delete user-created files unless you know they were created by the migration.
