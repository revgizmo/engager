#' Validate Ideal Course Transcript Structure
#'
#' Validates the structure and format of ideal course transcripts to ensure they
#' meet expected standards for VTT format, file structure, and required fields.
#'
#' @param transcript_data Data frame containing transcript data (optional)
#' @param file_path Path to transcript file (optional)
#' @param strict_mode Logical. Whether to use strict validation rules. Default: TRUE
#' @return Validation results list with status, issues, and recommendations
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' # Validate from file path
#' results <- validate_ideal_transcript_structure(
#'   file_path = "path/to/transcript.vtt"
#' )
#'
#' # Validate from data frame
#' transcript_data <- load_zoom_transcript("path/to/transcript.vtt")
#' results <- validate_ideal_transcript_structure(transcript_data = transcript_data)
#' }
vldtdltrnscrptstrctr <- function(transcript_data = NULL,
                                                file_path = NULL,
                                                strict_mode = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_transcript_structure' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Initialize results
  results <- list(
    status = "PENDING",
    issues = list(),
    warnings = list(),
    recommendations = list(),
    validation_details = list()
  )

  # Validate inputs
  if (is.null(transcript_data) && is.null(file_path)) {
    stop("Either transcript_data or file_path must be provided")
  }

  # Load data if file path provided
  if (!is.null(file_path)) {
    if (!file.exists(file_path)) {
      results$status <- "FAIL"
      results$issues$file_not_found <- "Transcript file not found"
      return(results)
    }

    tryCatch(
      {
        transcript_data <- load_zoom_transcript(file_path)
      },
      error = function(e) {
        results$status <- "FAIL"
        results$issues$load_error <- paste("Failed to load transcript:", e$message)
      }
    )
  }

  if (is.null(transcript_data) || nrow(transcript_data) == 0) {
    results$status <- "FAIL"
    results$issues$empty_data <- "Transcript data is empty or invalid"
    return(results)
  }

  # Validate data structure
  structure_validation <- validate_transcript_structure(transcript_data, strict_mode)
  results$validation_details$structure <- structure_validation

  # Validate VTT format compliance
  vtt_validation <- validate_vtt_format(transcript_data, strict_mode)
  results$validation_details$vtt_format <- vtt_validation

  # Validate required fields
  fields_validation <- validate_required_fields(transcript_data, strict_mode)
  results$validation_details$required_fields <- fields_validation

  # Validate timestamp formatting
  timestamp_validation <- validate_timestamp_format(transcript_data, strict_mode)
  results$validation_details$timestamps <- timestamp_validation

  # Determine overall status
  all_issues <- c(
    results$issues,
    structure_validation$issues,
    vtt_validation$issues,
    fields_validation$issues,
    timestamp_validation$issues
  )

  all_warnings <- c(
    results$warnings,
    structure_validation$warnings,
    vtt_validation$warnings,
    fields_validation$warnings,
    timestamp_validation$warnings
  )

  results$issues <- all_issues
  results$warnings <- all_warnings

  # Set final status
  if (length(all_issues) > 0) {
    results$status <- "FAIL"
  } else if (length(all_warnings) > 0) {
    results$status <- "WARN"
  } else {
    results$status <- "PASS"
  }

  # Generate recommendations
  results$recommendations <- generate_structure_recommendations(results)

  return(results)
}

#' Validate Ideal Course Transcript Content Quality
#'
#' Validates the content quality of ideal course transcripts to ensure they
#' contain realistic dialogue patterns, appropriate content length, and
#' consistent speaker names.
#'
#' @param transcript_data Data frame containing transcript data
#' @param quality_threshold Numeric. Quality threshold (0-1). Default: 0.8
#' @param check_realism Logical. Whether to check for realistic content. Default: TRUE
#' @return Validation results list with quality metrics and issues
#' @export
#' @examples
#' \dontrun{
#' transcript_data <- load_zoom_transcript("path/to/transcript.vtt")
#' results <- validate_ideal_content_quality(transcript_data)
#' }
validate_ideal_content_quality <- function(transcript_data = NULL,
                                           quality_threshold = 0.8,
                                           check_realism = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_content_quality' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Initialize results
  results <- list(
    status = "PENDING",
    quality_score = 0,
    issues = list(),
    warnings = list(),
    quality_metrics = list(),
    validation_details = list(),
    recommendations = list()
  )

  # Validate input
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }
  if (nrow(transcript_data) == 0) {
    results$status <- "FAIL"
    results$issues$empty_data <- "Transcript data is empty or invalid"
    return(results)
  }

  # Calculate quality metrics
  quality_metrics <- calculate_content_quality_metrics(transcript_data)
  results$quality_metrics <- quality_metrics

  # Check dialogue length patterns
  dialogue_validation <- validate_dialogue_length(transcript_data)
  results$validation_details$dialogue_length <- dialogue_validation

  # Check speaker name consistency
  name_validation <- validate_speaker_consistency(transcript_data)
  results$validation_details$speaker_consistency <- name_validation

  # Check content diversity
  diversity_validation <- validate_content_diversity(transcript_data)
  results$validation_details$content_diversity <- diversity_validation

  # Check for realistic patterns if requested
  if (check_realism) {
    realism_validation <- validate_realistic_patterns(transcript_data)
    results$validation_details$realism <- realism_validation
  }

  # Calculate overall quality score
  quality_score <- calculate_overall_quality_score(results$validation_details)
  results$quality_score <- quality_score

  # Determine status based on quality score and validation results
  results$status <- determine_validation_status(results$validation_details)

  # Collect all issues and warnings efficiently
  all_issues <- list()
  all_warnings <- list()
  for (detail in results$validation_details) {
    all_issues <- c(all_issues, detail$issues)
    all_warnings <- c(all_warnings, detail$warnings)
  }

  results$issues <- all_issues
  results$warnings <- all_warnings

  # Generate recommendations
  results$recommendations <- generate_content_recommendations(results)

  return(results)
}

