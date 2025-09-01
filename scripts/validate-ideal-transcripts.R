#!/usr/bin/env Rscript

#' Batch Validation for Ideal Course Transcripts
#' 
#' This script validates all ideal course transcripts to ensure quality and consistency.
#' It can be run from the command line or sourced within R.
#' 
#' @param output_file File to save validation results (default: "validation_results.rds")
#' @param verbose Whether to print detailed results (default: TRUE)
#' @param validation_options List of validation options (default: NULL)
#' @param save_detailed Whether to save detailed reports (default: TRUE)
#' @return Validation results summary
#' @export
#' @examples
#' \dontrun{
#' # Run batch validation
#' results <- validate_ideal_transcripts_batch()
#' 
#' # Run with custom options
#' options <- list(quality_threshold = 0.9, strict_mode = FALSE)
#' results <- validate_ideal_transcripts_batch(
#'   output_file = "custom_validation.rds",
#'   validation_options = options
#' )
#' }
validate_ideal_transcripts_batch <- function(output_file = "validation_results.rds",
                                            verbose = TRUE,
                                            validation_options = NULL,
                                            save_detailed = TRUE) {
  
  # Load package
  if (!requireNamespace("zoomstudentengagement", quietly = TRUE)) {
    stop("zoomstudentengagement package is required")
  }
  
  # Get ideal course transcript directory
  transcript_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  if (!dir.exists(transcript_dir)) {
    stop("Ideal course transcript directory not found")
  }
  
  if (verbose) {
    cat("🔍 Starting batch validation of ideal course transcripts\n")
    cat("📁 Transcript directory:", transcript_dir, "\n")
    cat("⏰ Timestamp:", as.character(Sys.time()), "\n\n")
  }
  
  # Define ideal course session files
  session_files <- c(
    "ideal_course_session1.vtt",
    "ideal_course_session2.vtt",
    "ideal_course_session3.vtt"
  )
  
  # Initialize results storage
  batch_results <- list(
    timestamp = Sys.time(),
    transcript_dir = transcript_dir,
    session_results = list(),
    summary = list(),
    overall_status = "PENDING",
    validation_options = validation_options
  )
  
  # Process each session
  for (i in seq_along(session_files)) {
    session_file <- session_files[i]
    session_name <- paste0("session", i)
    session_path <- file.path(transcript_dir, session_file)
    
    if (verbose) {
      cat("📋 Processing", session_name, "(", session_file, ")\n")
    }
    
    if (!file.exists(session_path)) {
      if (verbose) {
        cat("❌ File not found:", session_file, "\n")
      }
      batch_results$session_results[[session_name]] <- list(
        status = "FAIL",
        error = "File not found"
      )
      next
    }
    
    tryCatch({
      # Run comprehensive validation
      validation_result <- validate_ideal_transcript_comprehensive(
        file_path = session_path,
        validation_options = validation_options,
        detailed_report = save_detailed
      )
      
      batch_results$session_results[[session_name]] <- validation_result
      
      if (verbose) {
        status_icon <- switch(validation_result$overall_status,
                             "PASS" = "✅",
                             "WARN" = "⚠️",
                             "FAIL" = "❌",
                             "?")
        cat(status_icon, "Status:", validation_result$overall_status, "\n")
        
        if (validation_result$overall_status == "FAIL") {
          cat("   Issues:", length(unlist(validation_result$validation_results)), "\n")
        }
        if (validation_result$overall_status == "WARN") {
          cat("   Warnings:", length(unlist(validation_result$validation_results)), "\n")
        }
        cat("\n")
      }
      
    }, error = function(e) {
      if (verbose) {
        cat("❌ Error processing", session_name, ":", e$message, "\n\n")
      }
      batch_results$session_results[[session_name]] <- list(
        status = "FAIL",
        error = e$message
      )
    })
  }
  
  # Calculate batch summary
  batch_results$summary <- calculate_batch_summary(batch_results)
  batch_results$overall_status <- determine_batch_status(batch_results)
  
  # Save results if requested
  if (!is.null(output_file)) {
    tryCatch({
      saveRDS(batch_results, output_file)
      if (verbose) {
        cat("💾 Results saved to:", output_file, "\n")
      }
    }, error = function(e) {
      if (verbose) {
        cat("⚠️  Warning: Could not save results to", output_file, ":", e$message, "\n")
      }
    })
  }
  
  # Print final summary
  if (verbose) {
    print_batch_summary(batch_results)
  }
  
  return(batch_results)
}

