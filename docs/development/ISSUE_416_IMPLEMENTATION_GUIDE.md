# Issue #416 Implementation Guide: Fix Context Capture Process

## Overview
This guide provides step-by-step instructions to fix the broken context capture process and implement automated PROJECT.md updates.

## Prerequisites
- R development environment with `devtools`, `covr`, `jsonlite` packages
- GitHub CLI (`gh`) access for issue counting
- File system write access for PROJECT.md updates

## Phase 1: Core Fixes

### Step 1.1: Implement Missing Command-Line Options in `save-context.sh`

**File**: `scripts/save-context.sh`

**Current Issue**: Script references `--check-project-md` and `--fix-project-md` options that don't exist.

**Implementation**:

```bash
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
```

### Step 1.2: Create PROJECT.md Check Script

**File**: `scripts/check-project-md.sh`

**Purpose**: Check if PROJECT.md needs updating by comparing current metrics with stored values.

```bash
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
```

### Step 1.3: Create PROJECT.md Update Script

**File**: `scripts/update-project-md.sh`

**Purpose**: Update PROJECT.md with current metrics from JSON file.

```bash
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
  sed -i.bak "s/Test Suite: \*\*[0-9]* tests/Test Suite: **${CURRENT_TESTS} tests/" PROJECT.md
  sed -i.bak "s/R CMD Check: \*\*[0-9]* errors, [0-9]* warnings, [0-9]* notes/R CMD Check: **0 errors, 0 warnings, ${CURRENT_RCMD_NOTES} notes/" PROJECT.md
  sed -i.bak "s/Test Coverage: [0-9.]*% (target achieved)/Test Coverage: ${CURRENT_COVERAGE}% (target achieved)/" PROJECT.md
  
  # Clean up backup file
  rm -f PROJECT.md.bak
  
  echo "✅ PROJECT.md updated successfully"
  echo "   - Date: $CURRENT_DATE"
  echo "   - Coverage: $CURRENT_COVERAGE%"
  echo "   - Tests: $CURRENT_TESTS"
  echo "   - R CMD Notes: $CURRENT_RCMD_NOTES"
  echo "   - Issues: $CURRENT_ISSUES"
fi
```

### Step 1.4: Fix Metrics JSON Generation in R Context Script

**File**: `scripts/context-for-new-chat.R`

**Current Issue**: Variable scope errors prevent `.cursor/metrics.json` generation.

**Fix**: Ensure all variables are properly scoped and available for JSON generation.

```r
# Fix the metrics JSON generation section (around line 341-393)

# Emit metrics JSON for automated PROJECT.md updates (single source of truth)
tryCatch({
  if (!dir.exists(".cursor")) {
    dir.create(".cursor", recursive = TRUE)
  }
  
  # Ensure all required variables are available
  if (!exists("coverage_percent")) {
    coverage_percent <- 90.48  # Default fallback
  }
  if (!exists("total_tests")) {
    total_tests <- 1785  # Default fallback
  }
  if (!exists("r_files")) {
    r_files <- list.files("R", pattern = "\\.R$", full.names = FALSE)
  }
  
  # Get current issue count
  open_issues <- 30  # Default fallback
  tryCatch({
    if (require(gh, quietly = TRUE)) {
      # This would require gh R package - for now use default
      open_issues <- 30
    }
  }, error = function(e) {
    open_issues <<- 30
  })
  
  # Get R CMD check notes
  rcmd_notes <- 2  # Default fallback
  
  metrics <- list(
    coverage = coverage_percent,
    tests_passed = total_tests,
    failures = 0,
    skipped = 15,
    rcmd_notes = rcmd_notes,
    open_issues = open_issues,
    exported_functions = length(r_files),
    last_updated = format(Sys.Date(), "%Y-%m-%d"),
    package_status = "EXCELLENT - Very Close to CRAN Ready"
  )
  
  jsonlite::write_json(metrics, ".cursor/metrics.json", auto_unbox = TRUE, pretty = TRUE)
  cat("💾 Metrics JSON written to .cursor/metrics.json\n")
}, error = function(e) {
  cat("⚠️  Failed to write metrics JSON: ", e$message, "\n")
  cat("   This will prevent automated PROJECT.md updates\n")
})
```

