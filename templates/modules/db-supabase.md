# Module: DB / RLS (Supabase)

Opt-in. Include khi project dùng Supabase hoặc DB có migration + RLS.

## Phân công cứng

| Việc | Ai làm |
|------|--------|
| Viết SQL migration file | Codex |
| Apply migration | Claude (`mcp__supabase__apply_migration`) |
| Verify kết quả | Claude (`mcp__supabase__execute_sql`) |
| Tra schema khi viết SQL | Codex (nếu có read-only MCP) |

## Codex read-only Supabase (tùy chọn, recommended)

Thêm vào `.codex/config.toml` trong project root:
```toml
[mcp_servers.supabase-readonly]
command = "npx"
args = ["-y", "@supabase/mcp-server-supabase@latest", "--access-token", "${SUPABASE_ACCESS_TOKEN}", "--read-only"]
```

Cho phép Codex tự tra `list_tables`, `execute_sql` (SELECT) → ít ASSUMPTION hơn.
Write operations (`apply_migration`, INSERT/UPDATE/DELETE) vẫn do Claude thực thi.

## Investigation cross-source

Bug đụng DB → Claude được tự Phase 1 (token discipline suspended) khi cần cross-reference đồng thời: DB schema + RLS policy + code logic. Grep đơn thuần không đủ.
