# gen-reel — Tạo HTML Composition cho Facebook Reels

Skill này nhận brief ngắn bằng tiếng Việt → xuất HyperFrames HTML composition hoàn chỉnh cho Facebook Reels (9:16).

## DEFAULTS CỐ ĐỊNH

- Resolution: `data-width="1080" data-height="1920"` (9:16 vertical)
- Duration: 15–30s (hỏi user nếu không nói)
- FPS: 30 (default HyperFrames)
- Output: MP4, không watermark
- Language: Tiếng Việt (nội dung text mặc định tiếng Việt trừ khi user chỉ định khác)
- Font: Google Fonts — `Be Vietnam Pro` (default cho tiếng Việt), fallback `sans-serif`

## BƯỚC BẮT BUỘC TRƯỚC KHI VIẾT HTML

**1. Đọc brief → xác định 4 thứ:**
- Chủ đề / sản phẩm / nội dung gì?
- Tone: hype / professional / storytelling / tutorial?
- Có asset sẵn không? (ảnh, video clip, nhạc) — nếu không có → dùng CSS gradient + text only
- Độ dài: bao nhiêu giây?

**2. Nếu thiếu thông tin quan trọng → hỏi 1 câu duy nhất, gộp tất cả vào.**

**3. Nếu đủ thông tin → bắt đầu generate ngay, không hỏi thêm.**

## STRUCTURE BẮT BUỘC

### Project layout
```
[project-name]/
├── index.html
├── compositions/
│   ├── scene-01.html   ← intro / hook (3–5s)
│   ├── scene-02.html   ← nội dung chính (chia thành nhiều scene nếu cần)
│   └── scene-last.html ← CTA / outro (3–5s)
└── assets/
    └── (user cung cấp hoặc để placeholder)
```

### index.html skeleton
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;700;900&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3/dist/gsap.min.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { width: 1080px; height: 1920px; overflow: hidden; font-family: 'Be Vietnam Pro', sans-serif; }
    [data-composition-id] { position: absolute; width: 100%; height: 100%; }
    .clip { position: absolute; }
  </style>
</head>
<body>
<div id="root"
     data-composition-id="root"
     data-start="0"
     data-width="1080"
     data-height="1920">

  <!-- Nhạc nền (optional) -->
  <!-- <audio class="clip" src="assets/bgm.mp3" data-start="0" data-duration="30" data-volume="0.25" data-track-index="0"> -->

  <!-- Scenes — dùng relative timing: scene-02 bắt đầu khi scene-01 xong -->
  <div id="s01" data-composition-id="scene-01"
       data-composition-src="compositions/scene-01.html"
       data-start="0" data-track-index="1" class="clip"></div>

  <div id="s02" data-composition-id="scene-02"
       data-composition-src="compositions/scene-02.html"
       data-start="s01" data-track-index="1" class="clip"></div>

  <!-- ... thêm scenes tương tự -->

</div>
<script>
  window.__timelines = window.__timelines || {};
  const tl = gsap.timeline({ paused: true });
  tl.set({}, {}, TOTAL_DURATION); // thay TOTAL_DURATION bằng tổng số giây
  window.__timelines["root"] = tl;
</script>
</body>
</html>
```

### Scene template chuẩn
```html
<template id="[scene-id]-template">
<div data-composition-id="[scene-id]" data-width="1080" data-height="1920">

  <!-- Layer 1 (track thấp): Nền -->
  <!-- Option A: CSS gradient -->
  <div style="position:absolute;inset:0;background:linear-gradient(180deg, #0f0f0f 0%, #1a1a2e 100%);"></div>
  <!-- Option B: ảnh -->
  <!-- <img class="clip" src="../assets/bg.jpg" data-start="0" data-duration="[X]" data-track-index="0"
       style="width:100%;height:100%;object-fit:cover;"> -->

  <!-- Layer 2: Nội dung -->
  <h1 id="[scene-id]-title" style="
    position:absolute;
    top: [Y]px; left: 0; width: 100%;
    text-align: center;
    font-size: [SIZE]px; font-weight: 900;
    color: #fff;
    opacity: 0;
  ">[TEXT]</h1>

  <style>
    [data-composition-id="[scene-id]"] { overflow: hidden; }
  </style>

  <script>
    window.__timelines = window.__timelines || {};
    const tl = gsap.timeline({ paused: true });

    // Animations
    tl.from("#[scene-id]-title", { opacity: 0, y: 80, duration: 0.7, ease: "power3.out" }, 0.2);

    // Set scene duration
    tl.set({}, {}, [DURATION]);

    window.__timelines["[scene-id]"] = tl;
  </script>
