# Issue 533 Consolidated Plan: README and Repository Cleanup for CRAN Submission

## Project Context
- **Project Type**: R Package (detected via DESCRIPTION + NAMESPACE)
- **Compliance Target**: CRAN submission readiness
- **Current Status**: Advanced development phase, preparing for CRAN submission
- **Issue**: #533 - Cleanup README Generation and Root Directory for CRAN Submission

## Current Status Assessment

### ✅ Completed Work
- **Package Development**: Core functionality implemented and tested
- **Documentation Structure**: Basic documentation framework in place
- **Testing Infrastructure**: Comprehensive test suite with >90% coverage
- **CRAN Compliance**: Most technical requirements met

### ⚠️ Current Issues Identified
1. **README Problems**:
   - Contains internal developer workflows inappropriate for CRAN users
   - Multiple broken links to missing files (`PROJECT.md`, `DOCUMENTATION.md`, etc.)
   - Badge formatting issues (coverage badge has newline character)

2. **Documentation Navigation**:
   - Missing `DOCUMENTATION.md` index file
   - Recursive paths in `docs/README.md`
   - Inconsistent documentation structure

3. **Repository Organization**:
   - Root directory cluttered with backup files, analysis artifacts, and helper scripts
   - Mixed package and non-package files
   - Large data files in root directory

## Implementation Plan

### Phase 1: README Modernization (Priority: HIGH)
**Timeline**: 2-3 hours
**Dependencies**: None

**Tasks**:
1. Audit current README content for CRAN appropriateness
2. Remove internal developer workflows and Cursor automation references
3. Fix broken links and update references
4. Refresh badges and fix formatting issues
5. Test README generation with `devtools::build_readme()`
6. Run link checker validation

**Success Criteria**:
- README focuses on CRAN user onboarding
- All links resolve correctly
- Badges display properly
- No internal developer content visible to CRAN users

### Phase 2: Documentation Navigation Restoration (Priority: HIGH)
**Timeline**: 1-2 hours
**Dependencies**: Phase 1 completion

**Tasks**:
1. Decide on documentation index strategy (restore `DOCUMENTATION.md` vs. update links)
2. Fix recursive paths in `docs/README.md`
3. Update all references to missing files
4. Create consistent documentation structure
5. Test navigation and link resolution

**Success Criteria**:
- Single reliable documentation index
- All documentation links resolve
- Clear navigation structure for contributors
- No broken internal links

### Phase 3: Repository Root Cleanup (Priority: MEDIUM)
**Timeline**: 2-4 hours
**Dependencies**: Phase 2 completion

**Tasks**:
1. Inventory all non-standard root artifacts
2. Classify files by type (backup, analysis, dataset, script, documentation)
3. Move files to appropriate locations:
   - Backups → `backups/` with dated subfolders
   - Analysis artifacts → `dev/artifacts/` or `inst/extdata/`
   - Maintenance scripts → `scripts/maintenance/`
   - Documentation → `docs/` with contextual names
4. Update `.Rbuildignore` patterns
5. Verify package build excludes only appropriate files

**Success Criteria**:
- Root directory contains only package-relevant files
- All moved files accessible to scripts/tests that need them
- Clean package tarball without unnecessary files
- Maintained automation workflows

### Phase 4: Validation and Testing (Priority: HIGH)
**Timeline**: 1-2 hours
**Dependencies**: All previous phases

**Tasks**:
1. Run `scripts/pre-pr-validation.R` to ensure automation still works
2. Execute `devtools::check()` to verify no regressions
3. Test README generation and link checking
4. Update contributor documentation
5. Coordinate with pkgdown deployment if needed

**Success Criteria**:
- All automation workflows continue working
- No regressions in package functionality
- CRAN compliance maintained
- Contributor documentation updated

## Technical Requirements

### CRAN Compliance Requirements
- **README Standards**: CRAN-friendly content, proper formatting, working links
- **Package Structure**: Clean root directory, appropriate file organization
- **Documentation**: Complete and accurate, no broken references
- **Build Process**: Automated workflows continue functioning

### Environment Considerations
- **R Package Development**: Use `devtools`, `roxygen2`, `testthat` workflows
- **Documentation**: Follow roxygen2 standards for R package documentation
- **Testing**: Maintain >90% test coverage, all tests passing
- **Automation**: Preserve existing pre-PR validation workflows

### Risk Mitigation
- **Backup Strategy**: Create backup of current state before major changes
- **Incremental Approach**: Implement changes in phases to minimize risk
- **Validation**: Test each phase thoroughly before proceeding
- **Rollback Plan**: Document steps to revert changes if issues arise

## Success Metrics

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

## Open Questions for Implementation

1. **Documentation Index Strategy**: Should we restore `DOCUMENTATION.md` or update all links to use `docs/README.md`/pkgdown?

2. **Data File Management**: Which `.rds` datasets are required for tests/vignettes vs. historical analysis? Can any be regenerated?

3. **Development Workspace**: Should we create a dedicated `dev/` directory for future analysis artifacts?

4. **Automation Balance**: How much documentation index generation should be automated vs. manual?

## Next Steps

1. **Review Current State**: Thoroughly assess existing documentation and repository structure
2. **Prioritize Changes**: Focus on CRAN-critical items first (README, broken links)
3. **Implement Incrementally**: Complete each phase before moving to the next
4. **Validate Continuously**: Test after each major change to ensure no regressions
5. **Document Changes**: Update contributor documentation as structure changes

## Resources

- **CRAN Submission Guide**: https://cran.r-project.org/web/packages/policies.html
- **R Package Development**: https://r-pkgs.org/
- **Documentation Standards**: https://style.tidyverse.org/
- **Testing Guidelines**: https://testthat.r-lib.org/
