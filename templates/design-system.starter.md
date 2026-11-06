# Design System — [Tên project]

> Mẫu khởi đầu, sửa tự do. Chỉ giữ thứ dùng chung cho mọi màn; quyết định riêng từng màn để file khác.
> Version: v1.0 | Cập nhật: YYYY-MM-DD

## Tính cách (design language)

[1–3 câu: giao diện cho ai, cảm giác gì, cấm gì — vd không gradient, không ảnh trang trí.]

## Tokens

| Vai trò | Biến | Giá trị |
|---|---|---|
| Nền | `--color-bg` | |
| Bề mặt | `--color-surface` | |
| Chữ chính | `--color-text` | |
| Chữ phụ | `--color-text-muted` | |
| Viền | `--color-border` | |
| Nhấn | `--color-accent` | |

**Chữ:** font tiêu đề / nội dung / số; cỡ display, headline, body, label.
**Khoảng cách:** nhịp (vd 4px); lề desktop / mobile. **Bo góc:** sm / md / khung. **Bóng:** dùng ở đâu.

## Màu trạng thái

| Ý nghĩa | Chữ | Nền | Viền |
|---|---|---|---|
| Ổn / xong | | | |
| Cần chú ý | | | |
| Lỗi | | | |

Trạng thái luôn kèm chữ, không chỉ dựa vào màu.

## Thành phần chung (component contract)

| Thành phần | Quy tắc | Code |
|---|---|---|
| Button | | `src/ui/Button` |
| Input / Select | | |
| Table | | |
| Chip trạng thái | | |
| Loading / Empty / Error | | |

**Tương tác:** hover, pressed, focus-visible, reduced-motion.

## Code ở đâu

- Component library: `[thư mục]` — mọi màn import từ đây, không viết lại.
- Token khai báo ở: `[file CSS/theme]`.
- Trang mẫu trực quan (nếu có): `[đường dẫn]`.

## Định dạng dữ liệu

[Tiền, ngày giờ, đơn vị, trạng thái "chưa có dữ liệu".]
