---
name: init
description: Init project mới hoặc mở rộng project hiện tại — scaffold, template, component library
---

# Project Init / Extend

## Bước 0 — Xác định mode

**Init mới / mở rộng project:** hỏi loại project đầu tiên.

> "Project này thuộc loại nào: code / research / finance / personal / business?"

Loại project quyết định skeleton, template, tools cần check.

**Audit / sync project hiện tại:** auto-detect loại project trước từ deps + `CLAUDE.md`; chỉ hỏi nếu không detect được hoặc conflict.

**Global maintenance:** khi user explicit nhắc `~/.claude`, global Claude, templates, skills, hoặc settings — được đọc/sửa `~/.claude` sau khi báo scope. Không commit nếu user chưa yêu cầu.

---

## Auto-detect mode

```bash
[ -f "CLAUDE.md" ] || [ -f ".claude/CLAUDE.md" ]
```

- User nói init/setup project mới và không tìm thấy `CLAUDE.md` → chạy **PHẦN 1: Init mới**
- User nói mở rộng project hoặc tìm thấy `CLAUDE.md` → chạy **PHẦN 2: Mở rộng**
- User nói sync/audit rules → chạy **PHẦN 3: Audit / Sync Rules Project Hiện Tại**
- User nói global/`~/.claude` maintenance → chạy **PHẦN 4: Global Maintenance**

---

## PHẦN 1: Init Mới

### Bước 1 — Audit project có sẵn code

Nếu project có `package.json`, `*.py`, `*.go`:

1. Đọc file deps → detect stack
2. Kiểm tra gaps:

| Kiểm tra | Kết quả |
|----------|---------|
| `CLAUDE.md` | có / chưa → sẽ tạo |
| `CLAUDE.local.md` | có / chưa → tạo + gitignore |
| `.gitignore` | có / chưa → tạo hoặc append |
| `.mcp.json` | có / chưa → hỏi |
| `rules/` | có / chưa → sẽ tạo (trống) |
| `context/architecture.md` | có / chưa → tạo blank |

3. Báo cáo + xác nhận 1 lần → tạo hết.

Nếu project trống → Bước 2.

---

### Bước 2 — Skeleton theo loại

**Personal / Research / Finance:**
```
[project]/
├── CLAUDE.md              ← @include template tương ứng
├── CLAUDE.local.md        ← gitignored
└── .gitignore
```

CLAUDE.md:
```
@~/.claude/templates/[personal|research|finance].md

## Project-Specific Rules
[thêm nếu cần]
```

---

**Business:**
```
[project]/
├── CLAUDE.md
├── CLAUDE.local.md
├── .gitignore
├── data/
│   ├── raw/
│   └── processed/
├── reports/
│   ├── weekly/
│   └── monthly/
├── sop/
└── context/
    ├── business-overview.md
    └── decisions.md
```

F&B thêm: `menu/current/`, `menu/costing/`, `hr/schedules/`, `hr/onboarding/`

CLAUDE.md:
```
@~/.claude/templates/business.md

## Project-Specific Rules
- Specialization: [F&B / retail / dịch vụ / khác]
- Scale: [số cơ sở, số nhân viên]
- Phần mềm POS: [tên hoặc "chưa có"]
- Đơn vị tiền tệ: VND
```

---

**Code:**
```
[project]/
├── CLAUDE.md
├── CLAUDE.local.md
├── .gitignore
├── .mcp.json
├── AGENTS.md              ← chỉ tạo nếu user dùng Codex (xác nhận ở Bước 3e)
├── rules/                 ← project-specific tool/path rules
├── .claude/
│   ├── settings.json      ← project Claude Code settings only
│   └── commands/          ← /review /verify /ship (xác nhận ở Bước 3j)
├── context/
│   └── architecture.md
└── docs/superpowers/
    ├── specs/
    └── decisions.md       ← pre-created blank
```

CLAUDE.md:
```
@~/.claude/templates/code-project.md
@~/.claude/templates/modules/[module].md   ← chỉ module được chọn ở Bước 3h
@context/architecture.md

## Thông Tin Project
- Tên: [điền]
- Git repo: [điền hoặc N/A]
- Tech stack: [điền]
- Mục tiêu: [điền]

## Project-Specific Rules
```

Thứ tự @include bắt buộc: `code-project.md` (CORE) → `modules/*` → `rules/*` → `context/`. Rules project-specific @include thêm khi cần.

`.gitignore` tối thiểu:
```
CLAUDE.local.md
.claude/settings.local.json
.env
*.local.*
```

---

### Bước 3 — Kiểm tra tools universal (MỌI loại project)

Check trước, chỉ hỏi install khi chưa có:

**3a. Superpowers:**
```bash
# Claude Code: /plugin list → tìm superpowers
# Nếu chưa → hỏi: "Muốn cài Superpowers không?"
#              → /plugin install superpowers@latest
```

**3b. RTK — Rust Token Killer:**
```bash
rtk --version 2>/dev/null && echo "installed" || echo "missing"
# Nếu missing → hỏi: "Muốn cài RTK không?"
#               → hướng dẫn user xem ~/.claude/README.md
```

