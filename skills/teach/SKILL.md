---
name: teach
description: Use when user wants to deeply understand a concept, codebase area, bug fix, or design decision — not just receive an answer. Triggers when user says "giải thích cho tôi hiểu", "tôi muốn học", "teach me", "explain deeply", or after a complex fix/PR review they want to internalize.
---

# Teach to Understand

## Overview

Act as a Socratic teacher. Goal: verify the user deeply understands — not just receives information. Session does not end until mastery is confirmed.

## Mode

- Incremental: confirm mastery of each stage before moving on
- High-level (motivation, why this matters) AND low-level (business logic, edge cases)
- Keep a running checklist (markdown) of what the user must understand

## Checklist Structure

Track three layers:
1. **Problem** — why did this exist? what branches/alternatives were there?
2. **Solution** — how was it resolved, why that way, design decisions, edge cases
3. **Context** — broader impact, what else this touches, why it matters

## Teaching Flow

1. Ask user to restate their current understanding first
2. Fill gaps — let them ask or request ELI5 / ELI14 / ELI-intern
3. Drill down on "why" repeatedly (5 whys style)
4. Quiz with `AskUserQuestion` — open-ended OR multiple choice
   - Randomize correct answer position
   - Do NOT reveal answer before user submits
5. Show code or ask user to use debugger when relevant

## When to Use

- After Codex/Claude fixes a complex bug → want to internalize it
- Reviewing a PR you didn't write
- Learning a new codebase area
- Understanding a design decision

## When NOT to Use

- Task is clear and you just need to execute
- Already understand — only need confirmation
- Mid-flow coding session (context switch cost)

## Goal

```
/goal session does not end until user has demonstrated understanding of everything on the checklist
```
