# Test file for ideal transcript validation functions
# Tests for validation functions and quality checks

library(testthat)
library(zoomstudentengagement)

# Test data setup
test_that("validation functions can be loaded", {
  expect_true(exists("validate_ideal_transcript_structure"))
  expect_true(exists("validate_ideal_content_quality"))
  expect_true(exists("validate_ideal_timing_consistency"))
  expect_true(exists("validate_ideal_name_coverage"))
  expect_true(exists("validate_ideal_transcript_comprehensive"))
})

# Test structure validation
test_that("structure validation catches format errors", {
  # Test with valid data
  valid_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith", "Dr. Brown", "Guest Speaker"),
    comment = c("Welcome to class", "Hello everyone", "Good morning", "Thank you", "Excellent point"),
    start = c(0, 5, 10, 15, 20),
    end = c(2, 7, 12, 17, 22),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = valid_data)
  expect_equal(result$status, "PASS")

  # Test with missing columns
  invalid_data <- data.frame(
    name = c("Professor Ed"),
    comment = c("Welcome to class"),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = invalid_data)
  expect_equal(result$status, "FAIL")
  expect_true("missing_columns" %in% names(result$issues))

  # Test with empty data
  empty_data <- data.frame(
    name = character(0),
    comment = character(0),
    start = numeric(0),
    end = numeric(0),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = empty_data)
  expect_equal(result$status, "FAIL")
  expect_true("empty_data" %in% names(result$issues))

  # Test with very few rows
  few_rows_data <- data.frame(
    name = c("Professor Ed"),
    comment = c("Welcome"),
    start = c(0),
    end = c(2),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = few_rows_data)
  expect_equal(result$status, "WARN")
  expect_true("few_rows" %in% names(result$warnings))
})

test_that("structure validation handles file paths", {
  # Test with non-existent file
  result <- validate_ideal_transcript_structure(file_path = "nonexistent.vtt")
  expect_equal(result$status, "FAIL")
  expect_true("file_not_found" %in% names(result$issues))

  # Test with valid file path (using existing ideal course transcript)
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  valid_file <- file.path(transcript_dir, "ideal_course_session1.vtt")

  if (file.exists(valid_file)) {
    result <- validate_ideal_transcript_structure(file_path = valid_file)
    expect_true(result$status %in% c("PASS", "WARN"))
  }
})

test_that("structure validation checks required fields", {
  # Test with empty names
  data_with_empty_names <- data.frame(
    name = c("Professor Ed", "", "Tom Miller"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 2, 5),
    end = c(2, 4, 7),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = data_with_empty_names)
  expect_equal(result$status, "FAIL")
  expect_true("empty_names" %in% names(result$issues))

  # Test with empty comments (should be warning, not error)
  data_with_empty_comments <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "", "Hi"),
    start = c(0, 2, 5),
    end = c(2, 4, 7),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = data_with_empty_comments)
  expect_equal(result$status, "WARN")
  expect_true("empty_comments" %in% names(result$warnings))
})

