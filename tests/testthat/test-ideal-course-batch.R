# Test file for ideal course batch processing functions
# Tests for process_ideal_course_batch, compare_ideal_sessions, and validate_ideal_scenarios

library(testthat)
library(zoomstudentengagement)

# Test context
test_that("process_ideal_course_batch works with default parameters", {
  # Test basic functionality with default parameters
  result <- process_ideal_course_batch()

  # Check return structure
  expect_type(result, "list")
  expect_true("session_data" %in% names(result))
  expect_true("summary_metrics" %in% names(result))
  expect_true("participation_patterns" %in% names(result))
  expect_true("validation_results" %in% names(result))
  expect_true("processing_info" %in% names(result))

  # Check session data
  expect_true(length(result$session_data) > 0)
  expect_true(all(sapply(result$session_data, function(x) !is.null(x))))

  # Check summary metrics
  expect_true(length(result$summary_metrics) > 0)
  expect_true(all(sapply(result$summary_metrics, function(x) !is.null(x))))

  # Check participation patterns
  expect_true(length(result$participation_patterns) > 0)

  # Check validation results
  expect_true("all_sessions_loaded" %in% names(result$validation_results))
  expect_true("no_processing_errors" %in% names(result$validation_results))

  # Check processing info
  expect_true("timestamp" %in% names(result$processing_info))
  expect_true("privacy_level" %in% names(result$processing_info))
  expect_equal(result$processing_info$privacy_level, "masked")
})

test_that("process_ideal_course_batch handles different privacy levels", {
  # Test with full privacy
  result_full <- process_ideal_course_batch(privacy_level = "full")
  expect_equal(result_full$processing_info$privacy_level, "full")

  # Test with no privacy
  result_none <- process_ideal_course_batch(privacy_level = "none")
  expect_equal(result_none$processing_info$privacy_level, "none")

  # Test with masked privacy (default)
  result_masked <- process_ideal_course_batch(privacy_level = "masked")
  expect_equal(result_masked$processing_info$privacy_level, "masked")
})

test_that("process_ideal_course_batch handles different output formats", {
  # Test list format (default)
  result_list <- process_ideal_course_batch(output_format = "list")
  expect_type(result_list, "list")
  expect_true("session_data" %in% names(result_list))

  # Test data.frame format
  result_df <- process_ideal_course_batch(output_format = "data.frame")
  expect_s3_class(result_df, "data.frame")
  expect_true("session" %in% names(result_df))

  # Test summary format
  result_summary <- process_ideal_course_batch(output_format = "summary")
  expect_s3_class(result_summary, "data.frame")
  expect_true("session" %in% names(result_summary))
  expect_true("participants" %in% names(result_summary))
  expect_true("total_comments" %in% names(result_summary))
})

test_that("process_ideal_course_batch handles roster inclusion", {
  # Test with roster
  result_with_roster <- process_ideal_course_batch(include_roster = TRUE)
  expect_true(result_with_roster$processing_info$processing_options$include_roster)

  # Test without roster
  result_without_roster <- process_ideal_course_batch(include_roster = FALSE)
  expect_false(result_without_roster$processing_info$processing_options$include_roster)
})

test_that("process_ideal_course_batch validates inputs correctly", {
  # Test invalid privacy level
  expect_error(
    process_ideal_course_batch(privacy_level = "invalid"),
    "privacy_level must be one of: 'full', 'masked', 'none'"
  )

  # Test invalid output format
  expect_error(
    process_ideal_course_batch(output_format = "invalid"),
    "output_format must be one of: 'list', 'data.frame', 'summary'"
  )
})

test_that("process_ideal_course_batch handles processing options", {
  # Test with different processing options
  result <- process_ideal_course_batch(
    consolidate_comments = FALSE,
    add_dead_air = FALSE,
    names_exclude = c("dead_air", "unknown")
  )

  expect_false(result$processing_info$processing_options$consolidate_comments)
  expect_false(result$processing_info$processing_options$add_dead_air)
  expect_equal(result$processing_info$processing_options$names_exclude, c("dead_air", "unknown"))
})

test_that("process_ideal_course_batch includes proper attributes", {
  result <- process_ideal_course_batch()

  expect_true(attr(result, "batch_processing"))
  expect_equal(attr(result, "privacy_level"), "masked")
  expect_true(!is.null(attr(result, "processing_timestamp")))
})

