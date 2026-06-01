---
name: chom
description: Use when user shares a repo link, tool name, screenshot of GitHub/ProductHunt/npm, YouTube review, Twitter thread, or any promotional content about a tool/AI/SaaS — to fact-check hype vs reality and decide whether to adopt or extract patterns.
---

# Chôm — Fact-check Repo & Tool

Fact-check bài PR / link repo / tool quảng cáo → 3 phase cố định: R&D thật-giả → Đánh giá → Quyết định áp dụng.

## NGUYÊN TẮC CỨNG

| # | Rule |
|---|------|
| 1 | KHÔNG tin caption bài PR — luôn cross-check reality |
| 2 | KHÔNG khen nếu chưa verify thực tế |
| 3 | KHÔNG đề xuất down nếu chưa nêu vấn đề cụ thể cần giải quyết |
| 4 | Khi Phase 3a borderline (MAYBE) → default NO + chôm pattern thay vì YES |
| 5 | Phase 1 luôn chạy kể cả source uy tín |
| 6 | Tool budget Phase 1: tối đa 2 call (web_search + 1 web_fetch) |
| 7 | Flag "sơ bộ" khi thiếu data (private repo, paywall, PDF) — không bịa verdict |
| 8 | Không reply trong 1 turn → dùng default AI engineer, ghi assumption |

---

## BƯỚC 0 — CONTEXT CHECK (chạy TRƯỚC Phase 1)

Nếu user chưa nêu ngữ cảnh doanh nghiệp:

> "Tao apply theo context AI engineer (build tools / workflow AI). Đúng không, hay mày muốn adjust theo ngành khác?"

- User confirm hoặc không reply → dùng AI engineer, ghi: `[Assumption: context = AI engineer]`
- User nêu ngành khác → adjust toàn bộ 3 phase theo context đó

---

## DETECT INPUT

| Dạng | Hành động |
|------|-----------|
| Link GitHub repo | web_search tên repo → web_fetch README |
| Link non-GitHub (npm, ProductHunt, PyPI, HuggingFace) | web_search tên tool → web_fetch landing/doc |
| Tên repo không link (`owner/repo`) | web_search `"{owner}/{repo}"` |
| Ảnh screenshot repo/PR | view ảnh → tách URL/tên → web_search |
| Bài text + caption hype (không link) | Phân tích claim trong text → web_search tên tool |
| Paywall / tool thương mại | web_search reviews + alternatives, flag "không fetch được nội dung trả phí" |
| YouTube review / Twitter thread | web_search tên tool → xử lý như bài PR text |
| GitHub profile link | Flag "đây là link profile. Mày muốn check repo nào của họ?" |
| PDF upload | Flag "không đọc được PDF. Copy paste nội dung hoặc share link repo" |
| Nhiều link cùng lúc | "Tao handle 1 link mỗi lần. Mày muốn bắt đầu với cái nào?" → sau khi xong hỏi tiếp: "Còn [link kế]. Tao check không?" |
| Không rõ input | Hỏi 1 câu: "Mày muốn tao check tool/repo nào — link hoặc tên?" |

---

## PHASE 0.5 — TÓM TẮT "ĐÂY LÀ GÌ" (chạy sau Bước 0, trước Phase 1)

Trước khi fact-check, giải thích repo/tool bằng ngôn ngữ đơn giản:

```
📦 [Tên repo]
Làm gì: [1 câu, không dùng jargon]
Dùng cho ai: [developer / non-tech / AI engineer / ...]
Cách hoạt động: [2-3 câu mô tả cơ chế thực tế]
So sánh gần nhất: [tool/concept quen thuộc] — nhưng [điểm khác biệt chính]
```

**Quy tắc:**
- Không copy description từ README — diễn giải lại bằng lời thật
- Nếu tool phức tạp → dùng analogy ("giống X nhưng Y")
- Tối đa 5 dòng — nếu cần dài hơn → tool đó quá phức tạp để tóm tắt ngắn, flag rõ

---

## PHASE 1 — R&D (tối đa 2 tool call)

Fact-check 4 nhóm:

1. **Còn sống?** — Recent commit, stars, contributors, issues ratio
2. **Claim "shock" vs reality** — đối chiếu từng câu hype với fact
3. **License + dependency** — Apache/MIT ok, GPL cẩn thận, 0 license = red flag
4. **Red flag** — Abandon >6 tháng, 0 issues (suspicious), 1 maintainer duy nhất, security warning

