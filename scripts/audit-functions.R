#!/usr/bin/env Rscript

# Comprehensive Function Audit Script
# Analyzes all functions in the zoomstudentengagement package for scope crisis resolution

library(zoomstudentengagement)

cat("🔍 COMPREHENSIVE FUNCTION AUDIT\n")
cat("================================\n\n")

# Load the package to get all functions
devtools::load_all()

# Get all available functions
all_functions <- ls("package:zoomstudentengagement")
exported_functions <- ls("package:zoomstudentengagement")

cat("📊 FUNCTION INVENTORY\n")
cat("--------------------\n")
cat("Total functions loaded:", length(all_functions), "\n")
cat("Exported functions (NAMESPACE):", length(exported_functions), "\n\n")

# Categorize functions by purpose
cat("📋 FUNCTION CATEGORIZATION\n")
cat("-------------------------\n")

# Core workflow functions (essential)
core_workflow <- c(
  "analyze_transcripts",
  "process_zoom_transcript", 
  "load_zoom_transcript",
  "consolidate_transcript",
  "summarize_transcript_metrics",
  "plot_users",
  "write_metrics"
)

# Privacy and compliance functions
privacy_functions <- c(
  "ensure_privacy",
  "set_privacy_defaults",
  "privacy_audit",
  "mask_user_names_by_metric",
  "hash_name_consistently",
  "anonymize_educational_data",
  "validate_privacy_compliance",
  "validate_ferpa_compliance"
)

# Data loading and processing functions
data_functions <- c(
  "load_roster",
  "load_session_mapping",
  "load_transcript_files_list",
  "load_zoom_recorded_sessions_list",
  "load_cancelled_classes",
  "load_section_names_lookup"
)

# Analysis and reporting functions
analysis_functions <- c(
  "analyze_multi_session_attendance",
  "generate_attendance_report",
  "generate_ferpa_report",
  "run_student_reports",
  "calculate_content_similarity",
  "classify_participants"
)

# Utility and helper functions
utility_functions <- c(
  "add_dead_air_rows",
  "detect_duplicate_transcripts",
  "detect_unmatched_names",
  "ensure_instructor_rows",
  "make_clean_names_df",
  "make_names_to_clean_df"
)

# Validation and testing functions
validation_functions <- c(
  "validate_schema",
  "validate_ethical_use",
  "audit_ethical_usage",
  "validate_ideal_transcript_structure",
  "validate_ideal_content_quality"
)

# Export and writing functions
export_functions <- c(
  "write_engagement_metrics",
  "write_lookup_transactional",
  "write_section_names_lookup",
  "write_transcripts_summary",
  "write_transcripts_session_summary"
)

# Categorize all functions
categorized_functions <- list(
  "Core Workflow" = core_workflow,
  "Privacy & Compliance" = privacy_functions,
  "Data Loading" = data_functions,
  "Analysis & Reporting" = analysis_functions,
  "Utilities" = utility_functions,
  "Validation" = validation_functions,
  "Export & Writing" = export_functions
)

# Count functions in each category
cat("Function Categories:\n")
for (category in names(categorized_functions)) {
  count <- length(categorized_functions[[category]])
  cat(sprintf("  %s: %d functions\n", category, count))
}

# Identify uncategorized functions
all_categorized <- unlist(categorized_functions)
uncategorized <- setdiff(all_functions, all_categorized)

cat("\n📝 UNCATEGORIZED FUNCTIONS\n")
cat("-------------------------\n")
if (length(uncategorized) > 0) {
  cat("Count:", length(uncategorized), "\n")
  cat("Functions:", paste(uncategorized, collapse = ", "), "\n")
} else {
  cat("All functions categorized!\n")
}

# Scope reduction analysis
cat("\n🎯 SCOPE REDUCTION ANALYSIS\n")
cat("---------------------------\n")
ideal_count <- 25
current_count <- length(all_functions)
reduction_needed <- current_count - ideal_count
reduction_percentage <- (reduction_needed / current_count) * 100

