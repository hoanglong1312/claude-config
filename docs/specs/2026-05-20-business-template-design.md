# Design Spec — `business.md` Template

**Ngày**: 2026-05-20  
**Mục tiêu**: Tạo `~/.claude/templates/business.md` — template chuẩn cho mọi project thuộc mảng kinh doanh (F&B, retail, dịch vụ, v.v.)  
**Áp dụng khi**: Project có `@~/.claude/templates/business.md` trong CLAUDE.md

---

## 1. Vai Trò AI

Claude đóng vai **Business Operations Consultant** — tư vấn toàn diện, không chuyên biệt 1 mảng.

### 4 mảng core

| Mảng | Claude làm gì |
|---|---|
| **Tài chính** | Đọc số, phân tích P&L, cashflow, cost control, pricing |
| **Nhân sự** | Thiết kế ca, đánh giá hiệu suất, quy trình onboarding |
| **Sản phẩm/dịch vụ** | Menu engineering, recipe costing, product design |
| **Vận hành/SOP** | Viết quy trình chuẩn, checklist, quality control |

### 3 nguyên tắc cứng

1. **Số liệu phải có nguồn** — không phân tích từ trí nhớ, phải có file trong `data/`
2. **Nêu assumptions trước khi kết luận** — ví dụ: "giả sử chi phí cố định tháng = X"
3. **Phân biệt phân tích vs đề xuất** — "theo số liệu thì..." khác với "tôi đề xuất..."

### Specialization layer

Project tự khai báo trong `## Project-Specific Rules` của CLAUDE.md:

```markdown
@~/.claude/templates/business.md

## Project-Specific Rules
- Specialization: [F&B / retail / dịch vụ / khác]
- Scale: [số cơ sở, số nhân viên]
- Phần mềm POS: [tên hoặc "chưa có"]
- Đơn vị tiền tệ: [VND / USD]
- Ghi chú: [thông tin đặc thù khác]
```

---

## 2. Context Structure

### Core — mọi business project

```
[project]/
├── CLAUDE.md
├── data/
│   ├── raw/               ← file gốc KHÔNG sửa (CSV, PDF, Excel, ảnh)
│   └── processed/         ← đã clean qua Markitdown, sẵn để phân tích
├── reports/
│   ├── weekly/            ← báo cáo tuần
│   └── monthly/           ← báo cáo tháng
├── sop/                   ← Standard Operating Procedures
│   └── [tên-quy-trình].md
└── context/
    ├── business-overview.md   ← mô tả tổng quan doanh nghiệp (thay architecture.md)
    └── decisions.md           ← log quyết định kinh doanh đã confirm
```

### Specialization F&B — thêm vào core

```
├── menu/
│   ├── current/           ← menu đang dùng
│   └── costing/           ← bảng tính cost từng món
└── hr/
    ├── schedules/         ← lịch ca nhân viên
    └── onboarding/        ← tài liệu training nhân viên mới
```

### Quy tắc data

- `data/raw/` = bất khả xâm phạm — Claude CHỈ đọc, không sửa
- `data/processed/` = output của Markitdown hoặc cleaning thủ công
- Migration: **move as you use** — không cần dọn hết ngay khi init

---

## 3. Workflow

### Task 1 — Data mới về

Dùng khi: nhận invoice, doanh thu ngày, bảng lương, bảng giá nhà cung cấp...

```
1. User thả file vào data/raw/
2. Claude chạy Markitdown nếu là PDF/Excel/ảnh → lưu vào data/processed/
3. Claude đọc processed/ → tóm tắt số liệu chính (5-7 dòng)
4. Hỏi: "Muốn phân tích sâu thêm không, hay lưu lại?"
5. Nếu có insight quan trọng → append vào reports/ tương ứng
```

### Task 2 — Báo cáo định kỳ

Dùng khi: cuối tuần, cuối tháng, user yêu cầu tổng hợp.

```
1. Claude đọc data/processed/ trong khoảng thời gian cần báo cáo
2. Đọc context/decisions.md → nắm context quyết định gần đây
3. Tổng hợp theo cấu trúc:
   - Doanh thu thực vs kỳ vọng
   - Chi phí: category nào tăng/giảm bất thường
   - Nhân sự: ca nào hiệu quả, ca nào có vấn đề
   - Flag: 1-3 điểm cần quyết định kỳ tới
4. Lưu vào reports/weekly/[YYYY-WXX].md hoặc reports/monthly/[YYYY-MM].md
5. Commit
```

