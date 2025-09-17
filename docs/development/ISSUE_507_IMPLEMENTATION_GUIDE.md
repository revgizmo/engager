# Issue #507: Add Startup Message for New User Guidance - Implementation Guide

## 🎯 Mission
Implement startup message functionality to guide new users to available vignettes and resources when they load the zoomstudentengagement package.

## 📋 Step-by-Step Implementation Plan

### Step 1: Create Feature Branch
```bash
git checkout -b feature/issue-507-startup-message
git push -u origin feature/issue-507-startup-message
```

### Step 2: Create Package Startup File
**File: `R/zzz.R`**

Create the package startup file with the following content:

```r
.onAttach <- function(libname, pkgname) {
  # Check if user wants to suppress startup message
  show_startup <- getOption("zoomstudentengagement.show_startup", TRUE)
  
  if (show_startup) {
    packageStartupMessage(
      "Welcome to zoomstudentengagement!\n",
      "- Start with: vignette('getting-started', package='zoomstudentengagement')\n",
      "- Core functions: vignette('essential-functions', package='zoomstudentengagement')\n",
      "- Sample data: system.file('extdata/transcripts', package='zoomstudentengagement')\n",
      "- Quick example: example(summarize_transcript_metrics)\n",
      "\n",
      "To suppress this message: options(zoomstudentengagement.show_startup = FALSE)"
    )
  }
}
```

### Step 3: Test Startup Message
**File: `tests/testthat/test-startup.R`**

Create tests for the startup message:

```r
test_that("startup message displays by default", {
  # Test that startup message is shown by default
  expect_message(
    library(zoomstudentengagement),
    "Welcome to zoomstudentengagement!"
  )
})

test_that("startup message can be suppressed", {
  # Test that startup message can be suppressed
  options(zoomstudentengagement.show_startup = FALSE)
  expect_no_message(
    library(zoomstudentengagement)
  )
  # Reset option
  options(zoomstudentengagement.show_startup = TRUE)
})

test_that("startup message includes key information", {
  # Test that startup message includes key vignette links
  expect_message(
    library(zoomstudentengagement),
    "vignette\\('getting-started'"
  )
  expect_message(
    library(zoomstudentengagement),
    "vignette\\('essential-functions'"
  )
  expect_message(
    library(zoomstudentengagement),
    "system\\.file\\('extdata/transcripts'"
  )
})
```

### Step 4: Update Documentation
**File: `README.md`**

Add section about startup message:

```markdown
## 🚀 Quick Start

### Installation

``` r
devtools::install_github("revgizmo/zoomstudentengagement")
```

### First Time Loading

When you first load the package, you'll see a welcome message with guidance:

``` r
library(zoomstudentengagement)
# Welcome to zoomstudentengagement!
# - Start with: vignette('getting-started', package='zoomstudentengagement')
# - Core functions: vignette('essential-functions', package='zoomstudentengagement')
# - Sample data: system.file('extdata/transcripts', package='zoomstudentengagement')
# - Quick example: example(summarize_transcript_metrics)
```

To suppress this message: `options(zoomstudentengagement.show_startup = FALSE)`
```

### Step 5: Validate Implementation
Run the following commands to validate:

```bash
# Run tests
Rscript -e "devtools::test()"

# Check package
Rscript -e "devtools::check()"

# Test startup message
Rscript -e "library(zoomstudentengagement)"

# Test suppression
Rscript -e "options(zoomstudentengagement.show_startup = FALSE); library(zoomstudentengagement)"
```

### Step 6: Create Pull Request
```bash
git add .
git commit -m "feat(ux): Add startup message to guide new users to vignettes

- Add packageStartupMessage() to guide new users
- Include links to key vignettes and sample data
- Provide quick example command
- Add option to suppress message for advanced users
- Add comprehensive tests for startup behavior
- Update README with startup message documentation

Fixes #507"

git push origin feature/issue-507-startup-message
```

## 🔧 Technical Requirements

### Package Startup Behavior
- Message displays when package is loaded
- Message includes links to key vignettes
- Message references sample data location
- Message provides quick example command
- Message can be suppressed via options

### Testing Requirements
- Test startup message displays by default
- Test startup message can be suppressed
- Test startup message includes key information
- Test works in both interactive and non-interactive sessions

### Documentation Requirements
- Update README with startup message information
- Document suppression option
- Include examples of startup message output

## 🎯 Success Criteria

### Functional Requirements
- [ ] Startup message displays when package is loaded
- [ ] Message includes links to key vignettes (getting-started, essential-functions)
- [ ] Message references sample data location
- [ ] Message provides quick example command
- [ ] Message can be suppressed via options
- [ ] Message works in both interactive and non-interactive sessions

### Quality Requirements
- [ ] All tests pass
- [ ] CRAN compliance maintained
- [ ] Documentation updated
- [ ] Code follows project standards
- [ ] No performance impact

### User Experience Requirements
- [ ] New users see helpful guidance
- [ ] Message is not overwhelming
- [ ] Advanced users can suppress message
- [ ] Clear next steps provided

## 🚨 Potential Issues & Solutions

### Issue: Message too long or overwhelming
**Solution**: Keep message concise and focused on key next steps

### Issue: Message interferes with non-interactive sessions
**Solution**: Use `packageStartupMessage()` which handles non-interactive sessions appropriately

### Issue: Message appears too frequently
**Solution**: Add option to suppress message for advanced users

### Issue: CRAN compliance concerns
**Solution**: Ensure message is informative and not promotional, follows CRAN guidelines

## 📚 References
- [R Package Development Best Practices](https://r-pkgs.org/)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [packageStartupMessage() documentation](https://rdrr.io/r/base/packageStartupMessage.html)
