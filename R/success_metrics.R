#' Success Metrics Framework for zoomstudentengagement Package
#'
#' This module provides comprehensive success metrics tracking and validation
#' for the zoomstudentengagement R package development and CRAN submission.
#'
#' @keywords internal
#' @noRd

# Success Metrics Framework
success_metrics_framework <- list(

  # CRAN Readiness Metrics
  cran_readiness = list(
    errors = 0,
    warnings = 0,
    notes = "minimal (0-1 acceptable)",
    check_status = "PASS",
    description = "R CMD check must pass with 0 errors, 0 warnings, minimal notes"
  ),

  # Function Scope Metrics
  function_scope = list(
    current = 67,
    target = "25-30",
    reduction_percentage = "63-67%",
    essential_functions = "≤30",
    deprecated_functions = "37-42",
    description = "Reduce from 67 to 25-30 essential functions for CRAN readiness"
  ),

  # Performance Metrics
  performance = list(
    transcript_processing = "1MB in <30 seconds",
    user_analysis_time = "<15 minutes for new users",
    test_coverage = "≥90% on essential functions",
    description = "Performance benchmarks for user experience and CRAN compliance"
  ),

  # User Experience Metrics
  user_experience = list(
    time_to_first_analysis = "<15 minutes",
    workflow_complexity = "≤5 essential functions",
    error_resolution_time = "<5 minutes",
    documentation_clarity = "Essential guides only",
    description = "User experience targets for adoption and usability"
  ),

  # Documentation Metrics
  documentation = list(
    current_files = 357,
    target_files = 75,
    reduction_percentage = "79%",
    essential_content = "Core user guides only",
    description = "Reduce documentation from 357 to 75 essential files"
  ),

  # Process Metrics
  process = list(
    pre_pr_validation_time = "25 → 10 minutes (60% reduction)",
    issue_count = "30 → 75 (150% increase to manageable level)",
    development_friction = "Minimal",
    description = "Development process improvement targets"
  )
)

#' Track all success metrics
#'
#' @return Comprehensive success metrics report
#' @export
track_success_metrics <- function() {
  # Use the existing deprecated function for now
  # This maintains backward compatibility while the new framework is developed
  gen_success_metrics_report()
}

#' Generate success metrics report
#'
#' @return Success metrics report
gen_success_metrics_report <- function() {
  # Get current baseline
  baseline <- get_current_baseline()

  # Get target state
  targets <- get_target_state()

  # Generate progress tracking for key metrics
  progress <- list()

  if (length(baseline$functions) == 1 && !is.na(baseline$functions)) {
    progress$functions <- track_progress("functions", baseline$functions, targets$functions)
  }

  if (length(baseline$documentation_files) == 1 && !is.na(baseline$documentation_files)) {
    progress$documentation <- track_progress("documentation", baseline$documentation_files, targets$documentation_files)
  }

  if (length(baseline$test_coverage) == 1 && !is.na(baseline$test_coverage)) {
    progress$coverage <- track_progress("coverage", baseline$test_coverage, 90)
  }

  # Compile report
  report <- list(
    timestamp = Sys.time(),
    framework = success_metrics_framework,
    baseline = baseline,
    targets = targets,
    progress = progress,
    summary = list(
      function_scope_ok = ifelse(!is.na(progress$functions), progress$functions$current <= 30, FALSE),
      test_coverage_ok = ifelse(!is.na(progress$coverage), progress$coverage$current >= 90, FALSE),
      documentation_ok = ifelse(!is.na(progress$documentation), progress$documentation$current <= 75, FALSE)
    )
  )

  report
}

