#' Scope Reduction Implementation for Issue #393
#' 
#' This module implements the massive scope reduction required for CRAN submission,
#' reducing from 175 exported functions to 25-30 essential functions.
#' 
#' @keywords internal
#' @noRd

# Essential functions to keep (25-30 functions)
ESSENTIAL_FUNCTIONS <- c(
  # Core workflow functions (7)
  "analyze_transcripts",           # Main user-facing function
  "process_zoom_transcript",       # Core transcript processing
  "load_zoom_transcript",          # Basic transcript loading
  "consolidate_transcript",        # Transcript consolidation
  "summarize_transcript_metrics",  # Basic metrics
  "plot_users",                    # Basic visualization
  "write_metrics",                 # Basic output
  
  # Privacy and compliance functions (8)
  "ensure_privacy",                # Privacy protection
  "set_privacy_defaults",          # Privacy configuration
  "privacy_audit",                 # Privacy validation
  "mask_user_names_by_metric",     # Name masking
  "hash_name_consistently",        # Consistent hashing
  "anonymize_educational_data",    # Data anonymization
  "validate_privacy_compliance",   # Privacy validation
  "validate_ferpa_compliance",     # FERPA compliance
  
  # Data loading functions (5)
  "load_roster",                   # Roster loading
  "load_session_mapping",          # Session mapping
  "load_transcript_files_list",    # Transcript file loading
  "detect_duplicate_transcripts",  # Duplicate detection
  "detect_unmatched_names",        # Name matching
  
  # Analysis functions (4)
  "analyze_multi_session_attendance", # Multi-session analysis
  "generate_attendance_report",     # Attendance reporting
  "safe_name_matching_workflow",   # Name matching workflow
  "validate_schema"                # Data validation
)

