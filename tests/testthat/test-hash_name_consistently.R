<<<<<<< HEAD
# Test file for hash_name_consistently function

library(testthat)
library(engager)

test_that("hash_name_consistently produces consistent hashes", {
  # Test that the same input produces the same hash
  name1 <- "John Doe"
  hash1 <- hash_name_consistently(name1)
  hash2 <- hash_name_consistently(name1)

  expect_identical(hash1, hash2)
  expect_type(hash1, "character")
  expect_length(hash1, 1)
})

test_that("hash_name_consistently produces different hashes for different inputs", {
  # Test that different inputs produce different hashes
  name1 <- "John Doe"
  name2 <- "Jane Smith"

  hash1 <- hash_name_consistently(name1)
  hash2 <- hash_name_consistently(name2)

  expect_false(identical(hash1, hash2))
})

test_that("hash_name_consistently handles empty strings", {
  # Test with empty string
  hash_empty <- hash_name_consistently("")
  expect_type(hash_empty, "character")
  expect_length(hash_empty, 1)
})

test_that("hash_name_consistently handles NA values", {
  # Test with NA (should error since it's not character)
  expect_error(hash_name_consistently(NA), "names must be a character vector")
})

test_that("hash_name_consistently handles NULL values", {
  # Test with NULL (should error since it's not character)
  expect_error(hash_name_consistently(NULL), "names must be a character vector")
})

test_that("hash_name_consistently handles special characters", {
  # Test with special characters
  name_special <- "José María O'Connor"
  hash_special <- hash_name_consistently(name_special)

  expect_type(hash_special, "character")
  expect_length(hash_special, 1)
})

test_that("hash_name_consistently handles case sensitivity", {
  # Test case sensitivity (with normalization, should be same)
  name_upper <- "JOHN DOE"
  name_lower <- "john doe"

  hash_upper <- hash_name_consistently(name_upper)
  hash_lower <- hash_name_consistently(name_lower)

  # With normalization enabled (default), should produce same hashes
  expect_identical(hash_upper, hash_lower)
})

test_that("hash_name_consistently handles whitespace", {
  # Test with different whitespace (with normalization, should be same)
  name1 <- "John Doe"
  name2 <- " John Doe "
  name3 <- "John  Doe"

  hash1 <- hash_name_consistently(name1)
  hash2 <- hash_name_consistently(name2)
  hash3 <- hash_name_consistently(name3)

  # With normalization enabled (default), should produce same hashes
  expect_identical(hash1, hash2)
  expect_identical(hash1, hash3)
  expect_identical(hash2, hash3)
})

test_that("hash_name_consistently handles numeric inputs", {
  # Test with numeric input (should error since it's not character)
  expect_error(hash_name_consistently(123), "names must be a character vector")
})

test_that("hash_name_consistently handles logical inputs", {
  # Test with logical input (should error since it's not character)
  expect_error(hash_name_consistently(TRUE), "names must be a character vector")
})

test_that("hash_name_consistently handles vector inputs", {
  # Test with vector input
  names <- c("John Doe", "Jane Smith", "Bob Johnson")
  hashes <- hash_name_consistently(names)

  expect_type(hashes, "character")
  expect_length(hashes, 3)
  expect_false(any(duplicated(hashes)))
})

test_that("hash_name_consistently produces reasonable hash lengths", {
  # Test that hashes are reasonable length
  name <- "John Doe"
  hash <- hash_name_consistently(name)

  # Should be a reasonable length (not too short, not too long)
  expect_gt(nchar(hash), 5)
  expect_lt(nchar(hash), 100)
})

test_that("hash_name_consistently handles very long names", {
  # Test with very long name
  long_name <- paste(rep("A", 1000), collapse = "")
  hash_long <- hash_name_consistently(long_name)

  expect_type(hash_long, "character")
  expect_length(hash_long, 1)
})

test_that("hash_name_consistently handles unicode characters", {
  # Test with unicode characters
  unicode_name <- "测试名字"
  hash_unicode <- hash_name_consistently(unicode_name)

  expect_type(hash_unicode, "character")
  expect_length(hash_unicode, 1)
})

test_that("hash_name_consistently handles mixed data types", {
  # Test with mixed data types
  mixed_input <- c("John", 123, TRUE, NA)
  hashes <- hash_name_consistently(mixed_input)

  expect_type(hashes, "character")
  expect_length(hashes, 4)
=======
test_that("hash_name_consistently normalizes and hashes deterministically", {
  names <- c("John Smith", "Smith, John", " john   smith ")
  hashes <- hash_name_consistently(names, salt = "unit-test", normalize_names = TRUE)

  expect_equal(length(hashes), length(names))
  expect_true(all(nchar(hashes) == 8))
  expect_equal(length(unique(hashes)), 1)
})

test_that("hash_name_consistently respects normalization flag", {
  variants <- c("Professor Jane Doe", "Doe, Jane", "Jane Doe")

  normalized <- hash_name_consistently(variants, salt = "unit-test", normalize_names = TRUE)
  raw_hashes <- hash_name_consistently(variants, salt = "unit-test", normalize_names = FALSE)

  expect_equal(normalized[1], normalized[2])
  expect_equal(normalized[1], normalized[3])
  expect_false(raw_hashes[1] == raw_hashes[2])
  expect_false(raw_hashes[1] == raw_hashes[3])
})

test_that("hash_name_consistently validates inputs and handles missing values", {
  expect_error(hash_name_consistently(123), "names must be a character vector")
  expect_error(hash_name_consistently("A", salt = c("a", "b")), "salt must be a single character string")
  expect_error(hash_name_consistently("A", normalize_names = c(TRUE, FALSE)), "normalize_names must be a single logical value")

  names <- c("Alice", NA_character_, " ")
  hashes <- hash_name_consistently(names, salt = "unit-test", normalize_names = TRUE)

  expect_true(is.na(hashes[2]))
  expect_true(is.na(hashes[3]))
  expect_equal(nchar(hashes[1]), 8)
>>>>>>> cf1c7ed (test(coverage): add tests for uncovered exports)
})
