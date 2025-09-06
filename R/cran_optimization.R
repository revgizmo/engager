#' CRAN Optimization System
#'
#' @description Optimizes function set for CRAN submission
#' @keywords internal
#' @noRd
#'
#' @param function_categories Function categories from audit
#' @param max_functions Maximum number of functions for CRAN (default: 30)
#' @return CRAN-optimized function set
select_cran_functions <- function(function_categories, max_functions = 30) {
  cat("🎯 Selecting functions for CRAN submission...\n")
  cat("📊 Target: Maximum", max_functions, "functions\n\n")

  # Priority order for CRAN functions (based on user workflow importance)
  priority_order <- c(
    "core_workflow", # Essential for basic transcript analysis
    "privacy_compliance", # Critical for FERPA compliance
    "data_processing", # Core data handling
    "analysis", # Core analysis functions
    "visualization", # Essential plotting and export
    "utility" # Helper functions
  )

  cran_functions <- character(0)
  category_allocations <- list()

  # Allocate functions by category priority
  for (category in priority_order) {
    if (category %in% names(function_categories)) {
      category_functions <- function_categories[[category]]

      # Determine allocation for this category
      allocation <- get_category_allocation(category, max_functions, length(cran_functions))

      if (allocation > 0 && length(category_functions) > 0) {
        functions_to_add <- category_functions[seq_len(min(allocation, length(category_functions)))]
        cran_functions <- c(cran_functions, functions_to_add)
        category_allocations[[category]] <- length(functions_to_add)

        cat(sprintf(
          "📁 %-20s: %2d functions allocated\n",
          category, length(functions_to_add)
        ))
      }
    }
  }

  # Remove any duplicates and limit to max_functions
  cran_functions <- unique(cran_functions)
  cran_functions <- cran_functions[seq_len(min(max_functions, length(cran_functions)))]

  cat(sprintf("\n✅ Selected %d functions for CRAN submission\n", length(cran_functions)))

  return(list(
    functions = cran_functions,
    allocations = category_allocations,
    total_selected = length(cran_functions)
  ))
}

#' Get category allocation based on priority and remaining slots
#'
#' @param category Category name
#' @param max_functions Maximum total functions
#' @param current_count Current number of selected functions
#' @return Number of functions to allocate to this category
get_category_allocation <- function(category, max_functions, current_count) {
  # Allocation strategy based on category importance
  allocations <- list(
    core_workflow = 8, # Essential workflow functions
    privacy_compliance = 6, # Critical for compliance
    data_processing = 6, # Core data handling
    analysis = 5, # Analysis functions
    visualization = 3, # Plotting and export
    utility = 2 # Helper functions
  )

  if (category %in% names(allocations)) {
    requested <- allocations[[category]]
    remaining <- max_functions - current_count
    min(requested, remaining)
  } else {
    0
  }
}

#' Mark functions for deprecation
#'
#' @param function_categories Function categories from audit
#' @param cran_functions Functions selected for CRAN
#' @return Functions marked for deprecation
mark_deprecated_functions <- function(function_categories, cran_functions) {
  all_functions <- unlist(function_categories)
  deprecated_functions <- setdiff(all_functions, cran_functions)

  cat("📋 Marking functions for deprecation...\n")
  cat("📊 Total functions:", length(all_functions), "\n")
  cat("📊 CRAN functions:", length(cran_functions), "\n")
  cat("📊 Deprecated functions:", length(deprecated_functions), "\n\n")

  deprecated_functions
}

#' Analyze breaking change impact
#'
#' @param deprecated_functions Functions marked for deprecation
#' @param function_analysis Function analysis results
#' @return Breaking change analysis
analyze_breaking_changes <- function(deprecated_functions, function_analysis) {
  cat("⚠️  Analyzing breaking change impact...\n")

  impact_analysis <- list(
    high_impact = character(0),
    medium_impact = character(0),
    low_impact = character(0),
    no_impact = character(0)
  )

  for (func_name in deprecated_functions) {
    if (func_name %in% names(function_analysis)) {
      func_info <- function_analysis[[func_name]]

      # Determine impact level based on usage patterns
      impact_level <- determine_impact_level(func_info)
      impact_analysis[[impact_level]] <- c(impact_analysis[[impact_level]], func_name)
    }
  }

  # Print impact summary
  cat("📊 Breaking Change Impact Summary:\n")
  for (impact in names(impact_analysis)) {
    count <- length(impact_analysis[[impact]])
    cat(sprintf("  %-12s: %2d functions\n", impact, count))
  }
  cat("\n")

  impact_analysis
}

#' Determine impact level of deprecating a function
#'
#' @param func_info Function analysis information
#' @return Impact level
determine_impact_level <- function(func_info) {
  usage <- func_info$usage
  documentation <- func_info$documentation

  # High impact: functions with examples and tests
  if (usage$in_examples && usage$in_tests && documentation == "Complete") {
    return("high_impact")
  }

  # Medium impact: functions with either examples or tests
  if ((usage$in_examples || usage$in_tests) && documentation == "Complete") {
    return("medium_impact")
  }

  # Low impact: functions with documentation but no examples/tests
  if (documentation == "Complete") {
    return("low_impact")
  }

  # No impact: functions without proper documentation
  "no_impact"
}

