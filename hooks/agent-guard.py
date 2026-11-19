#!/usr/bin/env python3
"""PreToolUse:Agent|Task|Bash — ép 2 luật của skill orchestrating-agents trong code project.

1. Chặn subagent `general-purpose` (hoặc không ghi subagent_type, mặc định cũng là
   general-purpose): ăn 13% token đợt kho A/C/D mà không có vai.
   → tìm/đọc/chạy dùng `scout`; cần phán đoán dùng `architect`.
2. Chặn `git add -A` / `git add --all` / `git add .`: thư mục chung thường có file dở
   của phiên khác → chỉ add đúng file mình sửa.

Chỉ áp trong code project = có CLAUDE.md (từ cwd đi lên) nạp `code-project.md`.
Lối thoát: prompt Agent hoặc lệnh Bash chứa `[guard-ok]` kèm lý do → cho qua.
"""
import json
import os
import re
import sys

BYPASS = "[guard-ok]"


IMPORT = re.compile(r"^@\S*code-project\.md\s*$", re.MULTILINE)


def is_code_project(cwd):
    # Chỉ tính dòng import thật `@.../code-project.md` ở đầu dòng; dừng trước $HOME
    # (global ~/.claude/CLAUDE.md có nhắc tên file nhưng không import).
    d = os.path.abspath(cwd or os.getcwd())
    home = os.path.expanduser("~")
    while d != home:
        for name in ("CLAUDE.md", ".claude/CLAUDE.md"):
            try:
                with open(os.path.join(d, name), encoding="utf-8", errors="ignore") as f:
                    if IMPORT.search(f.read(4000)):
                        return True
            except OSError:
                pass
        parent = os.path.dirname(d)
        if parent == d:
            return False
        d = parent
    return False


def block(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool = data.get("tool_name", "")
inp = data.get("tool_input") or {}
if not is_code_project(data.get("cwd")):
    sys.exit(0)

if tool in ("Agent", "Task"):
    sub = (inp.get("subagent_type") or "general-purpose").strip()
    if sub == "general-purpose" and BYPASS not in (inp.get("prompt") or ""):
        block(
            "agent-guard: code project cấm subagent `general-purpose` "
            "(skill orchestrating-agents). Tìm/đọc/chạy lệnh → subagent_type \"scout\"; "
            "cần phán đoán → \"architect\"; code → \"builder\". "
            "Bắt buộc dùng thì thêm `[guard-ok] <lý do>` vào prompt."
        )
    sys.exit(0)

if tool == "Bash":
    cmd = inp.get("command") or ""
    if BYPASS in cmd:
        sys.exit(0)
    for m in re.finditer(r"\bgit(?:\s+-C\s+(?:\"[^\"]*\"|'[^']*'|\S+))?\s+add\b([^;&|\n]*)", cmd):
        args = m.group(1).split()
        if any(a in ("-A", "--all", ".", "-u", "--update", ":/") for a in args):
            block(
                "agent-guard: không dùng `git add -A/--all/./-u` trong code project — "
                "thư mục chung có thể chứa file dở của phiên khác. "
                "Add đúng từng file đã sửa (`git add <file>`). "
                "Chắc chắn cả cây là của mình thì thêm `# [guard-ok] <lý do>` cuối lệnh."
            )
    sys.exit(0)

sys.exit(0)
