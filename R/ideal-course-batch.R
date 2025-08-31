#' Process all ideal course transcripts in batch
#'
#' Processes all ideal course transcripts (sessions 1-3) in batch mode, providing
#' comprehensive analysis across multiple scenarios. This function is designed
#' for testing, validation, and demonstration purposes using the package's
#' synthetic ideal course data.
#'
#' @param include_roster Logical. Whether to include roster data in processing.
#'   Default: TRUE
#' @param privacy_level Character. Privacy level for processing. Options:
#'   "full" (FERPA strict), "masked" (default), "none" (no privacy protection)
#' @param output_format Character. Output format. Options: "list" (default),
#'   "data.frame", "summary"
#' @param consolidate_comments Logical. Whether to consolidate consecutive comments.
#'   Default: TRUE
#' @param add_dead_air Logical. Whether to add dead air rows. Default: TRUE
#' @param names_exclude Character vector. Names to exclude from analysis.
#'   Default: c("dead_air")
#'
#' @return List or data.frame with batch processing results containing:
#'   - session_data: Processed transcript data for each session
#'   - summary_metrics: Engagement metrics for each session
#'   - participation_patterns: Cross-session participation analysis
#'   - validation_results: Basic validation checks
#'   - processing_info: Metadata about the batch processing
#'
#' @importFrom utils read.csv
#' @examples
#' \dontrun{
#' # Process all ideal course sessions with default settings
#' batch_results <- process_ideal_course_batch()
#'
#' # Process with custom privacy settings
#' batch_results <- process_ideal_course_batch(
#'   privacy_level = "full",
#'   output_format = "summary"
#' )
#'
#' # Process without roster data
#' batch_results <- process_ideal_course_batch(
#'   include_roster = FALSE,
#'   output_format = "data.frame"
#' )
#' }
#'
#' @export
process_ideal_course_batch <- function(include_roster = TRUE,
                                       privacy_level = "masked",
                                       output_format = "list",
                                       consolidate_comments = TRUE,
                                       add_dead_air = TRUE,
                                       names_exclude = c("dead_air")) {
  # Validate inputs
  if (!privacy_level %in% c("full", "masked", "none")) {
    stop("privacy_level must be one of: 'full', 'masked', 'none'")
  }

  if (!output_format %in% c("list", "data.frame", "summary")) {
    stop("output_format must be one of: 'list', 'data.frame', 'summary'")
  }

  # Get ideal course transcript directory
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  if (!dir.exists(transcript_dir)) {
    stop("Ideal course transcript directory not found")
  }

  # Define ideal course session files
  session_files <- c(
    "ideal_course_session1.vtt",
    "ideal_course_session2.vtt",
    "ideal_course_session3.vtt"
  )

  # Initialize results storage
  session_data <- list()
  summary_metrics <- list()
  participation_patterns <- list()
  processing_errors <- list()

  # Load roster data if requested
  roster_data <- NULL
  if (include_roster) {
    roster_path <- file.path(transcript_dir, "ideal_course_roster.csv")
    if (file.exists(roster_path)) {
      roster_data <- read.csv(roster_path, stringsAsFactors = FALSE)
    } else {
      warning("Roster file not found, proceeding without roster data")
    }
  }

  # Process each session
  for (i in seq_along(session_files)) {
    session_file <- session_files[i]
    session_name <- paste0("session", i)
    session_path <- file.path(transcript_dir, session_file)

    if (!file.exists(session_path)) {
      processing_errors[[session_name]] <- paste("File not found:", session_file)
      next
    }

    tryCatch(
      {
        # Load and process transcript
        raw_transcript <- load_zoom_transcript(session_path)

        if (is.null(raw_transcript) || nrow(raw_transcript) == 0) {
          processing_errors[[session_name]] <- "Empty or invalid transcript"
          next
        }

        # Process transcript with specified options
        processed_transcript <- process_zoom_transcript(
          transcript_file_path = session_path,
          consolidate_comments = consolidate_comments,
          add_dead_air = add_dead_air,
          dead_air_name = "dead_air",
          na_name = "unknown"
        )

        # Calculate summary metrics
        session_metrics <- summarize_transcript_metrics(
          transcript_file_path = session_path,
          names_exclude = names_exclude,
          consolidate_comments = consolidate_comments,
          add_dead_air = add_dead_air
        )

        # Store results
        session_data[[session_name]] <- processed_transcript
        summary_metrics[[session_name]] <- session_metrics

        # Extract participation patterns
        participants <- unique(processed_transcript$name)
        participants <- participants[!participants %in% names_exclude]
        participation_patterns[[session_name]] <- participants
      },
      error = function(e) {
        processing_errors[[session_name]] <- e$message
      }
    )
  }

  # Create processing info
  processing_info <- list(
    timestamp = Sys.time(),
    privacy_level = privacy_level,
    sessions_processed = length(session_data),
    sessions_failed = length(processing_errors),
    total_participants = length(unique(unlist(participation_patterns))),
    processing_options = list(
      consolidate_comments = consolidate_comments,
      add_dead_air = add_dead_air,
      names_exclude = names_exclude,
      include_roster = include_roster
    )
  )

  # Create validation results
  validation_results <- list(
    all_sessions_loaded = length(session_data) == 3,
    no_processing_errors = length(processing_errors) == 0,
    data_consistency = all(sapply(session_data, function(x) !is.null(x) && nrow(x) > 0)),
    privacy_compliant = privacy_level != "none"
  )

  # Prepare output based on format
  if (output_format == "list") {
    result <- list(
      session_data = session_data,
      summary_metrics = summary_metrics,
      participation_patterns = participation_patterns,
      validation_results = validation_results,
      processing_info = processing_info,
      processing_errors = processing_errors
    )
  } else if (output_format == "data.frame") {
    # Combine all summary metrics into a single data frame
    all_metrics <- do.call(rbind, lapply(names(summary_metrics), function(session) {
      if (!is.null(summary_metrics[[session]]) && nrow(summary_metrics[[session]]) > 0) {
        summary_metrics[[session]]$session <- session
        summary_metrics[[session]]
      } else {
        NULL
      }
    }))

    result <- all_metrics
  } else if (output_format == "summary") {
    # Create a summary data frame
    summary_df <- data.frame(
      session = names(session_data),
      participants = sapply(participation_patterns, length),
      total_comments = sapply(session_data, function(x) nrow(x[x$name != "dead_air", ])),
      total_duration = sapply(session_data, function(x) sum(x$duration[x$name != "dead_air"], na.rm = TRUE)),
      total_words = sapply(session_data, function(x) sum(x$wordcount[x$name != "dead_air"], na.rm = TRUE)),
      stringsAsFactors = FALSE
    )

    result <- summary_df
  }

  # Add attributes for provenance
  attr(result, "batch_processing") <- TRUE
  attr(result, "privacy_level") <- privacy_level
  attr(result, "processing_timestamp") <- processing_info$timestamp

  return(result)
}

