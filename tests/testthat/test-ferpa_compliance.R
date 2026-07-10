# Test file for privacy review functions
# Tests for review_privacy_risks, anonymize_educational_data, and related functions

library(testthat)
library(engager)

# Load test data patterns
# source("../../test_data_patterns.R")
# source("../../validation_patterns.R")
# source("../../parameter_testing_patterns.R")

# =============================================================================
# TEST DATA SETUP
# =============================================================================

# Create test data with PII
create_ferpa_test_data_with_pii <- function() {
  tibble::tibble(
    student_id = c("STU001", "STU002", "STU003"),
    preferred_name = c("John Doe", "Jane Smith", "Bob Johnson"),
    email = c("john@university.edu", "jane@university.edu", "bob@university.edu"),
    course = c("MATH101", "MATH101", "MATH102"),
    section = c("A", "A", "B"),
    participation_data = c("high", "medium", "low")
  )
}

# Create test data without PII
create_ferpa_test_data_without_pii <- function() {
  tibble::tibble(
    course = c("MATH101", "MATH101", "MATH102"),
    section = c("A", "A", "B"),
    participation_data = c("high", "medium", "low"),
    score = c(85, 92, 78)
  )
}

# =============================================================================
# TESTS FOR review_privacy_risks
# =============================================================================

test_that("review_privacy_risks returns proper structure", {
  data <- create_ferpa_test_data_with_pii()
  result <- review_privacy_risks(data)

  # Validate structure
  expect_true(is.list(result))
  expect_true("passed" %in% names(result))
  expect_true("pii_detected" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("retention_check" %in% names(result))
  expect_true("institution_guidance" %in% names(result))
})

test_that("review_privacy_risks detects PII correctly", {
  data <- create_ferpa_test_data_with_pii()
  result <- review_privacy_risks(data)

  # Should detect PII
  expect_false(result$passed)
  expect_true(length(result$pii_detected) > 0)
  expect_true("student_id" %in% result$pii_detected)
  expect_true("preferred_name" %in% result$pii_detected)
  expect_true("email" %in% result$pii_detected)
})

test_that("review_privacy_risks handles data without PII", {
  data <- create_ferpa_test_data_without_pii()
  result <- review_privacy_risks(data)

  # Should pass the technical privacy review
  expect_true(result$passed)
  expect_equal(length(result$pii_detected), 0)
})

test_that("review_privacy_risks handles different institution types", {
  data <- create_ferpa_test_data_with_pii()

  # Test educational institution
  result_edu <- review_privacy_risks(data, institution_type = "educational")
  expect_true("Consider reviewing applicable student-record privacy requirements" %in% result_edu$institution_guidance)

  # Test research institution
  result_research <- review_privacy_risks(data, institution_type = "research")
  expect_true("Research institutions should follow IRB guidelines" %in% result_research$institution_guidance)

  # Test mixed institution
  result_mixed <- review_privacy_risks(data, institution_type = "mixed")
  expect_true("Mixed institutions should review both student-record privacy and research ethics requirements" %in% result_mixed$institution_guidance)
})

test_that("review_privacy_risks handles different retention periods", {
  data <- create_ferpa_test_data_with_pii()

  # Test academic year
  result_ay <- review_privacy_risks(data, retention_period = "academic_year")
  expect_true(is.list(result_ay$retention_check))

  # Test semester
  result_sem <- review_privacy_risks(data, retention_period = "semester")
  expect_true(is.list(result_sem$retention_check))

  # Test quarter
  result_qtr <- review_privacy_risks(data, retention_period = "quarter")
  expect_true(is.list(result_qtr$retention_check))

  # Test custom
  result_custom <- review_privacy_risks(data, retention_period = "custom", custom_retention_days = 100)
  expect_true(is.list(result_custom$retention_check))
})

test_that("review_privacy_risks handles invalid data", {
  # Test with NULL data
  expect_error(review_privacy_risks(NULL))

  # Test with non-data.frame
  expect_error(review_privacy_risks("not a data frame"))
  expect_error(review_privacy_risks(123))
  expect_error(review_privacy_risks(list()))
})

test_that("review_privacy_risks provides appropriate recommendations", {
  data <- create_ferpa_test_data_with_pii()
  result <- review_privacy_risks(data)

  # Should have recommendations
  expect_true(length(result$recommendations) > 0)
  expect_true(any(grepl("PII detected", result$recommendations)))
  expect_true(any(grepl("ensure_privacy", result$recommendations)))
  expect_true(any(grepl("institutional privacy policies", result$recommendations)))
})

# =============================================================================
# TESTS FOR anonymize_educational_data
# =============================================================================

test_that("anonymize_educational_data returns proper structure", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data)

  # Validate structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_true("privacy_applied" %in% names(attributes(result)))
  expect_true("anonymization_method" %in% names(attributes(result)))
  expect_true("anonymized_columns" %in% names(attributes(result)))
  expect_true("anonymization_timestamp" %in% names(attributes(result)))
})

