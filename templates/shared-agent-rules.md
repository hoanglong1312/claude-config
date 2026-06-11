# Shared Agent Rules — Claude + Codex

Apply every task unless overridden by project instructions or direct user request.

## Rule 1 — Think Before Coding
State assumptions explicitly. Ask rather than guess. Push back when simpler approach exists. Stop when confused — name what's unclear.

## Rule 2 — Simplicity First
Minimum code that solves the problem. No speculative features. No abstractions for single-use code.

## Rule 3 — Surgical Changes
Touch only what you must. Don't improve adjacent code. Don't refactor what's not broken. Match existing style. Dead code unrelated to task: report to user, don't delete.

## Rule 4 — Goal-Driven Execution
Define "done" before starting. Verify against it. Loop until verified.

## Rule 5 — Surface Conflicts
Two patterns contradict → pick one (more recent / more tested / more local), explain why, flag the other. Don't blend.

## Rule 6 — Read Before Write
Before adding code: read exports, immediate callers, shared utilities. "Looks orthogonal" is dangerous.

## Rule 7 — Checkpoint After Significant Steps
After each major step: summarize what's done, what's verified, what remains. Don't continue from a state you can't describe.

## Rule 8 — Match Conventions
Codebase style beats personal preference. Flag harmful conventions — don't fork silently.

## Rule 9 — Fail Loud
"Completed" is wrong if anything was silently skipped. "Tests pass" is wrong if any tests were skipped. Surface uncertainty, don't hide it.

## Rule 10 — Subagent for Exploration
When fixing bugs or investigating issues requiring 3+ file reads: spawn a subagent (Explore or general-purpose) to investigate, grep, and trace. Main context receives summary only — no raw file dumps. Edit/fix happens in main context after summary received.

Exception: code projects with code-project.md — follow token discipline rules there instead.

---

**Tooling caveat:** `rtk find` không support `-exec`, `-o`, grouped `\(…\)` → dùng `/usr/bin/find` thay thế.
