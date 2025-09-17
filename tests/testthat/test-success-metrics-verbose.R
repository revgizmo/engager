# Test verbose branches in success metrics system
# This file tests the diagnostic output and verbose functionality

test_that("success metrics framework provides comprehensive tracking", {
  skip_on_cran()
  # Test that the success metrics framework is properly structured
  expect_true(is.list(success_metrics_framework))
  expect_true("cran_readiness" %in% names(success_metrics_framework))
  expect_true("function_scope" %in% names(success_metrics_framework))
  expect_true("performance" %in% names(success_metrics_framework))
  expect_true("user_experience" %in% names(success_metrics_framework))
  expect_true("documentation" %in% names(success_metrics_framework))

  # Test CRAN readiness metrics
  cran_metrics <- success_metrics_framework$cran_readiness
  expect_equal(cran_metrics$errors, 0)
  expect_equal(cran_metrics$warnings, 0)
  expect_equal(cran_metrics$check_status, "PASS")

  # Test function scope metrics
  scope_metrics <- success_metrics_framework$function_scope
  expect_true(is.numeric(scope_metrics$current))
  expect_true(scope_metrics$current > 0)
})

test_that("calculate_overall_status works correctly", {
  skip_on_cran()
  # Test the calculate_overall_status function
  mock_metrics <- list(
    cran_readiness = list(errors = 0, warnings = 0, check_status = "PASS"),
    function_scope = list(current = 25, target = "25-30"),
    performance = list(test_coverage = "≥90%"),
    user_experience = list(workflow_complexity = "≤5 essential functions"),
    documentation = list(essential_guides = 5)
  )

  # Test that status calculation works
  status <- calculate_overall_status(mock_metrics)
  expect_true(is.character(status))
  expect_true(length(status) > 0)
})

test_that("get_target_state provides current targets", {
  skip_on_cran()
  # Test the get_target_state function
  target_state <- get_target_state()
  expect_true(is.list(target_state))
  expect_true(length(target_state) > 0)
})

test_that("success metrics handle edge cases", {
  skip_on_cran()
  # Test with minimal data
  minimal_metrics <- list(
    cran_readiness = list(errors = 0, warnings = 0),
    function_scope = list(current = 1)
  )

  # Should handle minimal data gracefully
  expect_error(calculate_overall_status(minimal_metrics), NA)

  # Test with missing data
  incomplete_metrics <- list(
    cran_readiness = list(errors = 0)
  )

  # Should handle incomplete data gracefully
  expect_error(calculate_overall_status(incomplete_metrics), NA)
})

test_that("success metrics provide actionable insights", {
  # Test that metrics provide useful information
  current_state <- get_target_state()

  # Should provide current status
  expect_true(is.list(current_state))
  expect_true(length(current_state) > 0)

  # Test overall status calculation
  overall_status <- calculate_overall_status(success_metrics_framework)
  expect_true(is.character(overall_status))
  expect_true(nchar(overall_status) > 0)
})

test_that("success metrics respect quiet mode", {
  # Test that metrics can be calculated without verbose output
  mock_metrics <- list(
    cran_readiness = list(errors = 0, warnings = 0, check_status = "PASS"),
    function_scope = list(current = 25, target = "25-30")
  )

  # Should be able to calculate status without errors
  expect_error(calculate_overall_status(mock_metrics), NA)

  # Should be able to get target state without errors
  expect_error(get_target_state(), NA)
})

test_that("track_success_metrics returns structured report with progress", {
  skip_on_cran()

  captured_warnings <- character()
  report <- withCallingHandlers(
    track_success_metrics(),
    warning = function(w) {
      captured_warnings <<- c(captured_warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  expect_true(any(grepl("deprecated", captured_warnings)))

  expect_true(is.list(report))
  expect_true(all(c("timestamp", "framework", "baseline", "targets", "progress", "summary") %in% names(report)))
  expect_s3_class(report$timestamp, "POSIXct")

  baseline <- report$baseline
  expect_true(is.list(baseline))
  expect_true(all(c("functions", "documentation_files", "test_coverage", "open_issues", "timestamp") %in% names(baseline)))

  expected_functions <- length(list.files("R/", pattern = "\\.R$", full.names = FALSE))
  expect_equal(baseline$functions, expected_functions)

  expected_docs <- length(list.files("docs/", recursive = TRUE))
  expect_equal(baseline$documentation_files, expected_docs)

  expect_true(is.numeric(baseline$test_coverage) || is.na(baseline$test_coverage))

  expect_true(is.list(report$progress))
  expect_true(all(c("function_scope_ok", "test_coverage_ok", "documentation_ok") %in% names(report$summary)))

  if (!is.null(report$progress$functions)) {
    expect_equal(report$progress$functions$metric, "functions")
    expect_equal(report$progress$functions$current, baseline$functions)
  }

  if (!is.null(report$progress$documentation)) {
    expect_equal(report$progress$documentation$metric, "documentation")
    expect_equal(report$progress$documentation$current, baseline$documentation_files)
  }
})
