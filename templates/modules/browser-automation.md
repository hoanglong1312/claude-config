# Module: Browser Automation (Playwright / Camoufox)

Opt-in. Include cho project lái browser tương tác web thật (signup flow, OAuth, OTP, scraping...) bằng Playwright hoặc Camoufox (anti-detect Firefox).

## Reverse-Engineer UI Mới — Cấm Đoán Selector Từ Ảnh

Khác với debug bug có sẵn (xem module/rule debug riêng nếu có) — đây là case **viết flow tương tác mới** với 1 web chưa quen. Screenshot chỉ để tham khảo bố cục, **không bao giờ dùng để đoán CSS selector/DOM structure**.

**Bắt buộc theo thứ tự:**
1. `playwright codegen <url>` — tự click tay 1 lần thật trên page, để nó tự sinh selector đúng thay vì đoán.
2. Không tiện dùng codegen (page cần login/2FA/proxy phức tạp) → viết script Playwright/Camoufox thật, dùng `page.accessibility.snapshot()` hoặc `page.content()` dump DOM thật rồi mới viết selector — không suy diễn từ ảnh chụp.
3. Bug khó tái hiện / cần xem lại nhiều lần → bật `--trace on`, replay bằng Trace Viewer thay vì chạy lại live nhiều lần.
4. Trước khi build full automation, thử `page.route()`/Network tab xem có API JSON ẩn thay UI không — có thể nhanh hơn nhiều so với lái UI.
5. Test nhiều scenario/account song song → chạy Playwright/Camoufox **trực tiếp**, không qua cmux (cmux cache state, không phản ánh đúng session mới).

## Playwright vs Puppeteer

Playwright là default. Chỉ lý do đổi sang Puppeteer nếu project thật sự chỉ cần Chromium và không cần anti-detect — hiếm khi đúng cho automation dạng signup/OTP.

| | Playwright | Puppeteer |
|---|---|---|
| Engine | Chromium + Firefox + WebKit | Chỉ Chromium tốt |
| Anti-detect | Camoufox (Firefox core, patch sâu) — né Cloudflare tốt | Chromium-only lib (vd whatsapp-web.js) — dễ dính lock/corrupt profile khi kill -9 |
| Tooling debug | `codegen`, Trace Viewer, auto-wait | Yếu hơn |

## UI Bug Investigation (debug flow đã có, khác với build-mới ở trên)

Khi user báo bug UI trên flow đã build:
1. Khởi động dev server nếu chưa chạy
2. Chạy Playwright script capture: screenshot + console logs + JS errors
3. Phân tích findings → xác định root cause
4. Fix hoặc delegate

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    console_logs = []
    page.on("console", lambda msg: console_logs.append(f"[{msg.type}] {msg.text}"))
    page.on("pageerror", lambda err: console_logs.append(f"[error] {err}"))
    page.goto("http://localhost:PORT/...")
    # reproduce steps here
    page.screenshot(path="debug-screenshot.png")
    browser.close()
    print("\n".join(console_logs))
```

**Cách user báo bug chuẩn nhất:** steps to reproduce, screenshot nếu visual, console error paste (F12), không cần paste toàn bộ code.
