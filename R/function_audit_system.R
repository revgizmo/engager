#' Function Audit System for Issue #393 Phase 3
#'
#' This module provides comprehensive function auditing, categorization, and
#' dependency mapping for the scope reduction implementation.
#'
#' @keywords internal
#' @noRd
#'
#' Create Comprehensive Function Inventory
#'
#' @return List containing function inventory and metadata
#' @keywords internal
create_function_inventory <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'create_function_inventory' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  tryCatch(
    {
      # Get all R files
      r_files <- list.files("R/", pattern = "\\.R$", full.names = FALSE)

      # Get exported functions from NAMESPACE
      namespace_exports <- character(0)
      if (file.exists("NAMESPACE")) {
        namespace_content <- readLines("NAMESPACE")
        export_lines <- grep("^export\\(", namespace_content, value = TRUE)
        namespace_exports <- gsub("^export\\(([^)]+)\\)", "\\1", export_lines)
        # Remove quotes and clean up
        namespace_exports <- gsub('"', "", namespace_exports)
        namespace_exports <- gsub("'", "", namespace_exports)
      }

      # Get function documentation files
      man_files <- list.files("man/", pattern = "\\.Rd$", full.names = FALSE)
      documented_functions <- gsub("\\.Rd$", "", man_files)

      # Create inventory
      inventory <- list(
        metadata = list(
          audit_date = Sys.Date(),
          audit_time = Sys.time(),
          total_r_files = length(r_files),
          total_man_files = length(man_files),
          total_exports = length(namespace_exports)
        ),
        r_files = r_files,
        namespace_exports = namespace_exports,
        documented_functions = documented_functions,
        export_status = list(
          exported_and_documented = intersect(namespace_exports, documented_functions),
          exported_not_documented = setdiff(namespace_exports, documented_functions),
          documented_not_exported = setdiff(documented_functions, namespace_exports)
        )
      )

      return(inventory)
    },
    error = function(e) {
      warning("Failed to create function inventory: ", e$message)
      list(error = e$message)
    }
  )
}

#' Categorize Functions by Type and Purpose
#'
#' @param inventory Function inventory from create_function_inventory()
#' @return Categorized function list
#' @keywords internal
categorize_functions <- function(inventory) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'categorize_functions' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  if (is.null(inventory) || "error" %in% names(inventory)) {
    return(list(error = "Invalid inventory provided"))
  }

  # Define function categories based on naming patterns and purpose
  categories <- list(
    essential = c(
      "analyze_transcripts", "process_zoom_transcript", "load_zoom_transcript",
      "consolidate_transcript", "summarize_transcript_metrics", "plot_users",
      "write_metrics", "ensure_privacy", "set_privacy_defaults", "privacy_audit",
      "load_roster", "load_session_mapping", "safe_name_matching_workflow",
      "validate_schema", "validate_privacy_compliance"
    ),
    deprecated = c(
      "add_dead_air_rows", "make_transcripts_session_summary_df", "make_sections_df",
      "join_transcripts_list", "validate_ethical_use", "create_ethical_use_report",
      "audit_ethical_usage", "make_blank_cancelled_classes_df", "load_section_names_lookup",
      "create_session_mapping", "is_verbose", "diag_message", "make_blank_section_names_lookup_csv",
      "process_ideal_course_batch", "compare_ideal_sessions", "validate_ideal_scenarios",
      "extract_character_values", "detect_privacy_violations", "normalize_name_for_matching",
      "write_engagement_metrics", "log_privacy_operation", "make_names_to_clean_df",
      "export_ideal_transcripts_csv", "export_ideal_transcripts_json", "export_ideal_transcripts_excel",
      "export_ideal_transcripts_summary", "generate_ferpa_report", "check_data_retention_policy",
      "make_roster_small", "classify_participants"
    ),
    advanced = c(
      "analyze_multi_session_attendance", "anonymize_educational_data",
      "calculate_content_similarity", "detect_duplicate_transcripts",
      "ensure_instructor_rows", "create_analysis_config", "create_course_info",
      "detect_unmatched_names", "prompt_name_matching", "run_student_reports"
    ),
    utility = c(
      "conditionally_write_lookup", "get_essential_functions", "get_deprecated_functions"
    )
  )

  # Categorize each exported function
  exported_functions <- inventory$namespace_exports
  categorization <- list()

  for (func in exported_functions) {
    category <- "uncategorized"
    for (cat_name in names(categories)) {
      if (func %in% categories[[cat_name]]) {
        category <- cat_name
        break
      }
    }
    categorization[[func]] <- category
  }

  # Create summary
  summary <- list(
    total_exported = length(exported_functions),
    essential_count = sum(categorization == "essential"),
    deprecated_count = sum(categorization == "deprecated"),
    advanced_count = sum(categorization == "advanced"),
    utility_count = sum(categorization == "utility"),
    uncategorized_count = sum(categorization == "uncategorized"),
    categorization = categorization
  )

  summary
}

