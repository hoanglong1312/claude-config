#!/usr/bin/env python3
"""PreToolUse:Bash — hard-block `git commit` when staged diff touches
security-sensitive paths unless /review ran recently.

Marker: `.claude/.security-reviewed` in project root, touched by the
/review command's final step. Same rationale as commit-gate.py: text
rules decay in long sessions, only mechanical gates are reliable.

Scope guard: only enforced in code projects stamped by init
(detected via `.claude/commands/ship.md`) — other repos always pass.
"""
import json
import os
import re
import subprocess
import sys
import time

MAX_AGE_SECONDS = 30 * 60  # /review valid for 30 min

SENSITIVE = re.compile(
    r"(^|/)(auth|middleware)(/|$)|(^|/)api/|migration|\brls\b", re.IGNORECASE
)

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")
payload_cwd = data.get("cwd") or os.getcwd()

if not re.search(r"\bgit\s+commit\b", cmd):
    sys.exit(0)

# resolve repo dir same way as commit-gate.py (handle `cd X && git commit`)
commit_pos = re.search(r"\bgit\s+commit\b", cmd).start()
start_dir = payload_cwd
for m in re.finditer(r"(?:^|[\n;&|])\s*cd\s+(\"[^\"]+\"|'[^']+'|\S+)", cmd):
    if m.start() >= commit_pos:
        break
    target = m.group(1).strip("\"'")
    start_dir = target if os.path.isabs(target) else os.path.join(start_dir, target)

try:
    root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=5, cwd=start_dir,
    ).stdout.strip()
except Exception:
    sys.exit(0)

if not root or not os.path.isfile(os.path.join(root, ".claude", "commands", "ship.md")):
    sys.exit(0)  # not an init-stamped code project — don't gate

try:
    staged = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True, text=True, timeout=5, cwd=root,
    ).stdout.splitlines()
except Exception:
    sys.exit(0)

hits = [f for f in staged if SENSITIVE.search(f)]
if not hits:
    sys.exit(0)

marker = os.path.join(root, ".claude", ".security-reviewed")
fresh = os.path.isfile(marker) and (time.time() - os.path.getmtime(marker)) <= MAX_AGE_SECONDS
if fresh:
    sys.exit(0)

print(
    f"⛔ SECURITY GATE ({root}): staged diff đụng path nhạy cảm: {', '.join(hits[:5])}. "
    "Chạy /review (security checklist) trước khi commit — bước cuối của /review sẽ touch "
    ".claude/.security-reviewed để mở gate (hiệu lực 30 phút).",
    file=sys.stderr,
)
sys.exit(2)
