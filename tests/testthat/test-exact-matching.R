test_that("exact matching assigns student_id and reports unresolved", {
  # Build a simple roster in-memory
  roster <- tibble::tibble(
    preferred_name = c("Alice Smith", "Bob Jones"),
    student_id = c("S1", "S2"),
    aliases = c("A Smith; Alice S", NA_character_)
  )
  tmp <- withr::local_tempfile(fileext = ".csv")
  readr::write_csv(roster, tmp)
  ro <- load_roster(tmp)

  transcripts <- tibble::tibble(
    speaker = c("alice smith", "Carol"),
    timestamp = as.POSIXct(c("2025-01-01 10:00:00", "2025-01-01 10:01:00"), tz = "UTC")
  )
  res <- match_names_workflow(transcripts, ro, options = list(match_strategy = "exact"))
  expect_s3_class(res, "engager_match")
  expect_equal(nrow(res$unresolved), 1)
  expect_true(all(c("reason", "guidance") %in% names(res$unresolved)))
  expect_equal(sum(!is.na(res$transcripts_with_ids$student_id)), 1)
})
