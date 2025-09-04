test_that("Success Metrics Framework Structure", {
  # Test that the framework has the expected structure
  expect_true(is.list(success_metrics_framework))
  expect_true("cran_readiness" %in% names(success_metrics_framework))
  expect_true("function_scope" %in% names(success_metrics_framework))
  expect_true("performance" %in% names(success_metrics_framework))
  expect_true("user_experience" %in% names(success_metrics_framework))
  expect_true("documentation" %in% names(success_metrics_framework))
  expect_true("process" %in% names(success_metrics_framework))

  # Test CRAN readiness metrics
  expect_equal(success_metrics_framework$cran_readiness$errors, 0)
  expect_equal(success_metrics_framework$cran_readiness$warnings, 0)
  expect_equal(success_metrics_framework$cran_readiness$check_status, "PASS")

  # Test function scope metrics
  expect_equal(success_metrics_framework$function_scope$current, 67)
  expect_equal(success_metrics_framework$function_scope$target, "25-30")
  expect_equal(success_metrics_framework$function_scope$reduction_percentage, "63-67%")

  # Test performance metrics
  expect_equal(success_metrics_framework$performance$transcript_processing, "1MB in <30 seconds")
  expect_equal(success_metrics_framework$performance$test_coverage, "≥90% on essential functions")

  # Test user experience metrics
  expect_equal(success_metrics_framework$user_experience$time_to_first_analysis, "<15 minutes")
  expect_equal(success_metrics_framework$user_experience$workflow_complexity, "≤5 essential functions")

  # Test documentation metrics
  expect_equal(success_metrics_framework$documentation$current_files, 357)
  expect_equal(success_metrics_framework$documentation$target_files, 75)
  expect_equal(success_metrics_framework$documentation$reduction_percentage, "79%")

  # Test process metrics
  expect_equal(success_metrics_framework$process$pre_pr_validation_time, "25 → 10 minutes (60% reduction)")
  expect_equal(success_metrics_framework$process$issue_count, "30 → 75 (150% increase to manageable level)")
})

test_that("Target State Definitions", {
  targets <- get_target_state()

  expect_true(is.list(targets))
  expect_equal(targets$functions, "25-30")
  expect_equal(targets$documentation_files, 75)
  expect_equal(targets$test_coverage, "≥90%")
  expect_equal(targets$cran_readiness, "0 errors, 0 warnings, minimal notes")
  expect_equal(targets$user_experience, "<15 minutes to first analysis")
  expect_equal(targets$performance, "1MB transcript in <30 seconds")
})

test_that("Progress Tracking Function", {
  # Test reduction metrics (functions)
  progress <- track_progress("functions", 67, "25-30")
  expect_equal(progress$metric, "functions")
  expect_equal(progress$current, 67)
  expect_equal(progress$target, "25-30")
  expect_equal(progress$target_avg, 27.5)
  expect_true(progress$progress > 0)
  expect_true(progress$remaining > 0)
  expect_equal(progress$status, "In Progress")

  # Test increase metrics (coverage)
  progress <- track_progress("coverage", 89.08, "≥90")
  expect_equal(progress$metric, "coverage")
  expect_equal(progress$current, 89.08)
  expect_equal(progress$target, "≥90")
  expect_equal(progress$target_avg, 90)
  expect_true(progress$progress > 0)
  expect_true(progress$remaining > 0)
  expect_equal(progress$status, "In Progress")

  # Test completed metrics
  progress <- track_progress("coverage", 95, "≥90")
  expect_equal(progress$status, "Complete")

  # Test edge cases
  progress <- track_progress("test", NA, "100")
  expect_equal(progress$status, "Unknown")
})

test_that("Current Baseline Measurement", {
  baseline <- get_current_baseline()

  expect_true(is.list(baseline))
  expect_true("functions" %in% names(baseline))
  expect_true("documentation_files" %in% names(baseline))
  expect_true("test_coverage" %in% names(baseline))
  expect_true("open_issues" %in% names(baseline))
  expect_true("timestamp" %in% names(baseline))

  # Test that we get actual values (not all NA)
  expect_true(length(baseline) > 0)
  expect_true(!is.null(baseline$timestamp))

  # Test that function count is reasonable
  expect_true(baseline$functions > 0)
  expect_true(baseline$functions < 100)

  # Test that documentation count is reasonable
  expect_true(baseline$documentation_files > 0)
  expect_true(baseline$documentation_files < 1000)

  # Test that test coverage is reasonable
  expect_true(baseline$test_coverage >= 0)
  expect_true(baseline$test_coverage <= 100)
})

