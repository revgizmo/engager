# UX System Global Variables
UX_ESSENTIAL_FUNCTIONS <- c(
  "basic_transcript_analysis",
  "quick_analysis",
  "batch_basic_analysis",
  "show_getting_started",
  "show_available_functions",
  "find_function_for_task"
)

UX_COMMON_FUNCTIONS <- c(
  "load_zoom_transcript",
  "process_zoom_transcript",
  "analyze_transcripts",
  "plot_users",
  "write_metrics",
  "ensure_privacy",
  "show_function_help"
)

UX_ADVANCED_FUNCTIONS <- c(
  "consolidate_transcript",
  "summarize_transcript_metrics",
  "summarize_transcript_files",
  "detect_unmatched_names",
  "match_names_workflow",
  "review_privacy_risks"
)

UX_EXPERT_FUNCTIONS <- c(
  "anonymize_educational_data",
  "validate_privacy_compliance",
  "analyze_multi_session_attendance",
  "generate_attendance_report",
  "generate_privacy_review_report"
)

# Declare globals to silence NSE notes in CRAN checks
utils::globalVariables(c(
  "aliases", "name_hash", "collision", "reason", "guidance"
))

# UX Function Descriptions
UX_FUNCTION_DESCRIPTIONS <- list(
  "basic_transcript_analysis" = "Complete analysis workflow for new users",
  "quick_analysis" = "Fast analysis for single transcripts",
  "batch_basic_analysis" = "Process multiple transcripts at once",
  "show_getting_started" = "Display getting started guide",
  "show_available_functions" = "Show functions at your skill level",
  "find_function_for_task" = "Find the right function for your task",
  "load_zoom_transcript" = "Load transcript from file",
  "process_zoom_transcript" = "Clean and prepare transcript data",
  "analyze_transcripts" = "Calculate engagement metrics",
  "plot_users" = "Create visualizations",
  "write_metrics" = "Save results to file",
  "ensure_privacy" = "Protect sensitive data",
  "show_function_help" = "Get help for specific function",
  "consolidate_transcript" = "Combine transcript data",
  "summarize_transcript_metrics" = "Calculate summary statistics",
  "summarize_transcript_files" = "Summarize multiple transcript files",
  "detect_unmatched_names" = "Find transcript speakers that need roster review",
  "review_privacy_risks" = "Run a technical privacy review",
  "anonymize_educational_data" = "Anonymize sensitive data",
  "validate_privacy_compliance" = "Run technical identifier checks",
  "match_names_workflow" = "Safe name matching process",
  "analyze_multi_session_attendance" = "Analyze attendance across sessions",
  "generate_attendance_report" = "Generate an attendance summary",
  "generate_privacy_review_report" = "Generate a technical privacy review report"
)

.onAttach <- function(libname, pkgname) {
  # Check if user wants to suppress startup message
  show_startup <- getOption("engager.show_startup", TRUE)

  if (show_startup) {
    packageStartupMessage(
      "Welcome to engager!\n",
      "- Start with: vignette('getting-started', package='engager')\n",
      "- Core functions: vignette('essential-functions', package='engager')\n",
      "- Sample data: system.file('extdata/test_transcripts', package='engager')\n",
      "- Quick example: example(summarize_transcript_metrics)\n",
      "\n",
      "To suppress this message: options(engager.show_startup = FALSE)"
    )
  }
}