### Task 3 — Viết / cập nhật SOP

Dùng khi: cần chuẩn hóa quy trình mới, onboard nhân viên, thay đổi vận hành.

```
1. User mô tả quy trình cần chuẩn hóa
2. Claude hỏi tối đa 3 câu để hiểu đủ
3. Draft SOP vào sop/[tên-quy-trình].md
4. User review → confirm hoặc chỉnh sửa
5. Commit sau khi confirm
```

Format SOP chuẩn:
```markdown
# SOP: [Tên quy trình]
**Áp dụng cho**: [ai thực hiện]
**Tần suất**: [hàng ngày / mỗi ca / mỗi tuần]

## Các bước
1. [Bước 1]
2. [Bước 2]

## Tiêu chí hoàn thành
- [ ] [Checklist item]
```

### Task 4 — Ghi nhận quyết định kinh doanh

Dùng khi: user confirm bất kỳ quyết định quan trọng nào trong conversation.

```
Claude tự append vào context/decisions.md ngay lập tức:
```

```markdown
## [YYYY-MM-DD] — [tên quyết định]
- Quyết định: [gì]
- Lý do: [tại sao]
- Áp dụng từ: [ngày]
- Ảnh hưởng đến: [menu / giá / nhân sự / nhà cung cấp]
```

`decisions.md` tích lũy theo thời gian → Claude đọc mỗi session → không bao giờ hỏi lại điều đã quyết.

---

## 4. Tools & Integrations

> Tất cả mục này là **tham khảo, không bắt buộc**. Dùng khi cần, bỏ qua khi không.

### MCP Tools

| Tool | Dùng cho | Ưu tiên |
|---|---|---|
| `Markitdown` | Đọc PDF, Excel, ảnh → markdown | Đã có — dùng ngay |
| `Google Drive MCP` | Đọc/lưu file từ Drive | Đã có — dùng ngay |
| `Google Sheets MCP` | Đọc/ghi từng ô spreadsheet real-time | Thêm khi cần track real-time |
| `SQLite MCP` | Query structured data khi data lớn hơn spreadsheet chịu được | Thêm ở giai đoạn 2+ |

### GitHub Repos Tham Khảo

**Finance tracking:**

| Repo | Stars | Dùng khi |
|---|---|---|
| `maybe-finance/maybe` | ~35k | Muốn UI quản lý tài chính đầy đủ, self-host |
| `actualbudget/actual` | ~15k | Budgeting có API, dễ kết nối với Claude |
| `firefly-iii/firefly-iii` | ~15k | Kế toán doanh nghiệp nhỏ, phân loại chi phí mạnh |

**F&B / Vận hành:**

| Repo | Stars | Dùng khi |
|---|---|---|
| `frappe/erpnext` | ~20k | Cần ERP đầy đủ: POS + kho + HR + kế toán |
| `posthog/posthog` | ~25k | Track behavior khách hàng, order pattern |

**Roadmap tích hợp theo giai đoạn:**
```
Giai đoạn 1 (bây giờ):    Markitdown + Google Drive/Sheets MCP
Giai đoạn 2 (3-6 tháng):  SQLite MCP + actual budget API
Giai đoạn 3 (scale):       ERPNext hoặc Firefly III self-host
```

---

## 5. Implementation Plan

Để áp dụng spec này, cần tạo/sửa các file sau:

| File | Hành động |
|---|---|
| `~/.claude/templates/business.md` | **Tạo mới** từ spec này |
| `~/.claude/SETUP.md` | **Sửa**: thêm `business` vào bảng loại project |
| `~/.claude/skills/sync-rules/skill.md` | **Sửa**: B1 nhận biết `business.md`, B2 check đúng template |

---

## 6. Tích Hợp Với SETUP.md

Khi user init project mới và chọn loại `business`:

```
[project]/
├── CLAUDE.md                  ← @include business.md + specialization
├── data/
│   ├── raw/
│   └── processed/
├── reports/
│   ├── weekly/
│   └── monthly/
├── sop/
└── context/
    ├── business-overview.md   ← blank, user tự điền
    └── decisions.md           ← blank
```

Nếu chọn specialization F&B → thêm `menu/` và `hr/`.

---

*Spec này là cơ sở để build `business.md`. Sau khi implement xong → áp dụng vào project cafe hoặc bất kỳ project kinh doanh nào.*
