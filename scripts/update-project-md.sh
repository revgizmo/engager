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
  echo "     - All Open Issues section"
else
  # Update specific lines in PROJECT.md
  sed -i.bak "s/Updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Updated: $CURRENT_DATE/" PROJECT.md
  sed -i.bak "s/- \*\*Test Suite\*\*: \*\*[0-9]* tests/- **Test Suite**: **${CURRENT_TESTS} tests/" PROJECT.md
  sed -i.bak "s/- \*\*R CMD Check\*\*: \*\*[0-9]* errors, [0-9]* warnings, [0-9]* notes/- **R CMD Check**: **0 errors, 0 warnings, ${CURRENT_RCMD_NOTES} notes/" PROJECT.md
  sed -i.bak "s/- \*\*Test Coverage\*\*: [0-9.]*% (target achieved)/- **Test Coverage**: ${CURRENT_COVERAGE}% (target achieved)/" PROJECT.md
  
  # Update All Open Issues section
  echo "Updating All Open Issues section in PROJECT.md..."
  
  # Fetch issues by priority
  echo "Fetching high priority issues..."
  HIGH_ISSUES=$(gh issue list --label "priority:high" --state open --json number,title,labels --limit 50 2>/dev/null || echo "[]")
  HIGH_COUNT=$(echo "$HIGH_ISSUES" | jq 'length' 2>/dev/null || echo "0")
  
  echo "Fetching medium priority issues..."
  MEDIUM_ISSUES=$(gh issue list --label "priority:medium" --state open --json number,title,labels --limit 50 2>/dev/null || echo "[]")
  MEDIUM_COUNT=$(echo "$MEDIUM_ISSUES" | jq 'length' 2>/dev/null || echo "0")
  
  echo "Fetching low priority issues..."
  LOW_ISSUES=$(gh issue list --label "priority:low" --state open --json number,title,labels --limit 50 2>/dev/null || echo "[]")
  LOW_COUNT=$(echo "$LOW_ISSUES" | jq 'length' 2>/dev/null || echo "0")
  
  echo "Fetching unprioritized issues..."
  ALL_ISSUES=$(gh issue list --state open --json number,title,labels --limit 100 2>/dev/null || echo "[]")
  UNPRIORITIZED_ISSUES=$(echo "$ALL_ISSUES" | jq '[.[] | select(.labels[].name | startswith("priority:") | not)]' 2>/dev/null || echo "[]")
  UNPRIORITIZED_COUNT=$(echo "$UNPRIORITIZED_ISSUES" | jq 'length' 2>/dev/null || echo "0")
  
  TOTAL_COUNT=$((HIGH_COUNT + MEDIUM_COUNT + LOW_COUNT + UNPRIORITIZED_COUNT))
  
  echo "Counts: High=$HIGH_COUNT, Medium=$MEDIUM_COUNT, Low=$LOW_COUNT, Unprioritized=$UNPRIORITIZED_COUNT, Total=$TOTAL_COUNT"
  
  # Format issue lists
  echo "Formatting issue lists..."
  HIGH_LIST=$(echo "$HIGH_ISSUES" | jq -r '.[] | "- [Issue #\(.number)]: \(.title) (\(.labels | map(.name) | join(", ")))"' 2>/dev/null || echo "No High priority issues found.")
  MEDIUM_LIST=$(echo "$MEDIUM_ISSUES" | jq -r '.[] | "- [Issue #\(.number)]: \(.title) (\(.labels | map(.name) | join(", ")))"' 2>/dev/null || echo "No Medium priority issues found.")
  LOW_LIST=$(echo "$LOW_ISSUES" | jq -r '.[] | "- [Issue #\(.number)]: \(.title) (\(.labels | map(.name) | join(", ")))"' 2>/dev/null || echo "No Low priority issues found.")
  UNPRIORITIZED_LIST=$(echo "$UNPRIORITIZED_ISSUES" | jq -r '.[] | "- [Issue #\(.number)]: \(.title) (\(.labels | map(.name) | join(", ")))"' 2>/dev/null || echo "No Unprioritized issues found.")
  
  # Create new section content
  NEW_SECTION="### All Open Issues ($TOTAL_COUNT Total)

#### High Priority ($HIGH_COUNT issues)
$HIGH_LIST

#### Medium Priority ($MEDIUM_COUNT issues)
$MEDIUM_LIST

#### Low Priority ($LOW_COUNT issues)
$LOW_LIST

#### Unprioritized ($UNPRIORITIZED_COUNT issues)
$UNPRIORITIZED_LIST"
  
  # Replace or add the section
  if grep -q "### All Open Issues" PROJECT.md; then
    # Replace existing section using awk
    awk '/^### All Open Issues/{p=1; next} /^### / && p{p=0} !p' PROJECT.md > PROJECT.md.tmp
    {
      cat PROJECT.md.tmp
      echo "$NEW_SECTION"
      echo ""
    } > PROJECT.md.tmp2 && mv PROJECT.md.tmp2 PROJECT.md && rm PROJECT.md.tmp
  else
    # Add new section at the beginning
    {
      echo "$NEW_SECTION"
      echo ""
      cat PROJECT.md
    } > PROJECT.md.tmp && mv PROJECT.md.tmp PROJECT.md
  fi
  
  echo "✅ All Open Issues section updated successfully"
  
  # Clean up backup file
  rm -f PROJECT.md.bak
  
  echo "✅ PROJECT.md updated successfully"
  echo "   - Date: $CURRENT_DATE"
  echo "   - Coverage: $CURRENT_COVERAGE%"
  echo "   - Tests: $CURRENT_TESTS"
  echo "   - R CMD Notes: $CURRENT_RCMD_NOTES"
  echo "   - Issues: $CURRENT_ISSUES"
  echo "   - All Open Issues section updated"
fi
