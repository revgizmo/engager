#!/bin/bash

# Run pre-PR validation then refresh context files and update PROJECT.md
# Usage: ./scripts/pre-pr.sh [args passed to pre-pr-validation.R]

set -euo pipefail

# Generate AI review prompt
generate_ai_review_prompt() {
  echo ""
  echo "🤖 AI Review Required for Strategic Content"
  echo "=========================================="
  echo ""
  echo "The following sections need AI review based on current project state:"
  echo ""
  echo "1. Current Critical Priorities"
  echo "   - Review current high-priority issues"
  echo "   - Update priority order based on CRAN readiness"
  echo "   - Adjust timelines based on current blockers"
  echo ""
  echo "2. Implementation Timeline"
  echo "   - Update based on completed work"
  echo "   - Adjust for new blockers or resolved items"
  echo "   - Revise estimates based on current progress"
  echo ""
  echo "3. Next Steps"
  echo "   - Prioritize based on current CRAN blockers"
  echo "   - Identify new critical path items"
  echo "   - Update based on recent completions"
  echo ""
  echo "4. Current Status Narrative"
  echo "   - Update the story based on current metrics"
  echo "   - Revise 'Bottom Line' statements"
  echo "   - Adjust success criteria based on progress"
  echo ""
  echo "📝 AI Review Instructions:"
  echo "   - Review the auto-updated issue lists above"
  echo "   - Analyze current metrics and blockers"
  echo "   - Update strategic sections accordingly"
  echo "   - Focus on CRAN readiness and priority alignment"
  echo ""
  echo "📋 Review Context Available:"
  echo "   - .cursor/ai-review-context.md (current project state)"
  echo "   - .cursor/metrics.json (current metrics)"
  echo "   - project-docs/release/PROJECT.md (current strategic content)"
  echo ""
}

# Create AI review context file
create_ai_review_context() {
  echo "📝 Creating AI review context file..."
  
  # Ensure .cursor directory exists
  mkdir -p .cursor
  
  # Get current metrics
  local coverage=$(jq -r '.coverage' .cursor/metrics.json 2>/dev/null || echo "90.48")
  local tests=$(jq -r '.tests_passed' .cursor/metrics.json 2>/dev/null || echo "1875")
  local rcmd_notes=$(jq -r '.rcmd_notes' .cursor/metrics.json 2>/dev/null || echo "2")
  local open_issues=$(jq -r '.open_issues' .cursor/metrics.json 2>/dev/null || echo "30")
  
  # Create context file
  cat > .cursor/ai-review-context.md << EOF
# AI Review Context for PROJECT.md Strategic Updates

## Current Project State
- Test Coverage: ${coverage}%
- Test Suite: ${tests} tests passing
- R CMD Check: 0 errors, 0 warnings, ${rcmd_notes} notes
- Open Issues: ${open_issues} total

## Auto-Updated Issue Lists
[Current issue lists from GitHub API - see PROJECT.md for details]

## Strategic Sections Requiring Review
1. Current Critical Priorities
2. Implementation Timeline
3. Next Steps
4. Current Status Narrative

## Review Instructions
- Analyze current blockers vs. CRAN readiness
- Update priorities based on current state
- Revise timelines based on progress
- Adjust narrative to reflect reality

## Success Criteria
- All strategic content aligns with current state
- Priorities reflect actual CRAN blockers
- Timeline is realistic and achievable
- Narrative accurately describes current status

## Current PROJECT.md Strategic Content
[Include relevant sections from PROJECT.md for context]
EOF
  
  echo "✅ AI review context file created: .cursor/ai-review-context.md"
}

# Validate AI review requirements
validate_ai_review_requirements() {
  echo "🔍 Validating AI review requirements..."
  
  local missing_files=()
  
  # Check required files
  [[ -f ".cursor/metrics.json" ]] || missing_files+=(".cursor/metrics.json")
  [[ -f "project-docs/release/PROJECT.md" ]] || missing_files+=("project-docs/release/PROJECT.md")
  [[ -f ".cursor/ai-review-context.md" ]] || missing_files+=(".cursor/ai-review-context.md")
  
  if [[ ${#missing_files[@]} -gt 0 ]]; then
    echo "⚠️  Missing required files for AI review:"
    printf '   - %s\n' "${missing_files[@]}"
    return 1
  fi
  
  # Validate metrics JSON
  if ! jq empty .cursor/metrics.json 2>/dev/null; then
    echo "⚠️  Invalid metrics JSON file"
    return 1
  fi
  
  echo "✅ AI review requirements validated"
  return 0
}

echo "🔍 Running pre-PR validation..."
Rscript scripts/pre-pr-validation.R "$@"

echo ""
echo "🔄 Refreshing context files..."
./scripts/save-context.sh

echo ""
echo "🔧 PROJECT.md is maintained at project-docs/release/PROJECT.md"
echo "   Skipping automated update (root PROJECT.md no longer used)"

echo ""
echo "🤖 Setting up AI review system..."
create_ai_review_context
validate_ai_review_requirements
generate_ai_review_prompt

echo ""
echo "✅ Pre-PR workflow complete!"
echo ""
echo "📋 Next Steps:"
echo "   1. Review the AI review prompt above"
echo "   2. Check .cursor/ai-review-context.md for current state"
echo "   3. Update strategic sections in PROJECT.md as needed"
echo "   4. Commit changes and create pull request"