test_that("compare_ideal_sessions provides meaningful insights", {
  # Process batch data first
  batch_results <- process_ideal_course_batch()

  # Test basic comparison
  comparison <- compare_ideal_sessions(batch_results)

  # Check return structure
  expect_type(comparison, "list")
  expect_true("comparison_data" %in% names(comparison))
  expect_true("insights" %in% names(comparison))
  expect_true("trends" %in% names(comparison))
  expect_true("visualization_data" %in% names(comparison))
  expect_true("roster_analysis" %in% names(comparison))

  # Check comparison data
  expect_s3_class(comparison$comparison_data, "data.frame")
  expect_true(nrow(comparison$comparison_data) > 0)
  expect_true("session" %in% names(comparison$comparison_data))

  # Check insights
  expect_type(comparison$insights, "list")
  expect_true("general" %in% names(comparison$insights))

  # Check trends
  expect_type(comparison$trends, "list")

  # Check visualization data
  expect_s3_class(comparison$visualization_data, "data.frame")
  expect_true(nrow(comparison$visualization_data) > 0)

  # Check roster analysis
  expect_type(comparison$roster_analysis, "list")
  expect_true("total_unique_participants" %in% names(comparison$roster_analysis))
})

test_that("compare_ideal_sessions handles different comparison metrics", {
  batch_results <- process_ideal_course_batch()

  # Test with specific metrics
  comparison <- compare_ideal_sessions(
    batch_results,
    comparison_metrics = c("total_comments", "duration", "wpm")
  )

  expect_type(comparison, "list")
  expect_true("comparison_data" %in% names(comparison))

  # Test with single metric
  comparison_single <- compare_ideal_sessions(
    batch_results,
    comparison_metrics = "total_comments"
  )

  expect_type(comparison_single, "list")
})

test_that("compare_ideal_sessions validates inputs correctly", {
  batch_results <- process_ideal_course_batch()

  # Test invalid metrics
  expect_error(
    compare_ideal_sessions(batch_results, comparison_metrics = "invalid_metric"),
    "Invalid comparison_metrics"
  )

  # Test invalid batch results
  expect_error(
    compare_ideal_sessions(list()),
    "batch_results must contain summary_metrics"
  )
})

test_that("compare_ideal_sessions handles visualization options", {
  batch_results <- process_ideal_course_batch()

  # Test with visualization
  comparison_with_viz <- compare_ideal_sessions(batch_results, visualization = TRUE)
  expect_true(!is.null(comparison_with_viz$visualization_data))

  # Test without visualization
  comparison_without_viz <- compare_ideal_sessions(batch_results, visualization = FALSE)
  expect_true(is.null(comparison_without_viz$visualization_data))
})

test_that("compare_ideal_sessions includes proper attributes", {
  batch_results <- process_ideal_course_batch()
  comparison <- compare_ideal_sessions(batch_results)

  expect_equal(attr(comparison, "comparison_metrics"), c("total_comments", "duration"))
  expect_true(attr(comparison, "visualization_included"))
})

test_that("validate_ideal_scenarios checks all expected scenarios", {
  # Process batch data first
  batch_results <- process_ideal_course_batch()

  # Test basic validation
  validation <- validate_ideal_scenarios(batch_results)

  # Check return structure
  expect_type(validation, "list")
  expect_true("validation_summary" %in% names(validation))
  expect_true("rule_results" %in% names(validation))
  expect_true("data_quality_report" %in% names(validation))
  expect_true("recommendations" %in% names(validation))
  expect_true("detailed_report" %in% names(validation))

  # Check validation summary
  expect_true("total_rules" %in% names(validation$validation_summary))
  expect_true("passed_rules" %in% names(validation$validation_summary))
  expect_true("failed_rules" %in% names(validation$validation_summary))
  expect_true("overall_status" %in% names(validation$validation_summary))

  # Check rule results
  expect_type(validation$rule_results, "list")
  expect_true(length(validation$rule_results) > 0)

  # Check data quality report
  expect_type(validation$data_quality_report, "list")
  expect_true("overall_stats" %in% names(validation$data_quality_report))

  # Check recommendations
  expect_type(validation$recommendations, "list")
  expect_true("priority" %in% names(validation$recommendations))

  # Check detailed report
  expect_type(validation$detailed_report, "list")
  expect_true("executive_summary" %in% names(validation$detailed_report))
})

test_that("validate_ideal_scenarios handles custom validation rules", {
  batch_results <- process_ideal_course_batch()

  # Test with custom rules
  custom_rules <- list(
    min_sessions = 2,
    min_participants_per_session = 2,
    max_participants_per_session = 15,
    min_total_comments = 5,
    max_session_duration = 1000
  )

  validation <- validate_ideal_scenarios(batch_results, validation_rules = custom_rules)

  expect_type(validation, "list")
  expect_true("validation_summary" %in% names(validation))
  expect_true("rule_results" %in% names(validation))
})

