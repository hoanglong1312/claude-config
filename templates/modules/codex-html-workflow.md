# Module: HTML Visual Workflow (html-eff)

Opt-in. Include khi muốn plan/spec render thành HTML xem trực quan.
Core dùng `.md` thuần làm source of truth; module này thêm layer render HTML.

## Nguyên tắc
- `.md` = source of truth (spec, plan, status) — git-friendly, diffable
- `.html` = rendered view, KHÔNG edit trực tiếp — generate từ `.md` bằng `html-eff` CLI
- Claude viết `.md` content (hybrid Markdown + YAML component blocks) + chạy `html-eff` ngay sau (1 Bash command)
- Codex: code changes + update `**Status:**` field trong `plan-overview.md` + commit

## Tool Setup (nếu `html-eff` chưa có)

```bash
git clone https://github.com/luisoncpp/html-effectiveness-scripts.git ~/.local/share/html-effectiveness-scripts
cd ~/.local/share/html-effectiveness-scripts && cargo build --release
mkdir -p ~/.local/bin
ln -sf ~/.local/share/html-effectiveness-scripts/target/release/html-effectiveness ~/.local/bin/html-eff
# Thêm vào ~/.zshrc nếu chưa có: export PATH="$HOME/.local/bin:$PATH"
```

Reference gallery (20 demos): https://github.com/ThariqS/html-effectiveness

## Spec Visual (trước writing-plans)

Sau brainstorming/spec xong, Claude hỏi: "Tạo HTML visual spec không?"
Nếu Có:
1. Claude viết (hoặc convert) `docs/superpowers/specs/[spec]-design.md` sang hybrid format
2. Claude chạy: `html-eff -i docs/superpowers/specs/[spec]-design.md -o docs/superpowers/specs/[spec]-design.html`
   - Nếu html-eff lỗi: báo error ngay, KHÔNG edit .html tay
3. Claude chạy: `open docs/superpowers/specs/[spec]-design.html`
4. User review HTML, confirm rồi mới chạy writing-plans

## Plan Tracker (sau writing-plans)

Sau `writing-plans` hoàn thành:
1. Claude hỏi: "Thêm plan này vào HTML overview không?"
2. Nếu Có: Claude append section vào `docs/plan-overview.md` (hybrid format)
3. Claude chạy: `html-eff -i docs/plan-overview.md -o docs/plan-overview.html` (nếu lỗi: báo error, giữ .html cũ)
4. Claude chạy: `open docs/plan-overview.html`

Sau mỗi lần edit `.md`: Claude chạy `html-eff -i docs/plan-overview.md -o docs/plan-overview.html` để sync HTML.

## Wireframe → Mockup Process

**Thứ tự cố định khi brainstorm UI/layout:**
1. **ASCII wireframe trong chat** — chốt structure, layout, zones. Nhanh, sửa tự do trong brainstorm loop.
2. **HTML mockup** (html-eff hoặc standalone) — chỉ sau khi layout đã được approve.

Không gen HTML mockup trước khi layout ASCII đã confirmed. ASCII wireframe = lo-fi, đủ để chốt structure.
