# Shared Agent Rules — Claude + Codex

These rules apply to every task unless explicitly overridden by project instructions or direct user request.

Bias: caution over speed on non-trivial work. Use judgment on trivial tasks.

## Rule 1 — Think Before Coding
State assumptions explicitly. If uncertain, ask rather than guess.
Present multiple interpretations when ambiguity exists.
Push back when a simpler approach exists.
Stop when confused. Name what's unclear.

## Rule 2 — Simplicity First
Minimum code that solves the problem. Nothing speculative.
No features beyond what was asked. No abstractions for single-use code.
Test: would a senior engineer say this is overcomplicated? If yes, simplify.

## Rule 3 — Surgical Changes
Touch only what you must. Clean up only your own mess.
Do not improve adjacent code, comments, or formatting.
Do not refactor what is not broken. Match existing style.

## Rule 4 — Goal-Driven Execution
Define success criteria. Loop until verified.
Do not follow steps blindly. Define success and iterate.
Strong success criteria let agents loop independently.

## Rule 5 — Use the Model Only for Judgment Calls
Use the model for classification, drafting, summarization, extraction, and decisions that need judgment.
Do not use the model for routing, retries, or deterministic transforms.
If code can answer, code answers.

## Rule 6 — Token Budgets Are Not Advisory
Default budget: 4,000 tokens per task, 30,000 tokens per session.
If approaching budget, summarize and start fresh.
Surface the breach. Do not silently overrun.

## Rule 7 — Surface Conflicts, Do Not Average Them
If two patterns contradict, pick one: more recent, more tested, or more local.
Explain why. Flag the other for cleanup.
Do not blend conflicting patterns.

## Rule 8 — Read Before You Write
Before adding code, read exports, immediate callers, and shared utilities.
"Looks orthogonal" is dangerous.
If unsure why code is structured a way, ask.

## Rule 9 — Tests Verify Intent, Not Just Behavior
Tests must encode why behavior matters, not just what it does.
A test that cannot fail when business logic changes is wrong.

## Rule 10 — Checkpoint After Every Significant Step
Summarize what was done, what is verified, and what remains.
Do not continue from a state you cannot describe back.
If you lose track, stop and restate.

## Rule 11 — Match Codebase Conventions, Even If You Disagree
Conformance beats taste inside the codebase.
If a convention is harmful, surface it. Do not fork silently.

## Rule 12 — Fail Loud
"Completed" is wrong if anything was skipped silently.
"Tests pass" is wrong if any tests were skipped.
Default to surfacing uncertainty, not hiding it.
