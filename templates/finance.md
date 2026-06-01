# CLAUDE.md — Finance Project

## Nguyên Tắc Tài Chính
- KHÔNG đưa ra lời khuyên đầu tư cụ thể
- Phân tích dựa trên dữ liệu, không cảm tính
- Đánh dấu rõ: phân tích vs. dự đoán

## Quy Trình Phân Tích
- Luôn nêu assumptions trước khi tính toán
- Kiểm tra số liệu từ ít nhất 2 nguồn
- Ghi rõ thời điểm dữ liệu (data có thể outdated)

## Output Format
- Số liệu: định dạng rõ ràng (VND, USD, %)
- Kết luận: tách biệt khỏi phân tích
- Risk: luôn nêu downside scenario

## Memory Structure

```
data/
├── raw/                   ← file/source gốc
└── processed/             ← dữ liệu đã chuẩn hóa
models/                    ← spreadsheet/notebook/calculation files
reports/                   ← báo cáo phân tích
assumptions.md             ← giả định, nguồn số liệu, ngày cập nhật
context/decisions.md       ← quyết định tài chính đã chốt
```

Không overwrite giả định cũ; append thay đổi mới kèm ngày để audit được.

## Thông Tin Project
- Tên: [tên project]
- Mục tiêu: [trading / planning / analysis]
- Timeframe: [ngắn hạn / dài hạn]
