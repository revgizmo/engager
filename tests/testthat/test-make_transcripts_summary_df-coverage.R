# Additional coverage for make_transcripts_summary_df

library(testthat)
library(engager)

test_that("make_transcripts_summary_df returns empty tibble for empty input", {
  empty <- tibble::tibble()
  out <- make_transcripts_summary_df(empty)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  expect_true(all(c("section", "preferred_name", "session_ct", "n", "duration", "wordcount", "wpm", "perc_n", "perc_duration", "perc_wordcount") %in% names(out)))
  # Missing columns path
  df2 <- tibble::tibble(section = c("A","A"), preferred_name = c("X","Y"))
  expect_warning(make_transcripts_summary_df(df2))
})

test_that("make_transcripts_summary_df returns typed columns for schema-only input", {
  empty_schema <- tibble::tibble(
    section = character(),
    preferred_name = character(),
    n = numeric(),
    duration = numeric(),
    wordcount = numeric()
  )

  out <- make_transcripts_summary_df(empty_schema)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  expect_identical(
    names(out),
    c("section", "preferred_name", "session_ct", "n", "duration", "wordcount", "wpm", "perc_n", "perc_duration", "perc_wordcount")
  )
})

test_that("make_transcripts_summary_df aggregates and computes percentages", {
  df <- tibble::tibble(
    section = c("S1", "S1", "S1", "S2"),
    preferred_name = c("A", "A", "B", "A"),
    n = c(1, 2, 3, 4),
    duration = c(10, 20, 30, 40),
    wordcount = c(100, 200, 300, 400)
  )
  out <- make_transcripts_summary_df(df)
  expect_s3_class(out, "tbl_df")
  # Totals per S1: A n=3,dur=30,words=300 ; B n=3,dur=30,words=300
  s1 <- out[out$section == "S1", ]
  expect_equal(sum(s1$n), 6)
  expect_equal(sum(s1$duration), 60)
  expect_equal(sum(s1$wordcount), 600)
  # Percent columns sum to ~100 per section (allowing numeric tolerance)
  expect_lt(abs(sum(s1$perc_n) - 100), 1e-6)
  expect_lt(abs(sum(s1$perc_duration) - 100), 1e-6)
  expect_lt(abs(sum(s1$perc_wordcount) - 100), 1e-6)
})

test_that("make_transcripts_summary_df handles zero and NA durations without NaNs", {
  df <- tibble::tibble(
    section = c("S1", "S1", "S2", "S2"),
    preferred_name = c("A", "B", "A", "B"),
    n = c(0, 0, 1, 1),
    duration = c(0, NA, 0, 10),
    wordcount = c(0, 0, 0, 100)
  )
  out <- make_transcripts_summary_df(df)
  expect_s3_class(out, "tbl_df")
  expect_true(all(is.finite(out$perc_n) | is.na(out$perc_n)))
  expect_true(all(is.finite(out$perc_duration) | is.na(out$perc_duration)))
  expect_true(all(is.finite(out$perc_wordcount) | is.na(out$perc_wordcount)))
})

test_that("make_transcripts_summary_df handles an all-zero section safely", {
  df <- tibble::tibble(
    section = c("Z", "Z", "Y"),
    preferred_name = c("a", "b", "c"),
    n = c(0, 0, 1),
    duration = c(0, 0, 5),
    wordcount = c(0, 0, 50)
  )
  out <- make_transcripts_summary_df(df)
  expect_s3_class(out, "tbl_df")
  z <- out[out$section == "Z", ]
  expect_true(all(is.na(z$perc_n) | is.finite(z$perc_n)))
  expect_true(all(is.na(z$perc_duration) | is.finite(z$perc_duration)))
  expect_true(all(is.na(z$perc_wordcount) | is.finite(z$perc_wordcount)))
})
