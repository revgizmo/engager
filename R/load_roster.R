# Roster loader enforcing engager_v1 schema (scaffold)

#' Load a roster and compute canonical names and hashes
#'
#' Enforces the `engager_v1` schema: requires `preferred_name`; optional
#' `student_id` (unique if present), `formal_name`, `transcript_name`, and
#' `aliases`. Aliases are parsed into a list column (no row explosion), names
#' are normalized with ICU-backed rules, and hashes are computed using
#' SHA-256 or HMAC-SHA-256 based on key precedence.
#'
#' @param path Path to a CSV roster file.
#' @param schema Schema name, default `'engager_v1'`.
#' @param key Optional override key for name hashing (HMAC). If `NULL`, falls
#'   back to `Sys.getenv("ENGAGER_NAME_HASH_KEY")` then
#'   `getOption("engager.name_hash_key")`.
#' @param delimiter Character used to split `aliases`. Default `";"`. Common
#'   delimiters like `,` and `|` are also supported when present.
#' @param include_formal_as_alias Logical; if `TRUE`, includes normalized
#'   `formal_name` as an additional alias.
#' @param ... Additional arguments passed to `readr::read_csv()`.
#'
#' @return A tibble with columns including `canonical_name`, `name_hash`,
#'   `alias_hashes` (list<chr>), and `all_name_hashes` (list<chr>). An
#'   `engager_spec` attribute is attached describing hashing and normalization.
#'
#' @examples
#' tmp <- tempfile(fileext = ".csv")
#' dat <- tibble::tibble(
#'   preferred_name = c("Alice Smith", "Bob Jones"),
#'   student_id = c("S1", "S2"),
#'   aliases = c("A Smith; Alice S", NA_character_)
#' )
#' readr::write_csv(dat, tmp)
#' ro <- load_roster(tmp)
#' names(ro)
#'
#' @export
#' @family name-matching
load_roster <- function(path,
                        ..., 
                        schema = "engager_v1",
                        key = NULL,
                        delimiter = ";",
                        include_formal_as_alias = FALSE) {
  if (!identical(schema, "engager_v1")) {
    rlang::abort(sprintf("Unsupported schema: %s", schema), class = "engager_schema_error")
  }
  ro <- readr::read_csv(path, show_col_types = FALSE, ...)
  ro <- tibble::as_tibble(ro)

  required <- c("preferred_name")
  optional <- c("student_id", "formal_name", "transcript_name", "aliases")
  missing_req <- setdiff(required, names(ro))
  if (length(missing_req) > 0) {
    rlang::abort(
      message = sprintf("Missing required columns: %s", paste(missing_req, collapse = ", ")),
      class = "engager_schema_error"
    )
  }
  if (any(is.na(ro$preferred_name) | ro$preferred_name == "")) {
    rlang::abort("preferred_name must be non-empty for all rows.", class = "engager_schema_error")
  }
  if ("student_id" %in% names(ro)) {
    dup_id <- any(duplicated(ro$student_id[!is.na(ro$student_id)]))
    if (dup_id) {
      rlang::abort("student_id must be unique when present.", class = "engager_schema_error")
    }
  } else {
    ro$student_id <- NA_character_
  }

  # Normalize preferred/formal/transcript
  ro$canonical_name <- normalize_name(ro$preferred_name)

  if (isTRUE(include_formal_as_alias) && "formal_name" %in% names(ro)) {
    if (!("aliases" %in% names(ro))) ro$aliases <- list()
    add_formal <- normalize_name(ro$formal_name)
    ro$aliases <- purrr::map2(ro$aliases, add_formal, ~unique(c(.x, .y)))
  }

  # Parse aliases into list<chr>
  if (!("aliases" %in% names(ro))) {
    ro$aliases <- vector("list", nrow(ro))
  } else {
    delim <- delimiter
    parse_aliases <- function(x) {
      if (is.na(x) || identical(x, "")) return(character(0))
      parts <- stringr::str_split(x, pattern = sprintf("[%s,|]", stringr::str_replace_all(delim, "\\|", "\\\\|")), n = Inf)[[1]]
      parts <- stringr::str_trim(parts)
      parts <- parts[parts != ""]
      normalize_name(parts)
    }
    ro$aliases <- lapply(ro$aliases, parse_aliases)
  }

  # Hashes
  resolved_key <- resolve_name_hash_key(key)
  ro$name_hash <- hash_canonical_name(ro$canonical_name, key = resolved_key)
  ro$alias_hashes <- lapply(ro$aliases, hash_canonical_name, key = resolved_key)
  ro$all_name_hashes <- mapply(
    function(h, hs) unique(c(h, hs)), ro$name_hash, ro$alias_hashes,
    SIMPLIFY = FALSE
  )

  # Collision detection in roster
  idx <- build_roster_hash_index(ro)
  if (any(idx$collision)) {
    # Note: strict policy—do not assign matches for colliding hashes
    # Collisions are flagged and will cause unresolved in workflow
    # We continue but attach a warning message
    warning("Detected ambiguous name hash collisions in roster; affected hashes will be unresolved.")
  }

  # Attach spec attributes
  spec <- list(
    schema = schema,
    norm_chain = "nfkd->strip_marks->casefold(full)->trim->collapse_ws->nfc",
    hash_algo = "sha256",
    hmac_used = !is.null(resolved_key),
    icu_version = stringi::stri_info()[["ICUversion"]],
    spec_version = "1"
  )
  attr(ro, "engager_spec") <- spec
  ro
}

# Internal function - no documentation needed
load_roster <- function(
    data_folder = ".",
    roster_file = "roster.csv",
    strict_errors = FALSE) {
  roster_file_path <- file.path(data_folder, roster_file)

  if (file.exists(roster_file_path)) {
    roster_data <- readr::read_csv(roster_file_path, show_col_types = FALSE)

    # Check if enrolled column exists and filter if it does
    if ("enrolled" %in% names(roster_data)) {
      # Use base R subsetting to avoid segmentation faults
      roster_data <- roster_data[roster_data$enrolled == TRUE, ]
    }

    roster_tbl <- tibble::as_tibble(roster_data)
    # Validate minimal roster schema where possible
    try(validate_schema(roster_tbl, zse_schema$roster$required), silent = TRUE)
    return(roster_tbl)
  } else {
    if (strict_errors) {
      # Throw error when file doesn't exist for enhanced error handling
      abort_zse(paste0("Roster file not found at `", roster_file_path, "`"), class = "zse_input_error")
    } else {
      # Return empty tibble with expected structure when file doesn't exist (backward compatibility)
      return(tibble::tibble())
    }
  }
}
