# Test Privacy Vectorization Fix
# 
# This test file verifies that the privacy functions handle vector privacy_level
# input gracefully, preventing the "condition has length > 1" error that was
# causing 100+ test failures and preventing CRAN submission.

test_that("apply_privacy_masking_plot handles vector privacy_level in plot_users.R", {
  # Test with vector input
  test_data <- data.frame(name = c("Alice", "Bob"), value = c(1, 2))
  
  # Should not error with vector input
  expect_no_error(
    engager:::apply_privacy_masking_plot(test_data, c("mask", "none"), "name", "name")
  )
  
  # Should use first element
  result <- engager:::apply_privacy_masking_plot(test_data, c("mask", "none"), "name", "name")
  expect_true(all(grepl("^Student_", result$name)))
  
  # Test with scalar input (existing behavior)
  result_scalar <- engager:::apply_privacy_masking_plot(test_data, "mask", "name", "name")
  expect_true(all(grepl("^Student_", result_scalar$name)))
  
  # Test with "none" privacy level
  result_none <- engager:::apply_privacy_masking_plot(test_data, "none", "name", "name")
  expect_identical(result_none$name, test_data$name)
})

test_that("validate_privacy_level handles vector privacy_level in ensure_privacy.R", {
  # Test with vector input
  expect_no_error(
    engager:::validate_privacy_level(c("mask", "none"))
  )
  
  # Test with scalar input (existing behavior)
  expect_no_error(
    engager:::validate_privacy_level("mask")
  )
  
  # Test with invalid privacy level
  expect_error(
    engager:::validate_privacy_level("invalid"),
    "Invalid privacy_level"
  )
  
  # Test with empty vector
  expect_error(
    engager:::validate_privacy_level(character(0)),
    "privacy_level must be a non-empty character vector"
  )
  
  # Test with non-character input
  expect_error(
    engager:::validate_privacy_level(123),
    "privacy_level must be a non-empty character vector"
  )
})

test_that("ensure_privacy handles vector privacy_level gracefully", {
  # Test data
  test_data <- data.frame(
    name = c("Alice", "Bob"),
    value = c(1, 2),
    stringsAsFactors = FALSE
  )
  
  # Test with vector privacy_level
  expect_no_error(
    result <- engager::ensure_privacy(test_data, privacy_level = c("mask", "none"))
  )
  
  # Should use first element (mask)
  expect_true(all(grepl("^Student", result$name)))
  
  # Test with scalar privacy_level (existing behavior)
  result_scalar <- engager::ensure_privacy(test_data, privacy_level = "mask")
  expect_true(all(grepl("^Student", result_scalar$name)))
})

test_that("plot_users handles vector privacy_level gracefully", {
  # Test data
  test_data <- data.frame(
    name = c("Alice", "Bob"),
    session_ct = c(1, 2),
    stringsAsFactors = FALSE
  )
  
  # Test with vector privacy_level
  expect_no_error(
    result <- engager::plot_users(test_data, privacy_level = c("mask", "none"))
  )
  
  # Should create a plot without error
  expect_s3_class(result, "ggplot")
})

test_that("vector privacy_level handling maintains backward compatibility", {
  # Test that existing scalar behavior still works
  test_data <- data.frame(
    name = c("Alice", "Bob"),
    value = c(1, 2),
    stringsAsFactors = FALSE
  )
  
  # Scalar input should work as before
  result_scalar <- engager::ensure_privacy(test_data, privacy_level = "mask")
  expect_true(all(grepl("^Student", result_scalar$name)))
  
  # Vector input should use first element
  result_vector <- engager::ensure_privacy(test_data, privacy_level = c("mask", "none"))
  expect_true(all(grepl("^Student", result_vector$name)))
  
  # Results should be identical
  expect_identical(result_scalar$name, result_vector$name)
})

test_that("vector privacy_level handling emits appropriate warnings", {
  # Test that warnings are emitted for vector input
  test_data <- data.frame(
    name = c("Alice", "Bob"),
    value = c(1, 2),
    stringsAsFactors = FALSE
  )
  
  # Should emit warning for vector input
  expect_warning(
    engager::ensure_privacy(test_data, privacy_level = c("mask", "none")),
    "privacy_level had length > 1, using first element"
  )
  
  # Should not emit warning for scalar input
  expect_no_warning(
    engager::ensure_privacy(test_data, privacy_level = "mask")
  )
})
