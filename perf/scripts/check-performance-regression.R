#!/usr/bin/env Rscript

#' Performance Regression Detection
#' 
#' This script compares current performance results to baseline and detects regressions.
#' Used in PR regression guard to block PRs with performance regressions.
#' 
#' @param current_file Current performance results file (default: "perf_results.json")
#' @param baseline_file Baseline performance file (default: "perf/baselines/linux-R-release.json")
#' @return Exit code 0 if no regression, 1 if regression detected
#' @export
check_performance_regression <- function(current_file = "perf_results.json", 
                                        baseline_file = "perf/baselines/linux-R-release.json") {
  
  library(jsonlite)
  
  cat("Checking for performance regressions...\n")
  
  # Load current and baseline results
  if (!file.exists(current_file)) {
    cat("ERROR: Current performance results file not found:", current_file, "\n")
    return(1)
  }
  
  if (!file.exists(baseline_file)) {
    cat("ERROR: Baseline file not found:", baseline_file, "\n")
    return(1)
  }
  
  current <- jsonlite::fromJSON(current_file)
  baseline <- jsonlite::fromJSON(baseline_file)
  
  # Extract regression thresholds
  time_threshold <- baseline$regression_thresholds$time_increase_percent / 100
  memory_threshold <- baseline$regression_thresholds$memory_increase_percent / 100
  
  cat("Regression thresholds: +", baseline$regression_thresholds$time_increase_percent, 
      "% time, +", baseline$regression_thresholds$memory_increase_percent, "% memory\n")
  
  regressions <- list()
  
  # Check each test for regressions
  for (test_name in names(current$tests)) {
    if (test_name %in% names(baseline$performance_metrics)) {
      current_test <- current$tests[[test_name]]
      baseline_test <- baseline$performance_metrics[[test_name]]
      
      # Check time regression
      time_increase <- (current_test$time_median_ms - baseline_test$time_median_ms) / baseline_test$time_median_ms
      if (time_increase > time_threshold) {
        regressions[[paste0(test_name, "_time")]] <- list(
          type = "time",
          increase_percent = time_increase * 100,
          current = current_test$time_median_ms,
          baseline = baseline_test$time_median_ms,
          threshold = baseline$regression_thresholds$time_increase_percent
        )
      }
      
      # Check memory regression
      memory_increase <- (current_test$memory_peak_mb - baseline_test$memory_peak_mb) / baseline_test$memory_peak_mb
      if (memory_increase > memory_threshold) {
        regressions[[paste0(test_name, "_memory")]] <- list(
          type = "memory",
          increase_percent = memory_increase * 100,
          current = current_test$memory_peak_mb,
          baseline = baseline_test$memory_peak_mb,
          threshold = baseline$regression_thresholds$memory_increase_percent
        )
      }
    }
  }
  
  # Report results
  if (length(regressions) > 0) {
    cat("\n❌ PERFORMANCE REGRESSIONS DETECTED:\n")
    for (regression_name in names(regressions)) {
      reg <- regressions[[regression_name]]
      cat(sprintf("  %s: +%.1f%% %s (current: %.1f, baseline: %.1f, threshold: +%.1f%%)\n",
                  regression_name, reg$increase_percent, reg$type, 
                  reg$current, reg$baseline, reg$threshold))
    }
    cat("\nThis PR will be blocked due to performance regressions.\n")
    cat("Consider optimizing the code or updating the baseline if the regression is acceptable.\n")
    return(1)
  } else {
    cat("\n✅ No performance regressions detected.\n")
    return(0)
  }
}

# Run if called directly
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  current_file <- if (length(args) > 0) args[1] else "perf_results.json"
  baseline_file <- if (length(args) > 1) args[2] else "perf/baselines/linux-R-release.json"
  
  exit_code <- check_performance_regression(current_file, baseline_file)
  quit(status = exit_code)
}
