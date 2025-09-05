#' Package startup message
#' 
#' @description Shows helpful startup message for new users
#' @keywords internal
#' @noRd

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