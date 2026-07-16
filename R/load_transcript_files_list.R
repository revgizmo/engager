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
    df$session_key <- derive_transcript_session_key(df$file_name)

    # Extract date
    df$date_extract <- stringr::str_extract(df$file_name, dt_extract_pattern)
    missing_date <- is.na(df$date_extract) | !nzchar(df$date_extract)
    df$date_extract[missing_date] <- df$session_key[missing_date]

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

    # One session may have one file of each supported type. Two files that map
    # to the same session and type are ambiguous and must not be silently
    # collapsed into one attendance input.
    session_type_key <- paste(df$session_key, df$file_type, sep = "\r")
    duplicate_session_type <- duplicated(session_type_key) |
      duplicated(session_type_key, fromLast = TRUE)
    if (any(duplicate_session_type)) {
      duplicate_session_count <- length(unique(
        df$session_key[duplicate_session_type]
      ))
      rlang::abort(
        message = sprintf(
          paste0(
            "%d session%s %s duplicate files of the same type; ",
            "session keys and file types must map uniquely."
          ),
          duplicate_session_count,
          if (duplicate_session_count == 1L) "" else "s",
          if (duplicate_session_count == 1L) "contains" else "contain"
        ),
        class = "engager_schema_error"
      )
    }

    # Extract and parse recording start time
    recording_start_str <- stringr::str_extract(df$file_name, recording_start_pattern)
    df$recording_start <- as.POSIXct(
      recording_start_str,
      format = recording_start_format,
      tz = "UTC"
    )
    missing_start <- is.na(df$recording_start)
    if (any(missing_start)) {
      unknown_session_count <- length(unique(df$session_key[missing_start]))
      warning(
        sprintf(
          paste0(
            "Recording time could not be parsed for %d session%s; ",
            "recording_start and start_time_local remain NA. ",
            "Unknown-time sessions are ordered by session_key."
          ),
          unknown_session_count,
          if (unknown_session_count == 1L) "" else "s"
        ),
        call. = FALSE
      )
    }
    df$start_time_local <- lubridate::with_tz(df$recording_start, tzone = start_time_local_tzone)

    # Pivot to wide format per stable session key using base R.
    first_session_row <- match(unique(df$session_key), df$session_key)
    groups_df <- df[
      first_session_row,
      c("session_key", "date_extract", "recording_start", "start_time_local"),
      drop = FALSE
    ]

    # Known sessions sort chronologically. Unknown sessions sort after them by
    # stable session key rather than by a fabricated timestamp or input order.
    known_rows <- which(!is.na(groups_df$recording_start))
    unknown_rows <- which(is.na(groups_df$recording_start))
    known_rows <- known_rows[order(
      groups_df$recording_start[known_rows],
      groups_df$session_key[known_rows]
    )]
    unknown_rows <- unknown_rows[order(groups_df$session_key[unknown_rows])]
    groups_df <- groups_df[c(known_rows, unknown_rows), , drop = FALSE]
    rownames(groups_df) <- NULL

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
        row_session_key <- result$session_key[k]
        for (file_type in file_types) {
          type_files <- df[
            df$file_type == file_type & df$session_key == row_session_key,
            "file_name",
            drop = TRUE
          ]
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
