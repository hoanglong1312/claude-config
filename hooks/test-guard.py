#!/usr/bin/env python3
"""PreToolUse:Bash — chặn `git commit` khi diff xoá file test hoặc thêm skip/only.

Lý do: luật chữ "không sửa/xoá/skip test để pass" (AGENTS.md, Codex lỗi loại D)
có thể bị quên; commit luôn đi qua đây nên chặn ở đây là chắc nhất.
Lối thoát: commit message có `[test-change-ok]` (kèm lý do) → cho qua.
"""
import json
import os
import re
import subprocess
import sys

BYPASS = "[test-change-ok]"

TEST_PATH = re.compile(
    r"(^|/)(tests?|__tests__|specs?|e2e)/"
    r"|[._-](test|spec)\.[A-Za-z0-9]+$"
    r"|(^|/)test_[^/]+\.py$"
    r"|_test\.(go|py|rb|exs?)$",
    re.IGNORECASE,
)

SKIP = re.compile(
    r"\b(it|describe|test|context|suite)\.(skip|only)\s*\("
    r"|\bx(it|describe|test)\s*\("
    r"|\bf(it|describe)\s*\("
    r"|@pytest\.mark\.(skip|skipif|xfail)\b"
    r"|\bpytest\.skip\s*\("
    r"|@unittest\.skip"
    r"|\bt\.Skip(Now|f)?\s*\("
    r"|#\[ignore\]"
    r"|@Disabled\b"
)


def git(args, cwd):
    return subprocess.run(
        ["git", *args], capture_output=True, text=True, timeout=10, cwd=cwd
    ).stdout


data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")
m = re.search(r"\bgit\s+commit\b", cmd)
if not m or BYPASS in cmd:
    sys.exit(0)

# repo dir: xử lý `cd X && git commit`
start_dir = data.get("cwd") or os.getcwd()
for c in re.finditer(r"(?:^|[\n;&|])\s*cd\s+(\"[^\"]+\"|'[^']+'|\S+)", cmd):
    if c.start() >= m.start():
        break
    target = os.path.expanduser(c.group(1).strip("\"'"))
    start_dir = target if os.path.isabs(target) else os.path.join(start_dir, target)

try:
    root = git(["rev-parse", "--show-toplevel"], start_dir).strip()
    if not root:
        sys.exit(0)
    # `git commit -a` stage lúc commit → so với HEAD thay vì index
    commit_all = re.search(r"\bgit\s+commit\b[^;&|\n]*\s(-[a-zA-Z]*a[a-zA-Z]*|--all)\b", cmd)
    base = ["diff", "HEAD"] if commit_all else ["diff", "--cached"]
    status = git([*base, "--name-status", "--no-renames"], root)
    patch = git([*base, "-U0", "--no-color", "--no-renames"], root)
except Exception:
    sys.exit(0)

problems = []
for line in status.splitlines():
    parts = line.split("\t")
    if len(parts) == 2 and parts[0] == "D" and TEST_PATH.search(parts[1]):
        problems.append(f"xoá file test: {parts[1]}")

current = None
for line in patch.splitlines():
    if line.startswith("+++ "):
        current = line[6:] if line.startswith("+++ b/") and not line.endswith((".md", ".mdx", ".txt")) else None
    elif current and line.startswith("+") and SKIP.search(line):
        problems.append(f"thêm skip/only ở {current}: {line[1:].strip()[:80]}")

if not problems:
    sys.exit(0)

print(
    "⛔ TEST GUARD: commit này làm yếu test suite:\n  - "
    + "\n  - ".join(problems[:8])
    + "\nKhông xoá/skip test để cho pass — sửa code cho test pass thật."
    + f"\nNếu thay đổi test là cố ý (test lỗi thời…): ghi lý do vào commit message kèm `{BYPASS}`.",
    file=sys.stderr,
)
sys.exit(2)
