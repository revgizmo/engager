#!/bin/bash
set -euo pipefail

echo "🔍 Validating context updates..."

# Validate metrics JSON
if [[ ! -f ".cursor/metrics.json" ]]; then
  echo "❌ Missing .cursor/metrics.json"
  exit 1
fi

if ! jq empty .cursor/metrics.json 2>/dev/null; then
  echo "❌ Invalid .cursor/metrics.json"
  exit 1
fi

# Validate context files
for file in "context.md" "r-context.md" "full-context.md"; do
  if [[ ! -f ".cursor/$file" ]]; then
    echo "❌ Missing .cursor/$file"
    exit 1
  fi
done

# Validate PROJECT.md has current metrics
if ! grep -q "Test Coverage.*90.48%" PROJECT.md; then
  echo "❌ PROJECT.md missing current test coverage"
  exit 1
fi

if ! grep -q "Test Suite.*1875 tests" PROJECT.md; then
  echo "❌ PROJECT.md missing current test suite info"
  exit 1
fi

# Validate issue section
if ! grep -q "### All Open Issues" PROJECT.md; then
  echo "❌ Missing All Open Issues section in PROJECT.md"
  exit 1
fi

# Validate issue counts
if ! grep -q "High Priority" PROJECT.md; then
  echo "❌ Missing High Priority section in PROJECT.md"
  exit 1
fi

if ! grep -q "Medium Priority" PROJECT.md; then
  echo "❌ Missing Medium Priority section in PROJECT.md"
  exit 1
fi

if ! grep -q "Low Priority" PROJECT.md; then
  echo "❌ Missing Low Priority section in PROJECT.md"
  exit 1
fi

if ! grep -q "Unprioritized" PROJECT.md; then
  echo "❌ Missing Unprioritized section in PROJECT.md"
  exit 1
fi

# Validate AI review context
if [[ ! -f ".cursor/ai-review-context.md" ]]; then
  echo "❌ Missing AI review context file"
  exit 1
fi

# Validate AI review context content
if ! grep -q "Current Project State" .cursor/ai-review-context.md; then
  echo "❌ AI review context missing project state"
  exit 1
fi

if ! grep -q "Strategic Sections Requiring Review" .cursor/ai-review-context.md; then
  echo "❌ AI review context missing review instructions"
  exit 1
fi

echo "✅ All context updates validated successfully"
