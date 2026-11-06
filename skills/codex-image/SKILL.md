---
name: codex-image
description: Use when the user wants to generate or edit a raster image (product photo, menu/Fabi item image, poster, mockup photo, illustration, background replacement, reframing an existing photo) in any project — Claude writes the prompt, Codex creates the image with gpt-image-2.5 through Cockpit Tools, Claude checks the result. Triggers on "tạo ảnh", "sửa ảnh", "gen ảnh", "vẽ ảnh", "image gen", "imagegen", "cockpit 2.5".
---

# Codex Image — tạo/sửa ảnh qua Codex + Cockpit Tools

Claude không tự vẽ được ảnh bitmap. Việc tạo ảnh giao cho Codex: Codex dùng tool built-in `image_gen`, model `gpt-image-2.5` do app **Cockpit Tools** cung cấp. Claude giữ 3 việc: soạn prompt, gọi Codex, kiểm tra kết quả.

## 0. Điều kiện (kiểm trước, đừng đoán)

| Cần | Lệnh kiểm | Nếu hỏng |
|---|---|---|
| Cockpit Tools đang mở | `nc -z localhost 54726` | `open -a "Cockpit Tools"`, chờ 3s rồi kiểm lại; vẫn đóng thì báo user |
| Codex CLI ≥ 0.166 | `codex --version` | Dùng bản trong ChatGPT.app: `/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex`. Cả hai đều thấp → báo user chạy `npm i -g @openai/codex@latest` |
| Model ảnh | Cài trong Cockpit Tools (`gpt-image-2.5`, dự phòng `gpt-image-2`) | Không đổi từ phía Claude |

- **KHÔNG** gọi qua agent `codex:codex-rescue` hay Codex MCP: ở hai đường đó Codex báo không có `image_gen` (đã thử 2026-11-02). Chỉ `codex exec` là chạy được.
- CLI 0.141 trở xuống không có `image_gen`.

## 1. Đọc chuẩn ảnh của project (nếu có)

Trước khi viết prompt, tìm file hướng dẫn ảnh của project. Thử `grep -ril "image prompt\|IMAGE_PROMPTS\|brand" --include=*.md`, rồi đọc CLAUDE.md của project. Chuẩn của project (khung, kích thước, brand, cái gì cấm) luôn thắng mặc định dưới đây. Ví dụ project Long Cafe có lệnh `/anh` + `Menu/IMAGE_PROMPTS.md`: khi đó dùng lệnh đó.

## 2. Soạn prompt

- Viết bằng tiếng Anh, theo khối: use case → asset type → input images (Image 1 = …) → bất biến cần giữ → composition (tỉ lệ khung, % chiều cao sản phẩm, **% khoảng trống trên và dưới**, căn tâm) → ánh sáng/nền → quality control → `NO TEXT, NO WATERMARK`.
- **Sửa ảnh có sẵn** (edit): ghi rõ "Use Image 1 as the exact product. Do NOT recreate…". Liệt kê những gì phải giữ nguyên (sản phẩm, nền, đạo cụ, ánh sáng). Chỉ nêu đúng lỗi cần sửa.
- Không để AI vẽ chữ, logo, QR: chừa ô trống, user tự dán sau. Nếu bắt buộc có chữ thì ghi cứng `reading EXACTLY "..."`.
- Lưu prompt cạnh output (`<slug>-YYYYMMDD-prompt.md`) để sau này truy lại được nguồn gốc ảnh.

## 3. Gọi Codex

Tạo file lệnh cho Codex (`<slug>-YYYYMMDD-prompt-codex.txt`, file tạm) gồm:

```text
Use your built-in image_gen tool (imagegen skill, built-in mode; do NOT use the CLI script or any API key).
[Nếu có ảnh đính kèm:] The attached image is the source photo: EDIT it, do not regenerate the subject.
Create N version(s). Save/copy each result into the current directory as <slug>-YYYYMMDD-v1.png, -v2.png…
(if a name exists, use the next number). Do not create or modify any other file.
Print the absolute path of each saved file. If image_gen is unavailable, print exactly NO_IMAGE_GEN and stop.

IMAGE PROMPT:
<prompt ở bước 2>
```

Chạy nền (`run_in_background: true`, mỗi ảnh mất khoảng 1–3 phút):

```bash
codex exec --skip-git-repo-check -s workspace-write -C "<thư mục output tuyệt đối>" \
  -i "<ảnh nguồn 1>" [-i "<ảnh nguồn 2>"] - < "<file prompt-codex.txt>"
```

- `-i` đính kèm ảnh nguồn hoặc ảnh tham chiếu (nhiều ảnh thì lặp `-i`).
- Phải có `- < file` (đọc prompt từ stdin). Thiếu stdin thì exec treo ở "Reading additional input from stdin".
- Codex còn tự lưu một bản gốc vào `~/.codex/generated_images/<thread>/`.

## 4. Kiểm tra (Claude tự làm, không tin output in ra)

1. `ls` thư mục output; `sips -g pixelWidth -g pixelHeight -g hasAlpha <file>`. Mặc định Codex ra **1254×1254** RGB, không alpha.
2. Dùng Read mở ảnh kết quả và ảnh nguồn, so: sản phẩm, nền, đạo cụ, ánh sáng có giữ nguyên không (bị lệch so với nguồn là loại); kiểm khung và căn tâm theo chuẩn project.
3. Bản lỗi: thêm khối `REVISION ROUND n` lên đầu prompt, nêu lỗi cụ thể bằng số (vd "pedestal bottom only 1.5% from edge → make it 8–9%"). Đính kèm cả ảnh nguồn lẫn bản lỗi, chạy lại. Tối đa 2 vòng, sau đó báo user.
4. Xuất kích thước kênh bằng `sips` (không nhờ Codex), ví dụ `sips -s format jpeg -s formatOptions 90 -z 750 750 in.png --out out-750.jpg`. Không phóng ảnh nhỏ lên.

## 5. Báo user

Bảng gồm: bản | file | kích thước | đạt/không | lý do. Gửi ảnh cho user xem (SendUserFile). Chưa được user duyệt thì không commit, không upload lên kênh bán hàng.

## Bài học đã kiểm chứng

- Codex căn **ngang** tốt ngay lượt đầu, nhưng căn **dọc** hay sai: sản phẩm bị dồn sát mép dưới. Luôn ghi rõ % khoảng trống trên/dưới trong prompt.
- Ảnh nguồn nhỏ (750px) vẫn ra 1254px vì AI vẽ lại chứ không phóng to. Cần soi chi tiết ở cỡ lớn trước khi duyệt.
- Ảnh có chữ do AI vẽ hay sai chính tả: mặc định không để AI vẽ chữ.
