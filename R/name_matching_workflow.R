# Public workflow API: detect_unmatched_names(), safe_name_matching_workflow()

#' Detect unmatched names from transcripts against a roster
#'
#' @param transcripts_df Tibble/data.frame with at least a `speaker` column.
#' @param roster_df Tibble/data.frame returned by `load_roster()`.
#' @param options List of options; supports `match_strategy` (default `'exact'`)
#'   and `include_name_hash` (default `FALSE`).
#' @return Tibble with columns: `name_hash`, `occurrence_n`, `first_seen_at`,
#'   `reason`, `guidance`. `name_hash` omitted unless `include_name_hash = TRUE`.
#' @export
#' @family name-matching
detect_unmatched_names <- function(transcripts_df, roster_df, options = list()) {
  match_strategy <- options$match_strategy %||% "exact"
  include_name_hash <- isTRUE(options$include_name_hash %||% FALSE)
  key <- options$key %||% NULL
  if (!identical(match_strategy, "exact")) {
    match_names_fuzzy()
  }
  prepped <- prepare_transcript_names(transcripts_df, key = key)
  idx <- build_roster_hash_index(roster_df)
  res <- match_names_exact(prepped, idx, include_name_hash = TRUE)
  unresolved <- res$unresolved |>
    dplyr::group_by(name_hash, reason, guidance) |>
    dplyr::summarise(
      occurrence_n = dplyr::n(),
      first_seen_at = suppressWarnings(dplyr::first(if ("timestamp" %in% names(res$unresolved)) res$unresolved$timestamp else NA)),
      .groups = "drop"
    ) |>
    dplyr::select(name_hash, occurrence_n, first_seen_at, reason, guidance)
  if (!include_name_hash) {
    unresolved$name_hash <- NULL
  }
  unresolved
}

#' Safe name matching workflow (privacy-first)
#'
#' Returns an object of class 'engager_match' with redacted print/summary.
#'
#' @param transcripts_df Tibble/data.frame with at least a `speaker` column.
#' @param roster_df Tibble/data.frame returned by `load_roster()`.
#' @param options List of options; supports `match_strategy` (default `'exact'`)
#'   and `include_name_hash` (default `FALSE`).
#' @return A list with elements `transcripts_with_ids`, `unresolved`, and
#'   `audit`. Returns an object of class `'engager_match'` with redacted
#'   `print()` and `summary()` methods.
#' @export
#' @family name-matching
safe_name_matching_workflow <- function(transcripts_df, roster_df, options = list()) {
  match_strategy <- options$match_strategy %||% "exact"
  include_name_hash <- isTRUE(options$include_name_hash %||% FALSE)
  key <- options$key %||% NULL
  if (!identical(match_strategy, "exact")) {
    match_names_fuzzy()
  }
  prepped <- prepare_transcript_names(transcripts_df, key = key)
  idx <- build_roster_hash_index(roster_df)
  match_res <- match_names_exact(prepped, idx, include_name_hash = include_name_hash)

  twi <- match_res$transcripts_with_ids
  unresolved <- match_res$unresolved
  audit <- build_match_audit(
    roster_spec = attr(roster_df, "engager_spec"),
    hmac_used = !is.null(resolve_name_hash_key(key)),
    icu_version = stringi::stri_info()[["ICUversion"]]
  )

  obj <- list(
    transcripts_with_ids = twi,
    unresolved = unresolved,
    audit = audit,
    .__n_total = nrow(prepped),
    .__n_matched = sum(!is.na(twi$student_id)),
    .__n_unresolved = nrow(unresolved)
  )
  class(obj) <- c("engager_match", class(obj))
  message(sprintf(
    "Matched %s/%s transcript speakers (%s unresolved).",
    obj$.__n_matched, obj$.__n_total, obj$.__n_unresolved
  ))
  obj
}

#' @export
print.engager_match <- function(x, ...) {
  # Redacted printing: counts only
  n_total <- x$.__n_total %||% NA_integer_
  n_matched <- x$.__n_matched %||% NA_integer_
  n_unresolved <- x$.__n_unresolved %||% NA_integer_
  message(sprintf("engager_match: %s total, %s matched, %s unresolved",
                  n_total, n_matched, n_unresolved))
  invisible(x)
}

#' @export
summary.engager_match <- function(object, ...) {
  # Redacted summary; future fields can be added without revealing PII
  res <- list(
    total = object$.__n_total %||% NA_integer_,
    matched = object$.__n_matched %||% NA_integer_,
    unresolved = object$.__n_unresolved %||% NA_integer_
  )
  class(res) <- "summary.engager_match"
  res
}


