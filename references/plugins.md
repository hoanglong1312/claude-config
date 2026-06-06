# Plugin References

| Plugin | Repo | Shared adaptation | Tool-specific mechanism |
|---|---|---|---|
| Superpowers | https://github.com/obra/superpowers | intent routing, planning, debugging, TDD, verification, review | Claude Code uses `Skill`; Codex follows materialized checklists |
| Caveman | Add repo URL when finalized | terse response style | Claude Code may use plugin/hook; Codex follows style text |
| RTK | Add repo URL when finalized | output/token discipline | Claude Code may use RTK hooks/commands; Codex uses RTK only if available |

Do not auto-fetch plugin docs at runtime. Review upstream manually and update curated workflow files.
