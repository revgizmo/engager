#' User-Friendly Error Handling System
#'
#' @description Provides helpful error messages and recovery guidance to help
#'   users understand and resolve issues quickly.

#' User-friendly error wrapper
#'
#' @description Wraps expressions with user-friendly error handling
#'
#' @param expr Expression to evaluate
#' @param context Context for error message
#' @export
#' @examples
#' \dontrun{
#' # Wrap any expression with user-friendly error handling
#' result <- user_friendly_error(
#'   {
#'     load_zoom_transcript("nonexistent.vtt")
#'   },
#'   "loading transcript"
#' )
#' }
user_friendly_error <- function(expr, context = "operation") {
  tryCatch(
    {
      expr
    },
    error = function(e) {
      # Convert technical errors to user-friendly messages
      error_msg <- convert_error_to_user_friendly(e$message, context)
      stop(error_msg, call. = FALSE)
    }
  )
}

#' Convert technical error to user-friendly message
#'
#' @description Converts technical error messages to helpful, actionable guidance
#'
#' @param error_message Technical error message
#' @param context Operation context
#' @return User-friendly error message
convert_error_to_user_friendly <- function(error_message, context) {
  # Function not found errors
  if (grepl("could not find function|could not find object", error_message)) {
    paste0(
      "ERROR: Function not found. This might be an advanced function.\n",
      "TIP: Try: set_ux_level('intermediate') to see more functions\n",
      "TIP: Or: show_function_help('function_name') for guidance\n",
      "TIP: Or: find_function_for_task('what you want to do') to find the right function"
    )
  }

  # File not found errors
  if (grepl("file not found|cannot open file|no such file", error_message)) {
    paste0(
      "ERROR: File not found. Please check the file path.\n",
      "TIP: Make sure the file exists and you have permission to read it\n",
      "TIP: Try: list.files() to see available files\n",
      "TIP: Check file extension (.vtt, .txt, .csv are supported)"
    )
  }

  # Permission denied errors
  if (grepl("permission denied|access denied|cannot open", error_message)) {
    paste0(
      "ERROR: Permission denied. You don't have access to this file.\n",
      "TIP: Check file permissions or try a different file\n",
      "TIP: Try a different output directory\n",
      "TIP: Contact your system administrator if needed"
    )
  }

  # Memory errors
  if (grepl("memory|cannot allocate|out of memory", error_message)) {
    paste0(
      "ERROR: Memory issue. The file might be too large.\n",
      "TIP: Try with a smaller file first\n",
      "TIP: Use batch processing for large datasets\n",
      "TIP: Check available system memory"
    )
  }

  # Data format errors
  if (grepl("invalid|malformed|parse error|format", error_message)) {
    paste0(
      "ERROR: Data format issue. The file might be corrupted or in wrong format.\n",
      "TIP: Check file format (VTT, TXT, CSV are supported)\n",
      "TIP: Try: validate_schema() to check data structure\n",
      "TIP: Use a different transcript file to test"
    )
  }

  # Network/connection errors
  if (grepl("connection|network|timeout|unreachable", error_message)) {
    paste0(
      "ERROR: Connection issue. Network or server problem.\n",
      "TIP: Check your internet connection\n",
      "TIP: Try again in a few minutes\n",
      "TIP: Contact support if problem persists"
    )
  }

  # Package dependency errors
  if (grepl("package.*not found|library.*not found|namespace", error_message)) {
    paste0(
      "ERROR: Missing package dependency.\n",
      "TIP: Try: install.packages('package_name')\n",
      "TIP: Or: devtools::install_deps() to install all dependencies\n",
      "TIP: Check package installation"
    )
  }

  # Argument errors
  if (grepl("argument|parameter|missing|required", error_message)) {
    paste0(
      "ERROR: Function argument issue.\n",
      "TIP: Check function arguments and required parameters\n",
      "TIP: Try: show_function_help('function_name') for usage\n",
      "TIP: Or: find_function_for_task('what you want to do')"
    )
  }

  # Privacy/security errors
  if (grepl("privacy|security|access|unauthorized", error_message)) {
    paste0(
      "ERROR: Privacy or security issue.\n",
      "TIP: Check privacy settings: set_privacy_defaults()\n",
      "TIP: Use: ensure_privacy() to protect data\n",
      "TIP: See: show_privacy_guidance() for help"
    )
  }

  # Default user-friendly message
  paste0(
    "ERROR: Something went wrong during ", context, ".\n",
    "TIP: Error details: ", error_message, "\n",
    "TIP: Try: show_getting_started() for help\n",
    "TIP: Or: show_function_help('function_name') for specific guidance\n",
    "TIP: Or: show_troubleshooting() for common solutions"
  )
}

