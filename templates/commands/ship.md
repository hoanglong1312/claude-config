# /ship — Pre-ship Checklist

Kiểm tra trước khi commit/báo done.

## Checklist

1. `/verify` — chạy toàn bộ tests, phải 0 FAIL
2. `git diff` — Claude review scope, không có thứ ngoài plan
3. `/review` — dispatch code-reviewer agent
4. Grep `ASSUMPTION:` trong staged/recent commits → nếu có, xác nhận với user trước
5. Check migration nếu có DB: version đã tăng chưa?
6. Diff có file/module/bảng DB mới → update map trong `context/architecture.md` + status trong `docs/plan-overview.md`
7. **Quiz-gate (người là gate):** diff đụng vùng code user chưa quen HOẶC >100 dòng → quiz user 2-3 câu về change (nó làm gì, tại sao cách này, hỏng thì hỏng ở đâu) qua AskUserQuestion. User trả lời sai/không chắc → giải thích lại (behavior flow đơn giản) rồi quiz lại. Không hiểu thì chưa merge. Diff nhỏ + vùng quen → skip, ghi rõ skip.
8. Báo cáo: ✓ pass / ✗ fail với lý do cụ thể

## Chỉ báo "sẵn sàng commit" khi tất cả ✓
