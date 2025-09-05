#' User-Friendly Error Handling System
#'
#' @description Provides helpful error messages and recovery guidance to help
#'   users understand and resolve issues quickly.
#' @export

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
convert_error_to_user_friendly <- function(error_message, context) 
{
  # Function not found errors
  if (grepl("could not find function|could not find object", error_message)) {
    paste0(
      "❌ Function not found. This might be an advanced function.\n",
      "💡 Try: set_ux_level('intermediate') to see more functions\n",
      "💡 Or: show_function_help('function_name') for guidance\n",
      "💡 Or: find_function_for_task('what you want to do') to find the right function"
    )
  }

  # File not found errors
  if (grepl("file not found|cannot open file|no such file", error_message)) {
    paste0(
      "❌ File not found. Please check the file path.\n",
      "💡 Make sure the file exists and you have permission to read it\n",
      "💡 Try: list.files() to see available files\n",
      "💡 Check file extension (.vtt, .txt, .csv are supported)"
    )
  }

  # Permission denied errors
  if (grepl("permission denied|access denied|cannot open", error_message)) {
    paste0(
      "❌ Permission denied. You don't have access to this file.\n",
      "💡 Check file permissions or try a different file\n",
      "💡 Try a different output directory\n",
      "💡 Contact your system administrator if needed"
    )
  }

  # Memory errors
  if (grepl("memory|cannot allocate|out of memory", error_message)) {
    paste0(
      "❌ Memory issue. The file might be too large.\n",
      "💡 Try with a smaller file first\n",
      "💡 Use batch processing for large datasets\n",
      "💡 Check available system memory"
    )
  }

  # Data format errors
  if (grepl("invalid|malformed|parse error|format", error_message)) {
    paste0(
      "❌ Data format issue. The file might be corrupted or in wrong format.\n",
      "💡 Check file format (VTT, TXT, CSV are supported)\n",
      "💡 Try: validate_schema() to check data structure\n",
      "💡 Use a different transcript file to test"
    )
  }

  # Network/connection errors
  if (grepl("connection|network|timeout|unreachable", error_message)) {
    paste0(
      "❌ Connection issue. Network or server problem.\n",
      "💡 Check your internet connection\n",
      "💡 Try again in a few minutes\n",
      "💡 Contact support if problem persists"
    )
  }

  # Package dependency errors
  if (grepl("package.*not found|library.*not found|namespace", error_message)) {
    paste0(
      "❌ Missing package dependency.\n",
      "💡 Try: install.packages('package_name')\n",
      "💡 Or: devtools::install_deps() to install all dependencies\n",
      "💡 Check package installation"
    )
  }

  # Argument errors
  if (grepl("argument|parameter|missing|required", error_message)) {
    paste0(
      "❌ Function argument issue.\n",
      "💡 Check function arguments and required parameters\n",
      "💡 Try: show_function_help('function_name') for usage\n",
      "💡 Or: find_function_for_task('what you want to do')"
    )
  }

  # Privacy/security errors
  if (grepl("privacy|security|access|unauthorized", error_message)) {
    paste0(
      "❌ Privacy or security issue.\n",
      "💡 Check privacy settings: set_privacy_defaults()\n",
      "💡 Use: ensure_privacy() to protect data\n",
      "💡 See: show_privacy_guidance() for help"
    )
  }

  # Default user-friendly message
  paste0(
    "❌ Something went wrong during ", context, ".\n",
    "💡 Error details: ", error_message, "\n",
    "💡 Try: show_getting_started() for help\n",
    "💡 Or: show_function_help('function_name') for specific guidance\n",
    "💡 Or: show_troubleshooting() for common solutions"
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
    stop("❌ File path is required.\n",
      "💡 Please provide a valid file path\n",
      "💡 Example: 'transcript.vtt' or '/path/to/transcript.vtt'",
      call. = FALSE
    )
  }

  if (!is.character(file_path) || length(file_path) != 1) {
    stop("❌ File path must be a single text string.\n",
      "💡 Example: 'transcript.vtt'\n",
      "💡 Not: c('file1.vtt', 'file2.vtt')",
      call. = FALSE
    )
  }

  if (!file.exists(file_path)) {
    stop("❌ File not found: ", file_path, "\n",
      "💡 Check the file path and try again\n",
      "💡 Use list.files() to see available files\n",
      "💡 Make sure file has .vtt, .txt, or .csv extension",
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
    stop("❌ Directory path is required.\n",
      "💡 Please provide a valid directory path\n",
      "💡 Example: 'output' or '/path/to/output'",
      call. = FALSE
    )
  }

  if (!is.character(dir_path) || length(dir_path) != 1) {
    stop("❌ Directory path must be a single text string.\n",
      "💡 Example: 'output'\n",
      "💡 Not: c('dir1', 'dir2')",
      call. = FALSE
    )
  }

  if (!dir.exists(dir_path)) {
    if (create_if_missing) {
      message("📁 Creating directory: ", dir_path)
      dir.create(dir_path, recursive = TRUE)
    } else {
      stop("❌ Directory not found: ", dir_path, "\n",
        "💡 Check the directory path and try again\n",
        "💡 Use list.dirs() to see available directories\n",
        "💡 Or set create_if_missing = TRUE to create it",
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
      cat("🔧 File Not Found - Recovery Steps:\n")
      cat("1. Check file path: list.files() to see available files\n")
      cat("2. Check file extension: .vtt, .txt, .csv are supported\n")
      cat("3. Check working directory: getwd() to see current location\n")
      cat("4. Use full path: '/full/path/to/file.vtt'\n")
    },
    "permission_denied" = {
      cat("🔧 Permission Denied - Recovery Steps:\n")
      cat("1. Check file permissions\n")
      cat("2. Try a different output directory\n")
      cat("3. Run as administrator if needed\n")
      cat("4. Contact system administrator\n")
    },
    "function_not_found" = {
      cat("🔧 Function Not Found - Recovery Steps:\n")
      cat("1. Check function name spelling\n")
      cat("2. Use show_available_functions() to see available functions\n")
      cat("3. Try set_ux_level('intermediate') for more functions\n")
      cat("4. Use find_function_for_task('what you want to do')\n")
    },
    "memory_error" = {
      cat("🔧 Memory Error - Recovery Steps:\n")
      cat("1. Try with a smaller file first\n")
      cat("2. Use batch processing for large datasets\n")
      cat("3. Check available system memory\n")
      cat("4. Close other applications to free memory\n")
    },
    {
      cat("🔧 General Error Recovery:\n")
      cat("1. Check error message for specific details\n")
      cat("2. Try show_troubleshooting() for common solutions\n")
      cat("3. Use show_function_help('function_name') for specific help\n")
      cat("4. Use find_function_for_task('what you want to do')\n")
    }
  )
}
