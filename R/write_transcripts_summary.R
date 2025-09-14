# Internal function - no documentation needed
write_transcripts_summary <-
  function(transcripts_summary_df = NULL,
           data_folder = ".",
           transcripts_summary_file = "transcripts_summary.csv") {
    if (!tibble::is_tibble(transcripts_summary_df)) {
      return(invisible(NULL))
    }
    path <- paste0(data_folder, "/", transcripts_summary_file)
    write_metrics(transcripts_summary_df, what = "summary", path = path)
  }