#' Validate Ideal Course Transcript Timing Consistency
#'
#' Validates the timing consistency of ideal course transcripts to ensure
#' timestamps are logical, chronological, and without overlaps.
#'
#' @param transcript_data Data frame containing transcript data
#' @param max_gap_seconds Numeric. Maximum allowed gap between entries. Default: 300
#' @param check_overlaps Logical. Whether to check for overlapping timestamps. Default: TRUE
#' @return Validation results list with timing analysis and issues
#' @export
#' @examples
#' \dontrun{
#' transcript_data <- load_zoom_transcript("path/to/transcript.vtt")
#' results <- validate_ideal_timing_consistency(transcript_data)
#' }
vldtdltmngcnsstncy <- function(transcript_data = NULL,
                                              max_gap_seconds = 300,
                                              check_overlaps = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_timing_consistency' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_timing_consistency' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Initialize results
  results <- list(
    status = "PENDING",
    issues = list(),
    warnings = list(),
    validation_details = list(),
    timing_analysis = list(),
    recommendations = list()
  )

  # Validate input
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }
  if (nrow(transcript_data) == 0) {
    results$status <- "FAIL"
    results$issues$empty_data <- "Transcript data is empty or invalid"
    return(results)
  }

  # Check for required timing columns
  if (!all(c("start", "end") %in% names(transcript_data))) {
    results$status <- "FAIL"
    results$issues$missing_timing_columns <- "Missing start/end timestamp columns"
    return(results)
  }

  # Validate chronological order
  chronological_validation <- validate_chronological_order(transcript_data)
  results$validation_details$chronological <- chronological_validation

  # Check for overlapping timestamps
  if (check_overlaps) {
    overlap_validation <- validate_no_overlaps(transcript_data)
    results$validation_details$overlaps <- overlap_validation
  }

  # Validate duration calculations
  duration_validation <- validate_duration_calculations(transcript_data)
  results$validation_details$duration <- duration_validation

  # Check for reasonable gaps
  gap_validation <- validate_reasonable_gaps(transcript_data, max_gap_seconds)
  results$validation_details$gaps <- gap_validation

  # Analyze timing patterns
  timing_analysis <- analyze_timing_patterns(transcript_data)
  results$timing_analysis <- timing_analysis

  # Determine overall status
  all_issues <- list()
  all_warnings <- list()
  for (detail in results$validation_details) {
    all_issues <- c(all_issues, detail$issues)
    all_warnings <- c(all_warnings, detail$warnings)
  }

  results$issues <- all_issues
  results$warnings <- all_warnings

  results$status <- determine_validation_status(results$validation_details)

  # Generate recommendations
  results$recommendations <- generate_timing_recommendations(results)

  return(results)
}

