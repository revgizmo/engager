# Issue #509 Phase 3 (Repository Rename) - Implementation Guide

**Date**: 2025-01-27  
**Branch**: `feature/issue-509-phase-3-repository-rename`  
**Status**: Ready to Begin  
**Phase**: Phase 3 - Repository Rename  

---

## 🎯 **Phase 3 Objective**

Complete the repository rename from `zoomstudentengagement` to `engager` on GitHub, update all URLs and references, and ensure all links and badges continue to work correctly.

---

## 📋 **Prerequisites**

✅ **Phase 2 Completed**: All validation checks passed  
✅ **Package Identity**: Successfully renamed to `engager`  
✅ **Local Validation**: Pre-PR validation passes  
✅ **Tests**: All tests pass  
✅ **Vignettes**: All vignettes build successfully  

---

## 🚀 **Step-by-Step Implementation**

### **Step 1: Pre-Rename Preparation**

#### 1.1 Create Feature Branch
```bash
git checkout main
git pull origin main
git checkout -b feature/issue-509-phase-3-repository-rename
git push -u origin feature/issue-509-phase-3-repository-rename
```

#### 1.2 Verify Current Status
```bash
# Confirm Phase 2 work is merged
git log --oneline -10

# Run final validation
Rscript scripts/pre-pr-validation.R

# Verify package builds
Rscript -e "devtools::build()"
```

#### 1.3 Check CRAN Name Availability
- Verify `engager` is available on CRAN
- Check reverse dependencies for conflicts
- Confirm no naming conflicts exist

### **Step 2: Update URLs and References**

#### 2.1 Update DESCRIPTION URLs
**File**: `DESCRIPTION`
```diff
-URL: https://github.com/revgizmo/zoomstudentengagement
-BugReports: https://github.com/revgizmo/zoomstudentengagement/issues
+URL: https://github.com/revgizmo/engager
+BugReports: https://github.com/revgizmo/engager/issues
```

#### 2.2 Update README Badges and Links
**File**: `README.md`
- Update all GitHub URLs from `zoomstudentengagement` to `engager`
- Update badges (CI, coverage, pkgdown) to use new repository name
- Update installation instructions
- Update any hardcoded links

#### 2.3 Update pkgdown Configuration
**File**: `_pkgdown.yml`
```yaml
url: https://revgizmo.github.io/engager/
```

#### 2.4 Update NEWS.md
Add entry for the repository rename:
```markdown
# engager 1.0.0

## Repository Rename
- Repository renamed from `zoomstudentengagement` to `engager`
- All URLs and references updated
- Package functionality remains unchanged
```

### **Step 3: GitHub Repository Rename**

#### 3.1 Rename Repository on GitHub
1. Go to GitHub repository: `https://github.com/revgizmo/zoomstudentengagement`
2. Navigate to **Settings** → **General**
3. Scroll to **Repository name** section
4. Change from `zoomstudentengagement` to `engager`
5. Click **Rename**

**⚠️ Important**: GitHub will automatically:
- Create redirects from old URLs to new URLs
- Update all existing links and references
- Preserve repository history and issues

#### 3.2 Update Local Remote
```bash
# Update local remote URL
git remote set-url origin https://github.com/revgizmo/engager.git

# Verify remote update
git remote -v
```

### **Step 4: Post-Rename Validation**

#### 4.1 Update CI Workflows
**File**: `.github/workflows/R-CMD-check.yaml`
- Verify workflow still works with new repository name
- Check if any hardcoded references need updating

**File**: `.github/workflows/build-validation.yml`
- Verify workflow still works with new repository name
- Check if any hardcoded references need updating

#### 4.2 Test All Links and Badges
- Verify README badges work correctly
- Test pkgdown site builds and deploys
- Check all documentation links
- Verify installation instructions work

#### 4.3 Run Full Validation Suite
```bash
# Run pre-PR validation
Rscript scripts/pre-pr-validation.R

# Run full test suite
Rscript -e "devtools::test()"

# Build and check package
Rscript -e "devtools::build()"
Rscript -e "devtools::check(args = c('--no-manual', '--as-cran'))"

# Build vignettes
Rscript -e "devtools::build_vignettes()"
```

