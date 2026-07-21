#' User Guidance and Help System
#'
#' @description Provides contextual help and guidance for users to navigate
#'   the package effectively and find the right functions for their tasks.

#' Show getting started guide
#'
#' @description Displays a comprehensive getting started guide for new users
#' @return Invisibly `NULL`; called for its formatted console guide.
#' @export
#' @examples
#' show_getting_started()
show_getting_started <- function() {
  cat("
Getting Started with engager
============================

BASIC WORKFLOW (5 steps):
1. load_zoom_transcript() - Load your transcript file
2. process_zoom_transcript() - Clean and prepare data
3. analyze_transcripts() - Calculate engagement metrics
4. plot_users() - Create charts and graphs
5. write_metrics(..., path = 'your/output.csv') - Save to an explicit path

QUICK START (Recommended for new users):
   results <- basic_transcript_analysis('your_file.vtt')
   # To export, supply output_dir = 'your/output/directory'

STEP-BY-STEP WORKFLOW:
   transcript <- load_zoom_transcript('your_file.vtt')
   processed <- process_zoom_transcript(transcript_df = transcript)
   analysis <- summarize_transcript_metrics(transcript_df = processed)
   plots <- plot_users(analysis, metric = 'wordcount', facet_by = 'transcript_file')
   write_metrics(analysis, path = 'output/engagement_metrics.csv')

BATCH PROCESSING:
   files <- c('session1.vtt', 'session2.vtt')
   results <- batch_basic_analysis(files, 'output/')

NEED HELP?
   - show_available_functions() - See functions at your level
   - show_function_help('function_name') - Get help for specific function
   - find_function_for_task('what you want to do') - Find the right function
   - set_ux_level('intermediate') - Show more functions

PRIVACY & ETHICS:
   - Privacy protection is enabled by default
   - Use ensure_privacy() to protect sensitive data
   - See review_privacy_risks() for privacy review

MORE RESOURCES:
   - vignette('getting-started') - Detailed tutorial
   - utils::help(package = 'engager') - All documentation
")
}

#' Show help for specific function
#'
#' @param function_name Name of function to get help for
#' @return Invisibly `NULL`; called for its formatted console help.
#' @export
#' @examples
#' show_function_help("load_zoom_transcript")
#' show_function_help("basic_transcript_analysis")
show_function_help <- function(function_name) {
  # Check if function exists
  if (!exists(function_name, envir = asNamespace("engager"))) {
    cat("ERROR: Function '", function_name, "' not found\n")
    cat("TIP: Try: show_available_functions() to see available functions\n")
    cat("TIP: Or: find_function_for_task('what you want to do')\n")
    return(invisible())
  }

  # Determine function category
  if (function_name %in% UX_ESSENTIAL_FUNCTIONS) {
    cat("Essential Function: ", function_name, "\n")
    cat(paste(rep("=", nchar(function_name) + 20), collapse = ""), "\n")
  } else if (function_name %in% UX_COMMON_FUNCTIONS) {
    cat("RESULTS: Common Function: ", function_name, "\n")
    cat(paste(rep("=", nchar(function_name) + 18), collapse = ""), "\n")
  } else if (function_name %in% UX_ADVANCED_FUNCTIONS) {
    cat("Advanced Function: ", function_name, "\n")
    cat(paste(rep("=", nchar(function_name) + 20), collapse = ""), "\n")
  } else if (function_name %in% UX_EXPERT_FUNCTIONS) {
    cat("TOOLS: Expert Function: ", function_name, "\n")
    cat(paste(rep("=", nchar(function_name) + 18), collapse = ""), "\n")
  } else {
    cat("Function: ", function_name, "\n")
    cat(paste(rep("=", nchar(function_name) + 12), collapse = ""), "\n")
  }

  # Show function description if available
  desc <- UX_FUNCTION_DESCRIPTIONS[[function_name]]
  if (!is.null(desc)) {
    cat("Description: ", desc, "\n\n")
  }

  # Show function documentation
  cat("DOCS: Documentation:\n")
  documentation <- tryCatch(
    utils::help(function_name, package = "engager"),
    error = function(e) NULL
  )
  if (length(documentation) == 0) {
    cat("   No documentation available\n")
  } else {
    print(documentation)
  }

  # Show usage examples for common functions
  if (function_name %in% c("basic_transcript_analysis", "quick_analysis", "batch_basic_analysis")) {
    cat("\nTIP: Usage Examples:\n")
    switch(function_name,
      "basic_transcript_analysis" = {
        cat("   results <- basic_transcript_analysis('transcript.vtt')\n")
        cat("   results <- basic_transcript_analysis('transcript.vtt', 'output/', 'medium')\n")
      },
      "quick_analysis" = {
        cat("   results <- quick_analysis('transcript.vtt')\n")
      },
      "batch_basic_analysis" = {
        cat("   files <- c('session1.vtt', 'session2.vtt')\n")
        cat("   results <- batch_basic_analysis(files, 'output/')\n")
      }
    )
  }
}

#' Show workflow help and templates
#'
#' @return Invisibly `NULL`; called for its formatted console guide.
#' @export
#' @examples
#' show_workflow_help()
show_workflow_help <- function() {
  cat("
Available Workflows
=====================

Basic Workflow (Recommended for new users):
   results <- basic_transcript_analysis('file.vtt')
   # Supply output_dir explicitly when files should be written.

QUICK: Quick Workflow (Fastest):
   results <- quick_analysis('file.vtt')

RESULTS: Step-by-Step Workflow (Full control):
   1. transcript <- load_zoom_transcript('file.vtt')
   2. processed <- process_zoom_transcript(transcript_df = transcript)
   3. analysis <- summarize_transcript_metrics(transcript_df = processed)
   4. plots <- plot_users(analysis, metric = 'wordcount', facet_by = 'transcript_file')
   5. write_metrics(analysis, path = 'output/engagement_metrics.csv')

Batch Workflow (Multiple files):
   files <- c('session1.vtt', 'session2.vtt', 'session3.vtt')
   results <- batch_basic_analysis(files)
   # Supply output_dir explicitly when files should be written.

Advanced Workflows:
   - Use set_ux_level('intermediate') to see more options
   - Use set_ux_level('advanced') for specialized functions
   - Use set_ux_level('expert') for all functions

TIP: Need help finding the right workflow?
   find_function_for_task('what you want to do')
")
}

#' Show privacy and ethics guidance
#'
#' @return Invisibly `NULL`; called for its formatted console guide.
#' @export
#' @examples
#' show_privacy_guidance()
show_privacy_guidance <- function() {
  cat("
Privacy & Ethics Guidance
===========================

Privacy Protection (Enabled by Default):
   - Common structured identifier fields are masked by default
   - Free transcript text still requires local review before sharing
   - Technical privacy review helpers are included

TOOLS: Privacy Functions:
   - ensure_privacy() - Apply privacy protection
   - write_metrics(data, path = 'your/output.csv') - Export masked metrics without raw comments by default
   - privacy_audit() - Check privacy risks
   - review_privacy_risks() - privacy review

Ethical Use Guidelines:
   - Focus on participation equity, not surveillance
   - Use data to improve learning, not punish students
   - Respect student privacy and consent
   - Follow institutional policies

Best Practices:
   - Always use privacy protection for real data
   - Review privacy settings before analysis
   - Document your analysis purpose
   - Follow institutional data policies

Privacy Questions?
   - show_function_help('ensure_privacy')
   - show_function_help('review_privacy_risks')
   - vignette('privacy-ethics-review')
")
}

#' Show troubleshooting guide
#'
#' @return Invisibly `NULL`; called for its formatted console guide.
#' @export
#' @examples
#' show_troubleshooting()
show_troubleshooting <- function() {
  cat("
TOOLS: Troubleshooting Guide
========================

ERROR: Common Issues and Solutions:

File Not Found:
   - Check file path is correct
   - Use list.files() to see available files
   - Check the function documentation for the expected file extension

Permission Denied:
   - Check file permissions
   - Try a different output directory
   - Contact system administrator if needed

Function Not Found:
   - Use show_available_functions() to see available functions
   - Try set_ux_level('intermediate') for more functions
   - Use find_function_for_task('what you want to do')

RESULTS: Analysis Errors:
   - Check transcript file format
   - Use show_function_help('load_zoom_transcript') to review input requirements
   - Try with a smaller file first

Memory Issues:
   - Use smaller files for testing
   - Try batch processing for large datasets
   - Check available system memory

TIP: Getting More Help:
   - show_getting_started() - Basic guide
   - show_function_help('function_name') - Specific help
   - find_function_for_task('task') - Find right function
   - vignette('privacy-ethics-review') - Privacy review guide
")
}