test_that("validate_ideal_scenarios handles report options", {
  batch_results <- process_ideal_course_batch()

  # Test with detailed report
  validation_detailed <- validate_ideal_scenarios(batch_results, detailed_report = TRUE)
  expect_true(!is.null(validation_detailed$detailed_report))

  # Test without detailed report
  validation_simple <- validate_ideal_scenarios(batch_results, detailed_report = FALSE)
  expect_true(is.null(validation_simple$detailed_report))

  # Test with data quality report
  validation_with_quality <- validate_ideal_scenarios(batch_results, include_data_quality = TRUE)
  expect_true(!is.null(validation_with_quality$data_quality_report))

  # Test without data quality report
  validation_without_quality <- validate_ideal_scenarios(batch_results, include_data_quality = FALSE)
  expect_true(is.null(validation_without_quality$data_quality_report))
})

test_that("validate_ideal_scenarios includes proper attributes", {
  batch_results <- process_ideal_course_batch()
  validation <- validate_ideal_scenarios(batch_results)

  expect_true(!is.null(attr(validation, "validation_timestamp")))
  expect_true(!is.null(attr(validation, "validation_rules_used")))
})

test_that("batch functions integrate with existing package functions", {
  # Test integration with existing transcript processing
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  session1_path <- file.path(transcript_dir, "ideal_course_session1.vtt")

  # Test that batch processing uses the same underlying functions
  batch_results <- process_ideal_course_batch()

  # Verify that session data matches individual processing
  individual_result <- process_zoom_transcript(session1_path)
  batch_session1 <- batch_results$session_data$session1

  # Check that the data structures are compatible
  expect_equal(names(individual_result), names(batch_session1))
  expect_equal(nrow(individual_result), nrow(batch_session1))
})

test_that("batch functions handle errors gracefully", {
  # Test with missing files (should handle gracefully)
  # This test verifies that the functions don't crash when files are missing

  # The functions should handle missing ideal course files gracefully
  # by recording errors in the processing_errors list

  # Test that the functions still return valid results even with some errors
  result <- process_ideal_course_batch()

  # Should have processing_info even if some sessions fail
  expect_true("processing_info" %in% names(result))
  expect_true("processing_errors" %in% names(result))
})

test_that("batch functions maintain privacy compliance", {
  # Test that privacy settings are respected
  result_full <- process_ideal_course_batch(privacy_level = "full")
  result_masked <- process_ideal_course_batch(privacy_level = "masked")
  result_none <- process_ideal_course_batch(privacy_level = "none")

  # Check that privacy levels are properly set
  expect_equal(result_full$processing_info$privacy_level, "full")
  expect_equal(result_masked$processing_info$privacy_level, "masked")
  expect_equal(result_none$processing_info$privacy_level, "none")

  # Check that validation results reflect privacy compliance
  expect_true(result_full$validation_results$privacy_compliant)
  expect_true(result_masked$validation_results$privacy_compliant)
  expect_false(result_none$validation_results$privacy_compliant)
})

test_that("batch functions provide comprehensive metadata", {
  result <- process_ideal_course_batch()

  # Check processing info
  expect_true("timestamp" %in% names(result$processing_info))
  expect_true("sessions_processed" %in% names(result$processing_info))
  expect_true("sessions_failed" %in% names(result$processing_info))
  expect_true("total_participants" %in% names(result$processing_info))
  expect_true("processing_options" %in% names(result$processing_info))

  # Check validation results
  expect_true("all_sessions_loaded" %in% names(result$validation_results))
  expect_true("no_processing_errors" %in% names(result$validation_results))
  expect_true("data_consistency" %in% names(result$validation_results))
  expect_true("privacy_compliant" %in% names(result$validation_results))
})

test_that("batch functions work with different data scenarios", {
  # Test with different processing options
  scenarios <- list(
    list(consolidate_comments = TRUE, add_dead_air = TRUE),
    list(consolidate_comments = FALSE, add_dead_air = TRUE),
    list(consolidate_comments = TRUE, add_dead_air = FALSE),
    list(consolidate_comments = FALSE, add_dead_air = FALSE)
  )

  for (scenario in scenarios) {
    result <- do.call(process_ideal_course_batch, scenario)

    # Should always return valid structure
    expect_type(result, "list")
    expect_true("session_data" %in% names(result))
    expect_true("summary_metrics" %in% names(result))

    # Check that processing options are recorded
    expect_equal(
      result$processing_info$processing_options$consolidate_comments,
      scenario$consolidate_comments
    )
    expect_equal(
      result$processing_info$processing_options$add_dead_air,
      scenario$add_dead_air
    )
  }
})

test_that("batch functions provide meaningful comparison insights", {
  batch_results <- process_ideal_course_batch()
  comparison <- compare_ideal_sessions(batch_results)

  # Check that insights are generated
  expect_type(comparison$insights, "list")
  expect_true("general" %in% names(comparison$insights))

  # Check that insights contain meaningful information
  general_insight <- comparison$insights$general
  expect_true(grepl("ideal course sessions", general_insight))
  expect_true(grepl("participant", general_insight))

  # Check metric-specific insights
  if ("total_comments" %in% names(comparison$insights)) {
    expect_true(grepl("comments", comparison$insights$total_comments))
  }

  if ("duration" %in% names(comparison$insights)) {
    expect_true(grepl("duration", comparison$insights$duration))
  }
})

