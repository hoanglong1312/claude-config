---
title: Claude Global Overview
layout: wide
theme: clay-slate
---

# Claude — Global Overview

```yaml
type: notice
variant: info
content: |
  Quick reference cho toàn bộ Claude setup. Source of truth: ~/.claude/CLAUDE.md và templates/.
  Cập nhật file này khi thêm skill, template, project, hoặc đổi rule quan trọng.
```

---

# Superpowers Skills

```yaml
type: data-grid
columns:
  - Skill
  - Khi dùng
  - Invoke
rows:
  - ["brainstorming", "Tạo / design feature mới", "Skill('brainstorming')"]
  - ["writing-plans", "Có spec, cần plan implement", "Skill('writing-plans')"]
  - ["test-driven-development", "Bắt đầu code (non-code-project)", "Skill('test-driven-development')"]
  - ["subagent-driven-development", "2+ task độc lập (non-code-project)", "Skill('subagent-driven-development')"]
  - ["systematic-debugging", "Bug / lỗi / không hoạt động", "Skill('systematic-debugging')"]
  - ["requesting-code-review", "Xong implement, muốn kiểm tra", "Skill('requesting-code-review')"]
  - ["receiving-code-review", "Nhận review feedback", "Skill('receiving-code-review')"]
  - ["verification-before-completion", "Xong implement, verify trước khi done", "Skill('verification-before-completion')"]
  - ["finishing-a-development-branch", "Kết thúc branch", "Skill('finishing-a-development-branch')"]
  - ["using-git-worktrees", "Feature cần isolate / chạy song song", "Skill('using-git-worktrees')"]
  - ["dispatching-parallel-agents", "Dispatch nhiều agent cùng lúc", "Skill('dispatching-parallel-agents')"]
  - ["executing-plans", "Chạy plan từng task (inline)", "Skill('executing-plans')"]
  - ["writing-skills", "Viết skill mới", "Skill('writing-skills')"]
```

---

# Templates

```yaml
type: board-layout
variant: kanban
columns:
  - title: "Code Project"
    items:
      - "File: ~/.claude/templates/code-project.md"
      - "Dùng khi: có codebase, Codex execute"
      - "Flow: brainstorm → spec → plan → Codex → review"
      - "@include vào project CLAUDE.md"
  - title: "Business"
    items:
      - "File: ~/.claude/templates/business.md"
      - "Dùng khi: dự án kinh doanh, ops, marketing"
      - "Không có Codex delegation"
  - title: "Research"
    items:
      - "File: ~/.claude/templates/research.md"
      - "Dùng khi: nghiên cứu, phân tích, so sánh"
      - "Web search, synthesis, Obsidian output"
  - title: "Finance / Personal"
    items:
      - "finance.md: tài chính cá nhân / doanh nghiệp"
      - "personal.md: dự án cá nhân không có code"
```

---

# HTML Visual Workflow

```yaml
type: data-grid
columns:
  - Bước
  - Ai làm
  - Command
rows:
  - ["Viết .md hybrid", "Claude", "—"]
  - ["Compile → HTML", "Claude", "html-eff --input file.md --output file.html"]
  - ["Mở browser", "Claude", "open file.html"]
  - ["Update task status", "Codex", "Edit **Status:** field trong .md"]
  - ["Sync HTML sau update", "Claude", "html-eff --input plan-overview.md --output plan-overview.html"]
```

```yaml
type: notice
variant: warning
content: |
  html-eff binary: ~/.local/bin/html-eff (cài 1 lần, dùng mọi project)
  Setup nếu chưa có: git clone https://github.com/luisoncpp/html-effectiveness-scripts.git ~/.local/share/html-effectiveness-scripts && cd ~/.local/share/html-effectiveness-scripts && cargo build --release && ln -sf ~/.local/share/html-effectiveness-scripts/target/release/html-effectiveness ~/.local/bin/html-eff
  Theme hiện tại: clay-slate (duy nhất — muốn thêm theme: fork repo + thêm CSS token file)
```

---

# Global Rules Quick Ref

```yaml
type: data-grid
columns:
  - Rule
  - Nội dung
rows:
  - ["Ngôn ngữ", "Luôn trả lời Tiếng Việt. Thuật ngữ giải thích lần đầu."]
  - ["Markitdown", "PDF/Word/PPT/Excel/HTML → markitdown [file] > [file].md trước khi đọc"]
  - ["Superpowers", "Classify intent trước mỗi response. Nếu không chắc → assume skill áp dụng."]
  - ["Obsidian", "Cuối session nhắc lưu nếu: topic mới, bug khó, quyết định kiến trúc"]
  - ["Codex Review Gate", "Spec/plan phức tạp (3+ subsystem) → dispatch Codex review trước khi execute"]
  - ["Token Discipline", "Claude viết .md + chạy html-eff. Codex viết code + update .md status."]
  - ["Kết thúc session", "Báo: git status, Obsidian gợi ý, task còn lại"]
  - ["Sync rules", "User nói 'sync rules' / 'audit rules' → Skill('sync-rules')"]
```

---

# Config — Đặt Rule Ở Đâu

```yaml
type: data-grid
columns:
  - Rule thuộc loại nào
  - Đặt ở đâu
rows:
  - ["Mọi session, mọi project", "~/.claude/CLAUDE.md"]
  - ["Mọi session, theo loại project", "~/.claude/templates/[type].md"]
  - ["Tool config project cụ thể", "[project]/.claude/rules/[name].md"]
  - ["Chỉ khi init/setup project", "~/.claude/SETUP.md"]
  - ["Chỉ khi skill invoke", "~/.claude/skills/[skill]/skill.md"]
  - ["Chỉ Codex đọc", "[project]/AGENTS.md"]
```

---

# Active Projects

```yaml
type: board-layout
variant: kanban
columns:
  - title: "MMO (Active)"
    items:
      - "Path: ~/Documents/MMO"
      - "Stack: Python, FastAPI, Camoufox, SQLite, Node.js, Telegraf"
      - "Goals: AutoHub + Account Factory"
      - "Template: code-project.md"
      - "Plans: docs/plan-overview.html"
  - title: "Spliteasy Boss"
    items:
      - "Path: ~/Library/.../Spliteasy-boss"
      - "Template: business.md"
  - title: "Long Cafe"
    items:
      - "Path: ~/Library/.../LONG-CAFE"
      - "Template: business.md"
  - title: "my-brain (Obsidian)"
    items:
      - "Path: ~/Library/.../my-brain"
      - "Vault: AI knowledge base"
      - "Output target cho mọi session research"
```

---

# html-eff Component Cheatsheet

```yaml
type: data-grid
columns:
  - Component
  - type field
  - Fields chính
rows:
  - ["Notice/Warning", "notice", "variant: info|warning|error, content: |"]
  - ["Card", "card", "title, content, tags, elevation, children"]
  - ["Table", "data-grid", "columns: [], rows: [[\"val\"]]"]
  - ["Kanban Board", "board-layout", "variant: kanban, columns: [{title, items}]"]
  - ["Timeline", "timeline", "orientation: vertical, steps: [{timestamp, title, type, description, tags}]"]
  - ["Code diff", "code-panel", "tabs: [{name, language, diff, added, removed, content}]"]
  - ["Flowchart", "flowchart", "nodes, edges, details"]
  - ["Module Map", "module-map", "nodes, edges"]
```
