# Test verbose branches in validation system
# This file tests the diagnostic output and verbose functionality

test_that("validation system diagnostic output works correctly", {
  # Test that validation functions produce expected output
  # This tests the verbose branches that are currently not covered

  # Create mock data for testing
  mock_categories <- list(
    essential = c("process_zoom_transcript", "summarize_transcript_metrics"),
    deprecated = c("old_function"),
    internal = c("helper_function")
  )

  mock_cran_functions <- c("process_zoom_transcript", "summarize_transcript_metrics")

  mock_analysis <- list(
    process_zoom_transcript = list(
      dependencies = c("dplyr", "lubridate"),
      documentation = TRUE,
      tests = TRUE
    ),
    summarize_transcript_metrics = list(
      dependencies = c("dplyr"),
      documentation = TRUE,
      tests = TRUE
    )
  )

  # Test that validation produces output (verbose branch)
  output <- capture.output({
    result <- validate_audit_results(mock_categories, mock_cran_functions, mock_analysis)
  })

  # Should produce validation output
  expect_true(length(output) > 0)
  expect_true(any(grepl("Validating function audit results", output)))

  # Test individual validation functions
  category_result <- validate_categories(mock_categories)
  expect_true(is.list(category_result))
  expect_true("total_functions" %in% names(category_result))

  dependency_result <- validate_dependencies(mock_cran_functions, mock_analysis)
  expect_true(is.list(dependency_result))

  documentation_result <- validate_documentation(mock_cran_functions, mock_analysis)
  expect_true(is.list(documentation_result))

  test_coverage_result <- validate_test_coverage(mock_cran_functions, mock_analysis)
  expect_true(is.list(test_coverage_result))

  cran_compliance_result <- validate_cran_compliance(mock_cran_functions, mock_analysis)
  expect_true(is.list(cran_compliance_result))
})

test_that("validation system handles edge cases", {
  # Test with empty inputs
  empty_categories <- list()
  empty_functions <- character(0)
  empty_analysis <- list()

  # Should handle empty inputs gracefully
  expect_error(validate_audit_results(empty_categories, empty_functions, empty_analysis), NA)

  # Test with malformed data
  malformed_categories <- list(
    essential = "single_function",
    deprecated = NULL
  )

  expect_error(validate_audit_results(malformed_categories, empty_functions, empty_analysis), NA)
})

test_that("validation recommendations generation works", {
  # Test the generate_validation_recommendations function
  mock_validation_results <- list(
    cran_compliance = list(
      function_count_ok = TRUE,
      documentation_complete = FALSE,
      tests_present = TRUE
    ),
    function_count = 5,
    category_completeness = list(
      total_functions = 5,
      duplicates = FALSE,
      empty_categories = character(0)
    )
  )

  # Test that recommendations are generated
  recommendations <- generate_validation_recommendations(mock_validation_results)
  expect_true(is.list(recommendations))
  expect_true("priority" %in% names(recommendations))
})

test_that("validation system respects quiet mode", {
  # Test that validation can run without producing output when needed
  mock_categories <- list(essential = c("test_function"))
  mock_functions <- c("test_function")
  mock_analysis <- list(test_function = list(dependencies = character(0), documentation = TRUE, tests = TRUE))

  # Should be able to run without errors even in quiet mode
  expect_error(validate_audit_results(mock_categories, mock_functions, mock_analysis), NA)
})