#' Validate Ideal Course Transcript Name Coverage
#'
#' Validates that ideal course transcripts include comprehensive name coverage
#' for all test scenarios, name variations, and edge cases.
#'
#' @param transcript_data Data frame containing transcript data
#' @param expected_names Character vector. Expected speaker names. Default: NULL
#' @param check_variations Logical. Whether to check for name variations. Default: TRUE
#' @param check_edge_cases Logical. Whether to check for edge case names. Default: TRUE
#' @return Validation results list with name coverage analysis
#' # # # # @export (REMOVED - deprecated function) (REMOVED - deprecated function) (REMOVED - deprecated function)
#' (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' transcript_data <- load_zoom_transcript("path/to/transcript.vtt")
#' results <- validate_ideal_name_coverage(transcript_data)
#'
#' # With expected names
#' expected_names <- c("Professor Ed", "Tom Miller", "Samantha Smith")
#' results <- validate_ideal_name_coverage(transcript_data, expected_names)
#' }
validate_ideal_name_coverage <- function(transcript_data = NULL,
                                         expected_names = NULL,
                                         check_variations = TRUE,
                                         check_edge_cases = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_name_coverage' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_name_coverage' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Initialize results
  results <- list(
    status = "PENDING",
    issues = list(),
    warnings = list(),
    validation_details = list(),
    coverage_analysis = list(),
    recommendations = list()
  )

  # Validate input
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }
  if (nrow(transcript_data) == 0) {
    results$status <- "FAIL"
    results$issues$empty_data <- "Transcript data is empty or invalid"
    return(results)
  }

  # Check for name column
  if (!"name" %in% names(transcript_data)) {
    results$status <- "FAIL"
    results$issues$missing_name_column <- "Missing name column"
    return(results)
  }

  # Analyze name coverage
  coverage_analysis <- analyze_name_coverage(transcript_data)
  results$coverage_analysis <- coverage_analysis

  # Check expected names if provided
  if (!is.null(expected_names)) {
    expected_validation <- validate_expected_names(transcript_data, expected_names)
    results$validation_details$expected_names <- expected_validation
  }

  # Check name variations
  if (check_variations) {
    variation_validation <- validate_name_variations(transcript_data)
    results$validation_details$name_variations <- variation_validation
  }

  # Check edge cases
  if (check_edge_cases) {
    edge_case_validation <- validate_name_edge_cases(transcript_data)
    results$validation_details$edge_cases <- edge_case_validation
  }

  # Check scenario completeness
  scenario_validation <- validate_scenario_completeness(transcript_data)
  results$validation_details$scenarios <- scenario_validation

  # Determine overall status
  all_issues <- list()
  all_warnings <- list()

  # Collect all issues and warnings efficiently
  for (detail in results$validation_details) {
    all_issues <- c(all_issues, detail$issues)
    all_warnings <- c(all_warnings, detail$warnings)
  }

  results$issues <- all_issues
  results$warnings <- all_warnings

  results$status <- determine_validation_status(results$validation_details)

  # Generate recommendations
  results$recommendations <- generate_name_coverage_recommendations(results)

  return(results)
}

#' Comprehensive Validation for Ideal Course Transcripts
#'
#' Performs comprehensive validation of ideal course transcripts including
#' structure, content quality, timing consistency, and name coverage.
#'
#' @param transcript_data Data frame containing transcript data (optional)
#' @param file_path Path to transcript file (optional)
#' @param validation_options List. Custom validation options. Default: NULL
#' @param detailed_report Logical. Whether to generate detailed report. Default: TRUE
#' @return Comprehensive validation results
#' # # # # @export (REMOVED - deprecated function) (REMOVED - deprecated function) (REMOVED - deprecated function)
#' (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' # Validate from file
#' results <- validate_ideal_transcript_comprehensive(
#'   file_path = "path/to/transcript.vtt"
#' )
#'
#' # Validate from data with custom options
#' transcript_data <- load_zoom_transcript("path/to/transcript.vtt")
#' options <- list(quality_threshold = 0.9, strict_mode = FALSE)
#' results <- validate_ideal_transcript_comprehensive(
#'   transcript_data = transcript_data,
#'   validation_options = options
#' )
#' }
vldtdltrnscrptcmprhnsv <- function(transcript_data = NULL,
                                                    file_path = NULL,
                                                    validation_options = NULL,
                                                    detailed_report = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_transcript_comprehensive' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_ideal_transcript_comprehensive' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Set default options
  if (is.null(validation_options)) {
    validation_options <- list(
      strict_mode = TRUE,
      quality_threshold = 0.8,
      check_realism = TRUE,
      max_gap_seconds = 300,
      check_overlaps = TRUE,
      check_variations = TRUE,
      check_edge_cases = TRUE
    )
  }

  # Initialize comprehensive results
  results <- list(
    timestamp = Sys.time(),
    overall_status = "PENDING",
    validation_results = list(),
    summary = list(),
    recommendations = list(),
    detailed_report = NULL
  )

  # Load data if file path provided
  if (!is.null(file_path)) {
    if (!file.exists(file_path)) {
      results$overall_status <- "FAIL"
      results$validation_results$file_error <- "File not found"
      return(results)
    }

    tryCatch(
      {
        transcript_data <- load_zoom_transcript(file_path)
      },
      error = function(e) {
        results$overall_status <- "FAIL"
        results$validation_results$load_error <- paste("Failed to load transcript:", e$message)
      }
    )
  }

  if (is.null(transcript_data) || nrow(transcript_data) == 0) {
    results$overall_status <- "FAIL"
    results$validation_results$data_error <- "Transcript data is empty or invalid"
    return(results)
  }

  # Run all validation checks
  results$validation_results$structure <- validate_ideal_transcript_structure(
    transcript_data = transcript_data,
    strict_mode = validation_options$strict_mode
  )

  results$validation_results$content_quality <- validate_ideal_content_quality(
    transcript_data = transcript_data,
    quality_threshold = validation_options$quality_threshold,
    check_realism = validation_options$check_realism
  )

  results$validation_results$timing_consistency <- validate_ideal_timing_consistency(
    transcript_data = transcript_data,
    max_gap_seconds = validation_options$max_gap_seconds,
    check_overlaps = validation_options$check_overlaps
  )

  results$validation_results$name_coverage <- validate_ideal_name_coverage(
    transcript_data = transcript_data,
    check_variations = validation_options$check_variations,
    check_edge_cases = validation_options$check_edge_cases
  )

  # Calculate overall status
  all_statuses <- sapply(results$validation_results, function(x) x$status)

  if (all(all_statuses == "PASS")) {
    results$overall_status <- "PASS"
  } else if (any(all_statuses == "FAIL")) {
    results$overall_status <- "FAIL"
  } else {
    results$overall_status <- "WARN"
  }

  # Generate summary
  results$summary <- generate_comprehensive_summary(results)

  # Generate recommendations
  results$recommendations <- generate_comprehensive_recommendations(results)

  # Generate detailed report if requested
  if (detailed_report) {
    results$detailed_report <- generate_detailed_validation_report(results)
  }

  return(results)
}

