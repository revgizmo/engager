#!/bin/bash

# Check if PROJECT.md needs updating
set -euo pipefail

echo "🔍 Checking PROJECT.md status..."

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

# Read PROJECT.md values
if [[ ! -f "PROJECT.md" ]]; then
  echo "❌ PROJECT.md not found"
  exit 1
fi

PROJECT_COVERAGE=$(grep "Test Coverage" PROJECT.md | head -1 | sed 's/.*Test Coverage.*: \([0-9.]*\)%.*/\1/' 2>/dev/null || echo "0")
PROJECT_TESTS=$(grep "Test Suite" PROJECT.md | head -1 | sed 's/.*Test Suite.*: \*\*\([0-9]*\) tests.*/\1/' 2>/dev/null || echo "0")
PROJECT_RCMD=$(grep "R CMD Check" PROJECT.md | head -1 | sed 's/.*R CMD Check.*: \*\*.*, \([0-9]*\) notes.*/\1/' 2>/dev/null || echo "0")

# Clean up extracted values
PROJECT_COVERAGE=$(echo "$PROJECT_COVERAGE" | tr -d '[:space:]' | sed 's/[^0-9.]//g')
PROJECT_TESTS=$(echo "$PROJECT_TESTS" | tr -d '[:space:]' | sed 's/[^0-9]//g')
PROJECT_RCMD=$(echo "$PROJECT_RCMD" | tr -d '[:space:]' | sed 's/[^0-9]//g')

# Compare values
NEEDS_UPDATE=false

echo "📊 Current Metrics vs PROJECT.md:"
echo "   Test Coverage: ${CURRENT_COVERAGE}% vs ${PROJECT_COVERAGE}%"
echo "   Test Suite: ${CURRENT_TESTS} tests vs ${PROJECT_TESTS} tests"
echo "   R CMD Notes: ${CURRENT_RCMD_NOTES} vs ${PROJECT_RCMD}"

if [[ "$CURRENT_COVERAGE" != "$PROJECT_COVERAGE" ]]; then
  echo "   ⚠️  Coverage mismatch"
  NEEDS_UPDATE=true
fi

if [[ "$CURRENT_TESTS" != "$PROJECT_TESTS" ]]; then
  echo "   ⚠️  Test count mismatch"
  NEEDS_UPDATE=true
fi

if [[ "$CURRENT_RCMD_NOTES" != "$PROJECT_RCMD" ]]; then
  echo "   ⚠️  R CMD notes mismatch"
  NEEDS_UPDATE=true
fi

if [[ "$NEEDS_UPDATE" == "true" ]]; then
  echo ""
  echo "❌ PROJECT.md needs updating"
  echo "   Run: ./scripts/save-context.sh --fix-project-md"
  exit 1
else
  echo ""
  echo "✅ PROJECT.md is up to date"
  exit 0
fi