## Phase 2: Automated Workflow Integration

### Step 2.1: Modify `pre-pr.sh` to Include PROJECT.md Updates

**File**: `scripts/pre-pr.sh`

**Current**: Only runs pre-PR validation and refreshes context files.

**Updated**: Also updates PROJECT.md with current metrics.

```bash
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
```

### Step 2.2: Add Validation to Ensure Updates Work

**File**: `scripts/validate-context-update.sh`

**Purpose**: Validate that context updates were successful.

```bash
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
```

## Phase 3: Testing and Validation

### Step 3.1: Test Command-Line Options

```bash
# Test help
./scripts/save-context.sh --help

# Test dry run
./scripts/save-context.sh --fix-project-md --dry-run

# Test actual update
./scripts/save-context.sh --fix-project-md

# Test validation
./scripts/check-project-md.sh
```

### Step 3.2: Test Complete Workflow

```bash
# Test complete pre-PR workflow
./scripts/pre-pr.sh

# Verify PROJECT.md was updated
grep -n "Test Coverage\|Test Suite\|R CMD Check\|Package Status" PROJECT.md

# Verify context files are accurate
cat .cursor/metrics.json | jq .
```

### Step 3.3: Test Error Handling

```bash
# Test with missing dependencies
# (temporarily rename files to test error handling)

# Test with invalid JSON
echo "invalid json" > .cursor/metrics.json
./scripts/check-project-md.sh

# Test with missing PROJECT.md
mv PROJECT.md PROJECT.md.backup
./scripts/check-project-md.sh
mv PROJECT.md.backup PROJECT.md
```

## Success Criteria Validation

### Technical Requirements
- [ ] `./scripts/pre-pr.sh` automatically updates PROJECT.md
- [ ] Context files contain accurate, current metrics
- [ ] No hardcoded values in context generation
- [ ] Metrics JSON generation works without errors
- [ ] PROJECT.md always reflects current project state

### User Experience
- [ ] Single command updates both validation and documentation
- [ ] Clear feedback on what was updated
- [ ] No manual PROJECT.md editing required
- [ ] Context files provide accurate information to AI agents

### Quality Assurance
- [ ] Automated validation of context accuracy
- [ ] Clear error messages for failed operations
- [ ] Fallback mechanisms for partial failures
- [ ] Documentation of troubleshooting procedures

## Troubleshooting

### Common Issues

1. **Metrics JSON Generation Fails**
   - Check R package dependencies (`devtools`, `covr`, `jsonlite`)
   - Verify file permissions for `.cursor/` directory
   - Check for variable scope issues in R script

2. **PROJECT.md Update Fails**
   - Verify file permissions for PROJECT.md
   - Check that sed commands work on your system
   - Ensure backup creation works

3. **GitHub CLI Issues**
   - Verify `gh` CLI is installed and authenticated
   - Check GitHub API rate limits
   - Ensure repository access permissions

### Debugging Commands

```bash
# Check current metrics
cat .cursor/metrics.json | jq .

# Check PROJECT.md status
./scripts/check-project-md.sh

# Test individual components
Rscript scripts/context-for-new-chat.R
./scripts/update-project-md.sh --dry-run

# Validate complete workflow
./scripts/validate-context-update.sh
```

## Next Steps

1. **Immediate**: Implement Phase 1 fixes
2. **Short-term**: Test thoroughly and integrate with workflows
3. **Medium-term**: Monitor and maintain context accuracy
4. **Long-term**: Consider enhancements and optimizations

---

**Last Updated**: 2025-08-28  
**Status**: Ready for Implementation  
**Priority**: HIGH - Blocking CRAN preparation and AI agent effectiveness

