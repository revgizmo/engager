#!/bin/bash

# Run pre-PR validation then refresh context files and update PROJECT.md
# Usage: ./scripts/pre-pr.sh [args passed to pre-pr-validation.R]

set -euo pipefail

echo "🔍 Running pre-PR validation..."
Rscript scripts/pre-pr-validation.R "$@"

echo ""
echo "🔄 Refreshing context files..."
./scripts/save-context.sh

echo ""
echo "🔧 Updating PROJECT.md with current metrics..."
./scripts/update-project-md.sh

echo ""
echo "✅ Pre-PR workflow complete!"
echo "   - Validation checks passed"
echo "   - Context files refreshed"
echo "   - PROJECT.md updated with current metrics"
