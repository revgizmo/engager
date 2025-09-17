# Internal function - no documentation needed

make_students_only_transcripts_summary_df <-
  function(transcripts_session_summary_df = NULL,
           preferred_name_exclude_cv = c("dead_air", "Instructor Name", "Guests", "unknown")) {
    if (tibble::is_tibble(transcripts_session_summary_df)
    ) {
      # Use base R operations instead of dplyr to avoid segmentation fault
      # Filter for valid sections and student names
      valid_sections <- !is.na(transcripts_session_summary_df$section)
      valid_names <- !is.na(transcripts_session_summary_df$preferred_name)
      not_excluded <- !(transcripts_session_summary_df$preferred_name %in% preferred_name_exclude_cv)

      # Combine all filter conditions
      keep_rows <- valid_sections & valid_names & not_excluded

      # Apply filter
      filtered_df <- transcripts_session_summary_df[keep_rows, , drop = FALSE]

      # Call make_transcripts_summary_df on filtered data
      make_transcripts_summary_df(filtered_df)
    }
  }
