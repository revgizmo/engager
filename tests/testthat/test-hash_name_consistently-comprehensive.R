# Test file for hash_name_consistently comprehensive coverage
# This function has hashing logic that needs thorough testing

test_that("hash_name_consistently handles different input types", {
  # Test with valid character vector
  names <- c("John Smith", "Jane Doe", "Bob Johnson")
  result1 <- hash_name_consistently(names)
  expect_type(result1, "character")
  expect_equal(length(result1), 3)
  expect_true(all(nchar(result1) == 8)) # Should be 8-character hashes

  # Test with single name
  result2 <- hash_name_consistently("John Smith")
  expect_type(result2, "character")
  expect_equal(length(result2), 1)
  expect_equal(nchar(result2), 8)

  # Test with empty vector
  result3 <- hash_name_consistently(character(0))
  expect_type(result3, "character")
  expect_equal(length(result3), 0)
})

test_that("hash_name_consistently handles input validation", {
  # Test with non-character input
  expect_error(hash_name_consistently(123), "names must be a character vector")
  expect_error(hash_name_consistently(c(1, 2, 3)), "names must be a character vector")
  expect_error(hash_name_consistently(list("John")), "names must be a character vector")

  # Test with invalid salt
  expect_error(hash_name_consistently("John", salt = 123), "salt must be a single character string")
  expect_error(hash_name_consistently("John", salt = c("salt1", "salt2")), "salt must be a single character string")

  # Test with invalid normalize_names
  expect_error(hash_name_consistently("John", normalize_names = "invalid"), "normalize_names must be a single logical value")
  expect_error(hash_name_consistently("John", normalize_names = c(TRUE, FALSE)), "normalize_names must be a single logical value")
})

test_that("hash_name_consistently handles different salt values", {
  names <- c("John Smith", "Jane Doe")

  # Test with default salt
  result1 <- hash_name_consistently(names)
  expect_type(result1, "character")
  expect_equal(length(result1), 2)

  # Test with custom salt
  result2 <- hash_name_consistently(names, salt = "custom_salt")
  expect_type(result2, "character")
  expect_equal(length(result2), 2)
  expect_false(identical(result1, result2)) # Different salts should produce different hashes

  # Test with empty salt
  result3 <- hash_name_consistently(names, salt = "")
  expect_type(result3, "character")
  expect_equal(length(result3), 2)
})

test_that("hash_name_consistently handles normalize_names parameter", {
  names <- c("John Smith", "JOHN SMITH", "john smith")

  # Test with normalization (default)
  result1 <- hash_name_consistently(names, normalize_names = TRUE)
  expect_type(result1, "character")
  expect_equal(length(result1), 3)
  expect_true(all(result1 == result1[1])) # All should be identical when normalized

  # Test without normalization
  result2 <- hash_name_consistently(names, normalize_names = FALSE)
  expect_type(result2, "character")
  expect_equal(length(result2), 3)
  expect_false(all(result2 == result2[1])) # Should be different without normalization
})

test_that("hash_name_consistently handles NA and empty values", {
  # Test with NA values
  names_with_na <- c("John Smith", NA, "Jane Doe")
  result1 <- hash_name_consistently(names_with_na)
  expect_type(result1, "character")
  expect_equal(length(result1), 3)
  expect_true(is.na(result1[2])) # NA input should produce NA output

  # Test with empty strings
  names_with_empty <- c("John Smith", "", "Jane Doe")
  result2 <- hash_name_consistently(names_with_empty)
  expect_type(result2, "character")
  expect_equal(length(result2), 3)
  expect_true(is.na(result2[2])) # Empty string should produce NA output

  # Test with whitespace-only strings
  names_with_whitespace <- c("John Smith", "   ", "Jane Doe")
  result3 <- hash_name_consistently(names_with_whitespace)
  expect_type(result3, "character")
  expect_equal(length(result3), 3)
  expect_true(is.na(result3[2])) # Whitespace-only should produce NA output
})

test_that("hash_name_consistently produces consistent hashes", {
  names <- c("John Smith", "Jane Doe")

  # Test that same input produces same hash
  result1 <- hash_name_consistently(names)
  result2 <- hash_name_consistently(names)
  expect_identical(result1, result2)

  # Test that different inputs produce different hashes
  different_names <- c("Bob Johnson", "Alice Brown")
  result3 <- hash_name_consistently(different_names)
  expect_false(identical(result1, result3))
})

