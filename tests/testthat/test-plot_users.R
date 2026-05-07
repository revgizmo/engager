test_that("plot_users produces a ggplot with default masking and no facet", {
  transcript_file <- system.file(
    "extdata/test_transcripts/intro_statistics_week1.vtt",
    package = "engager"
  )
  skip_if(transcript_file == "", "Sample transcript not available")

  metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)
  p <- plot_users(metrics, metric = "n", facet_by = "none", mask_by = "name")
  expect_s3_class(p, "ggplot")
})

test_that("plot_users can facet by section and mask by rank", {
  transcript_file <- system.file(
    "extdata/test_transcripts/intro_statistics_week1.vtt",
    package = "engager"
  )
  skip_if(transcript_file == "", "Sample transcript not available")

  metrics <- summarize_transcript_metrics(transcript_file_path = transcript_file)
  p <- plot_users(metrics, metric = "duration", facet_by = "section", mask_by = "rank")
  expect_s3_class(p, "ggplot")
})
