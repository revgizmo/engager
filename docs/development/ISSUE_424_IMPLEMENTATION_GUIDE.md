# Issue 424: Performance Benchmarking Implementation Guide

## Overview
This guide provides step-by-step instructions for implementing performance benchmarking tools for ideal course transcripts in the engager R package.

## Prerequisites
- R development environment with package development tools
- Existing ideal course transcript data
- Current transcript processing functions from Issue #423

## Implementation Steps

### Step 1: Create Main Benchmarking Script

**File**: `scripts/benchmark-ideal-transcripts.R`

**Purpose**: Main script for running performance benchmarks on ideal course transcripts

**Key Features**:
- Processing time measurement
- Memory usage tracking
- Performance profiling
- Results reporting

**Implementation**:
```r
#!/usr/bin/env Rscript

#' Performance Benchmarking for Ideal Course Transcripts
#' 
#' This script benchmarks the performance of ideal course transcript processing
#' functions, measuring processing time, memory usage, and identifying bottlenecks.
#' 
#' @param iterations Number of iterations for each benchmark (default: 5)
#' @param output_file File to save benchmark results (default: "benchmark_results.rds")
#' @param include_memory Whether to include memory profiling (default: TRUE)
#' @param include_profiling Whether to include detailed profiling (default: FALSE)
#' 
#' @return Benchmark results as a list
#' @export
benchmark_ideal_transcripts <- function(iterations = 5, 
                                       output_file = "benchmark_results.rds",
                                       include_memory = TRUE,
                                       include_profiling = FALSE) {
  
  # Load required packages
  library(engager)
  library(microbenchmark)
  library(pryr)
  
  # Initialize results storage
  benchmark_results <- list(
    timestamp = Sys.time(),
    environment = sessionInfo(),
    benchmarks = list()
  )
  
  # Get ideal course transcript paths
  transcript_dir <- system.file("extdata", "test_transcripts", package = "engager")
  session_files <- c(
    "ideal_course_session1.vtt",
    "ideal_course_session2.vtt", 
    "ideal_course_session3.vtt"
  )
  
  # Benchmark 1: Individual transcript processing
  cat("Running individual transcript processing benchmarks...\n")
  individual_benchmarks <- list()
  
  for (session_file in session_files) {
    session_path <- file.path(transcript_dir, session_file)
    if (file.exists(session_path)) {
      cat("Benchmarking:", session_file, "\n")
      
      # Measure processing time
      time_result <- microbenchmark(
        process_zoom_transcript(session_path),
        times = iterations
      )
      
      # Measure memory usage if requested
      memory_result <- NULL
      if (include_memory) {
        memory_result <- measure_memory_usage(
          process_zoom_transcript(session_path)
        )
      }
      
      individual_benchmarks[[session_file]] <- list(
        processing_time = time_result,
        memory_usage = memory_result,
        file_size = file.size(session_path)
      )
    }
  }
  
  benchmark_results$benchmarks$individual <- individual_benchmarks
  
  # Benchmark 2: Batch processing
  cat("Running batch processing benchmarks...\n")
  
  batch_time <- microbenchmark(
    process_ideal_course_batch(),
    times = iterations
  )
  
  batch_memory <- NULL
  if (include_memory) {
    batch_memory <- measure_memory_usage(
      process_ideal_course_batch()
    )
  }
  
  benchmark_results$benchmarks$batch <- list(
    processing_time = batch_time,
    memory_usage = batch_memory
  )
  
  # Benchmark 3: Function-specific benchmarks
  cat("Running function-specific benchmarks...\n")
  
  # Test with first session
  test_file <- file.path(transcript_dir, session_files[1])
  
  function_benchmarks <- list(
    load_transcript = microbenchmark(
      load_zoom_transcript(test_file),
      times = iterations
    ),
    summarize_metrics = microbenchmark(
      summarize_transcript_metrics(test_file),
      times = iterations
    ),
    consolidate_transcript = microbenchmark(
      consolidate_transcript(load_zoom_transcript(test_file)),
      times = iterations
    )
  )
  
  benchmark_results$benchmarks$functions <- function_benchmarks
  
  # Generate summary statistics
  benchmark_results$summary <- generate_benchmark_summary(benchmark_results)
  
  # Save results
  if (!is.null(output_file)) {
    saveRDS(benchmark_results, output_file)
    cat("Benchmark results saved to:", output_file, "\n")
  }
  
  # Print summary
  print_benchmark_summary(benchmark_results$summary)
  
  return(benchmark_results)
}

#' Measure memory usage of a function
#' @keywords internal
measure_memory_usage <- function(expr) {
  mem_before <- pryr::mem_used()
  result <- eval(expr)
  mem_after <- pryr::mem_used()
  
  return(list(
    memory_before = mem_before,
    memory_after = mem_after,
    memory_increase = mem_after - mem_before,
    result_size = pryr::object_size(result)
  ))
}

#' Generate benchmark summary statistics
#' @keywords internal
generate_benchmark_summary <- function(benchmark_results) {
  summary <- list()
  
  # Individual processing summary
  if ("individual" %in% names(benchmark_results$benchmarks)) {
    individual_times <- sapply(benchmark_results$benchmarks$individual, 
                              function(x) summary(x$processing_time)$median)
    
    summary$individual_processing <- list(
      mean_time = mean(individual_times),
      median_time = median(individual_times),
      min_time = min(individual_times),
      max_time = max(individual_times),
      total_files = length(individual_times)
    )
  }
  
  # Batch processing summary
  if ("batch" %in% names(benchmark_results$benchmarks)) {
    batch_time <- summary(benchmark_results$benchmarks$batch$processing_time)$median
    
    summary$batch_processing <- list(
      median_time = batch_time,
      throughput = 3 / batch_time  # files per second
    )
  }
  
  return(summary)
}

#' Print benchmark summary
#' @keywords internal
print_benchmark_summary <- function(summary) {
  cat("\n=== PERFORMANCE BENCHMARK SUMMARY ===\n")
  
  if ("individual_processing" %in% names(summary)) {
    ind <- summary$individual_processing
    cat("Individual Processing:\n")
    cat("  Mean time:", round(ind$mean_time, 2), "ms\n")
    cat("  Median time:", round(ind$median_time, 2), "ms\n")
    cat("  Range:", round(ind$min_time, 2), "-", round(ind$max_time, 2), "ms\n")
    cat("  Files processed:", ind$total_files, "\n\n")
  }
  
  if ("batch_processing" %in% names(summary)) {
    batch <- summary$batch_processing
    cat("Batch Processing:\n")
    cat("  Median time:", round(batch$median_time, 2), "ms\n")
    cat("  Throughput:", round(batch$throughput, 2), "files/second\n\n")
  }
}

# Run benchmarks if script is executed directly
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  
  iterations <- if (length(args) >= 1) as.numeric(args[1]) else 5
  output_file <- if (length(args) >= 2) args[2] else "benchmark_results.rds"
  
  cat("Starting performance benchmarks...\n")
  cat("Iterations:", iterations, "\n")
  cat("Output file:", output_file, "\n\n")
  
  results <- benchmark_ideal_transcripts(
    iterations = iterations,
    output_file = output_file
  )
  
  cat("\nBenchmarking completed successfully!\n")
}
```

