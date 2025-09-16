# Extra coverage: vector with NA/empty names and normalize_names flag

library(testthat)
library(engager)

test_that("hash_name_consistently handles vector with NA and empty elements", {
  input <- c("John", NA_character_, "", "Jane")
  out <- hash_name_consistently(input)
  expect_type(out, "character")
  expect_equal(length(out), 4L)
})

test_that("hash_name_consistently differs when normalize_names = FALSE", {
  name <- "John  Doe"
  h_norm <- hash_name_consistently(name, normalize_names = TRUE)
  h_raw  <- hash_name_consistently(name, normalize_names = FALSE)
  expect_false(identical(h_norm, h_raw))
})
