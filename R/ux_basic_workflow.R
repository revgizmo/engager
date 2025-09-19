#' Basic Analysis Workflow for New Users
#'
#' @description Simplified workflow that guides new users through basic analysis
#'   of Zoom transcripts with minimal complexity.

#' Complete basic transcript analysis workflow
#'
#' @description This is the main function for new users. It performs a complete
#'   analysis workflow in 5 simple steps: load, process, analyze, visualize, and export.
#'
#' @param transcript_file Path to transcript file (VTT, TXT, or CSV format)
#' @param output_dir Output directory for results (default: "output")
#' @param privacy_level Privacy protection level: "high" (default), "medium", "low"
#' @return List containing analysis results, plots, and output directory path
#' @export
#' @examples
#' \dontrun{
#' # Basic workflow for new users
#' results <- basic_transcript_analysis("transcript.vtt", "output/")
#'
#' # With custom privacy level
#' results <- basic_transcript_analysis("transcript.vtt", "output/", "medium")
#' }
basic_transcript_analysis <- function(transcript_file, output_dir = "output", privacy_level = "high") {
  # Validate inputs
  if (!file.exists(transcript_file)) {
    stop(
      "ERROR: File not found: ", transcript_file, "\n",
      "TIP: Please check the file path and try again"
    )
  }

  if (!dir.exists(output_dir)) {
    message("Creating output directory: ", output_dir)
    dir.create(output_dir, recursive = TRUE)
  }

  # Set privacy defaults
  set_privacy_defaults()

  # TARGET: Starting Basic Transcript Analysis
  message("==> Starting Basic Transcript Analysis")
  message(paste(rep("=", 40), collapse = ""))
  message("FILE: File: ", basename(transcript_file))
  message("DIR: Output: ", output_dir)
  message("PRIVACY: Privacy: ", privacy_level)
  message("")

  tryCatch(
    {
      # Step 1: Load transcript
      message("Step 1/5: Loading transcript...")
      transcript <- load_zoom_transcript(transcript_file)
      message("SUCCESS: Loaded ", nrow(transcript), " transcript entries")

      # Step 2: Process transcript
      message("Step 2/5: Processing transcript...")
      processed <- process_zoom_transcript(transcript)
      message("SUCCESS: Processed transcript data")

      # Step 3: Analyze engagement
      message("Step 3/5: Analyzing engagement...")
      analysis <- analyze_transcripts(processed)
      message("SUCCESS: Calculated engagement metrics")

      # Step 4: Create visualizations
      message("Step 4/5: Creating visualizations...")
      plots <- plot_users(analysis)
      message("SUCCESS: Created engagement visualizations")

      # Step 5: Export results
      message("Step 5/5: Exporting results...")
      write_metrics(analysis, output_dir)
      message("SUCCESS: Exported results to ", output_dir)

      message("")
      message("COMPLETE: Basic analysis complete!")
      message("RESULTS: Results saved to: ", output_dir)
      message("TIP: Next steps:")
      message("   - Check the output files in ", output_dir)
      message("   - Use show_available_functions() to see more options")
      message("   - Use set_ux_level('intermediate') for more functions")

      return(list(
        analysis = analysis,
        plots = plots,
        output_dir = output_dir,
        transcript_file = transcript_file,
        privacy_level = privacy_level
      ))
    },
    error = function(e) {
      message("ERROR: Analysis failed: ", e$message)
      message("TIP: Try: show_getting_started() for help")
      message("TIP: Or: show_function_help('basic_transcript_analysis')")
      stop(e)
    }
  )
}

#' Quick analysis for single transcript file
#'
#' @description Simplified version for users who just want quick results
#'
#' @param transcript_file Path to transcript file
#' @return Analysis results
#' @export
#' @examples
#' \dontrun{
#' # Quick analysis
#' results <- quick_analysis("transcript.vtt")
#' }
quick_analysis <- function(transcript_file) {
  message("QUICK: Quick Analysis Mode")
  message(paste(rep("=", 25), collapse = ""))

  # Use basic workflow with default settings
  results <- basic_transcript_analysis(transcript_file, "quick_output")

  message("SUCCESS: Quick analysis complete!")
  message("DIR: Results in: quick_output/")

  results
}

#' Batch analysis for multiple transcript files
#'
#' @description Process multiple transcript files in one workflow
#'
#' @param transcript_files Vector of transcript file paths
#' @param output_dir Output directory for results
#' @param privacy_level Privacy protection level
#' @return List of analysis results for each file
#' @export
#' @examples
#' \dontrun{
#' # Batch analysis
#' files <- c("session1.vtt", "session2.vtt", "session3.vtt")
#' results <- batch_basic_analysis(files, "batch_output")
#' }
batch_basic_analysis <- function(transcript_files, output_dir = "batch_output", privacy_level = "high") {
  if (length(transcript_files) == 0) {
    stop("ERROR: No transcript files provided")
  }

  # Validate all files exist
  missing_files <- transcript_files[!file.exists(transcript_files)]
  if (length(missing_files) > 0) {
    stop("ERROR: Files not found: ", paste(missing_files, collapse = ", "))
  }

  message("BATCH: Batch Analysis Mode")
  message(paste(rep("=", 25), collapse = ""))
  message("FILE: Files: ", length(transcript_files))
  message("DIR: Output: ", output_dir)
  message("PRIVACY: Privacy: ", privacy_level)
  message("")

  results <- list()

  for (i in seq_along(transcript_files)) {
    file <- transcript_files[i]
    message("Processing file ", i, "/", length(transcript_files), ": ", basename(file))

    # Create subdirectory for each file
    file_output_dir <- file.path(output_dir, paste0("session_", i))

    tryCatch(
      {
        result <- basic_transcript_analysis(file, file_output_dir, privacy_level)
        results[[basename(file)]] <- result
        message("SUCCESS: Completed: ", basename(file))
      },
      error = function(e) {
        message("ERROR: Failed: ", basename(file), " - ", e$message)
        results[[basename(file)]] <- list(error = e$message)
      }
    )

    message("")
  }

  message("COMPLETE: Batch analysis complete!")
  message("RESULTS: Results saved to: ", output_dir)
  message("STATS: Successful: ", sum(sapply(results, function(x) is.null(x$error))))
  message("ERROR: Failed: ", sum(sapply(results, function(x) !is.null(x$error))))

  results
}
