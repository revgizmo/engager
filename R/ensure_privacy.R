#' Ensure Privacy for Outputs
#'
#' Applies privacy rules to objects before they are returned, written, or
#' plotted. By default, masks personally identifiable information in tabular
#' data to privacy-supporting placeholders.
#'
#' **CRITICAL ETHICAL USE**: This function is designed to promote
#' participation equity and educational improvement, NOT surveillance. Outputs
#' are masked by default to support student privacy review; institutional
#' compliance review remains the user's responsibility.
#'
#' The default behavior is controlled by the global option
#' `engager.privacy_level`, which is set to "mask" on package
#' load. Pass `privacy_level` explicitly for one call, or set the
#' `engager.privacy_level` option for the current R session.
#'
#' @param x Data object to apply privacy rules to (typically a `tibble`)
#' @param privacy_level Privacy level: "mask", "privacy_strict",
#'   "privacy_standard", or "none". Deprecated aliases "ferpa_strict" and
#'   "ferpa_standard" are accepted with a warning.
#' @param id_columns Vector of column names to treat as identifiers (default: common name columns)
#' @param audit_log Whether to log privacy operations (default: TRUE)
#' @return For tabular input, an object with the same data-frame class as `x`
#'   and configured identifier columns transformed according to `privacy_level`.
#'   Non-tabular input is returned unchanged. This is a technical masking result,
#'   not a legal or institutional compliance determination.
#' @examples
#' df <- tibble::tibble(
#'   section = c("A", "A", "B"),
#'   preferred_name = c("Alice Johnson", "Bob Lee", "Cara Diaz"),
#'   session_ct = c(3, 5, 2)
#' )
#' ensure_privacy(df)
#'
#' @export
ensure_privacy <- function(x = NULL,
                           privacy_level = getOption(
                             "engager.privacy_level",
                             "mask"
                           ),
                           id_columns = c(
                             "preferred_name", "name", "first_last",
                             "name_raw", "student_id", "email",
                             "transcript_name", "formal_name", "user_name",
                             "speaker"
                           ),
                           audit_log = TRUE) {
  privacy_level <- normalize_privacy_level(privacy_level)

  # Handle privacy level and get appropriate columns
  result <- handle_privacy_level(privacy_level, id_columns, audit_log, x)
  if (result$early_return) {
    return(result$data)
  }
  id_columns <- result$id_columns
  privacy_level <- result$privacy_level # Use scalarized privacy_level

  # Only handle tabular data for MVP; return other objects unchanged
  if (!is.data.frame(x)) {
    return(x)
  }

  # Apply privacy masking
  df <- apply_privacy_masking(x, id_columns, privacy_level, audit_log)

  # Preserve tibble class if input was a tibble
  if (tibble::is_tibble(x)) {
    df <- tibble::as_tibble(df)
  }

  df
}

# Helper function to normalize privacy level aliases
normalize_privacy_level <- function(privacy_level) {
  if (!is.character(privacy_level) || length(privacy_level) == 0) {
    stop(
      "Invalid privacy_level. Must be one of: privacy_strict, privacy_standard, mask, none",
      call. = FALSE
    )
  }

  if (length(privacy_level) > 1) {
    privacy_level <- privacy_level[1]
    warning("privacy_level had length > 1, using first element: ", privacy_level)
  }

  deprecated_levels <- c(
    ferpa_strict = "privacy_strict",
    ferpa_standard = "privacy_standard"
  )

  if (privacy_level %in% names(deprecated_levels)) {
    new_level <- unname(deprecated_levels[[privacy_level]])
    warning(
      "privacy_level = \"", privacy_level, "\" is deprecated; use \"",
      new_level, "\" instead.",
      call. = FALSE
    )
    privacy_level <- new_level
  }

  valid_levels <- c("privacy_strict", "privacy_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ", paste(valid_levels, collapse = ", "), call. = FALSE)
  }

  privacy_level
}

# Helper function to validate privacy level
validate_privacy_level <- function(privacy_level) {
  normalize_privacy_level(privacy_level)
}