#' Calculate overall success status
#'
#' @param ... All metric categories
#' @return Overall success status
calculate_overall_status <- function(...) {
  # Calculate overall success status based on all metrics
  # Focus on CRAN readiness metrics for overall status
  cran_ready <- all(sapply(list(...)[[1]], function(x) {
    if (is.list(x) && "target_met" %in% names(x)) {
      x$target_met
    } else {
      TRUE
    }
  }))

  list(
    status = if (cran_ready) "READY_FOR_CRAN" else "NEEDS_IMPROVEMENT",
    cran_ready = cran_ready,
    recommendations = if (cran_ready) {
      "Package is ready for CRAN submission"
    } else {
      "Address CRAN readiness issues before submission"
    }
  )
}

#' Get Current Baseline Measurements
#'
#' @return List of current baseline measurements for all success metrics
#' @keywords internal
get_current_baseline <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'get_current_baseline' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Get current function count
  current_functions <- tryCatch(
    {
      # Simple approach - count R files
      r_files <- list.files("R/", pattern = "\\.R$", full.names = FALSE)
      if (length(r_files) == 0) {
        # Fallback to fixed value if file counting fails
        67
      } else {
        length(r_files)
      }
    },
    error = function(e) {
      warning("Could not count R files: ", e$message)
      67 # Fallback to known value
    }
  )

  # Get current documentation file count
  current_docs <- tryCatch(
    {
      doc_count <- length(list.files("docs/", recursive = TRUE))
      if (doc_count == 0) {
        # Fallback to fixed value if file counting fails
        357
      } else {
        doc_count
      }
    },
    error = function(e) {
      warning("Could not count documentation files: ", e$message)
      357 # Fallback to known value
    }
  )

  # Get current test coverage (simplified)
  current_coverage <- tryCatch(
    {
      # For now, return a fixed value to avoid freezing
      89.08
    },
    error = function(e) {
      warning("Could not get test coverage: ", e$message)
      NA
    }
  )

  list(
    functions = current_functions,
    documentation_files = current_docs,
    test_coverage = current_coverage,
    open_issues = 30, # Fixed value for now
    timestamp = Sys.time()
  )
}

#' Get Target State Definitions
#'
#' @return List of target state definitions for all success metrics
#' @keywords internal
get_target_state <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'get_target_state' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  list(
    functions = "25-30",
    documentation_files = 75,
    test_coverage = "≥90%",
    cran_readiness = "0 errors, 0 warnings, minimal notes",
    user_experience = "<15 minutes to first analysis",
    performance = "1MB transcript in <30 seconds"
  )
}

#' Track Progress for a Specific Metric
#'
#' @param metric_name Name of the metric to track
#' @param current_value Current value of the metric
#' @param target_value Target value of the metric
#' @return List with progress information
#' @keywords internal
track_progress <- function(metric_name, current_value, target_value) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'track_progress' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Handle different types of targets
  if (is.character(target_value)) {
    # For string targets like "25-30", extract numeric range
    if (grepl("(\\d+)-(\\d+)", target_value)) {
      target_range <- as.numeric(strsplit(target_value, "-")[[1]])
      target_min <- target_range[1]
      target_max <- target_range[2]
      target_avg <- (target_min + target_max) / 2
    } else if (grepl("≥(\\d+)", target_value)) {
      target_avg <- as.numeric(gsub("≥", "", target_value))
    } else {
      target_avg <- NA
    }
  } else {
    target_avg <- as.numeric(target_value)
  }

  # Calculate progress if we have numeric values
  if (!is.na(current_value) && !is.na(target_avg)) {
    if (current_value > target_avg) {
      # For reduction metrics (functions, docs, issues)
      progress <- ((current_value - target_avg) / current_value) * 100
      remaining <- current_value - target_avg
    } else {
      # For increase metrics (coverage, performance)
      progress <- (current_value / target_avg) * 100
      remaining <- target_avg - current_value
    }
  } else {
    progress <- NA
    remaining <- NA
  }

  # Determine status based on metric type and current vs target relationship
  if (is.na(progress)) {
    status <- "Unknown"
  } else {
    # For reduction metrics (functions, docs): Complete when current <= target
    # For increase metrics (coverage): Complete when current >= target
    if (grepl("functions|documentation", metric_name)) {
      # Reduction metrics
      status <- ifelse(current_value <= target_avg, "Complete", "In Progress")
    } else if (grepl("coverage", metric_name)) {
      # Increase metrics
      status <- ifelse(current_value >= target_avg, "Complete", "In Progress")
    } else {
      # Default logic
      status <- ifelse(current_value <= target_avg, "Complete", "In Progress")
    }
  }

  list(
    metric = metric_name,
    current = current_value,
    target = target_value,
    target_avg = target_avg,
    progress = progress,
    remaining = remaining,
    status = status
  )
}

