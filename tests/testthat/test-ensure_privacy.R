# Comprehensive tests for ensure_privacy function
# Tests to improve coverage

test_that("ensure_privacy handles NULL input", {
  result <- ensure_privacy(NULL)
  expect_null(result)
})

test_that("ensure_privacy handles non-data.frame input", {
  # Test with character vector
  result1 <- ensure_privacy(c("test", "data"))
  expect_equal(result1, c("test", "data"))

  # Test with list
  result2 <- ensure_privacy(list(a = 1, b = 2))
  expect_equal(result2, list(a = 1, b = 2))

  # Test with numeric
  result3 <- ensure_privacy(123)
  expect_equal(result3, 123)
})

test_that("ensure_privacy handles empty tibble", {
  empty_tibble <- tibble::tibble(
    name = character(0),
    comment = character(0)
  )

  result <- ensure_privacy(empty_tibble)
  expect_equal(nrow(result), 0)
  expect_equal(names(result), names(empty_tibble))
})

test_that("ensure_privacy handles different privacy levels", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there"),
    student_id = c("12345", "67890")
  )

  # Test mask privacy level
  result1 <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 2)

  # Test ferpa_standard privacy level
  result2 <- ensure_privacy(test_data, privacy_level = "ferpa_standard")
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 2)

  # Test ferpa_strict privacy level
  result3 <- ensure_privacy(test_data, privacy_level = "ferpa_strict")
  expect_s3_class(result3, "tbl_df")
  expect_equal(nrow(result3), 2)

  # Test ferpa_standard privacy level (duplicate removed)
  result4 <- ensure_privacy(test_data, privacy_level = "ferpa_standard")
  expect_s3_class(result4, "tbl_df")
  expect_equal(nrow(result4), 2)

  # Test ferpa_strict privacy level (duplicate removed)
  result5 <- ensure_privacy(test_data, privacy_level = "ferpa_strict")
  expect_s3_class(result5, "tbl_df")
  expect_equal(nrow(result5), 2)

  # Test none privacy level
  result6 <- ensure_privacy(test_data, privacy_level = "none")
  expect_s3_class(result6, "tbl_df")
  expect_equal(nrow(result6), 2)
})

test_that("ensure_privacy handles custom id_columns", {
  test_data <- tibble::tibble(
    student_name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there"),
    user_id = c("12345", "67890")
  )

  result <- ensure_privacy(test_data, id_columns = c("student_name", "user_id"))
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
})

test_that("ensure_privacy handles data without name columns", {
  test_data <- tibble::tibble(
    comment = c("Hello", "Hi there"),
    duration = c(5, 10),
    wordcount = c(1, 2)
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(names(result), names(test_data))
})

test_that("ensure_privacy handles data with mixed column types", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there"),
    duration = hms::as_hms(c("00:00:05", "00:00:10")),
    wordcount = c(1, 2),
    is_student = c(TRUE, FALSE),
    score = c(85.5, 92.0)
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(names(result), names(test_data))
})

test_that("ensure_privacy handles audit_log parameter", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there")
  )

  # Test with audit_log = TRUE
  result1 <- ensure_privacy(test_data, audit_log = TRUE)
  expect_s3_class(result1, "tbl_df")

  # Test with audit_log = FALSE
  result2 <- ensure_privacy(test_data, audit_log = FALSE)
  expect_s3_class(result2, "tbl_df")
})

test_that("ensure_privacy handles invalid privacy_level gracefully", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there")
  )

  # Should throw an error for invalid privacy level
  expect_error(
    ensure_privacy(test_data, privacy_level = "invalid"),
    "Invalid privacy_level. Must be one of: ferpa_strict, ferpa_standard, mask, none"
  )
})

test_that("ensure_privacy preserves data structure", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there"),
    metadata = list(list(type = "student"), list(type = "instructor"))
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 3)
  expect_true("metadata" %in% names(result))
})

