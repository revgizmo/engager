test_that("write_unresolved blocks raw export unless option enabled", {
  tbl <- tibble::tibble(
    name_hash = c("abc", "def"),
    occurrence_n = c(2L, 1L),
    first_seen_at = as.POSIXct(NA),
    reason = c("no_candidate", "collision_ambiguous"),
    guidance = c("add alias", "refine roster")
  )
  out <- withr::local_tempfile(fileext = ".csv")
  expect_error(write_unresolved(tbl, out, include_raw = TRUE), class = "engager_privacy_error")
  # hashed-only ok
  p <- write_unresolved(tbl, out, include_raw = FALSE, overwrite = TRUE)
  expect_true(file.exists(p))
})
