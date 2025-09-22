# Test Reusability Patterns

## Overview
This document provides reusable test patterns and utilities to maximize testing efficiency and maintain consistency across the `engager` package test suite.

## Core Test Patterns

### 1. Data Structure Validation
```r
# Pattern: Validate tibble structure
validate_tibble_structure <- function(result, expected_class = "tbl_df", expected_rows = 0) {
  testthat::expect_s3_class(result, expected_class)
  testthat::expect_equal(nrow(result), expected_rows)
}

# Pattern: Validate column names
validate_column_names <- function(result, expected_names) {
  testthat::expect_equal(names(result), expected_names)
}

# Pattern: Validate all expected columns are present
validate_all_expected_columns_present <- function(result, expected_columns) {
  testthat::expect_true(all(expected_columns %in% names(result)))
}
```

### 2. Error Handling Patterns
```r
# Pattern: Test error conditions
test_error_condition <- function(func, invalid_input, expected_error_regex) {
  testthat::expect_error(func(invalid_input), expected_error_regex)
}

# Pattern: Test NULL input handling
test_null_input_handling <- function(func, expected_class = "tbl_df", expected_rows = 0) {
  result <- func(NULL)
  validate_tibble_structure(result, expected_class, expected_rows)
}

# Pattern: Test invalid parameter types
test_invalid_parameter_types <- function(func, param_name, invalid_values, expected_error_regex) {
  for (val in invalid_values) {
    args <- list()
    args[[param_name]] <- val
    testthat::expect_error(do.call(func, args), expected_error_regex)
  }
}
```

### 3. Parameter Testing Patterns
```r
# Pattern: Test default parameters
test_default_parameters <- function(func, ...) {
  result <- func(...)
  testthat::expect_s3_class(result, "tbl_df")
  testthat::expect_equal(nrow(result), 0)
}

# Pattern: Test parameter combinations
test_parameter_combinations <- function(func, param_combinations) {
  for (combo in param_combinations) {
    result <- do.call(func, combo)
    testthat::expect_s3_class(result, "tbl_df")
  }
}

# Pattern: Test edge case parameters
test_edge_case_parameters <- function(func, edge_cases) {
  for (case in edge_cases) {
    result <- func(case)
    testthat::expect_s3_class(result, "tbl_df")
  }
}
```

### 4. Data Processing Patterns
```r
# Pattern: Test data transformation
test_data_transformation <- function(func, input_data, expected_output) {
  result <- func(input_data)
  testthat::expect_equal(result, expected_output)
}

# Pattern: Test data aggregation
test_data_aggregation <- function(func, input_data, aggregation_level) {
  result <- func(input_data, aggregation_level = aggregation_level)
  testthat::expect_s3_class(result, "tbl_df")
  testthat::expect_true(nrow(result) <= nrow(input_data))
}

# Pattern: Test data filtering
test_data_filtering <- function(func, input_data, filter_condition) {
  result <- func(input_data, filter_condition)
  testthat::expect_s3_class(result, "tbl_df")
  testthat::expect_true(nrow(result) <= nrow(input_data))
}
```

### 5. File I/O Patterns
```r
# Pattern: Test file reading
test_file_reading <- function(func, file_path, expected_class = "tbl_df") {
  result <- func(file_path)
  testthat::expect_s3_class(result, expected_class)
}

# Pattern: Test file writing
test_file_writing <- function(func, data, file_path) {
  result <- func(data, file_path)
  testthat::expect_true(file.exists(file_path))
  testthat::expect_equal(result, data)
}

# Pattern: Test file validation
test_file_validation <- function(func, file_path, expected_result) {
  result <- func(file_path)
  testthat::expect_equal(result, expected_result)
}
```

## Test Data Utilities

### 1. Test Data Creation
```r
# Create test data for different scenarios
create_test_data <- function(type = "basic") {
  switch(type,
    "basic" = tibble::tibble(
      id = 1:3,
      name = c("Alice", "Bob", "Charlie"),
      value = c(10, 20, 30)
    ),
    "empty" = tibble::tibble(
      id = integer(),
      name = character(),
      value = numeric()
    ),
    "single_row" = tibble::tibble(
      id = 1L,
      name = "Alice",
      value = 10
    ),
    "with_na" = tibble::tibble(
      id = 1:3,
      name = c("Alice", NA, "Charlie"),
      value = c(10, NA, 30)
    ),
    "large" = tibble::tibble(
      id = 1:1000,
      name = paste0("Person", 1:1000),
      value = runif(1000)
    )
  )
}
```

### 2. Test Data Validation
```r
# Validate test data structure
validate_test_data <- function(data, expected_cols, expected_rows = NULL) {
  testthat::expect_s3_class(data, "tbl_df")
  testthat::expect_true(all(expected_cols %in% names(data)))
  if (!is.null(expected_rows)) {
    testthat::expect_equal(nrow(data), expected_rows)
  }
}

# Validate test data content
validate_test_data_content <- function(data, expected_values) {
  for (col in names(expected_values)) {
    testthat::expect_equal(data[[col]], expected_values[[col]])
  }
}
```

