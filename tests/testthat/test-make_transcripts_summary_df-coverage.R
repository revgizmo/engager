# Additional coverage for make_transcripts_summary_df

library(testthat)
library(engager)

test_that("make_transcripts_summary_df returns empty tibble for empty input", {
  empty <- tibble::tibble()
  out <- make_transcripts_summary_df(empty)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  expect_true(all(c("section","preferred_name","session_ct","n","duration","wordcount","wpm","perc_n","perc_duration","perc_wordcount") %in% names(out)))
})

test_that("make_transcripts_summary_df aggregates and computes percentages", {
  df <- tibble::tibble(
    section = c("S1","S1","S1","S2"),
    preferred_name = c("A","A","B","A"),
    n = c(1,2,3,4),
    duration = c(10,20,30,40),
    wordcount = c(100,200,300,400)
  )
  out <- make_transcripts_summary_df(df)
  expect_s3_class(out, "tbl_df")
  # Totals per S1: A n=3,dur=30,words=300 ; B n=3,dur=30,words=300
  s1 <- out[out$section=="S1",]
  expect_equal(sum(s1$n), 6)
  expect_equal(sum(s1$duration), 60)
  expect_equal(sum(s1$wordcount), 600)
  # Percent columns sum to ~100 per section (allowing numeric tolerance)
  expect_lt(abs(sum(s1$perc_n) - 100), 1e-6)
  expect_lt(abs(sum(s1$perc_duration) - 100), 1e-6)
  expect_lt(abs(sum(s1$perc_wordcount) - 100), 1e-6)
})
