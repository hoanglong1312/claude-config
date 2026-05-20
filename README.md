# Claude Code Global Config — Setup Guide

Đọc file này khi setup máy mới. KHÔNG load tự động — chỉ đọc thủ công khi cần.

---

## 1. Superpowers Plugin

```bash
/plugin install superpowers@claude-plugins-official
```

Cài trên Codex CLI: mở Codex → `/plugins` → search "superpowers" → Install.

---

## 2. settings.json — Các giá trị cần set

Tạo hoặc merge vào `~/.claude/settings.json`:

```json
{
  "model": "sonnet",
  "effortLevel": "medium",
  "theme": "dark",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  },
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "rtk hook claude" }]
      }
    ]
  }
}
```

**Giải thích từng env:**
- `MAX_THINKING_TOKENS=10000` — giới hạn extended thinking, tránh tốn token
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` — compact khi context 70% full (không để tràn)
- `CLAUDE_CODE_SUBAGENT_MODEL=haiku` — subagent dùng model rẻ hơn 10x

---

## 3. RTK (Token Optimizer)

```bash
# Cài RTK
curl -fsSL https://rtk.dev/install.sh | sh

# Verify
rtk --version
rtk gain
```

Hook đã config sẵn trong settings.json — RTK tự chạy với mọi Bash command.

---

## 4. MCP Codex

```bash
claude mcp add codex
```

Workflow: Claude (planning) → `mcp__codex__codex` (implementation) → Claude (review)

---

## 5. Templates & Cấu Trúc Project Chuẩn

Các template nằm tại `~/.claude/templates/`:
- `code-project.md` — workflow chung cho mọi code project
- `research.md` — nghiên cứu, phân tích
- `finance.md` — tài chính, trading
- `personal.md` — dự án cá nhân
- `AGENTS.md` — universal cross-tool template
- `rules/supabase.md` — Supabase MCP rules (copy vào project nếu dùng Supabase)
- `rules/testing.md` — Quality Gate rules (copy vào project, điền lệnh test cụ thể)

### Cấu trúc 3 tầng cho mọi code project

```
Tầng 1: ~/.claude/CLAUDE.md              ← Universal (mọi project)
Tầng 2: ~/.claude/templates/             ← Per-type (code/research/finance/personal)
Tầng 3: [project]/                       ← Per-project
         ├── CLAUDE.md                    ← Lean, chỉ dùng @imports
         ├── rules/
         │   ├── workflow.md              ← Codex workflow (copy từ template)
         │   ├── supabase.md              ← Nếu dùng Supabase
         │   └── testing.md              ← Test commands cụ thể của project
         └── context/
             └── architecture.md         ← Stack, file structure, decisions
```

### CLAUDE.md chuẩn cho project mới

```markdown
# CLAUDE.md — [Tên Project]

**Ngôn ngữ:** [nếu cần override]

@context/architecture.md
@rules/workflow.md
@rules/supabase.md    ← chỉ thêm nếu dùng Supabase
@rules/testing.md
```

### Tạo project mới — checklist
1. Copy `~/.claude/templates/rules/workflow.md` → `[project]/rules/workflow.md`
2. Copy `~/.claude/templates/rules/testing.md` → `[project]/rules/testing.md` + điền lệnh test
3. Nếu dùng Supabase: copy `~/.claude/templates/rules/supabase.md` → `[project]/rules/supabase.md`
4. Tạo `[project]/context/architecture.md` — mô tả stack, file quan trọng, constraints
5. Tạo `[project]/CLAUDE.md` lean với @imports

---

## 6. Obsidian Vault

Vault path: `~/Library/Mobile Documents/com~apple~CloudDocs/AI/my-brain/`

Sync qua iCloud — không cần setup thêm trên máy mới nếu đã đăng nhập iCloud.
