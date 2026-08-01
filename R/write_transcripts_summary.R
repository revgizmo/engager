# Internal function - no documentation needed
write_transcripts_summary <-
  function(transcripts_summary_df = NULL,
           data_folder = NULL,
           transcripts_summary_file = "transcripts_summary.csv") {
    if (!tibble::is_tibble(transcripts_summary_df)) {
      return(invisible(NULL))
    }
    if (is.null(data_folder) || !is.character(data_folder) ||
        length(data_folder) != 1L || is.na(data_folder) ||
        !nzchar(trimws(data_folder))) {
      stop("`data_folder` must be supplied to write the summary", call. = FALSE)
    }
    if (!is.character(transcripts_summary_file) ||
        length(transcripts_summary_file) != 1L ||
        is.na(transcripts_summary_file) ||
        !nzchar(trimws(transcripts_summary_file))) {
      stop("`transcripts_summary_file` must be one non-empty file name", call. = FALSE)
    }
    path <- file.path(data_folder, transcripts_summary_file)
    write_metrics(transcripts_summary_df, what = "summary", path = path)
  }
