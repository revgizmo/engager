# Internal helpers for privacy-first name matching

# These helpers are intentionally not exported.

#' Null-coalescing helper
#' @keywords internal
## removed custom %||% helper in favor of explicit null checks at call sites

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
  # Expand student_id to match the number of hashes
  base_student_ids <- if ("student_id" %in% names(roster_df)) roster_df$student_id else NA_character_
  # Use mapply to properly expand each student_id by its corresponding hash length
  student_ids <- as.character(unlist(mapply(rep, base_student_ids, lengths(hashes), SIMPLIFY = FALSE)))
  name_hash_vec <- as.character(unlist(hashes, use.names = FALSE))
  expanded <- tibble::tibble(
    student_id = student_ids,
    name_hash = name_hash_vec
  )
  # Use base R aggregation to avoid dplyr segfault
  unique_hashes <- unique(name_hash_vec)
  idx_list <- lapply(unique_hashes, function(hash) {
    mask <- name_hash_vec == hash
    student_ids_for_hash <- student_ids[mask]
    non_na_students <- student_ids_for_hash[!is.na(student_ids_for_hash)]

    list(
      name_hash = hash,
      n = sum(mask),
      student_id = if (length(unique(non_na_students)) == 1) {
        unique(non_na_students)[1]
      } else {
        NA_character_
      },
      collision = sum(mask) > 1 & length(unique(non_na_students)) == 0
    )
  })

  idx <- do.call(rbind, lapply(idx_list, function(x) {
    data.frame(
      name_hash = x$name_hash,
      student_id = x$student_id,
      collision = x$collision,
      stringsAsFactors = FALSE
    )
  }))
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
    transcripts_df <- derive_speaker_column(transcripts_df)
  }
  canon <- normalize_name(transcripts_df$speaker)
  name_hash <- hash_canonical_name(canon, key = key)
  out <- tibble::as_tibble(transcripts_df)
  out$canonical_name <- canon
  out$name_hash <- name_hash
  out
}

#' Derive a 'speaker' column from common alternatives
#' @keywords internal
derive_speaker_column <- function(df) {
  candidate_cols <- c(
    "speaker", "user_name", "name", "speaker_name", "participant_name", "transcript_name"
  )
  present <- intersect(candidate_cols, names(df))
  if (length(present) >= 1) {
    df$speaker <- df[[present[[1]]]]
    return(df)
  }
  rlang::abort("transcripts_df must have a 'speaker' column.", class = "engager_schema_error")
}

#' Perform exact matching by name_hash against roster index
#' Returns list(transcripts_with_ids, unresolved)
#' @keywords internal
match_names_exact <- function(prepped_transcripts, roster_index, include_name_hash = FALSE) {
  # Use base R merge instead of dplyr::left_join to avoid segfault
  joined <- merge(
    prepped_transcripts,
    roster_index,
    by = "name_hash",
    all.x = TRUE,
    all.y = FALSE
  )

  # Identify unresolved entries using base R
  unresolved_mask <- is.na(joined$student_id) | joined$collision
  unresolved <- joined[unresolved_mask, ]

  # Add reason and guidance columns using base R (only if unresolved has rows)
  if (nrow(unresolved) > 0) {
    unresolved$reason <- ifelse(
      isTRUE(unresolved$collision),
      "collision_ambiguous",
      ifelse(
        is.na(unresolved$student_id),
        "no_candidate",
        "unknown"
      )
    )

    unresolved$guidance <- ifelse(
      unresolved$reason == "collision_ambiguous",
      "Refine roster aliases or use future fuzzy tools",
      ifelse(
        unresolved$reason == "no_candidate",
        "Add alias to roster or correct transcript",
        NA_character_
      )
    )
  }

  # Select only needed columns for unresolved (only if it has rows)
  if (nrow(unresolved) > 0) {
    unresolved_cols <- c("name_hash", "reason", "guidance")
    if ("timestamp" %in% names(unresolved)) {
      unresolved_cols <- c(unresolved_cols, "timestamp")
    }
    unresolved <- unresolved[, unresolved_cols, drop = FALSE]
  }

  # Create transcripts_with_ids by removing sensitive columns
  twi <- joined
  sensitive_cols <- c("canonical_name", "name_hash", "collision")
  twi <- twi[, !names(twi) %in% sensitive_cols, drop = FALSE]

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

# Internal function to validate roster schema for name matching
validate_roster_for_matching <- function(roster_df, key = NULL) {
  required <- c("preferred_name")
  optional <- c("student_id", "formal_name", "transcript_name", "aliases")
  missing_req <- setdiff(required, names(roster_df))

  if (length(missing_req) > 0) {
    rlang::abort(
      message = sprintf("Missing required columns for name matching: %s", paste(missing_req, collapse = ", ")),
      class = "engager_schema_error"
    )
  }

  if (any(is.na(roster_df$preferred_name) | roster_df$preferred_name == "")) {
    rlang::abort("preferred_name must be non-empty for all rows.", class = "engager_schema_error")
  }

  if ("student_id" %in% names(roster_df)) {
    dup_id <- any(duplicated(roster_df$student_id[!is.na(roster_df$student_id)]))
    if (dup_id) {
      rlang::abort("student_id must be unique when present.", class = "engager_schema_error")
    }
  }

  roster_df
}

# Internal function to compute roster hashes for name matching
compute_roster_hashes <- function(roster_df, key = NULL, delimiter = ";", include_formal_as_alias = FALSE) {
  # Compute canonical name (normalized preferred_name)
  roster_df$canonical_name <- normalize_name(roster_df$preferred_name)

  # Parse aliases into list<chr>
  if (!("aliases" %in% names(roster_df))) {
    roster_df$aliases <- vector("list", nrow(roster_df))
  } else {
    delim <- delimiter
    parse_aliases <- function(x) {
      if (is.null(x) || is.na(x) || identical(x, "")) {
        return(character(0))
      }
      parts <- stringr::str_split(x, pattern = sprintf("[%s,|]", stringr::str_replace_all(delim, "\\|", "\\\\|")), n = Inf)[[1]]
      parts <- stringr::str_trim(parts)
      parts <- parts[parts != ""]
      normalize_name(parts)
    }
    roster_df$aliases <- lapply(roster_df$aliases, parse_aliases)
  }

  # Hashes
  resolved_key <- resolve_name_hash_key(key)
  roster_df$name_hash <- hash_canonical_name(roster_df$canonical_name, key = resolved_key)
  roster_df$alias_hashes <- lapply(roster_df$aliases, hash_canonical_name, key = resolved_key)
  roster_df$all_name_hashes <- mapply(
    function(h, hs) unique(c(h, hs)), roster_df$name_hash, roster_df$alias_hashes,
    SIMPLIFY = FALSE
  )

  # Attach spec attributes
  spec <- list(
    schema = "engager_v1",
    norm_chain = "nfkd->strip_marks->casefold(full)->trim->collapse_ws->nfc",
    hash_algo = if (is.null(resolved_key)) "SHA-256" else "HMAC-SHA-256",
    icu_version = stringi::stri_info()[["ICUversion"]],
    collision_detected = FALSE # Will be updated by build_roster_hash_index
  )
  attr(roster_df, "engager_spec") <- spec

  roster_df
}
