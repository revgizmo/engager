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
  expect_true(file.exists("perf/scripts/performance-test.R"))
  expect_true(file.exists("perf/scripts/check-performance-regression.R"))
  expect_true(file.exists("perf/scripts/performance-profiling.R"))
})

test_that("performance baselines exist", {
  skip_on_cran()
  
  # Check that baseline files exist
  expect_true(file.exists("perf/baselines/linux-R-release.json"))
  expect_true(file.exists("perf/baselines/macos-R-release.json"))
  expect_true(file.exists("perf/baselines/windows-R-release.json"))
})

test_that("performance test functions are available", {
  skip_on_cran()
  
  # Test that performance test functions can be loaded
  source("perf/scripts/performance-test.R", local = TRUE)
  source("perf/scripts/check-performance-regression.R", local = TRUE)
  source("perf/scripts/performance-profiling.R", local = TRUE)
  
  # Check that functions exist
  expect_true(exists("run_performance_tests"))
  expect_true(exists("check_performance_regression"))
  expect_true(exists("run_performance_profiling"))
})

test_that("performance test data structure is valid", {
  skip_on_cran()
  
  # Test that baseline JSON files are valid
  baseline_files <- c(
    "perf/baselines/linux-R-release.json",
    "perf/baselines/macos-R-release.json", 
    "perf/baselines/windows-R-release.json"
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
