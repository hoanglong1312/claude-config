#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
PROJECT_DIR="${1:-$REPO_DIR}"
DATE="$(date +%F)"

hash_file() {
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$@" | shasum -a 256 | awk '{print $1}'
  else sha256sum "$@" | sha256sum | awk '{print $1}'
  fi
}

render_agents() {
  local out="$1"
  local notes
  notes='<!-- BEGIN PROJECT NOTES -->
<!-- Project-specific Codex notes live here. Sync scripts preserve this block. -->
<!-- END PROJECT NOTES -->'
  if [ -f "$out" ]; then
    notes="$(python3 - "$out" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
s=p.read_text()
start='<!-- BEGIN PROJECT NOTES -->'
end='<!-- END PROJECT NOTES -->'
if start in s and end in s:
    a=s.index(start); b=s.index(end)+len(end)
    print(s[a:b])
else:
    print(start+'\n<!-- Project-specific Codex notes live here. Sync scripts preserve this block. -->\n'+end)
PY
)"
  fi
  local workflows=(intent-routing.md planning.md debugging.md tdd.md verification.md review.md response-style.md tool-output-discipline.md)
  {
    echo '<!-- BEGIN GENERATED AGENT RULES -->'
    echo '<!-- generated-from: templates/shared-agent-rules.md + templates/shared-workflows/*.md + templates/AGENTS.md -->'
    echo "<!-- generated-date: $DATE -->"
    echo "<!-- shared-rules-sha256: $(hash_file "$REPO_DIR/templates/shared-agent-rules.md") -->"
    echo "<!-- workflows-sha256: $(hash_file "${workflows[@]/#/$REPO_DIR/templates/shared-workflows/}") -->"
    echo "<!-- template-sha256: $(hash_file "$REPO_DIR/templates/AGENTS.md") -->"
    echo
    cat "$REPO_DIR/templates/shared-agent-rules.md"
    for f in "${workflows[@]}"; do echo; echo '---'; echo; cat "$REPO_DIR/templates/shared-workflows/$f"; done
    echo; echo '---'; echo; cat "$REPO_DIR/templates/AGENTS.md"
    echo
    echo '<!-- END GENERATED AGENT RULES -->'
    echo
    printf '%s\n' "$notes"
  } > "$out"
}

mkdir -p "$CLAUDE_DIR/templates/shared-workflows"
cp "$REPO_DIR/templates/shared-agent-rules.md" "$CLAUDE_DIR/templates/shared-agent-rules.md"
cp "$REPO_DIR/templates/shared-workflows/"*.md "$CLAUDE_DIR/templates/shared-workflows/"
render_agents "$PROJECT_DIR/AGENTS.md"
echo "Synced shared rules to $CLAUDE_DIR and rendered $PROJECT_DIR/AGENTS.md"
