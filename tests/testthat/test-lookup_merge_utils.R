# Test file for lookup merge utility functions
# Tests for lookup_merge_utils functions

library(testthat)
library(engager)

# =============================================================================
# TEST DATA SETUP
# =============================================================================

# Create test lookup data
create_lookup_test_data <- function() {
  tibble::tibble(
    transcript_name = c("John Smith", "Jane Doe", "Bob Johnson"),
    preferred_name = c("John", "Jane", "Bob"),
    formal_name = c("John Smith", "Jane Doe", "Bob Johnson"),
    participant_type = c("enrolled_student", "enrolled_student", "instructor"),
    student_id = c("STU001", "STU002", "INSTRUCTOR"),
    notes = c("", "", "Primary instructor")
  )
}

# Create test lookup data with missing values
create_lookup_test_data_missing <- function() {
  tibble::tibble(
    transcript_name = c("John Smith", "Jane Doe", NA),
    preferred_name = c("John", NA, "Bob"),
    formal_name = c("John Smith", "Jane Doe", "Bob Johnson"),
    participant_type = c("enrolled_student", NA, "instructor"),
    student_id = c("STU001", "STU002", NA),
    notes = c("", "", "Primary instructor")
  )
}

# Create empty lookup data
create_empty_lookup_data <- function() {
  tibble::tibble(
    transcript_name = character(),
    preferred_name = character(),
    formal_name = character(),
    participant_type = character(),
    student_id = character(),
    notes = character()
  )
}

# =============================================================================
# TESTS FOR .lookup_expected_columns
# =============================================================================

test_that(".lookup_expected_columns returns expected columns", {
  result <- engager:::.lookup_expected_columns()
  
  # Should return character vector
  expect_true(is.character(result))
  expect_equal(length(result), 6)
  
  # Should contain expected columns
  expect_true("transcript_name" %in% result)
  expect_true("preferred_name" %in% result)
  expect_true("formal_name" %in% result)
  expect_true("participant_type" %in% result)
  expect_true("student_id" %in% result)
  expect_true("notes" %in% result)
})

# =============================================================================
# TESTS FOR .coerce_to_utf8
# =============================================================================

test_that(".coerce_to_utf8 handles NULL input", {
  result <- engager:::.coerce_to_utf8(NULL)
  expect_null(result)
})

test_that(".coerce_to_utf8 handles character input", {
  result <- engager:::.coerce_to_utf8("test string")
  expect_true(is.character(result))
  expect_equal(result, "test string")
})

test_that(".coerce_to_utf8 handles factor input", {
  result <- engager:::.coerce_to_utf8(factor("test"))
  expect_true(is.character(result))
  expect_equal(result, "test")
})

test_that(".coerce_to_utf8 handles non-character input", {
  result <- engager:::.coerce_to_utf8(123)
  expect_equal(result, 123)
})

# =============================================================================
# TESTS FOR .normalize_lookup_df
# =============================================================================

test_that(".normalize_lookup_df handles NULL input", {
  result <- engager:::.normalize_lookup_df(NULL)
  
  # Should return data frame with expected columns
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
  expect_true(all(engager:::.lookup_expected_columns() %in% names(result)))
})

test_that(".normalize_lookup_df handles data with missing columns", {
  data <- tibble::tibble(
    transcript_name = c("John", "Jane"),
    preferred_name = c("John", "Jane")
  )
  result <- engager:::.normalize_lookup_df(data)
  
  # Should add missing columns
  expect_true(all(engager:::.lookup_expected_columns() %in% names(result)))
  expect_equal(nrow(result), 2)
})

test_that(".normalize_lookup_df handles instructor student_id", {
  data <- tibble::tibble(
    transcript_name = c("John", "Jane"),
    preferred_name = c("John", "Jane"),
    formal_name = c("John Smith", "Jane Doe"),
    participant_type = c("instructor", "enrolled_student"),
    student_id = c(NA, "STU001"),
    notes = c("", "")
  )
  result <- engager:::.normalize_lookup_df(data)
  
  # Should set instructor student_id to "INSTRUCTOR"
  expect_equal(result$student_id[result$participant_type == "instructor"], "INSTRUCTOR")
  expect_equal(result$student_id[result$participant_type == "enrolled_student"], "STU001")
})

test_that(".normalize_lookup_df handles unknown participant_type", {
  data <- tibble::tibble(
    transcript_name = c("John", "Jane"),
    preferred_name = c("John", "Jane"),
    formal_name = c("John Smith", "Jane Doe"),
    participant_type = c(NA, "enrolled_student"),
    student_id = c("STU001", "STU002"),
    notes = c("", "")
  )
  result <- engager:::.normalize_lookup_df(data)
  
  # Should set NA participant_type to "unknown"
  expect_equal(result$participant_type[is.na(data$participant_type)], "unknown")
})

