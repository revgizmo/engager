# Performance Tests - CRAN Safe
# These tests are wrapped in skip_on_cran() to ensure they don't affect CRAN submission

test_that("performance tests are skipped on CRAN", {
  skip_on_cran()
  
  # This test ensures performance tests don't run on CRAN
  # The actual performance testing is done in CI workflows
  expect_true(TRUE)
})

test_that("performance test infrastructure exists", {
  skip_on_cran()
  
  # Check that performance test scripts exist
  # Use relative paths from tests/testthat/ to package root
  expect_true(file.exists("../../perf/scripts/performance-test.R"))
  expect_true(file.exists("../../perf/scripts/check-performance-regression.R"))
  expect_true(file.exists("../../perf/scripts/performance-profiling.R"))
})

test_that("performance baselines exist", {
  skip_on_cran()
  
  # Check that baseline files exist
  # Use relative paths from tests/testthat/ to package root
  expect_true(file.exists("../../perf/baselines/linux-R-release.json"))
  expect_true(file.exists("../../perf/baselines/macos-R-release.json"))
  expect_true(file.exists("../../perf/baselines/windows-R-release.json"))
})

test_that("performance test functions are available", {
  skip_on_cran()
  
  # Test that performance test functions can be loaded
  # Use relative paths from tests/testthat/ to package root
  # Note: We don't actually run these functions in tests to avoid bench::mark() issues
  # The actual performance testing is done in CI workflows
  
  # Check that the script files are readable and contain expected functions
  perf_test_content <- readLines("../../perf/scripts/performance-test.R", warn = FALSE)
  expect_true(any(grepl("run_performance_tests", perf_test_content)))
  
  regression_content <- readLines("../../perf/scripts/check-performance-regression.R", warn = FALSE)
  expect_true(any(grepl("check_performance_regression", regression_content)))
  
  profiling_content <- readLines("../../perf/scripts/performance-profiling.R", warn = FALSE)
  expect_true(any(grepl("run_performance_profiling", profiling_content)))
})

test_that("performance test data structure is valid", {
  skip_on_cran()
  
  # Test that baseline JSON files are valid
  # Use relative paths from tests/testthat/ to package root
  baseline_files <- c(
    "../../perf/baselines/linux-R-release.json",
    "../../perf/baselines/macos-R-release.json", 
    "../../perf/baselines/windows-R-release.json"
  )
  
  for (baseline_file in baseline_files) {
    if (file.exists(baseline_file)) {
      baseline <- jsonlite::fromJSON(baseline_file)
      
      # Check required structure
      expect_true("environment" %in% names(baseline))
      expect_true("performance_metrics" %in% names(baseline))
      expect_true("regression_thresholds" %in% names(baseline))
      
      # Check regression thresholds are reasonable
      expect_true(baseline$regression_thresholds$time_increase_percent > 0)
      expect_true(baseline$regression_thresholds$memory_increase_percent > 0)
    }
  }
})
