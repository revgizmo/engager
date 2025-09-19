# Issue 533 Implementation Guide: README and Repository Cleanup

## Overview
This guide provides step-by-step instructions for implementing Issue #533: Cleanup README Generation and Root Directory for CRAN Submission.

## Prerequisites
- R environment with `devtools`, `roxygen2`, `testthat` packages
- Git access to the repository
- Understanding of R package development workflows
- Access to link checking tools (optional but recommended)

## Phase 1: README Modernization

### Step 1.1: Audit Current README
```bash
# Check current README content
cat README.Rmd | head -50
cat README.md | head -50

# Identify problematic content
grep -n "Cursor\|automation\|workflow" README.Rmd
grep -n "PROJECT.md\|DOCUMENTATION.md" README.Rmd
```

### Step 1.2: Remove Internal Developer Content
```bash
# Backup current README
cp README.Rmd README.Rmd.backup
cp README.md README.md.backup

# Edit README.Rmd to remove:
# - Cursor automation references
# - Internal developer workflows
# - Non-CRAN appropriate content
```

**Content to Remove**:
- Lines 47-64: Internal Cursor automation workflows
- References to missing files (`PROJECT.md`, `DOCUMENTATION.md`, `PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md`)
- Internal development processes not relevant to CRAN users

### Step 1.3: Fix Broken Links
```bash
# Update README.Rmd to:
# - Remove references to missing files
# - Update links to point to existing documentation
# - Ensure all links resolve correctly
```

**Link Updates**:
- Replace `PROJECT.md` references with appropriate status document
- Update `DOCUMENTATION.md` links to `docs/README.md` or pkgdown
- Remove references to `PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md`

### Step 1.4: Fix Badge Formatting
```bash
# Check current badge formatting
grep -n "badge\|coverage" README.Rmd

# Fix coverage badge newline issue
# Ensure all badges use HTTPS URLs
```

### Step 1.5: Test README Generation
```bash
# Generate README from Rmd
Rscript -e "devtools::build_readme()"

# Verify generated README.md
cat README.md | head -50

# Check for formatting issues
grep -n "h$" README.md  # Look for newline in coverage badge
```

### Step 1.6: Link Validation
```bash
# Install link checker (if available)
# npm install -g lychee

# Run link checker
lychee README.md

# Or use markdownlint
markdownlint README.md
```

## Phase 2: Documentation Navigation Restoration

### Step 2.1: Assess Documentation Structure
```bash
# Check current documentation structure
ls -la docs/
cat docs/README.md

# Identify missing files
ls -la | grep -E "(PROJECT\.md|DOCUMENTATION\.md)"
```

### Step 2.2: Decide on Documentation Index Strategy
**Option A: Restore DOCUMENTATION.md**
```bash
# Create new DOCUMENTATION.md
touch DOCUMENTATION.md
# Add curated index of high-value docs
```

**Option B: Update Links to docs/README.md**
```bash
# Update all references to point to docs/README.md
# Remove DOCUMENTATION.md references
```

### Step 2.3: Fix docs/README.md
```bash
# Edit docs/README.md to:
# - Remove recursive paths
# - Fix duplicated docs/development/ paths
# - Remove references to missing DOCUMENTATION.md
# - Create clean navigation structure
```

### Step 2.4: Update All Documentation References
```bash
# Find all files referencing missing documents
grep -r "PROJECT\.md" docs/ README.md
grep -r "DOCUMENTATION\.md" docs/ README.md

# Update each reference appropriately
```

## Phase 3: Repository Root Cleanup

### Step 3.1: Inventory Root Artifacts
```bash
# List all non-standard root files
ls -la | grep -v -E "(DESCRIPTION|NAMESPACE|README|LICENSE|\.gitignore|\.Rbuildignore|R/|man/|tests/|inst/|vignettes/|\.Rproj$|\.md$|\.yml$|\.yaml$)"

# Categorize files:
# - Backup files: PROJECT.md.backup.*, NAMESPACE.new, NAMESPACE.backup
# - Analysis artifacts: function_audit_report*.rds, function_dependencies_diagram.md
# - Data files: session_mapping.csv, test_data_*.rds
# - Generated files: Rplots.pdf, coverage_report.html
# - Scripts: fix_*.R, various helper scripts
# - Documentation: PR_522_APPROVAL_CHECKLIST.md
```

