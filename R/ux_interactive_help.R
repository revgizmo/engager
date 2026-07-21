#' Interactive Help System
#'
#' @description Provides interactive help and function discovery to help users
#'   find the right functions for their specific tasks.

#' Interactive function discovery
#'
#' @description Helps users find the right function based on what they want to do
#'
#' @param task Description of what user wants to do
#' @return Invisibly `NULL`; called for its function suggestions printed to the console.
#' @export
#' @examples
#' find_function_for_task("load transcript file")
#' find_function_for_task("create visualizations")
#' find_function_for_task("export results")
find_function_for_task <- function(task) {
  if (missing(task) || is.null(task) || task == "") {
    cat("What would you like to do? Please describe your task.\n")
    cat("TIP: Examples:\n")
    cat("   - find_function_for_task('load transcript file')\n")
    cat("   - find_function_for_task('create visualizations')\n")
    cat("   - find_function_for_task('export results')\n")
    return(invisible())
  }

  # Simple keyword matching for function discovery
  task_lower <- tolower(task)

  cat("Looking for functions to: ", task, "\n")
  cat(paste(rep("=", nchar(task) + 30), collapse = ""), "\n\n")

  # Load transcript functions
  if (grepl("load|read|import|open", task_lower)) {
    cat("Loading Transcript Files:\n")
    cat("   - load_zoom_transcript() - Load individual transcript files\n")
    cat("   - load_roster() - Load student roster information\n")
    cat("   - summarize_transcript_files() - Load and summarize multiple transcripts\n\n")
  }

  # Process transcript functions
  if (grepl("process|clean|prepare|organize", task_lower)) {
    cat("Processing Transcript Data:\n")
    cat("   - process_zoom_transcript() - Clean and prepare transcript data\n")
    cat("   - consolidate_transcript() - Combine multiple transcript files\n")
    cat("   - summarize_transcript_metrics() - Summarize processed transcript data\n")
    cat("   - match_names_workflow() - Match transcript speakers to roster data\n\n")
  }

  # Analyze functions
  if (grepl("analyze|calculate|metrics|engagement|measure", task_lower)) {
    cat("RESULTS: Analyzing Engagement:\n")
    cat("   - analyze_transcripts() - Calculate engagement metrics\n")
    cat("   - summarize_transcript_metrics() - Generate summary statistics\n\n")
  }

  # Visualize functions
  if (grepl("visualize|plot|chart|graph|display|show", task_lower)) {
    cat("Creating Visualizations:\n")
    cat("   - plot_users() - Create engagement visualizations\n\n")
  }

  # Export functions
  if (grepl("export|save|output|write|download", task_lower)) {
    cat("Exporting Results:\n")
    cat("   - write_metrics(data, path = 'your/output.csv') - Export privacy-processed metrics to CSV\n")
    cat("   - write_unresolved() - Export unresolved-name review data\n")
    cat("   - generate_privacy_review_report() - Write a privacy review report\n\n")
  }

  # Privacy functions
  if (grepl("privacy|protect|anonymize|mask|secure", task_lower)) {
    cat("Privacy Protection:\n")
    cat("   - ensure_privacy() - Apply privacy protection to data\n")
    cat("   - write_metrics(data, path = 'your/output.csv') - Export masked metrics without raw comments by default\n")
    cat("   - privacy_audit() - Check privacy risks\n")
    cat("   - anonymize_educational_data() - Transform recognized identifier columns\n")
    cat("   - review_privacy_risks() - Run a technical privacy review\n\n")
  }

  # Batch processing
  if (grepl("batch|multiple|several|all", task_lower)) {
    cat("Batch Processing:\n")
    cat("   - batch_basic_analysis() - Process multiple transcript files\n")
    cat("   - summarize_transcript_files() - Summarize multiple transcripts\n\n")
  }

  # Validation functions
  if (grepl("validate|check|verify|test", task_lower)) {
    cat("SUCCESS: Validation & Quality:\n")
    cat("   - validate_privacy_compliance() - Run technical identifier checks\n")
    cat("   - review_privacy_risks() - Run a technical privacy review\n\n")
  }

  # If no specific matches, show general guidance
  if (!any(grepl("load|read|import|open|process|clean|prepare|organize|analyze|calculate|metrics|engagement|measure|visualize|plot|chart|graph|display|show|export|save|output|write|download|privacy|protect|anonymize|mask|secure|batch|multiple|several|all|validate|check|verify|test", task_lower))) {
    cat("TIP: General Guidance:\n")
    cat("   - For complete analysis: basic_transcript_analysis()\n")
    cat("   - For quick results: quick_analysis()\n")
    cat("   - For multiple files: batch_basic_analysis()\n")
    cat("   - For step-by-step: show_getting_started()\n\n")
  }

  cat("TARGET: Recommended Next Steps:\n")
  cat("   - show_function_help('function_name') - Get detailed help\n")
  cat("   - show_available_functions() - See all available functions\n")
  cat("   - set_ux_level('intermediate') - Show more functions\n")
  cat("   - show_getting_started() - Complete getting started guide\n")
}

