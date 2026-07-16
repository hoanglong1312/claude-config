---
name: wireframe
description: Sinh wireframe B&W dạng 1 file HTML tự chứa (user flow map + màn hình + bảng spec control) từ mô tả feature hoặc file SRS .md. Dùng khi user cần wireframe, mockup lo-fi, spec màn hình trước khi code, hoặc gõ /wireframe.
---

# Wireframe — spec-driven, 1 file HTML

Sinh wireframe lo-fi đen trắng kèm bảng spec — làm TRƯỚC khi code UI. Output là 1 file HTML tự chứa (không dependency ngoài, mở bằng browser là chạy).

## Input

1. **Có SRS/spec .md** (user đưa path, hoặc tồn tại `srs/[feature]*.md`, `docs/srs/`): đọc file đó — flow, business rule (mã `BR-*`), non-functional (mã `NFR-*`), error (mã `E-*`) lấy từ đây, KHÔNG bịa.
2. **Chỉ có mô tả miệng**: phỏng vấn gộp 1 lần (AskUserQuestion nếu có): màn hình nào, flow chính, viewport (desktop 1024px / mobile 390px). Rule chưa rõ → ghi `[ASSUMPTION]` ngay trong description, không đoán ngầm.

## Output

Path: `docs/wireframe/[feature].html` (project) hoặc user chỉ định. Một file gồm 3 phần:

### 1. Sidebar trái — điều hướng
Danh sách flow (`FLOW 1 · TÊN`, đếm số màn) → từng màn là anchor link nhảy tới section.

### 2. User flow tổng (section đầu)
Mỗi flow 1 card: tên + 1 dòng tóm tắt `happy (...) · error (...) · edge (...)` + chuỗi node màn hình nối bằng `→`, mỗi node click nhảy tới wireframe màn đó.

### 3. Mỗi màn hình — wireframe + bảng spec
- **Header**: tên feature/màn, số màn, ngày tạo/cập nhật, nguồn SRS, 1 câu mô tả flow.
- **Wireframe**: khung browser giả (3 chấm + title bar), thuần HTML/CSS đen trắng — border 1-2px, nền trắng/xám nhạt, KHÔNG màu, KHÔNG icon lib, KHÔNG font ngoài (system-ui). Control thật: input có label + placeholder + dòng validate nghiêng bên dưới, button đen chữ trắng (kèm ghi chú disabled-khi-nào in nghiêng), info box nền xám. Nhiều màn cùng flow đặt cạnh nhau nối bằng `→`, đánh số ①②.
- **Bảng "Mô tả màn hình"** (bắt buộc — giá trị chính của skill):

| # | ITEMS | CONTROL TYPE | DATA TYPE | DESCRIPTION |
|---|---|---|---|---|

  - CONTROL TYPE: Textbox / Button / Label / Link / Checkbox / Dropdown / Table…
  - DATA TYPE: Text / Click / ReadOnly / Number / Date…
  - DESCRIPTION: bắt buộc ghi — required?, validate gì, default/placeholder, disabled khi nào, submit thì chuyện gì xảy ra, error hiển thị sao. Có SRS → gắn mã (`BR-*`, `NFR-*`, `E-*`) vào cuối câu tương ứng.
  - Nhiều màn → mỗi màn 1 nhóm row có header đen `Screen N: tên`.

## Style HTML cố định

- 1 file, CSS inline trong `<style>`, JS chỉ để anchor scroll (hoặc không cần).
- Đen trắng toàn bộ: `#000`/`#fff`/xám. Font `system-ui`. Layout: sidebar fixed trái 260px, content phải.
- In được ra PDF sạch (không đổ màu nền tối).

## Sau khi sinh

1. Mở kiểm tra: `open docs/wireframe/[feature].html` (macOS).
2. Báo user: path + số flow/màn + list `[ASSUMPTION]` nếu có → user confirm rồi mới code UI theo wireframe.
3. Wireframe đã duyệt = input cho plan/Codex — link nó trong plan thay vì tả lại UI bằng chữ.

## Không làm

- Không high-fidelity, không màu brand, không CSS framework — lo-fi để bàn cấu trúc, không bàn đẹp xấu (đẹp xấu để `frontend-design` lo khi code thật).
- Không tự chế business rule ngoài SRS/câu trả lời phỏng vấn.