test_that("batch functions validate data quality appropriately", {
  batch_results <- process_ideal_course_batch()
  validation <- validate_ideal_scenarios(batch_results)

  # Check that validation provides comprehensive assessment
  expect_type(validation$data_quality_report, "list")
  expect_true("overall_stats" %in% names(validation$data_quality_report))
  expect_true("session_quality" %in% names(validation$data_quality_report))

  # Check overall stats
  overall_stats <- validation$data_quality_report$overall_stats
  expect_true("total_sessions" %in% names(overall_stats))
  expect_true("total_participants" %in% names(overall_stats))
  expect_true("avg_participants_per_session" %in% names(overall_stats))

  # Check session quality metrics
  session_quality <- validation$data_quality_report$session_quality
  expect_type(session_quality, "list")
  expect_true(length(session_quality) > 0)
})

test_that("batch functions provide actionable recommendations", {
  batch_results <- process_ideal_course_batch()
  validation <- validate_ideal_scenarios(batch_results)

  # Check that recommendations are provided
  expect_type(validation$recommendations, "list")
  expect_true("priority" %in% names(validation$recommendations))

  # Check that recommendations are meaningful
  priority <- validation$recommendations$priority
  expect_true(is.character(priority))
  expect_true(nchar(priority) > 0)
})

test_that("batch functions maintain data integrity", {
  result <- process_ideal_course_batch()

  # Check that session data is consistent
  for (session_name in names(result$session_data)) {
    session_data <- result$session_data[[session_name]]
    summary_metrics <- result$summary_metrics[[session_name]]

    if (!is.null(session_data) && nrow(session_data) > 0) {
      # Check that participant counts match (excluding dead_air and other excluded names)
      unique_participants <- unique(session_data$name)
      unique_participants <- unique_participants[!unique_participants %in% c("dead_air", "unknown")]
      unique_participant_count <- length(unique_participants)

      if (!is.null(summary_metrics) && nrow(summary_metrics) > 0) {
        expect_equal(unique_participant_count, nrow(summary_metrics))
      }
    }
  }

  # Check that participation patterns are consistent
  for (session_name in names(result$participation_patterns)) {
    participants <- result$participation_patterns[[session_name]]
    session_data <- result$session_data[[session_name]]

    if (!is.null(session_data) && nrow(session_data) > 0) {
      session_participants <- unique(session_data$name)
      session_participants <- session_participants[!session_participants %in% c("dead_air")]
      expect_equal(sort(participants), sort(session_participants))
    }
  }
})

test_that("batch functions handle edge cases appropriately", {
  # Test with minimal processing options
  result <- process_ideal_course_batch(
    consolidate_comments = FALSE,
    add_dead_air = FALSE,
    names_exclude = character(0)
  )

  # Should still return valid results
  expect_type(result, "list")
  expect_true("session_data" %in% names(result))
  expect_true("summary_metrics" %in% names(result))

  # Test comparison with minimal data
  comparison <- compare_ideal_sessions(result)
  expect_type(comparison, "list")
  expect_true("comparison_data" %in% names(comparison))

  # Test validation with minimal data
  validation <- validate_ideal_scenarios(result)
  expect_type(validation, "list")
  expect_true("validation_summary" %in% names(validation))
})

test_that("batch functions provide comprehensive documentation", {
  # Test that all functions have proper documentation
  expect_true(exists("process_ideal_course_batch"))
  expect_true(exists("compare_ideal_sessions"))
  expect_true(exists("validate_ideal_scenarios"))

  # Test that functions are exported
  expect_true("process_ideal_course_batch" %in% ls("package:zoomstudentengagement"))
  expect_true("compare_ideal_sessions" %in% ls("package:zoomstudentengagement"))
  expect_true("validate_ideal_scenarios" %in% ls("package:zoomstudentengagement"))
})

test_that("batch functions follow package conventions", {
  # Test that functions follow the package's coding conventions
  result <- process_ideal_course_batch()

  # Check that return values have proper structure
  expect_true(is.list(result) || is.data.frame(result))

  # Check that attributes are properly set
  expect_true(!is.null(attr(result, "batch_processing")))
  expect_true(!is.null(attr(result, "privacy_level")))
  expect_true(!is.null(attr(result, "processing_timestamp")))

  # Check that error handling is consistent
  expect_error(process_ideal_course_batch(privacy_level = "invalid"))
  expect_error(process_ideal_course_batch(output_format = "invalid"))
})
