# Internal function - no documentation needed
write_transcripts_session_summary <-
  function(transcripts_session_summary_df = NULL,
           data_folder = ".",
           transcripts_session_summary_file = "transcripts_session_summary.csv") {
    if (!tibble::is_tibble(transcripts_session_summary_df)) {
      return(invisible(NULL))
    }
    path <- paste0(data_folder, "/", transcripts_session_summary_file)
    write_metrics(transcripts_session_summary_df, what = "session_summary", path = path)
  }
