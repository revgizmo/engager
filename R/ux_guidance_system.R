#' User Guidance and Help System
#'
#' @description Provides contextual help and guidance for users to navigate
#'   the package effectively and find the right functions for their tasks.

#' Show getting started guide
#'
#' @description Displays a comprehensive getting started guide for new users
#' @export
#' @examples
#' \dontrun{
#' show_getting_started()
#' }
show_getting_started <- function() {
  cat("
Getting Started with zoomstudentengagement
============================================

BASIC WORKFLOW (5 steps):
1. load_zoom_transcript() - Load your transcript file
2. process_zoom_transcript() - Clean and prepare data
3. analyze_transcripts() - Calculate engagement metrics
4. plot_users() - Create charts and graphs
5. write_metrics() - Save your results

QUICK START (Recommended for new users):
   results <- basic_transcript_analysis('your_file.vtt')

STEP-BY-STEP WORKFLOW:
   transcript <- load_zoom_transcript('your_file.vtt')
   processed <- process_zoom_transcript(transcript)
   analysis <- analyze_transcripts(processed)
   plots <- plot_users(analysis)
   write_metrics(analysis, 'output/')

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
   - See validate_ferpa_compliance() for compliance checking

MORE RESOURCES:
   - vignette('getting-started') - Detailed tutorial
   - utils::help(package = 'zoomstudentengagement') - All documentation
")
}

#' Show help for specific function
#'
#' @param function_name Name of function to get help for
#' @export
#' @examples
#' \dontrun{
#' show_function_help("load_zoom_transcript")
#' show_function_help("basic_transcript_analysis")
#' }
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
  tryCatch(
    {
      utils::help(function_name, package = "zoomstudentengagement")
    },
    error = function(e) {
      cat("   No documentation available\n")
    }
  )

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
#' @export
#' @examples
#' \dontrun{
#' show_workflow_help()
#' }
show_workflow_help <- function() {
  cat("
Available Workflows
=====================

Basic Workflow (Recommended for new users):
   results <- basic_transcript_analysis('file.vtt', 'output/')

QUICK: Quick Workflow (Fastest):
   results <- quick_analysis('file.vtt')

RESULTS: Step-by-Step Workflow (Full control):
   1. transcript <- load_zoom_transcript('file.vtt')
   2. processed <- process_zoom_transcript(transcript)
   3. analysis <- analyze_transcripts(processed)
   4. plots <- plot_users(analysis)
   5. write_metrics(analysis, 'output/')

Batch Workflow (Multiple files):
   files <- c('session1.vtt', 'session2.vtt', 'session3.vtt')
   results <- batch_basic_analysis(files, 'output/')

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
#' @export
#' @examples
#' \dontrun{
#' show_privacy_guidance()
#' }
show_privacy_guidance <- function() {
  cat("
Privacy & Ethics Guidance
===========================

Privacy Protection (Enabled by Default):
   - Student names are automatically protected
   - Sensitive data is anonymized
   - FERPA compliance features included

TOOLS: Privacy Functions:
   - ensure_privacy() - Apply privacy protection
   - set_privacy_defaults() - Configure privacy settings
   - privacy_audit() - Check privacy compliance
   - validate_ferpa_compliance() - FERPA compliance check

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
   - show_function_help('validate_ferpa_compliance')
   - vignette('privacy-and-ethics')
")
}

#' Show troubleshooting guide
#'
#' @export
#' @examples
#' \dontrun{
#' show_troubleshooting()
#' }
show_troubleshooting <- function() {
  cat("
TOOLS: Troubleshooting Guide
========================

ERROR: Common Issues and Solutions:

File Not Found:
   - Check file path is correct
   - Use list.files() to see available files
   - Ensure file has .vtt, .txt, or .csv extension

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
   - Use validate_schema() to check data structure
   - Try with a smaller file first

Memory Issues:
   - Use smaller files for testing
   - Try batch processing for large datasets
   - Check available system memory

TIP: Getting More Help:
   - show_getting_started() - Basic guide
   - show_function_help('function_name') - Specific help
   - find_function_for_task('task') - Find right function
   - vignette('troubleshooting') - Detailed guide
")
}
