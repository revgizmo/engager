# Internal helpers for privacy-first name matching

# These helpers are intentionally not exported.

#' Null-coalescing helper
#' @keywords internal
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Normalize a human name to a canonical form (UTF-8)
#'
#' Applies ICU-backed normalization pipeline using stringi:
#' NFKD -> strip combining marks -> full casefold -> trim ->
#' collapse internal whitespace -> NFC.
#'
#' @keywords internal
normalize_name <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }
  x <- as.character(x)
  # Ensure UTF-8
  x <- stringi::stri_enc_toutf8(x)
  # NFKD decomposition
  x <- stringi::stri_trans_nfkd(x)
  # Strip combining marks
  x <- stringi::stri_replace_all_regex(
    x,
    "\\p{M}+",
    "",
    opts_regex = stringi::stri_opts_regex(case_insensitive = FALSE)
  )
  # Full casefold (locale-independent)
  x <- stringi::stri_trans_casefold(x)
  # Trim
  x <- stringi::stri_trim_both(x)
  # Collapse internal whitespace to single spaces
  x <- stringi::stri_replace_all_regex(x, "\\s+", " ")
  # NFC recomposition
  x <- stringi::stri_trans_nfc(x)
  x
}

#' Resolve the name hash key using precedence
#'
#' Precedence: explicit function argument >
#'   Sys.getenv("ENGAGER_NAME_HASH_KEY") >
#'   getOption("engager.name_hash_key", NULL)
#'
#' @keywords internal
resolve_name_hash_key <- function(key) {
  if (!is.null(key) && !identical(key, "")) {
    return(as.character(key))
  }
  env_key <- Sys.getenv("ENGAGER_NAME_HASH_KEY", unset = "")
  if (!identical(env_key, "")) {
    return(env_key)
  }
  opt_key <- getOption("engager.name_hash_key", NULL)
  if (!is.null(opt_key) && !identical(opt_key, "")) {
    return(as.character(opt_key))
  }
  NULL
}

#' Hash a canonicalized name using SHA-256 or HMAC-SHA-256
#'
#' Returns lowercase hex string. Uses openssl for both plain and HMAC.
#'
#' @param canonical_name Character vector of normalized names
#' @param key Optional secret key for HMAC-SHA-256
#' @param algo Currently only "sha256" supported
#' @keywords internal
hash_canonical_name <- function(canonical_name,
                                key = NULL,
                                algo = "sha256") {
  if (!identical(algo, "sha256")) {
    rlang::abort(
      message = sprintf("Unsupported hash algo: %s", algo),
      class = "engager_schema_error"
    )
  }
  key <- resolve_name_hash_key(key)
  vapply(
    X = as.character(canonical_name),
    FUN = function(elem) {
      if (is.na(elem) || identical(elem, "")) {
        return(NA_character_)
      }
      if (is.null(key)) {
        # plain SHA-256
        as.character(openssl::sha256(elem))
      } else {
        # HMAC-SHA-256 with provided/precedence key
        as.character(openssl::sha256(elem, key = charToRaw(key)))
      }
    },
    FUN.VALUE = character(1)
  )
}

#' Fuzzy matching stub (not implemented)
#'
#' Accepts the same inputs as future implementation but aborts with a clear
#' message. This keeps the API future-proof without enabling behavior now.
#'
#' @keywords internal
match_names_fuzzy <- function(...) {
  rlang::abort(
    message = "Fuzzy matching is not implemented in the MVP. Use match_strategy='exact'.",
    class = "engager_not_implemented_error"
  )
}

# --- Additional internal helpers for exact matching ---

#' Build a mapping from name_hash to unique student_id (or mark collision)
#'
#' Returns a tibble with columns: name_hash, student_id, collision
#' where collision is TRUE if the hash corresponds to multiple students.
#' @keywords internal
build_roster_hash_index <- function(roster_df) {
  # Expect columns: student_id (optional), name_hash, all_name_hashes (list<chr>)
  hashes <- roster_df$all_name_hashes
  if (!is.list(hashes)) {
    rlang::abort("Expected list<chr> in all_name_hashes.", class = "engager_schema_error")
  }
  expanded <- tibble::tibble(
    student_id = roster_df$student_id %||% NA_character_,
    name_hash = unlist(hashes, use.names = FALSE)
  )
  expanded <- dplyr::mutate(expanded, student_id = as.character(student_id))
  idx <- expanded |>
    dplyr::group_by(name_hash) |>
    dplyr::summarise(
      n = dplyr::n(),
      student_id = if (dplyr::n_distinct(student_id[!is.na(student_id)]) == 1) {
        unique(student_id[!is.na(student_id)])
      } else {
        NA_character_
      },
      .groups = "drop"
    ) |>
    dplyr::mutate(collision = n > 1 & is.na(student_id)) |>
    dplyr::select(name_hash, student_id, collision)
  idx
}

#' Convert aliases list column to long form (internal)
#' @keywords internal
aliases_long <- function(roster_df) {
  stopifnot(is.list(roster_df$aliases))
  tibble::tibble(
    row_id = seq_len(nrow(roster_df)),
    aliases = roster_df$aliases
  ) |>
    tidyr::unnest_longer(aliases, values_to = "alias", indices_include = FALSE)
}

#' Prepare transcript names: normalize and hash speaker names
#' Expects column 'speaker'. Optional 'timestamp'.
#' @keywords internal
prepare_transcript_names <- function(transcripts_df, key = NULL) {
  if (!("speaker" %in% names(transcripts_df))) {
    rlang::abort("transcripts_df must have a 'speaker' column.", class = "engager_schema_error")
  }
  canon <- normalize_name(transcripts_df$speaker)
  name_hash <- hash_canonical_name(canon, key = key)
  out <- tibble::as_tibble(transcripts_df)
  out$canonical_name <- canon
  out$name_hash <- name_hash
  out
}

#' Perform exact matching by name_hash against roster index
#' Returns list(transcripts_with_ids, unresolved)
#' @keywords internal
match_names_exact <- function(prepped_transcripts, roster_index, include_name_hash = FALSE) {
  joined <- dplyr::left_join(
    prepped_transcripts,
    roster_index,
    by = dplyr::join_by(name_hash)
  )
  # Unresolved reasons
  unresolved <- dplyr::filter(joined, is.na(student_id) | collision)
  unresolved <- dplyr::mutate(
    unresolved,
    reason = dplyr::case_when(
      isTRUE(collision) ~ "collision_ambiguous",
      is.na(student_id) ~ "no_candidate",
      TRUE ~ "unknown"
    ),
    guidance = dplyr::case_when(
      reason == "collision_ambiguous" ~ "Refine roster aliases or use future fuzzy tools",
      reason == "no_candidate" ~ "Add alias to roster or correct transcript",
      TRUE ~ NA_character_
    )
  ) |>
    dplyr::select(name_hash, reason, guidance, dplyr::any_of(c("timestamp")))

  # Redact name_hash in transcripts unless requested
  twi <- dplyr::transmute(
    joined,
    dplyr::across(-dplyr::any_of(c("canonical_name", "name_hash", "collision"))),
    student_id = student_id
  )
  if (include_name_hash) {
    twi$name_hash <- joined$name_hash
  }

  list(transcripts_with_ids = twi, unresolved = unresolved)
}

#' Build match audit structure
#' @keywords internal
build_match_audit <- function(roster_spec, hmac_used, icu_version, algo = "sha256") {
  list(
    algo = algo,
    hmac_used = isTRUE(hmac_used),
    icu_version = icu_version,
    spec = roster_spec
  )
}