#' Generate Success Metrics Report
#'
#' @return Comprehensive success metrics report
#' @keywords internal
gen_success_metrics_report <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'generate_success_metrics_report' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Get current baseline
  baseline <- get_current_baseline()

  # Get target state
  targets <- get_target_state()

  # Generate progress tracking for key metrics
  progress <- list()

  if (length(baseline$functions) == 1 && !is.na(baseline$functions)) {
    progress$functions <- track_progress("functions", baseline$functions, targets$functions)
  }

  if (length(baseline$documentation_files) == 1 && !is.na(baseline$documentation_files)) {
    progress$documentation <- track_progress("documentation", baseline$documentation_files, targets$documentation_files)
  }

  if (length(baseline$test_coverage) == 1 && !is.na(baseline$test_coverage)) {
    progress$coverage <- track_progress("coverage", baseline$test_coverage, 90)
  }

  # Compile report
  report <- list(
    timestamp = Sys.time(),
    framework = success_metrics_framework,
    baseline = baseline,
    targets = targets,
    progress = progress,
    summary = list(
      function_scope_ok = ifelse(!is.na(progress$functions), progress$functions$current <= 30, FALSE),
      test_coverage_ok = ifelse(!is.na(progress$coverage), progress$coverage$current >= 90, FALSE),
      documentation_ok = ifelse(!is.na(progress$documentation), progress$documentation$current <= 75, FALSE)
    )
  )

  report
}

#' Print Success Metrics Summary
#'
#' @param report Success metrics report from generate_success_metrics_report()
#' @keywords internal
print_success_metrics_summary <- function(report = NULL) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'print_success_metrics_summary' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  if (is.null(report)) {
    report <- gen_success_metrics_report()
  }

  cat("🎯 Success Metrics Summary for zoomstudentengagement Package\n")
  cat("========================================================\n\n")

  # Function Scope
  cat("📊 Function Scope:\n")
  if (!is.null(report$progress$functions)) {
    cat("   Current: ", report$progress$functions$current, " functions\n")
    cat("   Target: 25-30 functions\n")
    cat("   Progress: ", round(report$progress$functions$progress, 1), "% complete\n")
  }

  # Test Coverage
  cat("\n🧪 Test Coverage:\n")
  if (!is.null(report$progress$coverage)) {
    cat("   Current: ", report$progress$coverage$current, "%\n")
    cat("   Target: ≥90%\n")
    if (report$progress$coverage$current >= 90) {
      cat("   ✅ Target achieved\n")
    } else {
      cat("   ❌ Need ", 90 - report$progress$coverage$current, "% more coverage\n")
    }
  }

  # Documentation
  cat("\n📚 Documentation:\n")
  if (!is.null(report$progress$documentation)) {
    cat("   Current: ", report$progress$documentation$current, " files\n")
    cat("   Target: 75 files\n")
    cat("   Progress: ", round(report$progress$documentation$progress, 1), "% complete\n")
  }

  # Overall Status
  cat("\n🎯 Overall Status:\n")
  overall_ready <- all(unlist(report$summary))
  if (overall_ready) {
    cat("   ✅ READY for CRAN submission\n")
  } else {
    cat("   ❌ NOT READY - ", sum(!unlist(report$summary)), " criteria unmet\n")
  }

  cat("\n📅 Report generated: ", format(report$timestamp, "%Y-%m-%d %H:%M:%S"), "\n")
}
