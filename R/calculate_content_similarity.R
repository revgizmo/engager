#' Calculate Content Similarity Between Two Transcripts
#'
#' This function calculates the similarity between two transcript data frames
#' based on various metrics including speaker overlap, duration, word count,
#' comment count, and content similarity.

calculate_content_similarity <- function(
    transcript1 = NULL,
    transcript2 = NULL,
    names_to_exclude = c("dead_air")) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'calculate_content_similarity' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  # Validate inputs
  if (is.null(transcript1) || is.null(transcript2)) {
    return(0)
  }

  # Check if required columns exist
  required_cols <- c("name", "duration", "wordcount")
  if (!all(required_cols %in% names(transcript1)) || !all(required_cols %in% names(transcript2))) {
    return(0)
  }
  
  # Check if comments column exists, if not use nrow as fallback
  has_comments1 <- "comments" %in% names(transcript1)
  has_comments2 <- "comments" %in% names(transcript2)

  # Filter out excluded names
  if (!is.null(names_to_exclude)) {
    transcript1 <- transcript1[!transcript1$name %in% names_to_exclude, ]
    transcript2 <- transcript2[!transcript2$name %in% names_to_exclude, ]
  }

  # Calculate speaker overlap
  speakers1 <- unique(transcript1$name)
  speakers2 <- unique(transcript2$name)
  common_speakers <- intersect(speakers1, speakers2)
  speaker_overlap <- if (max(length(speakers1), length(speakers2)) > 0) {
    length(common_speakers) / max(length(speakers1), length(speakers2))
  } else {
    1.0  # Both have no speakers, so they're identical
  }

  # Calculate duration ratio
  duration1 <- as.numeric(sum(transcript1$duration, na.rm = TRUE))
  duration2 <- as.numeric(sum(transcript2$duration, na.rm = TRUE))
  duration_ratio <- if (max(duration1, duration2) > 0) {
    min(duration1, duration2) / max(duration1, duration2)
  } else {
    1.0  # Both are 0, so they're identical
  }

  # Calculate word count ratio
  wordcount1 <- sum(transcript1$wordcount, na.rm = TRUE)
  wordcount2 <- sum(transcript2$wordcount, na.rm = TRUE)
  word_count_ratio <- if (max(wordcount1, wordcount2) > 0) {
    min(wordcount1, wordcount2) / max(wordcount1, wordcount2)
  } else {
    1.0  # Both are 0, so they're identical
  }

  # Calculate comment count ratio
  if (has_comments1 && has_comments2) {
    comments1 <- sum(transcript1$comments, na.rm = TRUE)
    comments2 <- sum(transcript2$comments, na.rm = TRUE)
  } else {
    # Fallback to row count if comments column doesn't exist
    comments1 <- nrow(transcript1)
    comments2 <- nrow(transcript2)
  }
  comment_count_ratio <- if (max(comments1, comments2) > 0) {
    min(comments1, comments2) / max(comments1, comments2)
  } else {
    1.0  # Both have no comments, so they're identical
  }

  # Check if there's any meaningful data to compare
  total_duration1 <- as.numeric(sum(transcript1$duration, na.rm = TRUE))
  total_duration2 <- as.numeric(sum(transcript2$duration, na.rm = TRUE))
  total_wordcount1 <- sum(transcript1$wordcount, na.rm = TRUE)
  total_wordcount2 <- sum(transcript2$wordcount, na.rm = TRUE)
  
  # If both transcripts have no meaningful content, return 0
  if (total_duration1 == 0 && total_duration2 == 0 && 
      total_wordcount1 == 0 && total_wordcount2 == 0) {
    return(0.0)
  }

  # Calculate content similarity (simplified)
  content_similarity <- (speaker_overlap + duration_ratio + word_count_ratio + comment_count_ratio) / 4

  # Overall similarity score
  similarity_score <- content_similarity

  return(similarity_score)
}