# Helper function to handle privacy level and get appropriate columns
handle_privacy_level <- function(privacy_level, id_columns, audit_log, x) {
  # Normalize privacy-level input before selecting masking controls.

  privacy_level <- normalize_privacy_level(privacy_level)

  # If privacy is explicitly disabled, warn and return unmodified
  if (identical(privacy_level, "none")) {
    warning(
      paste(
        "CRITICAL: Privacy disabled; outputs may contain identifiable data.",
        "Confirm this is authorized before sharing outputs."
      ),
      call. = FALSE
    )

    # Log the privacy violation for audit purposes
    if (audit_log) {
      log_privacy_operation(
        operation = "privacy_disabled",
        privacy_level = privacy_level,
        timestamp = Sys.time(),
        warning_issued = TRUE
      )
    }

    return(list(early_return = TRUE, data = x, id_columns = NULL, privacy_level = privacy_level))
  }

  # Privacy strict level - most comprehensive masking
  if (identical(privacy_level, "privacy_strict")) {
    id_columns <- c(
      id_columns,
      "email", "email_address", "e_mail",
      "phone", "phone_number", "telephone",
      "address", "street_address", "home_address",
      "ssn", "social_security", "social_security_number",
      "birth_date", "birthday", "date_of_birth",
      "parent_name", "guardian_name",
      "instructor_name", "instructor_id"
    )
  }

  # Privacy standard level - standard educational privacy masking
  if (identical(privacy_level, "privacy_standard")) {
    id_columns <- c(
      id_columns,
      "email", "email_address", "e_mail",
      "phone", "phone_number", "telephone",
      "instructor_name", "instructor_id"
    )
  }

  list(early_return = FALSE, data = NULL, id_columns = id_columns, privacy_level = privacy_level)
}

# Helper function to apply privacy masking
apply_privacy_masking <- function(x, id_columns, privacy_level, audit_log) {
  # Normalize vector input before scalar privacy-level comparisons.

  # Validate inputs
  if (!is.character(privacy_level) || length(privacy_level) == 0) {
    stop("privacy_level must be a non-empty character vector")
  }

  # Handle vector input gracefully
  if (length(privacy_level) > 1) {
    privacy_level <- privacy_level[1]
    warning("privacy_level had length > 1, using first element: ", privacy_level)
  }

  # Log privacy operation for audit purposes
  if (audit_log) {
    log_privacy_operation(
      operation = "privacy_applied",
      privacy_level = privacy_level,
      data_rows = nrow(x),
      data_columns = ncol(x),
      timestamp = Sys.time()
    )
  }

  df <- x

  # Identify columns to mask while preserving structure
  columns_to_mask <- intersect(id_columns, names(df))
  if (length(columns_to_mask) == 0) {
    # Nothing to mask; return as-is
    if (tibble::is_tibble(x)) {
      return(tibble::as_tibble(df))
    } else {
      return(df)
    }
  }

  mask_values <- function(values) {
    # Convert to character for stable mapping; preserve NAs and empty strings
    chr <- as.character(values)
    # Unique non-empty, non-NA values for deterministic mapping
    unique_vals <- unique(chr[!is.na(chr) & nzchar(chr)])
    unique_vals <- sort(unique_vals)
    if (length(unique_vals) == 0) {
      return(chr)
    }
    labels <- paste(
      "Student",
      sprintf("%02d", seq_along(unique_vals))
    )
    mapping <- stats::setNames(labels, unique_vals)
    to_mask <- !is.na(chr) & nzchar(chr)
    chr[to_mask] <- unname(mapping[chr[to_mask]])
    chr
  }

  for (col_name in columns_to_mask) {
    # Mask only character or factor columns
    if (is.character(df[[col_name]]) || is.factor(df[[col_name]])) {
      df[[col_name]] <- mask_values(df[[col_name]])
    }
  }

  df
}

# Internal function - no documentation needed
log_privacy_operation <- function(operation,
                                  privacy_level,
                                  timestamp = Sys.time(),
                                  data_rows = NULL,
                                  data_columns = NULL,
                                  warning_issued = FALSE) {
  # This function is used by ensure_privacy() and is kept for compatibility

  # Create log entry
  log_entry <- list(
    timestamp = timestamp,
    operation = operation,
    privacy_level = privacy_level,
    data_rows = data_rows,
    data_columns = data_columns,
    warning_issued = warning_issued,
    session_id = Sys.getpid()
  )

  # Store in package environment for session tracking (CRAN compliant)
  log_key <- paste0("zse_privacy_log_", format(timestamp, "%Y%m%d_%H%M%S"))
  # Simple in-memory storage for session tracking - use options() for CRAN compliance
  current_logs <- getOption("engager.privacy_logs", list())
  current_logs[[log_key]] <- log_entry
  options(engager.privacy_logs = current_logs)

  # Optionally write to file if logging is enabled
  log_file <- getOption("engager.privacy_log_file", NULL)
  if (!is.null(log_file) && is.character(log_file)) {
    tryCatch(
      {
        log_line <- paste(
          format(timestamp, "%Y-%m-%d %H:%M:%S"),
          operation,
          privacy_level,
          ifelse(is.null(data_rows), "NA", data_rows),
          ifelse(is.null(data_columns), "NA", data_columns),
          ifelse(warning_issued, "WARNING", "OK"),
          sep = "\t"
        )
        write(log_line, file = log_file, append = TRUE)
      },
      error = function(e) {
        # Silently fail if logging fails
        NULL
      }
    )
  }

  invisible(log_entry)
}