test_that(".normalize_lookup_df removes empty rows", {
  data <- tibble::tibble(
    transcript_name = c("John", "", NA),
    preferred_name = c("John", "", NA),
    formal_name = c("John Smith", "Jane Doe", "Bob Johnson"),
    participant_type = c("enrolled_student", "enrolled_student", "instructor"),
    student_id = c("STU001", "STU002", "INSTRUCTOR"),
    notes = c("", "", "Primary instructor")
  )
  result <- engager:::.normalize_lookup_df(data)
  
  # Should remove empty rows
  expect_equal(nrow(result), 1)
  expect_equal(result$transcript_name, "John")
})

# =============================================================================
# TESTS FOR read_lookup_safely
# =============================================================================

test_that("read_lookup_safely handles invalid path", {
  # Test with NULL path
  expect_error(engager:::read_lookup_safely(NULL))
  
  # Test with non-character path
  expect_error(engager:::read_lookup_safely(123))
  
  # Test with multiple paths
  expect_error(engager:::read_lookup_safely(c("path1", "path2")))
})

test_that("read_lookup_safely handles non-existent file", {
  result <- engager:::read_lookup_safely("/non/existent/path.csv")
  
  # Should return normalized empty data frame
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
  expect_true(all(engager:::.lookup_expected_columns() %in% names(result)))
})

test_that("read_lookup_safely handles existing file", {
  # Create temporary file
  temp_file <- tempfile(fileext = ".csv")
  test_data <- create_lookup_test_data()
  utils::write.csv(test_data, temp_file, row.names = FALSE)
  
  result <- engager:::read_lookup_safely(temp_file)
  
  # Should return normalized data
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), nrow(test_data))
  expect_true(all(engager:::.lookup_expected_columns() %in% names(result)))
  
  # Clean up
  unlink(temp_file)
})

# =============================================================================
# TESTS FOR merge_lookup_preserve
# =============================================================================

test_that("merge_lookup_preserve returns proper structure", {
  existing_data <- create_lookup_test_data()
  add_data <- create_lookup_test_data()
  
  result <- engager:::merge_lookup_preserve(existing_data, add_data)
  
  # Should return tibble with expected structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("transcript_name" %in% names(result))
  expect_true("participant_type" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true("formal_name" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true("course_section" %in% names(result))
  expect_true("dept" %in% names(result))
  expect_true("course" %in% names(result))
  expect_true("instructor" %in% names(result))
})

test_that("merge_lookup_preserve handles NULL inputs", {
  result <- engager:::merge_lookup_preserve(NULL, NULL)
  
  # Should return empty tibble with proper structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c("transcript_name", "participant_type", "preferred_name", 
                   "formal_name", "student_id", "course_section", "dept", 
                   "course", "instructor") %in% names(result)))
})

# =============================================================================
# TESTS FOR write_lookup_transactional
# =============================================================================

test_that("write_lookup_transactional handles invalid path", {
  data <- create_lookup_test_data()
  
  # Test with NULL path
  expect_error(engager:::write_lookup_transactional(data, NULL))
  
  # Test with non-character path
  expect_error(engager:::write_lookup_transactional(data, 123))
  
  # Test with multiple paths
  expect_error(engager:::write_lookup_transactional(data, c("path1", "path2")))
})

test_that("write_lookup_transactional handles valid data", {
  data <- create_lookup_test_data()
  temp_file <- tempfile(fileext = ".csv")
  
  result <- engager:::write_lookup_transactional(data, temp_file)
  
  # Should return path invisibly
  expect_equal(result, temp_file)
  expect_true(file.exists(temp_file))
  
  # Should write data correctly
  written_data <- utils::read.csv(temp_file, stringsAsFactors = FALSE)
  expect_equal(nrow(written_data), nrow(data))
  
  # Clean up
  unlink(temp_file)
})

test_that("write_lookup_transactional handles backup creation", {
  data <- create_lookup_test_data()
  temp_file <- tempfile(fileext = ".csv")
  
  # Write initial file
  utils::write.csv(data, temp_file, row.names = FALSE)
  
  # Write again (should create backup)
  result <- engager:::write_lookup_transactional(data, temp_file)
  
  # Should return path invisibly
  expect_equal(result, temp_file)
  expect_true(file.exists(temp_file))
  
  # Clean up
  unlink(temp_file)
  unlink(paste0(temp_file, ".backup.*"))
})

# =============================================================================
# TESTS FOR conditionally_write_lookup
# =============================================================================

