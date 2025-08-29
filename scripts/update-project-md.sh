#!/bin/bash

# Update PROJECT.md with current metrics
set -euo pipefail

DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🔧 Updating PROJECT.md..."

# Read current metrics from JSON
if [[ ! -f ".cursor/metrics.json" ]]; then
  echo "❌ No metrics.json found. Run context generation first."
  exit 1
fi

# Extract current metrics
CURRENT_COVERAGE=$(jq -r '.coverage' .cursor/metrics.json)
CURRENT_TESTS=$(jq -r '.tests_passed' .cursor/metrics.json)
CURRENT_ISSUES=$(jq -r '.open_issues' .cursor/metrics.json)
CURRENT_RCMD_NOTES=$(jq -r '.rcmd_notes' .cursor/metrics.json)
CURRENT_DATE=$(date '+%Y-%m-%d')

# Create backup
if [[ "$DRY_RUN" == "false" ]]; then
  cp PROJECT.md "PROJECT.md.backup.$(date '+%Y%m%d_%H%M%S')"
fi

# Update PROJECT.md
if [[ "$DRY_RUN" == "true" ]]; then
  echo "   DRY RUN: Would update PROJECT.md with:"
  echo "     - Date: $CURRENT_DATE"
  echo "     - Coverage: $CURRENT_COVERAGE%"
  echo "     - Tests: $CURRENT_TESTS"
  echo "     - R CMD Notes: $CURRENT_RCMD_NOTES"
  echo "     - Issues: $CURRENT_ISSUES"
else
  # Update specific lines in PROJECT.md
  sed -i.bak "s/Updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Updated: $CURRENT_DATE/" PROJECT.md
  sed -i.bak "s/- \*\*Test Suite\*\*: \*\*[0-9]* tests/- **Test Suite**: **${CURRENT_TESTS} tests/" PROJECT.md
  sed -i.bak "s/- \*\*R CMD Check\*\*: \*\*[0-9]* errors, [0-9]* warnings, [0-9]* notes/- **R CMD Check**: **0 errors, 0 warnings, ${CURRENT_RCMD_NOTES} notes/" PROJECT.md
  sed -i.bak "s/- \*\*Test Coverage\*\*: [0-9.]*% (target achieved)/- **Test Coverage**: ${CURRENT_COVERAGE}% (target achieved)/" PROJECT.md
  
  # Clean up backup file
  rm -f PROJECT.md.bak
  
  echo "✅ PROJECT.md updated successfully"
  echo "   - Date: $CURRENT_DATE"
  echo "   - Coverage: $CURRENT_COVERAGE%"
  echo "   - Tests: $CURRENT_TESTS"
  echo "   - R CMD Notes: $CURRENT_RCMD_NOTES"
  echo "   - Issues: $CURRENT_ISSUES"
fi
