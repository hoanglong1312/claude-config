# Tool Output Discipline

Use tools to reduce noise.

- Prefer scoped commands and filters over full raw dumps.
- Do not paste long logs into final answers.
- Summarize only the lines needed for the decision.
- Report exact failed command and exact relevant error when a check fails.
- If a token-saving proxy or output filter is available, use it when it does not change semantics.
- Do not assume optional tools exist; detect or degrade gracefully.
