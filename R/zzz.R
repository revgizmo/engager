.onAttach <- function(libname, pkgname) {
  # Check if user wants to suppress startup message
  show_startup <- getOption("engager.show_startup", TRUE)

  if (show_startup) {
    packageStartupMessage(
      "Welcome to engager!\n",
      "- Start with: vignette('getting-started', package='engager')\n",
      "- Core functions: vignette('essential-functions', package='engager')\n",
      "- Sample data: system.file('extdata/transcripts', package='engager')\n",
      "- Quick example: example(summarize_transcript_metrics)\n",
      "\n",
      "To suppress this message: options(engager.show_startup = FALSE)"
    )
  }
}