#' Generate migration recommendations
#'
#' @param deprecated_functions Functions marked for deprecation
#' @param cran_functions Functions selected for CRAN
#' @param function_analysis Function analysis results
#' @return Migration recommendations
gen_migration_recommendations <- function(deprecated_functions, cran_functions, function_analysis) {
  cat("📝 Generating migration recommendations...\n")

  migration_guide <- list()

  for (func_name in deprecated_functions) {
    if (func_name %in% names(function_analysis)) {
      func_info <- function_analysis[[func_name]]

      # Find potential replacement function
      replacement <- find_replacement_function(func_name, cran_functions, function_analysis)

      migration_guide[[func_name]] <- list(
        original_function = func_name,
        replacement_function = replacement,
        migration_strategy = get_migration_strategy(func_name, replacement),
        impact_level = determine_impact_level(func_info)
      )
    }
  }

  migration_guide
}

#' Find replacement function for deprecated function
#'
#' @param deprecated_func Deprecated function name
#' @param cran_functions Available CRAN functions
#' @param function_analysis Function analysis results
#' @return Suggested replacement function
find_replacement_function <- function(deprecated_func, cran_functions, function_analysis) {
  # Simple heuristic-based replacement suggestions
  replacements <- list(
    # Common patterns
    "make_" = "create_",
    "generate_" = "create_",
    "write_" = "export_",
    "plot_" = "visualize_"
  )

  for (pattern in names(replacements)) {
    if (grepl(pattern, deprecated_func)) {
      potential_replacement <- gsub(pattern, replacements[[pattern]], deprecated_func)
      if (potential_replacement %in% cran_functions) {
        return(potential_replacement)
      }
    }
  }

  # Look for functions with similar names
  similar_functions <- cran_functions[grepl(gsub("_.*", "", deprecated_func), cran_functions)]
  if (length(similar_functions) > 0) {
    return(similar_functions[1])
  }

  "No direct replacement available"
}

#' Get migration strategy for deprecated function
#'
#' @param deprecated_func Deprecated function name
#' @param replacement Suggested replacement
#' @return Migration strategy
get_migration_strategy <- function(deprecated_func, replacement) {
  if (replacement == "No direct replacement available") {
    "Function will be removed. Consider alternative approaches or contact maintainers."
  } else {
    paste("Replace", deprecated_func, "with", replacement, "and update function calls.")
  }
}

#' Validate CRAN optimization results
#'
#' @param cran_selection CRAN function selection results
#' @param deprecated_functions Functions marked for deprecation
#' @param function_analysis Function analysis results
#' @return Validation results
validate_cran_optimization <- function(cran_selection, deprecated_functions, function_analysis) {
  cat("✅ Validating CRAN optimization results...\n")

  validation_results <- list(
    function_count_valid = length(cran_selection$functions) <= 30,
    no_duplicates = length(cran_selection$functions) == length(unique(cran_selection$functions)),
    all_cran_functions_documented = TRUE,
    migration_path_available = length(deprecated_functions) > 0
  )

  # Check documentation for CRAN functions
  for (func_name in cran_selection$functions) {
    if (func_name %in% names(function_analysis)) {
      if (function_analysis[[func_name]]$documentation != "Complete") {
        validation_results$all_cran_functions_documented <- FALSE
        break
      }
    }
  }

  # Print validation results
  cat("📊 Validation Results:\n")
  for (check in names(validation_results)) {
    status <- if (validation_results[[check]]) "✅" else "❌"
    cat(sprintf("  %-30s: %s\n", check, status))
  }
  cat("\n")

  validation_results
}

#' Test CRAN optimization system
#'
#' @return Test results
test_cran_optimization <- function() {
  cat("🧪 Testing CRAN optimization system...\n")

  # Test with sample categories
  sample_categories <- list(
    core_workflow = c("analyze_transcripts", "load_zoom_transcript", "process_zoom_transcript"),
    privacy_compliance = c("privacy_audit", "ensure_privacy", "validate_ferpa_compliance"),
    data_processing = c("consolidate_transcript", "detect_duplicate_transcripts"),
    analysis = c("summarize_transcript_metrics", "generate_attendance_report"),
    visualization = c("plot_users", "write_metrics"),
    utility = c("get_essential_functions", "set_privacy_defaults")
  )

  cran_selection <- select_cran_functions(sample_categories, max_functions = 15)
  deprecated_functions <- mark_deprecated_functions(sample_categories, cran_selection$functions)

  cat("✅ CRAN optimization test completed\n")

  list(
    cran_selection = cran_selection,
    deprecated_functions = deprecated_functions
  )
}
