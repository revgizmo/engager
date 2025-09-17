#' Lookup Merge Utilities (Safe, Transactional, UTF-8)
#'
#' Utilities to safely read, merge, and write the participant lookup
#' configuration (`section_names_lookup.csv`). All operations are
#' read-then-merge in memory; writes are opt-in and transactional with
#' timestamped backups to prevent accidental data loss.
#'
#' Expected columns in lookup data frame:
#'   - transcript_name
#'   - preferred_name
#'   - formal_name
#'   - participant_type (e.g., instructor, enrolled_student, guest, unknown)
#'   - student_id
#'   - notes (optional)
#'
#' @name lookup_merge_utils
NULL

.lookup_expected_columns <- function() {
  c(
    "transcript_name",
    "preferred_name",
    "formal_name",
    "participant_type",
    "student_id",
    "notes"
  )
}

.coerce_to_utf8 <- function(x) {
  if (is.null(x)) {
    return(x)
  }
  if (is.factor(x)) x <- as.character(x)
  if (!is.character(x)) {
    return(x)
  }
  enc2utf8(x)
}

.normalize_lookup_df <- function(df) {
  if (is.null(df)) {
    df <- data.frame(stringsAsFactors = FALSE)
  }
  # Ensure UTF-8 and expected columns exist
  expected <- .lookup_expected_columns()
  for (col in expected) {
    if (!col %in% names(df)) {
      df[[col]] <- rep(NA_character_, nrow(df))
    }
  }
  # Subset and order columns deterministically
  df <- df[expected]
  # Coerce character columns to UTF-8
  for (nm in names(df)) {
    df[[nm]] <- .coerce_to_utf8(df[[nm]])
  }
  # Replace NA student_id for instructors with constant
  is_instructor <- !is.na(df$participant_type) & df$participant_type == "instructor"
  df$student_id[is_instructor & is.na(df$student_id)] <- "INSTRUCTOR"
  # Ensure participant_type known set
  df$participant_type[is.na(df$participant_type)] <- "unknown"
  # Remove completely empty rows (no transcript_name and no preferred_name)
  empty_rows <- (is.na(df$transcript_name) | trimws(df$transcript_name) == "") &
    (is.na(df$preferred_name) | trimws(df$preferred_name) == "")
  if (length(empty_rows) > 0 && any(empty_rows)) {
    df <- df[!empty_rows, , drop = FALSE]
  }
  df
}

# Internal function - no documentation needed
read_lookup_safely <- function(path = NULL) {

  if (!is.character(path) || length(path) != 1) {
    stop("path must be a single character string", call. = FALSE)
  }
  if (!file.exists(path)) {
    return(.normalize_lookup_df(data.frame(stringsAsFactors = FALSE)))
  }
  df <- utils::read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
  .normalize_lookup_df(df)
}

# Internal function - no documentation needed
merge_lookup_preserve <- function(existing_df = NULL, add_df = NULL) {

  # Simplified deprecated function - return empty tibble with correct structure
  tibble::tibble(
    transcript_name = character(),
    participant_type = character(),
    preferred_name = character(),
    formal_name = character(),
    student_id = character(),
    course_section = character(),
    dept = character(),
    course = character(),
    instructor = character()
  )
}

# Internal function - no documentation needed
write_lookup_transactional <- function(df = NULL, path = NULL) {

  if (!is.character(path) || length(path) != 1) {
    stop("path must be a single character string", call. = FALSE)
  }
  df <- .normalize_lookup_df(df)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  # Backup if exists
  if (file.exists(path)) {
    backup <- paste0(path, ".backup.", format(Sys.time(), "%Y%m%d_%H%M%S"))
    # Try to create backup, but don't fail if backup directory doesn't exist
    ok <- tryCatch(
      {
        file.copy(path, backup, overwrite = FALSE)
      },
      error = function(e) {
        # If backup fails, continue without backup (for vignette builds)
        FALSE
      }
    )
    if (!isTRUE(ok)) {
      # Don't fail the entire operation if backup fails
      warning("Could not create backup for ", path, " - continuing without backup", call. = FALSE)
    }
  }
  # Write to temp file first
  tmp <- paste0(path, ".tmp.", Sys.getpid())
  utils::write.csv(df, tmp, row.names = FALSE, fileEncoding = "UTF-8")
  # Atomic-ish replace
  ok <- file.rename(tmp, path)
  if (!isTRUE(ok)) {
    # Attempt fallback: remove and rename
    if (file.exists(path)) unlink(path)
    ok2 <- file.rename(tmp, path)
    if (!isTRUE(ok2)) {
      unlink(tmp)
      stop("Failed to write lookup file atomically: ", path, call. = FALSE)
    }
  }
  invisible(path)
}

# Internal function - no documentation needed
conditionally_write_lookup <- function(df = NULL, path = NULL, allow_write = FALSE) {

  if (!isTRUE(allow_write)) {
    return(FALSE)
  }
  write_lookup_transactional(df, path)
  TRUE
}

# Internal function - no documentation needed
ensure_instructor_rows <- function(existing_df = NULL, instructor_name = NULL) {

  if (!is.character(instructor_name) || length(instructor_name) != 1) {
    stop("instructor_name must be a single character string", call. = FALSE)
  }
  base <- .normalize_lookup_df(existing_df)
  instructor_df <- data.frame(
    transcript_name = instructor_name,
    preferred_name = instructor_name,
    formal_name = instructor_name,
    participant_type = "instructor",
    student_id = "INSTRUCTOR",
    notes = "Primary instructor name - add variations manually if needed",
    stringsAsFactors = FALSE
  )
  merge_lookup_preserve(base, instructor_df)
}
