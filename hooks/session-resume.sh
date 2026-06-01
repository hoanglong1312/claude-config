#!/bin/bash
VAULT="/Users/giinlow./Library/Mobile Documents/iCloud~md~obsidian/Documents/my-brain"
PROJECT_DIR="$(pwd)"

# Skip vault itself và ~/.claude
if [[ "$PROJECT_DIR" == *"my-brain"* ]] || [[ "$PROJECT_DIR" == *".claude"* ]] || [[ "$PROJECT_DIR" == "$HOME" ]]; then
  exit 0
fi

# Lấy tên project từ working dir
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Tìm folder tương ứng trong vault
PROJECT_NOTES="$VAULT/raw/projects/$PROJECT_NAME"

if [ ! -d "$PROJECT_NOTES" ]; then
  exit 0
fi

# Tìm session note mới nhất
LATEST=$(ls "$PROJECT_NOTES"/*.md 2>/dev/null | sort -r | head -1)

if [ -z "$LATEST" ]; then
  exit 0
fi

FILENAME=$(basename "$LATEST")
echo "RESUME-CONTEXT: Session note gần nhất cho project '$PROJECT_NAME': $FILENAME"
echo "---"
cat "$LATEST"
echo "---"
echo "Đọc xong context trên trước khi tiếp tục."
