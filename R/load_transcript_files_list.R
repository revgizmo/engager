# Internal function - no documentation needed
load_transcript_files_list <-
  function(data_folder = ".",
           transcripts_folder = "transcripts",
           # zoom_recorded_sessions_csv_names_pattern =
           #   'zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv',
           transcript_files_names_pattern =
             "GMT\\d{8}-\\d{6}_Recording",
           dt_extract_pattern = "(?<=GMT)\\d{8}",
           trnscrptflxtnsnpttrn = ".transcript",
           clsdcptnflxtnsnpttrn = ".cc",
           recording_start_pattern = "(?<=GMT)\\d{8}-\\d{6}",
           recording_start_format = "%Y%m%d-%H%M%S",
           start_time_local_tzone = "America/Los_Angeles") {
    transcripts_folder_path <- file.path(data_folder, transcripts_folder)

    if (!dir.exists(transcripts_folder_path)) {
      return(NULL)
    }

    transcript_files <- list.files(
      transcripts_folder_path,
      transcript_files_names_pattern
    )

    # Return empty tibble when no matching files are found
    if (length(transcript_files) == 0) {
      return(tibble::as_tibble(data.frame()))
    }

    # Use base R operations instead of dplyr to avoid segmentation fault
    # Create data frame with file names
    df <- data.frame(file_name = transcript_files, stringsAsFactors = FALSE)

    # Extract date
    df$date_extract <- stringr::str_extract(df$file_name, dt_extract_pattern)
    missing_date <- is.na(df$date_extract) | !nzchar(df$date_extract)
    df$date_extract[missing_date] <- derive_transcript_session_key(df$file_name[missing_date])

    # Determine file type
    df$file_type <- ifelse(
      grepl(trnscrptflxtnsnpttrn, df$file_name, fixed = FALSE),
      "transcript_file",
      ifelse(
        grepl(clsdcptnflxtnsnpttrn, df$file_name, fixed = FALSE),
        "closed_caption_file",
        ifelse(
          grepl("[.]chat[.]", df$file_name),
          "chat_file",
          "transcript_file"
        )
      )
    )

    # Extract and parse recording start time
    recording_start_str <- stringr::str_extract(df$file_name, recording_start_pattern)
    df$recording_start <- lubridate::parse_date_time(recording_start_str, orders = recording_start_format)
    df$recording_start <- as.POSIXct(df$recording_start, tz = "UTC")
    missing_start <- is.na(df$recording_start)
    if (any(missing_start)) {
      fallback_session_keys <- unique(df$date_extract[missing_start])
      fallback_recording_start <- as.POSIXct(
        seq_along(fallback_session_keys),
        origin = "1970-01-01",
        tz = "UTC"
      )
      names(fallback_recording_start) <- fallback_session_keys
      df$recording_start[missing_start] <- as.POSIXct(
        fallback_recording_start[df$date_extract[missing_start]],
        origin = "1970-01-01",
        tz = "UTC"
      )
    }
    df$start_time_local <- lubridate::with_tz(df$recording_start, tzone = start_time_local_tzone)

    # Pivot to wide format per recording using base R
    groups_df <- unique(df[, c("date_extract", "recording_start", "start_time_local"), drop = FALSE])
    # Ensure groups are ordered by time
    groups_df <- groups_df[order(groups_df$start_time_local), , drop = FALSE]
    # Initialize result with groups
    result <- groups_df

    # Add file type columns per group
    file_types <- unique(df$file_type)
    for (file_type in file_types) {
      result[[file_type]] <- NA_character_
    }

    # Fill in file names per group and type
    if (nrow(result) > 0) {
      for (k in seq_len(nrow(result))) {
        row_date <- result$date_extract[k]
        row_start <- result$recording_start[k]
        for (file_type in file_types) {
          type_files <- df[df$file_type == file_type & df$date_extract == row_date &
            df$recording_start == row_start, "file_name", drop = TRUE]
          if (length(type_files) > 0) {
            result[[file_type]][k] <- type_files[1]
          }
        }
      }
    }

    return(tibble::as_tibble(result))
  }

# Internal helper to derive a shared session key for non-Zoom fixture names
derive_transcript_session_key <- function(file_name) {
  session_key <- tools::file_path_sans_ext(file_name)
  session_key <- sub("[.]transcript$", "", session_key)
  session_key <- sub("[.]cc$", "", session_key)
  session_key <- sub("[.]chat$", "", session_key)
  session_key
}