**3c. Markitdown:**
```bash
markitdown --version 2>/dev/null && echo "installed" || echo "missing"
# Nếu missing → hỏi: "Muốn cài Markitdown không?"
#               → pip install markitdown
```

**3d. Caveman mode:**
> Không detect được tự động. Hỏi 1 lần: "Muốn bật Caveman mode không? Claude trả lời ngắn hơn. Bật: `/caveman full`. Tắt: `stop caveman`."

**3e. Codex plugin (CHỈ hỏi nếu là code project):**
```bash
# Claude Code: /plugin list → tìm codex@openai-codex
# Nếu chưa → hỏi: "Dự án này dùng Codex không?"
#   Có → /plugin install codex@openai-codex && /codex:setup
#   Không → bỏ qua AGENTS.md ở Bước 2
```

**3g. Project permissions (CHỈ cho code project):**

Detect stack từ deps, map sang permissions cần thiết, hỏi trước khi ghi:

```bash
cat package.json 2>/dev/null | jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' 2>/dev/null
```

| Phát hiện | Permissions gợi ý |
|---|---|
| `next` / `vite` / `react-scripts` | `Bash(npm run build*)`, `Bash(npm run dev*)`, `Bash(npm run test*)` |
| `typescript` / `ts-node` | `Bash(npx tsc*)` |
| `playwright` / `@playwright/test` | `Bash(npx playwright*)` |
| `vitest` / `jest` | `Bash(npm run test*)` |
| `supabase-js` / `@supabase/*` | `Bash(npx supabase*)` |
| `vercel` trong scripts hoặc `.vercel/` tồn tại | `Bash(vercel*)` |
| `axios` / `node-fetch` / `got` trong code | `Bash(curl*)` |
| `python` / `pyproject.toml` | `Bash(python*)`, `Bash(pip*)`, `Bash(uv*)` |
| `docker-compose.yml` / `Dockerfile` | `Bash(docker*)` |

Sau khi detect xong, hiện list gợi ý:
```
Project permissions cần thêm vào .claude/settings.json:
  ✓ Bash(npm run build*)  — từ next/vite
  ✓ Bash(npm run dev*)    — từ next/vite
  ✓ Bash(npx tsc*)        — từ typescript
  ✓ Bash(npx playwright*) — từ playwright

Thêm vào .claude/settings.json không? [y/n/chỉnh sửa]
```

