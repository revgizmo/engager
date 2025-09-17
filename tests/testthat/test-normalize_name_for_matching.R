# Tests for internal normalize_name_for_matching helper

library(testthat)
library(engager)

# Access internal function
normalize_name_for_matching <- engager:::normalize_name_for_matching

test_that("normalize_name_for_matching handles NA and empty values", {
  input <- c("John Smith", NA, " ")
  out <- normalize_name_for_matching(input)
  expect_type(out, "character")
  expect_equal(length(out), 3L)
  expect_equal(out[2], "")
  expect_equal(out[3], "")
})

test_that("normalize_name_for_matching lowercases, strips punctuation, collapses spaces", {
  input <- c("John\tSmith", "Smith, John", "Dr. Jane-Doe")
  out <- normalize_name_for_matching(input)
  # punctuation removed and spaces normalized
  expect_equal(out[1], "john smith")
  expect_equal(out[2], "john smith")
  # title removed, hyphen treated as space and collapsed
  expect_equal(out[3], "doe jane")
})

test_that("normalize_name_for_matching sorts name parts for consistent ordering", {
  input <- c("Smith John", "John Smith", "  john   SMITH  ")
  out <- normalize_name_for_matching(input)
  expect_true(all(out == "john smith"))
})

test_that("normalize_name_for_matching returns empty string for fully empty names", {
  input <- c("", "   ")
  out <- normalize_name_for_matching(input)
  expect_identical(out, c("", ""))
})
