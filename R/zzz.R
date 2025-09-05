#' Package startup message
#'
#' @description Shows helpful startup message for new users
#' @keywords internal
#' @noRd

# Declare global variables to avoid lintr warnings
utils::globalVariables(c(
  "UX_ESSENTIAL_FUNCTIONS", "UX_COMMON_FUNCTIONS", "UX_ADVANCED_FUNCTIONS", 
  "UX_EXPERT_FUNCTIONS", "UX_FUNCTION_DESCRIPTIONS"
))

# Make UX function categories available globally
UX_ESSENTIAL_FUNCTIONS <- c(
  "load_zoom_transcript",
  "process_zoom_transcript", 
  "analyze_transcripts",
  "plot_users",
  "write_metrics"
)

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

UX_ADVANCED_FUNCTIONS <- c(
  "batch_process_transcripts",
  "custom_engagement_analysis",
  "advanced_visualization_options",
  "performance_optimization",
  "custom_metrics_calculation"
)

UX_EXPERT_FUNCTIONS <- c(
  "internal_data_processing",
  "low_level_utilities",
  "development_tools"
)

UX_FUNCTION_DESCRIPTIONS <- list(
  "load_zoom_transcript" = "Load Zoom transcript files",
  "process_zoom_transcript" = "Process and clean transcript data",
  "analyze_transcripts" = "Analyze engagement metrics",
  "plot_users" = "Create visualizations",
  "write_metrics" = "Export results"
)

.onAttach <- function(libname, pkgname) {
  # Get current UX level
  ux_level <- getOption("zoomstudentengagement.ux_level", "basic")

  # Create startup message
  packageStartupMessage(
    "🎯 Welcome to zoomstudentengagement!\n",
    "📊 Ready to analyze student engagement from Zoom transcripts\n\n",
    "🚀 Quick Start:\n",
    "   results <- basic_transcript_analysis('your_file.vtt')\n\n",
    "❓ Need Help?\n",
    "   • show_getting_started() - Complete guide\n",
    "   • show_available_functions() - See available functions\n",
    "   • find_function_for_task('what you want to do') - Find functions\n\n",
    "🔒 Privacy protection is enabled by default\n",
    "💡 Use set_ux_level('intermediate') to see more functions\n"
  )
}
