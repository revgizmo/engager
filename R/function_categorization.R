#' Function Categorization System
#'
#' @description Categorizes functions by technical purpose and CRAN readiness
#' @keywords internal
#' @noRd

#' Categorize functions by technical purpose
#'
#' @param function_analysis List of function analysis results
#' @return Function categories
categorize_functions <- function(function_analysis) {
  categories <- list(
    core_workflow = character(0),
    privacy_compliance = character(0),
    data_processing = character(0),
    analysis = character(0),
    visualization = character(0),
    utility = character(0),
    advanced = character(0),
    deprecated = character(0)
  )

  for (func_name in names(function_analysis)) {
    func <- function_analysis[[func_name]]
    category <- determine_function_category(func)
    categories[[category]] <- c(categories[[category]], func_name)
  }

  categories
}

#' Determine function category based on name and analysis
#'
#' @param func Function analysis result
#' @return Category name
determine_function_category <- function(func) {
  name <- func$name

  # Handle empty or NULL names
  if (is.null(name) || length(name) == 0 || name == "") {
    return("uncategorized")
  }

  # Core workflow functions - essential for basic transcript analysis
  if (grepl("load_zoom|process_zoom|analyze_transcript|consolidate_transcript", name)) {
    return("core_workflow")
  }

  # Privacy and compliance functions - FERPA and privacy-related
  if (grepl("privacy|ferpa|compliance|validate_ethical|audit_ethical|anonymize|mask_user|hash_name", name)) {
    return("privacy_compliance")
  }

  # Data processing functions - data cleaning, validation, transformation
  if (grepl("clean|validate|transform|process|detect_|make_|create_|merge_|join_", name)) {
    return("data_processing")
  }

  # Analysis functions - engagement metrics, statistical analysis
  if (grepl("analyze_|calculate_|summarize_|generate_|compare_|benchmark_", name)) {
    return("analysis")
  }

  # Visualization functions - plotting, reporting, export functions
  if (grepl("plot_|export_|write_|generate_.*report", name)) {
    return("visualization")
  }

  # Utility functions - helper functions, internal utilities
  if (grepl("get_|set_|ensure_|prompt_|safe_|read_|conditionally_", name)) {
    return("utility")
  }

  # Advanced functions - specialized features for expert users
  if (grepl("ideal_|batch_|multi_session|timing_patterns|content_quality|attendance", name)) {
    return("advanced")
  }

  # Default to utility for uncategorized functions
  "utility"
}

#' Get functions by category
#'
#' @param categories Function categories
#' @param category_name Name of category
#' @return Functions in category
get_functions_by_category <- function(categories, category_name) {
  if (category_name %in% names(categories)) {
    categories[[category_name]]
  } else {
    character(0)
  }
}

#' Get category summary
#'
#' @param categories Function categories
#' @return Category summary
get_category_summary <- function(categories) {
  summary <- list()
  for (category in names(categories)) {
    summary[[category]] <- length(categories[[category]])
  }
  summary
}

#' Validate function categories
#'
#' @param categories Function categories
#' @return Validation results
validate_categories <- function(categories) {
  # Check that all functions are categorized
  all_functions <- unlist(categories)
  total_functions <- length(all_functions)

  # Check for duplicates
  duplicates <- any(duplicated(all_functions))

  # Check for empty categories
  empty_categories <- names(categories)[sapply(categories, length) == 0]

  validation_results <- list(
    total_functions = total_functions,
    has_duplicates = duplicates,
    categories_complete = total_functions > 0,
    empty_categories = empty_categories,
    category_counts = get_category_summary(categories)
  )

  validation_results
}

#' Print category summary
#'
#' @param categories Function categories
print_category_summary <- function(categories) {
  # cat("INFO: FUNCTION CATEGORY SUMMARY\n")
  # cat(paste(rep("=", 30), collapse = ""), "\n")

  for (category in names(categories)) {
    count <- length(categories[[category]])
    percentage <- if (sum(sapply(categories, length)) > 0) {
      round(100 * count / sum(sapply(categories, length)), 1)
    } else {
      0
    }

    # cat(sprintf(
    #   "%-20s: %2d functions (%4.1f%%)\n",
    #   category, count, percentage
    # ))
  }
  # cat("\n")
}

#' Get functions for CRAN submission
#'
#' @param categories Function categories
#' @param max_functions Maximum number of functions for CRAN
#' @return Functions selected for CRAN
get_cran_functions <- function(categories, max_functions = 30) {
  # Priority order for CRAN functions
  priority_order <- c(
    "core_workflow",
    "privacy_compliance",
    "data_processing",
    "analysis",
    "visualization",
    "utility"
  )

  cran_functions <- character(0)

  for (category in priority_order) {
    if (category %in% names(categories)) {
      category_functions <- categories[[category]]

      # Add functions from this category
      remaining_slots <- max_functions - length(cran_functions)
      if (remaining_slots > 0) {
        functions_to_add <- category_functions[seq_len(min(remaining_slots, length(category_functions)))]
        cran_functions <- c(cran_functions, functions_to_add)
      }
    }
  }

  return(cran_functions)
}

#' Get functions marked for deprecation
#'
#' @param categories Function categories
#' @param cran_functions Functions selected for CRAN
#' @return Functions marked for deprecation
get_deprecated_functions <- function(categories, cran_functions) {
  all_functions <- unlist(categories)
  deprecated_functions <- setdiff(all_functions, cran_functions)

  deprecated_functions
}

#' Analyze function dependencies within categories
#'
#' @param function_analysis Function analysis results
#' @param categories Function categories
#' @return Dependency analysis
analyze_category_dependencies <- function(function_analysis, categories) {
  dependency_analysis <- list()

  for (category in names(categories)) {
    category_functions <- categories[[category]]
    category_deps <- list()

    for (func_name in category_functions) {
      if (func_name %in% names(function_analysis)) {
        func_deps <- function_analysis[[func_name]]$dependencies
        category_deps[[func_name]] <- func_deps
      }
    }

    dependency_analysis[[category]] <- category_deps
  }

  dependency_analysis
}

#' Test categorization system
#'
#' @return Test results
test_categorization_system <- function() {
  # cat("TEST: Testing categorization system...\n")

  # Test with sample function analysis
  sample_analysis <- list(
    analyze_transcripts = list(name = "analyze_transcripts", signature = "transcripts"),
    privacy_audit = list(name = "privacy_audit", signature = "data"),
    load_zoom_transcript = list(name = "load_zoom_transcript", signature = "file"),
    plot_users = list(name = "plot_users", signature = "data"),
    make_roster_small = list(name = "make_roster_small", signature = "roster")
  )

  categories <- categorize_functions(sample_analysis)

  # cat("SUCCESS: Categorization test completed\n")
  print_category_summary(categories)

  categories
}