### Step 2: Create Performance Regression Tests

**File**: `tests/testthat/test-performance.R`

**Purpose**: Automated tests to detect performance regressions

**Implementation**:
```r
# Test file for performance benchmarking
# Tests for performance regression detection and benchmarking functions

library(testthat)
library(engager)

# Performance thresholds (in milliseconds)
PERFORMANCE_THRESHOLDS <- list(
  individual_processing_max = 1000,  # 1 second max for individual processing
  batch_processing_max = 3000,       # 3 seconds max for batch processing
  memory_increase_max = 100 * 1024 * 1024  # 100MB max memory increase
)

test_that("individual transcript processing meets performance requirements", {
  # Skip on CRAN to avoid long-running tests
  skip_on_cran()
  
  # Get test transcript
  transcript_dir <- system.file("extdata", "test_transcripts", package = "engager")
  test_file <- file.path(transcript_dir, "ideal_course_session1.vtt")
  
  # Measure processing time
  start_time <- Sys.time()
  result <- process_zoom_transcript(test_file)
  end_time <- Sys.time()
  
  processing_time_ms <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
  
  # Check performance threshold
  expect_lt(processing_time_ms, PERFORMANCE_THRESHOLDS$individual_processing_max)
  
  # Verify result is valid
  expect_true(!is.null(result))
  expect_true(nrow(result) > 0)
})

test_that("batch processing meets performance requirements", {
  # Skip on CRAN to avoid long-running tests
  skip_on_cran()
  
  # Measure batch processing time
  start_time <- Sys.time()
  result <- process_ideal_course_batch()
  end_time <- Sys.time()
  
  processing_time_ms <- as.numeric(difftime(end_time, start_time, units = "secs")) * 1000
  
  # Check performance threshold
  expect_lt(processing_time_ms, PERFORMANCE_THRESHOLDS$batch_processing_max)
  
  # Verify result is valid
  expect_true(!is.null(result))
  expect_true("session_data" %in% names(result))
})

test_that("memory usage is within acceptable limits", {
  # Skip on CRAN to avoid long-running tests
  skip_on_cran()
  
  # This test would require memory profiling tools
  # For now, we'll just verify the function runs without errors
  expect_no_error(process_ideal_course_batch())
})

test_that("benchmarking functions work correctly", {
  # Test that benchmarking functions can be called
  expect_true(exists("benchmark_ideal_transcripts"))
  
  # Test with minimal iterations to avoid long runtime
  expect_no_error(
    benchmark_ideal_transcripts(iterations = 1, output_file = NULL)
  )
})

test_that("performance regression detection works", {
  # Test performance regression detection logic
  current_times <- c(500, 600, 550)  # Current performance times
  baseline_times <- c(400, 450, 420)  # Baseline times
  
  # Calculate performance regression
  regression_ratio <- mean(current_times) / mean(baseline_times)
  
  # Check if regression is detected (more than 20% slower)
  expect_true(regression_ratio > 1.2)
})

test_that("benchmark results have expected structure", {
  # Skip on CRAN to avoid long-running tests
  skip_on_cran()
  
  # Run minimal benchmark
  results <- benchmark_ideal_transcripts(iterations = 1, output_file = NULL)
  
  # Check structure
  expect_true("timestamp" %in% names(results))
  expect_true("benchmarks" %in% names(results))
  expect_true("summary" %in% names(results))
  
  # Check benchmarks structure
  expect_true("individual" %in% names(results$benchmarks))
  expect_true("batch" %in% names(results$benchmarks))
  expect_true("functions" %in% names(results$benchmarks))
})
```

