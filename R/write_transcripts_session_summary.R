# Internal function - no documentation needed
write_transcripts_session_summary <-
  function(transcripts_session_summary_df = NULL,
           data_folder = NULL,
           transcripts_session_summary_file = "transcripts_session_summary.csv") {
    if (!tibble::is_tibble(transcripts_session_summary_df)) {
      return(invisible(NULL))
    }
    if (is.null(data_folder) || !is.character(data_folder) || length(data_folder) != 1L || !nzchar(data_folder)) {
      stop("`data_folder` must be supplied to write the session summary", call. = FALSE)
    }
    path <- paste0(data_folder, "/", transcripts_session_summary_file)
    write_metrics(transcripts_session_summary_df, what = "session_summary", path = path)
  }
