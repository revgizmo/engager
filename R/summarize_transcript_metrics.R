#' Summarize Transcript Metrics
#'
#' Process a Zoom recording transcript and return summary metrics by speaker
#'
#' Original code posted by Conor Healy:
#' https://ucbischool.slack.com/archives/C02A36407K9/p1631855705002000 Addition
#' of `wordcount`, `wordcount_perc`, and `wpm` by Brooks Ambrose:
#' https://gist.github.com/brooksambrose/1a8a673eb3bf884c1868ad4d80f08246
#'
#' @param transcript_file_path Path to the transcript file to process
#' @param names_exclude Vector of names to exclude from analysis (default: c("dead_air"))
#' @param consolidate_comments Whether to consolidate consecutive comments (default: TRUE)
#' @param max_pause_sec Maximum pause in seconds between comments to consolidate (default: 1)
#' @param add_dead_air Whether to add dead air rows for gaps in transcript (default: TRUE)
#' @param dead_air_name Name to use for dead air periods (default: 'dead_air')
#' @param na_name Name to use for unknown speakers (default: 'unknown')
#' @param transcript_df Pre-loaded transcript data frame (alternative to transcript_file_path)
#' @param comments_format Format for comments: "list", "text", or "count" (default: "list")
#' @return A tibble containing summary metrics by speaker
#' @examples
#'
#' # Load a sample transcript from the package's extdata directory
#' transcript_file <- system.file("extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
#'   package = "engager"
#' )
#' summarize_transcript_metrics(transcript_file_path = transcript_file)
#'
#' @export
summarize_transcript_metrics <- function(transcript_file_path = "",
                                         names_exclude = c("dead_air"),
                                         consolidate_comments = TRUE,
                                         max_pause_sec = 1,
                                         add_dead_air = TRUE,
                                         dead_air_name = "dead_air",
                                         na_name = "unknown",
                                         transcript_df = NULL,
                                         comments_format = c("list", "text", "count")) {
  consolidate_comments_ <- consolidate_comments
  max_pause_sec_ <- max_pause_sec
  add_dead_air_ <- add_dead_air
  dead_air_name_ <- dead_air_name
  na_name_ <- na_name
  comments_format <- match.arg(comments_format)


  if (file.exists(transcript_file_path)) {
    transcript_df <- engager::process_zoom_transcript(
      transcript_file_path,
      consolidate_comments = consolidate_comments_,
      max_pause_sec = max_pause_sec_,
      add_dead_air = add_dead_air_,
      dead_air_name = dead_air_name_,
      na_name = na_name_
    )
  } else if (is.null(transcript_df)) {
    # If no file path and no transcript_df provided, return NULL
    return(NULL)
  }


  if (is.data.frame(transcript_df)) {
    # Check if transcript_file column exists and prepare grouping
    group_vars <- c("name")
    if ("transcript_file" %in% names(transcript_df)) {
      group_vars <- c("transcript_file", "name")
    }

    # Use base R operations instead of dplyr to avoid segmentation fault
    # Filter out excluded names
    filtered_df <- transcript_df[!transcript_df$name %in% unlist(names_exclude), , drop = FALSE]

    if (nrow(filtered_df) == 0) {
      return(tibble::tibble(
        name = character(),
        n = numeric(),
        duration = numeric(),
        wordcount = numeric(),
        comments = list(),
        # Canonical percentage columns
        perc_n = numeric(),
        perc_duration = numeric(),
        perc_wordcount = numeric(),
        # Temporary aliases for backward compatibility (to be deprecated)
        n_perc = numeric(),
        duration_perc = numeric(),
        wordcount_perc = numeric(),
        wpm = numeric()
      ))
    }

    # Create a unique identifier for each group
    filtered_df$group_id <- apply(filtered_df[, group_vars], 1, paste, collapse = "|")

    # Aggregate by group using base R
    group_ids <- unique(filtered_df$group_id)
    result_rows <- list()

    for (i in seq_along(group_ids)) {
      group_id <- group_ids[i]
      group_data <- filtered_df[filtered_df$group_id == group_id, , drop = FALSE]

      # Calculate summaries
      n_count <- nrow(group_data)
      duration_sum <- sum(as.numeric(group_data$duration), na.rm = TRUE)
      wordcount_sum <- sum(as.numeric(group_data$wordcount), na.rm = TRUE)

      # Format comments based on comments_format parameter
      raw_comments <- group_data$comment
      if (comments_format == "text") {
        comments_col <- paste(unlist(raw_comments), collapse = "; ")
      } else if (comments_format == "count") {
        comments_col <- length(unlist(raw_comments))
      } else {
        # "list" format (default)
        comments_col <- list(raw_comments)
      }

      # Get group identifiers
      group_parts <- strsplit(group_id, "\\|")[[1]]

      # Create result row
      if (length(group_vars) == 1) {
        result_row <- data.frame(
          name = group_parts[1],
          n = n_count,
          duration = duration_sum,
          wordcount = wordcount_sum,
          comments = I(comments_col),
          stringsAsFactors = FALSE
        )
      } else {
        result_row <- data.frame(
          transcript_file = group_parts[1],
          name = group_parts[2],
          n = n_count,
          duration = duration_sum,
          wordcount = wordcount_sum,
          comments = I(comments_col),
          stringsAsFactors = FALSE
        )
      }

      result_rows[[i]] <- result_row
    }

    # Combine results
    result <- do.call(rbind, result_rows)

    # Calculate percentages using base R
    total_n <- sum(result$n, na.rm = TRUE)
    total_duration <- sum(result$duration, na.rm = TRUE)
    total_wordcount <- sum(result$wordcount, na.rm = TRUE)

    # Canonical percentage columns (preferred naming)
    result$perc_n <- result$n / total_n * 100
    result$perc_duration <- result$duration / total_duration * 100
    result$perc_wordcount <- result$wordcount / total_wordcount * 100
    # Temporary aliases for backward compatibility (to be deprecated)
    result$n_perc <- result$perc_n
    result$duration_perc <- result$perc_duration
    result$wordcount_perc <- result$perc_wordcount
    result$wpm <- result$wordcount / result$duration

    # Sort by duration (descending) using base R
    result <- result[order(-result$duration), , drop = FALSE]

    # Convert to tibble to maintain expected return type
    result <- tibble::as_tibble(result)

    # Attach provenance attributes
    attr(result, "schema_version") <- "1.0"
    attr(
      result,
      "source_files"
    ) <- if (!is.null(transcript_file_path) && nzchar(transcript_file_path)) {
      basename(transcript_file_path)
    } else {
      NA_character_
    }
    attr(result, "processing_timestamp") <- as.character(Sys.time())
    attr(result, "privacy_level") <- getOption("zoomstudentengagement.privacy_level", "mask")

    # Apply privacy before returning
    return(engager::ensure_privacy(result))
  }
}