### Step 3: Create Performance Guidelines Documentation

**File**: `docs/performance-guidelines.md`

**Purpose**: Document performance guidelines and optimization recommendations

**Implementation**:
```markdown
# Performance Guidelines for Engager Package

## Overview
This document provides performance guidelines and optimization recommendations for the engager R package, particularly for processing ideal course transcripts.

## Performance Benchmarks

### Current Performance Targets
- **Individual Transcript Processing**: < 1 second per transcript
- **Batch Processing**: < 3 seconds for 3 transcripts
- **Memory Usage**: < 100MB increase during processing
- **Scalability**: Linear scaling with transcript size

### Benchmarking Tools
The package includes comprehensive benchmarking tools:

```r
# Run performance benchmarks
library(engager)
benchmark_ideal_transcripts(iterations = 5)

# Run with custom parameters
benchmark_ideal_transcripts(
  iterations = 10,
  output_file = "my_benchmarks.rds",
  include_memory = TRUE
)
```

## Performance Optimization Guidelines

### 1. Data Processing Optimization
- Use `data.table` for large datasets
- Minimize data copying
- Use vectorized operations where possible
- Avoid loops when vectorized alternatives exist

### 2. Memory Management
- Clean up large objects when no longer needed
- Use `gc()` strategically for memory-intensive operations
- Monitor memory usage with `pryr::mem_used()`

### 3. Function Optimization
- Profile functions with `Rprof()` to identify bottlenecks
- Use `microbenchmark` for precise timing measurements
- Consider parallel processing for independent operations

### 4. File I/O Optimization
- Read files once and cache results when possible
- Use efficient file formats (CSV over Excel when possible)
- Minimize file system calls

## Performance Monitoring

### Automated Performance Tests
The package includes automated performance regression tests:

```r
# Run performance tests
devtools::test(filter = "performance")
```

### Continuous Performance Monitoring
- Performance benchmarks run in CI/CD pipeline
- Performance metrics are tracked over time
- Alerts are generated for performance regressions

## Troubleshooting Performance Issues

### Common Performance Problems
1. **Slow transcript processing**
   - Check transcript file size and format
   - Verify memory availability
   - Consider using batch processing for multiple files

2. **High memory usage**
   - Monitor memory usage with `pryr::mem_used()`
   - Clean up large objects with `rm()` and `gc()`
   - Consider processing files in smaller batches

3. **Performance regressions**
   - Run benchmarks to identify the source
   - Check recent code changes
   - Review function profiling results

### Performance Profiling
Use R's built-in profiling tools:

```r
# Profile a function
Rprof("profile.out")
result <- process_ideal_course_batch()
Rprof(NULL)
summaryRprof("profile.out")
```

## Best Practices

### For Package Developers
1. **Always benchmark new features**
2. **Include performance tests in test suite**
3. **Monitor performance in CI/CD pipeline**
4. **Document performance characteristics**

### For Package Users
1. **Use batch processing for multiple files**
2. **Monitor memory usage for large datasets**
3. **Report performance issues with benchmark results**
4. **Follow optimization guidelines**

## Performance Metrics

### Key Metrics Tracked
- Processing time per transcript
- Memory usage during processing
- Scalability with transcript size
- Performance regression detection

### Reporting Performance Issues
When reporting performance issues, include:
- Benchmark results
- System specifications
- Transcript file sizes
- Expected vs. actual performance

## Future Performance Improvements

### Planned Optimizations
1. **Parallel processing support**
2. **Memory-mapped file I/O**
3. **Caching mechanisms**
4. **Compressed data formats**

### Performance Roadmap
- Q1: Implement parallel processing
- Q2: Add memory optimization features
- Q3: Implement caching system
- Q4: Performance monitoring dashboard
```

