# Repo Library

Tham chiếu khi làm việc với design, domain, tools. Claude fetch khi relevant.

---

## Design — Data Sources (brand tokens, colors, typography)

| Resource | URL pattern | Brands | Dùng khi |
|---|---|---|---|
| **awesome-design-md** | `https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/[brand].md` | 73 | Build UI cho brand có sẵn |
| **open-design** | `https://raw.githubusercontent.com/nexu-io/open-design/main/design-systems/[brand]/DESIGN.md` | 150 | Tương tự, nhiều brand hơn |

Brands phổ biến: `stripe`, `linear`, `vercel`, `notion`, `airbnb`, `shopify`, `claude`, `openai`, `figma`, `github`, `discord`, `slack`.

Fetch trước khi code UI nếu brief có brand name cụ thể.

---

## Design — Process Skills

| Resource | Invoke | Dùng khi |
|---|---|---|
| **taste-skill** | `Skill("taste-skill")` | Design UI từ đầu — landing page, component, redesign |

**Kết hợp:** taste-skill (process) + open-design (data) — không conflict, complement nhau.
- taste-skill chạy trước → xác định design direction
- Nếu có brand name → fetch open-design → apply tokens vào output

---

## Domain / Hosting

| Resource | URL | Dùng khi |
|---|---|---|
| **FreeDomain** | https://domain.digitalplat.org | Đăng ký domain miễn phí (.us.kg, .eu.org...) cho project demo/test |

---

## Để Thêm Repo Mới

Append vào file này theo format trên. Claude sẽ tự biết khi nào dùng qua rule trong CLAUDE.md.
