# Shared Agent Rules — Claude + Codex

Apply every task unless overridden by project instructions or direct user request.

## Rule 1 — Think Before Coding
State assumptions explicitly. Ask rather than guess. Push back when simpler approach exists. Stop when confused — name what's unclear.

**Anti-rationalization:**

| Bào chữa | Thực tế |
|---|---|
| "Tôi biết bug rồi, fix luôn" | Reproduce trước — 30% đoán sai |
| "Test này chắc wrong" | Verify trước khi skip |
| "Refactor nhỏ, thêm vào luôn" | Refactor + feature = review + debug đều khó hơn |

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

## Rule 10 — Debug Tier Selection

Pick the lightest tool that can confirm the bug:

| Bug loại | Tool |
|---|---|
| Logic thuần / function / formatter / reducer | Unit test — nhanh nhất, run nhiều lần |
| React component / interaction / state | Inspect code + `npm run build`, unit test nhỏ nếu cần |
| UI visual / layout / navigation | `cmux browser snapshot` — đọc accessibility tree, verify bằng mắt |
| Console error / network / DOM / JS | `cmux browser devtools toggle` hoặc `cmux browser eval <js>` |
| Click, fill, interact | `cmux browser click/fill/type <selector>` |
| Screenshot | `cmux browser screenshot` |
| E2E flow quan trọng (login, payment, navigation nhiều màn) | Playwright — chỉ khi flow dễ regression |

Default với React/Vite project:
```
Đọc file liên quan → sửa scoped → npm run build → cmux browser verify → commit file cụ thể
```

## Rule 11 — claude-teams cho Multi-Agent

Dùng `cmux claude-teams` thay `claude` khi có 2+ việc độc lập chạy song song được (fix A + fix B, feature + test).

## Rule 12 — Subagent for Exploration
When fixing bugs or investigating issues requiring 3+ file reads: spawn a subagent (Explore or general-purpose) to investigate, grep, and trace. Main context receives summary only — no raw file dumps. Edit/fix happens in main context after summary received.

Exception: code projects with code-project.md — follow token discipline rules there instead.

## Rule 13 — Clarify Before Execute

Nếu có bất kỳ điều gì mơ hồ trong yêu cầu — hỏi user trong **1 lần duy nhất** trước khi ghi file, chạy code, hoặc thực thi bất kỳ action nào. Không đoán, không ghi rồi mới hỏi.
