# Package Rename Plan: zoomstudentengagement → engager

## Discovery Results

### Current Package Name
- **Current**: `zoomstudentengagement`
- **Target**: `engager`
- **Status**: Confirmed from `DESCRIPTION: Package` field

### Inventory of References

#### 1. Identity (Must Change)
- `DESCRIPTION: Package` field
- `R/zoomstudentengagement-package.R` → `R/engager-package.R`
- Package-level documentation and namespace

#### 2. Textual Mentions (Should Change)
- **README files**: `README.md`, `README.Rmd`
- **Vignettes**: All 10 vignettes in `vignettes/` directory
- **Tests**: All test files in `tests/testthat/`
- **Test scripts**: Root-level test scripts
- **NEWS.md**: Package news header
- **PROJECT.md**: Multiple references throughout

#### 3. Repo URLs/Badges (Defer with TODO)
- `DESCRIPTION: URL` and `BugReports` fields
- README badges (GitHub Actions, coverage)
- pkgdown site references

#### 4. Third-party Names/Quotes (Leave Unchanged)
- GitHub repository paths in issue links
- External references and citations

### CRAN Compliance Check
- **Name format**: ✅ `engager` is lowercase alphanumeric
- **Availability**: To be checked during preflight

### Dependencies Status
- **renv/packrat**: ❌ Not present (good - no lockfile churn)
- **RStudio project**: ✅ `zoomstudentengagement_cursor.Rproj` (will update)

## Implementation Plan

### Phase 1: Core Package Identity
1. Update `DESCRIPTION: Package` → `engager`
2. Add TODO markers above `URL:` and `BugReports:` fields
3. Rename `R/zoomstudentengagement-package.R` → `R/engager-package.R`
4. Update package documentation content
5. Regenerate `NAMESPACE` via roxygen2

### Phase 2: Documentation Updates
1. Update README files with new package name
2. Add rename note: "Renamed from `zoomstudentengagement` to `engager` (no API changes)"
3. Update all vignettes (10 files)
4. Update NEWS.md header
5. Update PROJECT.md references

### Phase 3: Test and Code Updates
1. Update all test files
2. Update root-level test scripts
3. Update helper files
4. Update `tests/testthat.R`

### Phase 4: CI and Build Configuration
1. Update workflow display names (cosmetic only)
2. Update pkgdown configuration
3. Update `.Rbuildignore` for new documentation files
4. Add TODO markers for post-repo-rename updates

### Phase 5: Validation and Documentation
1. Run roxygen2 documentation generation
2. Run full test suite
3. Run R CMD check with --as-cran
4. Build pkgdown locally
5. Create CRAN comments skeleton
6. Document results and TODOs

## Risk Assessment

### High Risk
- **Name conflict**: If `engager` already exists on CRAN
  - *Mitigation*: Preflight check, define fallback names
- **Broken functionality**: If rename breaks package loading
  - *Mitigation*: Comprehensive testing, rollback plan

### Medium Risk
- **Documentation inconsistencies**: Some references missed
  - *Mitigation*: Systematic search/replace, validation
- **CI failures**: Workflow changes causing build issues
  - *Mitigation*: Minimal changes, test thoroughly

### Low Risk
- **Style drift**: Unintended formatting changes
  - *Mitigation*: Surgical replacements, no style tools
- **Lockfile churn**: Dependency changes
  - *Mitigation*: No renv/packrat present

## Rollback Plan
- **Immediate**: Delete feature branch, no merge
- **Partial**: Revert specific commits if needed
- **Full**: Restore from main branch if catastrophic

## Success Criteria
- [ ] `DESCRIPTION: Package` is `engager`
- [ ] All internal references updated
- [ ] R CMD check: 0E/0W/≤1N
- [ ] Tests pass
- [ ] pkgdown builds successfully
- [ ] Documentation regenerated
- [ ] TODO markers in place for post-repo-rename

## Post-Repo-Rename TODOs
- Update DESCRIPTION URLs and BugReports
- Update README badges and links
- Update pkgdown.yml url
- Rebuild and publish pkgdown site
- Final validation and CRAN submission