#' Compare engagement patterns across ideal course sessions
#'
#' Analyzes and compares engagement patterns across all ideal course sessions,
#' providing insights into participation trends, attendance patterns, and
#' engagement metrics.
#'
#' @param batch_results Results from process_ideal_course_batch()
#' @param comparison_metrics Character vector. Metrics to compare. Options:
#'   "total_comments", "duration", "wordcount", "wpm", "participation_rate".
#'   Default: c("total_comments", "duration")
#' @param visualization Logical. Whether to include visualization data.
#'   Default: TRUE
#' @param include_roster_comparison Logical. Whether to include roster-based
#'   comparison. Default: TRUE
#'
#' @return List containing comparison results and insights:
#'   - comparison_data: Data frame with comparison metrics
#'   - insights: Text insights about patterns
#'   - trends: Trend analysis across sessions
#'   - visualization_data: Data prepared for plotting (if visualization = TRUE)
#'   - roster_analysis: Roster-based attendance analysis (if include_roster_comparison = TRUE)
#'
#' @examples
#' \dontrun{
#' # Process batch data first
#' batch_results <- process_ideal_course_batch()
#'
#' # Compare sessions
#' comparison <- compare_ideal_sessions(batch_results)
#'
#' # Compare specific metrics
#' comparison <- compare_ideal_sessions(
#'   batch_results,
#'   comparison_metrics = c("total_comments", "duration", "wpm")
#' )
#' }
#'
#' @export
compare_ideal_sessions <- function(batch_results,
                                   comparison_metrics = c("total_comments", "duration"),
                                   visualization = TRUE,
                                   include_roster_comparison = TRUE) {
  # Validate inputs
  valid_metrics <- c("total_comments", "duration", "wordcount", "wpm", "participation_rate")
  if (!all(comparison_metrics %in% valid_metrics)) {
    stop("Invalid comparison_metrics. Valid options: ", paste(valid_metrics, collapse = ", "))
  }

  # Extract summary metrics from batch results
  if ("summary_metrics" %in% names(batch_results)) {
    summary_metrics <- batch_results$summary_metrics
  } else {
    stop("batch_results must contain summary_metrics from process_ideal_course_batch()")
  }

  # Create comparison data frame
  comparison_data <- data.frame()

  for (session_name in names(summary_metrics)) {
    session_metrics <- summary_metrics[[session_name]]

    if (!is.null(session_metrics) && nrow(session_metrics) > 0) {
      # Calculate session-level metrics
      session_summary <- data.frame(
        session = session_name,
        total_participants = nrow(session_metrics),
        total_comments = sum(session_metrics$n, na.rm = TRUE),
        total_duration = sum(session_metrics$duration, na.rm = TRUE),
        total_words = sum(session_metrics$wordcount, na.rm = TRUE),
        avg_wpm = mean(session_metrics$wpm, na.rm = TRUE),
        participation_rate = nrow(session_metrics) / max(nrow(session_metrics), 1),
        stringsAsFactors = FALSE
      )

      comparison_data <- rbind(comparison_data, session_summary)
    }
  }

  # Generate insights
  insights <- generate_comparison_insights(comparison_data, comparison_metrics)

  # Analyze trends
  trends <- analyze_session_trends(comparison_data, comparison_metrics)

  # Prepare visualization data
  visualization_data <- NULL
  if (visualization) {
    visualization_data <- prepare_visualization_data(comparison_data, comparison_metrics)
  }

  # Roster-based analysis
  roster_analysis <- NULL
  if (include_roster_comparison) {
    roster_analysis <- analyze_roster_attendance(batch_results)
  }

  # Create result
  result <- list(
    comparison_data = comparison_data,
    insights = insights,
    trends = trends,
    visualization_data = visualization_data,
    roster_analysis = roster_analysis
  )

  # Add attributes
  attr(result, "comparison_metrics") <- comparison_metrics
  attr(result, "visualization_included") <- visualization

  return(result)
}

