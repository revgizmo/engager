#!/usr/bin/env Rscript

#' Comprehensive Performance Profiling Script
#' 
#' This script runs comprehensive performance profiling for weekly trend tracking.
#' Includes large synthetic datasets and detailed performance analysis.
#' 
#' @param output_dir Directory to save profiling results (default: "perf/reports/weekly")
#' @return List of comprehensive performance metrics
#' @export
run_performance_profiling <- function(output_dir = "perf/reports/weekly") {
  
  library(engager)
  library(bench)
  library(jsonlite)
  library(profvis)
  
  # Create output directory
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  
  cat("Running comprehensive performance profiling...\n")
  
  # Initialize results
  results <- list(
    timestamp = Sys.time(),
    environment = list(
      os = Sys.info()[["sysname"]],
      r_version = R.version.string,
      platform = R.version$platform,
      memory_limit = memory.limit()
    ),
    profiling = list()
  )
  
  # Test 1: Small transcript processing
  cat("Profiling small transcript processing...\n")
  transcript_dir <- system.file("extdata", "transcripts", package = "engager")
  small_files <- list.files(transcript_dir, pattern = "\\.(vtt|csv)$", full.names = TRUE)
  
  if (length(small_files) > 0) {
    small_file <- small_files[1]
    
    # Detailed profiling with multiple iterations
    small_profiling <- bench::mark(
      parse_vtt(small_file),
      iterations = 10,
      memory = TRUE,
      check = FALSE,
      filter_gc = FALSE
    )
    
    results$profiling$small_transcript <- list(
      time_stats = list(
        median_ms = as.numeric(median(small_profiling$time)) * 1000,
        mean_ms = as.numeric(mean(small_profiling$time)) * 1000,
        p95_ms = as.numeric(quantile(small_profiling$time, 0.95)) * 1000,
        min_ms = as.numeric(min(small_profiling$time)) * 1000,
        max_ms = as.numeric(max(small_profiling$time)) * 1000
      ),
      memory_stats = list(
        median_mb = as.numeric(median(small_profiling$memory)) / 1024^2,
        mean_mb = as.numeric(mean(small_profiling$memory)) / 1024^2,
        peak_mb = as.numeric(max(small_profiling$memory)) / 1024^2
      ),
      gc_stats = list(
        median_count = median(small_profiling$gc_count),
        mean_count = mean(small_profiling$gc_count),
        total_count = sum(small_profiling$gc_count)
      ),
      file_size_kb = file.size(small_file) / 1024
    )
  }
  
  # Test 2: Medium transcript processing
  if (length(small_files) > 1) {
    cat("Profiling medium transcript processing...\n")
    medium_file <- small_files[2]
    
    medium_profiling <- bench::mark(
      parse_vtt(medium_file),
      iterations = 8,
      memory = TRUE,
      check = FALSE,
      filter_gc = FALSE
    )
    
    results$profiling$medium_transcript <- list(
      time_stats = list(
        median_ms = as.numeric(median(medium_profiling$time)) * 1000,
        mean_ms = as.numeric(mean(medium_profiling$time)) * 1000,
        p95_ms = as.numeric(quantile(medium_profiling$time, 0.95)) * 1000
      ),
      memory_stats = list(
        median_mb = as.numeric(median(medium_profiling$memory)) / 1024^2,
        peak_mb = as.numeric(max(medium_profiling$memory)) / 1024^2
      ),
      gc_stats = list(
        median_count = median(medium_profiling$gc_count),
        total_count = sum(medium_profiling$gc_count)
      ),
      file_size_kb = file.size(medium_file) / 1024
    )
  }
  
  # Test 3: Large synthetic dataset (O(n²) canary)
  cat("Profiling large synthetic dataset...\n")
  
  # Create large synthetic dataset
  large_data <- data.frame(
    user_name = rep(paste0("Student_", sprintf("%03d", 1:100)), 50),
    message = rep("This is a test message for performance profiling", 5000),
    timestamp = seq(as.POSIXct("2025-01-01 10:00:00"), length.out = 5000, by = "1 min")
  )
  
  large_profiling <- bench::mark(
    {
      # Simulate complex processing
      result <- large_data
      result$word_count <- nchar(result$message)
      result$hour <- as.numeric(format(result$timestamp, "%H"))
      result$engagement_score <- result$word_count * result$hour
      result
    },
    iterations = 5,
    memory = TRUE,
    check = FALSE,
    filter_gc = FALSE
  )
  
  results$profiling$large_synthetic <- list(
    time_stats = list(
      median_ms = as.numeric(median(large_profiling$time)) * 1000,
      mean_ms = as.numeric(mean(large_profiling$time)) * 1000,
      p95_ms = as.numeric(quantile(large_profiling$time, 0.95)) * 1000
    ),
    memory_stats = list(
      median_mb = as.numeric(median(large_profiling$memory)) / 1024^2,
      peak_mb = as.numeric(max(large_profiling$memory)) / 1024^2
    ),
    gc_stats = list(
      median_count = median(large_profiling$gc_count),
      total_count = sum(large_profiling$gc_count)
    ),
    dataset_size = nrow(large_data)
  )
  
  # Test 4: Memory stress test
  cat("Running memory stress test...\n")
  
  memory_test <- bench::mark(
    {
      # Create and process multiple datasets
      datasets <- lapply(1:10, function(i) {
        data.frame(
          id = 1:1000,
          value = rnorm(1000),
          category = rep(LETTERS[1:10], 100)
        )
      })
      
      # Process all datasets
      results <- lapply(datasets, function(df) {
        df$processed <- df$value * 2
        df$category_sum <- ave(df$value, df$category, FUN = sum)
        df
      })
      
      # Clean up
      rm(datasets)
      gc()
      
      results
    },
    iterations = 3,
    memory = TRUE,
    check = FALSE,
    filter_gc = FALSE
  )
  
  results$profiling$memory_stress <- list(
    time_stats = list(
      median_ms = as.numeric(median(memory_test$time)) * 1000,
      mean_ms = as.numeric(mean(memory_test$time)) * 1000
    ),
    memory_stats = list(
      median_mb = as.numeric(median(memory_test$memory)) / 1024^2,
      peak_mb = as.numeric(max(memory_test$memory)) / 1024^2
    ),
    gc_stats = list(
      median_count = median(memory_test$gc_count),
      total_count = sum(memory_test$gc_count)
    )
  )
  
  # Save comprehensive results
  timestamp_str <- format(Sys.time(), "%Y%m%d_%H%M%S")
  output_file <- file.path(output_dir, paste0("profiling_", timestamp_str, ".json"))
  jsonlite::write_json(results, output_file, pretty = TRUE)
  
  # Save summary report
  summary_file <- file.path(output_dir, paste0("summary_", timestamp_str, ".txt"))
  writeLines(c(
    paste("Performance Profiling Summary -", Sys.time()),
    paste("Environment:", Sys.info()[["sysname"]], R.version.string),
    "",
    "Test Results:"
  ), summary_file)
  
  for (test_name in names(results$profiling)) {
    test <- results$profiling[[test_name]]
    writeLines(c(
      paste("  ", test_name, ":"),
      paste("    Time (median):", sprintf("%.1f ms", test$time_stats$median_ms)),
      paste("    Memory (peak):", sprintf("%.1f MB", test$memory_stats$peak_mb)),
      paste("    GC count:", test$gc_stats$median_count),
      ""
    ), summary_file, append = TRUE)
  }
  
  cat("Comprehensive profiling completed.\n")
  cat("Results saved to:", output_file, "\n")
  cat("Summary saved to:", summary_file, "\n")
  
  return(results)
}

# Run if called directly
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  output_dir <- if (length(args) > 0) args[1] else "perf/reports/weekly"
  
  run_performance_profiling(output_dir)
}