test_that("anonymize_educational_data handles mask method", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data, method = "mask")

  # Should mask PII columns
  expect_true(all(grepl("^Student_", result$student_id)))
  expect_true(all(grepl("^Student_", result$preferred_name)))
  expect_true(all(grepl("^Student_", result$email)))

  # Should preserve non-PII columns
  expect_equal(result$course, data$course)
  expect_equal(result$section, data$section)
  expect_equal(result$participation_data, data$participation_data)
})

test_that("anonymize_educational_data maps repeated identifiers consistently", {
  data <- tibble::tibble(
    student_id = c("S1", "S2", "S1"),
    preferred_name = c("Alice", "Bob", "Alice")
  )
  result <- anonymize_educational_data(data, method = "mask")

  expect_identical(result$student_id[[1]], result$student_id[[3]])
  expect_identical(result$preferred_name[[1]], result$preferred_name[[3]])
  expect_false(identical(result$student_id[[1]], result$student_id[[2]]))
})

test_that("anonymize_educational_data handles hash method", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data, method = "hash", hash_salt = "test_salt")

  # Should hash PII columns
  expect_true(all(nchar(result$student_id) == 8))
  expect_true(all(nchar(result$preferred_name) == 8))
  expect_true(all(nchar(result$email) == 8))
  expect_identical(
    result$student_id[[1]],
    substr(digest::digest(
      paste0(data$student_id[[1]], "test_salt"),
      algo = "sha256",
      serialize = FALSE
    ), 1, 8)
  )

  # Should preserve non-PII columns
  expect_equal(result$course, data$course)
  expect_equal(result$section, data$section)
  expect_equal(result$participation_data, data$participation_data)
})

test_that("anonymize_educational_data requires an explicit hash salt", {
  data <- create_ferpa_test_data_with_pii()
  expect_error(
    anonymize_educational_data(data, method = "hash"),
    "hash_salt must be one non-empty character value"
  )
  expect_error(
    anonymize_educational_data(data, method = "hash", hash_salt = "  "),
    "hash_salt must be one non-empty character value"
  )
})

test_that("anonymize_educational_data handles pseudonymize method", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data, method = "pseudonymize")

  # Should pseudonymize PII columns
  expect_true(all(grepl("^PSEUDO_", result$student_id)))
  expect_true(all(grepl("^PSEUDO_", result$preferred_name)))
  expect_true(all(grepl("^PSEUDO_", result$email)))

  # Should preserve non-PII columns
  expect_equal(result$course, data$course)
  expect_equal(result$section, data$section)
  expect_equal(result$participation_data, data$participation_data)
})

test_that("anonymize_educational_data rejects unsafe aggregate method", {
  data <- tibble::tibble(
    section = c("A", "A", "B", "B"),
    student_id = c("S1", "S2", "S3", "S4"),
    participation_data = c(10, 15, 20, 25)
  )

  expect_error(
    anonymize_educational_data(data, method = "aggregate", aggregation_level = "section"),
    "not supported in engager 0.1.0"
  )
})

test_that("anonymize_educational_data handles preserve_columns", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data, method = "mask", preserve_columns = "student_id")

  # Should preserve student_id
  expect_equal(result$student_id, data$student_id)

  # Should mask other PII columns
  expect_true(all(grepl("^Student_", result$preferred_name)))
  expect_true(all(grepl("^Student_", result$email)))
})

