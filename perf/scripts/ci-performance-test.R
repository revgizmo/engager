#!/usr/bin/env Rscript

#' CI-Friendly Performance Test Script
#' 
#' This script runs performance tests in a CI environment with minimal dependencies.
#' It focuses on basic functionality rather than complex transcript processing.

# Load required packages with error handling
tryCatch({
  library(jsonlite)
}, error = function(e) {
  cat("ERROR: Failed to load jsonlite:", e$message, "\n")
  quit(status = 1)
})

# Function to run basic performance tests
run_ci_performance_tests <- function(iterations = 3, output_file = "perf_results.json") {
  
  cat("Running CI-friendly performance tests...\n")
  
  # Initialize results
  results <- list(
    timestamp = Sys.time(),
    environment = list(
      os = Sys.info()[["sysname"]],
      r_version = R.version.string,
      platform = R.version$platform
    ),
    tests = list()
  )
  
  # Test 1: Basic R operations (synthetic test)
  cat("Testing basic R operations...\n")
  
  times_basic <- numeric(iterations)
  memory_basic <- numeric(iterations)
  
  for (i in seq_len(iterations)) {
    start_time <- Sys.time()
    start_memory <- gc(verbose = FALSE)[1, "used"]
    
    # Basic data processing
    data <- data.frame(
      x = rnorm(1000),
      y = rnorm(1000),
      z = rnorm(1000)
    )
    data$sum <- data$x + data$y + data$z
    data$mean <- (data$x + data$y + data$z) / 3
    data$norm <- sqrt(data$x^2 + data$y^2 + data$z^2)
    
    end_time <- Sys.time()
    end_memory <- gc(verbose = FALSE)[1, "used"]
    
    times_basic[i] <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
    memory_basic[i] <- end_memory - start_memory
  }
  
  results$tests$basic_operations <- list(
    time_median_ms = median(times_basic),
    time_mean_ms = mean(times_basic),
    memory_peak_mb = max(memory_basic) / 1024^2,
    memory_median_mb = median(memory_basic) / 1024^2,
    iterations = iterations
  )
  
  # Test 2: String processing (simulating transcript-like operations)
  cat("Testing string processing...\n")
  
  times_string <- numeric(iterations)
  memory_string <- numeric(iterations)
  
  for (i in seq_len(iterations)) {
    start_time <- Sys.time()
    start_memory <- gc(verbose = FALSE)[1, "used"]
    
    # String processing simulation
    messages <- paste0("Student message ", 1:100, ": This is a test message for performance testing")
    word_counts <- nchar(messages)
    processed <- toupper(messages)
    filtered <- messages[word_counts > 20]
    
    end_time <- Sys.time()
    end_memory <- gc(verbose = FALSE)[1, "used"]
    
    times_string[i] <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
    memory_string[i] <- end_memory - start_memory
  }
  
  results$tests$string_processing <- list(
    time_median_ms = median(times_string),
    time_mean_ms = mean(times_string),
    memory_peak_mb = max(memory_string) / 1024^2,
    memory_median_mb = median(memory_string) / 1024^2,
    iterations = iterations
  )
  
  # Save results
  jsonlite::write_json(results, output_file, pretty = TRUE)
  cat("CI performance test results saved to:", output_file, "\n")
  
  # Print summary
  cat("\nCI Performance Test Summary:\n")
  for (test_name in names(results$tests)) {
    test <- results$tests[[test_name]]
    cat(sprintf("  %s: %.1f ms (median), %.1f ms (mean), %.1f MB (peak)\n", 
                test_name, test$time_median_ms, test$time_mean_ms, test$memory_peak_mb))
  }
  
  return(results)
}

# Run if called directly
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  iterations <- if (length(args) > 0) as.numeric(args[1]) else 3
  output_file <- if (length(args) > 1) args[2] else "perf_results.json"
  
  # Run with error handling
  tryCatch({
    run_ci_performance_tests(iterations, output_file)
  }, error = function(e) {
    cat("ERROR: CI performance test failed:", e$message, "\n")
    quit(status = 1)
  })
}
