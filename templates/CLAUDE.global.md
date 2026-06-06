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

## Superpowers
- Before each response, classify user intent.
- If a matching Superpowers skill exists, invoke it with the `Skill` tool before answering or acting.
- Use `superpowers:brainstorming` for feature/design shaping.
- Use `superpowers:writing-plans` for implementation plans.
- Use `superpowers:systematic-debugging` for bugs, failing tests, or unexpected behavior.
- Use `superpowers:test-driven-development` for code implementation when practical.
- Use `superpowers:verification-before-completion` before reporting implementation done.
- Use `superpowers:requesting-code-review` or project review tools after large changes.

## Caveman
- If Caveman mode is active, follow its terse response style.
- Keep technical content exact even when terse.

## RTK
- Use `rtk gain`, `rtk gain --history`, and `rtk discover` directly for RTK meta commands.
- Use `rtk proxy <cmd>` when debugging RTK hook behavior.
- `rtk find` may not support compound predicates/actions; use system `find` for complex queries.

## Statusline and Settings
- For statusline or `settings.json` changes, use the `update-config` skill first.
- Read current settings before editing.
- Merge settings; do not replace the whole file.
- Preserve `statusLine.type = "command"` unless explicitly asked otherwise.
- Validate JSON after edits.
- If UI does not update, restart Claude Code or reload `/hooks`.

## Local Paths and Private Workflow
- Do not hardcode private machine paths in public config.
- Use environment variables for local paths such as `OBSIDIAN_VAULT_PATH`.
- If an optional local path/env is missing, skip silently when safe.