#' Calculate batch summary statistics
#' @keywords internal
calculate_batch_summary <- function(batch_results) {
  summary <- list()
  
  # Count sessions by status
  session_statuses <- sapply(batch_results$session_results, function(x) {
    if (is.list(x) && "overall_status" %in% names(x)) {
      x$overall_status
    } else if (is.list(x) && "status" %in% names(x)) {
      x$status
    } else {
      "UNKNOWN"
    }
  })
  
  summary$total_sessions <- length(session_statuses)
  summary$passed_sessions <- sum(session_statuses == "PASS")
  summary$warning_sessions <- sum(session_statuses == "WARN")
  summary$failed_sessions <- sum(session_statuses == "FAIL")
  summary$unknown_sessions <- sum(session_statuses == "UNKNOWN")
  
  # Calculate overall metrics
  summary$pass_rate <- summary$passed_sessions / summary$total_sessions
  summary$success_rate <- (summary$passed_sessions + summary$warning_sessions) / summary$total_sessions
  
  # Collect all issues and warnings
  all_issues <- list()
  all_warnings <- list()
  
  for (session_name in names(batch_results$session_results)) {
    session_result <- batch_results$session_results[[session_name]]
    
    if (is.list(session_result) && "validation_results" %in% names(session_result)) {
      # Extract issues and warnings from validation results
      for (validation_type in names(session_result$validation_results)) {
        validation_result <- session_result$validation_results[[validation_type]]
        
        if (is.list(validation_result) && "issues" %in% names(validation_result)) {
          all_issues[[paste0(session_name, ".", validation_type)]] <- validation_result$issues
        }
        
        if (is.list(validation_result) && "warnings" %in% names(validation_result)) {
          all_warnings[[paste0(session_name, ".", validation_type)]] <- validation_result$warnings
        }
      }
    }
  }
  
  summary$total_issues <- length(unlist(all_issues))
  summary$total_warnings <- length(unlist(all_warnings))
  summary$all_issues <- all_issues
  summary$all_warnings <- all_warnings
  
  return(summary)
}

#' Determine overall batch status
#' @keywords internal
determine_batch_status <- function(batch_results) {
  summary <- batch_results$summary
  
  if (summary$failed_sessions > 0) {
    return("FAIL")
  } else if (summary$warning_sessions > 0) {
    return("WARN")
  } else if (summary$passed_sessions > 0) {
    return("PASS")
  } else {
    return("UNKNOWN")
  }
}

#' Print batch summary
#' @keywords internal
print_batch_summary <- function(batch_results) {
  summary <- batch_results$summary
  
  cat("📊 BATCH VALIDATION SUMMARY\n")
  cat("==========================\n")
  cat("⏰ Timestamp:", as.character(batch_results$timestamp), "\n")
  cat("📁 Directory:", batch_results$transcript_dir, "\n")
  cat("📋 Total sessions:", summary$total_sessions, "\n")
  cat("✅ Passed:", summary$passed_sessions, "\n")
  cat("⚠️  Warnings:", summary$warning_sessions, "\n")
  cat("❌ Failed:", summary$failed_sessions, "\n")
  cat("❓ Unknown:", summary$unknown_sessions, "\n")
  cat("📈 Pass rate:", round(summary$pass_rate * 100, 1), "%\n")
  cat("🎯 Success rate:", round(summary$success_rate * 100, 1), "%\n")
  cat("🚨 Total issues:", summary$total_issues, "\n")
  cat("⚠️  Total warnings:", summary$total_warnings, "\n")
  cat("🏆 Overall status:", batch_results$overall_status, "\n\n")
  
  # Print session-specific results
  cat("📋 SESSION DETAILS\n")
  cat("==================\n")
  for (session_name in names(batch_results$session_results)) {
    session_result <- batch_results$session_results[[session_name]]
    
    status_icon <- switch(session_result$overall_status %||% session_result$status,
                         "PASS" = "✅",
                         "WARN" = "⚠️",
                         "FAIL" = "❌",
                         "?")
    
    cat(status_icon, session_name, ":", session_result$overall_status %||% session_result$status, "\n")
    
    if (is.list(session_result) && "validation_results" %in% names(session_result)) {
      for (validation_type in names(session_result$validation_results)) {
        validation_result <- session_result$validation_results[[validation_type]]
        
        if (is.list(validation_result) && "status" %in% names(validation_result)) {
          type_icon <- switch(validation_result$status,
                             "PASS" = "  ✅",
                             "WARN" = "  ⚠️",
                             "FAIL" = "  ❌",
                             "  ?")
          cat(type_icon, validation_type, ":", validation_result$status, "\n")
        }
      }
    }
    cat("\n")
  }
  
  # Print recommendations if any
  if (summary$total_issues > 0 || summary$total_warnings > 0) {
    cat("💡 RECOMMENDATIONS\n")
    cat("==================\n")
    
    if (summary$failed_sessions > 0) {
      cat("❌ Critical: Fix failed sessions before proceeding\n")
    }
    
    if (summary$warning_sessions > 0) {
      cat("⚠️  Review: Address warnings in sessions with issues\n")
    }
    
    if (summary$total_issues > 0) {
      cat("🔧 Action: Review and fix", summary$total_issues, "validation issues\n")
    }
    
    if (summary$total_warnings > 0) {
      cat("📝 Consider: Address", summary$total_warnings, "validation warnings\n")
    }
    
    cat("\n")
  }
}

