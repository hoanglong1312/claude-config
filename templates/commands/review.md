# /review — Code Review

Dispatch `.claude/agents/code-reviewer` để review git diff hiện tại.

## Steps

1. Chạy `git diff HEAD~1..HEAD` để lấy diff commit cuối
2. Nếu có staged changes chưa commit: `git diff --cached` thay thế
3. Diff đụng auth/middleware/api/migration/rls → review thêm security checklist: authz từng endpoint, input validation, RLS policy, secret/token không hardcode, error không leak internals
4. Dispatch agent `code-reviewer` với diff + context task hiện tại
5. Hiện output APPROVE/REQUEST_CHANGES
6. Nếu REQUEST_CHANGES → list issues, hỏi user muốn fix gì trước
7. Nếu APPROVE → `mkdir -p .claude && touch .claude/.security-reviewed` (mở security gate 30 phút; file này phải nằm trong .gitignore)
