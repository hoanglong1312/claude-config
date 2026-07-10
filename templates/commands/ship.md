# /ship — Pre-ship Checklist

Kiểm tra trước khi commit/báo done.

## Checklist

1. `/verify` — chạy toàn bộ tests, phải 0 FAIL
2. `git diff` — Claude review scope, không có thứ ngoài plan
3. `/review` — dispatch code-reviewer agent
4. Grep `ASSUMPTION:` trong staged/recent commits → nếu có, xác nhận với user trước
5. Check migration nếu có DB: version đã tăng chưa?
6. Báo cáo: ✓ pass / ✗ fail với lý do cụ thể

## Chỉ báo "sẵn sàng commit" khi tất cả ✓
