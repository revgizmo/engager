# Testing Best Practices for CRAN Compliance

## Overview
This document outlines testing best practices for achieving and maintaining 90%+ test coverage while ensuring CRAN compliance for the `engager` R package.

## CRAN Compliance Requirements

### Critical Testing Standards
- **Minimum Coverage:** 90% (enforced by CI)
- **All Examples Must Run:** `devtools::check_examples()` must pass
- **All Tests Must Pass:** `devtools::test()` must pass with 0 failures
- **R-CMD-check Compliance:** `devtools::check()` must pass with 0 errors, 0 warnings
- **Documentation Completeness:** All exported functions must have complete roxygen2 documentation

### Coverage Calculation
- **Coverage = (Lines Executed / Total Lines) × 100%**
- **Excluded Lines:** `# nocov` markers, comments, empty lines
- **Target:** 90%+ for CRAN submission
- **Stretch Goal:** 95%+ for excellence

## Testing Strategy

### 1. Function Prioritization
**Priority Order:**
1. **Exported Functions** (user-facing, must be well-tested)
2. **Large Functions** (more lines = more coverage potential)
3. **Critical Functions** (core functionality, error handling)
4. **Internal Functions** (if they have significant uncovered lines)

### 2. Test Coverage Patterns

#### High-Impact Testing
```r
# Test all code paths
test_that("function_name handles all scenarios", {
  # Happy path
  result <- function_name(valid_input)
  expect_s3_class(result, "expected_class")
  
  # Edge cases
  result_edge <- function_name(edge_case_input)
  expect_equal(nrow(result_edge), expected_rows)
  
  # Error conditions
  expect_error(function_name(invalid_input), "expected error message")
  
  # NULL inputs
  result_null <- function_name(NULL)
  expect_s3_class(result_null, "expected_class")
})
```

#### Comprehensive Parameter Testing
```r
# Test all parameter combinations
test_that("function_name handles all parameters", {
  # Default parameters
  result1 <- function_name()
  expect_s3_class(result1, "expected_class")
  
  # Custom parameters
  result2 <- function_name(param1 = "value1", param2 = "value2")
  expect_s3_class(result2, "expected_class")
  
  # Edge case parameters
  result3 <- function_name(param1 = "", param2 = NULL)
  expect_s3_class(result3, "expected_class")
})
```

#### Error Handling Testing
```r
# Test all error conditions
test_that("function_name handles errors gracefully", {
  # Invalid input types
  expect_error(function_name(123), "expected error message")
  expect_error(function_name(NULL), "expected error message")
  
  # Invalid parameter values
  expect_error(function_name(invalid_param = "bad_value"), "expected error message")
  
  # Missing required parameters
  expect_error(function_name(), "expected error message")
})
```

### 3. Test Data Management

#### Reusable Test Data
```r
# Create test data patterns
create_test_data <- function(type = "basic") {
  switch(type,
    "basic" = tibble::tibble(
      id = 1:3,
      name = c("Alice", "Bob", "Charlie"),
      value = c(10, 20, 30)
    ),
    "edge_case" = tibble::tibble(
      id = integer(),
      name = character(),
      value = numeric()
    ),
    "error_case" = NULL
  )
}
```

#### Test Data Validation
```r
# Validate test data structure
validate_test_data <- function(data, expected_cols) {
  expect_s3_class(data, "tbl_df")
  expect_true(all(expected_cols %in% names(data)))
  expect_equal(nrow(data), expected_rows)
}
```

### 4. Coverage Optimization

#### Avoiding `# nocov` Markers
- **Minimize use of `# nocov`** - only for truly untestable code
- **Test error conditions** instead of marking them as `# nocov`
- **Test edge cases** instead of marking them as `# nocov`

#### Maximizing Coverage Efficiency
```r
# Good: Test all branches
test_that("function_name handles all conditions", {
  # Test if condition
  result1 <- function_name(condition = TRUE)
  expect_equal(result1, expected_true)
  
  # Test else condition
  result2 <- function_name(condition = FALSE)
  expect_equal(result2, expected_false)
})

# Bad: Using # nocov for testable code
if (condition) {
  # nocov start
  do_something()
  # nocov end
}
```

### 5. CRAN-Specific Testing

#### Skip Tests on CRAN
```r
# Skip tests that require external resources
test_that("function_name requires external resource", {
  skip_on_cran()  # Skip on CRAN, run in CI
  
  result <- function_name(external_resource)
  expect_s3_class(result, "expected_class")
})
```

#### Test Examples
```r
# Ensure all examples run
test_that("examples run without error", {
  # Test that examples in documentation run
  expect_no_error({
    # Copy example from roxygen2 documentation
    result <- function_name(example_input)
  })
})
```

### 6. Test Organization

#### File Structure
```
tests/testthat/
├── test-function_name.R          # One test file per R file
├── test-helper_functions.R        # Helper function tests
└── test-integration.R             # Integration tests
```

#### Test Naming Convention
```r
# Descriptive test names
test_that("function_name handles valid input correctly", { ... })
test_that("function_name handles invalid input with error", { ... })
test_that("function_name handles edge cases appropriately", { ... })
test_that("function_name handles NULL input gracefully", { ... })
```

### 7. Performance Testing

#### Skip Performance Tests on CRAN
```r
# Performance tests (skip on CRAN)
test_that("function_name performance is acceptable", {
  skip_on_cran()
  
  # Performance testing code
  expect_lt(system.time(function_name(large_input))[3], 5.0)
})
```

### 8. Documentation Testing

#### Test Documentation Examples
```r
# Test that documentation examples work
test_that("documentation examples run correctly", {
  # Test examples from roxygen2 documentation
  expect_no_error({
    # Example 1
    result1 <- function_name(input1)
    
    # Example 2
    result2 <- function_name(input2, param = "value")
  })
})
```

## Implementation Guidelines

### Week 1: Critical Functions
- Focus on 6 largest exported functions
- Target 95%+ coverage for each
- Implement comprehensive error handling tests

### Week 2: Medium Priority Functions
- Focus on remaining exported functions
- Target 90%+ coverage for each
- Implement edge case testing

### Week 3: Optimization
- Fine-tune coverage gaps
- Review and optimize test efficiency
- Ensure all CRAN requirements are met

## Quality Assurance

### Pre-PR Validation
```bash
# Run full validation suite
./scripts/pre-pr-validation.R
```

### Coverage Monitoring
```r
# Check coverage locally
library(covr)
cov <- package_coverage()
percent_coverage(cov)  # Should be 90%+
```

### CI Validation
- All CI checks must pass
- Coverage threshold enforced at 90%
- R-CMD-check must pass with 0 errors, 0 warnings

## Best Practices Summary

1. **Test All Exported Functions** - User-facing functions must be well-tested
2. **Test All Code Paths** - Ensure all branches are covered
3. **Test Error Conditions** - Don't use `# nocov` for testable error handling
4. **Test Edge Cases** - Include boundary conditions and unusual inputs
5. **Test Examples** - Ensure documentation examples run correctly
6. **Skip External Dependencies** - Use `skip_on_cran()` for tests requiring external resources
7. **Organize Tests Systematically** - One test file per R file
8. **Use Descriptive Test Names** - Make test purpose clear
9. **Validate Test Data** - Ensure test data is realistic and comprehensive
10. **Monitor Coverage Continuously** - Check coverage after each change

---
*Created: $(date)*
*Status: Ready for implementation*
*Priority: High (essential for CRAN compliance)*
