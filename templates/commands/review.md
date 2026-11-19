# /review — Code Review

Một lần review độc lập cho git diff hiện tại. Agent `code-reviewer` có sẵn ở global (`~/.claude/agents/`); project có bản riêng trong `.claude/agents/` thì bản project được dùng.

## Steps

1. Chạy `git diff HEAD~1..HEAD` để lấy diff commit cuối
2. Nếu có staged changes chưa commit: `git diff --cached` thay thế
3. Diff đụng auth/middleware/api/migration/rls → review thêm security checklist: authz từng endpoint, input validation, RLS policy, secret/token không hardcode, error không leak internals
4. Chọn reviewer theo skill `orchestrating-agents` (nguồn duy nhất; không review 2 lần cùng diff):
   - Diff do worker/`builder` viết → trước khi review phải qua bước kiểm đầu vào của skill (file ngoài danh sách được phép · bằng chứng test fail rồi pass · test bị sửa/xoá/skip). Thiếu → trả lại người code, chưa review.
   - Việc LỚN mà `architect` của task đã review diff này → dùng verdict của architect (ACCEPT = APPROVE), không dispatch thêm.
   - Việc VỪA (bắt buộc, dù ai code — Codex, builder hay phiên chính), việc NHỎ đụng ghi dữ liệu / logic tiền → dispatch agent `code-reviewer` (Sonnet) với khoảng diff + mục tiêu task 1 câu + danh sách yêu cầu đánh số (hoặc đường dẫn đề bài) + điều đã quyết. Không để Codex review diff Codex viết.
   - Việc NHỎ khác → phiên chính tự đọc diff, ghi rõ "không review độc lập (việc NHỎ)".
   - Diff đụng vùng bảo mật → cần thêm verdict của `security-reviewer`; thiếu thì dispatch.
5. Hiện output APPROVE/REQUEST_CHANGES
6. Nếu REQUEST_CHANGES → list issues, hỏi user muốn fix gì trước. Sửa xong: chạy lại test/build và đọc lại đúng đoạn vừa sửa; phần sửa (do người code ban đầu sửa) đổi logic → SendMessage cho chính `code-reviewer` đó kiểm lại (không dispatch agent mới)
7. Nếu APPROVE → `mkdir -p .claude && touch .claude/.security-reviewed` (mở security gate 30 phút; file này phải nằm trong .gitignore)
