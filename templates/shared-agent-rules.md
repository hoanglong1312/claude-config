# Shared Agent Rules — Claude + Codex

Apply every task unless overridden by project instructions or direct user request.

## Rule 1 — Think Before Coding
State assumptions explicitly. Ask rather than guess. Push back when simpler approach exists. Stop when confused — name what's unclear.

**Anti-rationalization — Debugging:**

| Bào chữa hay gặp | Thực tế |
|---|---|
| "Tôi biết bug là gì rồi, fix luôn" | 30% sai → reproduce trước |
| "Test này chắc wrong" | Verify trước khi skip |
| "Works on my machine" | Check CI, config, dependencies |
| "Fix sau" | Fix ngay — next commit chồng bug mới lên |
| "Flaky test, bỏ qua" | Flaky test = real bug đang hide |

**Anti-rationalization — Implementation:**

| Bào chữa hay gặp | Thực tế |
|---|---|
| "Test cuối luôn cho nhanh" | Bug ở slice 1 làm sai toàn bộ slice sau |
| "Làm hết 1 lượt nhanh hơn" | Nhanh đến khi có lỗi, không biết trong 500 dòng lỗi ở đâu |
| "Refactor này nhỏ, thêm vào luôn" | Refactor + feature = review + debug đều khó hơn |

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

**Không mở Chrome hay browser mới.** Dùng cmux in-app browser:
- `⌘⇧L` — mở browser split pane
- `⌥⌘I` — toggle DevTools
- `⌥⌘C` — JS Console
- Agent tương tác CLI: `cmux browser <snapshot|screenshot|click|eval|goto|wait|...>`

## Rule 11 — claude-teams cho Multi-Agent

Dùng `cmux claude-teams` thay `claude` khi task có **2+ việc độc lập có thể chạy song song**:

| Tình huống | Lệnh |
|---|---|
| 1 task tuần tự | `claude` |
| Fix bug A + fix bug B cùng lúc | `cmux claude-teams` |
| Viết feature + viết test song song | `cmux claude-teams` |
| Tiếp session cũ multi-agent | `cmux claude-teams --continue` |

Dấu hiệu: đang chờ agent xong A mới làm B, nhưng A và B không liên quan → dùng claude-teams.

## Rule 12 — Subagent for Exploration
When fixing bugs or investigating issues requiring 3+ file reads: spawn a subagent (Explore or general-purpose) to investigate, grep, and trace. Main context receives summary only — no raw file dumps. Edit/fix happens in main context after summary received.

Exception: code projects with code-project.md — follow token discipline rules there instead.

## Rule 13 — Clarify Before Execute

Nếu có bất kỳ điều gì mơ hồ trong yêu cầu — hỏi user trong **1 lần duy nhất** trước khi ghi file, chạy code, hoặc thực thi bất kỳ action nào. Không đoán, không ghi rồi mới hỏi.

---

**Tooling caveat:** `rtk find` không support `-exec`, `-o`, grouped `\(…\)` → dùng `/usr/bin/find` thay thế.
