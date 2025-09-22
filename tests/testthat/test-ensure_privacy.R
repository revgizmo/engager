# Test file for ensure_privacy function

library(testthat)
library(engager)

# Test data setup
create_privacy_test_data <- function() {
  tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice Johnson", "Bob Lee", "Cara Diaz"),
    student_id = c("STU001", "STU002", "STU003"),
    email = c("alice@university.edu", "bob@university.edu", "cara@university.edu"),
    session_ct = c(3, 5, 2)
  )
}

create_privacy_test_data_with_pii <- function() {
  tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice Johnson", "Bob Lee", "Cara Diaz"),
    student_id = c("STU001", "STU002", "STU003"),
    email = c("alice@university.edu", "bob@university.edu", "cara@university.edu"),
    phone = c("555-1234", "555-5678", "555-9012"),
    address = c("123 Main St", "456 Oak Ave", "789 Pine St"),
    session_ct = c(3, 5, 2)
  )
}

create_empty_privacy_data <- function() {
  tibble::tibble(
    section = character(),
    preferred_name = character(),
    student_id = character(),
    email = character(),
    session_ct = numeric()
  )
}

# Basic tests
test_that("ensure_privacy returns proper structure", {
  data <- create_privacy_test_data()
  result <- ensure_privacy(data)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
  expect_true("section" %in% names(result))
  expect_true("preferred_name" %in% names(result))
  expect_true("student_id" %in% names(result))
  expect_true("email" %in% names(result))
  expect_true("session_ct" %in% names(result))
})

test_that("ensure_privacy handles NULL input", {
  result <- ensure_privacy(NULL)
  expect_null(result)
})

test_that("ensure_privacy handles non-data.frame input", {
  result <- ensure_privacy("not a data frame")
  expect_equal(result, "not a data frame")

  result <- ensure_privacy(123)
  expect_equal(result, 123)

  result <- ensure_privacy(list())
  expect_equal(result, list())
})

test_that("ensure_privacy handles empty data", {
  data <- create_empty_privacy_data()
  result <- ensure_privacy(data)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles different privacy levels", {
  data <- create_privacy_test_data()

  # Test mask level (default)
  result_mask <- ensure_privacy(data, privacy_level = "mask")
  expect_s3_class(result_mask, "tbl_df")
  expect_equal(nrow(result_mask), nrow(data))

  # Test ferpa_standard level
  result_standard <- ensure_privacy(data, privacy_level = "ferpa_standard")
  expect_s3_class(result_standard, "tbl_df")
  expect_equal(nrow(result_standard), nrow(data))

  # Test ferpa_strict level
  result_strict <- ensure_privacy(data, privacy_level = "ferpa_strict")
  expect_s3_class(result_strict, "tbl_df")
  expect_equal(nrow(result_strict), nrow(data))

  # Test none level
  result_none <- ensure_privacy(data, privacy_level = "none")
  expect_s3_class(result_none, "tbl_df")
  expect_equal(nrow(result_none), nrow(data))
})

test_that("ensure_privacy handles custom id_columns", {
  data <- create_privacy_test_data()

  custom_columns <- c("preferred_name", "student_id")
  result <- ensure_privacy(data, id_columns = custom_columns)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles audit logging", {
  data <- create_privacy_test_data()

  # Test with audit logging enabled
  result_with_log <- ensure_privacy(data, audit_log = TRUE)
  expect_s3_class(result_with_log, "tbl_df")
  expect_equal(nrow(result_with_log), nrow(data))

  # Test with audit logging disabled
  result_without_log <- ensure_privacy(data, audit_log = FALSE)
  expect_s3_class(result_without_log, "tbl_df")
  expect_equal(nrow(result_without_log), nrow(data))
})

test_that("ensure_privacy handles invalid privacy levels", {
  data <- create_privacy_test_data()

  expect_error(ensure_privacy(data, privacy_level = "invalid"))
  expect_error(ensure_privacy(data, privacy_level = NULL))
  expect_error(ensure_privacy(data, privacy_level = character(0)))
  expect_error(ensure_privacy(data, privacy_level = 123))
})

