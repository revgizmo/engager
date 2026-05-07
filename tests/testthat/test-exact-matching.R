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

test_that("alias parsing handles regex metacharacter delimiters safely", {
  roster <- tibble::tibble(
    preferred_name = "Alice Smith",
    student_id = "S1",
    aliases = "A Smith[Ally^Alice S"
  )

  hashed <- engager:::compute_roster_hashes(roster, delimiter = "[^")

  expect_equal(
    hashed$aliases[[1]],
    engager:::normalize_name(c("A Smith", "Ally", "Alice S"))
  )
})

test_that("alias parsing preserves comma and pipe fallback delimiters", {
  roster <- tibble::tibble(
    preferred_name = "Bob Jones",
    student_id = "S2",
    aliases = "B Jones,Bobby|Robert"
  )

  hashed <- engager:::compute_roster_hashes(roster, delimiter = "[")

  expect_equal(
    hashed$aliases[[1]],
    engager:::normalize_name(c("B Jones", "Bobby", "Robert"))
  )
})

test_that("exact matching preserves transcript row order", {
  roster <- tibble::tibble(
    preferred_name = c("Zoey Alpha", "Amir Beta", "Mina Gamma"),
    student_id = c("S1", "S2", "S3")
  )

  transcripts <- tibble::tibble(
    speaker = c("Mina Gamma", "Zoey Alpha", "Amir Beta", "Zoey Alpha"),
    timestamp = as.POSIXct(
      c(
        "2025-01-01 10:03:00",
        "2025-01-01 10:01:00",
        "2025-01-01 10:02:00",
        "2025-01-01 10:04:00"
      ),
      tz = "UTC"
    )
  )

  res <- match_names_workflow(transcripts, roster, options = list(match_strategy = "exact"))

  expect_equal(res$transcripts_with_ids$speaker, transcripts$speaker)
  expect_equal(res$transcripts_with_ids$timestamp, transcripts$timestamp)
})
