# Issue #470: Vignette Cleanup for CRAN Submission - Implementation Guide

## Overview
This guide provides step-by-step instructions for updating all vignettes to use only essential functions, ensuring they pass R CMD check and provide clear user guidance for the simplified API surface.

## Environment Assessment
- **Environment Type**: Full R Package Development
- **Capabilities**: Build, test, develop, lint, document, benchmark
- **Tools Available**: R, devtools, roxygen2, testthat, lintr, styler, covr
- **Current Status**: Vignettes failing due to deprecated function usage

## Implementation Commands

### Phase 1: Investigation and Analysis

#### Step 1: Create Branch and Setup
```bash
# Create feature branch
git checkout -b feature/issue-470-vignette-cleanup
git push -u origin feature/issue-470-vignette-cleanup

# Run environment check
./scripts/ai-environment-check.sh

# Load package for development
Rscript -e "devtools::load_all()"
```

#### Step 2: Identify Vignette Failures
```bash
# Check current vignette status
Rscript -e "devtools::build_vignettes()" > vignette_build.log 2>&1

# Extract failure summary
grep -E "(Error|Warning|Failed)" vignette_build.log | head -20

# Count total failures
grep -c "Error\|Warning\|Failed" vignette_build.log

# List all vignette files
ls -la vignettes/
```

#### Step 3: Analyze Deprecated Function Usage
```bash
# Check which functions are referenced in vignettes but not exported
Rscript -e "
library(devtools)
load_all()
vignette_files <- list.files('vignettes', pattern = '.*\\.Rmd$', full.names = TRUE)
for (file in vignette_files) {
  content <- readLines(file)
  func_calls <- grep('\\w+\\(', content, value = TRUE)
  print(paste('File:', basename(file)))
  print(head(func_calls, 10))
  print('---')
}
"
```

### Phase 2: Essential Function Analysis

#### Step 4: Document Current Exported Functions
```bash
# Check NAMESPACE for exported functions
grep "^export(" NAMESPACE | wc -l

# List all exported functions
grep "^export(" NAMESPACE

# Get function categories
Rscript -e "
library(devtools)
load_all()
essential_functions <- get_essential_functions()
deprecated_functions <- get_deprecated_functions()
print('Essential Functions:')
print(essential_functions)
print('Deprecated Functions:')
print(head(deprecated_functions, 10))
"
```

#### Step 5: Create Function Migration Map
```bash
# Create migration mapping file
cat > vignette_migration_map.md << 'EOF'
# Vignette Function Migration Map

## Essential Functions (Use These)
- analyze_transcripts() - Main user-facing function
- process_zoom_transcript() - Core transcript processing
- load_zoom_transcript() - Basic transcript loading
- consolidate_transcript() - Transcript consolidation
- summarize_transcript_metrics() - Basic metrics
- plot_users() - Basic visualization
- write_metrics() - Basic output
- ensure_privacy() - Privacy protection
- set_privacy_defaults() - Privacy configuration
- privacy_audit() - Privacy validation

## Deprecated Functions (Replace These)
- [List deprecated functions found in vignettes]
- [Map to essential function equivalents]

## Migration Examples
- [Show before/after examples for each deprecated function]
EOF
```

### Phase 3: Vignette Updates

#### Step 6: Update Individual Vignettes
```bash
# For each vignette file, update deprecated function usage
# Example for one vignette:

# 1. Identify deprecated functions in vignette
grep -n "deprecated_function_name" vignettes/example_vignette.Rmd

# 2. Replace with essential function equivalent
# Edit the file to replace deprecated functions

# 3. Test the updated vignette
Rscript -e "
library(devtools)
load_all()
# Test vignette code chunks
"
```

#### Step 7: Systematic Vignette Updates
```bash
# Create script to update all vignettes
cat > update_vignettes.R << 'EOF'
# Script to update vignettes systematically

library(devtools)
load_all()

# Get essential and deprecated functions
essential_functions <- get_essential_functions()
deprecated_functions <- get_deprecated_functions()

# List all vignette files
vignette_files <- list.files("vignettes", pattern = ".*\\.Rmd$", full.names = TRUE)

# Process each vignette
for (file in vignette_files) {
  cat("Processing:", basename(file), "\n")
  
  # Read vignette content
  content <- readLines(file)
  
  # Check for deprecated function usage
  deprecated_used <- character(0)
  for (dep_func in deprecated_functions) {
    if (any(grepl(dep_func, content))) {
      deprecated_used <- c(deprecated_used, dep_func)
    }
  }
  
  if (length(deprecated_used) > 0) {
    cat("  Deprecated functions found:", paste(deprecated_used, collapse = ", "), "\n")
    # TODO: Implement replacement logic
  } else {
    cat("  No deprecated functions found\n")
  }
}
EOF

# Run the update script
Rscript update_vignettes.R
```