#' Validate all ideal course scenarios
#'
#' Performs comprehensive validation of all ideal course scenarios, checking
#' expected patterns, data consistency, and processing quality.
#'
#' @param batch_results Results from process_ideal_course_batch()
#' @param validation_rules List. Custom validation rules. Default: NULL (uses defaults)
#' @param detailed_report Logical. Whether to generate detailed report.
#'   Default: TRUE
#' @param include_data_quality Logical. Whether to include data quality checks.
#'   Default: TRUE
#'
#' @return List containing validation results:
#'   - validation_summary: Overall validation status
#'   - rule_results: Results for each validation rule
#'   - data_quality_report: Data quality assessment (if include_data_quality = TRUE)
#'   - recommendations: Recommendations for improvement
#'   - detailed_report: Detailed validation report (if detailed_report = TRUE)
#'
#' @examples
#' \dontrun{
#' # Process batch data first
#' batch_results <- process_ideal_course_batch()
#'
#' # Validate scenarios
#' validation <- validate_ideal_scenarios(batch_results)
#'
#' # Validate with custom rules
#' custom_rules <- list(
#'   min_participants = 3,
#'   max_duration = 600
#' )
#' validation <- validate_ideal_scenarios(batch_results, validation_rules = custom_rules)
#' }
#'
#' @export
validate_ideal_scenarios <- function(batch_results,
                                     validation_rules = NULL,
                                     detailed_report = TRUE,
                                     include_data_quality = TRUE) {
  # Set default validation rules if none provided
  if (is.null(validation_rules)) {
    validation_rules <- list(
      min_sessions = 3,
      min_participants_per_session = 3,
      max_participants_per_session = 10,
      min_total_comments = 10,
      max_session_duration = 600, # 10 minutes
      require_name_consistency = TRUE,
      require_timestamp_consistency = TRUE,
      require_comment_content = TRUE
    )
  }

  # Initialize validation results
  rule_results <- list()
  validation_summary <- list(
    total_rules = length(validation_rules),
    passed_rules = 0,
    failed_rules = 0,
    overall_status = "PENDING"
  )

  # Extract data from batch results
  session_data <- batch_results$session_data
  summary_metrics <- batch_results$summary_metrics
  participation_patterns <- batch_results$participation_patterns

  # Validate number of sessions
  if ("min_sessions" %in% names(validation_rules)) {
    rule_results$session_count <- validate_session_count(
      session_data, validation_rules$min_sessions
    )
  }

  # Validate participant counts
  if ("min_participants_per_session" %in% names(validation_rules) ||
    "max_participants_per_session" %in% names(validation_rules)) {
    rule_results$participant_counts <- validate_participant_counts(
      participation_patterns, validation_rules
    )
  }

  # Validate engagement metrics
  if ("min_total_comments" %in% names(validation_rules)) {
    rule_results$engagement_metrics <- validate_engagement_metrics(
      summary_metrics, validation_rules$min_total_comments
    )
  }

  # Validate session duration
  if ("max_session_duration" %in% names(validation_rules)) {
    rule_results$session_duration <- validate_session_duration(
      session_data, validation_rules$max_session_duration
    )
  }

  # Validate data consistency
  if ("require_name_consistency" %in% names(validation_rules) &&
    validation_rules$require_name_consistency) {
    rule_results$name_consistency <- validate_name_consistency(session_data)
  }

  if ("require_timestamp_consistency" %in% names(validation_rules) &&
    validation_rules$require_timestamp_consistency) {
    rule_results$timestamp_consistency <- validate_timestamp_consistency(session_data)
  }

  if ("require_comment_content" %in% names(validation_rules) &&
    validation_rules$require_comment_content) {
    rule_results$comment_content <- validate_comment_content(session_data)
  }

  # Calculate validation summary
  passed_rules <- sum(sapply(rule_results, function(x) {
    if (is.list(x) && "status" %in% names(x)) {
      x$status == "PASS"
    } else if (is.list(x)) {
      # Handle nested lists (like participant_counts)
      sum(sapply(x, function(y) if (is.list(y) && "status" %in% names(y)) y$status == "PASS" else FALSE))
    } else {
      FALSE
    }
  }))

  failed_rules <- sum(sapply(rule_results, function(x) {
    if (is.list(x) && "status" %in% names(x)) {
      x$status == "FAIL"
    } else if (is.list(x)) {
      # Handle nested lists (like participant_counts)
      sum(sapply(x, function(y) if (is.list(y) && "status" %in% names(y)) y$status == "FAIL" else FALSE))
    } else {
      FALSE
    }
  }))

  validation_summary$passed_rules <- passed_rules
  validation_summary$failed_rules <- failed_rules
  validation_summary$overall_status <- ifelse(failed_rules == 0, "PASS", "FAIL")

  # Generate data quality report
  data_quality_report <- NULL
  if (include_data_quality) {
    data_quality_report <- generate_data_quality_report(session_data, summary_metrics)
  }

  # Generate recommendations
  recommendations <- generate_validation_recommendations(rule_results, validation_summary)

  # Generate detailed report
  detailed_report_content <- NULL
  if (detailed_report) {
    # Create a results object compatible with the validation function
    validation_results <- list(
      validation_results = rule_results,
      overall_status = validation_summary$overall_status,
      summary = validation_summary,
      recommendations = recommendations,
      timestamp = Sys.time()
    )
    detailed_report_content <- generate_detailed_validation_report(validation_results)
  }

  # Create result
  result <- list(
    validation_summary = validation_summary,
    rule_results = rule_results,
    data_quality_report = data_quality_report,
    recommendations = recommendations,
    detailed_report = detailed_report_content
  )

  # Add attributes
  attr(result, "validation_timestamp") <- Sys.time()
  attr(result, "validation_rules_used") <- names(validation_rules)

  return(result)
}

