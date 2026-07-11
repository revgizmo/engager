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

test_that("plot_users masks labels at every enabled privacy level", {
  metrics <- tibble::tibble(
    name = c("Alice Smith", "Bob Jones"),
    n = c(3, 2)
  )

  for (privacy_level in c("mask", "privacy_standard", "privacy_strict")) {
    plot <- plot_users(
      metrics,
      metric = "n",
      facet_by = "none",
      mask_by = "name",
      privacy_level = privacy_level
    )

    expect_equal(plot$data$name, c("Student_1", "Student_2"))
    expect_false(any(metrics$name %in% plot$data$name))
  }
})

test_that("plot_users preserves labels only when privacy is disabled", {
  metrics <- tibble::tibble(
    name = c("Alice Smith", "Bob Jones"),
    n = c(3, 2)
  )

  plot <- plot_users(
    metrics,
    metric = "n",
    facet_by = "none",
    privacy_level = "none"
  )

  expect_equal(plot$data$name, metrics$name)
})

test_that("plot_users normalizes vector privacy input before comparison", {
  metrics <- tibble::tibble(
    name = c("Alice Smith", "Bob Jones"),
    n = c(3, 2)
  )

  expect_warning(
    plot <- plot_users(
      metrics,
      metric = "n",
      facet_by = "none",
      mask_by = "rank",
      privacy_level = c("privacy_strict", "none")
    ),
    "privacy_level had length > 1"
  )

  expect_equal(plot$data$name, c("Rank_1", "Rank_2"))
})