test_that("ensure_privacy handles large datasets", {
  # Create a larger dataset
  large_data <- tibble::tibble(
    name = paste("Student", 1:100),
    comment = paste("Comment", 1:100),
    duration = rep(hms::as_hms("00:00:05"), 100)
  )

  result <- ensure_privacy(large_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 100)
  expect_equal(ncol(result), 3)
})

test_that("ensure_privacy handles special characters in names", {
  test_data <- tibble::tibble(
    name = c("José García", "François Müller", "李小明"),
    comment = c("Hello", "Bonjour", "你好")
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("ensure_privacy handles NA values", {
  test_data <- tibble::tibble(
    name = c("John Smith", NA, "Jane Doe"),
    comment = c("Hello", "Hi", NA),
    student_id = c("12345", "67890", NA)
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("ensure_privacy handles empty strings", {
  test_data <- tibble::tibble(
    name = c("John Smith", "", "Jane Doe"),
    comment = c("Hello", "", "Hi there"),
    student_id = c("12345", "", "67890")
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("ensure_privacy handles data.frame input", {
  test_data <- data.frame(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there"),
    stringsAsFactors = FALSE
  )

  result <- ensure_privacy(test_data)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
})

test_that("ensure_privacy handles edge case privacy levels", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    comment = c("Hello", "Hi there")
  )

  # Test with invalid privacy level (should error)
  expect_error(ensure_privacy(test_data, privacy_level = "invalid_level"), "Invalid privacy_level")

  # Test with NULL privacy level (should error)
  expect_error(ensure_privacy(test_data, privacy_level = NULL), "privacy_level must be a non-empty character vector")
})

test_that("ensure_privacy handles special characters in names", {
  test_data <- tibble::tibble(
    name = c("José María", "O'Connor", "测试名字"),
    comment = c("Hello", "Hi", "你好")
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("ensure_privacy handles very long names", {
  long_name <- paste(rep("A", 1000), collapse = "")
  test_data <- tibble::tibble(
    name = c("John Smith", long_name),
    comment = c("Hello", "Hi")
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
})

test_that("ensure_privacy handles NA values in names", {
  test_data <- tibble::tibble(
    name = c("John Smith", NA, "Jane Doe"),
    comment = c("Hello", "Hi", "Hey")
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("ensure_privacy handles empty strings in names", {
  test_data <- tibble::tibble(
    name = c("John Smith", "", "Jane Doe"),
    comment = c("Hello", "Hi", "Hey")
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
})

test_that("ensure_privacy handles numeric columns", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    age = c(25, 30),
    grade = c(85, 92)
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("age" %in% names(result))
  expect_true("grade" %in% names(result))
})

test_that("ensure_privacy handles logical columns", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    active = c(TRUE, FALSE),
    enrolled = c(FALSE, TRUE)
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("active" %in% names(result))
  expect_true("enrolled" %in% names(result))
})

test_that("ensure_privacy handles date columns", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    enrollment_date = as.Date(c("2023-01-01", "2023-02-01")),
    last_login = as.POSIXct(c("2023-01-15 10:00:00", "2023-02-15 14:30:00"))
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("enrollment_date" %in% names(result))
  expect_true("last_login" %in% names(result))
})

test_that("ensure_privacy handles mixed data types", {
  test_data <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    age = c(25L, 30L),
    active = c(TRUE, FALSE),
    score = c(85.5, 92.0),
    comments = c("Good", "Excellent")
  )

  result <- ensure_privacy(test_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 5)
})

test_that("ensure_privacy handles large datasets", {
  # Create a larger dataset
  large_data <- tibble::tibble(
    name = paste("Student", 1:100),
    comment = paste("Comment", 1:100),
    grade = runif(100, 0, 100)
  )

  result <- ensure_privacy(large_data, privacy_level = "mask")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 100)
  expect_equal(ncol(result), 3)
})
