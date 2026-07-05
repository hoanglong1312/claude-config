#!/usr/bin/env python3
"""PreToolUse:Bash — hard-block `git commit` in a GitNexus-indexed repo
unless `detect_changes` was run recently (see touch-detect-changes.py).

Rationale: text rules ("MUST run detect_changes before commit") get
ignored under long sessions — only a mechanical gate is reliable.
Repo not GitNexus-indexed (no .gitnexus/ dir) -> always allow.
"""
import json
import os
import re
import subprocess
import sys
import time

MAX_AGE_SECONDS = 30 * 60  # marker valid for 30 min after detect_changes

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")

if not re.search(r"\bgit\s+commit\b", cmd):
    sys.exit(0)

try:
    root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=5,
    ).stdout.strip()
except Exception:
    sys.exit(0)  # not a git repo — nothing to gate

if not root:
    sys.exit(0)

gitnexus_dir = os.path.join(root, ".gitnexus")
if not os.path.isdir(gitnexus_dir):
    sys.exit(0)  # repo not GitNexus-indexed — don't force adoption

marker = os.path.join(gitnexus_dir, ".commit_gate_ok")
if not os.path.isfile(marker):
    print(
        "⛔ GitNexus: chưa chạy detect_changes() lần nào trong session này. "
        "Gọi mcp__gitnexus__detect_changes trước khi commit (xem rules/gitnexus.md).",
        file=sys.stderr,
    )
    sys.exit(2)

age = time.time() - os.path.getmtime(marker)
if age > MAX_AGE_SECONDS:
    print(
        f"⛔ GitNexus: detect_changes() cuối cùng đã {int(age // 60)} phút trước — "
        "quá cũ so với thay đổi hiện tại. Chạy lại mcp__gitnexus__detect_changes trước khi commit.",
        file=sys.stderr,
    )
    sys.exit(2)

sys.exit(0)