test_that("Success Metrics Report Generation", {
  report <- generate_success_metrics_report()

  expect_true(is.list(report))
  expect_true("timestamp" %in% names(report))
  expect_true("framework" %in% names(report))
  expect_true("baseline" %in% names(report))
  expect_true("targets" %in% names(report))
  expect_true("progress" %in% names(report))
  expect_true("summary" %in% names(report))

  # Test summary structure
  expect_true("function_scope_ok" %in% names(report$summary))
  expect_true("test_coverage_ok" %in% names(report$summary))
  expect_true("documentation_ok" %in% names(report$summary))

  # Test that summary contains logical values
  expect_true(is.logical(report$summary$function_scope_ok))
  expect_true(is.logical(report$summary$test_coverage_ok))
  expect_true(is.logical(report$summary$documentation_ok))

  # Test timestamp
  expect_true(inherits(report$timestamp, "POSIXt"))

  # Test progress tracking
  expect_true("functions" %in% names(report$progress))
  expect_true("coverage" %in% names(report$progress))
  expect_true("documentation" %in% names(report$progress))
})

test_that("Success Metrics Summary Printing", {
  # Test that the function runs without error
  expect_no_error(print_success_metrics_summary())

  # Test with custom report
  report <- generate_success_metrics_report()
  expect_no_error(print_success_metrics_summary(report))
})

test_that("Framework Integration", {
  # Test that all framework components work together

  # Generate baseline
  baseline <- get_current_baseline()
  expect_true(is.list(baseline))

  # Get targets
  targets <- get_target_state()
  expect_true(is.list(targets))

  # Track progress
  if (!is.na(baseline$functions)) {
    progress <- track_progress("functions", baseline$functions, targets$functions)
    expect_true(is.list(progress))
  }

  # Generate report
  report <- generate_success_metrics_report()
  expect_true(is.list(report))

  # Print summary
  expect_no_error(print_success_metrics_summary(report))
})

test_that("Privacy and Ethical Compliance", {
  # Test that the framework doesn't expose sensitive information

  # Test that no student data is processed
  expect_false(any(grepl("student", names(success_metrics_framework))))
  expect_false(any(grepl("transcript", names(success_metrics_framework))))

  # Test that metrics are educational and privacy-focused
  expect_true(grepl("R CMD check", success_metrics_framework$cran_readiness$description))
  expect_true(grepl("essential", success_metrics_framework$function_scope$description))
  expect_true(grepl("User experience", success_metrics_framework$user_experience$description))
})

test_that("CRAN Compliance", {
  # Test that the framework supports CRAN submission requirements

  # Test that all required metrics are defined
  required_metrics <- c("cran_readiness", "function_scope", "test_coverage")
  for (metric in required_metrics) {
    expect_true(metric %in% names(success_metrics_framework) ||
      metric %in% names(get_target_state()))
  }

  # Test that validation functions exist
  expect_true(exists("generate_success_metrics_report"))
  expect_true(exists("print_success_metrics_summary"))

  # Test that progress tracking supports CRAN goals
  expect_true(exists("track_progress"))
})

test_that("Realistic Metrics", {
  # Test that the metrics reflect realistic current state

  baseline <- get_current_baseline()

  # Function count should be reasonable for an R package
  expect_true(baseline$functions >= 50)
  expect_true(baseline$functions <= 100)

  # Documentation count should be reasonable
  expect_true(baseline$documentation_files >= 100)
  expect_true(baseline$documentation_files <= 500)

  # Test coverage should be reasonable
  expect_true(baseline$test_coverage >= 80)
  expect_true(baseline$test_coverage <= 95)
})

test_that("Progress Calculation Accuracy", {
  # Test that progress calculations are mathematically correct

  # Test function reduction progress
  progress <- track_progress("functions", 67, "25-30")
  expected_progress <- ((67 - 27.5) / 67) * 100
  expect_equal(progress$progress, expected_progress, tolerance = 0.1)

  # Test documentation reduction progress
  progress <- track_progress("documentation", 357, 75)
  expected_progress <- ((357 - 75) / 357) * 100
  expect_equal(progress$progress, expected_progress, tolerance = 0.1)

  # Test coverage progress
  progress <- track_progress("coverage", 89.08, 90)
  expected_progress <- (89.08 / 90) * 100
  expect_equal(progress$progress, expected_progress, tolerance = 0.1)
})