test_that("anonymize_educational_data preserves missing and blank identifiers", {
  data <- tibble::tibble(
    student_id = c("S1", NA_character_, ""),
    preferred_name = c("Alice", NA_character_, "  "),
    score = c(1, 2, 3)
  )

  results <- list(
    anonymize_educational_data(data, method = "mask"),
    anonymize_educational_data(data, method = "hash", hash_salt = "test-salt"),
    anonymize_educational_data(data, method = "pseudonymize")
  )

  for (result in results) {
    expect_true(is.na(result$student_id[[2]]))
    expect_identical(result$student_id[[3]], "")
    expect_true(is.na(result$preferred_name[[2]]))
    expect_identical(result$preferred_name[[3]], "  ")
    expect_equal(result$score, data$score)
  }
})

test_that("anonymize_educational_data handles invalid method argument", {
  data <- create_ferpa_test_data_with_pii()
  expect_error(anonymize_educational_data(data, method = "invalid"))
})

test_that("anonymize_educational_data handles data without PII", {
  data <- create_ferpa_test_data_without_pii()
  result <- anonymize_educational_data(data)

  # Should return data unchanged
  expect_equal(result, data)
})

test_that("anonymize_educational_data preserves columns and metadata", {
  data <- create_ferpa_test_data_with_pii()
  res <- anonymize_educational_data(data, method = "mask", preserve_columns = c("student_id"))
  expect_equal(res$student_id, data$student_id)
  expect_true(attr(res, "privacy_applied"))
  expect_true(!is.null(attr(res, "anonymization_method")))
  expect_true("student_id" %in% attr(res, "anonymized_columns") || is.character(attr(res, "anonymized_columns")))
})

test_that("anonymize_educational_data handles invalid data", {
  # Test with NULL data
  expect_error(anonymize_educational_data(NULL))

  # Test with non-data.frame
  expect_error(anonymize_educational_data("not a data frame"))
  expect_error(anonymize_educational_data(123))
  expect_error(anonymize_educational_data(list()))
})

# =============================================================================
# TESTS FOR check_data_retention_policy
# =============================================================================

