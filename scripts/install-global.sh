#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/backups/install-$STAMP"
OS_SETTINGS="$REPO_DIR/settings.macos.json"

is_secret_key() { [[ "$1" =~ ^ANTHROPIC_ || "$1" =~ ^OPENAI_ || "$1" =~ _API_KEY$ || "$1" =~ _TOKEN$ || "$1" =~ _SECRET$ || "$1" =~ _PASSWORD$ || "$1" == BASE_URL || "$1" =~ _BASE_URL$ ]]; }

mkdir -p "$CLAUDE_DIR" "$BACKUP_DIR"
for p in settings.json CLAUDE.md templates hooks skills references docs; do
  [ -e "$CLAUDE_DIR/$p" ] && cp -R "$CLAUDE_DIR/$p" "$BACKUP_DIR/"
done

mkdir -p "$CLAUDE_DIR/templates" "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/references" "$CLAUDE_DIR/docs"
cp -R "$REPO_DIR/templates/"* "$CLAUDE_DIR/templates/"
cp -R "$REPO_DIR/hooks/"* "$CLAUDE_DIR/hooks/"
[ -d "$REPO_DIR/skills" ] && cp -R "$REPO_DIR/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
[ -d "$REPO_DIR/references" ] && cp -R "$REPO_DIR/references/"* "$CLAUDE_DIR/references/" 2>/dev/null || true
[ -d "$REPO_DIR/docs" ] && cp -R "$REPO_DIR/docs/"* "$CLAUDE_DIR/docs/" 2>/dev/null || true
cp "$REPO_DIR/templates/CLAUDE.global.md" "$CLAUDE_DIR/CLAUDE.md"

python3 - "$CLAUDE_DIR/settings.json" "$REPO_DIR/settings.shared.json" "$OS_SETTINGS" "$REPO_DIR/settings.local.json" <<'PY'
import json, sys, re
from pathlib import Path
out=Path(sys.argv[1]); inputs=[Path(p) for p in sys.argv[2:] if Path(p).exists()]
secret=re.compile(r'^(ANTHROPIC_|OPENAI_)|(_API_KEY|_TOKEN|_SECRET|_PASSWORD|_BASE_URL)$|^BASE_URL$')
def load(p):
    return json.loads(p.read_text()) if p.exists() and p.read_text().strip() else {}
def merge(a,b,path=''):
    for k,v in b.items():
        keypath=f'{path}.{k}' if path else k
        if keypath.startswith('env.') and secret.search(k):
            print(f'skip secret env: {k}')
            continue
        if k not in a:
            a[k]=v; continue
        if isinstance(a[k],dict) and isinstance(v,dict):
            merge(a[k],v,keypath)
        elif isinstance(a[k],list) and isinstance(v,list):
            for item in v:
                if item not in a[k]: a[k].append(item)
        else:
            if a[k] != v:
                print(f'preserve existing setting: {keypath}')
    return a
base=load(out)
for p in inputs: base=merge(base, load(p))
out.write_text(json.dumps(base, indent=2, ensure_ascii=False)+"\n")
PY

if command -v jq >/dev/null 2>&1; then jq empty "$CLAUDE_DIR/settings.json"; else python3 -m json.tool "$CLAUDE_DIR/settings.json" >/dev/null; fi
for tool in node claude codex rtk markitdown; do command -v "$tool" >/dev/null 2>&1 && echo "$tool: installed" || echo "$tool: missing"; done
echo "Backup: $BACKUP_DIR"
echo "Installed global Claude config to $CLAUDE_DIR"