### Step 3.2: Create Directory Structure
```bash
# Create organized directory structure
mkdir -p backups/$(date +%Y%m%d)
mkdir -p dev/artifacts
mkdir -p scripts/maintenance
mkdir -p docs/checklists
```

### Step 3.3: Move Files by Category
```bash
# Move backup files
mv PROJECT.md.backup.* backups/$(date +%Y%m%d)/
mv NAMESPACE.new NAMESPACE.backup backups/$(date +%Y%m%d)/

# Move analysis artifacts
mv function_audit_report*.rds dev/artifacts/
mv function_dependencies_diagram.md dev/artifacts/

# Move data files (check if needed for tests first)
# mv session_mapping.csv dev/artifacts/
# mv test_data_*.rds dev/artifacts/

# Move generated files
mv Rplots.pdf dev/artifacts/
mv coverage_report.html dev/artifacts/

# Move maintenance scripts
mv fix_*.R scripts/maintenance/

# Move documentation
mv PR_522_APPROVAL_CHECKLIST.md docs/checklists/
```

### Step 3.4: Update .Rbuildignore
```bash
# Edit .Rbuildignore to:
# - Add new directories to ignore
# - Remove patterns for moved files
# - Ensure package build excludes only appropriate files

cat >> .Rbuildignore << EOF
# Development artifacts
dev/
backups/
scripts/maintenance/
docs/checklists/
EOF
```

### Step 3.5: Update Script References
```bash
# Find scripts that reference moved files
grep -r "test_data_" scripts/ tests/
grep -r "session_mapping" scripts/ tests/
grep -r "function_audit_report" scripts/ tests/

# Update paths in scripts
# sed -i 's|test_data_|dev/artifacts/test_data_|g' scripts/that/use/them
```

## Phase 4: Validation and Testing

### Step 4.1: Test Automation Workflows
```bash
# Run pre-PR validation
Rscript scripts/pre-pr-validation.R

# Check if README generation still works
Rscript -e "devtools::build_readme()"

# Verify documentation builds
Rscript -e "devtools::document()"
```

### Step 4.2: Run Package Checks
```bash
# Run full package check
Rscript -e "devtools::check()"

# Run tests
Rscript -e "devtools::test()"

# Check coverage
Rscript -e "covr::package_coverage()"
```

### Step 4.3: Update Contributor Documentation
```bash
# Update CONTRIBUTING.md with new structure
# Add section about new directory layout
# Document where to find development resources
```

### Step 4.4: Test pkgdown Integration
```bash
# Test pkgdown site generation
Rscript -e "pkgdown::build_site()"

# Check if moved docs should appear on site
# Update _pkgdown.yml if needed
```

## Validation Checklist

### README Validation
- [ ] No internal developer workflows visible to CRAN users
- [ ] All links resolve correctly
- [ ] Badges display properly without formatting issues
- [ ] Content appropriate for CRAN submission
- [ ] Generated README.md renders correctly on GitHub

### Documentation Validation
- [ ] Single reliable documentation index
- [ ] No broken internal links
- [ ] Clear navigation structure
- [ ] All references updated appropriately

### Repository Structure Validation
- [ ] Root directory contains only package-relevant files
- [ ] Moved files accessible to scripts that need them
- [ ] .Rbuildignore patterns updated correctly
- [ ] No unnecessary files in package tarball

### Automation Validation
- [ ] Pre-PR validation scripts continue working
- [ ] README generation automation intact
- [ ] Package build process unaffected
- [ ] All tests continue passing

## Success Criteria

### Immediate Success
- README appropriate for CRAN users
- All documentation links working
- Clean repository root directory
- No broken automation workflows

### Long-term Success
- Improved CRAN submission readiness
- Better contributor experience
- Maintainable repository structure
- Professional package presentation

## Troubleshooting

### Common Issues
1. **Broken Links**: Use link checker to identify and fix
2. **Automation Failures**: Check file paths in scripts
3. **Package Build Issues**: Verify .Rbuildignore patterns
4. **Test Failures**: Ensure moved data files accessible to tests

### Rollback Plan
1. Restore from backups if major issues arise
2. Revert .Rbuildignore changes
3. Move files back to original locations
4. Update script references as needed

## Resources
- **CRAN Submission Guide**: https://cran.r-project.org/web/packages/policies.html
- **R Package Development**: https://r-pkgs.org/
- **Documentation Standards**: https://style.tidyverse.org/
- **Testing Guidelines**: https://testthat.r-lib.org/