test_that("check_data_retention_policy returns proper structure", {
  data <- create_ferpa_test_data_with_pii()
  result <- check_data_retention_policy(data)

  # Validate structure
  expect_true(is.list(result))
  expect_true("passed" %in% names(result))
  expect_true("compliant" %in% names(result))
  expect_true("retention_period_days" %in% names(result))
  expect_true("data_to_dispose" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_identical(result$passed, result$compliant)
})

test_that("check_data_retention_policy handles different retention periods", {
  data <- create_ferpa_test_data_with_pii()

  # Test academic year
  result_ay <- check_data_retention_policy(data, retention_period = "academic_year")
  expect_equal(result_ay$retention_period_days, 365)

  # Test semester
  result_sem <- check_data_retention_policy(data, retention_period = "semester")
  expect_equal(result_sem$retention_period_days, 180)

  # Test quarter
  result_qtr <- check_data_retention_policy(data, retention_period = "quarter")
  expect_equal(result_qtr$retention_period_days, 90)

  # Test custom
  result_custom <- check_data_retention_policy(data, retention_period = "custom", custom_retention_days = 100)
  expect_equal(result_custom$retention_period_days, 100)
})

test_that("check_data_retention_policy keeps passed and compliant aliases synchronized", {
  data <- tibble::tibble(
    student_id = c("12345", "67890"),
    session_date = as.Date(c("2020-01-15", "2025-02-20"))
  )

  result <- check_data_retention_policy(
    data,
    retention_period = "academic_year",
    date_column = "session_date",
    current_date = as.Date("2025-03-01")
  )

  expect_false(result$passed)
  expect_false(result$compliant)
  expect_identical(result$passed, result$compliant)
})

test_that("check_data_retention_policy handles invalid data", {
  # Test with NULL data
  expect_error(check_data_retention_policy(NULL))

  # Test with non-data.frame
  expect_error(check_data_retention_policy("not a data frame"))
  expect_error(check_data_retention_policy(123))
  expect_error(check_data_retention_policy(list()))
})

# =============================================================================
# TESTS FOR generate_privacy_review_report
# =============================================================================

test_that("generate_privacy_review_report returns proper structure", {
  data <- create_ferpa_test_data_with_pii()
  result <- generate_privacy_review_report(data)

  # Validate structure
  expect_true(is.list(result))
  expect_true("title" %in% names(result))
  expect_true("generated" %in% names(result))
  expect_true("summary" %in% names(result))
  expect_true("validation_results" %in% names(result))
  expect_true("recommendations" %in% names(result))
})

test_that("generate_privacy_review_report supports institution-specific contexts", {
  data <- create_ferpa_test_data_with_pii()

  result <- generate_privacy_review_report(data, institution_type = "research")

  expect_true(any(grepl("IRB", result$validation_results$institution_guidance)))
})

test_that("deprecated privacy review wrappers preserve legacy compliant fields", {
  data <- create_ferpa_test_data_with_pii()

  legacy_review <- expect_warning(
    validate_ferpa_compliance(data, audit_log = FALSE),
    "deprecated"
  )
  expect_identical(legacy_review$compliant, legacy_review$passed)

  legacy_report <- expect_warning(
    generate_ferpa_report(data),
    "deprecated"
  )
  expect_identical(legacy_report$summary$compliant, legacy_report$summary$passed)
  expect_identical(
    legacy_report$validation_results$compliant,
    legacy_report$validation_results$passed
  )

  tmp_json <- tempfile(fileext = ".json")
  on.exit(unlink(tmp_json), add = TRUE)
  expect_warning(
    generate_ferpa_report(data, output_file = tmp_json, report_format = "json"),
    "deprecated"
  )
  persisted_report <- jsonlite::read_json(tmp_json, simplifyVector = TRUE)
  expect_identical(persisted_report$summary$compliant, persisted_report$summary$passed)
  expect_identical(
    persisted_report$validation_results$compliant,
    persisted_report$validation_results$passed
  )

  legacy_log <- expect_warning(
    log_ferpa_compliance_check(
      compliant = FALSE,
      pii_detected = 2,
      institution_type = "educational"
    ),
    "deprecated"
  )
  expect_identical(legacy_log$compliant, legacy_log$passed)
})

test_that("generate_privacy_review_report handles different report formats", {
  data <- create_ferpa_test_data_with_pii()

  # Test text format
  result_text <- generate_privacy_review_report(data, report_format = "text")
  expect_true(is.list(result_text))

  # Test HTML format
  result_html <- generate_privacy_review_report(data, report_format = "html")
  expect_true(is.list(result_html))

  # Test JSON format
  result_json <- generate_privacy_review_report(data, report_format = "json")
  expect_true(is.list(result_json))
})

test_that("generate_privacy_review_report handles invalid data", {
  # Test with NULL data
  expect_error(generate_privacy_review_report(NULL))

  # Test with non-data.frame
  expect_error(generate_privacy_review_report("not a data frame"))
  expect_error(generate_privacy_review_report(123))
  expect_error(generate_privacy_review_report(list()))
})

# =============================================================================
# TESTS FOR log_privacy_review
# =============================================================================

test_that("log_privacy_review handles logging", {
  # Test logging with different parameters
  result1 <- log_privacy_review(TRUE, 0, "educational")
  expect_true(is.list(result1))
  expect_true("timestamp" %in% names(result1))
  expect_true("passed" %in% names(result1))
  expect_true("pii_detected" %in% names(result1))
  expect_true("institution_type" %in% names(result1))

  result2 <- log_privacy_review(FALSE, 3, "research")
  expect_true(is.list(result2))
  expect_false(result2$passed)
  expect_equal(result2$pii_detected, 3)
  expect_equal(result2$institution_type, "research")
})

test_that("log_privacy_review avoids same-second audit key collisions", {
  old_logs <- getOption("engager.privacy_review_logs")
  old_ferpa_logs <- getOption("engager.ferpa_logs")
  on.exit(options(engager.privacy_review_logs = old_logs, engager.ferpa_logs = old_ferpa_logs), add = TRUE)
  options(engager.privacy_review_logs = list())
  options(engager.ferpa_logs = list())
  rm(list = ls(envir = .privacy_review_log_env), envir = .privacy_review_log_env)

  timestamp1 <- as.POSIXct("2026-05-09 12:00:00.123456", tz = "UTC")
  timestamp2 <- as.POSIXct("2026-05-09 12:00:00.654321", tz = "UTC")

  log_privacy_review(TRUE, 0, "educational", timestamp = timestamp1)
  log_privacy_review(FALSE, 1, "educational", timestamp = timestamp2)

  logs <- getOption("engager.privacy_review_logs")
  expect_length(logs, 2)
  expect_length(unique(names(logs)), 2)
  expect_length(ls(envir = .privacy_review_log_env), 2)
  expect_identical(getOption("engager.ferpa_logs"), logs)
})

test_that("log_privacy_review falls back to legacy FERPA log options", {
  old_logs <- getOption("engager.privacy_review_logs")
  old_ferpa_logs <- getOption("engager.ferpa_logs")
  old_log_file <- getOption("engager.privacy_review_log_file")
  old_ferpa_log_file <- getOption("engager.ferpa_log_file")
  on.exit(
    options(
      engager.privacy_review_logs = old_logs,
      engager.ferpa_logs = old_ferpa_logs,
      engager.privacy_review_log_file = old_log_file,
      engager.ferpa_log_file = old_ferpa_log_file
    ),
    add = TRUE
  )

  rm(list = ls(envir = .privacy_review_log_env), envir = .privacy_review_log_env)
  options(engager.privacy_review_logs = NULL)
  options(engager.ferpa_logs = list(existing = list(passed = TRUE)))

  tmp_log <- tempfile(fileext = ".log")
  on.exit(unlink(tmp_log), add = TRUE)
  options(engager.privacy_review_log_file = NULL)
  options(engager.ferpa_log_file = tmp_log)

  log_privacy_review(TRUE, 0, "educational")

  logs <- getOption("engager.privacy_review_logs")
  expect_true("existing" %in% names(logs))
  expect_true(file.exists(tmp_log))
})

# =============================================================================
# COMPREHENSIVE PARAMETER TESTING
# =============================================================================

test_that("review_privacy_risks handles comprehensive parameters", {
  data <- create_ferpa_test_data_with_pii()

  # Test all parameter combinations
  param_combinations <- list(
    list(data = data, institution_type = "educational", check_retention = TRUE, retention_period = "academic_year", audit_log = TRUE),
    list(data = data, institution_type = "research", check_retention = FALSE, retention_period = "semester", audit_log = FALSE),
    list(data = data, institution_type = "mixed", check_retention = TRUE, retention_period = "quarter", audit_log = TRUE),
    list(data = data, institution_type = "educational", check_retention = TRUE, retention_period = "custom", custom_retention_days = 100, audit_log = TRUE)
  )

  for (params in param_combinations) {
    result <- do.call(review_privacy_risks, params)
    expect_true(is.list(result))
    expect_true("passed" %in% names(result))
  }
})

test_that("anonymize_educational_data handles comprehensive parameters", {
  data <- create_ferpa_test_data_with_pii()

  # Test all supported v0.1.0 method combinations
  method_combinations <- list(
    list(data = data, method = "mask"),
    list(data = data, method = "hash", hash_salt = "test_salt"),
    list(data = data, method = "pseudonymize"),
    list(data = data, method = "mask", preserve_columns = "student_id")
  )

  for (params in method_combinations) {
    result <- do.call(anonymize_educational_data, params)
    expect_s3_class(result, "tbl_df")
    expect_true("privacy_applied" %in% names(attributes(result)))
  }
})

# =============================================================================
# EDGE CASE TESTING
# =============================================================================

test_that("privacy review functions handle edge cases", {
  # Test with empty data
  empty_data <- tibble::tibble()
  result <- review_privacy_risks(empty_data)
  expect_true(is.list(result))

  # Test with single row
  single_row <- create_ferpa_test_data_with_pii()[1, ]
  result <- review_privacy_risks(single_row)
  expect_true(is.list(result))

  # Test with missing values
  data_with_na <- create_ferpa_test_data_with_pii()
  data_with_na$student_id[1] <- NA
  result <- review_privacy_risks(data_with_na)
  expect_true(is.list(result))
})
