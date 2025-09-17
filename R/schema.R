#' Schema validators and contracts
#'
#' Defines simple schema validation helpers and canonical schemas used throughout
#' the package. Keep this intentionally lightweight to avoid dependency bloat.
#'
#' @name schema
NULL

# Internal function - no documentation needed
validate_schema <- function(df = NULL, required_cols = NULL, types = NULL) {
  if (!is.data.frame(df)) {
    abort_zse("`df` must be a data.frame or tibble", class = "zse_schema_error")
  }
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    abort_zse(
      paste0("Missing required columns: ", paste(missing, collapse = ", ")),
      class = "zse_schema_error"
    )
  }
  if (!is.null(types)) {
    for (nm in names(types)) {
      exp_type <- types[[nm]]
      if (!nm %in% names(df)) next
      actual <- class(df[[nm]])[1]
      if (!identical(actual, exp_type)) {
        abort_zse(
          paste0("Column `", nm, "` has type `", actual, "`, expected `", exp_type, "`"),
          class = "zse_schema_error"
        )
      }
    }
  }
  invisible(TRUE)
}

#' Canonical schemas used in pipelines
#'
#' These are documented here for reference and to be used by callers/tests.
#' Keep them minimal; adjust as the package evolves.
#'
zse_schema <- list(
  transcript = list(
    required = c("timestamp", "speaker", "text"),
    types = list(timestamp = "hms", speaker = "character", text = "character")
  ),
  roster = list(
    required = c("student_id", "preferred_name"),
    types = list(student_id = "character", preferred_name = "character")
  )
)