test_that("conditionally_write_lookup handles allow_write = FALSE", {
  data <- create_lookup_test_data()
  temp_file <- tempfile(fileext = ".csv")
  
  result <- engager:::conditionally_write_lookup(data, temp_file, allow_write = FALSE)
  
  # Should return FALSE and not write file
  expect_false(result)
  expect_false(file.exists(temp_file))
})

test_that("conditionally_write_lookup handles allow_write = TRUE", {
  data <- create_lookup_test_data()
  temp_file <- tempfile(fileext = ".csv")
  
  result <- engager:::conditionally_write_lookup(data, temp_file, allow_write = TRUE)
  
  # Should return TRUE and write file
  expect_true(result)
  expect_true(file.exists(temp_file))
  
  # Clean up
  unlink(temp_file)
})

# =============================================================================
# TESTS FOR ensure_instructor_rows
# =============================================================================

test_that("ensure_instructor_rows handles invalid instructor_name", {
  data <- create_lookup_test_data()
  
  # Test with NULL instructor_name
  expect_error(engager:::ensure_instructor_rows(data, NULL))
  
  # Test with non-character instructor_name
  expect_error(engager:::ensure_instructor_rows(data, 123))
  
  # Test with multiple instructor names
  expect_error(engager:::ensure_instructor_rows(data, c("John", "Jane")))
})

test_that("ensure_instructor_rows handles valid instructor_name", {
  data <- create_lookup_test_data()
  
  result <- engager:::ensure_instructor_rows(data, "Dr. Smith")
  
  # Should return tibble with proper structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c("transcript_name", "participant_type", "preferred_name", 
                   "formal_name", "student_id", "course_section", "dept", 
                   "course", "instructor") %in% names(result)))
})

test_that("ensure_instructor_rows handles NULL existing data", {
  result <- engager:::ensure_instructor_rows(NULL, "Dr. Smith")
  
  # Should return tibble with proper structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c("transcript_name", "participant_type", "preferred_name", 
                   "formal_name", "student_id", "course_section", "dept", 
                   "course", "instructor") %in% names(result)))
})

# =============================================================================
# COMPREHENSIVE PARAMETER TESTING
# =============================================================================

test_that("lookup_merge_utils functions handle comprehensive parameters", {
  # Test .normalize_lookup_df with various inputs
  test_inputs <- list(
    NULL,
    tibble::tibble(),
    create_lookup_test_data(),
    create_lookup_test_data_missing(),
    create_empty_lookup_data()
  )
  
  for (input in test_inputs) {
    result <- engager:::.normalize_lookup_df(input)
    expect_true(is.data.frame(result))
    expect_true(all(engager:::.lookup_expected_columns() %in% names(result)))
  }
})

test_that("lookup_merge_utils functions handle edge cases", {
  # Test with empty data
  empty_data <- create_empty_lookup_data()
  result <- engager:::.normalize_lookup_df(empty_data)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
  
  # Test with single row
  single_row <- create_lookup_test_data()[1, ]
  result <- engager:::.normalize_lookup_df(single_row)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 1)
  
  # Test with missing values
  missing_data <- create_lookup_test_data_missing()
  result <- engager:::.normalize_lookup_df(missing_data)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 3)
})

# =============================================================================
# ERROR HANDLING TESTING
# =============================================================================

test_that("lookup_merge_utils functions handle errors gracefully", {
  # Test .coerce_to_utf8 with various inputs
  expect_equal(engager:::.coerce_to_utf8(NULL), NULL)
  expect_equal(engager:::.coerce_to_utf8("test"), "test")
  expect_equal(engager:::.coerce_to_utf8(123), 123)
  
  # Test .normalize_lookup_df with various inputs
  expect_true(is.data.frame(engager:::.normalize_lookup_df(NULL)))
  expect_true(is.data.frame(engager:::.normalize_lookup_df(tibble::tibble())))
  
  # Test read_lookup_safely with invalid paths
  expect_error(engager:::read_lookup_safely(NULL))
  expect_error(engager:::read_lookup_safely(123))
  expect_error(engager:::read_lookup_safely(c("path1", "path2")))
  
  # Test write_lookup_transactional with invalid paths
  data <- create_lookup_test_data()
  expect_error(engager:::write_lookup_transactional(data, NULL))
  expect_error(engager:::write_lookup_transactional(data, 123))
  expect_error(engager:::write_lookup_transactional(data, c("path1", "path2")))
  
  # Test ensure_instructor_rows with invalid instructor names
  expect_error(engager:::ensure_instructor_rows(data, NULL))
  expect_error(engager:::ensure_instructor_rows(data, 123))
  expect_error(engager:::ensure_instructor_rows(data, c("John", "Jane")))
})
