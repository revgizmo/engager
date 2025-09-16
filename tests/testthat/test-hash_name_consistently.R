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
})
