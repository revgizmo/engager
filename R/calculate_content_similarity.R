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
  
  # Add comments column if missing (default to 0)
  if (!"comments" %in% names(transcript1)) {
    transcript1$comments <- 0
  }
  if (!"comments" %in% names(transcript2)) {
    transcript2$comments <- 0
  }

  # Filter out excluded names
  if (!is.null(names_to_exclude)) {
    transcript1 <- transcript1[!transcript1$name %in% names_to_exclude, ]
    transcript2 <- transcript2[!transcript2$name %in% names_to_exclude, ]
  }

  # Calculate speaker overlap
  speakers1 <- unique(transcript1$name)
  speakers2 <- unique(transcript2$name)
  common_speakers <- intersect(speakers1, speakers2)
  max_speakers <- max(length(speakers1), length(speakers2))
  speaker_overlap <- if (max_speakers > 0) length(common_speakers) / max_speakers else 1

  # Calculate duration ratio
  duration1 <- sum(as.numeric(transcript1$duration), na.rm = TRUE)
  duration2 <- sum(as.numeric(transcript2$duration), na.rm = TRUE)
  max_duration <- max(duration1, duration2)
  duration_ratio <- if (max_duration > 0) min(duration1, duration2) / max_duration else 1

  # Calculate word count ratio
  wordcount1 <- sum(transcript1$wordcount, na.rm = TRUE)
  wordcount2 <- sum(transcript2$wordcount, na.rm = TRUE)
  max_wordcount <- max(wordcount1, wordcount2)
  word_count_ratio <- if (max_wordcount > 0) min(wordcount1, wordcount2) / max_wordcount else 1

  # Calculate comment count ratio
  comments1 <- sum(transcript1$comments, na.rm = TRUE)
  comments2 <- sum(transcript2$comments, na.rm = TRUE)
  max_comments <- max(comments1, comments2)
  comment_count_ratio <- if (max_comments > 0) min(comments1, comments2) / max_comments else 1

  # Calculate content similarity (simplified)
  content_similarity <- (speaker_overlap + duration_ratio + word_count_ratio + comment_count_ratio) / 4

  # Special case: if all meaningful metrics are zero, return 0.0
  # This handles the case where transcripts have no meaningful data
  if (max_duration == 0 && max_wordcount == 0 && max_comments == 0 && length(common_speakers) == 0) {
    return(0.0)
  }

  # Overall similarity score
  similarity_score <- content_similarity

  return(similarity_score)
}