# Helper functions for structure validation

#' Validate transcript structure
#' @keywords internal
validate_transcript_structure <- function(transcript_data, strict_mode) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_transcript_structure' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  # Check if it's a data frame
  if (!is.data.frame(transcript_data)) {
    results$status <- "FAIL"
    results$issues$not_dataframe <- "Transcript data is not a data frame"
    return(results)
  }

  # Check minimum required columns
  required_columns <- c("name", "comment", "start", "end")
  missing_columns <- setdiff(required_columns, names(transcript_data))

  if (length(missing_columns) > 0) {
    results$status <- "FAIL"
    results$issues$missing_columns <- paste(
      "Missing required columns:",
      paste(missing_columns, collapse = ", ")
    )
  }

  # Check for empty data
  if (nrow(transcript_data) == 0) {
    results$status <- "FAIL"
    results$issues$empty_data <- "Transcript data has no rows"
  }

  # Check for reasonable number of rows
  if (nrow(transcript_data) < 5) {
    results$warnings$few_rows <- "Transcript has very few entries (< 5)"
  }

  results
}

#' Validate VTT format compliance
#' @keywords internal
validate_vtt_format <- function(transcript_data, strict_mode) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_vtt_format' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  # Check for WEBVTT-like structure
  # This is a basic check - actual VTT parsing is done by load_zoom_transcript

  # Check that timestamps are in expected format
  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    # Check if timestamps are numeric (seconds) or character (HH:MM:SS.mmm)
    start_times <- transcript_data$start
    end_times <- transcript_data$end

    # Basic timestamp validation
    if (is.numeric(start_times) && is.numeric(end_times)) {
      # Check for reasonable time ranges
      if (any(start_times < 0) || any(end_times < 0)) {
        results$issues$negative_timestamps <- "Found negative timestamps"
      }

      if (any(end_times <= start_times)) {
        results$issues$invalid_duration <- "Found entries where end time <= start time"
      }
    }
  }

  results
}

#' Validate required fields
#' @keywords internal
validate_required_fields <- function(transcript_data, strict_mode) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_required_fields' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  # Check for non-empty names
  if ("name" %in% names(transcript_data)) {
    empty_names <- sum(is.na(transcript_data$name) | transcript_data$name == "")
    if (empty_names > 0) {
      results$issues$empty_names <- paste("Found", empty_names, "entries with empty names")
    }
  }

  # Check for non-empty comments
  if ("comment" %in% names(transcript_data)) {
    empty_comments <- sum(is.na(transcript_data$comment) | transcript_data$comment == "")
    if (empty_comments > 0) {
      results$warnings$empty_comments <- paste("Found", empty_comments, "entries with empty comments")
    }
  }

  results
}

#' Validate timestamp format
#' @keywords internal
validate_timestamp_format <- function(transcript_data, strict_mode) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_timestamp_format' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    start_times <- transcript_data$start
    end_times <- transcript_data$end

    # Check for NA timestamps
    na_starts <- sum(is.na(start_times))
    na_ends <- sum(is.na(end_times))

    if (na_starts > 0 || na_ends > 0) {
      results$issues$na_timestamps <- paste("Found", na_starts, "NA start times and", na_ends, "NA end times")
    }

    # Check for reasonable time ranges
    if (is.numeric(start_times) && is.numeric(end_times)) {
      max_duration <- max(end_times - start_times, na.rm = TRUE)
      if (max_duration > 3600) { # More than 1 hour
        results$warnings$long_duration <- paste("Found entry with duration > 1 hour:", max_duration, "seconds")
      }
    }
  }

  results
}

