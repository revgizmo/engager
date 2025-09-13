#' Error handling helpers
#'
#' Provides a small wrapper around `rlang::abort()` to standardize
#' error classes within the package for precise testing and user handling.
#'
#'
#' \dontrun{
#' abort_zse("Invalid input", class = "zse_schema_error")
#' }
abort_zse <- function(message, class = character()) {
  rlang::abort(message, class = c("zse_error", class))
}