# Helper functions for compare_ideal_sessions

#' Generate comparison insights
#' @keywords internal
generate_comparison_insights <- function(comparison_data, metrics) {
  insights <- list()

  if (nrow(comparison_data) < 2) {
    insights$general <- "Insufficient data for comparison (need at least 2 sessions)"
    return(insights)
  }

  # General insights
  insights$general <- paste(
    "Analysis of", nrow(comparison_data), "ideal course sessions with",
    length(unique(comparison_data$total_participants)), "unique participant counts"
  )

  # Metric-specific insights
  if ("total_comments" %in% metrics) {
    comment_range <- range(comparison_data$total_comments)
    insights$comments <- paste(
      "Total comments range from", comment_range[1], "to", comment_range[2],
      "across sessions"
    )
  }

  if ("duration" %in% metrics) {
    duration_range <- range(comparison_data$total_duration)
    insights$duration <- paste(
      "Total duration ranges from", round(duration_range[1], 1), "to",
      round(duration_range[2], 1), "seconds across sessions"
    )
  }

  if ("wpm" %in% metrics) {
    wpm_range <- range(comparison_data$avg_wpm, na.rm = TRUE)
    insights$wpm <- paste(
      "Average words per minute ranges from", round(wpm_range[1], 1), "to",
      round(wpm_range[2], 1), "across sessions"
    )
  }

  return(insights)
}

