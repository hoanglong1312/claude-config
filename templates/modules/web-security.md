# Module: Web Security Review

Opt-in. Include cho project có API / auth / route nhận user input.

## No Insecure Defaults

Không hardcode default insecure — phải opt-in qua flag/env:
- TLS verify off, CORS `*`, auth bypass, debug endpoint mở → KHÔNG bật mặc định.
- Cần cho dev/test → opt-in qua flag/env, default = secure.

## Security Review — chạy khi

- Commit có tag `SECURITY-SENSITIVE:`, HOẶC
- Diff động vào file/path match pattern: `**/auth/**`, `**/middleware/**`, `**/*policy*`, `**/*rls*`, `**/*migration*`, `**/api/**`, file có `req.body` / `req.params` / `formData` trong thay đổi mới

| Loại lỗ hổng | Kiểm tra gì trong diff |
|---|---|
| SQL Injection | Raw query nối chuỗi user input? → phải parameterized query |
| RLS hole | Bảng mới có RLS policy? Cover đủ roles (anon/authenticated/service_role)? |
| Auth bypass | Endpoint/route mới có auth middleware/guard? |
| IDOR | Query theo ID có filter `WHERE user_id = auth.uid()`? User A lấy được data user B? |
| XSS | User input render vào HTML không qua sanitize/escape? |
| Hardcoded secret | String literal trông như key/token/password trong code? |
| Input validation | User input từ `req.body`/`req.params`/`formData` validate tại API boundary? |
| Privilege escalation | Endpoint admin kiểm tra role trước khi xử lý? |
| CSRF | Form POST/PUT/DELETE có CSRF token hoặc SameSite cookie? |
| Rate limiting | Endpoint public/auth mới có rate limit? |
| Error leakage | Error message trả client expose schema/stack trace/internal path? |

Phát hiện lỗ hổng → KHÔNG approve → gọi Codex fix với mô tả lỗ hổng cụ thể.
