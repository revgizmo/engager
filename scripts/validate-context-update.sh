#!/bin/bash

# Validate that context updates were successful
set -euo pipefail

echo "🔍 Validating context updates..."

# Check if metrics.json exists and is valid
if [[ ! -f ".cursor/metrics.json" ]]; then
  echo "❌ metrics.json not found"
  exit 1
fi

# Validate JSON structure
if ! jq empty .cursor/metrics.json 2>/dev/null; then
  echo "❌ metrics.json is not valid JSON"
  exit 1
fi

# Check if PROJECT.md was updated
if ! ./scripts/check-project-md.sh; then
  echo "❌ PROJECT.md validation failed"
  exit 1
fi

# Check if context files exist
for file in "context.md" "r-context.md" "full-context.md"; do
  if [[ ! -f ".cursor/$file" ]]; then
    echo "❌ Missing context file: .cursor/$file"
    exit 1
  fi
done

echo "✅ All context updates validated successfully"
