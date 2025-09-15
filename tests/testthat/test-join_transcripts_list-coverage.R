# Additional coverage for join_transcripts_list simplified behavior

library(testthat)
library(engager)

test_that("join_transcripts_list returns empty tibble with expected columns", {
  out <- join_transcripts_list(
    df_zoom_recorded_sessions = tibble::tibble(),
    df_transcript_files = tibble::tibble(),
    df_cancelled_classes = tibble::tibble()
  )
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  expect_equal(names(out), c(
    "section", "match_start_time", "match_end_time", "start_time_local", "session_num"
  ))
})

test_that("join_transcripts_list accepts NULLs and still returns proper structure", {
  out <- join_transcripts_list(NULL, NULL, NULL)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
})