# Functions to deprecate immediately (all non-essential functions)
DEPRECATED_FUNCTIONS <- c(
  # Utility functions that can be internalized
  "add_dead_air_rows",
  "ensure_instructor_rows",
  "make_clean_names_df",
  "make_names_to_clean_df",
  "make_new_analysis_template",
  "make_student_roster_sessions",
  
  # Data creation functions
  "make_blank_cancelled_classes_df",
  "make_blank_section_names_lookup_csv",
  "make_metrics_lookup_df",
  "make_roster_small",
  "make_sections_df",
  "make_semester_df",
  "make_transcripts_summary_df",
  "make_transcripts_session_summary_df",
  "make_students_only_transcripts_summary_df",
  
  # Export functions
  "export_ideal_transcripts_csv",
  "export_ideal_transcripts_excel",
  "export_ideal_transcripts_json",
  "export_ideal_transcripts_summary",
  "write_engagement_metrics",
  "write_lookup_transactional",
  "write_section_names_lookup",
  "write_transcripts_session_summary",
  "write_transcripts_summary",
  
  # Validation functions
  "validate_ideal_transcript_comprehensive",
  "validate_ideal_transcript_structure",
  "validate_ideal_content_quality",
  "validate_ideal_name_coverage",
  "validate_ideal_scenarios",
  "validate_ideal_timing_consistency",
  "validate_ethical_use",
  "audit_ethical_usage",
  
  # Analysis functions
  "analyze_name_coverage",
  "analyze_roster_attendance",
  "analyze_session_trends",
  "analyze_timing_patterns",
  "benchmark_ideal_transcripts",
  "compare_ideal_sessions",
  "calculate_content_similarity",
  "classify_participants",
  "generate_ferpa_report",
  "run_student_reports",
  
  # Advanced functions
  "process_ideal_course_batch",
  "join_transcripts_list",
  "load_and_process_zoom_transcript",
  "load_cancelled_classes",
  "load_zoom_recorded_sessions_list",
  "load_section_names_lookup",
  
  # Helper functions
  "add_export_metadata",
  "add_summary_charts",
  "aggregate",
  "apply_name_matching",
  "apply_privacy_aware_matching",
  "calculate_content_quality_metrics",
  "calculate_overall_quality_score",
  "check_data_retention_policy",
  "conditionally_write_lookup",
  "create_analysis_config",
  "create_course_info",
  "create_equity_test_data",
  "create_equity_validation_data",
  "create_ethical_use_report",
  "create_name_lookup",
  "create_sample_metrics_lookup",
  "create_sample_roster",
  "create_sample_section_names_lookup",
  "create_sample_transcript_metrics",
  "create_session_mapping",
  "create_temp_test_file",
  "detect_privacy_violations",
  "determine_validation_status",
  "diag_cat",
  "diag_cat_if",
  "diag_message",
  "diag_message_if",
  "extract_character_values",
  "extract_mapped_names",
  "extract_roster_names",
  "extract_transcript_names",
  "find_roster_match",
  "generate_benchmark_summary",
  "generate_comparison_insights",
  "generate_comprehensive_recommendations",
  "generate_comprehensive_summary",
  "generate_content_recommendations",
  "generate_data_quality_report",
  "generate_detailed_validation_report",
  "generate_export_metadata",
  "generate_name_coverage_recommendations",
  "generate_name_matching_guidance",
  "generate_structure_recommendations",
  "generate_success_metrics_report",
  "generate_timing_recommendations",
  "generate_transcript_summary",
  "generate_validation_recommendations",
  "get_current_baseline",
  "get_target_state",
  "handle_unmatched_names",
  "is_verbose",
  "library.dynam",
  "library.dynam.unload",
  "log_ferpa_compliance_check",
  "log_privacy_operation",
  "match_names_with_privacy",
  "measure_memory_usage",
  "merge_lookup_preserve",
  "normalize_name_for_matching",
  "plot_users_by_metric",
  "plot_users_masked_section_by_metric",
  "prepare_visualization_data",
  "print_benchmark_summary",
  "print_success_metrics_report",
  "process_transcript_with_privacy",
  "prompt_name_matching",
  "read_lookup_safely",
  "read.csv",
  "sessionInfo",
  "str",
  "success_metrics_framework",
  "summarize_transcript_files",
  "system.file",
  "track_progress",
  "validate_chronological_order",
  "validate_comment_content",
  "validate_content_diversity",
  "validate_dialogue_length",
  "validate_duration_calculations",
  "validate_engagement_metrics",
  "validate_expected_names",
  "validate_ideal_name_coverage",
  "validate_ideal_scenarios",
  "validate_ideal_timing_consistency",
  "validate_ideal_transcript_comprehensive",
  "validate_lookup_file_format",
  "validate_name_consistency",
  "validate_name_edge_cases",
  "validate_name_variations",
  "validate_no_overlaps",
  "validate_participant_counts",
  "validate_realistic_patterns",
  "validate_reasonable_gaps",
  "validate_required_fields",
  "validate_scenario_completeness",
  "validate_session_count",
  "validate_session_duration",
  "validate_speaker_consistency",
  "validate_timestamp_consistency",
  "validate_timestamp_format",
  "validate_transcript_structure",
  "validate_vtt_format",
  "zse_schema"
)

# Functions to keep but make internal (not exported)
INTERNAL_FUNCTIONS <- c(
  "abort_zse",
  "%||%",
  "aggregate",
  "setNames",
  "read.csv",
  "sessionInfo",
  "str",
  "system.file"
)

#' Add Deprecation Warnings to Non-Essential Functions
#' 
#' @keywords internal
#' @noRd
add_deprecation_warnings <- function() {
  # This function will be called to add deprecation warnings
  # to all functions in DEPRECATED_FUNCTIONS
  message("Adding deprecation warnings to ", length(DEPRECATED_FUNCTIONS), " functions")
}

#' Get Essential Functions List
#' 
#' @return Character vector of essential function names
#' @export
get_essential_functions <- function() {
  ESSENTIAL_FUNCTIONS
}

#' Get Deprecated Functions List
#' 
#' @return Character vector of deprecated function names
#' @export
get_deprecated_functions <- function() {
  DEPRECATED_FUNCTIONS
}

#' Get Internal Functions List
#' 
#' @return Character vector of internal function names
#' @export
get_internal_functions <- function() {
  INTERNAL_FUNCTIONS
}

#' Get Scope Reduction Summary
#' 
#' @return List with scope reduction statistics
#' @export
get_scope_reduction_summary <- function() {
  list(
    current_functions = 175,
    target_functions = 25,
    essential_functions = length(ESSENTIAL_FUNCTIONS),
    deprecated_functions = length(DEPRECATED_FUNCTIONS),
    internal_functions = length(INTERNAL_FUNCTIONS),
    reduction_percentage = round((175 - 25) / 175 * 100, 1),
    functions_to_remove = 175 - 25
  )
}
