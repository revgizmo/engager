# AI Agent Training Guide

**This document provides step-by-step training for AI agents to contribute effectively to the zoomstudentengagement R package project.**

## 🎯 **Training Overview**

This guide will walk you through the essential skills and knowledge needed to work on this R package project. Follow each section in order to build your expertise.

## 📚 **Prerequisites**

Before starting this training, ensure you understand:
- **R Programming**: Basic R syntax and data manipulation
- **R Package Development**: Package structure and development workflow
- **Git**: Version control and collaborative development
- **GitHub**: Issue tracking and pull request workflow

## 🚀 **Module 1: Project Understanding (30 minutes)**

### **1.1 Project Overview**
- **Purpose**: Analyze Zoom transcripts for student engagement
- **Focus**: Participation equity and privacy protection
- **Status**: Advanced development, preparing for CRAN submission
- **Key Goal**: Achieve 0 errors, 0 warnings in R CMD check

### **1.2 Project Structure**
```
zoomstudentengagement/
├── R/                    # Core package functions
├── tests/               # Unit tests
├── man/                 # Generated documentation
├── vignettes/           # User guides and examples
├── docs/                # Development documentation
├── scripts/             # Development and validation scripts
└── inst/                # Package data and resources
```

### **1.3 Key Dependencies**
- **Core**: data.table, dplyr, ggplot2, lubridate
- **Development**: testthat, covr, roxygen2
- **Privacy**: Built-in privacy functions and FERPA compliance

### **Exercise 1.1**: Explore the project structure
```bash
# Navigate to project directory
cd /path/to/zoomstudentengagement

# List key directories
ls -la R/ tests/ vignettes/ docs/

# Read the DESCRIPTION file
cat DESCRIPTION
```

## 🔧 **Module 2: Development Environment Setup (45 minutes)**

### **2.1 R Environment**
- **R Version**: 4.1.0 or higher
- **RStudio**: Recommended for development
- **Required Packages**: Install development dependencies

### **2.2 Package Loading and Development**
```r
# Load package for development
devtools::load_all()

# Check package status
devtools::check()

# Run tests
devtools::test()

# Generate documentation
devtools::document()
```

### **2.3 Git Workflow Setup**
```bash
# Check current branch
git branch

# Create feature branch
git checkout -b feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]

# Set upstream and push
git push -u origin feature/issue-[NUMBER]-[PHASE]-[WORK_TYPE]
```

### **Exercise 2.1**: Set up development environment
```r
# Install required packages
install.packages(c("devtools", "testthat", "covr", "roxygen2"))

# Load the package
devtools::load_all()

# Run a simple test
devtools::test()
```

## 📝 **Module 3: Documentation Standards (60 minutes)**

### **3.1 Roxygen2 Documentation**
All exported functions must have complete documentation:

```r
#' Analyze Zoom Transcripts for Student Engagement
#'
#' @description This function processes Zoom transcript files to analyze student
#'   engagement patterns and participation equity.
#'
#' @param transcript_files Character vector of file paths to Zoom transcripts
#' @param privacy_settings List of privacy configuration options
#' @param output_format Character string specifying output format ("data.frame", "list")
#'
#' @return A data frame or list containing engagement metrics and analysis results
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' results <- analyze_transcripts(
#'   transcript_files = c("transcript1.vtt", "transcript2.vtt"),
#'   privacy_settings = list(mask_names = TRUE, anonymize = TRUE)
#' )
#' }
#'
#' @export
analyze_transcripts <- function(transcript_files, privacy_settings = NULL, output_format = "data.frame") {
  # Function implementation
}
```

### **3.2 Documentation Requirements**
- **@title**: Clear, descriptive title
- **@description**: Detailed explanation of functionality
- **@param**: All parameters with types and descriptions
- **@return**: Return value description
- **@examples**: Runnable examples (use `\dontrun{}` for external dependencies)
- **@export**: Mark function as public API
- **@keywords internal**: Mark internal functions

### **Exercise 3.1**: Document a function
```r
# Choose a function from the R/ directory
# Add complete roxygen2 documentation
# Generate documentation
devtools::document()

# Check for documentation issues
devtools::check()
```

## 🧪 **Module 4: Testing Standards (90 minutes)**

### **4.1 Test Structure**
Tests are organized in `tests/testthat/` with one test file per R file:

```r
# tests/testthat/test-analyze-transcripts.R
test_that("analyze_transcripts handles basic input correctly", {
  # Test setup
  test_files <- c("test1.vtt", "test2.vtt")
  
  # Test execution
  result <- analyze_transcripts(test_files)
  
  # Assertions
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("student_name", "participation_count") %in% names(result)))
})

test_that("analyze_transcripts handles privacy settings correctly", {
  # Test privacy functionality
  privacy_config <- list(mask_names = TRUE, anonymize = TRUE)
  
  result <- analyze_transcripts(test_files, privacy_config)
  
  # Verify privacy compliance
  expect_false(any(grepl("real_name", result$student_name)))
})
```

### **4.2 Test Coverage Requirements**
- **Target**: >90% code coverage
- **Coverage**: All exported functions
- **Edge Cases**: Error conditions and boundary cases
- **Real Data**: Test with realistic scenarios

### **4.3 Test Data Management**
```r
# Use synthetic test data
test_data <- data.frame(
  student_name = c("Student A", "Student B"),
  participation_count = c(5, 3)
)

# Test with edge cases
test_that("handles empty input gracefully", {
  expect_error(analyze_transcripts(character(0)), "No transcript files provided")
})
```

### **Exercise 4.1**: Write comprehensive tests
```r
# Choose a function to test
# Write tests covering normal usage, edge cases, and error conditions
# Run tests and check coverage
devtools::test()
covr::package_coverage()
```

