# Codex Only

Codex reads this file as materialized text.

- Do not rely on Claude include directives in `AGENTS.md`.
- If shared rules mention a Claude Code skill or plugin, follow the equivalent checklist in this file instead of invoking that tool.
- For non-trivial work, plan before editing.
- For bugs, follow the debugging workflow before fixing.
- After code or config changes, review the diff and run relevant verification.
- Preserve user changes. Do not commit or push unless the user asks.
- Optional tools such as RTK may be used only when available.
