# Module: UI Design Handoff Artifacts

Opt-in. Include khi project có design UI mới / redesign / landing page / component có visual direction.

## UI Design Handoff Artifacts

Khi task là design UI mới, redesign, landing page, portfolio, hoặc component có visual direction rõ ràng, Claude/ChatGPT phải tạo đủ artifact trước khi Codex implement:

```text
UI_PREVIEW.html
UI_SPEC.md
UI_STYLE_GUIDE.md
UI_ACCEPTANCE_CHECKLIST.md
UI_DO_NOT_CHANGE.md
```

| File | Nội dung |
|---|---|
| `UI_PREVIEW.html` | Preview visual có layout thật để user xem trước. Generated/rendered artifact; không sửa tay nếu source `.md`/component có thể render lại. |
| `UI_SPEC.md` | Mục tiêu UI, user flow, layout từng màn hình, states, responsive behavior. |
| `UI_STYLE_GUIDE.md` | Màu chủ đạo, font, button/card/input sizes, spacing scale, radius, shadows, icon style. |
| `UI_ACCEPTANCE_CHECKLIST.md` | Checklist verify trước khi xong: visual, states, responsive, a11y, no regressions. |
| `UI_DO_NOT_CHANGE.md` | Codex không được tự đổi: brand colors, copy đã chốt, layout constraints, component behavior, routes/API/contracts. |

`UI_SPEC.md` phải ghi rõ: màu chủ đạo, font, kích thước button/card/input, khoảng cách giữa các khối, layout từng màn hình, trạng thái loading/error/empty, responsive, những thứ Codex không được tự ý đổi.

Codex nhận task UI phải đọc 5 file này trước khi sửa code. Nếu thiếu file hoặc mâu thuẫn, Codex ghi `ASSUMPTION:` và dừng hỏi/đợi Claude cập nhật spec.

## UI/UX Design Reference

Khi thiết kế / implement UI component hoặc cần brand style → fetch:

| Nguồn | Raw URL pattern | Số brands |
|-------|----------------|-----------|
| **awesome-design-md** | `https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/[brand].md` | 73+ |
| **open-design** | `https://raw.githubusercontent.com/nexu-io/open-design/main/design-systems/[brand]/DESIGN.md` | 150 |

Mỗi file có: color palette, typography, spacing, component styling, design tokens.
Brands phổ biến: stripe, linear, vercel, notion, airbnb, shopify, claude, openai.
