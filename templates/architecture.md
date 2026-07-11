# Architecture — [tên project]

Updated: [YYYY-MM-DD] — update file này khi thêm module / đổi flow chính / thêm bảng DB. KHÔNG ghi tiến độ ở đây (tiến độ → `docs/plan-overview.md`).

## Session mới — đọc theo thứ tự này, đừng đoán mò

1. `docs/plan-overview.md` — đang làm gì, task nào dở, task nào xong
2. `docs/superpowers/decisions.md` — quyết định đã chốt (không hỏi lại, không làm ngược)
3. File này — map codebase bên dưới
4. Cần sâu hơn → GitNexus `query({search_query})` (project đã index), KHÔNG grep lan man

## Stack & entry points

- Stack: [Vite + React + Supabase / ...]
- Entry: [src/main.tsx → App.tsx → router định nghĩa ở src/routes.tsx]
- Chạy dev: [npm run dev — port 5173]
- Env: [.env — các key bắt buộc: SUPABASE_URL, ...]

## Map feature → files

| Feature / Module | Files chính | DB tables / external | Ghi chú |
|---|---|---|---|
| [Auth] | [src/auth/*, src/middleware/auth.ts] | [users, RLS: policies/auth.sql] | [session lưu localStorage] |
| [Menu quản lý] | [src/features/menu/*] | [menu_items, categories] | |
| [...] | | | |

## Data flow chính (mô tả hành vi, không tên hàm)

```
→ Khi [user làm gì]
   1. [component nào] nhận → gọi [api/service nào]
   2. Data lưu vào [bảng nào] / state ở [đâu]
   3. User thấy [kết quả gì]
```

(1 block cho mỗi flow quan trọng: login, thanh toán, CRUD chính...)

## Quirks & bẫy đã biết

- [VD: build fail nếu thiếu env X — check trước]
- [VD: bảng orders có trigger tự tính total — đừng update tay]
