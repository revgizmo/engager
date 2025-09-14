# Internal function - no documentation needed
join_transcripts_list <- function(
    df_zoom_recorded_sessions = NULL,
    df_transcript_files = NULL,
    df_cancelled_classes = NULL) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'join_transcripts_list' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  # Simplified deprecated function - just return empty tibble with correct structure
  tibble::tibble(
    section = character(),
    match_start_time = as.POSIXct(character()),
    match_end_time = as.POSIXct(character()),
    start_time_local = as.POSIXct(character()),
    session_num = integer()
  )
}
# join_transcripts_list(df_zoom_recorded_sessions = zoom_recorded_sessions_df,
#                       df_transcript_files = transcript_files_df,
#                       df_cancelled_classes = cancelled_classes_df)
