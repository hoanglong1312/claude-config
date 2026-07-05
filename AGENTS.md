<!-- BEGIN GENERATED AGENT RULES -->
<!-- generated-from: templates/shared-agent-rules.md + templates/shared-workflows/*.md + templates/AGENTS.md -->
<!-- generated-date: 2026-06-06 -->
<!-- shared-rules-sha256: ac9a2d771372fb29dfb1612343e57f2b510f80e25cc388d30252fc1ac3d15667 -->
<!-- workflows-sha256: 5651a693e5f54029a6405d3aeb608d8b7ce5a9fcdebf68d91f697d7d17360f06 -->
<!-- template-sha256: b101fe6ba5797b4e21de69602afc3450c2ce84d045172d6e7690bf1be24f1535 -->

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

---

# Intent Routing Workflow

Before acting, classify the user's intent.

- New feature or design: clarify goal and success criteria before implementation.
- Existing spec needing implementation: write or follow an implementation plan.
- Bug, test failure, or unexpected behavior: use the debugging workflow before proposing fixes.
- Code change: prefer test-driven development when practical.
- Completed implementation: verify before saying done.
- Review request: review findings before praise or summary.
- Config or automation change: preserve existing config and merge safely.

If more than one workflow applies, follow the stricter workflow first.

---

# Planning Workflow

Use for non-trivial implementation, multi-file work, config migrations, and architecture changes.

1. Define success criteria that can be verified.
2. Identify files likely to change and what each file owns.
3. Break work into small tasks that can pass independently.
4. Name assumptions explicitly.
5. Prefer the simplest design that meets the goal.
6. Ask when requirements change outcome.
7. Execute one task at a time and checkpoint after major steps.

---

# Debugging Workflow

Do not guess fixes.

1. Reproduce the failure or identify the exact observed symptom.
2. Gather evidence from logs, tests, stack traces, or relevant code.
3. State the current hypothesis.
4. Make the smallest change that should address the hypothesis.
5. Re-run the same failing check.
6. If it still fails, update the hypothesis from evidence and repeat.
7. Report root cause, fix, verification, and remaining risk.

---

# Test-Driven Development Workflow

Use when changing code logic and tests are practical.

1. Write a failing test that encodes the intended behavior.
2. Run the test and confirm it fails for the expected reason.
3. Implement the smallest change that can pass the test.
4. Run the test and confirm it passes.
5. Run nearby relevant tests.
6. Refactor only if needed and only after tests pass.
7. State tests run and result.

---

# Verification Workflow

Before saying work is done:

1. Run the smallest reliable check that proves the change works.
2. Run broader checks when the change touches shared logic or config.
3. For generated files, verify generated output and source templates.
4. For config changes, validate syntax and run a dry-run or temp-dir test when possible.
5. If any check fails, fix or report the blocker.
6. If a check is skipped, state why and what risk remains.

---

# Review Workflow

Review changed work before completion.

Check:

- Correctness: does it satisfy the stated behavior?
- Readability: can a future maintainer understand it quickly?
- Architecture: are boundaries clear and simple?
- Security: are secrets, permissions, external effects, and user data handled safely?
- Performance: does it avoid unnecessary expensive work?

Report blockers first. Avoid formatting nits unless they change meaning.

---

# Response Style Workflow

Default style:

- Be concise and direct.
- Drop filler and empty reassurance.
- State the thing, the action, and the reason.
- Keep code blocks, commands, paths, errors, URLs, and identifiers exact.
- Use full clear language for security warnings, irreversible actions, and ordered procedures.
- End with the next step when useful.

---

# Tool Output Discipline

Use tools to reduce noise.

- Prefer scoped commands and filters over full raw dumps.
- Do not paste long logs into final answers.
- Summarize only the lines needed for the decision.
- Report exact failed command and exact relevant error when a check fails.
- If a token-saving proxy or output filter is available, use it when it does not change semantics.
- Do not assume optional tools exist; detect or degrade gracefully.

---

# Codex Only

Codex reads this file as materialized text.

- Do not rely on Claude include directives in `AGENTS.md`.
- If shared rules mention a Claude Code skill or plugin, follow the equivalent checklist in this file instead of invoking that tool.
- For non-trivial work, plan before editing.
- For bugs, follow the debugging workflow before fixing.
- After code or config changes, review the diff and run relevant verification.
- Preserve user changes. Do not commit or push unless the user asks.
- Optional tools such as RTK may be used only when available.

<!-- END GENERATED AGENT RULES -->

<!-- BEGIN PROJECT NOTES -->
<!-- Project-specific Codex notes live here. Sync scripts preserve this block. -->
<!-- END PROJECT NOTES -->
