#' Calculate Content Similarity Between Two Transcripts
#'
#' This function calculates the similarity between two transcript data frames
#' based on various metrics including speaker overlap, duration, word count,
#' comment count, and content similarity.
#'
#' @param transcript1 First transcript data frame
#' @param transcript2 Second transcript data frame
#' @param names_to_exclude Character vector of names to exclude from analysis
#' @return Numeric similarity score between 0 and 1
#'
#' @examples
#' # Calculate similarity between two transcripts
#' # similarity <- calculate_content_similarity(transcript1, transcript2)
#'
#' # Calculate similarity excluding dead air entries
#' # similarity <- calculate_content_similarity(transcript1, transcript2,
#' #   names_to_exclude = c("dead_air", "silence")
#' # )
calculate_content_similarity <- function(
    transcript1 = NULL,
    transcript2 = NULL,
    names_to_exclude = c("dead_air")) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'calculate_content_similarity' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Validate inputs
  if (is.null(transcript1) || is.null(transcript2)) {
    return(0.0)
  }
  
  if (!is.data.frame(transcript1) || !is.data.frame(transcript2)) {
    return(0.0)
  }
  
  if (nrow(transcript1) == 0 || nrow(transcript2) == 0) {
    return(0.0)
  }
  
  # Filter out excluded names (only if name column exists)
  if (!is.null(names_to_exclude) && "name" %in% names(transcript1) && "name" %in% names(transcript2)) {
    transcript1 <- transcript1[!transcript1$name %in% names_to_exclude, , drop = FALSE]
    transcript2 <- transcript2[!transcript2$name %in% names_to_exclude, , drop = FALSE]
  }
  
  # If no data left after filtering, return 0
  if (nrow(transcript1) == 0 || nrow(transcript2) == 0) {
    return(0.0)
  }
  
  # Calculate basic similarity based on common columns
  common_cols <- intersect(names(transcript1), names(transcript2))
  if (length(common_cols) == 0) {
    return(0.0)
  }
  
  # Simple similarity calculation based on numeric columns
  # Only consider transcript-relevant columns (not arbitrary numeric columns)
  transcript_cols <- c("duration", "word_count", "speaker_count", "turn_count", "avg_turn_length")
  relevant_cols <- intersect(common_cols, transcript_cols)
  if (length(relevant_cols) == 0) {
    return(0.0)
  }
  numeric_cols <- relevant_cols[sapply(transcript1[relevant_cols], is.numeric)]
  if (length(numeric_cols) == 0) {
    return(0.0)
  }
  
  # Calculate similarity for each numeric column
  similarities <- numeric(length(numeric_cols))
  for (i in seq_along(numeric_cols)) {
    col <- numeric_cols[i]
    val1 <- sum(transcript1[[col]], na.rm = TRUE)
    val2 <- sum(transcript2[[col]], na.rm = TRUE)
    
    if (val1 == 0 && val2 == 0) {
      similarities[i] <- 0.0  # No meaningful data when both are 0
    } else if (val1 == 0 || val2 == 0) {
      similarities[i] <- 0.0
    } else {
      similarities[i] <- 1.0 - abs(val1 - val2) / max(val1, val2)
    }
  }
  
  # Return average similarity
  mean(similarities, na.rm = TRUE)
}
