# Public workflow API: detect_unmatched_names(), safe_name_matching_workflow()

#' Detect unmatched names from transcripts against a roster
#'
#' @param transcripts_df Tibble/data.frame of transcript speakers
#' @param roster_df Tibble/data.frame returned by load_roster()
#' @param options List of options; supports match_strategy (default 'exact')
#' @return Tibble with columns: name_hash, occurrence_n, first_seen_at, reason, guidance
#' @export
#' @family name-matching
detect_unmatched_names <- function(transcripts_df, roster_df, options = list()) {
  rlang::check_installed("tibble")
  match_strategy <- options$match_strategy %||% "exact"
  if (!identical(match_strategy, "exact")) {
    match_names_fuzzy()
  }
  rlang::abort("detect_unmatched_names() not yet implemented in MVP scaffolding.",
               class = "engager_not_implemented_error")
}

#' Safe name matching workflow (privacy-first)
#'
#' Returns an object of class 'engager_match' with redacted print/summary.
#'
#' @param transcripts_df Tibble/data.frame of transcript speakers
#' @param roster_df Tibble/data.frame returned by load_roster()
#' @param options List of options; supports match_strategy (default 'exact')
#' @return A list with elements transcripts_with_ids, unresolved, audit
#' @export
#' @family name-matching
safe_name_matching_workflow <- function(transcripts_df, roster_df, options = list()) {
  match_strategy <- options$match_strategy %||% "exact"
  if (!identical(match_strategy, "exact")) {
    match_names_fuzzy()
  }
  rlang::abort("safe_name_matching_workflow() not yet implemented in MVP scaffolding.",
               class = "engager_not_implemented_error")
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


