# Module: Frontend Web (Vite + verify + deploy)

Opt-in. Include cho frontend web project (React/Vue + Vite).

## Frontend Build Tool — Vite (standard)

Mọi frontend project mới dùng Vite. Không dùng Create React App (deprecated), không dùng Webpack trừ khi project cũ đã có.

```bash
npm create vite@latest <tên-project> -- --template react-ts
# Templates phổ biến: react-ts, vue-ts, vanilla-ts, svelte-ts
```

Vite ≠ framework. Layer: React/Vue (framework) → Vite (build tool) → Node (runtime).
Dev server mặc định: `http://localhost:5173`. Prod build: `npm run build` → `dist/`.

## UI Verification — Localhost trước, deploy sau

Với bất kỳ thay đổi UI nào, verify trên localhost trước khi deploy:

1. Chạy dev server: `npm run dev` (background)
2. `cmux browser goto http://localhost:5173` → `cmux browser snapshot`/`screenshot` → confirm visual đúng (layout, rendering)
3. Nếu task có user interaction (form submit, click, navigation, auth flow) → invoke `playwright-testing` skill → viết test → chạy → confirm pass
4. Chỉ deploy khi localhost pass

**cmux browser vs Playwright — subagent rule:**
| Tool | Dùng khi | Subagent? |
|------|----------|-----------|
| `cmux browser snapshot/eval` | Tìm lỗi (DOM, network, console) | ✅ Spawn subagent — output nặng |
| Playwright verify | Confirm fix pass | ❌ Main context — output là text |
| Playwright `--headed` debug | Playwright fail, cần xem browser | ✅ Spawn subagent — có screenshot |

**Không mở Chrome hay browser mới.** Dùng cmux in-app browser:
- `⌘⇧L` — mở browser split pane
- Agent tương tác CLI: `cmux browser <snapshot|screenshot|click|eval|goto|wait|console list|network requests|...>`

## Deploy Fallback — Vercel webhook broken

Nếu `git push origin main` không trigger Vercel auto-deploy sau 2 phút:

```bash
curl -s <production-url> | grep -o 'assets/index-[^"]*\.js'   # check bundle hash
# Nếu hash cũ → vercel --prod
```

Root cause: Vercel-GitHub webhook broken → fix bằng disconnect/reconnect GitHub integration trong Vercel dashboard.
