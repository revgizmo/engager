#' Function Visibility Management System
#'
#' @description Manages which functions are visible to users based on experience level
#'   to implement progressive disclosure and simplify the user interface.

#' Get visible functions for user experience level
#'
#' @param level User experience level: "basic", "intermediate", "advanced", "expert"
#' @return Vector of function names visible at this level
#' @export
#' @examples
#' \dontrun{
#' # Get functions visible to basic users
#' basic_functions <- get_visible_functions("basic")
#'
#' # Get functions visible to intermediate users
#' intermediate_functions <- get_visible_functions("intermediate")
#' }
get_visible_functions <- function(level = "basic") {
  switch(level,
    "basic" = UX_ESSENTIAL_FUNCTIONS,
    "intermediate" = c(UX_ESSENTIAL_FUNCTIONS, UX_COMMON_FUNCTIONS),
    "advanced" = c(UX_ESSENTIAL_FUNCTIONS, UX_COMMON_FUNCTIONS, UX_ADVANCED_FUNCTIONS),
    "expert" = c(UX_ESSENTIAL_FUNCTIONS, UX_COMMON_FUNCTIONS, UX_ADVANCED_FUNCTIONS, UX_EXPERT_FUNCTIONS),
    UX_ESSENTIAL_FUNCTIONS
  )
}

#' Set user experience level
#'
#' @param level User experience level: "basic", "intermediate", "advanced", "expert"
#' @export
#' @examples
#' \dontrun{
#' # Set to basic level (5 essential functions)
#' set_ux_level("basic")
#'
#' # Set to intermediate level (15 functions)
#' set_ux_level("intermediate")
#' }
set_ux_level <- function(level = "basic") {
  valid_levels <- c("basic", "intermediate", "advanced", "expert")
  if (!level %in% valid_levels) {
    stop("Invalid UX level. Must be one of: ", paste(valid_levels, collapse = ", "))
  }

  options(zoomstudentengagement.ux_level = level)
  visible_count <- length(get_visible_functions(level))

  message("TARGET: User experience level set to: ", level)
  message("RESULTS: Visible functions: ", visible_count)

  if (level == "basic") {
    message("TIP: Tip: Use set_ux_level('intermediate') to see more functions")
  }

  invisible(level)
}

#' Get current user experience level
#'
#' @return Current UX level
#' @export
#' @examples
#' \dontrun{
#' current_level <- get_ux_level()
#' }
get_ux_level <- function() {
  getOption("zoomstudentengagement.ux_level", "basic")
}

#' Show functions available at current UX level
#'
#' @param level User experience level (optional, uses current level if not specified)
#' @export
#' @examples
#' \dontrun{
#' # Show functions at current level
#' show_available_functions()
#'
#' # Show functions at specific level
#' show_available_functions("intermediate")
#' }
show_available_functions <- function(level = NULL) {
  if (is.null(level)) {
    level <- get_ux_level()
  }

  visible_functions <- get_visible_functions(level)

  cat("TARGET: Available Functions (", level, " level)\n")
  cat(paste(rep("=", nchar(level) + 25), collapse = ""), "\n\n")

  # Group functions by category
  essential <- intersect(visible_functions, UX_ESSENTIAL_FUNCTIONS)
  common <- intersect(visible_functions, UX_COMMON_FUNCTIONS)
  advanced <- intersect(visible_functions, UX_ADVANCED_FUNCTIONS)
  expert <- intersect(visible_functions, UX_EXPERT_FUNCTIONS)

  if (length(essential) > 0) {
    cat("Essential Functions (", length(essential), "):\n")
    for (func in essential) {
      desc <- UX_FUNCTION_DESCRIPTIONS[[func]]
      if (!is.null(desc)) {
        cat("  - ", func, "() - ", desc, "\n")
      } else {
        cat("  - ", func, "()\n")
      }
    }
    cat("\n")
  }

  if (length(common) > 0) {
    cat("RESULTS: Common Functions (", length(common), "):\n")
    for (func in common) {
      desc <- UX_FUNCTION_DESCRIPTIONS[[func]]
      if (!is.null(desc)) {
        cat("  - ", func, "() - ", desc, "\n")
      } else {
        cat("  - ", func, "()\n")
      }
    }
    cat("\n")
  }

  if (length(advanced) > 0) {
    cat("Advanced Functions (", length(advanced), "):\n")
    for (func in advanced) {
      cat("  - ", func, "()\n")
    }
    cat("\n")
  }

  if (length(expert) > 0) {
    cat("TOOLS: Expert Functions (", length(expert), "):\n")
    for (func in expert) {
      cat("  - ", func, "()\n")
    }
    cat("\n")
  }

  cat("TIP: To see more functions: set_ux_level('", get_next_level(level), "')\n")
}

#' Get next UX level
#'
#' @param current_level Current UX level
#' @return Next UX level
get_next_level <- function(current_level) {
  levels <- c("basic", "intermediate", "advanced", "expert")
  current_index <- which(levels == current_level)
  if (current_index < length(levels)) {
    levels[current_index + 1]
  } else {
    "expert"
  }
}
