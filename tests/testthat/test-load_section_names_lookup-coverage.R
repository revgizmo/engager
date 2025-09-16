# Additional coverage for load_section_names_lookup alternate file names

library(testthat)
library(engager)

test_that("load_section_names_lookup accepts alternate names_lookup_file parameter", {
  out_csv <- load_section_names_lookup(names_lookup_file = "section_names_lookup_alt.csv")
  expect_true(is.data.frame(out_csv) || is.list(out_csv))

  out_txt <- load_section_names_lookup(names_lookup_file = "section_names_lookup.txt")
  expect_true(is.data.frame(out_txt) || is.list(out_txt))
})