# Test content quality validation
test_that("content quality checks verify realism", {
  # Test with good quality data
  good_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c(
      "Welcome to our discussion about student engagement",
      "I have a question about the analysis",
      "This is very helpful for understanding participation"
    ),
    start = c(0, 5, 10),
    end = c(3, 8, 13),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_content_quality(good_data)
  expect_equal(result$status, "PASS")
  expect_true("quality_score" %in% names(result))
  expect_true(result$quality_score > 0.5)

  # Test with poor quality data (very short comments)
  poor_data <- data.frame(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Hi", "Ok"),
    start = c(0, 2),
    end = c(1, 3),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_content_quality(poor_data)
  expect_equal(result$status, "WARN")
  expect_true("very_short_comments" %in% names(result$warnings))

  # Test with very long comments
  long_comment_data <- data.frame(
    name = c("Professor Ed"),
    comment = c(paste(rep("This is a very long comment that goes on and on ", 20), collapse = "")),
    start = c(0),
    end = c(5),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_content_quality(long_comment_data)
  expect_equal(result$status, "WARN")
  expect_true("very_long_comments" %in% names(result$warnings))
})

test_that("content quality validation calculates metrics correctly", {
  test_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome to class", "Hello everyone", "Good morning"),
    start = c(0, 2, 4),
    end = c(2, 4, 6),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_content_quality(test_data)

  expect_true("quality_metrics" %in% names(result))
  metrics <- result$quality_metrics

  expect_equal(metrics$total_entries, 3)
  expect_equal(metrics$unique_speakers, 3)
  expect_true(metrics$avg_comment_length > 0)
  expect_true(metrics$min_comment_length > 0)
  expect_true(metrics$max_comment_length > 0)
})

test_that("content quality validation checks diversity", {
  # Test with diverse content
  diverse_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome to our discussion about student engagement", "I have a question about the analysis", "This helps me understand the topic better"),
    start = c(0, 2, 4),
    end = c(2, 4, 6),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_content_quality(diverse_data)
  expect_equal(result$status, "PASS")

  # Test with low diversity (duplicate comments)
  low_diversity_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Hello", "Hello", "Hello"),
    start = c(0, 2, 4),
    end = c(2, 4, 6),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_content_quality(low_diversity_data)
  expect_equal(result$status, "WARN")
  expect_true("low_diversity" %in% names(result$warnings))
})

# Test timing validation
test_that("timing validation ensures logical consistency", {
  # Test with valid timing
  valid_timing_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 5, 10),
    end = c(3, 8, 13),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_timing_consistency(valid_timing_data)
  expect_equal(result$status, "PASS")

  # Test with non-chronological order
  non_chronological_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(10, 5, 0), # Not in chronological order
    end = c(13, 8, 3),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_timing_consistency(non_chronological_data)
  expect_equal(result$status, "FAIL")
  expect_true("non_chronological" %in% names(result$issues))

  # Test with overlapping timestamps
  overlapping_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 2, 4),
    end = c(5, 7, 9), # End time of first > start time of second
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_timing_consistency(overlapping_data)
  expect_equal(result$status, "FAIL")
  expect_true("overlaps" %in% names(result$issues))

  # Test with negative durations
  negative_duration_data <- data.frame(
    name = c("Professor Ed", "Tom Miller"),
    comment = c("Welcome", "Hello"),
    start = c(5, 10),
    end = c(3, 8), # End < start
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_timing_consistency(negative_duration_data)
  expect_equal(result$status, "FAIL")
  expect_true("negative_durations" %in% names(result$issues))

  # Test with large gaps
  large_gap_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 600, 1200), # Large gaps (600s and 600s)
    end = c(200, 800, 1400),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_timing_consistency(large_gap_data, max_gap_seconds = 300)
  expect_equal(result$status, "WARN")
  expect_true("large_gaps" %in% names(result$warnings))
})

test_that("timing validation analyzes patterns correctly", {
  test_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 5, 10),
    end = c(3, 8, 13),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_timing_consistency(test_data)

  expect_true("timing_analysis" %in% names(result))
  analysis <- result$timing_analysis

  expect_true(analysis$total_duration > 0)
  expect_true(analysis$avg_entry_duration > 0)
  expect_equal(analysis$total_entries, 3)
  expect_true(analysis$entries_per_minute > 0)
})

