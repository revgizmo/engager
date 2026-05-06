#!/usr/bin/env Rscript

#' Fast Performance Test Script
#' 
#' This script runs fast performance tests for PR regression guard.
#' Tests real user workflows with small/medium transcript fixtures.
#' 
#' @param iterations Number of iterations for each test (default: 5)
#' @param output_file File to save results (default: "perf_results.json")
#' @return List of performance metrics
#' @export
run_performance_tests <- function(iterations = 5, output_file = "perf_results.json") {
  
  # Load required packages
  library(engager)
  library(bench)
  library(jsonlite)
  
  cat("Running fast performance tests...\n")
  
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

  summarize_bench <- function(result, iterations) {
    result_summary <- summary(result)
    list(
      time_median_ms = as.numeric(result_summary$median) * 1000,
      memory_peak_mb = as.numeric(result_summary$mem_alloc) / 1024^2,
      gc_count = sum(result$gc[[1]][, "level2"]),
      iterations = iterations
    )
  }

  make_name_matching_fixture <- function(n) {
    names <- sprintf("Student %05d", seq_len(n))
    list(
      transcripts = data.frame(
        speaker = names,
        timestamp = as.POSIXct("2025-01-01 10:00:00", tz = "UTC") +
          seq_len(n),
        stringsAsFactors = FALSE
      ),
      roster = data.frame(
        preferred_name = names,
        student_id = sprintf("S%05d", seq_len(n)),
        stringsAsFactors = FALSE
      )
    )
  }
  
  # Test fixtures - use actual transcript files if available
  transcript_dir <- system.file("extdata", "transcripts", package = "engager")
  
  # Small transcript test
  small_files <- list.files(transcript_dir, pattern = "\\.(vtt|csv)$", full.names = TRUE)
  if (length(small_files) > 0) {
    small_file <- small_files[1]
    cat("Testing small transcript:", basename(small_file), "\n")
    
    # Test process_zoom_transcript on small file
    small_result <- bench::mark(
      {
        result <- process_zoom_transcript(small_file)
        result
      },
      iterations = iterations,
      memory = TRUE,
      check = FALSE,
      filter_gc = FALSE
    )
    
    results$tests$small_vtt_parse <- summarize_bench(small_result, iterations)
    
    # Test engagement_summary if we have parsed data
    if (length(small_files) > 1) {
      medium_file <- small_files[2]
      cat("Testing engagement summary...\n")
      
      summary_result <- bench::mark(
        {
          parsed <- process_zoom_transcript(medium_file)
          result <- summarize_transcript_metrics(transcript_df = parsed)
          result
        },
        iterations = max(1, iterations - 2),  # Fewer iterations for complex operation
        memory = TRUE,
        check = FALSE,
        filter_gc = FALSE
      )
      
      results$tests$engagement_summary <- summarize_bench(
        summary_result,
        max(1, iterations - 2)
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
    synthetic_result <- bench::mark(
      {
        # Simulate basic processing
        result <- synthetic_data
        result$word_count <- nchar(result$message)
        result
      },
      iterations = iterations,
      memory = TRUE,
      check = FALSE,
      filter_gc = FALSE
    )
    
    results$tests$synthetic_processing <- summarize_bench(
      synthetic_result,
      iterations
    )
  }

  for (n in c(100, 1000, 5000)) {
    fixture <- make_name_matching_fixture(n)
    test_iterations <- if (n >= 5000) max(1, min(3, iterations)) else iterations
    test_name <- paste0("name_matching_", n)
    cat("Testing name matching:", n, "speakers\n")

    name_match_result <- bench::mark(
      {
        result <- match_names_workflow(
          fixture$transcripts,
          fixture$roster,
          options = list(match_strategy = "exact")
        )
        summary(result)
      },
      iterations = test_iterations,
      memory = TRUE,
      check = FALSE,
      filter_gc = FALSE
    )

    results$tests[[test_name]] <- summarize_bench(
      name_match_result,
      test_iterations
    )
  }
  
  # Save results
  jsonlite::write_json(results, output_file, pretty = TRUE)
  cat("Performance test results saved to:", output_file, "\n")
  
  # Print summary
  cat("\nPerformance Test Summary:\n")
  for (test_name in names(results$tests)) {
    test <- results$tests[[test_name]]
    cat(sprintf("  %s: %.1f ms, %.1f MB, %d GC\n", 
                test_name, test$time_median_ms, test$memory_peak_mb, test$gc_count))
  }
  
  return(results)
}

# Run if called directly
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  iterations <- if (length(args) > 0) as.numeric(args[1]) else 5
  output_file <- if (length(args) > 1) args[2] else "perf_results.json"
  
  run_performance_tests(iterations, output_file)
}