cat("Current function count:", current_count, "\n")
cat("Ideal function count:", ideal_count, "\n")
cat("Functions to remove:", reduction_needed, "\n")
cat("Reduction needed:", sprintf("%.1f%%", reduction_percentage), "\n")

# Identify deprecation candidates
cat("\n🗑️  DEPRECATION CANDIDATES\n")
cat("------------------------\n")

# Functions that could be deprecated (examples)
deprecation_candidates <- c(
  # Duplicate or overlapping functionality
  "make_transcripts_summary_df",
  "make_transcripts_session_summary_df",
  "make_students_only_transcripts_summary_df",
  
  # Internal utilities that could be made internal
  "make_blank_cancelled_classes_df",
  "make_blank_section_names_lookup_csv",
  "make_metrics_lookup_df",
  "make_roster_small",
  "make_sections_df",
  "make_semester_df",
  
  # Specialized functions for specific use cases
  "benchmark_ideal_transcripts",
  "compare_ideal_sessions",
  "export_ideal_transcripts_csv",
  "export_ideal_transcripts_excel",
  "export_ideal_transcripts_json",
  "export_ideal_transcripts_summary",
  "process_ideal_course_batch",
  "validate_ideal_transcript_comprehensive",
  "validate_ideal_transcript_structure",
  "validate_ideal_content_quality",
  "validate_ideal_name_coverage",
  "validate_ideal_scenarios",
  "validate_ideal_timing_consistency"
)

cat("Deprecation candidates:", length(deprecation_candidates), "\n")
cat("Functions:", paste(deprecation_candidates, collapse = ", "), "\n")

# Essential functions to keep
cat("\n✅ ESSENTIAL FUNCTIONS TO KEEP\n")
cat("------------------------------\n")
essential_functions <- c(
  "analyze_transcripts",           # Main user-facing function
  "process_zoom_transcript",       # Core transcript processing
  "load_zoom_transcript",          # Basic transcript loading
  "consolidate_transcript",        # Transcript consolidation
  "summarize_transcript_metrics",  # Basic metrics
  "plot_users",                    # Basic visualization
  "write_metrics",                 # Basic output
  "ensure_privacy",                # Privacy protection
  "set_privacy_defaults",          # Privacy configuration
  "privacy_audit",                 # Privacy validation
  "load_roster",                   # Roster loading
  "load_session_mapping",          # Session mapping
  "safe_name_matching_workflow",   # Name matching
  "validate_schema",               # Data validation
  "validate_privacy_compliance"    # Compliance checking
)

cat("Essential functions:", length(essential_functions), "\n")
cat("Functions:", paste(essential_functions, collapse = ", "), "\n")

# Summary and recommendations
cat("\n📋 SUMMARY AND RECOMMENDATIONS\n")
cat("-------------------------------\n")
cat("1. IMMEDIATE ACTIONS:\n")
cat("   - Deprecate", length(deprecation_candidates), "non-essential functions\n")
cat("   - Reduce scope from", current_count, "to", ideal_count, "functions\n")
cat("   - Focus on", length(essential_functions), "essential functions\n\n")

cat("2. SCOPE REDUCTION STRATEGY:\n")
cat("   - Phase 1: Deprecate specialized/utility functions\n")
cat("   - Phase 2: Consolidate overlapping functionality\n")
cat("   - Phase 3: Make internal functions non-exported\n\n")

cat("3. CRAN READINESS:\n")
cat("   - Current scope is", sprintf("%.0f%%", (current_count/ideal_count)*100), "over ideal\n")
cat("   - Need", reduction_needed, "functions removed for CRAN submission\n")
cat("   - Focus on core workflow and privacy compliance\n")

cat("\n✅ AUDIT COMPLETE\n")
cat("================\n")