# Test name coverage validation
test_that("name coverage validation confirms all scenarios", {
  # Test with comprehensive name coverage
  comprehensive_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith", "José García", "Dr. Wei Chen"),
    comment = c("Welcome", "Hello", "Hi", "Good morning", "Thank you"),
    start = c(0, 2, 4, 6, 8),
    end = c(1, 3, 5, 7, 9),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_name_coverage(comprehensive_data)
  expect_equal(result$status, "PASS")

  # Test with expected names
  expected_names <- c("Professor Ed", "Tom Miller", "Samantha Smith", "José García", "Dr. Wei Chen")
  result <- validate_ideal_name_coverage(comprehensive_data, expected_names = expected_names)
  expect_equal(result$status, "PASS")

  # Test with missing expected names
  missing_names <- c("Professor Ed", "Tom Miller", "Missing Person")
  result <- validate_ideal_name_coverage(comprehensive_data, expected_names = missing_names)
  expect_equal(result$status, "FAIL")
  expect_true("missing_expected_names" %in% names(result$issues))

  # Test with no name variations
  no_variations_data <- data.frame(
    name = c("Ed", "Tom", "Sam"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 2, 4),
    end = c(1, 3, 5),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_name_coverage(no_variations_data)
  expect_equal(result$status, "WARN")
  expect_true("no_name_variations" %in% names(result$warnings))

  # Test with no edge cases
  no_edge_cases_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome", "Hello", "Hi"),
    start = c(0, 2, 4),
    end = c(1, 3, 5),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_name_coverage(no_edge_cases_data)
  expect_equal(result$status, "WARN")
  expect_true("no_edge_cases" %in% names(result$warnings))
})

test_that("name coverage validation analyzes patterns correctly", {
  test_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith", "Professor Ed"),
    comment = c("Welcome", "Hello", "Hi", "Goodbye"),
    start = c(0, 2, 4, 6),
    end = c(1, 3, 5, 7),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_name_coverage(test_data)

  expect_true("coverage_analysis" %in% names(result))
  analysis <- result$coverage_analysis

  expect_equal(analysis$total_unique_names, 3) # "Professor Ed" appears twice
  expect_equal(length(analysis$unique_names), 3)
  expect_true("Professor Ed" %in% analysis$unique_names)
  expect_true("Tom Miller" %in% analysis$unique_names)
  expect_true("Samantha Smith" %in% analysis$unique_names)
  expect_true(analysis$avg_name_length > 0)
})

# Test comprehensive validation
test_that("comprehensive validation combines all checks", {
  # Test with good data
  good_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c(
      "Welcome to our discussion about student engagement",
      "I have a question about the analysis",
      "This is very helpful for understanding participation"
    ),
    start = c(0, 5, 10),
    end = c(3, 8, 13),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_comprehensive(transcript_data = good_data)
  expect_true("overall_status" %in% names(result))
  expect_true("validation_results" %in% names(result))
  expect_true("summary" %in% names(result))
  expect_true("recommendations" %in% names(result))

  # Check that all validation types are included
  validation_types <- c("structure", "content_quality", "timing_consistency", "name_coverage")
  expect_true(all(validation_types %in% names(result$validation_results)))

  # Test with custom options
  custom_options <- list(
    strict_mode = FALSE,
    quality_threshold = 0.5,
    check_realism = FALSE,
    max_gap_seconds = 600,
    check_overlaps = FALSE,
    check_variations = FALSE,
    check_edge_cases = FALSE
  )

  result <- validate_ideal_transcript_comprehensive(
    transcript_data = good_data,
    validation_options = custom_options
  )
  expect_true("overall_status" %in% names(result))
})

test_that("comprehensive validation handles file paths", {
  # Test with non-existent file
  result <- validate_ideal_transcript_comprehensive(file_path = "nonexistent.vtt")
  expect_equal(result$overall_status, "FAIL")
  expect_true("file_error" %in% names(result$validation_results))

  # Test with valid file path
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  valid_file <- file.path(transcript_dir, "ideal_course_session1.vtt")

  if (file.exists(valid_file)) {
    result <- validate_ideal_transcript_comprehensive(file_path = valid_file)
    expect_true(result$overall_status %in% c("PASS", "WARN"))
  }
})

test_that("comprehensive validation generates detailed reports", {
  test_data <- data.frame(
    name = c("Professor Ed", "Tom Miller", "Samantha Smith"),
    comment = c("Welcome to class", "Hello everyone", "Good morning"),
    start = c(0, 5, 10),
    end = c(3, 8, 13),
    stringsAsFactors = FALSE
  )

  # Test with detailed report
  result <- validate_ideal_transcript_comprehensive(
    transcript_data = test_data,
    detailed_report = TRUE
  )
  expect_true("detailed_report" %in% names(result))
  expect_true(!is.null(result$detailed_report))

  # Test without detailed report
  result <- validate_ideal_transcript_comprehensive(
    transcript_data = test_data,
    detailed_report = FALSE
  )
  expect_true("detailed_report" %in% names(result))
  expect_true(is.null(result$detailed_report))
})

# Test edge cases and error handling
test_that("validation functions handle edge cases gracefully", {
  # Test with NULL input
  expect_error(validate_ideal_transcript_structure())
  expect_error(validate_ideal_content_quality(NULL))
  expect_error(validate_ideal_timing_consistency(NULL))
  expect_error(validate_ideal_name_coverage(NULL))

  # Test with invalid data types
  expect_error(validate_ideal_transcript_structure(transcript_data = "not a data frame"))
  expect_error(validate_ideal_content_quality("not a data frame"))
  expect_error(validate_ideal_timing_consistency("not a data frame"))
  expect_error(validate_ideal_name_coverage("not a data frame"))

  # Test with data frame but wrong structure
  wrong_structure_data <- data.frame(
    wrong_column = c("value1", "value2"),
    another_wrong_column = c(1, 2),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = wrong_structure_data)
  expect_equal(result$status, "FAIL")
  expect_true("missing_columns" %in% names(result$issues))
})

test_that("validation functions provide meaningful recommendations", {
  # Test with problematic data that should generate recommendations
  problematic_data <- data.frame(
    name = c("Professor Ed", "", "Tom Miller"),
    comment = c("Hi", "Hello", "Hi"), # Duplicate content
    start = c(0, 2, 4),
    end = c(2, 4, 6),
    stringsAsFactors = FALSE
  )

  result <- validate_ideal_transcript_structure(transcript_data = problematic_data)
  expect_true("recommendations" %in% names(result))
  expect_true(length(result$recommendations) > 0)

  result <- validate_ideal_content_quality(problematic_data)
  expect_true("recommendations" %in% names(result))
  expect_true(length(result$recommendations) > 0)

  result <- validate_ideal_name_coverage(problematic_data)
  expect_true("recommendations" %in% names(result))
  expect_true(length(result$recommendations) > 0)
})

# Test performance with larger datasets
test_that("validation functions handle larger datasets efficiently", {
  # Create larger test dataset
  n_entries <- 100
  large_data <- data.frame(
    name = rep(c("Professor Ed", "Tom Miller", "Samantha Smith"), length.out = n_entries),
    comment = paste("Comment", 1:n_entries),
    start = seq(0, by = 5, length.out = n_entries),
    end = seq(3, by = 5, length.out = n_entries),
    stringsAsFactors = FALSE
  )

  # Test that all validation functions complete without errors
  expect_no_error(validate_ideal_transcript_structure(transcript_data = large_data))
  expect_no_error(validate_ideal_content_quality(large_data))
  expect_no_error(validate_ideal_timing_consistency(large_data))
  expect_no_error(validate_ideal_name_coverage(large_data))
  expect_no_error(validate_ideal_transcript_comprehensive(transcript_data = large_data))
})

# Test integration with existing ideal course transcripts
test_that("validation functions work with existing ideal course transcripts", {
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")

  # Test with session 1
  session1_file <- file.path(transcript_dir, "ideal_course_session1.vtt")
  if (file.exists(session1_file)) {
    session1_data <- load_zoom_transcript(session1_file)

    # Test all validation functions
    expect_no_error(validate_ideal_transcript_structure(transcript_data = session1_data))
    expect_no_error(validate_ideal_content_quality(session1_data))
    expect_no_error(validate_ideal_timing_consistency(session1_data))
    expect_no_error(validate_ideal_name_coverage(session1_data))
    expect_no_error(validate_ideal_transcript_comprehensive(transcript_data = session1_data))
  }

  # Test with session 2
  session2_file <- file.path(transcript_dir, "ideal_course_session2.vtt")
  if (file.exists(session2_file)) {
    session2_data <- load_zoom_transcript(session2_file)

    # Test all validation functions
    expect_no_error(validate_ideal_transcript_structure(transcript_data = session2_data))
    expect_no_error(validate_ideal_content_quality(session2_data))
    expect_no_error(validate_ideal_timing_consistency(session2_data))
    expect_no_error(validate_ideal_name_coverage(session2_data))
    expect_no_error(validate_ideal_transcript_comprehensive(transcript_data = session2_data))
  }

  # Test with session 3
  session3_file <- file.path(transcript_dir, "ideal_course_session3.vtt")
  if (file.exists(session3_file)) {
    session3_data <- load_zoom_transcript(session3_file)

    # Test all validation functions
    expect_no_error(validate_ideal_transcript_structure(transcript_data = session3_data))
    expect_no_error(validate_ideal_content_quality(session3_data))
    expect_no_error(validate_ideal_timing_consistency(session3_data))
    expect_no_error(validate_ideal_name_coverage(session3_data))
    expect_no_error(validate_ideal_transcript_comprehensive(transcript_data = session3_data))
  }
})
