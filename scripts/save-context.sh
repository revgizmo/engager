#!/bin/bash

# Save project context for linking in Cursor chats
# Generates shell, R, and combined context files under .cursor

set -euo pipefail

OUT_DIR=".cursor"
mkdir -p "$OUT_DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

echo "🔄 Generating project context files..."
echo "======================================"

# Generate shell context
echo "📝 Step 1/4: Generating shell context..."
./scripts/context-for-new-chat.sh > "$OUT_DIR/context.md"
echo "   ✅ Shell context generated"

# Generate R context and metrics JSON
echo "📊 Step 2/4: Generating R context and metrics..."
Rscript scripts/context-for-new-chat.R > "$OUT_DIR/r-context.md"
echo "   ✅ R context and metrics generated"

# Combine for convenience
echo "🔗 Step 3/4: Combining context files..."
cat "$OUT_DIR/context.md" "$OUT_DIR/r-context.md" > "$OUT_DIR/full-context.md"
echo "   ✅ Combined context created"

# Create timestamped backup
echo "💾 Step 4/4: Creating timestamped backup..."
cp "$OUT_DIR/full-context.md" "$OUT_DIR/context_${TIMESTAMP}.md"
echo "   ✅ Timestamped backup created"

echo ""
echo "🎉 Context generation complete!"
echo "================================"
echo "Context saved to $OUT_DIR/"
echo "  📄 context.md"
echo "  📊 r-context.md"
echo "  🔗 full-context.md"
echo "  💾 context_${TIMESTAMP}.md"
echo ""
echo "💡 Remember to update PROJECT.md manually if project status changes."