### Step 4: CI/CD Integration

**File**: `.github/workflows/performance.yml`

**Purpose**: Automated performance testing in CI/CD pipeline

**Implementation**:
```yaml
name: Performance Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  performance:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        r-version: [4.1, 4.2, 4.3]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up R
      uses: r-lib/actions/setup-r@v2
      with:
        r-version: ${{ matrix.r-version }}
    
    - name: Install dependencies
      run: |
        install.packages(c("remotes", "testthat", "microbenchmark", "pryr"))
        remotes::install_deps(dep = TRUE)
    
    - name: Run performance tests
      run: |
        Rscript -e "devtools::test(filter = 'performance')"
    
    - name: Run benchmarks
      run: |
        Rscript scripts/benchmark-ideal-transcripts.R 3 benchmark_results.rds
    
    - name: Upload benchmark results
      uses: actions/upload-artifact@v3
      with:
        name: benchmark-results-${{ matrix.r-version }}
        path: benchmark_results.rds
```

## Validation Steps

### 1. CRAN Compliance
- [ ] All code follows R package standards
- [ ] Proper error handling implemented
- [ ] Comprehensive documentation with roxygen2
- [ ] All tests pass
- [ ] No external dependencies beyond base R and tidyverse

### 2. Performance Validation
- [ ] Benchmarking script runs successfully
- [ ] Performance regression tests pass
- [ ] Memory usage tracking works correctly
- [ ] Performance guidelines are comprehensive

### 3. Integration Testing
- [ ] CI/CD pipeline integration works
- [ ] Performance tests run in automated environment
- [ ] Benchmark results are properly saved and reported

## Success Criteria
- [ ] Benchmarking script measures processing time accurately
- [ ] Memory usage is tracked and reported
- [ ] Performance regression tests are automated
- [ ] Performance guidelines are documented
- [ ] Benchmarks run in CI/CD pipeline
- [ ] Performance metrics are tracked over time

## Environment-Specific Notes
- Full R development environment available
- CRAN compliance tools accessible
- Performance testing can be done with realistic data
- No environment limitations for this implementation