### **Step 5: Documentation and Communication**

#### 5.1 Update Project Documentation
- Update `PROJECT.md` with new repository information
- Update any internal documentation references
- Update development guides and scripts

#### 5.2 Create Migration Guide
Create a brief migration note for users:
```markdown
## Migration from zoomstudentengagement to engager

The package has been renamed from `zoomstudentengagement` to `engager`.

### For Users
- Update installation: `remotes::install_github("revgizmo/engager")`
- Update library calls: `library(engager)`
- All functionality remains the same

### For Developers
- Repository URL: https://github.com/revgizmo/engager
- All existing links will redirect automatically
```

### **Step 6: Final Validation and Commit**

#### 6.1 Commit All Changes
```bash
git add .
git commit -m "feat: Complete repository rename from zoomstudentengagement to engager

- Updated DESCRIPTION URLs to point to new repository
- Updated README badges and links
- Updated pkgdown configuration
- Added NEWS entry for repository rename
- All validation checks pass
- Ready for CRAN submission as engager"
```

#### 6.2 Push and Create PR
```bash
git push origin feature/issue-509-phase-3-repository-rename

# Create pull request
gh pr create --title "feat: Complete repository rename to engager" \
  --body "Phase 3 of Issue #509: Repository Rename

- Updated all URLs and references from zoomstudentengagement to engager
- Updated DESCRIPTION, README, pkgdown configuration
- Added NEWS entry for repository rename
- All validation checks pass
- Repository ready for CRAN submission

Closes #509"
```

---

## ✅ **Success Criteria**

- [ ] Repository successfully renamed on GitHub
- [ ] All URLs updated in DESCRIPTION, README, and documentation
- [ ] All badges and links work correctly
- [ ] Pre-PR validation passes
- [ ] All tests pass
- [ ] Package builds successfully
- [ ] Vignettes build successfully
- [ ] pkgdown site deploys correctly
- [ ] Local remote updated to new repository URL
- [ ] Migration guide created for users

---

## 🔧 **Validation Commands**

```bash
# Pre-PR validation
Rscript scripts/pre-pr-validation.R

# Full test suite
Rscript -e "devtools::test()"

# Package build and check
Rscript -e "devtools::build()"
Rscript -e "devtools::check(args = c('--no-manual', '--as-cran'))"

# Vignette build
Rscript -e "devtools::build_vignettes()"

# Documentation build
Rscript -e "pkgdown::build_site()"
```

---

## ⚠️ **Important Notes**

1. **GitHub Redirects**: GitHub automatically creates redirects from old URLs to new URLs, so existing links will continue to work.

2. **CI Workflows**: GitHub Actions workflows should continue to work automatically after the rename.

3. **Branch Protection**: Branch protection rules will continue to apply after the rename.

4. **Issues and PRs**: All existing issues and pull requests will be preserved and accessible.

5. **Releases**: All existing releases will be preserved and accessible.

---

## 🚨 **Risk Mitigation**

- **Backup**: Ensure all changes are committed before repository rename
- **Testing**: Run full validation suite after each major change
- **Verification**: Test all links and badges after repository rename
- **Rollback**: Keep the feature branch until Phase 4 is complete

---

## 📚 **References**

- [GitHub Repository Rename Documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository)
- Issue #509: Package Rename Implementation
- Phase 2 Validation Report: `ISSUE_509_PHASE_2_VALIDATION_REPORT.md`
- Implementation Guide: `ISSUE_509_IMPLEMENTATION_GUIDE.md`

---

## 🎯 **Next Steps**

After completing Phase 3:
1. Merge the Phase 3 pull request
2. Proceed to Phase 4 (CRAN Submission)
3. Submit package to CRAN as `engager`
4. Monitor and respond to CRAN feedback

**Estimated Time**: 1 day  
**Dependencies**: Phase 2 completion  
**Risk Level**: Low (GitHub handles redirects automatically)
