.onAttach <- function(libname, pkgname) {
  # Check if user wants to suppress startup message
  show_startup <- getOption("zoomstudentengagement.show_startup", TRUE)
  
  if (show_startup) {
    packageStartupMessage(
      "Welcome to zoomstudentengagement!\n",
      "- Start with: vignette('getting-started', package='zoomstudentengagement')\n",
      "- Core functions: vignette('essential-functions', package='zoomstudentengagement')\n",
      "- Sample data: system.file('extdata/transcripts', package='zoomstudentengagement')\n",
      "- Quick example: example(summarize_transcript_metrics)\n",
      "\n",
      "To suppress this message: options(zoomstudentengagement.show_startup = FALSE)"
    )
  }
}