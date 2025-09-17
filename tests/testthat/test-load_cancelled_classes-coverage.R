# Coverage tests for load_cancelled_classes edge cases

library(testthat)
library(engager)

test_that("load_cancelled_classes returns blank template when file missing", {
  tmp <- withr::local_tempdir()
  out <- load_cancelled_classes(data_folder = tmp, cancelled_classes_file = "missing.csv")
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  # Should not create file by default
  expect_false(file.exists(file.path(tmp, "missing.csv")))
})

test_that("load_cancelled_classes can write blank template when requested", {
  tmp <- withr::local_tempdir()
  out <- load_cancelled_classes(
    data_folder = tmp,
    cancelled_classes_file = "new.csv",
    write_blank_cancelled_classes = TRUE
  )
  expect_s3_class(out, "tbl_df")
  expect_true(file.exists(file.path(tmp, "new.csv")))
  # Subsequent call should read the file
  out2 <- load_cancelled_classes(data_folder = tmp, cancelled_classes_file = "new.csv")
  expect_s3_class(out2, "tbl_df")
})
