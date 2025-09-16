# Coverage tests for ensure_privacy ferpa_strict/standard verbose paths

library(testthat)
library(engager)

test_that("ensure_privacy executes ferpa_strict/standard without error when verbose", {
  old_verbose <- getOption("engager.verbose", NULL)
  on.exit(options(engager.verbose = old_verbose), add = TRUE)
  options(engager.verbose = TRUE)

  df <- tibble::tibble(name = c("Alice","Bob"), comment = c("Hi","Hello"))

  out1 <- ensure_privacy(df, privacy_level = "ferpa_strict")
  out2 <- ensure_privacy(df, privacy_level = "ferpa_standard")
  expect_s3_class(out1, "tbl_df")
  expect_s3_class(out2, "tbl_df")
})

test_that("ensure_privacy warns when privacy_level = none", {
  df <- tibble::tibble(name = c("Alice","Bob"), comment = c("Hi","Hello"))
  expect_warning(ensure_privacy(df, privacy_level = "none"))
})
