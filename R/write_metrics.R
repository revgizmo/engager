#' Write Metrics
#'
#' Unified writer for engagement-related outputs with privacy enforcement.
#' Parent directories are created if they do not exist.
#'
#' @param data A tibble containing the data to write
#' @param what Type of output: "engagement", "summary", or "session_summary" (default: "engagement")
#' @param path Explicit file path where the output will be written. No default
#'   path is used.
#' @param comments_format Deprecated alias for `comments_policy`. Use
#'   `comments_policy = "count"` or `comments_policy = "text"` instead.
#'   Retained before `privacy_level` to preserve positional compatibility.
#' @param privacy_level Privacy level for data export (default: from global option)
#' @param comments_policy Export policy for the `comments` column: "auto", "omit",
#'   "count", or "text" (default: "auto"). "auto" resolves to "omit" so raw
#'   transcript text is never exported accidentally. "text" is allowed only
#'   with `privacy_level = "none"` and emits a warning.
#' @return Invisibly returns the exported tibble after privacy and export
#'   policies are applied.
#'
#' @details `write_metrics()` is the privacy-safe CSV export path. It applies
#' structured identifier masking with `ensure_privacy()` and then omits raw
#' free-text comments by default. `ensure_privacy()` does not redact identifiers
#' embedded inside comment text.
#'
#' @export
write_metrics <- function(
    data = NULL,
    what = c("engagement", "summary", "session_summary"),
    path,
    comments_format = NULL,
    privacy_level = getOption("engager.privacy_level", "mask"),
    comments_policy = c("auto", "omit", "count", "text")) {
  what <- match.arg(what)
  comments_policy <- match.arg(comments_policy)
  privacy_level <- normalize_export_privacy_level(privacy_level)
  comments_policy <- resolve_comments_policy(
    comments_policy = comments_policy,
    comments_format = comments_format,
    privacy_level = privacy_level
  )

  if (!tibble::is_tibble(data)) {
    stop("`data` must be a tibble")
  }
  if (missing(path) || is.null(path) || !is.character(path) || length(path) != 1L || !nzchar(path)) {
    stop("`path` must be an explicit non-empty file path", call. = FALSE)
  }

  # Process data for export
  export_data <- process_data_for_export(data, privacy_level, comments_policy)

  # Write to file
  write_processed_data_to_file(export_data, what, path)

  invisible(export_data)
}

# Helper function to normalize privacy level before comment policy decisions
normalize_export_privacy_level <- function(privacy_level) {
  normalize_privacy_level(privacy_level)
}

# Helper function to resolve comment export policy
resolve_comments_policy <- function(comments_policy, comments_format, privacy_level) {
  if (!is.null(comments_format)) {
    comments_format <- match.arg(comments_format, c("text", "count"))

    warning(
      "`comments_format` is deprecated; use `comments_policy` instead.",
      call. = FALSE
    )
    comments_policy <- comments_format
  }

  if (identical(comments_policy, "auto")) {
    comments_policy <- "omit"
  }

  if (identical(comments_policy, "text")) {
    if (!identical(privacy_level, "none")) {
      stop(
        "`comments_policy = \"text\"` is only allowed when `privacy_level = \"none\"`; ",
        "use `comments_policy = \"omit\"` or `comments_policy = \"count\"` for privacy-safe exports.",
        call. = FALSE
      )
    }

    warning(
      paste(
        "Raw comments may contain direct or contextual identifiers.",
        "Export them only for authorized local review."
      ),
      call. = FALSE
    )
  }

  comments_policy
}

# Helper function to process data for export
process_data_for_export <- function(data, privacy_level, comments_policy) {
  # Enforce privacy (name masking)
  export_data <- ensure_privacy(data, privacy_level = privacy_level)

  # Handle raw transcript text before generic list-column conversion.
  export_data <- apply_comments_export_policy(export_data, comments_policy)

  list_columns <- vapply(export_data, is.list, logical(1))
  if (any(list_columns)) {
    list_col_names <- names(export_data)[list_columns]
    warning("Converting list columns to JSON strings: ", paste(list_col_names, collapse = ", "))
    for (col in list_col_names) {
      export_data[[col]] <- vapply(export_data[[col]], function(x) {
        if (is.null(x) || length(x) == 0) {
          return("")
        }
        jsonlite::toJSON(x, auto_unbox = TRUE)
      }, FUN.VALUE = character(1))
    }
  }

  export_data
}

# Helper function to apply the comment export policy
apply_comments_export_policy <- function(export_data, comments_policy) {
  if (!"comments" %in% names(export_data)) {
    return(export_data)
  }

  if (identical(comments_policy, "omit")) {
    export_data$comments <- NULL
    return(export_data)
  }

  if (identical(comments_policy, "count")) {
    export_data$comments_count <- comment_entry_counts(export_data$comments)
    export_data$comments <- NULL
    return(export_data)
  }

  if (identical(comments_policy, "text")) {
    export_data$comments <- flatten_comment_entries(export_data$comments)
  }

  export_data
}

# Helper function to count comments from a vector or list column
comment_entry_counts <- function(x) {
  if (is.list(x)) {
    return(vapply(x, comment_entry_count, FUN.VALUE = integer(1)))
  }

  as.integer(!is.na(x) & nzchar(as.character(x)))
}

# Helper function to count comments from list or scalar entries
comment_entry_count <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return(0L)
  }

  length(unlist(x, use.names = FALSE))
}

# Helper function to flatten comments from a vector or list column
flatten_comment_entries <- function(x) {
  if (is.list(x)) {
    return(vapply(x, flatten_comment_entry, FUN.VALUE = character(1)))
  }

  out <- as.character(x)
  out[is.na(out)] <- ""
  out
}

# Helper function to flatten comments only for explicit raw-text exports
flatten_comment_entry <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return("")
  }

  paste(unlist(x, use.names = FALSE), collapse = "; ")
}

# Helper function to write processed data to file
write_processed_data_to_file <- function(export_data, what, path) {
  dir_path <- dirname(path)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  utils::write.csv(export_data, path, row.names = FALSE)
}