### 3. Test Data Cleanup
```r
# Clean up test files
cleanup_test_files <- function(file_patterns) {
  for (pattern in file_patterns) {
    files <- list.files(pattern = pattern, full.names = TRUE)
    file.remove(files)
  }
}

# Clean up test directories
cleanup_test_directories <- function(dir_paths) {
  for (dir_path in dir_paths) {
    if (dir.exists(dir_path)) {
      unlink(dir_path, recursive = TRUE)
    }
  }
}
```

## Coverage Optimization Patterns

### 1. Branch Coverage
```r
# Test all conditional branches
test_all_branches <- function(func, conditions) {
  for (condition in conditions) {
    result <- func(condition)
    testthat::expect_s3_class(result, "tbl_df")
  }
}
```

### 2. Loop Coverage
```r
# Test loop iterations
test_loop_iterations <- function(func, input_data) {
  result <- func(input_data)
  testthat::expect_s3_class(result, "tbl_df")
  testthat::expect_true(nrow(result) > 0)
}
```

### 3. Error Path Coverage
```r
# Test all error paths
test_all_error_paths <- function(func, error_inputs) {
  for (input in error_inputs) {
    testthat::expect_error(func(input), "expected error message")
  }
}
```

## CRAN Compliance Patterns

### 1. Skip Tests on CRAN
```r
# Skip tests that require external resources
test_external_resource <- function(func, external_input) {
  testthat::skip_on_cran()
  
  result <- func(external_input)
  testthat::expect_s3_class(result, "tbl_df")
}
```

### 2. Test Examples
```r
# Test that documentation examples run
test_documentation_examples <- function(func, examples) {
  for (example in examples) {
    testthat::expect_no_error({
      eval(parse(text = example))
    })
  }
}
```

### 3. Performance Testing
```r
# Test performance (skip on CRAN)
test_performance <- function(func, input_data, max_time = 5.0) {
  testthat::skip_on_cran()
  
  execution_time <- system.time(func(input_data))[3]
  testthat::expect_lt(execution_time, max_time)
}
```

## Integration Testing Patterns

### 1. End-to-End Testing
```r
# Test complete workflows
test_complete_workflow <- function(workflow_func, input_data) {
  result <- workflow_func(input_data)
  testthat::expect_s3_class(result, "tbl_df")
  testthat::expect_true(nrow(result) > 0)
}
```

### 2. Data Pipeline Testing
```r
# Test data processing pipelines
test_data_pipeline <- function(pipeline_func, input_data, expected_output) {
  result <- pipeline_func(input_data)
  testthat::expect_equal(result, expected_output)
}
```

### 3. Error Recovery Testing
```r
# Test error recovery mechanisms
test_error_recovery <- function(func, error_input, recovery_func) {
  testthat::expect_error(func(error_input))
  
  recovered_result <- recovery_func(error_input)
  testthat::expect_s3_class(recovered_result, "tbl_df")
}
```

## Usage Examples

### 1. Basic Function Testing
```r
test_that("basic_function works correctly", {
  # Test with valid input
  result <- basic_function(create_test_data("basic"))
  validate_tibble_structure(result)
  
  # Test with empty input
  result_empty <- basic_function(create_test_data("empty"))
  validate_tibble_structure(result_empty, expected_rows = 0)
  
  # Test error handling
  test_error_condition(basic_function, "invalid_input", "expected error")
})
```

### 2. Parameter Testing
```r
test_that("parameterized_function handles all parameters", {
  # Test default parameters
  test_default_parameters(parameterized_function)
  
  # Test parameter combinations
  combinations <- list(
    list(param1 = "value1", param2 = "value2"),
    list(param1 = "value3", param2 = "value4")
  )
  test_parameter_combinations(parameterized_function, combinations)
})
```

### 3. File I/O Testing
```r
test_that("file_function handles file operations", {
  # Test file reading
  test_file_reading(file_function, "test_file.csv")
  
  # Test file writing
  test_data <- create_test_data("basic")
  test_file_writing(file_function, test_data, "output_file.csv")
  
  # Cleanup
  cleanup_test_files("output_file.csv")
})
```

## Best Practices

1. **Use Descriptive Test Names** - Make test purpose clear
2. **Group Related Tests** - Use `describe()` blocks for organization
3. **Test All Code Paths** - Ensure comprehensive coverage
4. **Test Error Conditions** - Don't skip error handling
5. **Use Reusable Patterns** - Leverage these patterns for consistency
6. **Clean Up Test Artifacts** - Remove temporary files and directories
7. **Skip External Dependencies** - Use `skip_on_cran()` appropriately
8. **Validate Test Data** - Ensure test data is realistic and comprehensive

---
*Created: $(date)*
*Status: Ready for implementation*
*Priority: High (essential for efficient testing)*