#' Analyze session trends
#' @keywords internal
analyze_session_trends <- function(comparison_data, metrics) {
  trends <- list()

  if (nrow(comparison_data) < 2) {
    trends$general <- "Insufficient data for trend analysis"
    return(trends)
  }

  # Sort by session number
  comparison_data$session_num <- as.numeric(gsub("session", "", comparison_data$session))
  comparison_data <- comparison_data[order(comparison_data$session_num), ]

  # Analyze trends for each metric
  for (metric in metrics) {
    if (metric %in% names(comparison_data)) {
      values <- comparison_data[[metric]]
      if (length(values) >= 2) {
        # Simple trend detection
        first_half <- mean(values[1:ceiling(length(values) / 2)], na.rm = TRUE)
        second_half <- mean(values[ceiling(length(values) / 2):length(values)], na.rm = TRUE)

        if (second_half > first_half * 1.1) {
          trends[[metric]] <- "increasing"
        } else if (second_half < first_half * 0.9) {
          trends[[metric]] <- "decreasing"
        } else {
          trends[[metric]] <- "stable"
        }
      }
    }
  }

  return(trends)
}

#' Prepare visualization data
#' @keywords internal
prepare_visualization_data <- function(comparison_data, metrics) {
  # Create long format data for plotting
  plot_data <- data.frame()

  for (metric in metrics) {
    if (metric %in% names(comparison_data)) {
      metric_data <- data.frame(
        session = comparison_data$session,
        metric = metric,
        value = comparison_data[[metric]],
        stringsAsFactors = FALSE
      )
      plot_data <- rbind(plot_data, metric_data)
    }
  }

  return(plot_data)
}