## 🔒 **Module 5: Privacy and Security (45 minutes)**

### **5.1 Privacy-First Approach**
- **FERPA Compliance**: Educational privacy regulations
- **Data Anonymization**: Never expose real student data
- **Privacy Functions**: Built-in privacy protection tools

### **5.2 Privacy Functions**
```r
# Apply privacy protection
ensure_privacy(data, settings = privacy_defaults())

# Configure privacy settings
set_privacy_defaults(
  mask_names = TRUE,
  anonymize = TRUE,
  remove_identifiers = TRUE
)

# Audit privacy compliance
privacy_audit(data)
```

### **5.3 Data Handling Best Practices**
- **Never commit real student data**
- **Use synthetic test data only**
- **Implement proper anonymization**
- **Validate privacy compliance**

### **Exercise 5.1**: Implement privacy protection
```r
# Create synthetic test data
test_data <- create_synthetic_transcript_data()

# Apply privacy protection
protected_data <- ensure_privacy(test_data)

# Verify privacy compliance
audit_result <- privacy_audit(protected_data)
expect_true(audit_result$privacy_compliant)
```

## ✅ **Module 6: Pre-PR Validation (60 minutes)**

### **6.1 Validation Checklist**
Before submitting a pull request, complete this checklist:

- [ ] **Code Quality**: Run `styler::style_pkg()` and `lintr::lint_package()`
- [ ] **Documentation**: Run `devtools::document()` and `devtools::build_readme()`
- [ ] **Testing**: Run `devtools::test()` and check coverage
- [ ] **Examples**: Run `devtools::check_examples()`
- [ ] **Package Check**: Run `devtools::check()` with 0 errors, 0 warnings
- [ ] **Build**: Run `devtools::build()` successfully

### **6.2 Automated Validation**
```bash
# Run complete validation script
Rscript scripts/pre-pr-validation.R

# This script runs all necessary checks
# Fix any issues found before proceeding
```

### **6.3 Common Issues and Solutions**
- **Style Issues**: Run `styler::style_pkg()`
- **Linting Errors**: Fix code quality issues
- **Documentation Warnings**: Update roxygen2 comments
- **Test Failures**: Debug and fix failing tests
- **Example Errors**: Test and fix broken examples

### **Exercise 6.1**: Complete pre-PR validation
```bash
# Run the validation script
Rscript scripts/pre-pr-validation.R

# Fix any issues found
# Re-run validation until all checks pass
```

## 🔄 **Module 7: Pull Request Workflow (45 minutes)**

### **7.1 Creating Pull Requests**
```bash
# Ensure all changes are committed
git add .
git commit -m "feat: implement [feature description]"

# Push to remote
git push

# Create pull request
gh pr create --title "feat: [Description]" --body "Fixes #[NUMBER]"
```

### **7.2 PR Best Practices**
- **Clear Title**: Descriptive and follows conventional commits
- **Detailed Description**: Explain what, why, and how
- **Issue Linking**: Use `Fixes #[NUMBER]` or `Closes #[NUMBER]`
- **Review Request**: Tag appropriate reviewers
- **CI Status**: Ensure all checks pass

### **7.3 Review Process**
- **Address Feedback**: Respond to review comments
- **Update Code**: Make requested changes
- **Re-request Review**: When ready for re-review
- **Merge**: When approved and CI passes

### **Exercise 7.1**: Create a practice PR**
```bash
# Make a small change (e.g., update documentation)
# Follow the complete workflow
# Create a PR (you can close it after practice)
```

## 🎯 **Module 8: CRAN Compliance (30 minutes)**

### **8.1 CRAN Requirements**
- **R CMD check**: 0 errors, 0 warnings (notes acceptable if unavoidable)
- **Examples**: All examples must run successfully
- **Documentation**: Complete and accurate
- **Dependencies**: Properly specified and versioned
- **License**: Valid and appropriate

### **8.2 CRAN Check Process**
```r
# Full package check
devtools::check()

# Check examples specifically
devtools::check_examples()

# Build package
devtools::build()
```

### **8.3 Common CRAN Issues**
- **Documentation**: Missing or incomplete roxygen2 docs
- **Examples**: Broken or non-runnable examples
- **Dependencies**: Missing or incorrectly specified
- **Tests**: Failing tests or insufficient coverage

## 📋 **Final Assessment**

### **8.1 Skills Checklist**
- [ ] Understand project structure and purpose
- [ ] Set up development environment
- [ ] Write complete roxygen2 documentation
- [ ] Create comprehensive tests with >90% coverage
- [ ] Implement privacy protection correctly
- [ ] Complete pre-PR validation successfully
- [ ] Create and manage pull requests
- [ ] Ensure CRAN compliance

### **8.2 Next Steps**
After completing this training:
1. **Practice**: Work on small issues to build confidence
2. **Contribute**: Take on larger features and improvements
3. **Mentor**: Help other contributors learn the workflow
4. **Improve**: Suggest workflow enhancements

## 🔗 **Additional Resources**

- **[AI Agent Workflow](AI_AGENT_WORKFLOW.md)**: Complete workflow reference
- **[Contributing Guidelines](../../CONTRIBUTING.md)**: Overall contribution process
- **[Project Documentation](../../PROJECT.md)**: Project status and priorities
- **[CRAN Checklist](../../CRAN_CHECKLIST.md)**: CRAN submission requirements
- **[R Package Development](https://r-pkgs.org/)**: Official R package guide

---

**Congratulations! You've completed the AI Agent Training. You're now ready to contribute effectively to the zoomstudentengagement R package project.**