# Helper functions for validation status determination

#' Determine validation status from issues and warnings
#' @keywords internal
determine_validation_status <- function(validation_details) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'determine_validation_status' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  has_issues <- any(sapply(validation_details, function(x) length(x$issues) > 0))
  has_warnings <- any(sapply(validation_details, function(x) length(x$warnings) > 0))

  if (has_issues) {
    "FAIL"
  } else if (has_warnings) {
    "WARN"
  } else {
    "PASS"
  }
}

# Helper functions for content quality validation

#' Calculate content quality metrics
#' @keywords internal
clcltcntntqltymtrcs <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'calculate_content_quality_metrics' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  metrics <- list()

  # Basic metrics
  metrics$total_entries <- nrow(transcript_data)
  metrics$unique_speakers <- length(unique(transcript_data$name))

  # Comment length metrics
  if ("comment" %in% names(transcript_data)) {
    comment_lengths <- nchar(transcript_data$comment)
    metrics$avg_comment_length <- mean(comment_lengths, na.rm = TRUE)
    metrics$min_comment_length <- min(comment_lengths, na.rm = TRUE)
    metrics$max_comment_length <- max(comment_lengths, na.rm = TRUE)
  }

  # Word count metrics
  if ("wordcount" %in% names(transcript_data)) {
    metrics$avg_words_per_comment <- mean(transcript_data$wordcount, na.rm = TRUE)
    metrics$total_words <- sum(transcript_data$wordcount, na.rm = TRUE)
  }

  metrics
}

#' Validate dialogue length
#' @keywords internal
validate_dialogue_length <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_dialogue_length' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("comment" %in% names(transcript_data)) {
    comment_lengths <- nchar(transcript_data$comment)

    # Check for very short comments
    very_short <- sum(comment_lengths <= 2, na.rm = TRUE)
    if (very_short > 0) {
      results$warnings$very_short_comments <- paste("Found", very_short, "comments with <= 2 characters")
    }

    # Check for very long comments
    very_long <- sum(comment_lengths > 500, na.rm = TRUE)
    if (very_long > 0) {
      results$warnings$very_long_comments <- paste("Found", very_long, "comments with > 500 characters")
    }
  }

  results
}

#' Validate speaker consistency
#' @keywords internal
validate_speaker_consistency <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_speaker_consistency' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("name" %in% names(transcript_data)) {
    unique_names <- unique(transcript_data$name)

    # Check for consistent name formats
    # This is a basic check - more sophisticated name validation would be needed
    name_lengths <- nchar(unique_names)

    # Check for very short names
    very_short_names <- sum(name_lengths < 2, na.rm = TRUE)
    if (very_short_names > 0) {
      results$warnings$very_short_names <- paste("Found", very_short_names, "names with < 2 characters")
    }

    # Check for very long names
    very_long_names <- sum(name_lengths > 50, na.rm = TRUE)
    if (very_long_names > 0) {
      results$warnings$very_long_names <- paste("Found", very_long_names, "names with > 50 characters")
    }
  }

  results
}

#' Validate content diversity
#' @keywords internal
validate_content_diversity <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_content_diversity' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("comment" %in% names(transcript_data)) {
    unique_comments <- unique(transcript_data$comment)
    total_comments <- nrow(transcript_data)

    # Calculate diversity ratio
    if (total_comments > 0) {
      diversity_ratio <- length(unique_comments) / total_comments

      if (diversity_ratio < 0.8) {
        results$warnings$low_diversity <- paste(
          "Low content diversity:",
          round(diversity_ratio, 2),
          "(many duplicate comments)"
        )
      }
    }
  }

  results
}

#' Validate realistic patterns
#' @keywords internal
validate_realistic_patterns <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_realistic_patterns' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  # Check for realistic academic dialogue patterns
  if ("comment" %in% names(transcript_data)) {
    comments <- tolower(transcript_data$comment)

    # Check for common academic words
    academic_words <- c(
      "discuss", "question", "answer", "explain", "understand",
      "analysis", "research", "study", "learn", "teach"
    )

    academic_word_count <- sum(sapply(academic_words, function(word) {
      sum(grepl(word, comments, fixed = TRUE))
    }))

    if (academic_word_count == 0) {
      results$warnings$no_academic_content <- "No academic dialogue patterns detected"
    }
  }

  results
}

#' Calculate overall quality score
#' @keywords internal
clcltvrllqltyscr <- function(validation_details) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'calculate_overall_quality_score' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Simple scoring based on validation results
  total_checks <- length(validation_details)
  passed_checks <- sum(sapply(validation_details, function(x) {
    if (is.list(x) && "status" %in% names(x)) {
      x$status == "PASS"
    } else {
      FALSE
    }
  }))

  passed_checks / total_checks
}

