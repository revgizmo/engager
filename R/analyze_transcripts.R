#' Analyze Transcripts (High-level orchestration)
#'
#' Convenience wrapper to process a set of `.transcript.vtt` files from a folder,
#' compute engagement metrics, and optionally write outputs.
#'
#' @param transcripts_folder Path to folder containing transcript files
#' @param names_to_exclude Vector of names to exclude from analysis (default: "dead_air")
#' @param write Whether to write results to file (default: FALSE)
#' @param output_path Path for output file (defaults to "engagement_metrics.csv")
#' @return Data frame with engagement metrics
#'
#' @export
analyze_transcripts <- function(
    transcripts_folder = NULL,
    names_to_exclude = c("dead_air"),
    write = FALSE,
    output_path = NULL) {
  if (!dir.exists(transcripts_folder)) {
    stop(sprintf("Folder not found: %s", transcripts_folder))
  }

  files <- list.files(transcripts_folder, pattern = "\\.transcript\\.vtt$", full.names = TRUE)
  if (length(files) == 0) {
    stop("No .transcript.vtt files found in the provided folder")
  }

  # Build input for summarize_transcript_files
  file_names <- basename(files)
  input_df <- tibble::tibble(transcript_file = file_names)

  metrics <- summarize_transcript_files(
    transcript_file_names = input_df,
    data_folder = ".",
    transcripts_folder = transcripts_folder,
    names_to_exclude = names_to_exclude,
    deduplicate_content = FALSE
  )

  if (isTRUE(write)) {
    write_metrics(
      metrics,
      what = "engagement",
      path = if (is.null(output_path)) "engagement_metrics.csv" else output_path
    )
  }

  metrics
}

# Safe infix for defaults (using backticks for special operator names)
# nolint: object_name_linter
