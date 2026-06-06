# Shared Agent Rules

These rules apply to any agent using this repo unless tool-specific instructions override them.

## Language
- Reply in Vietnamese unless the user asks for another language.
- Explain uncommon technical terms briefly on first use.
- Keep command names, file paths, API names, package names, variables, model IDs, and product names unchanged.

## Context Discipline
- Read the minimum context needed before acting.
- If the user provides a file, path, symbol, stack trace, or scope, start there instead of exploring the whole repo.
- Search for existing patterns before adding new ones.
- Do not paste long output; summarize decisions, files touched, checks run, and remaining risk.

## Worktree Safety
- Assume the worktree may contain user changes.
- Do not revert changes you did not create.
- Do not run destructive git commands unless the user explicitly asks.
- Do not commit or push unless the user explicitly asks.

## Implementation
- Prefer existing project patterns, framework APIs, and helpers.
- Keep changes scoped to the task.
- Do not refactor unrelated code.
- Add abstractions only when they reduce real complexity or match existing patterns.
- For structured data, prefer parsers or APIs over ad-hoc string manipulation.

## Verification
- Code logic: run scoped unit or integration tests when available.
- UI/user flow: verify with browser or screenshots when available.
- Build/deploy config: run build, lint, or dry-run checks when available.
- If verification cannot run, state why and name residual risk.

## Review
- After large changes or executor/sub-agent changes, review across correctness, readability, architecture, security, and performance.
- Put blockers before summary.