# Helper functions for timing validation

#' Validate chronological order
#' @keywords internal
validate_chronological_order <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_chronological_order' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    start_times <- as.numeric(transcript_data$start)

    # Check for chronological order
    if (length(start_times) > 1) {
      time_diffs <- diff(start_times)
      non_chronological <- sum(time_diffs < 0, na.rm = TRUE)

      if (non_chronological > 0) {
        results$status <- "FAIL"
        results$issues$non_chronological <- paste("Found", non_chronological, "non-chronological entries")
      }
    }
  }

  results
}

#' Validate no overlaps
#' @keywords internal
validate_no_overlaps <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_no_overlaps' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    start_times <- as.numeric(transcript_data$start)
    end_times <- as.numeric(transcript_data$end)

    # Check for overlaps (end time of one entry > start time of next entry)
    if (length(start_times) > 1) {
      overlaps <- 0
      for (i in 1:(length(start_times) - 1)) {
        if (end_times[i] > start_times[i + 1]) {
          overlaps <- overlaps + 1
        }
      }

      if (overlaps > 0) {
        results$status <- "FAIL"
        results$issues$overlaps <- paste("Found", overlaps, "overlapping timestamp entries")
      }
    }
  }

  results
}

#' Validate duration calculations
#' @keywords internal
validate_duration_calculations <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_duration_calculations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    start_times <- as.numeric(transcript_data$start)
    end_times <- as.numeric(transcript_data$end)

    # Calculate durations
    calculated_durations <- end_times - start_times

    # Check for negative durations
    negative_durations <- sum(calculated_durations < 0, na.rm = TRUE)
    if (negative_durations > 0) {
      results$status <- "FAIL"
      results$issues$negative_durations <- paste("Found", negative_durations, "entries with negative duration")
    }

    # Check for zero durations
    zero_durations <- sum(calculated_durations == 0, na.rm = TRUE)
    if (zero_durations > 0) {
      results$warnings$zero_durations <- paste("Found", zero_durations, "entries with zero duration")
    }

    # Check for very long durations
    very_long_durations <- sum(calculated_durations > 300, na.rm = TRUE) # > 5 minutes
    if (very_long_durations > 0) {
      results$warnings$very_long_durations <- paste("Found", very_long_durations, "entries with duration > 5 minutes")
    }
  }

  results
}

#' Validate reasonable gaps
#' @keywords internal
validate_reasonable_gaps <- function(transcript_data, max_gap_seconds) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_reasonable_gaps' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    start_times <- as.numeric(transcript_data$start)
    end_times <- as.numeric(transcript_data$end)

    # Calculate gaps between entries (only if more than one entry)
    if (length(start_times) > 1) {
      gaps <- start_times[2:length(start_times)] - end_times[1:(length(end_times) - 1)]

      # Check for large gaps
      large_gaps <- sum(gaps > max_gap_seconds, na.rm = TRUE)
      if (large_gaps > 0) {
        results$warnings$large_gaps <- paste("Found", large_gaps, "gaps >", max_gap_seconds, "seconds")
      }
    }
  }

  results
}

#' Analyze timing patterns
#' @keywords internal
analyze_timing_patterns <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'analyze_timing_patterns' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  analysis <- list()

  if ("start" %in% names(transcript_data) && "end" %in% names(transcript_data)) {
    start_times <- as.numeric(transcript_data$start)
    end_times <- as.numeric(transcript_data$end)

    analysis$total_duration <- max(end_times, na.rm = TRUE) - min(start_times, na.rm = TRUE)
    analysis$avg_entry_duration <- mean(end_times - start_times, na.rm = TRUE)
    analysis$total_entries <- length(start_times)
    analysis$entries_per_minute <- analysis$total_entries / (analysis$total_duration / 60)
  }

  analysis
}

# Helper functions for name coverage validation

#' Analyze name coverage
#' @keywords internal
analyze_name_coverage <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'analyze_name_coverage' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  analysis <- list()

  if ("name" %in% names(transcript_data)) {
    unique_names <- unique(transcript_data$name)

    analysis$total_unique_names <- length(unique_names)
    analysis$unique_names <- unique_names
    analysis$name_frequency <- table(transcript_data$name)

    # Analyze name patterns
    analysis$name_lengths <- nchar(unique_names)
    analysis$avg_name_length <- mean(analysis$name_lengths, na.rm = TRUE)
  }

  analysis
}