#' Analyze roster attendance
#' @keywords internal
analyze_roster_attendance <- function(batch_results) {
  # This would analyze attendance against the roster
  # For now, return basic participation patterns
  participation_patterns <- batch_results$participation_patterns

  attendance_summary <- list(
    total_unique_participants = length(unique(unlist(participation_patterns))),
    participants_per_session = sapply(participation_patterns, length),
    consistent_participants = length(Reduce(intersect, participation_patterns))
  )

  return(attendance_summary)
}

# Helper functions for validate_ideal_scenarios

#' Validate session count
#' @keywords internal
validate_session_count <- function(session_data, min_sessions) {
  actual_sessions <- length(session_data)
  status <- ifelse(actual_sessions >= min_sessions, "PASS", "FAIL")

  return(list(
    status = status,
    expected = min_sessions,
    actual = actual_sessions,
    message = paste("Expected at least", min_sessions, "sessions, found", actual_sessions)
  ))
}

#' Validate participant counts
#' @keywords internal
validate_participant_counts <- function(participation_patterns, rules) {
  results <- list()

  for (session_name in names(participation_patterns)) {
    participant_count <- length(participation_patterns[[session_name]])

    min_check <- ifelse("min_participants_per_session" %in% names(rules),
      participant_count >= rules$min_participants_per_session, TRUE
    )
    max_check <- ifelse("max_participants_per_session" %in% names(rules),
      participant_count <= rules$max_participants_per_session, TRUE
    )

    status <- ifelse(min_check && max_check, "PASS", "FAIL")

    results[[session_name]] <- list(
      status = status,
      participant_count = participant_count,
      min_expected = rules$min_participants_per_session %||% 0,
      max_expected = rules$max_participants_per_session %||% Inf
    )
  }

  return(results)
}

#' Validate engagement metrics
#' @keywords internal
validate_engagement_metrics <- function(summary_metrics, min_comments) {
  results <- list()

  for (session_name in names(summary_metrics)) {
    session_metrics <- summary_metrics[[session_name]]
    if (!is.null(session_metrics) && nrow(session_metrics) > 0) {
      total_comments <- sum(session_metrics$n, na.rm = TRUE)
      status <- ifelse(total_comments >= min_comments, "PASS", "FAIL")

      results[[session_name]] <- list(
        status = status,
        total_comments = total_comments,
        expected_min = min_comments
      )
    }
  }

  return(results)
}

#' Validate session duration
#' @keywords internal
validate_session_duration <- function(session_data, max_duration) {
  results <- list()

  for (session_name in names(session_data)) {
    session <- session_data[[session_name]]
    if (!is.null(session) && nrow(session) > 0) {
      total_duration <- sum(session$duration, na.rm = TRUE)
      status <- ifelse(total_duration <= max_duration, "PASS", "FAIL")

      results[[session_name]] <- list(
        status = status,
        total_duration = total_duration,
        max_expected = max_duration
      )
    }
  }

  return(results)
}

#' Validate name consistency
#' @keywords internal
validate_name_consistency <- function(session_data) {
  all_names <- unique(unlist(lapply(session_data, function(x) {
    if (!is.null(x) && nrow(x) > 0) unique(x$name) else character(0)
  })))

  # Check for consistent name formats (basic check)
  has_consistent_format <- all(grepl("^[A-Za-z]+", all_names))

  return(list(
    status = ifelse(has_consistent_format, "PASS", "FAIL"),
    unique_names = length(all_names),
    has_consistent_format = has_consistent_format
  ))
}