Chỉ ghi khi user confirm. Format ghi:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run build*)",
      "Bash(npm run dev*)",
      "Bash(npm run test*)"
    ],
    "defaultMode": "auto"
  }
}
```

Nếu `.claude/settings.json` đã tồn tại → merge `permissions.allow` array, không replace toàn bộ file. Validate JSON sau khi ghi: `jq empty .claude/settings.json`.

---

**3f. Skills per-project type (CHỈ cho code project):**

Detect stack từ deps, recommend skills chưa có trong `~/.claude/skills/` hoặc plugins:

```bash
# Check deps
cat package.json 2>/dev/null | grep -E '"dependencies"|"devDependencies"' -A 50
```

| Phát hiện trong deps | Skill recommend | Install |
|---|---|---|
| `react` + `tailwind` | `frontend-design` | `claude skill install frontend-design@anthropics` |
| `@shadcn/ui` hoặc `shadcn` | `shadcn/ui` | `claude skill install shadcn@shadcn` |
| `playwright` / `@playwright/test` | `webapp-testing` | `claude skill install webapp-testing@anthropics` |
| `next` / `nuxt` / `vite` | `web-artifacts-builder` | `claude skill install web-artifacts-builder@anthropics` |
| `.github/workflows` tồn tại | `ci-cd-pipeline-builder` | `claude skill install ci-cd-pipeline-builder@alirezarezvani` |
| `@modelcontextprotocol` / `mcp` | `mcp-builder` | `claude skill install mcp-builder@anthropics` |

Nếu detect được match → hỏi 1 lần gộp:
> "Phát hiện [X, Y]. Cài skills: `frontend-design`, `webapp-testing`? (y/n)"

Chỉ cài khi user confirm. Không cài tự động.

---

**3j. Slash commands chuẩn (CHỈ cho code project):**

Hỏi 1 lần: "Tạo 3 slash commands `/review`, `/verify`, `/ship` không?"

Nếu có → tạo trong `.claude/commands/` (xem template ở Component Templates):
- `review.md` — dispatch code-reviewer trên diff hiện tại
- `verify.md` — chạy test suite của project
- `ship.md` — pre-ship checklist: verify → review → check

Nếu project đã có test runner riêng (pytest / vitest / go test...) → hỏi trước để điền đúng lệnh vào `verify.md`.

---

**3h. Module opt-in cho code-project (CHỈ code project dùng Codex flow):**

`code-project.md` là CORE always-on. Phần optional nằm trong `~/.claude/templates/modules/`. Auto-detect từ deps → đề xuất module, hỏi 1 lần gộp, chỉ `@include` cái được chọn:

| Phát hiện trong deps/repo | Module đề xuất |
|---|---|
| `@supabase/*` / migration files | `db-supabase.md` |
| `next`/`vite`/`react`/`vue` (frontend) | `frontend-web.md` |
| Có `**/api/**`, `**/auth/**`, route nhận user input | `web-security.md` |
| Task design UI / landing / redesign (hỏi user) | `ui-design-handoff.md` |
| User muốn plan/spec render HTML (hỏi user) | `codex-html-workflow.md` |

Hỏi gộp:
```
Code project core đã include. Module opt-in (detect từ stack):
  [x] db-supabase    — phát hiện @supabase
  [x] frontend-web   — phát hiện vite
  [ ] web-security   — bật nếu có API/auth
  [ ] ui-design-handoff
  [ ] codex-html-workflow
Include module nào? (mặc định = các dòng [x])
```

Module được chọn → thêm dòng `@~/.claude/templates/modules/[name].md` vào CLAUDE.md, giữ thứ tự core → modules → rules → context.

---

**3i. Statusline với usage + model (global, mọi loại project):**

Check xem `~/.claude/settings.json` đã có `statusLine` chưa và script nào đang dùng:

```bash
cat ~/.claude/settings.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('statusLine', 'NOT SET'))"
ls ~/.claude/hooks/statusline.sh 2>/dev/null && echo "exists" || echo "missing"
```

**Nếu `statusline.sh` tồn tại nhưng settings dùng `caveman-statusline.sh`:**
→ Switch sang `statusline.sh` — nó đã có model + rate limits bar + caveman badge:

```json
"statusLine": {
  "type": "command",
  "command": "bash \"/Users/<user>/.claude/hooks/statusline.sh\""
}
```

**Nếu `statusline.sh` chưa có** → tạo tại `~/.claude/hooks/statusline.sh`:

```bash
#!/bin/bash
# Combined statusline: model + rate limits (or context) + caveman badge
# Receives Claude Code session JSON via stdin

input=$(cat)

bar() {
  local pct="${1:-0}" width=15 filled empty i out=""
  filled=$(( pct * width / 100 ))
  [ $filled -gt $width ] && filled=$width
  empty=$(( width - filled ))
  for ((i=0; i<filled; i++)); do out+="█"; done
  for ((i=0; i<empty; i++)); do out+="░"; done
  printf '%s' "$out"
}

fmt_reset() {
  local ts="$1"
  [ -z "$ts" ] && return
  local today reset_date
  today=$(TZ="Asia/Ho_Chi_Minh" date "+%Y-%m-%d")
  reset_date=$(TZ="Asia/Ho_Chi_Minh" date -r "$ts" "+%Y-%m-%d" 2>/dev/null)
  if [ "$reset_date" = "$today" ]; then
    TZ="Asia/Ho_Chi_Minh" date -r "$ts" "+%-I%p" 2>/dev/null | sed 's/AM/am/; s/PM/pm/'
  else
    TZ="Asia/Ho_Chi_Minh" date -r "$ts" "+%b %-d %-I%p" 2>/dev/null | sed 's/AM/am/; s/PM/pm/'
  fi
}

model=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
if [ -z "$model" ]; then
  model="${CLAUDE_MODEL:-}"
  [ -n "$model" ] && model=$(printf '%s' "$model" | sed 's/^us\.anthropic\.//' | sed 's/^claude-//')
fi

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
reset_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
reset_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)

out=()
[ -n "$model" ] && out+=("🤖 $model")

if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  reset_str=$(fmt_reset "$reset_5h")
  entry="⏱ $(bar $five_int) ${five_int}%"
  [ -n "$reset_str" ] && entry+=" → ${reset_str}"
  out+=("$entry")
fi

if [ -n "$seven_pct" ]; then
  seven_int=$(printf '%.0f' "$seven_pct")
  reset_str=$(fmt_reset "$reset_7d")
  entry="📅 $(bar $seven_int) ${seven_int}%"
  [ -n "$reset_str" ] && entry+=" → ${reset_str}"
  out+=("$entry")
fi

if [ -z "$five_pct" ] && [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
  [ "$ctx_int" -gt 0 ] && out+=("💬 ctx $(bar $ctx_int) ${ctx_int}%")
fi

FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
[ ! -L "$FLAG" ] && [ -f "$FLAG" ] && {
  MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr -cd 'a-z0-9-')
  case "$MODE" in
    off|lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      if [ -z "$MODE" ] || [ "$MODE" = "full" ]; then out+=("🪨 CAVEMAN")
      else out+=("🪨 CAVEMAN:$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')")
      fi ;;
  esac
}

[ ${#out[@]} -eq 0 ] && exit 0
printf '%s' "${out[0]}"
for ((i=1; i<${#out[@]}; i++)); do printf ' | %s' "${out[i]}"; done
printf '\n'
```

Sau khi ghi → `chmod +x ~/.claude/hooks/statusline.sh` → restart Claude Code.

**Timezone:** script dùng `Asia/Ho_Chi_Minh`. Đổi theo timezone user nếu khác.

---

### Bước 4 — One-time setup (CHỈ cho code project)

**4a. Tạo `docs/superpowers/decisions.md`:**

```bash
mkdir -p docs/superpowers/specs
touch docs/superpowers/decisions.md
```

**4b. Điền thông tin project:**

Auto-detect trước, hỏi chỉ khi không detect được:

```
1. "Tên project là gì?"
2. "Mục tiêu chính? (1-2 câu)"
3. "Tech stack?" → detect từ package.json / requirements.txt / go.mod trước
4. "Git remote URL?" (tùy chọn)
```

Với project có sẵn code: đọc deps → auto-fill stack; đọc README nếu có → gợi ý mục tiêu → hỏi user confirm.

Điền vào 2 nơi:

**CLAUDE.md** — section `## Thông Tin Project` (Claude đọc → behavior):
```markdown
## Thông Tin Project
- Tên: [điền]
- Git repo: [điền hoặc N/A]
- Tech stack: [điền]
- Mục tiêu: [điền]
```

**AGENTS.md** — CHỈ nếu user dùng Codex. Render/materialize từ shared rules + template body; không để `@include` vì Codex có thể không expand.

Nguồn:
```text
~/.claude/templates/shared-agent-rules.md
~/.claude/templates/AGENTS.md
```

Section `## Project Context` cần điền:
```markdown
## Project Context
- **Tên**: [điền]
- **Type**: code / multi-agent
- **Stack**: [điền]
- **Mục tiêu**: [điền]
```

Marker bắt buộc trong project `AGENTS.md`:
```markdown
<!-- generated-from: shared-agent-rules.md + templates/AGENTS.md -->
<!-- shared-rules: YYYY-MM-DD -->
<!-- template: YYYY-MM-DD -->
```

Khi sync, so sánh marker với source hiện tại; nếu outdated → báo diff và hỏi user trước khi regenerate/merge.

Render command mẫu:
```bash
{
  cat ~/.claude/templates/shared-agent-rules.md
  printf '\n---\n\n'
  cat ~/.claude/templates/AGENTS.md
} > AGENTS.md
```

**4c. Git repo (CHỈ cho code project):**

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

Nếu không phải git repo:
1. Hỏi: "Tạo git repo local + baseline commit không? Recommended để Codex/worktree/commit workflow chạy đúng."
2. Nếu Có:
   ```bash
   git init
   git add CLAUDE.md CLAUDE.local.md .gitignore AGENTS.md .claude context docs assets reels studio skills-lock.json 2>/dev/null
   git commit -m "chore: initialize project baseline"
   ```

Nếu đã là git repo:
- Báo branch hiện tại + working tree status.
- Không commit tự động trừ khi user yêu cầu.

---

**4d. Offer `setup.sh` (opt-in — KHÁC layer với init):**

`init` = AI context layer (CLAUDE.md/AGENTS.md). `setup.sh` = runtime/dev layer (venv, deps, binary, .env) cho human/CI re-run. Hai thứ orthogonal — KHÔNG thay nhau.

Chỉ **đề xuất** tạo `setup.sh` khi stack cần provisioning >1 bước:

| Cần setup.sh | Không cần (đủ với README) |
|---|---|
| Python venv + deps + binary download (Camoufox, model...) | `npm install` thuần |
| Nhiều bước env (.env scaffold, GeoIP, migrate DB) | 1 lệnh install duy nhất |
| Pin Python/Node version cụ thể | Dùng version mặc định |

Nếu cần → hỏi: *"Stack này nhiều bước setup. Tạo `setup.sh` idempotent (check trước → skip nếu có → fail-fast version) không?"*

Skeleton khi user OK (3 nguyên tắc: `set -euo pipefail` fail-fast, check-before-create idempotent, không leak ra ngoài project dir):
```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"; cd "$ROOT_DIR"

# version guard (sửa theo stack)
command -v node >/dev/null || { echo "ERROR: cần Node" >&2; exit 1; }

# idempotent deps
[ -d node_modules ] || npm install

# .env scaffold nếu chưa có
[ -f .env ] || cp .env.example .env 2>/dev/null || true

echo "✓ setup done"
```

Không ép — project đơn giản bỏ qua bước này.

---

### Bước 5 — Báo xong

---

## PHẦN 2: Mở Rộng Project Hiện Tại

Detect cấu trúc hiện tại trước:

```bash
ls .claude/hooks/ .claude/agents/ .claude/commands/ 2>/dev/null
```

Báo: "Project đã có: [X]. Muốn thêm gì?" — User nói → tạo tương ứng.

**Hooks** (thêm khi user muốn tự động hóa):

| Hook | Tác dụng | File |
|---|---|---|
| PostToolUse | Auto-commit sau Edit/Write | `.claude/hooks/PostToolUse.sh` |
| SessionStart | Show stats khi mở session | `.claude/hooks/SessionStart.sh` |
| PreCompact | Lưu git status trước context compact | `.claude/hooks/PreCompact.sh` |

Hooks phải đăng ký trong `.claude/settings.json`.

**Các component khác** (tạo khi project thực sự cần):

| User muốn | Component |
|---|---|
| Sub-agent review code | `.claude/agents/code-reviewer.md` |
| Sub-agent tìm web | `.claude/agents/researcher.md` |
| /ship, /test command | `.claude/commands/[name].md` |
| Rules cho Supabase | `rules/supabase.md` |
| Rules cho testing | `rules/testing.md` |
| Rules cho API layer | `rules/api.md` (path-scoped) |
| MCP server mới | `.mcp.json` |

---

## Component Templates

### `.claude/hooks/SessionStart.sh`

```bash
#!/bin/bash
if [ -f "docs/superpowers/decisions.md" ]; then
  echo "decisions.md: $(wc -l < docs/superpowers/decisions.md) entries"
fi
SPEC_COUNT=$(ls docs/superpowers/specs/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$SPEC_COUNT" -gt 0 ] && echo "Active specs: $SPEC_COUNT"
```

### `.claude/hooks/PostToolUse.sh`

```bash
#!/bin/bash
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "auto: $(git diff --cached --name-only | head -3 | tr '\n' ' ')" 2>/dev/null
  fi
fi
```

### `.claude/hooks/PreCompact.sh`

```bash
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
TODO_FILE=".claude/pre-compact-state-$TIMESTAMP.md"
echo "# Pre-compact state: $TIMESTAMP" > "$TODO_FILE"
echo "## Git status" >> "$TODO_FILE"
git status --short >> "$TODO_FILE" 2>/dev/null
echo "## Recent commits" >> "$TODO_FILE"
git log --oneline -5 >> "$TODO_FILE" 2>/dev/null
echo "State saved: $TODO_FILE"
```

Hook registration trong `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [{"hooks": [{"type": "command", "command": "bash .claude/hooks/PostToolUse.sh"}]}],
    "PreCompact": [{"hooks": [{"type": "command", "command": "bash .claude/hooks/PreCompact.sh"}]}]
  }
}
```

### `.claude/agents/code-reviewer.md`

```markdown
# Agent: Code Reviewer

## Nhiệm vụ
Đọc git diff → báo cáo:
1. Thay đổi đúng scope task chưa?
2. Có ASSUMPTION: nào cần xác nhận?
3. Có vấn đề logic hoặc regression không?
4. Test cover đủ chưa?

## Output
SCOPE: [đúng / lệch]
ASSUMPTION: [có / không]
ISSUES: [có / không]
TEST: [đủ / thiếu]
VERDICT: APPROVE / REQUEST_CHANGES

## Constraints
- Chỉ đọc diff được cung cấp
- Không sửa code, chỉ báo cáo
```

### `.claude/commands/review.md`

```markdown
# /review — Code Review

Dispatch `.claude/agents/code-reviewer` để review git diff hiện tại.

## Steps

1. Chạy `git diff HEAD~1..HEAD` để lấy diff commit cuối
2. Nếu có staged changes chưa commit: `git diff --cached` thay thế
3. Dispatch agent `code-reviewer` với diff + context task hiện tại
4. Hiện output APPROVE/REQUEST_CHANGES
5. Nếu REQUEST_CHANGES → list issues, hỏi user muốn fix gì trước
```

### `.claude/commands/verify.md`

```markdown
# /verify — Run All Tests

Chạy toàn bộ test suite và báo cáo kết quả.

## Steps

1. Compile/syntax check trước (adapt theo stack):
   - Python: `python -m py_compile <core files>`
   - Node/TS: `npm run build` hoặc `npx tsc --noEmit`
2. Chạy tests:
   - Python: `for f in test/check_*.py; do python "$f" && echo "PASS: $f" || echo "FAIL: $f"; done`
   - Node: `npm test`
3. Báo cáo: X pass, Y fail
4. Nếu có FAIL → show output, diagnose root cause
```

### `.claude/commands/ship.md`

```markdown
# /ship — Pre-ship Checklist

Kiểm tra trước khi commit/báo done.

## Checklist

1. `/verify` — chạy toàn bộ tests, phải 0 FAIL
2. `git diff` — Claude review scope, không có thứ ngoài plan
3. `/review` — dispatch code-reviewer agent
4. Grep `ASSUMPTION:` trong staged/recent commits → nếu có, xác nhận với user trước
5. Check migration nếu có DB: version đã tăng chưa?
6. Báo cáo: ✓ pass / ✗ fail với lý do cụ thể

## Chỉ báo "sẵn sàng commit" khi tất cả ✓
```

---

### `rules/api.md` (path-scoped)

```markdown
---
path: src/api/**
---
# API Layer Rules
- Mọi endpoint phải có auth middleware
- Response format: `{ data, error, meta }`
- Validate input tại đây
- Không return raw DB object
```

---

## Shared rules policy

- Canonical shared rules live in `~/.claude/templates/shared-agent-rules.md`.
- Global `~/.claude/CLAUDE.md` includes shared rules with `@~/.claude/templates/shared-agent-rules.md` for Claude.
- `~/.claude/templates/code-project.md` MUST NOT include shared rules, because Claude already gets them globally.
- `~/.claude/templates/AGENTS.md` is template body only. Project `AGENTS.md` must materialize shared rules as real text above that body; do not rely on `@include` for Codex unless include expansion is verified.
- New code project `CLAUDE.md` should include `@~/.claude/templates/code-project.md` first, then `@rules/[tool].md`, then `@context/architecture.md`.
- New code project `AGENTS.md` should be generated from `shared-agent-rules.md + templates/AGENTS.md` and include source markers for sync.

## Global vs Per-Project

| Loại | Global `~/.claude/` | Per-project `.claude/` |
|---|---|---|
| Ngôn ngữ, Superpowers triggers | ✓ CLAUDE.md | |
| Hook mọi project | ✓ settings.json | |
| Hook riêng project | | ✓ .claude/hooks/ |
| MCP server | | ✓ .mcp.json |
| Rules cụ thể | | ✓ rules/ |
| Sub-agent | | ✓ .claude/agents/ |
| /slash command | | ✓ .claude/commands/ |

Khi không chắc: đặt per-project trước, 3+ project dùng → move lên global template.

---

## PHẦN 3: Audit / Sync Rules Project Hiện Tại

Dùng khi user nói: "sync rules", "audit rules", "kiểm tra rules", "project này có lệch template không", hoặc muốn cleanup rule placement.

Init skill là entrypoint duy nhất cho init + extend + sync. `sync-rules` đã được remove để tránh drift.

<HARD-GATE>
**Bước đầu tiên bắt buộc: tạo task list/session todo với 6 tasks sau, TRƯỚC KHI làm bất cứ điều gì khác.**

Trong Claude Code v2 dùng `TaskCreate`/`TaskUpdate`; môi trường khác dùng todo tool tương đương.
Nếu không tạo task list → không được tiếp tục.

1. B0: chạy `git -C ~/.claude fetch` — check behind/ahead
2. B1: detect loại project (code / personal / research / finance / business)
3. B2: đọc `CLAUDE.md` project — check @include đúng template chưa, diff nếu copy, review trùng lặp
4. B3: đọc `AGENTS.md` project — marker date → git diff template → check conflict (bỏ qua nếu non-code và không có file)
5. B4: đọc từng file `rules/` — check ranh giới tool config vs workflow (CHỈ code project)
6. B5: xuất báo cáo đầy đủ + fix sau khi user OK

**`git status` KHÔNG phải cách detect gap.**
Gap chỉ xác định được sau khi ĐỌC FILE và SO SÁNH với template thực tế.
File không thay đổi trong git vẫn có thể outdated so với template.
</HARD-GATE>

## GIỚI HẠN PHẠM VI — PROJECT AUDIT/SYNC

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| Đọc `~/.claude/` (reference) | Ghi bất kỳ file nào vào `~/.claude/` |
| Tạo/sửa file trong project | Sửa global templates, skills, CLAUDE.md global |
| `git status`, `git log`, `git diff` (read-only) | `git add`, `git commit`, `git init` trong project |

Phát hiện vấn đề ở `~/.claude` trong project audit/sync → chỉ báo cáo. Nếu user explicit yêu cầu sửa global, chuyển sang **PHẦN 4: Global Maintenance**.

---

## Quy Trình

### B0 — Kiểm tra ~/.claude up-to-date

```bash
git -C ~/.claude fetch --quiet
git -C ~/.claude status --short --branch
```

Output có `behind` → **dừng lại**:
```
⚠ ~/.claude chưa up-to-date ([N] commits behind).
  Chạy: git -C ~/.claude pull → gọi lại init audit/sync.
```

Up-to-date hoặc không có remote → tiếp tục.

---

### B1 — Detect loại project

**Bước 1: check deps file**

```bash
ls package.json pyproject.toml go.mod 2>/dev/null
```

Có → **code project**. Ghi nhớ add-ons cần check:

| Phát hiện trong deps | Add-on cần có |
|---|---|
| `@supabase/supabase-js` | `rules/supabase.md` |
| `playwright` / `@playwright/test` | `rules/testing.md` |
| `vitest` / `jest` | `rules/testing.md` |

**Bước 2: nếu không có deps → đọc CLAUDE.md để xác định loại**

```bash
grep "@~/.claude/templates/" CLAUDE.md 2>/dev/null
```

| Tìm thấy | Loại project | Template so sánh |
|---|---|---|
| `@~/.claude/templates/personal.md` | personal | `~/.claude/templates/personal.md` |
| `@~/.claude/templates/research.md` | research | `~/.claude/templates/research.md` |
| `@~/.claude/templates/finance.md` | finance | `~/.claude/templates/finance.md` |
| `@~/.claude/templates/business.md` | business | `~/.claude/templates/business.md` |
| `@~/.claude/templates/code-project.md` | code (không có deps) | `~/.claude/templates/code-project.md` |

Không tìm thấy dòng nào → hỏi user:
```
Không detect được loại project. Đây là project loại gì?
  1. code  2. personal  3. research  4. finance  5. business
```

Sau khi biết loại → tiếp tục B2.

---

### B2 — Kiểm tra CLAUDE.md

**File tồn tại không?**
Không tồn tại → flag `✗ CLAUDE.md thiếu`, skip phần còn lại của B2.

**@include hay copy thủ công?**

Dùng `TEMPLATE` = tên template detect ở B1 (ví dụ: `personal.md`, `code-project.md`).

```bash
grep "@~/.claude/templates/$TEMPLATE" CLAUDE.md
```

**Nếu dùng @include:**

*Với code project* → kiểm tra thứ tự:
```
@~/.claude/templates/code-project.md   ← PHẢI đứng đầu
@rules/[tool].md                        ← sau
@context/architecture.md               ← sau cùng
```
Sai thứ tự → flag `✗ thứ tự @include sai`.

Kiểm tra add-on detect ở B1 → có `@rules/[tool].md` tương ứng chưa?

*Với personal / research / finance / business* → kiểm tra dòng @include đúng template chưa:
```
@~/.claude/templates/[type].md   ← phải có và đứng đầu
```

**Nếu là copy thủ công** → so sánh với template đúng loại:

```bash
PROJECT_DATE=$(git log --format="%ai" -1 -- CLAUDE.md | cut -c1-10)
# Nếu CLAUDE.md chưa commit → dùng ngày hôm nay làm mốc
TEMPLATE_FILE="templates/$TEMPLATE"
TEMPLATE_HASH=$(git -C ~/.claude log --oneline --before="$PROJECT_DATE 23:59" -1 -- $TEMPLATE_FILE | cut -d' ' -f1)
git -C ~/.claude diff $TEMPLATE_HASH..HEAD -- $TEMPLATE_FILE
```

Diff rỗng → không cần làm gì.  
Diff có nội dung → hiện section thay đổi, hỏi:
```
Template đã cập nhật [N] section. Muốn merge không?
  1. Merge (giữ override của project)
  2. Bỏ qua
  3. Chuyển sang @include
```
Option 3 → xác nhận "Override sẽ mất. Xác nhận?" trước khi xóa.

**Review nội dung local — tìm trùng lặp:**

Đọc toàn bộ CLAUDE.md. Với mỗi nội dung nằm ngoài các dòng `@include`:

- Đã có trong template tương ứng → **trùng lặp, đề xuất xóa**
- Chỉ có trong local (constraints, convention riêng) → **giữ**

---

### B3 — Kiểm tra AGENTS.md

**Non-code project (personal / research / finance / business):**
Không có file AGENTS.md → bình thường, bỏ qua B3.
Có file → vẫn check như code project bên dưới.

**Code project:**
Không tồn tại → flag `✗ AGENTS.md thiếu`, dừng.

**Phát hiện thay đổi shared rules / template:**

Project `AGENTS.md` phải materialize shared rules + template body, có marker:

```markdown
<!-- generated-from: shared-agent-rules.md + templates/AGENTS.md -->
<!-- shared-rules: YYYY-MM-DD -->
<!-- template: YYYY-MM-DD -->
```

```bash
SHARED_DATE=$(grep "shared-rules:" AGENTS.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
MARKER_DATE=$(grep "template:" AGENTS.md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
SHARED_HASH=$(git -C ~/.claude log --oneline --before="$SHARED_DATE 23:59" -1 -- templates/shared-agent-rules.md | cut -d' ' -f1)
TEMPLATE_HASH=$(git -C ~/.claude log --oneline --before="$MARKER_DATE 23:59" -1 -- templates/AGENTS.md | cut -d' ' -f1)
git -C ~/.claude diff $SHARED_HASH..HEAD -- templates/shared-agent-rules.md
git -C ~/.claude diff $TEMPLATE_HASH..HEAD -- templates/AGENTS.md
```

Không có marker → đề xuất regenerate `AGENTS.md` từ shared rules + template body, giữ `## Project Context`.

Diff rỗng → AGENTS.md up-to-date ✓

**Xử lý từng section thay đổi:**

Với mỗi section trong diff:
- Project chưa sửa section đó → merge tự động
- Project đã override → **hỏi user**:

```
Section "[tên]" bị conflict:
  Template mới:     [nội dung]
  Project hiện tại: [nội dung]

  1. Lấy template  2. Giữ project  3. Merge thủ công
```

---

### B4 — Kiểm tra `rules/*.md`

**Chỉ chạy B4 với code project.** Personal / research / finance / business không có `rules/` → bỏ qua.

Rules đặt trong `rules/` ở project root. Nếu phát hiện `.claude/rules/` → đề xuất di chuyển vào `rules/`.

`rules/*.md` chỉ được chứa tool config thuần túy — không chứa workflow.

| Được phép | KHÔNG được phép |
|-----------|-----------------|
| MCP commands, lệnh test | Workflow, feature flow, bug fix flow |
| Quirk tool (EPERM, port) | TDD rules, commit rules, token discipline |
| Path-scoped convention (frontmatter `path:`) | Global workflow |

`rules/workflow.md` tồn tại → xóa toàn bộ (không nên tồn tại).  
File khác có workflow lẫn vào → xóa phần vi phạm, giữ tool config.  
Di chuyển nội dung project-specific sang `## Project-Specific Rules` trong CLAUDE.md trước khi xóa.  
File rỗng sau cleanup → xóa luôn.

---

### B5 — Báo cáo + Fix

**Báo cáo trước — adapt theo loại project:**

*Code project:*
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề]
  ✗ AGENTS.md: outdated (section X từ [date]) — [N] conflict
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
  ⚠ rules/workflow.md: xóa "[section]", giữ "[section]"
  ✗ rules/supabase.md: thiếu (dùng Supabase)
  ✗ context/architecture.md: thiếu
```

*Business project:*
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề]
  ✗ context/business-overview.md: thiếu
  ✗ context/decisions.md: thiếu
  ✗ data/raw/: thiếu
  ✗ reports/: thiếu
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
```

*Personal / research / finance:*
```
[PROJECT — fix ngay]
  ✗ CLAUDE.md: [vấn đề — @include sai template hoặc thiếu]
  ✗ [memory file/folder]: thiếu theo template project type
  ⚠ CLAUDE.md: "[section]" trùng template → xóa
```

```
[GLOBAL — mở session ~/.claude để xử lý]
  ⚠ ...
```

Dù không có gap → vẫn liệt kê những gì đã check: `✓ đã check: CLAUDE.md, [danh sách phù hợp loại project]`.

Hỏi "Xử lý hết không?" → sau khi user OK, chỉ chạy bước phù hợp loại:

**Code:** Fix @include → Merge AGENTS.md → Cleanup rules/ → Xóa trùng lặp CLAUDE.md → Content cleanup
**Business:** Tạo memory structure thiếu → Fix @include → Xóa trùng lặp CLAUDE.md → Content cleanup
**Research:** Tạo `sources/`, `notes/`, `findings.md`, `open-questions.md`, `context/decisions.md` nếu thiếu → Fix @include → Content cleanup
**Finance:** Tạo `data/raw/`, `data/processed/`, `models/`, `reports/`, `assumptions.md`, `context/decisions.md` nếu thiếu → Fix @include → Content cleanup
**Personal:** Tạo `goals.md`, `weekly-review.md`, `notes.md`, `context/decisions.md` nếu thiếu → Fix @include → Content cleanup

**Content cleanup — chạy cuối cùng, sau tất cả fix:**

Đọc lại CLAUDE.md và AGENTS.md sau khi đã fix. Tìm và liệt kê:

| Loại | Ví dụ | Hành động |
|---|---|---|
| Placeholder chưa điền | `[tên project]`, `[link]`, `[mô tả]` | Flag — nhắc user điền |
| Section trùng với @include | Viết lại TDD rules đã có trong template | Đề xuất xóa |
| Override cũ không còn cần | Section dùng tool đã bỏ | Đề xuất xóa |
| Section rỗng | Heading không có nội dung | Đề xuất xóa |

Liệt kê tất cả, hỏi từng cái hoặc "Xóa hết không?" trước khi động vào file.

Báo: "Xong. Tự review + commit."

---

## PHẦN 4: Global Maintenance

Dùng khi user explicit nhắc `~/.claude`, global Claude, templates, skills, settings, statusline, hoặc muốn sửa global rule architecture.

Phạm vi:
- Được đọc/sửa `~/.claude/CLAUDE.md`, `~/.claude/templates/*.md`, `~/.claude/skills/*/skill.md`, `~/.claude/README.md`, `~/.claude/.gitignore`, `~/.claude/settings.json` khi đúng request.
- Luôn Read trước khi Edit/Write.
- Merge config, không replace toàn bộ settings.
- Không commit/push nếu user chưa yêu cầu.
- Sau sửa phải validate phù hợp: `jq` cho JSON, grep/check include policy cho shared rules, report skipped checks.

Global shared-rules validation:
```bash
grep -R "@~/.claude/templates/shared-agent-rules.md" ~/.claude/CLAUDE.md ~/.claude/templates/*.md
```
Kỳ vọng: chỉ `~/.claude/CLAUDE.md`. `templates/AGENTS.md` không dùng `@include`; project `AGENTS.md` materialize shared rules.

---

## Post-init / Post-sync Validation

Chạy sau mọi init hoặc sync:

1. Validate settings nếu có sửa config:
   ```bash
   jq empty ~/.claude/settings.json
   ```
2. Check duplicate shared rules include:
   ```bash
   grep -R "@~/.claude/templates/shared-agent-rules.md" ~/.claude/CLAUDE.md ~/.claude/templates/*.md
   ```
   Kỳ vọng: chỉ `CLAUDE.md`. `templates/AGENTS.md` không dùng `@include`; project `AGENTS.md` materialize shared rules.
3. Check project rules path:
   ```bash
   find . -path '*/.claude/rules/*.md' -print
   ```
   Kỳ vọng: rỗng. Project rules nằm ở `rules/*.md`.
4. Code project include order:
   ```markdown
   @~/.claude/templates/code-project.md
   @rules/[tool].md
   @context/architecture.md
   ```
5. Personal lightweight mode: nếu project là workspace hỏi linh tinh/config nhẹ, vẫn tạo skeleton tối thiểu (`goals.md`, `weekly-review.md`, `notes.md`, `context/decisions.md`) nhưng giữ nội dung ngắn.
6. Report skipped checks. Không báo "xong" nếu có check bị skip mà chưa nói rõ.
