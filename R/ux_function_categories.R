#' UX Function Categories for Progressive Disclosure
#' 
#' @description Categorizes functions by user experience level to implement
#'   progressive disclosure and simplify the interface for new users.
#' @keywords internal
#' @noRd

# Essential functions (always visible to all users - core workflow)
UX_ESSENTIAL_FUNCTIONS <- c(
  "load_zoom_transcript",
  "process_zoom_transcript", 
  "analyze_transcripts",
  "plot_users",
  "write_metrics"
)

# Common functions (visible with help system - frequently used)
UX_COMMON_FUNCTIONS <- c(
  "validate_schema",
  "consolidate_transcript",
  "join_transcripts_list",
  "load_roster",
  "load_session_mapping",
  "safe_name_matching_workflow",
  "ensure_privacy",
  "set_privacy_defaults",
  "privacy_audit",
  "write_engagement_metrics"
)

# Advanced functions (hidden by default, accessible via help - specialized tasks)
UX_ADVANCED_FUNCTIONS <- c(
  "analyze_multi_session_attendance",
  "classify_participants",
  "calculate_content_similarity",
  "detect_duplicate_transcripts",
  "detect_unmatched_names",
  "generate_attendance_report",
  "generate_ferpa_report",
  "hash_name_consistently",
  "mask_user_names_by_metric",
  "match_names_with_privacy",
  "process_transcript_with_privacy",
  "prompt_name_matching",
  "summarize_transcript_files",
  "summarize_transcript_metrics",
  "validate_ethical_use",
  "validate_ferpa_compliance",
  "validate_privacy_compliance"
)

# Expert/Internal functions (hidden from basic users - development/utility)
UX_EXPERT_FUNCTIONS <- c(
  "add_dead_air_rows",
  "anonymize_educational_data",
  "audit_ethical_usage",
  "check_data_retention_policy",
  "compare_ideal_sessions",
  "conditionally_write_lookup",
  "create_analysis_config",
  "create_course_info",
  "create_ethical_use_report",
  "create_session_mapping",
  "ensure_instructor_rows",
  "export_ideal_transcripts_csv",
  "export_ideal_transcripts_excel",
  "export_ideal_transcripts_json",
  "export_ideal_transcripts_summary",
  "get_deprecated_functions",
  "get_essential_functions",
  "get_internal_functions",
  "get_scope_reduction_summary",
  "load_cancelled_classes",
  "load_section_names_lookup",
  "load_transcript_files_list",
  "load_zoom_recorded_sessions_list",
  "make_blank_cancelled_classes_df",
  "make_blank_section_names_lookup_csv",
  "make_clean_names_df",
  "make_metrics_lookup_df",
  "make_names_to_clean_df",
  "make_new_analysis_template",
  "make_roster_small",
  "make_sections_df",
  "make_semester_df",
  "make_student_roster_sessions",
  "make_students_only_transcripts_summary_df",
  "make_transcripts_session_summary_df",
  "make_transcripts_summary_df",
  "merge_lookup_preserve",
  "process_ideal_course_batch",
  "read_lookup_safely",
  "validate_ideal_content_quality",
  "validate_ideal_scenarios",
  "validate_ideal_timing_consistency",
  "write_lookup_transactional",
  "write_section_names_lookup",
  "write_transcripts_session_summary",
  "write_transcripts_summary"
)

# Function descriptions for help system
UX_FUNCTION_DESCRIPTIONS <- list(
  # Essential functions
  "load_zoom_transcript" = "Load Zoom transcript files (VTT, TXT, CSV formats)",
  "process_zoom_transcript" = "Clean and prepare transcript data for analysis",
  "analyze_transcripts" = "Calculate student engagement metrics from transcripts",
  "plot_users" = "Create visualizations of student engagement patterns",
  "write_metrics" = "Export engagement metrics to files (CSV, Excel, JSON)",
  
  # Common functions
  "validate_schema" = "Check if data has required columns and structure",
  "consolidate_transcript" = "Combine multiple transcript files into one dataset",
  "join_transcripts_list" = "Merge transcript data with roster information",
  "load_roster" = "Load student roster information",
  "load_session_mapping" = "Load session mapping data",
  "safe_name_matching_workflow" = "Match student names while preserving privacy",
  "ensure_privacy" = "Apply privacy protection to data",
  "set_privacy_defaults" = "Configure default privacy settings",
  "privacy_audit" = "Check data for privacy compliance",
  "write_engagement_metrics" = "Export detailed engagement metrics"
)
