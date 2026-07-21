#' Load Zoom Transcript
#'
#' Load a Zoom recording transcript and return tibble containing the comments from a Zoom recording transcript
#'
#' Original code posted by Conor Healy:
#' https://ucbischool.slack.com/archives/C02A36407K9/p1631855705002000 Addition
#' of `wordcount` by Brooks Ambrose:
#' https://gist.github.com/brooksambrose/1a8a673eb3bf884c1868ad4d80f08246
#'
#' @param transcript_file_path Path to the transcript file to load
#' @return A tibble with one row per parsed WebVTT cue and columns describing
#'   speaker name, cue text, start and end times, duration, word count, and
#'   source transcript. Returns `NULL` when the file is empty.
#' @examples
#' # Load a sample transcript from the package's extdata directory
#' transcript_file <- system.file("extdata/test_transcripts/intro_statistics_week1.vtt",
#'   package = "engager"
#' )
#' load_zoom_transcript(transcript_file_path = transcript_file)
#'
#' @export
load_zoom_transcript <- function(transcript_file_path = NULL) {
  if (!file.exists(transcript_file_path)) {
    abort_zse("file.exists(transcript_file_path) is not TRUE", class = "zse_input_error")
  }

  # Read the first line to validate VTT format
  first_line <- readLines(transcript_file_path, n = 1)
  if (first_line != "WEBVTT") {
    abort_zse(paste0("Invalid VTT: expected 'WEBVTT', got '", first_line, "'"), class = "zse_input_error")
  }

  transcript_file <- basename(transcript_file_path)

  transcript_lines <- readLines(transcript_file_path, warn = FALSE)
  transcript_lines <- sub("\r$", "", transcript_lines)

  # Return NULL for empty files
  if (length(transcript_lines) <= 1) {
    return(NULL)
  }

  transcript_df <- parse_webvtt_cues(transcript_lines[-1], transcript_file)
  if (nrow(transcript_df) == 0) {
    return(NULL)
  }

  # Convert to hms with error handling and calculate duration
  safe_as_hms <- function(x) {
    tryCatch(hms::as_hms(x), warning = function(w) hms::as_hms(NA), error = function(e) hms::as_hms(NA))
  }
  transcript_df$start <- do.call(c, lapply(transcript_df$start, safe_as_hms))
  transcript_df$end <- do.call(c, lapply(transcript_df$end, safe_as_hms))
  transcript_df$duration <- transcript_df$end - transcript_df$start

  # Calculate wordcount
  transcript_df$wordcount <- sapply(transcript_df$comment, function(x) {
    if (is.na(x) || x == "") {
      return(0)
    }
    length(strsplit(x, " +")[[1]])
  })

  # Select final columns using base R
  result <- transcript_df[
    ,
    c("transcript_file", "comment_num", "name", "comment", "start", "end", "duration", "wordcount")
  ]

  # Filter out rows with missing or invalid timestamps, comments, or negative duration
  result <- result[
    !is.na(result$start) &
      !is.na(result$end) &
      !is.na(result$duration) &
      result$duration >= 0 &
      !is.na(result$comment) &
      result$comment != "", ,
    drop = FALSE
  ]

  if (nrow(result) == 0) {
    return(NULL)
  }

  # Convert to tibble to maintain expected return type and validate minimal shape
  result <- tibble::as_tibble(result)
  try(validate_schema(result, c(
    "transcript_file", "comment_num", "name", "comment",
    "start", "end", "duration", "wordcount"
  )), silent = TRUE)
  return(result)
}

# Internal helper to parse blank-separated WebVTT cues.
parse_webvtt_cues <- function(lines, transcript_file) {
  lines <- lines[!grepl("^NOTE($|[[:space:]])", lines)]
  timestamp_indices <- grep(" --> ", lines, fixed = TRUE)
  if (length(timestamp_indices) == 0) {
    return(tibble::tibble(
      transcript_file = character(),
      comment_num = character(),
      name = character(),
      comment = character(),
      start = character(),
      end = character()
    ))
  }

  rows <- list()
  for (i in seq_along(timestamp_indices)) {
    timestamp_idx <- timestamp_indices[i]
    next_timestamp_idx <- if (i < length(timestamp_indices)) timestamp_indices[i + 1] else length(lines) + 1L

    cue_id_idx <- timestamp_idx - 1L
    has_cue_id <- cue_id_idx >= 1L &&
      nzchar(lines[cue_id_idx]) &&
      !grepl(" --> ", lines[cue_id_idx], fixed = TRUE)

    comment_start <- timestamp_idx + 1L
    comment_end <- next_timestamp_idx - 1L
    if (comment_end >= comment_start && comment_end >= 1L && !nzchar(lines[comment_end])) {
      comment_end <- comment_end - 1L
    }
    if (comment_end >= comment_start && comment_end >= 1L && is_probable_cue_identifier(lines[comment_end])) {
      comment_end <- comment_end - 1L
    }

    comment_lines <- if (comment_start <= comment_end) {
      lines[comment_start:comment_end]
    } else {
      character()
    }
    comment_lines <- comment_lines[nzchar(comment_lines)]
    if (length(comment_lines) == 0) {
      next
    }

    comment_num <- if (has_cue_id) {
      lines[cue_id_idx]
    } else {
      as.character(length(rows) + 1L)
    }

    comment <- paste(comment_lines, collapse = " ")
    speaker_comment <- split_webvtt_speaker(comment)
    time_parts <- split_webvtt_timestamp(lines[timestamp_idx])

    rows[[length(rows) + 1L]] <- tibble::tibble(
      transcript_file = transcript_file,
      comment_num = comment_num,
      name = speaker_comment$name,
      comment = speaker_comment$comment,
      start = time_parts$start,
      end = time_parts$end
    )
  }

  if (length(rows) == 0) {
    return(tibble::tibble(
      transcript_file = character(),
      comment_num = character(),
      name = character(),
      comment = character(),
      start = character(),
      end = character()
    ))
  }

  do.call(rbind, rows)
}

# Internal helper to identify cue identifiers before the next timestamp.
is_probable_cue_identifier <- function(line) {
  line <- trimws(line)
  nzchar(line) &&
    !grepl(":", line, fixed = TRUE) &&
    !grepl("^<v[[:space:]]+", line) &&
    !grepl("[.?!]$", line)
}

# Internal helper to split WebVTT timestamps and drop cue settings.
split_webvtt_timestamp <- function(timestamp) {
  time_split <- strsplit(timestamp, " --> ", fixed = TRUE)[[1]]
  start <- if (length(time_split) >= 1) trimws(time_split[1]) else NA_character_
  end <- if (length(time_split) >= 2) trimws(strsplit(time_split[2], "[[:space:]]+")[[1]][1]) else NA_character_
  list(start = start, end = end)
}

# Internal helper to extract speaker labels from WebVTT voice spans or Zoom text.
split_webvtt_speaker <- function(comment) {
  voice_match <- regexec("^<v[[:space:]]+([^>]+)>(.*)$", comment)
  voice_parts <- regmatches(comment, voice_match)[[1]]
  if (length(voice_parts) == 3) {
    return(list(name = trimws(voice_parts[2]), comment = trimws(voice_parts[3])))
  }

  name_comment_split <- strsplit(comment, ": ", fixed = TRUE)[[1]]
  if (length(name_comment_split) > 1) {
    return(list(
      name = name_comment_split[1],
      comment = paste(name_comment_split[-1], collapse = ": ")
    ))
  }

  list(name = NA_character_, comment = comment)
}
