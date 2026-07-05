#!/usr/bin/env python3
"""PreToolUse:mcp__gitnexus__detect_changes — touch a per-repo marker file
so commit-gate.py can verify detect_changes actually ran before a commit.
"""
import json
import os
import subprocess
import sys

json.load(sys.stdin)  # tool_input not needed — repo root comes from cwd

try:
    root = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=5,
    ).stdout.strip()
except Exception:
    sys.exit(0)

if not root:
    sys.exit(0)

gitnexus_dir = os.path.join(root, ".gitnexus")
if not os.path.isdir(gitnexus_dir):
    sys.exit(0)

marker = os.path.join(gitnexus_dir, ".commit_gate_ok")
with open(marker, "w") as f:
    f.write("")

sys.exit(0)
