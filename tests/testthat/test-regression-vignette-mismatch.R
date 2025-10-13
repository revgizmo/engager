# Regression test: ensure no column length mismatches after consolidation/processing

library(testthat)
library(engager)

test_that("consolidate_transcript returns consistent column lengths", {
  tf <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "engager")
  skip_if_not(file.exists(tf), "sample transcript not available")

  tr <- load_zoom_transcript(tf)
  expect_gt(nrow(tr), 0)

  cons <- consolidate_transcript(tr, max_pause_sec = 1)
  expect_true(all(vapply(cons, length, integer(1)) == nrow(cons)))
})

test_that("process_zoom_transcript returns consistent column lengths", {
  tf <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt", package = "engager")
  skip_if_not(file.exists(tf), "sample transcript not available")

  proc <- process_zoom_transcript(transcript_file_path = tf, consolidate_comments = TRUE, add_dead_air = TRUE)
  expect_s3_class(proc, "tbl_df")
  expect_true(all(vapply(proc, length, integer(1)) == nrow(proc)))
  expect_true(all(c("name", "comment", "start", "end") %in% names(proc)))
})