</div>
</template>
```

## RULES KỸ THUẬT BẮT BUỘC

1. **Tất cả timed elements phải có `class="clip"`** + `data-start` + `data-duration` + `data-track-index`
2. **GSAP timeline: `{ paused: true }`** — không bao giờ bỏ
3. **Register timeline:** `window.__timelines["[composition-id]"] = tl`
4. **`tl.set({}, {}, DURATION)`** để set độ dài scene — bắt buộc
5. **Video element phải `muted`** — audio đặt trong `<audio>` riêng
6. **Không dùng `Math.random()`** — không deterministic
7. **Không animate `width/height` trực tiếp trên `<video>`** — wrap trong `<div>`
8. **Không dùng `async/await` trong GSAP setup**
9. **Relative timing:** dùng `data-start="[element-id]"` để chain scenes — không hardcode giây tuyệt đối trong index.html

## VISUAL DEFAULTS CHO FACEBOOK REELS

### Typography scale
| Vai trò | Size | Weight |
|---|---|---|
| Hook / Headline | 96–120px | 900 |
| Body text | 56–72px | 700 |
| Caption / label | 36–48px | 400 |

### Animation vocabulary → GSAP ease
| Cảm giác | Ease |
|---|---|
| Snappy, năng lượng | `power4.out` |
| Smooth, tự nhiên | `power2.out` |
| Bouncy, playful | `back.out(1.7)` |
| Dramatic | `expo.out` |
| Nhẹ nhàng | `sine.inOut` |

### Safe zones (tránh bị crop khi đăng)
- Top: tránh 150px đầu (Facebook UI)
- Bottom: tránh 200px cuối (Facebook controls)
- Nội dung chính: giữa màn hình từ y=200 đến y=1720

### Màu mặc định nếu không có brand
- Nền tối: `#0f0f0f` hoặc gradient `#0f0f0f → #1a1a2e`
- Text chính: `#FFFFFF`
- Accent: `#FFD700` (vàng) hoặc `#FF6B35` (cam)

## FLOW KHI NHẬN BRIEF

```
1. Parse brief → xác định: chủ đề, tone, assets, duration
2. Quyết định số scenes (thường: 3–5 cho 15–30s)
3. Viết index.html trước — đặt scene IDs và relative timing
4. Viết từng scene HTML — mỗi file có đủ: nền + content + style + GSAP script
5. Báo lệnh chạy tiếp theo:
   npx hyperframes preview   ← xem trong browser
   npx hyperframes render    ← xuất MP4
```

## THÊM SAU KHI CÓ REFERENCE VIDEO (optional)

Khi user gửi frame từ video đối thủ:
- Phân tích layout: safe zones, font size tương đối, vị trí text
- Ghi nhận animation pattern: fade / slide / scale / bounce
- Áp dụng vào template — không copy y chang, điều chỉnh cho phù hợp

## ANTI-PATTERNS

- ❌ Hỏi nhiều câu trước khi generate — 1 câu gộp hoặc generate luôn
- ❌ Dùng React/Vue/component framework
- ❌ Quên `class="clip"` trên timed elements
- ❌ Hardcode absolute seconds cho scene chaining trong index.html
- ❌ Tạo file `.html` không có `<template>` wrapper cho sub-composition
- ❌ Bỏ `tl.set({}, {}, DURATION)` → scene duration = 0 → video bị cắt
