#!/usr/bin/env Rscript

#' Simple Performance Test Script
#' 
#' This script runs simple performance tests without bench::mark() complexity.
#' Tests real user workflows with small/medium transcript fixtures.
#' 
#' @param iterations Number of iterations for each test (default: 5)
#' @param output_file File to save results (default: "perf_results.json")
#' @return List of performance metrics
#' @export
run_simple_performance_tests <- function(iterations = 5, output_file = "perf_results.json") {
  
  # Set timeout for performance tests (5 minutes)
  options(timeout = 300)
  
  # Load required packages with error handling
  tryCatch({
    # Try to load engager package, if not available, use devtools::load_all()
    if (!requireNamespace("engager", quietly = TRUE)) {
      if (requireNamespace("devtools", quietly = TRUE)) {
        devtools::load_all(".")
      } else {
        stop("engager package not available and devtools not installed")
      }
    }
    library(engager)
    library(jsonlite)
  }, error = function(e) {
    cat("ERROR: Failed to load required packages:", e$message, "\n")
    quit(status = 1)
  })
  
  cat("Running simple performance tests...\n")
  
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
  
  # Test fixtures - use actual transcript files if available
  transcript_dir <- system.file("extdata", "transcripts", package = "engager")
  
  # Small transcript test
  small_files <- list.files(transcript_dir, pattern = "\\.(vtt|csv)$", full.names = TRUE)
  if (length(small_files) > 0) {
    small_file <- small_files[1]
    cat("Testing small transcript:", basename(small_file), "\n")
    
    # Test process_zoom_transcript on small file
    times <- numeric(iterations)
    memory_usage <- numeric(iterations)
    
    for (i in seq_len(iterations)) {
      start_time <- Sys.time()
      start_memory <- gc(verbose = FALSE)[1, "used"]
      
      result <- process_zoom_transcript(small_file)
      
      end_time <- Sys.time()
      end_memory <- gc(verbose = FALSE)[1, "used"]
      
      times[i] <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
      memory_usage[i] <- end_memory - start_memory
    }
    
    results$tests$small_vtt_parse <- list(
      time_median_ms = median(times),
      time_mean_ms = mean(times),
      memory_peak_mb = max(memory_usage) / 1024^2,
      memory_median_mb = median(memory_usage) / 1024^2,
      iterations = iterations
    )
    
    # Test engagement_summary if we have parsed data
    if (length(small_files) > 1) {
      medium_file <- small_files[2]
      cat("Testing engagement summary...\n")
      
      summary_times <- numeric(max(1, iterations - 2))
      summary_memory <- numeric(max(1, iterations - 2))
      
      for (i in seq_len(max(1, iterations - 2))) {
        start_time <- Sys.time()
        start_memory <- gc(verbose = FALSE)[1, "used"]
        
        parsed <- process_zoom_transcript(medium_file)
        result <- summarize_transcript_metrics(transcript_df = parsed)
        
        end_time <- Sys.time()
        end_memory <- gc(verbose = FALSE)[1, "used"]
        
        summary_times[i] <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
        summary_memory[i] <- end_memory - start_memory
      }
      
      results$tests$engagement_summary <- list(
        time_median_ms = median(summary_times),
        time_mean_ms = mean(summary_times),
        memory_peak_mb = max(summary_memory) / 1024^2,
        memory_median_mb = median(summary_memory) / 1024^2,
        iterations = max(1, iterations - 2)
      )
    }
  } else {
    # Fallback: create synthetic test data
    cat("No transcript files found, creating synthetic test...\n")
    
    # Create minimal synthetic data for testing
    synthetic_data <- data.frame(
      user_name = rep(c("Student A", "Student B"), 10),
      message = rep("Test message", 20),
      timestamp = seq(as.POSIXct("2025-01-01 10:00:00"), length.out = 20, by = "1 min")
    )
    
    # Test basic data processing
    synthetic_times <- numeric(iterations)
    synthetic_memory <- numeric(iterations)
    
    for (i in seq_len(iterations)) {
      start_time <- Sys.time()
      start_memory <- gc(verbose = FALSE)[1, "used"]
      
      # Simulate basic processing
      result <- synthetic_data
      result$word_count <- nchar(result$message)
      result$hour <- as.numeric(format(result$timestamp, "%H"))
      result$engagement_score <- result$word_count * result$hour
      
      end_time <- Sys.time()
      end_memory <- gc(verbose = FALSE)[1, "used"]
      
      synthetic_times[i] <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
      synthetic_memory[i] <- end_memory - start_memory
    }
    
    results$tests$synthetic_processing <- list(
      time_median_ms = median(synthetic_times),
      time_mean_ms = mean(synthetic_times),
      memory_peak_mb = max(synthetic_memory) / 1024^2,
      memory_median_mb = median(synthetic_memory) / 1024^2,
      iterations = iterations
    )
  }
  
  # Save results
  jsonlite::write_json(results, output_file, pretty = TRUE)
  cat("Performance test results saved to:", output_file, "\n")
  
  # Print summary
  cat("\nPerformance Test Summary:\n")
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
  iterations <- if (length(args) > 0) as.numeric(args[1]) else 5
  output_file <- if (length(args) > 1) args[2] else "perf_results.json"
  
  # Run with error handling
  tryCatch({
    run_simple_performance_tests(iterations, output_file)
  }, error = function(e) {
    cat("ERROR: Performance test failed:", e$message, "\n")
    quit(status = 1)
  })
}
