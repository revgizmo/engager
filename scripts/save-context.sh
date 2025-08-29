#!/bin/bash

# Save project context for linking in Cursor chats
# Generates shell, R, and combined context files under .cursor

set -euo pipefail

# Parse command line arguments
CHECK_PROJECT_MD=false
FIX_PROJECT_MD=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --check-project-md)
      CHECK_PROJECT_MD=true
      shift
      ;;
    --fix-project-md)
      FIX_PROJECT_MD=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --check-project-md    Check if PROJECT.md needs updating"
      echo "  --fix-project-md      Update PROJECT.md with current metrics"
      echo "  --dry-run            Show what would be updated without making changes"
      echo "  --help               Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

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

# Handle PROJECT.md operations
if [[ "$CHECK_PROJECT_MD" == "true" ]]; then
  echo ""
  echo "🔍 Checking PROJECT.md status..."
  ./scripts/check-project-md.sh
fi

if [[ "$FIX_PROJECT_MD" == "true" ]]; then
  echo ""
  echo "🔧 Updating PROJECT.md..."
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "   DRY RUN: Would update PROJECT.md with current metrics"
    ./scripts/update-project-md.sh --dry-run
  else
    ./scripts/update-project-md.sh
  fi
fi

echo ""
echo "🎉 Context generation complete!"
echo "================================"
echo "Context saved to $OUT_DIR/"
echo "  📄 context.md"
echo "  📊 r-context.md"
echo "  🔗 full-context.md"
echo "  💾 context_${TIMESTAMP}.md"
echo ""
if [[ "$FIX_PROJECT_MD" == "true" ]]; then
  echo "✅ PROJECT.md updated with current metrics"
else
  echo "💡 Remember to update PROJECT.md manually if project status changes."
  echo "   Use: $0 --fix-project-md"
fi
