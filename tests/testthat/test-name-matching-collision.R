test_that("exact matching handles hash collisions as ambiguous", {
  roster <- tibble::tibble(
    preferred_name = c("Alice Smith", "Alicé Smith"),
    student_id = c("S1", "S2"),
    aliases = c(NA_character_, NA_character_)
  )
  # Use plain SHA-256 so minor accent differences may normalize to same canonical
  key <- NULL
  roster <- validate_roster_for_matching(roster, key = key)
  roster <- compute_roster_hashes(roster, key = key)
  idx <- build_roster_hash_index(roster)

  # Find collisions in index
  collisions <- idx[idx$collision, , drop = FALSE]
  expect_true(nrow(collisions) >= 1)
})