#' Validate timestamp consistency
#' @keywords internal
validate_timestamp_consistency <- function(session_data) {
  results <- list()

  for (session_name in names(session_data)) {
    session <- session_data[[session_name]]
    if (!is.null(session) && nrow(session) > 0) {
      # Check for valid timestamps
      valid_timestamps <- all(!is.na(session$start) & !is.na(session$end))
      chronological_order <- all(diff(as.numeric(session$start)) >= 0, na.rm = TRUE)

      status <- ifelse(valid_timestamps && chronological_order, "PASS", "FAIL")

      results[[session_name]] <- list(
        status = status,
        valid_timestamps = valid_timestamps,
        chronological_order = chronological_order
      )
    }
  }

  return(results)
}

#' Validate comment content
#' @keywords internal
validate_comment_content <- function(session_data) {
  results <- list()

  for (session_name in names(session_data)) {
    session <- session_data[[session_name]]
    if (!is.null(session) && nrow(session) > 0) {
      # Check for non-empty comments
      non_empty_comments <- sum(!is.na(session$comment) & session$comment != "", na.rm = TRUE)
      total_comments <- nrow(session)
      content_ratio <- non_empty_comments / total_comments

      status <- ifelse(content_ratio > 0.8, "PASS", "FAIL")

      results[[session_name]] <- list(
        status = status,
        non_empty_comments = non_empty_comments,
        total_comments = total_comments,
        content_ratio = content_ratio
      )
    }
  }

  return(results)
}

#' Generate data quality report
#' @keywords internal
generate_data_quality_report <- function(session_data, summary_metrics) {
  report <- list()

  # Overall statistics
  total_sessions <- length(session_data)
  total_participants <- length(unique(unlist(lapply(session_data, function(x) {
    if (!is.null(x) && nrow(x) > 0) unique(x$name) else character(0)
  }))))

  report$overall_stats <- list(
    total_sessions = total_sessions,
    total_participants = total_participants,
    avg_participants_per_session = total_participants / total_sessions
  )

  # Session-specific quality metrics
  session_quality <- list()
  for (session_name in names(session_data)) {
    session <- session_data[[session_name]]
    if (!is.null(session) && nrow(session) > 0) {
      session_quality[[session_name]] <- list(
        total_rows = nrow(session),
        unique_participants = length(unique(session$name)),
        missing_names = sum(is.na(session$name)),
        missing_comments = sum(is.na(session$comment) | session$comment == ""),
        missing_timestamps = sum(is.na(session$start) | is.na(session$end))
      )
    }
  }

  report$session_quality <- session_quality

  return(report)
}

#' Generate validation recommendations
#' @keywords internal
generate_validation_recommendations <- function(rule_results, validation_summary) {
  recommendations <- list()

  if (validation_summary$failed_rules > 0) {
    recommendations$priority <- "Address failed validation rules"

    # Generate specific recommendations based on failed rules
    # Handle both simple and nested rule structures
    failed_rules <- character(0)
    for (rule_name in names(rule_results)) {
      rule_result <- rule_results[[rule_name]]
      if (is.list(rule_result) && "status" %in% names(rule_result)) {
        if (rule_result$status == "FAIL") {
          failed_rules <- c(failed_rules, rule_name)
        }
      } else if (is.list(rule_result)) {
        # Handle nested lists
        for (nested_name in names(rule_result)) {
          nested_result <- rule_result[[nested_name]]
          if (is.list(nested_result) && "status" %in% names(nested_result)) {
            if (nested_result$status == "FAIL") {
              failed_rules <- c(failed_rules, paste0(rule_name, ".", nested_name))
            }
          }
        }
      }
    }

    if ("session_count" %in% failed_rules) {
      recommendations$session_count <- "Ensure all ideal course sessions are available"
    }

    if (any(grepl("participant_counts", failed_rules))) {
      recommendations$participant_counts <- "Review participant count expectations"
    }

    if (any(grepl("engagement_metrics", failed_rules))) {
      recommendations$engagement_metrics <- "Check minimum engagement thresholds"
    }
  } else {
    recommendations$priority <- "All validation rules passed"
    recommendations$next_steps <- "Proceed with confidence in data quality"
  }

  return(recommendations)
}
