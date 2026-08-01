#' Consolidate Transcript
#'
#' Take a tibble containing the comments from a Zoom recording transcript and return a tibble
#' that consolidates all consecutive comments from the same speaker where the time between the
#' end of the first comment and start of the second comment is less than `max_pause_sec` seconds.
#' This function addresses an issue with the Zoom transcript where the speaker is speaking a
#' continuous sentence, but the Zoom transcript will cut the comment into two lines.
#' For example, a comment of "This should be a single sentence." is often split into
#' "This should be" and "a single sentence". This function stitches those together into
#' "This should be a single sentence." where the `start` time of the consolidated comment
#' will be the beginning of the first row and the `end` time of the consolidated comment
#' will be the ending of the last row.
#'
#' @param df A tibble containing transcript comments with columns: name, start, end, comment
#' @param max_pause_sec Maximum pause in seconds between comments to consolidate (default: 1)
#' @return A tibble with consecutive comments consolidated by speaker and pause
#'   threshold, including `name`, `comment`, `start`, `end`, `duration`, and
#'   `wordcount` columns. Returns `NULL` when `df` is not a tibble.
#'
#' @export
consolidate_transcript <- function(df = NULL, max_pause_sec = 1) {
  if (tibble::is_tibble(df)) {
    # Handle empty data case
    if (nrow(df) == 0) {
      return(create_empty_result(df))
    }

    # Process time columns and calculate flags
    df <- process_transcript_timing(df, max_pause_sec)

    # Perform aggregation
    result <- aggregate_transcript_data(df)

    # Calculate final metrics and return
    return(calculate_final_metrics(result))
  }
}

# Helper function to create empty consolidated result
create_empty_result <- function(df) {
  # Return empty tibble with correct structure
  result_cols <- c("name", "comment", "start", "end", "duration", "wordcount")
  if ("transcript_file" %in% names(df)) {
    result_cols <- c("transcript_file", result_cols)
  }

  empty_result <- stats::setNames(
    lapply(result_cols, function(x) if (x %in% c("duration", "wordcount")) numeric(0) else character(0)),
    result_cols
  )
  tibble::as_tibble(empty_result)
}

# Helper function to process transcript timing
process_transcript_timing <- function(df, max_pause_sec) {
  # Ensure time columns are of type hms (replacing lubridate::period to avoid segfaults)
  # Use base R operations to avoid dplyr segfaults
  df$start <- hms::as_hms(df$start)
  df$end <- hms::as_hms(df$end)

  # Use base R operations to avoid segmentation faults with dplyr + hms
  # Sort by start time for lag operations
  df <- df[order(df$start), ]

  # Calculate lag values using base R
  df$prev_end <- c(hms::hms(0), df$end[-length(df$end)])
  df$prior_dead_air <- as.numeric(df$start - df$prev_end)
  df$prior_speaker <- c(df$name[1], df$name[-length(df$name)])

  # Calculate flags
  df$name_flag <- ((df$name != df$prior_speaker) | is.na(df$name) | is.na(df$prior_speaker))
  df$time_flag <- df$prior_dead_air > max_pause_sec
  df$comment_num <- cumsum(df$name_flag | df$time_flag)

  df
}

# Helper function to aggregate transcript data
aggregate_transcript_data <- function(df) {
  # Use aggregate() for efficient grouping operations; keep full vectors for post-processing:
  # specifically, collapsing comments into a single string and selecting the first/last timestamps per group.
  if ("transcript_file" %in% names(df)) {
    agg_result <- perform_aggregation(df, c("transcript_file", "comment_num"))

    # Post-process to get one row per group with consistent lengths
    data.frame(
      transcript_file = agg_result$transcript_file,
      name = vapply(agg_result$name, function(x) x[1], FUN.VALUE = character(1)),
      comment = vapply(agg_result$comment, function(x) paste(x, collapse = " "), FUN.VALUE = character(1)),
      start = vapply(agg_result$start, function(x) hms::as_hms(x[1]), FUN.VALUE = hms::hms(0)),
      end = vapply(agg_result$end, function(x) hms::as_hms(x[length(x)]), FUN.VALUE = hms::hms(0)),
      stringsAsFactors = FALSE
    )
  } else {
    agg_result <- perform_aggregation(df, "comment_num")

    data.frame(
      name = vapply(agg_result$name, function(x) x[1], FUN.VALUE = character(1)),
      comment = vapply(agg_result$comment, function(x) paste(x, collapse = " "), FUN.VALUE = character(1)),
      start = vapply(agg_result$start, function(x) hms::as_hms(x[1]), FUN.VALUE = hms::hms(0)),
      end = vapply(agg_result$end, function(x) hms::as_hms(x[length(x)]), FUN.VALUE = hms::hms(0)),
      stringsAsFactors = FALSE
    )
  }
}

# Helper function to perform the actual aggregation
perform_aggregation <- function(df, by_columns) {
  stats::aggregate(
    list(
      name = df$name,
      comment = df$comment,
      start = df$start,
      end = df$end
    ),
    by = if (length(by_columns) == 1) {
      list(comment_num = df$comment_num)
    } else {
      list(
        transcript_file = df$transcript_file,
        comment_num = df$comment_num
      )
    },
    FUN = function(x) {
      # Keep full vectors; collapsing (e.g., selecting first/last, concatenating) is handled in aggregate_transcript_data()
      x
    },
    simplify = FALSE
  )
}

# Helper function to calculate final metrics
calculate_final_metrics <- function(result) {
  # Calculate duration and wordcount efficiently
  result$duration <- as.numeric(result$end - result$start)

  # Vectorized wordcount calculation
  result$wordcount <- vapply(
    strsplit(result$comment, "\\s+"),
    function(x) length(x[x != ""]),
    integer(1)
  )

  # Convert to tibble to maintain expected return type
  tibble::as_tibble(result)
}