#' Show function categories and counts
#'
#' @return Invisibly `NULL`; called for its category summary printed to the console.
#' @export
#' @examples
#' show_function_categories()
show_function_categories <- function() {
  cat("RESULTS: Function Categories Overview\n")
  cat(paste(rep("=", 35), collapse = ""), "\n\n")

  cat("Essential Functions (", length(UX_ESSENTIAL_FUNCTIONS), "):\n")
  cat("   Core workflow functions for basic analysis\n")
  cat("   Always visible to all users\n\n")

  cat("RESULTS: Common Functions (", length(UX_COMMON_FUNCTIONS), "):\n")
  cat("   Frequently used functions for common tasks\n")
  cat("   Visible with help system\n\n")

  cat("Advanced Functions (", length(UX_ADVANCED_FUNCTIONS), "):\n")
  cat("   Specialized functions for advanced analysis\n")
  cat("   Hidden by default, accessible via help\n\n")

  cat("TOOLS: Expert Functions (", length(UX_EXPERT_FUNCTIONS), "):\n")
  cat("   Internal/utility functions for development\n")
  cat("   Hidden from basic users\n\n")

  cat(
    "Total Functions: ",
    length(UX_ESSENTIAL_FUNCTIONS) + length(UX_COMMON_FUNCTIONS) +
      length(UX_ADVANCED_FUNCTIONS) + length(UX_EXPERT_FUNCTIONS), "\n\n"
  )

  cat("TIP: To see functions in each category:\n")
  cat("   - show_available_functions('basic') - Essential only\n")
  cat("   - show_available_functions('intermediate') - Essential + Common\n")
  cat("   - show_available_functions('advanced') - Essential + Common + Advanced\n")
  cat("   - show_available_functions('expert') - All functions\n")
}

#' Smart function recommendations
#'
#' @description Provides intelligent function recommendations based on user context
#'
#' @param context User's current context or situation
#' @return Invisibly `NULL`; called for its recommendations printed to the console.
#' @export
#' @examples
#' get_smart_recommendations("new user")
#' get_smart_recommendations("batch processing")
#' get_smart_recommendations("privacy concerns")
get_smart_recommendations <- function(context) {
  if (missing(context) || is.null(context) || context == "") {
    cat("What's your situation? Please describe your context.\n")
    cat("TIP: Examples:\n")
    cat("   - get_smart_recommendations('new user')\n")
    cat("   - get_smart_recommendations('batch processing')\n")
    cat("   - get_smart_recommendations('privacy concerns')\n")
    return(invisible())
  }

  context_lower <- tolower(context)

  cat("TARGET: Smart Recommendations for: ", context, "\n")
  cat(paste(rep("=", nchar(context) + 35), collapse = ""), "\n\n")

  if (grepl("new|beginner|first time|start", context_lower)) {
    cat("Perfect for New Users:\n")
    cat("   1. basic_transcript_analysis('your_file.vtt') - Complete workflow\n")
    cat("   2. show_getting_started() - Step-by-step guide\n")
    cat("   3. show_available_functions() - See what's available\n")
    cat("   4. quick_analysis('your_file.vtt') - Fast results\n\n")
  }

  if (grepl("batch|multiple|several|many", context_lower)) {
    cat("Batch Processing Solutions:\n")
    cat("   1. batch_basic_analysis(files, 'output/') - Process multiple files\n")
    cat("   2. summarize_transcript_files() - Summarize multiple transcripts\n\n")
  }

  if (grepl("privacy|secure|protect|anonymize|ferpa", context_lower)) {
    cat("Privacy & Security Focus:\n")
    cat("   1. ensure_privacy() - Apply privacy protection\n")
    cat("   2. ensure_privacy(data, privacy_level = 'privacy_strict') - Broader masking\n")
    cat("   3. privacy_audit() - Check privacy risks\n")
    cat("   4. review_privacy_risks() - privacy review\n")
    cat("   5. show_privacy_guidance() - Privacy best practices\n\n")
  }

  if (grepl("visual|chart|graph|plot|display", context_lower)) {
    cat("Visualization Solutions:\n")
    cat("   1. plot_users() - Create engagement charts\n\n")
  }

  if (grepl("export|save|output|download|share", context_lower)) {
    cat("Export & Sharing:\n")
    cat("   1. write_metrics(data, path = 'your/output.csv') - Export privacy-processed metrics to CSV\n")
    cat("   2. write_unresolved() - Unresolved-name review CSV\n")
    cat("   3. generate_privacy_review_report() - Privacy review report\n\n")
  }

  if (grepl("error|problem|issue|trouble|help", context_lower)) {
    cat("TOOLS: Troubleshooting Help:\n")
    cat("   1. show_troubleshooting() - Common issues and solutions\n")
    cat("   2. show_function_help('function_name') - Specific help\n")
    cat("   3. find_function_for_task('what you want to do') - Find functions\n")
    cat("   4. show_getting_started() - Basic guidance\n\n")
  }

  cat("TIP: Next Steps:\n")
  cat("   - Try the recommended functions above\n")
  cat("   - Use show_function_help('function_name') for detailed help\n")
  cat("   - Use set_ux_level('intermediate') to see more options\n")
}