test_that("normalize_name_for_matching handles different name formats", {
  # Test with standard names
  names1 <- c("John Smith", "Jane Doe")
  result1 <- normalize_name_for_matching(names1)
  expect_type(result1, "character")
  expect_equal(length(result1), 2)

  # Test with names containing titles
  names2 <- c("Dr. John Smith", "Prof. Jane Doe", "Mr. Bob Johnson")
  result2 <- normalize_name_for_matching(names2)
  expect_type(result2, "character")
  expect_equal(length(result2), 3)

  # Test with names containing punctuation
  names3 <- c("Smith, John", "Doe, Jane", "Johnson, Bob")
  result3 <- normalize_name_for_matching(names3)
  expect_type(result3, "character")
  expect_equal(length(result3), 3)
})

test_that("normalize_name_for_matching handles NA and empty values", {
  # Test with NA values
  names_with_na <- c("John Smith", NA, "Jane Doe")
  result1 <- normalize_name_for_matching(names_with_na)
  expect_type(result1, "character")
  expect_equal(length(result1), 3)
  expect_equal(result1[2], "")

  # Test with empty strings
  names_with_empty <- c("John Smith", "", "Jane Doe")
  result2 <- normalize_name_for_matching(names_with_empty)
  expect_type(result2, "character")
  expect_equal(length(result2), 3)
  expect_equal(result2[2], "")

  # Test with whitespace-only strings
  names_with_whitespace <- c("John Smith", "   ", "Jane Doe")
  result3 <- normalize_name_for_matching(names_with_whitespace)
  expect_type(result3, "character")
  expect_equal(length(result3), 3)
  expect_equal(result3[2], "")
})

test_that("normalize_name_for_matching handles name variations", {
  # Test with different cases
  names_case <- c("JOHN SMITH", "jane doe", "Bob Johnson")
  result1 <- normalize_name_for_matching(names_case)
  expect_type(result1, "character")
  expect_true(all(grepl("^[a-z]", result1))) # All should be lowercase

  # Test with punctuation
  names_punct <- c("Smith, John", "Doe-Jane", "Johnson.Bob")
  result2 <- normalize_name_for_matching(names_punct)
  expect_type(result2, "character")
  expect_false(any(grepl("[[:punct:]]", result2))) # No punctuation should remain

  # Test with extra whitespace
  names_whitespace <- c("  John   Smith  ", "Jane\tDoe", "Bob\nJohnson")
  result3 <- normalize_name_for_matching(names_whitespace)
  expect_type(result3, "character")
  expect_false(any(grepl("\\s{2,}", result3))) # No multiple spaces
})

test_that("normalize_name_for_matching handles title removal", {
  # Test with various titles
  names_with_titles <- c(
    "Dr. John Smith",
    "Prof. Jane Doe",
    "Professor Bob Johnson",
    "Mr. Alice Brown",
    "Mrs. Carol White",
    "Ms. Diana Green",
    "Miss Emma Black"
  )

  result <- normalize_name_for_matching(names_with_titles)
  expect_type(result, "character")
  expect_equal(length(result), 7)

  # Check that titles are removed
  expect_false(any(grepl("\\b(dr|prof|professor|mr|mrs|ms|miss)\\b", result)))
})

test_that("normalize_name_for_matching handles name part sorting", {
  # Test with different name orders
  names_order1 <- c("John Smith", "Smith John")
  result1 <- normalize_name_for_matching(names_order1)
  expect_identical(result1[1], result1[2]) # Should be identical after sorting

  # Test with three-part names
  names_order2 <- c("John Michael Smith", "Smith John Michael", "Michael John Smith")
  result2 <- normalize_name_for_matching(names_order2)
  expect_true(all(result2 == result2[1])) # All should be identical after sorting
})

test_that("hash_name_consistently handles edge cases", {
  # Test with very long names
  long_name <- paste(rep("VeryLongName", 10), collapse = " ")
  result1 <- hash_name_consistently(long_name)
  expect_type(result1, "character")
  expect_equal(length(result1), 1)
  expect_equal(nchar(result1), 8)

  # Test with special characters
  special_names <- c("José María", "François", "Müller", "北京")
  result2 <- hash_name_consistently(special_names)
  expect_type(result2, "character")
  expect_equal(length(result2), 4)
  expect_true(all(nchar(result2) == 8))

  # Test with numeric strings
  numeric_names <- c("123", "456", "789")
  result3 <- hash_name_consistently(numeric_names)
  expect_type(result3, "character")
  expect_equal(length(result3), 3)
  expect_true(all(nchar(result3) == 8))
})