#' Validate expected names
#' @keywords internal
validate_expected_names <- function(transcript_data, expected_names) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_expected_names' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("name" %in% names(transcript_data)) {
    actual_names <- unique(transcript_data$name)
    missing_names <- setdiff(expected_names, actual_names)
    unexpected_names <- setdiff(actual_names, expected_names)

    if (length(missing_names) > 0) {
      results$status <- "FAIL"
      results$issues$missing_expected_names <- paste(
        "Missing expected names:",
        paste(missing_names, collapse = ", ")
      )
    }

    if (length(unexpected_names) > 0) {
      results$warnings$unexpected_names <- paste(
        "Found unexpected names:",
        paste(unexpected_names, collapse = ", ")
      )
    }
  }

  results
}

#' Validate name variations
#' @keywords internal
validate_name_variations <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_name_variations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("name" %in% names(transcript_data)) {
    unique_names <- unique(transcript_data$name)

    # Check for common name variation patterns
    # This is a basic check - more sophisticated name matching would be needed

    # Check for formal vs informal variations
    formal_patterns <- grepl("^(Dr\\.|Professor|Prof\\.)", unique_names)
    informal_patterns <- grepl("^(Tom|Sam|Rob|Tony|Ed)", unique_names)

    if (sum(formal_patterns) == 0 && sum(informal_patterns) > 0) {
      results$warnings$no_name_variations <- "Only informal name variations detected (no formal variations)"
    } else if (sum(formal_patterns) == 0 && sum(informal_patterns) == 0) {
      results$warnings$no_name_variations <- "No name variations detected (formal/informal)"
    }
  }

  results
}

#' Validate name edge cases
#' @keywords internal
validate_name_edge_cases <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_name_edge_cases' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("name" %in% names(transcript_data)) {
    unique_names <- unique(transcript_data$name)

    # Check for edge case patterns
    edge_cases <- list()

    # Names with special characters
    special_char_names <- grepl("[^A-Za-z0-9 ]", unique_names)
    if (sum(special_char_names) > 0) {
      edge_cases$special_characters <- sum(special_char_names)
    }

    # Names with numbers
    number_names <- grepl("[0-9]", unique_names)
    if (sum(number_names) > 0) {
      edge_cases$numbers <- sum(number_names)
    }

    # Very long names
    long_names <- nchar(unique_names) > 30
    if (sum(long_names) > 0) {
      edge_cases$very_long <- sum(long_names)
    }

    if (length(edge_cases) == 0) {
      results$warnings$no_edge_cases <- "No edge case names detected"
    } else {
      results$validation_details$edge_cases_found <- edge_cases
    }
  }

  results
}

#' Validate scenario completeness
#' @keywords internal
validate_scenario_completeness <- function(transcript_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'validate_scenario_completeness' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  results <- list(status = "PASS", issues = list(), warnings = list())

  if ("name" %in% names(transcript_data)) {
    unique_names <- unique(transcript_data$name)

    # Check for common ideal course scenarios
    scenarios <- list()

    # Instructor scenario
    instructor_patterns <- grepl("^(Professor|Prof\\.|Dr\\.)", unique_names)
    scenarios$instructor <- sum(instructor_patterns)

    # Student scenarios
    student_patterns <- grepl("^(Tom|Samantha|Robert|Wei|Jose|A\\.J\\.)", unique_names)
    scenarios$students <- sum(student_patterns)

    # Guest scenarios
    guest_patterns <- grepl("^(Guest|Dr\\. Brown)", unique_names)
    scenarios$guests <- sum(guest_patterns)

    # Check for minimum scenario coverage
    if (scenarios$instructor == 0) {
      results$warnings$no_instructor <- "No instructor names detected"
    }

    if (scenarios$students == 0) {
      results$warnings$no_students <- "No student names detected"
    }

    results$validation_details$scenarios_found <- scenarios
  }

  results
}

# Recommendation generation functions

#' Generate structure recommendations
#' @keywords internal
gen_structure_recommendations <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_structure_recommendations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  recommendations <- list()

  if (results$status == "FAIL") {
    recommendations$priority <- "Fix critical structure issues"

    if ("missing_columns" %in% names(results$issues)) {
      recommendations$missing_columns <- "Add required columns: name, comment, start, end"
    }

    if ("empty_data" %in% names(results$issues)) {
      recommendations$empty_data <- "Ensure transcript contains valid data"
    }
  }

  if (results$status == "WARN") {
    recommendations$priority <- "Address structure warnings"

    if ("few_rows" %in% names(results$warnings)) {
      recommendations$few_rows <- "Consider adding more transcript entries"
    }
  }

  recommendations
}

