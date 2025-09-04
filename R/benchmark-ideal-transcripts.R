#' Performance Benchmarking for Ideal Course Transcripts
#'
#' This function benchmarks the performance of ideal course transcript processing
#' functions, measuring processing time, memory usage, and identifying bottlenecks.
#'
#' @param iterations Number of iterations for each benchmark (default: 5)
#' @param output_file File to save benchmark results (default: "benchmark_results.rds")
#' @param include_memory Whether to include memory profiling (default: TRUE)
#' @param include_profiling Whether to include detailed profiling (default: FALSE)
#'
#' @return Benchmark results as a list
#' @importFrom utils sessionInfo
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
benchmark_ideal_transcripts <- function(iterations = 5,
                                        output_file = "benchmark_results.rds",
                                        include_memory = TRUE,
                                        include_profiling = FALSE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'benchmark_ideal_transcripts' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Check if microbenchmark is available
  if (!requireNamespace("microbenchmark", quietly = TRUE)) {
    stop("microbenchmark package is required for benchmarking")
  }

  # Check if pryr is available for memory profiling
  if (include_memory) {
    if (!requireNamespace("pryr", quietly = TRUE)) {
      warning("pryr package not available, memory profiling disabled")
      include_memory <- FALSE
    }
  }

  # Initialize results storage
  benchmark_results <- list(
    timestamp = Sys.time(),
    environment = utils::sessionInfo(),
    benchmarks = list()
  )

  # Get ideal course transcript paths
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  session_files <- c(
    "ideal_course_session1.vtt",
    "ideal_course_session2.vtt",
    "ideal_course_session3.vtt"
  )

  # Validate that transcript files exist
  missing_files <- session_files[!file.exists(file.path(transcript_dir, session_files))]
  if (length(missing_files) > 0) {
    warning("Missing transcript files: ", paste(missing_files, collapse = ", "))
  }

  # Benchmark 1: Individual transcript processing
  individual_benchmarks <- list()

  for (session_file in session_files) {
    session_path <- file.path(transcript_dir, session_file)
    if (file.exists(session_path)) {
      # Measure processing time
      time_result <- microbenchmark::microbenchmark(
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

  # nolint: object_usage_linter
  batch_time <- microbenchmark::microbenchmark(
    process_ideal_course_batch(),
    times = iterations
  )

  batch_memory <- NULL
  if (include_memory) {
    # nolint: object_usage_linter
    batch_memory <- measure_memory_usage(
      process_ideal_course_batch()
    )
  }

  benchmark_results$benchmarks$batch <- list(
    processing_time = batch_time,
    memory_usage = batch_memory
  )

  # Benchmark 3: Function-specific benchmarks

  # Test with first session
  test_file <- file.path(transcript_dir, session_files[1])

  function_benchmarks <- list(
    load_transcript = microbenchmark::microbenchmark(
      load_zoom_transcript(test_file),
      times = iterations
    ),
    summarize_metrics = microbenchmark::microbenchmark(
      summarize_transcript_metrics(test_file),
      times = iterations
    ),
    consolidate_transcript = microbenchmark::microbenchmark(
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
  }

  # Print summary
  print_benchmark_summary(benchmark_results$summary)

  benchmark_results
}

#' Measure memory usage of a function
#' @keywords internal
measure_memory_usage <- function(expr) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'measure_memory_usage' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  if (!requireNamespace("pryr", quietly = TRUE)) {
    return(NULL)
  }

  mem_before <- pryr::mem_used()
  result <- eval(expr)
  mem_after <- pryr::mem_used()

  list(
    memory_before = mem_before,
    memory_after = mem_after,
    memory_increase = mem_after - mem_before,
    result_size = pryr::object_size(result)
  )
}

#' Generate benchmark summary statistics
#' @keywords internal

generate_benchmark_summary <- function(benchmark_results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'generate_benchmark_summary' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  summary <- list()

  # Individual processing summary
  if ("individual" %in% names(benchmark_results$benchmarks)) {
    individual_times <- sapply(
      benchmark_results$benchmarks$individual,
      function(x) summary(x$processing_time)$median
    )

    summary$individual_processing <- list(
      mean_time = mean(individual_times),
      median_time = stats::median(individual_times),
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
      throughput = 3 / batch_time # files per second
    )
  }

  summary
}

#' Print benchmark summary
#' @keywords internal
print_benchmark_summary <- function(summary) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'print_benchmark_summary' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Silent function - no diagnostic output
  invisible(summary)
}