#' Generate validation report
#' 
#' Generates a detailed validation report for batch results
#' 
#' @param batch_results Results from validate_ideal_transcripts_batch()
#' @param output_file File to save report (default: "validation_report.txt")
#' @param format Report format: "text" or "markdown" (default: "text")
#' @return Report content
#' @export
generate_validation_report <- function(batch_results,
                                      output_file = "validation_report.txt",
                                      format = "text") {
  
  if (format == "text") {
    report <- generate_text_report(batch_results)
  } else if (format == "markdown") {
    report <- generate_markdown_report(batch_results)
  } else {
    stop("Unsupported format. Use 'text' or 'markdown'")
  }
  
  # Save report if requested
  if (!is.null(output_file)) {
    tryCatch({
      writeLines(report, output_file)
      cat("📄 Report saved to:", output_file, "\n")
    }, error = function(e) {
      cat("⚠️  Warning: Could not save report to", output_file, ":", e$message, "\n")
    })
  }
  
  return(report)
}

#' Generate text report
#' @keywords internal
generate_text_report <- function(batch_results) {
  summary <- batch_results$summary
  
  report <- c(
    "IDEAL COURSE TRANSCRIPT VALIDATION REPORT",
    "==========================================",
    "",
    paste("Timestamp:", as.character(batch_results$timestamp)),
    paste("Transcript Directory:", batch_results$transcript_dir),
    paste("Overall Status:", batch_results$overall_status),
    "",
    "SUMMARY STATISTICS",
    "------------------",
    paste("Total Sessions:", summary$total_sessions),
    paste("Passed:", summary$passed_sessions),
    paste("Warnings:", summary$warning_sessions),
    paste("Failed:", summary$failed_sessions),
    paste("Pass Rate:", round(summary$pass_rate * 100, 1), "%"),
    paste("Success Rate:", round(summary$success_rate * 100, 1), "%"),
    paste("Total Issues:", summary$total_issues),
    paste("Total Warnings:", summary$total_warnings),
    "",
    "SESSION DETAILS",
    "---------------"
  )
  
  for (session_name in names(batch_results$session_results)) {
    session_result <- batch_results$session_results[[session_name]]
    
    report <- c(report,
                "",
                paste("Session:", session_name),
                paste("Status:", session_result$overall_status %||% session_result$status)
    )
    
    if (is.list(session_result) && "validation_results" %in% names(session_result)) {
      for (validation_type in names(session_result$validation_results)) {
        validation_result <- session_result$validation_results[[validation_type]]
        
        if (is.list(validation_result) && "status" %in% names(validation_result)) {
          report <- c(report,
                      paste("  ", validation_type, ":", validation_result$status)
          )
        }
      }
    }
  }
  
  # Add issues and warnings if any
  if (summary$total_issues > 0 || summary$total_warnings > 0) {
    report <- c(report,
                "",
                "ISSUES AND WARNINGS",
                "-------------------"
    )
    
    if (summary$total_issues > 0) {
      report <- c(report,
                  "",
                  "ISSUES:",
                  ""
      )
      
      for (issue_key in names(summary$all_issues)) {
        issues <- summary$all_issues[[issue_key]]
        report <- c(report,
                    paste("  ", issue_key, ":"),
                    paste("    ", issues)
        )
      }
    }
    
    if (summary$total_warnings > 0) {
      report <- c(report,
                  "",
                  "WARNINGS:",
                  ""
      )
      
      for (warning_key in names(summary$all_warnings)) {
        warnings <- summary$all_warnings[[warning_key]]
        report <- c(report,
                    paste("  ", warning_key, ":"),
                    paste("    ", warnings)
        )
      }
    }
  }
  
  return(report)
}