**Verdict:**
```
Hype X% / Thật Y%

Bài viết NÓI SAI: [dẫn chứng cụ thể]
Bài viết NÓI ĐÚNG: [dẫn chứng cụ thể]
```

> **Nếu verdict sơ bộ** (paywall, private repo, repo quá lớn): ghi rõ `[Sơ bộ — thiếu data: lý do]`. Success criteria #2 exempt. Budget Phase 1 vẫn giữ 1-2 call.
>
> **Nếu không có claim verifiable** (blog thuần architecture): bỏ NÓI SAI, chỉ NÓI ĐÚNG + flag "không đủ dữ liệu fact-check claim".

---

## PHASE 2 — ĐÁNH GIÁ KHÁCH QUAN

| ✅ Điểm mạnh thực | ⚠️ Điểm yếu / Điều kiện cần |
|---|---|
| [3-5 dòng] | [3-5 dòng] |

**Trust level:**

| Level | Tiêu chí |
|---|---|
| 🟢 Official big-tech | Anthropic, OpenAI, Google, Microsoft — repo chính thức |
| 🟡 Top dev uy tín | >1k stars, active issue response, known maintainer/org |
| 🟠 Cộng đồng mid-tier | <1k stars hoặc ít contributor, activity bình thường |
| 🔴 Random chưa verify | Mới tạo, 0 issue, 1 maintainer, không có track record |

**Điều kiện cần tối thiểu:** Platform + SaaS phụ thuộc + Skill kỹ thuật

---

## PHASE 3 — ÁP DỤNG

### 3a. Có nên down về test? [YES / NO / MAYBE]

**MAYBE** = data không đủ để kết luận → mô tả rõ thiếu gì, cần làm gì để kết luận.

Nếu **YES** → lộ trình 3-5 bước:
```
1. Vấn đề đang gặp: [cụ thể]
2. Đang xử lý như thế nào: [tool hiện tại hoặc "thủ công, chưa có tool"]
3. Gap mà tool này có thể lấp: [cụ thể]
4. Test: [platform + 1 use case + thời gian]
5. KPI: [đo gì] — Sau [X ngày]: giữ / bỏ
```

Nếu **NO** → 2-3 câu lý do cụ thể.

### 3b. Không down — chôm gì? (luôn chạy, kể cả khi 3a = YES)

| Loại | Cụ thể | Bỏ vào đâu |
|------|--------|------------|
| Pattern/kiến trúc | [tên pattern cụ thể] | CLAUDE.md / skills / KB |
| File mẫu | [tên file fork được] | Customize → sửa thành phiên bản VN |
| Workflow/SOP | [cụ thể] | Bổ sung CI hoặc KB |

---

## EDGE CASES

| Tình huống | Xử lý |
|---|---|
| Link 404 / private | Flag, dừng, không bịa |
| Official source (Anthropic, OpenAI) | Vẫn đủ 3 phase, Trust 🟢 nhưng không miễn Phase 1 |
| Paywall / tool thương mại | web_search reviews thay vì fetch; verdict sơ bộ nếu không đủ data |
| Repo quá lớn (kubernetes) | Budget vẫn 1-2 call. Verdict sơ bộ, flag rõ; success criteria #2 exempt |
| Bài PR blog không có repo | Fact-check claim, Phase 2-3 phân tích pattern |

---

## ANTI-PATTERNS

- ❌ Khen repo dựa caption chưa fetch README
- ❌ Đề xuất "down thử xem" không có vấn đề cụ thể
- ❌ Dump >2 tool call Phase 1
- ❌ Bỏ qua Phase 1 vì source uy tín
- ❌ Output dài >2 màn hình mobile
- ❌ Bịa verdict khi data thiếu — flag "sơ bộ" thay vì confidence giả
- ❌ Bỏ qua 3b vì 3a = YES — 3b luôn chạy

---

## SUCCESS CRITERIA

1. User đọc xong <2 phút, biết rõ "down hay không" — không lửng lơ
2. Verdict có ≥2 điểm "bài viết nói sai" có dẫn chứng *(exempt nếu verdict sơ bộ hoặc không có verifiable claim)*
3. Phase 3a YES → lộ trình ≥3 bước + 1 KPI đo được
4. Phase 3b → ≥1 pattern cụ thể + "bỏ vào đâu" rõ ràng
5. Không vượt tool budget Phase 1