#' Map Function Dependencies
#'
#' @param inventory Function inventory from create_function_inventory()
#' @return Dependency map
#' @keywords internal
map_function_dependencies <- function(inventory) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'map_function_dependencies' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  if (is.null(inventory) || "error" %in% names(inventory)) {
    return(list(error = "Invalid inventory provided"))
  }

  # Simple dependency mapping based on function calls
  # This is a simplified approach - in practice, you might want more sophisticated parsing

  dependencies <- list(
    essential_functions = list(
      analyze_transcripts = c("process_zoom_transcript", "consolidate_transcript", "summarize_transcript_metrics"),
      process_zoom_transcript = c("load_zoom_transcript", "ensure_privacy"),
      consolidate_transcript = c("load_zoom_transcript", "ensure_privacy"),
      summarize_transcript_metrics = c("consolidate_transcript", "plot_users"),
      plot_users = c("ensure_privacy", "write_metrics")
    ),
    deprecated_functions = list(
      add_dead_air_rows = c("process_zoom_transcript"),
      make_transcripts_session_summary_df = c("analyze_transcripts"),
      make_sections_df = c("load_roster"),
      join_transcripts_list = c("load_zoom_transcript")
    )
  )

  dependencies
}

#' Generate Function Audit Report
#'
#' @param inventory Function inventory
#' @param categorization Function categorization
#' @param dependencies Function dependencies
#' @return Formatted audit report
#' @keywords internal
generate_function_audit_report <- function(inventory, categorization, dependencies) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'generate_function_audit_report' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  if (is.null(inventory) || "error" %in% names(inventory)) {
    return("ERROR: Invalid inventory provided")
  }

  report <- paste0(
    "=== FUNCTION AUDIT REPORT ===\n",
    "Audit Date: ", format(Sys.Date(), "%Y-%m-%d"), "\n",
    "Audit Time: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n",
    "INVENTORY SUMMARY:\n",
    "  Total R Files: ", inventory$metadata$total_r_files, "\n",
    "  Total Documentation Files: ", inventory$metadata$total_man_files, "\n",
    "  Total Exported Functions: ", inventory$metadata$total_exports, "\n\n",
    "EXPORT STATUS:\n",
    "  Exported and Documented: ", length(inventory$export_status$exported_and_documented), "\n",
    "  Exported but Not Documented: ", length(inventory$export_status$exported_not_documented), "\n",
    "  Documented but Not Exported: ", length(inventory$export_status$documented_not_exported), "\n\n"
  )

  if (!is.null(categorization) && !("error" %in% names(categorization))) {
    report <- paste0(
      report,
      "FUNCTION CATEGORIZATION:\n",
      "  Essential Functions: ", categorization$essential_count, "\n",
      "  Deprecated Functions: ", categorization$deprecated_count, "\n",
      "  Advanced Functions: ", categorization$advanced_count, "\n",
      "  Utility Functions: ", categorization$utility_count, "\n",
      "  Uncategorized Functions: ", categorization$uncategorized_count, "\n\n"
    )
  }

  report
}

#' Save Function Audit Report
#'
#' @param inventory Function inventory
#' @param categorization Function categorization
#' @param dependencies Function dependencies
#' @param output_file Output file path
#' @return TRUE if successful
#' @keywords internal
save_function_audit_report <- function(inventory, categorization, dependencies,
                                       output_file = "function_audit_report.txt") {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'save_function_audit_report' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  tryCatch(
    {
      report <- generate_function_audit_report(inventory, categorization, dependencies)
      writeLines(report, output_file)
      message("Function audit report saved to: ", output_file)
      TRUE
    },
    error = function(e) {
      warning("Failed to save function audit report: ", e$message)
      FALSE
    }
  )
}
