# Internal helpers for privacy-first name matching

# These helpers are intentionally not exported.

#' Normalize a human name to a canonical form (UTF-8)
#'
#' Applies ICU-backed normalization pipeline using stringi:
#' NFKD -> strip combining marks -> full casefold -> trim ->
#' collapse internal whitespace -> NFC.
#'
#' @keywords internal
normalize_name <- function(x) {
  if (is.null(x)) return(NA_character_)
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
  x <- stringi::stri_trans_casefold(x, type = "full")
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
      if (is.na(elem) || identical(elem, "")) return(NA_character_)
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


