#!/bin/bash

# Save project context for linking in Cursor chats
# Generates shell, R, and combined context files under .cursor

set -euo pipefail

OUT_DIR=".cursor"
mkdir -p "$OUT_DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Generate shell context
./scripts/context-for-new-chat.sh > "$OUT_DIR/context.md"

# Generate R context and metrics JSON
Rscript scripts/context-for-new-chat.R > "$OUT_DIR/r-context.md"

# Combine for convenience
cat "$OUT_DIR/context.md" "$OUT_DIR/r-context.md" > "$OUT_DIR/full-context.md"
cp "$OUT_DIR/full-context.md" "$OUT_DIR/context_${TIMESTAMP}.md"

echo "Context saved to $OUT_DIR/"
echo "  - context.md"
echo "  - r-context.md"
echo "  - full-context.md"
echo "  - context_${TIMESTAMP}.md"
echo "Remember to update PROJECT.md manually if project status changes."
