# Safe writer for unresolved names (scaffold)

#' Write unresolved matches to disk with privacy guardrails
#'
#' @param unresolved_tbl Tibble returned by detect_unmatched_names()
#' @param path Output file path
#' @param include_raw Logical; include raw names if TRUE and allowed
#' @param overwrite Logical; overwrite existing file if TRUE
#' @return Invisibly, the path written
#' @export
#' @family name-matching
write_unresolved <- function(unresolved_tbl,
                             path,
                             include_raw = FALSE,
                             overwrite = FALSE) {
  if (isTRUE(include_raw)) {
    allow_raw <- getOption("engager.allow_raw_name_exports", FALSE)
    if (!isTRUE(allow_raw)) {
      rlang::abort(
        message = "Raw name export is disabled. Set options(engager.allow_raw_name_exports=TRUE) to allow and call with include_raw=TRUE.",
        class = "engager_privacy_error"
      )
    }
  }

  if (!overwrite && file.exists(path)) {
    rlang::abort(sprintf("File exists: %s (set overwrite=TRUE to replace)", path),
                 class = "engager_schema_error")
  }

  tbl <- tibble::as_tibble(unresolved_tbl)
  # Default: hashed-only export (no raw names)
  if (!isTRUE(include_raw)) {
    keep_cols <- intersect(
      c("name_hash", "occurrence_n", "first_seen_at", "reason", "guidance"),
      names(tbl)
    )
    tbl <- tbl[, keep_cols, drop = FALSE]
  }

  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  readr::write_csv(tbl, path)
  invisible(path)
}


