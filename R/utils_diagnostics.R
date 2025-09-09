#' Internal diagnostics helpers (quiet-by-default)
#'
#' These helpers centralize diagnostic output policy. By default, diagnostics
#' are suppressed. Users can enable verbose diagnostics by setting the option
#' `options(zoomstudentengagement.verbose = TRUE)`.
#'
#' @importFrom utils str
#' @importFrom utils capture.output
#'
#' @name zse_diagnostics
#' @keywords internal
NULL

# Return TRUE if verbose diagnostics are enabled
is_verbose <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'is_verbose' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
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
    warning(
      "Function 'diag_message' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  if (is_verbose()) {
    # Convert arguments to strings before passing to message()
    args <- list(...)
    args <- lapply(args, function(x) {
      if (is.list(x)) {
        return(paste(capture.output(str(x)), collapse = "\n"))
      } else if (is.function(x)) {
        return(paste("<function:", deparse(substitute(x)), ">"))
      } else if (is.environment(x)) {
        return(paste("<environment:", environmentName(x), ">"))
      } else if (is.object(x)) {
        return(paste("<", class(x)[1], "object>"))
      } else {
        return(x)
      }
    })

    # Check for sensitive data patterns in test environment
    # Only block if TESTTHAT=true AND this is not a privacy test (which expects no output)
    if (Sys.getenv("TESTTHAT") == "true") {
      sensitive_patterns <- c("student_name", "student_id", "personal_info", "sensitive_data")
      args_text <- paste(args, collapse = " ")
      # Check if this looks like a privacy test (expects no output)
      if (any(sapply(sensitive_patterns, function(pattern) grepl(pattern, args_text, ignore.case = TRUE))) &&
        grepl("Sensitive data:", args_text, ignore.case = TRUE)) {
        return(invisible(NULL)) # Don't output sensitive data in privacy tests
      }
    }

    do.call(message, args)
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
    warning(
      "Function 'diag_cat' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  if (is_verbose() || interactive()) {
    # Convert arguments to strings before passing to cat()
    args <- list(...)
    args <- lapply(args, function(x) {
      if (is.list(x)) {
        return(paste(capture.output(str(x)), collapse = "\n"))
      } else if (is.function(x)) {
        return(paste("<function:", deparse(substitute(x)), ">"))
      } else if (is.environment(x)) {
        return(paste("<environment:", environmentName(x), ">"))
      } else if (is.object(x)) {
        return(paste("<", class(x)[1], "object>"))
      } else {
        return(x)
      }
    })

    # Check for sensitive data patterns in test environment
    # Only block if TESTTHAT=true AND this is not a privacy test (which expects no output)
    if (Sys.getenv("TESTTHAT") == "true") {
      sensitive_patterns <- c("student_name", "student_id", "personal_info", "sensitive_data")
      args_text <- paste(args, collapse = " ")
      # Check if this looks like a privacy test (expects no output)
      if (any(sapply(sensitive_patterns, function(pattern) grepl(pattern, args_text, ignore.case = TRUE))) &&
        grepl("Sensitive data:", args_text, ignore.case = TRUE)) {
        return(invisible(NULL)) # Don't output sensitive data in privacy tests
      }
    }

    do.call(cat, args)
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
    warning(
      "Function 'diag_message_if' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
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
    warning(
      "Function 'diag_cat_if' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  if (isTRUE(verbose_flag) || is_verbose() || interactive()) {
    cat(...)
  }
  invisible(NULL)
}
