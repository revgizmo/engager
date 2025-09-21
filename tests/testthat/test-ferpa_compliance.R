# Test file for FERPA compliance functions
# Tests for validate_ferpa_compliance, anonymize_educational_data, and related functions

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
# TESTS FOR validate_ferpa_compliance
# =============================================================================

test_that("validate_ferpa_compliance returns proper structure", {
  data <- create_ferpa_test_data_with_pii()
  result <- validate_ferpa_compliance(data)
  
  # Validate structure
  expect_true(is.list(result))
  expect_true("compliant" %in% names(result))
  expect_true("pii_detected" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("retention_check" %in% names(result))
  expect_true("institution_guidance" %in% names(result))
})

test_that("validate_ferpa_compliance detects PII correctly", {
  data <- create_ferpa_test_data_with_pii()
  result <- validate_ferpa_compliance(data)

  # Should detect PII
  expect_false(result$compliant)
  expect_true(length(result$pii_detected) > 0)
  expect_true("student_id" %in% result$pii_detected)
  expect_true("preferred_name" %in% result$pii_detected)
  expect_true("email" %in% result$pii_detected)
})

test_that("validate_ferpa_compliance handles data without PII", {
  data <- create_ferpa_test_data_without_pii()
  result <- validate_ferpa_compliance(data)
  
  # Should be compliant
  expect_true(result$compliant)
  expect_equal(length(result$pii_detected), 0)
})

test_that("validate_ferpa_compliance handles different institution types", {
  data <- create_ferpa_test_data_with_pii()
  
  # Test educational institution
  result_edu <- validate_ferpa_compliance(data, institution_type = "educational")
  expect_true("Educational institutions must comply with FERPA regulations" %in% result_edu$institution_guidance)
  
  # Test research institution
  result_research <- validate_ferpa_compliance(data, institution_type = "research")
  expect_true("Research institutions should follow IRB guidelines" %in% result_research$institution_guidance)
  
  # Test mixed institution
  result_mixed <- validate_ferpa_compliance(data, institution_type = "mixed")
  expect_true("Mixed institutions must comply with both FERPA and research ethics" %in% result_mixed$institution_guidance)
})

test_that("validate_ferpa_compliance handles different retention periods", {
  data <- create_ferpa_test_data_with_pii()
  
  # Test academic year
  result_ay <- validate_ferpa_compliance(data, retention_period = "academic_year")
  expect_true(is.list(result_ay$retention_check))
  
  # Test semester
  result_sem <- validate_ferpa_compliance(data, retention_period = "semester")
  expect_true(is.list(result_sem$retention_check))
  
  # Test quarter
  result_qtr <- validate_ferpa_compliance(data, retention_period = "quarter")
  expect_true(is.list(result_qtr$retention_check))
  
  # Test custom
  result_custom <- validate_ferpa_compliance(data, retention_period = "custom", custom_retention_days = 100)
  expect_true(is.list(result_custom$retention_check))
})

test_that("validate_ferpa_compliance handles invalid data", {
  # Test with NULL data
  expect_error(validate_ferpa_compliance(NULL))
  
  # Test with non-data.frame
  expect_error(validate_ferpa_compliance("not a data frame"))
  expect_error(validate_ferpa_compliance(123))
  expect_error(validate_ferpa_compliance(list()))
})

test_that("validate_ferpa_compliance provides appropriate recommendations", {
  data <- create_ferpa_test_data_with_pii()
  result <- validate_ferpa_compliance(data)
  
  # Should have recommendations
  expect_true(length(result$recommendations) > 0)
  expect_true(any(grepl("PII detected", result$recommendations)))
  expect_true(any(grepl("ensure_privacy", result$recommendations)))
  expect_true(any(grepl("FERPA policies", result$recommendations)))
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

test_that("anonymize_educational_data handles hash method", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data, method = "hash", hash_salt = "test_salt")
  
  # Should hash PII columns
  expect_true(all(nchar(result$student_id) == 8))
  expect_true(all(nchar(result$preferred_name) == 8))
  expect_true(all(nchar(result$email) == 8))
  
  # Should preserve non-PII columns
  expect_equal(result$course, data$course)
  expect_equal(result$section, data$section)
  expect_equal(result$participation_data, data$participation_data)
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

test_that("anonymize_educational_data handles aggregate method", {
  data <- create_ferpa_test_data_with_pii()
  result <- anonymize_educational_data(data, method = "aggregate", aggregation_level = "section")
  
  # Should aggregate by section
  expect_true(nrow(result) <= nrow(data))
  expect_true("section" %in% names(result))
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

test_that("anonymize_educational_data handles data without PII", {
  data <- create_ferpa_test_data_without_pii()
  result <- anonymize_educational_data(data)
  
  # Should return data unchanged
  expect_equal(result, data)
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
  expect_true("compliant" %in% names(result))
  expect_true("retention_period_days" %in% names(result))
  expect_true("data_to_dispose" %in% names(result))
  expect_true("recommendations" %in% names(result))
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

test_that("check_data_retention_policy handles invalid data", {
  # Test with NULL data
  expect_error(check_data_retention_policy(NULL))
  
  # Test with non-data.frame
  expect_error(check_data_retention_policy("not a data frame"))
  expect_error(check_data_retention_policy(123))
  expect_error(check_data_retention_policy(list()))
})

# =============================================================================
# TESTS FOR generate_ferpa_report
# =============================================================================

test_that("generate_ferpa_report returns proper structure", {
  data <- create_ferpa_test_data_with_pii()
  result <- generate_ferpa_report(data)
  
  # Validate structure
  expect_true(is.list(result))
  expect_true("title" %in% names(result))
  expect_true("generated" %in% names(result))
  expect_true("summary" %in% names(result))
  expect_true("validation_results" %in% names(result))
  expect_true("recommendations" %in% names(result))
})

test_that("generate_ferpa_report handles different report formats", {
  data <- create_ferpa_test_data_with_pii()
  
  # Test text format
  result_text <- generate_ferpa_report(data, report_format = "text")
  expect_true(is.list(result_text))
  
  # Test HTML format
  result_html <- generate_ferpa_report(data, report_format = "html")
  expect_true(is.list(result_html))
  
  # Test JSON format
  result_json <- generate_ferpa_report(data, report_format = "json")
  expect_true(is.list(result_json))
})

test_that("generate_ferpa_report handles invalid data", {
  # Test with NULL data
  expect_error(generate_ferpa_report(NULL))
  
  # Test with non-data.frame
  expect_error(generate_ferpa_report("not a data frame"))
  expect_error(generate_ferpa_report(123))
  expect_error(generate_ferpa_report(list()))
})

# =============================================================================
# TESTS FOR log_ferpa_compliance_check
# =============================================================================

test_that("log_ferpa_compliance_check handles logging", {
  # Test logging with different parameters
  result1 <- log_ferpa_compliance_check(TRUE, 0, "educational")
  expect_true(is.list(result1))
  expect_true("timestamp" %in% names(result1))
  expect_true("compliant" %in% names(result1))
  expect_true("pii_detected" %in% names(result1))
  expect_true("institution_type" %in% names(result1))
  
  result2 <- log_ferpa_compliance_check(FALSE, 3, "research")
  expect_true(is.list(result2))
  expect_false(result2$compliant)
  expect_equal(result2$pii_detected, 3)
  expect_equal(result2$institution_type, "research")
})

# =============================================================================
# COMPREHENSIVE PARAMETER TESTING
# =============================================================================

test_that("validate_ferpa_compliance handles comprehensive parameters", {
  data <- create_ferpa_test_data_with_pii()
  
  # Test all parameter combinations
  param_combinations <- list(
    list(data = data, institution_type = "educational", check_retention = TRUE, retention_period = "academic_year", audit_log = TRUE),
    list(data = data, institution_type = "research", check_retention = FALSE, retention_period = "semester", audit_log = FALSE),
    list(data = data, institution_type = "mixed", check_retention = TRUE, retention_period = "quarter", audit_log = TRUE),
    list(data = data, institution_type = "educational", check_retention = TRUE, retention_period = "custom", custom_retention_days = 100, audit_log = TRUE)
  )
  
  for (params in param_combinations) {
    result <- do.call(validate_ferpa_compliance, params)
    expect_true(is.list(result))
    expect_true("compliant" %in% names(result))
  }
})

test_that("anonymize_educational_data handles comprehensive parameters", {
  data <- create_ferpa_test_data_with_pii()
  
  # Test all method combinations
  method_combinations <- list(
    list(data = data, method = "mask"),
    list(data = data, method = "hash", hash_salt = "test_salt"),
    list(data = data, method = "pseudonymize"),
    list(data = data, method = "aggregate", aggregation_level = "section"),
    list(data = data, method = "aggregate", aggregation_level = "course"),
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

test_that("FERPA functions handle edge cases", {
  # Test with empty data
  empty_data <- tibble::tibble()
  result <- validate_ferpa_compliance(empty_data)
  expect_true(is.list(result))
  
  # Test with single row
  single_row <- create_ferpa_test_data_with_pii()[1, ]
  result <- validate_ferpa_compliance(single_row)
  expect_true(is.list(result))
  
  # Test with missing values
  data_with_na <- create_ferpa_test_data_with_pii()
  data_with_na$student_id[1] <- NA
  result <- validate_ferpa_compliance(data_with_na)
  expect_true(is.list(result))
})