#' Generate markdown report
#' @keywords internal
generate_markdown_report <- function(batch_results) {
  summary <- batch_results$summary
  
  report <- c(
    "# Ideal Course Transcript Validation Report",
    "",
    paste("**Timestamp:**", as.character(batch_results$timestamp)),
    paste("**Transcript Directory:**", batch_results$transcript_dir),
    paste("**Overall Status:**", batch_results$overall_status),
    "",
    "## Summary Statistics",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    paste("| Total Sessions |", summary$total_sessions, "|"),
    paste("| Passed |", summary$passed_sessions, "|"),
    paste("| Warnings |", summary$warning_sessions, "|"),
    paste("| Failed |", summary$failed_sessions, "|"),
    paste("| Pass Rate |", round(summary$pass_rate * 100, 1), "% |"),
    paste("| Success Rate |", round(summary$success_rate * 100, 1), "% |"),
    paste("| Total Issues |", summary$total_issues, "|"),
    paste("| Total Warnings |", summary$total_warnings, "|"),
    "",
    "## Session Details",
    ""
  )
  
  for (session_name in names(batch_results$session_results)) {
    session_result <- batch_results$session_results[[session_name]]
    
    report <- c(report,
                paste("###", session_name),
                "",
                paste("**Status:**", session_result$overall_status %||% session_result$status),
                ""
    )
    
    if (is.list(session_result) && "validation_results" %in% names(session_result)) {
      report <- c(report,
                  "| Validation Type | Status |",
                  "|----------------|--------|"
      )
      
      for (validation_type in names(session_result$validation_results)) {
        validation_result <- session_result$validation_results[[validation_type]]
        
        if (is.list(validation_result) && "status" %in% names(validation_result)) {
          report <- c(report,
                      paste("|", validation_type, "|", validation_result$status, "|")
          )
        }
      }
      report <- c(report, "")
    }
  }
  
  # Add issues and warnings if any
  if (summary$total_issues > 0 || summary$total_warnings > 0) {
    report <- c(report,
                "## Issues and Warnings",
                ""
    )
    
    if (summary$total_issues > 0) {
      report <- c(report,
                  "### Issues",
                  ""
      )
      
      for (issue_key in names(summary$all_issues)) {
        issues <- summary$all_issues[[issue_key]]
        report <- c(report,
                    paste("####", issue_key),
                    ""
        )
        
        for (issue in issues) {
          report <- c(report,
                      paste("-", issue)
          )
        }
        report <- c(report, "")
      }
    }
    
    if (summary$total_warnings > 0) {
      report <- c(report,
                  "### Warnings",
                  ""
      )
      
      for (warning_key in names(summary$all_warnings)) {
        warnings <- summary$all_warnings[[warning_key]]
        report <- c(report,
                    paste("####", warning_key),
                    ""
        )
        
        for (warning in warnings) {
          report <- c(report,
                      paste("-", warning)
          )
        }
        report <- c(report, "")
      }
    }
  }
  
  return(report)
}

# Command line interface
if (!interactive()) {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  
  # Default values
  output_file <- "validation_results.rds"
  verbose <- TRUE
  save_detailed <- TRUE
  report_format <- "text"
  report_file <- NULL
  
  # Parse arguments
  i <- 1
  while (i <= length(args)) {
    if (args[i] == "--output" && i + 1 <= length(args)) {
      output_file <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--quiet") {
      verbose <- FALSE
      i <- i + 1
    } else if (args[i] == "--no-details") {
      save_detailed <- FALSE
      i <- i + 1
    } else if (args[i] == "--report" && i + 1 <= length(args)) {
      report_file <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--report-format" && i + 1 <= length(args)) {
      report_format <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--help") {
      cat("Usage: Rscript validate-ideal-transcripts.R [options]\n")
      cat("\nOptions:\n")
      cat("  --output FILE        Output file for results (default: validation_results.rds)\n")
      cat("  --quiet              Suppress verbose output\n")
      cat("  --no-details         Don't save detailed reports\n")
      cat("  --report FILE        Generate validation report\n")
      cat("  --report-format FMT  Report format: text or markdown (default: text)\n")
      cat("  --help               Show this help message\n")
      cat("\nExamples:\n")
      cat("  Rscript validate-ideal-transcripts.R\n")
      cat("  Rscript validate-ideal-transcripts.R --output results.rds --quiet\n")
      cat("  Rscript validate-ideal-transcripts.R --report report.txt --report-format markdown\n")
      quit(status = 0)
    } else {
      cat("Unknown option:", args[i], "\n")
      cat("Use --help for usage information\n")
      quit(status = 1)
    }
  }
  
  # Run batch validation
  tryCatch({
    results <- validate_ideal_transcripts_batch(
      output_file = output_file,
      verbose = verbose,
      save_detailed = save_detailed
    )
    
    # Generate report if requested
    if (!is.null(report_file)) {
      generate_validation_report(results, report_file, report_format)
    }
    
    # Exit with appropriate status code
    if (results$overall_status == "FAIL") {
      quit(status = 1)
    } else if (results$overall_status == "WARN") {
      quit(status = 2)
    } else {
      quit(status = 0)
    }
    
  }, error = function(e) {
    cat("Error:", e$message, "\n")
    quit(status = 1)
  })
}
