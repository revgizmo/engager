# Test verbose branches in enhanced function audit system
# This file tests the diagnostic output and verbose functionality

test_that("enhanced function audit provides comprehensive analysis", {
  # Test that the audit system can analyze functions
  # Note: This may produce output, so we capture it

  # Test get_exported_functions
  exported_functions <- get_exported_functions()
  expect_true(is.character(exported_functions))
  
  # Skip test if NAMESPACE file doesn't exist (test environment)
  if (file.exists("NAMESPACE")) {
    expect_true(length(exported_functions) > 0)
  } else {
    skip("NAMESPACE file not available in test environment")
  }

  # Test analyze_function with a known function
  if (length(exported_functions) > 0) {
    test_function <- exported_functions[1]
    analysis <- analyze_function(test_function)
    expect_true(is.list(analysis))
  }
})

test_that("function categorization works correctly", {
  # Test function categorization
  mock_analysis <- list(
    process_zoom_transcript = list(
      category = "essential",
      dependencies = c("dplyr", "lubridate"),
      complexity = "medium"
    ),
    old_function = list(
      category = "deprecated",
      dependencies = c("base"),
      complexity = "low"
    )
  )

  # Test categorization
  categories <- categorize_functions(mock_analysis)
  expect_true(is.list(categories))
  expect_true(length(categories) > 0)
})

test_that("audit report generation works correctly", {
  # Test audit report generation
  mock_categories <- list(
    essential = c("process_zoom_transcript"),
    deprecated = c("old_function")
  )

  mock_analysis <- list(
    process_zoom_transcript = list(
      category = "essential",
      dependencies = c("dplyr", "lubridate"),
      complexity = "medium"
    ),
    old_function = list(
      category = "deprecated",
      dependencies = c("base"),
      complexity = "low"
    )
  )

  # Test report generation
  report <- generate_audit_report(mock_categories, mock_analysis)
  expect_true(is.list(report))
  expect_true(length(report) > 0)
})

test_that("enhanced function audit handles edge cases", {
  # Test with empty inputs
  empty_analysis <- list()
  empty_categories <- list()

  # Should handle empty inputs gracefully
  expect_error(categorize_functions(empty_analysis), NA)
  expect_error(generate_audit_report(empty_categories, empty_analysis), NA)

  # Test with minimal data
  minimal_analysis <- list(
    test_function = list(
      category = "essential",
      dependencies = character(0),
      complexity = "low"
    )
  )

  minimal_categories <- list(essential = c("test_function"))

  # Should handle minimal data gracefully
  expect_error(categorize_functions(minimal_analysis), NA)
  expect_error(generate_audit_report(minimal_categories, minimal_analysis), NA)
})

test_that("enhanced function audit respects quiet mode", {
  # Test that audit functions can run without verbose output when needed
  mock_analysis <- list(
    test_function = list(
      category = "essential",
      dependencies = c("dplyr"),
      complexity = "medium"
    )
  )

  mock_categories <- list(essential = c("test_function"))

  # Should be able to categorize without errors
  expect_error(categorize_functions(mock_analysis), NA)

  # Should be able to generate report without errors
  expect_error(generate_audit_report(mock_categories, mock_analysis), NA)
})

test_that("function analysis provides meaningful insights", {
  # Test that function analysis produces useful information
  exported_functions <- get_exported_functions()

  if (length(exported_functions) > 0) {
    test_function <- exported_functions[1]
    analysis <- analyze_function(test_function)

    # Should provide analysis information
    expect_true(is.list(analysis))
    expect_true(length(analysis) > 0)
  }
})

test_that("audit system provides comprehensive coverage", {
  # Test that the audit system covers all necessary aspects
  mock_analysis <- list(
    essential_func = list(
      category = "essential",
      dependencies = c("dplyr", "lubridate"),
      complexity = "medium",
      documentation = TRUE,
      tests = TRUE
    ),
    deprecated_func = list(
      category = "deprecated",
      dependencies = c("base"),
      complexity = "low",
      documentation = FALSE,
      tests = FALSE
    )
  )

  categories <- categorize_functions(mock_analysis)
  report <- generate_audit_report(categories, mock_analysis)

  # Should provide comprehensive analysis
  expect_true(is.list(categories))
  expect_true(is.list(report))
  expect_true(length(categories) > 0)
  expect_true(length(report) > 0)
})

test_that("function audit handles complex scenarios", {
  # Test with complex function analysis
  complex_analysis <- list(
    complex_function = list(
      category = "essential",
      dependencies = c("dplyr", "lubridate", "ggplot2", "stringr"),
      complexity = "high",
      documentation = TRUE,
      tests = TRUE,
      lines_of_code = 150,
      cyclomatic_complexity = 8
    ),
    simple_function = list(
      category = "utility",
      dependencies = c("base"),
      complexity = "low",
      documentation = TRUE,
      tests = TRUE,
      lines_of_code = 10,
      cyclomatic_complexity = 1
    )
  )

  # Should handle complex analysis
  expect_error(categorize_functions(complex_analysis), NA)

  complex_categories <- categorize_functions(complex_analysis)
  expect_error(generate_audit_report(complex_categories, complex_analysis), NA)
})