#' Validate function arguments with user-friendly errors
#'
#' @description Validates function arguments and provides helpful error messages
#'
#' @param file_path Path to file
#' @param context Context for error message
#' @return TRUE if valid, stops with user-friendly error if invalid
validate_file_argument <- function(file_path, context = "file operation") {
  if (missing(file_path) || is.null(file_path) || file_path == "") {
    stop("ERROR: File path is required.\n",
      "TIP: Please provide a valid file path\n",
      "TIP: Example: 'transcript.vtt' or '/path/to/transcript.vtt'",
      call. = FALSE
    )
  }

  if (!is.character(file_path) || length(file_path) != 1) {
    stop("ERROR: File path must be a single text string.\n",
      "TIP: Example: 'transcript.vtt'\n",
      "TIP: Not: c('file1.vtt', 'file2.vtt')",
      call. = FALSE
    )
  }

  if (!file.exists(file_path)) {
    stop("ERROR: File not found: ", file_path, "\n",
      "TIP: Check the file path and try again\n",
      "TIP: Use list.files() to see available files\n",
      "TIP: Make sure file has .vtt, .txt, or .csv extension",
      call. = FALSE
    )
  }

  return(TRUE)
}

#' Validate directory argument with user-friendly errors
#'
#' @description Validates directory arguments and provides helpful error messages
#'
#' @param dir_path Path to directory
#' @param context Context for error message
#' @param create_if_missing Whether to create directory if it doesn't exist
#' @return TRUE if valid, stops with user-friendly error if invalid
validate_directory_argument <- function(dir_path, context = "directory operation", create_if_missing = TRUE) {
  if (missing(dir_path) || is.null(dir_path) || dir_path == "") {
    stop("ERROR: Directory path is required.\n",
      "TIP: Please provide a valid directory path\n",
      "TIP: Example: 'output' or '/path/to/output'",
      call. = FALSE
    )
  }

  if (!is.character(dir_path) || length(dir_path) != 1) {
    stop("ERROR: Directory path must be a single text string.\n",
      "TIP: Example: 'output'\n",
      "TIP: Not: c('dir1', 'dir2')",
      call. = FALSE
    )
  }

  if (!dir.exists(dir_path)) {
    if (create_if_missing) {
      message("Creating directory: ", dir_path)
      dir.create(dir_path, recursive = TRUE)
    } else {
      stop("ERROR: Directory not found: ", dir_path, "\n",
        "TIP: Check the directory path and try again\n",
        "TIP: Use list.dirs() to see available directories\n",
        "TIP: Or set create_if_missing = TRUE to create it",
        call. = FALSE
      )
    }
  }

  return(TRUE)
}

#' Show error recovery suggestions
#'
#' @description Provides specific recovery suggestions based on error type
#'
#' @param error_type Type of error encountered
#' @export
#' @examples
#' \dontrun{
#' show_error_recovery("file_not_found")
#' show_error_recovery("permission_denied")
#' }
show_error_recovery <- function(error_type) {
  switch(error_type,
    "file_not_found" = {
      cat("TOOLS: File Not Found - Recovery Steps:\n")
      cat("1. Check file path: list.files() to see available files\n")
      cat("2. Check file extension: .vtt, .txt, .csv are supported\n")
      cat("3. Check working directory: getwd() to see current location\n")
      cat("4. Use full path: '/full/path/to/file.vtt'\n")
    },
    "permission_denied" = {
      cat("TOOLS: Permission Denied - Recovery Steps:\n")
      cat("1. Check file permissions\n")
      cat("2. Try a different output directory\n")
      cat("3. Run as administrator if needed\n")
      cat("4. Contact system administrator\n")
    },
    "function_not_found" = {
      cat("TOOLS: Function Not Found - Recovery Steps:\n")
      cat("1. Check function name spelling\n")
      cat("2. Use show_available_functions() to see available functions\n")
      cat("3. Try set_ux_level('intermediate') for more functions\n")
      cat("4. Use find_function_for_task('what you want to do')\n")
    },
    "memory_error" = {
      cat("TOOLS: Memory Error - Recovery Steps:\n")
      cat("1. Try with a smaller file first\n")
      cat("2. Use batch processing for large datasets\n")
      cat("3. Check available system memory\n")
      cat("4. Close other applications to free memory\n")
    },
    {
      cat("TOOLS: General Error Recovery:\n")
      cat("1. Check error message for specific details\n")
      cat("2. Try show_troubleshooting() for common solutions\n")
      cat("3. Use show_function_help('function_name') for specific help\n")
      cat("4. Use find_function_for_task('what you want to do')\n")
    }
  )
}