#' Generate content recommendations
#' @keywords internal
gen_content_recommendations <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_content_recommendations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  recommendations <- list()

  if (results$status == "FAIL") {
    recommendations$priority <- "Improve content quality"
  }

  if (results$status == "WARN") {
    recommendations$priority <- "Address content quality warnings"

    if ("very_short_comments" %in% names(results$warnings)) {
      recommendations$short_comments <- "Consider expanding very short comments"
    }

    if ("very_long_comments" %in% names(results$warnings)) {
      recommendations$long_comments <- "Consider breaking up very long comments"
    }

    if ("low_diversity" %in% names(results$warnings)) {
      recommendations$diversity <- "Consider adding more diverse content"
    }
  }

  # Always provide at least one recommendation
  if (length(recommendations) == 0) {
    recommendations$general <- "Content quality is good"
  }

  recommendations
}

#' Generate timing recommendations
#' @keywords internal
gen_timing_recommendations <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_timing_recommendations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  recommendations <- list()

  if (results$status == "FAIL") {
    recommendations$priority <- "Fix timing issues"

    if ("non_chronological" %in% names(results$issues)) {
      recommendations$chronological <- "Ensure timestamps are in chronological order"
    }

    if ("overlaps" %in% names(results$issues)) {
      recommendations$overlaps <- "Remove overlapping timestamp entries"
    }
  }

  if (results$status == "WARN") {
    recommendations$priority <- "Address timing warnings"

    if ("large_gaps" %in% names(results$warnings)) {
      recommendations$gaps <- "Consider adding content to fill large time gaps"
    }
  }

  if (results$status == "PASS") {
    recommendations$general <- "Timing validation passed successfully"
  }

  # Always return at least one recommendation
  if (length(recommendations) == 0) {
    recommendations$general <- "Review timing validation results"
  }

  recommendations
}

#' Generate name coverage recommendations
#' @keywords internal
generate_name_coverage_recommendations <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_name_coverage_recommendations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  recommendations <- list()

  if (results$status == "FAIL") {
    recommendations$priority <- "Improve name coverage"

    if ("missing_expected_names" %in% names(results$issues)) {
      recommendations$missing_names <- "Add missing expected speaker names"
    }
  }

  if (results$status == "WARN") {
    recommendations$priority <- "Enhance name coverage"

    if ("no_name_variations" %in% names(results$warnings)) {
      recommendations$variations <- "Add name variations (formal/informal)"
    }

    if ("no_edge_cases" %in% names(results$warnings)) {
      recommendations$edge_cases <- "Add edge case names for comprehensive testing"
    }
  }

  if (results$status == "PASS") {
    recommendations$general <- "Name coverage validation passed successfully"
  }

  # Always return at least one recommendation
  if (length(recommendations) == 0) {
    recommendations$general <- "Review name coverage validation results"
  }

  recommendations
}

#' Generate comprehensive summary
#' @keywords internal
generate_comprehensive_summary <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_comprehensive_summary' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  summary <- list()

  # Overall status
  summary$overall_status <- results$overall_status

  # Individual validation statuses
  summary$validation_statuses <- sapply(results$validation_results, function(x) x$status)

  # Count issues and warnings
  total_issues <- sum(sapply(results$validation_results, function(x) length(x$issues)))
  total_warnings <- sum(sapply(results$validation_results, function(x) length(x$warnings)))

  summary$total_issues <- total_issues
  summary$total_warnings <- total_warnings

  # Quality score if available
  if ("content_quality" %in% names(results$validation_results)) {
    summary$quality_score <- results$validation_results$content_quality$quality_score
  }

  summary
}

#' Generate comprehensive recommendations
#' @keywords internal
generate_comprehensive_recommendations <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_comprehensive_recommendations' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  recommendations <- list()

  if (results$overall_status == "FAIL") {
    recommendations$priority <- "Critical: Fix validation failures"

    # Collect all critical issues
    critical_issues <- unlist(lapply(results$validation_results, function(x) x$issues))
    recommendations$critical_issues <- critical_issues
  }

  if (results$overall_status == "WARN") {
    recommendations$priority <- "Address validation warnings"

    # Collect all warnings
    all_warnings <- unlist(lapply(results$validation_results, function(x) x$warnings))
    recommendations$warnings <- all_warnings
  }

  if (results$overall_status == "PASS") {
    recommendations$priority <- "Excellent: All validations passed"
    recommendations$general <- "Transcript validation is complete and successful"
  }

  # Always return at least one recommendation
  if (length(recommendations) == 0) {
    recommendations$general <- "Review validation results and address any issues"
  }

  if (results$overall_status == "PASS") {
    recommendations$next_steps <- "Transcript is ready for use"
  }

  recommendations
}

#' Generate detailed validation report
#' @keywords internal
gen_detailed_validation_report <- function(results) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_detailed_validation_report' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  report <- list()

  # Executive summary
  report$executive_summary <- paste(
    "Comprehensive validation completed at", results$timestamp,
    "with overall status:", results$overall_status
  )

  # Detailed results for each validation type
  report$validation_details <- results$validation_results

  # Summary statistics
  report$summary <- results$summary

  # Recommendations
  report$recommendations <- results$recommendations

  report
}
