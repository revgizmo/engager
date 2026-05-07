test_that("write_metrics writes CSV with masking", {
  transcript_file <- system.file(
    "extdata/test_transcripts/intro_statistics_week1.vtt",
    package = "engager"
  )
  skip_if(transcript_file == "", "Sample transcript not available")

  metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)

  out <- write_metrics(metrics, what = "engagement", path = tmp)
  expect_true(file.exists(tmp))
  # Should not contain raw names like typical English-looking full names
  txt <- readLines(tmp, warn = FALSE)
  expect_true(any(grepl("Student\\s+\\d+", txt)))
  expect_s3_class(out, "tbl_df")
})
