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
    return(list(
      similarity_score = 0,
      speaker_overlap = 0,
      duration_ratio = 0,
      word_count_ratio = 0,
      comment_count_ratio = 0,
      content_similarity = 0
    ))
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
  speaker_overlap <- length(common_speakers) / max(length(speakers1), length(speakers2))

  # Calculate duration ratio
  duration1 <- sum(transcript1$duration, na.rm = TRUE)
  duration2 <- sum(transcript2$duration, na.rm = TRUE)
  duration_ratio <- min(duration1, duration2) / max(duration1, duration2)

  # Calculate word count ratio
  wordcount1 <- sum(transcript1$wordcount, na.rm = TRUE)
  wordcount2 <- sum(transcript2$wordcount, na.rm = TRUE)
  word_count_ratio <- min(wordcount1, wordcount2) / max(wordcount1, wordcount2)

  # Calculate comment count ratio
  comments1 <- sum(transcript1$comments, na.rm = TRUE)
  comments2 <- sum(transcript2$comments, na.rm = TRUE)
  comment_count_ratio <- min(comments1, comments2) / max(comments1, comments2)

  # Calculate content similarity (simplified)
  content_similarity <- (speaker_overlap + duration_ratio + word_count_ratio + comment_count_ratio) / 4

  # Overall similarity score
  similarity_score <- content_similarity

  return(list(
    similarity_score = similarity_score,
    speaker_overlap = speaker_overlap,
    duration_ratio = duration_ratio,
    word_count_ratio = word_count_ratio,
    comment_count_ratio = comment_count_ratio,
    content_similarity = content_similarity
  ))
}