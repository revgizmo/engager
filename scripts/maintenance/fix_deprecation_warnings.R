#!/usr/bin/env Rscript

# Fix deprecation warning line length issues
files_with_deprecation <- c(
  "R/ideal-course-batch.R", "R/success_metrics.R", "R/scope_reduction_tracker.R",
  "R/safe_name_matching_workflow.R", "R/prompt_name_matching.R", "R/make_semester_df.R",
  "R/make_metrics_lookup_df.R", "R/function_audit_system.R", "R/benchmark-ideal-transcripts.R",
  "R/write_engagement_metrics.R", "R/validate_privacy_compliance.R", "R/utils_diagnostics.R",
  "R/participant_classification.R", "R/make_transcripts_session_summary_df.R", "R/make_sections_df.R",
  "R/make_roster_small.R", "R/make_names_to_clean_df.R", "R/make_blank_section_names_lookup_csv.R",
  "R/make_blank_cancelled_classes_df.R", "R/load_section_names_lookup.R", "R/join_transcripts_list.R",
  "R/ideal-transcript-export.R", "R/hash_name_consistently.R", "R/ferpa_compliance.R",
  "R/ethical_compliance.R", "R/ensure_privacy.R", "R/create_session_mapping.R",
  "R/create_analysis_config.R", "R/run_student_reports.R", "R/plot_users_masked_section_by_metric.R",
  "R/plot_users_by_metric.R", "R/make_clean_names_df.R", "R/lookup_merge_utils.R",
  "R/load_and_process_zoom_transcript.R", "R/ideal-transcript-validation.R", "R/create_course_info.R"
)

for (file_path in files_with_deprecation) {
  if (!file.exists(file_path)) {
    cat("File not found:", file_path, "\n")
    next
  }
  
  cat("Processing", file_path, "\n")
  
  # Read the file
  lines <- readLines(file_path)
  
  # Find and fix long deprecation warnings
  for (i in seq_along(lines)) {
    line <- lines[i]
    
    # Check if this is a long deprecation warning
    if (nchar(line) > 120 && 
        grepl("warning\\(", line) && 
        grepl("deprecated", line) && 
        grepl("essential functions", line)) {
      
      cat("  Fixing line", i, "(", nchar(line), "characters)\n")
      
      # Extract function name from the warning
      func_match <- regmatches(line, regexec("Function '([^']+)' is deprecated", line))
      if (length(func_match) > 0 && length(func_match[[1]]) > 1) {
        func_name <- func_match[[1]][2]
        
        # Create the fixed warning
        new_warning <- paste0(
          "  warning(\n",
          "    \"Function '", func_name, "' is deprecated and will be removed in the next version. \",\n",
          "    \"Please use the essential functions instead. See ?get_essential_functions for alternatives.\",\n",
          "    call. = FALSE\n",
          "  )"
        )
        
        lines[i] <- new_warning
      }
    }
  }
  
  # Write the file back
  writeLines(lines, file_path)
}

cat("Deprecation warning fixes completed\n")
