#' Error handling helpers
#'
#' Provides a small wrapper around `rlang::abort()` to standardize
#' error classes within the package for precise testing and user handling.
#'
#' @param message Error message to display
#' @param class Additional error class to add to the error
#' @return No return value, throws an error
abort_zse <- function(message, class = character()) {
  rlang::abort(message, class = c("zse_error", class))
}