### Phase 4: Documentation Updates

#### Step 8: Update README.md
```bash
# Update README to reflect simplified API
Rscript -e "devtools::build_readme()"

# Check if README needs manual updates
grep -n "deprecated_function" README.md
```

#### Step 9: Create Migration Guide
```bash
# Create comprehensive migration guide
cat > MIGRATION_GUIDE.md << 'EOF'
# Function Migration Guide

## Overview
This guide helps users migrate from deprecated functions to their essential function equivalents.

## Quick Start
The main function for most users is `analyze_transcripts()`:

```r
# Load and analyze transcripts
results <- analyze_transcripts(
  transcript_files = c("session1.vtt", "session2.vtt"),
  roster_file = "roster.csv"
)

# View results
print(results)
```

## Function Replacements
[Detailed replacement guide for each deprecated function]

## Examples
[Working examples using only essential functions]
EOF
```

### Phase 5: Validation and Testing

#### Step 10: Test All Vignettes
```bash
# Build all vignettes
Rscript -e "devtools::build_vignettes()"

# Check for errors
if [ $? -eq 0 ]; then
  echo "✅ All vignettes built successfully"
else
  echo "❌ Vignette build failed"
  exit 1
fi
```

#### Step 11: Run R CMD Check
```bash
# Run full package check
Rscript -e "devtools::check()"

# Check specifically for vignette issues
Rscript -e "devtools::check()" 2>&1 | grep -i vignette
```

#### Step 12: Test Vignette Examples
```bash
# Test each vignette individually
for vignette in vignettes/*.Rmd; do
  echo "Testing vignette: $(basename $vignette)"
  Rscript -e "
    library(devtools)
    load_all()
    # Extract and test code chunks from vignette
    # [Implementation needed]
  "
done
```

### Phase 6: Final Validation

#### Step 13: Comprehensive Testing
```bash
# Run all validation steps
Rscript -e "devtools::test()"
Rscript -e "devtools::check()"
Rscript -e "devtools::build_vignettes()"

# Check for any remaining issues
Rscript -e "lintr::lint_package()"
```

#### Step 14: Documentation Validation
```bash
# Regenerate documentation
Rscript -e "devtools::document()"

# Check documentation consistency
Rscript -e "
library(devtools)
load_all()
# Verify all documented functions are exported
# Verify all exported functions are documented
"
```

## Success Criteria Validation

### Primary Success Criteria
- [ ] Vignette Success Rate: 10/10 vignettes pass R CMD check
- [ ] API Surface: All examples use only essential functions
- [ ] User Migration: Clear guidance for deprecated function users
- [ ] Documentation: README and vignettes reflect simplified API
- [ ] CRAN Compliance: All examples run without errors

### Validation Commands
```bash
# Test 1: All vignettes build
Rscript -e "devtools::build_vignettes()" | grep -c "Error\|Failed" # Should be 0

# Test 2: Package builds
Rscript -e "devtools::check()" | grep -c "ERROR\|WARNING" # Should be 0

# Test 3: No deprecated functions in vignettes
grep -r "deprecated_function_name" vignettes/ | wc -l # Should be 0

# Test 4: All examples use essential functions
Rscript -e "
library(devtools)
load_all()
essential_functions <- get_essential_functions()
# Check that vignettes only use essential functions
# [Implementation needed]
"
```

## Troubleshooting

### Common Issues
1. **Vignette build failures**: Check for missing dependencies or syntax errors
2. **Deprecated function usage**: Replace with essential function equivalents
3. **Documentation inconsistencies**: Ensure all docs reflect current API
4. **Example failures**: Test all examples with realistic data

### Debug Commands
```bash
# Check vignette build errors
Rscript -e "devtools::build_vignettes()" 2>&1 | grep -A 5 -B 5 "Error"

# Check specific vignette
Rscript -e "
library(devtools)
load_all()
# Test specific vignette code
"

# Check function availability
Rscript -e "library(devtools); load_all(); ls('package:zoomstudentengagement')"
```

## Environment-Specific Notes

### Full R Package Development Environment
- Can build and test vignettes
- Can run R CMD check
- Can generate documentation
- Can test all examples
- Can validate package compliance

### Validation Requirements
- All vignettes must build successfully
- All examples must run without errors
- No deprecated functions in vignettes
- Clear migration guidance provided
- Documentation consistency maintained

This implementation guide provides a systematic approach to updating all vignettes for CRAN submission readiness.
