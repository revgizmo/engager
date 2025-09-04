#' Internal diagnostics helpers (quiet-by-default)
#'
#' These helpers centralize diagnostic output policy. By default, diagnostics
#' are suppressed. Users can enable verbose diagnostics by setting the option
#' `options(zoomstudentengagement.verbose = TRUE)`.
#'
#' @importFrom utils str
#'
#' @name zse_diagnostics
#' @keywords internal
NULL

# Return TRUE if verbose diagnostics are enabled
is_verbose <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning("Function 'is_verbose' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)
  }

  isTRUE(getOption("zoomstudentengagement.verbose", FALSE))
}

#' Conditionally emit a message when verbose is enabled
#'
#' @keywords internal
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
diag_message <- function(...) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning("Function 'diag_message' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)
  }

  if (is_verbose()) {
    message(...)
  }
  invisible(NULL)
}

#' Conditionally emit cat-style output when verbose is enabled or in interactive sessions
#'
#' @keywords internal
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
diag_cat <- function(...) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning("Function 'diag_cat' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)
  }

  if (is_verbose() || interactive()) {
    cat(...)
  }
  invisible(NULL)
}

#' Conditionally emit a message if a local verbose flag is TRUE or global verbose is enabled
#'
#' @param verbose_flag Logical flag controlling local verbosity
#' @keywords internal
diag_message_if <- function(verbose_flag, ...) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning("Function 'diag_message_if' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)
  }

  if (isTRUE(verbose_flag) || is_verbose()) {
    message(...)
  }
  invisible(NULL)
}

#' Conditionally emit cat output if a local verbose flag is TRUE or global verbose is enabled
#'
#' @param verbose_flag Logical flag controlling local verbosity
#' @keywords internal
diag_cat_if <- function(verbose_flag, ...) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning("Function 'diag_cat_if' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)
  }

  if (isTRUE(verbose_flag) || is_verbose() || interactive()) {
    cat(...)
  }
  invisible(NULL)
}
