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
  match_strategy <- if (is.null(options$match_strategy)) "exact" else options$match_strategy
  include_name_hash <- isTRUE(if (is.null(options$include_name_hash)) FALSE else options$include_name_hash)
  key <- if (is.null(options$key)) NULL else options$key
  if (!identical(match_strategy, "exact")) {
    match_names_fuzzy()
  }
  prepped <- prepare_transcript_names(transcripts_df, key = key)
  idx <- build_roster_hash_index(roster_df)
  res <- match_names_exact(prepped, idx, include_name_hash = TRUE)
  # Use base R aggregation instead of dplyr to avoid segfault
  if (nrow(res$unresolved) > 0) {
    # Group by name_hash, reason, guidance using base R
    group_keys <- paste(res$unresolved$name_hash, res$unresolved$reason, res$unresolved$guidance, sep = "|")
    unique_groups <- unique(group_keys)

    unresolved_list <- lapply(unique_groups, function(key) {
      mask <- group_keys == key
      group_data <- res$unresolved[mask, ]

      list(
        name_hash = group_data$name_hash[1],
        occurrence_n = sum(mask),
        first_seen_at = if ("timestamp" %in% names(group_data)) {
          suppressWarnings(group_data$timestamp[1])
        } else {
          NA
        },
        reason = group_data$reason[1],
        guidance = group_data$guidance[1]
      )
    })

    unresolved <- do.call(rbind, lapply(unresolved_list, function(x) {
      data.frame(
        name_hash = x$name_hash,
        occurrence_n = x$occurrence_n,
        first_seen_at = x$first_seen_at,
        reason = x$reason,
        guidance = x$guidance,
        stringsAsFactors = FALSE
      )
    }))
  } else {
    unresolved <- data.frame(
      name_hash = character(0),
      occurrence_n = integer(0),
      first_seen_at = as.POSIXct(character(0)),
      reason = character(0),
      guidance = character(0),
      stringsAsFactors = FALSE
    )
  }
  if (!include_name_hash) {
    unresolved$name_hash <- NULL
  }
  unresolved
}

#' Match names workflow (privacy-first)
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
match_names_workflow <- function(transcripts_df, roster_df, options = list()) {
  match_strategy <- if (is.null(options$match_strategy)) "exact" else options$match_strategy
  include_name_hash <- isTRUE(if (is.null(options$include_name_hash)) FALSE else options$include_name_hash)
  key <- if (is.null(options$key)) NULL else options$key
  if (!identical(match_strategy, "exact")) {
    match_names_fuzzy()
  }

  # Validate and prepare roster for matching
  roster_df <- validate_roster_for_matching(roster_df, key = key)
  roster_df <- compute_roster_hashes(roster_df, key = key)

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
  # Silent by default; users can inspect the object for counts
  obj
}

#' @export
print.engager_match <- function(x, ...) {
  # Redacted printing: counts only
  n_total <- if (is.null(x$.__n_total)) NA_integer_ else x$.__n_total
  n_matched <- if (is.null(x$.__n_matched)) NA_integer_ else x$.__n_matched
  n_unresolved <- if (is.null(x$.__n_unresolved)) NA_integer_ else x$.__n_unresolved
  # Silent by default; users can inspect the object for counts
  invisible(x)
}

#' @export
summary.engager_match <- function(object, ...) {
  # Redacted summary; future fields can be added without revealing PII
  res <- list(
    total = if (is.null(object$.__n_total)) NA_integer_ else object$.__n_total,
    matched = if (is.null(object$.__n_matched)) NA_integer_ else object$.__n_matched,
    unresolved = if (is.null(object$.__n_unresolved)) NA_integer_ else object$.__n_unresolved
  )
  class(res) <- "summary.engager_match"
  res
}