test_that("ensure_privacy handles vector privacy levels", {
  data <- create_privacy_test_data()

  # Test with vector privacy level (should use first element)
  result <- ensure_privacy(data, privacy_level = c("mask", "ferpa_standard"))
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
})

test_that("ensure_privacy handles data with PII", {
  data <- create_privacy_test_data_with_pii()

  result <- ensure_privacy(data, privacy_level = "ferpa_strict")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles data without PII columns", {
  data <- tibble::tibble(
    section = c("A", "A", "B"),
    session_ct = c(3, 5, 2),
    score = c(85, 92, 78)
  )

  result <- ensure_privacy(data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles factor columns", {
  data <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = factor(c("Alice Johnson", "Bob Lee", "Cara Diaz")),
    student_id = c("STU001", "STU002", "STU003"),
    session_ct = c(3, 5, 2)
  )

  result <- ensure_privacy(data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles missing values", {
  data <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice Johnson", NA, "Cara Diaz"),
    student_id = c("STU001", "STU002", NA),
    email = c("alice@university.edu", "bob@university.edu", "cara@university.edu"),
    session_ct = c(3, 5, 2)
  )

  result <- ensure_privacy(data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles empty strings", {
  data <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice Johnson", "", "Cara Diaz"),
    student_id = c("STU001", "STU002", "STU003"),
    email = c("alice@university.edu", "bob@university.edu", "cara@university.edu"),
    session_ct = c(3, 5, 2)
  )

  result <- ensure_privacy(data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles single row data", {
  data <- create_privacy_test_data()[1, ]

  result <- ensure_privacy(data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles single column data", {
  data <- tibble::tibble(
    preferred_name = c("Alice Johnson", "Bob Lee", "Cara Diaz")
  )

  result <- ensure_privacy(data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data))
  expect_equal(ncol(result), ncol(data))
})

test_that("ensure_privacy handles comprehensive parameters", {
  data <- create_privacy_test_data()

  param_combinations <- list(
    list(x = data, privacy_level = "mask"),
    list(x = data, privacy_level = "ferpa_standard"),
    list(x = data, privacy_level = "ferpa_strict"),
    list(x = data, privacy_level = "none"),
    list(x = data, privacy_level = "mask", id_columns = c("preferred_name", "student_id")),
    list(x = data, privacy_level = "mask", audit_log = TRUE),
    list(x = data, privacy_level = "mask", audit_log = FALSE)
  )

  for (params in param_combinations) {
    result <- do.call(ensure_privacy, params)
    expect_s3_class(result, "tbl_df")
    expect_equal(nrow(result), nrow(data))
  }
})

test_that("ensure_privacy handles edge cases", {
  # Test with all NA values
  data_na <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c(NA, NA, NA),
    student_id = c(NA, NA, NA),
    email = c(NA, NA, NA),
    session_ct = c(3, 5, 2)
  )

  result <- ensure_privacy(data_na)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data_na))

  # Test with all empty strings
  data_empty <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("", "", ""),
    student_id = c("", "", ""),
    email = c("", "", ""),
    session_ct = c(3, 5, 2)
  )

  result <- ensure_privacy(data_empty)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), nrow(data_empty))
})

test_that("ensure_privacy handles errors gracefully", {
  data <- create_privacy_test_data()

  # Test with invalid privacy levels
  expect_error(ensure_privacy(data, privacy_level = "invalid"))
  expect_error(ensure_privacy(data, privacy_level = NULL))
  expect_error(ensure_privacy(data, privacy_level = character(0)))
  expect_error(ensure_privacy(data, privacy_level = 123))

  # Test with invalid audit_log
  expect_error(ensure_privacy(data, audit_log = "invalid"))
  expect_error(ensure_privacy(data, audit_log = NULL))
})
