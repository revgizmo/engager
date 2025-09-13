#' Make Names to Clean DF
#'
#' This function creates a tibble from the provided tibble containing session details
#' and summary metrics by speaker for all class sessions (and placeholders for
#' missing sections), including customized student names, and filters out all
#' records except for those students with transcript recordings but no matching
#' student id.
#'
#' If any names except "dead_air", "unknown", or the instructor's name are listed, resolve them.
#'
#'   + Update students with their formal name from the roster in your `section_names_lookup.csv`
#'   + If appropriate, update `section_names_lookup.csv` with a corresponding `preferred_name`
#'   + Any guest students, label them as "Guests"
#'
#'
#'
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#'
#'   by speaker students with transcript recordings but no matching
#' student id.
#'
make_names_to_clean_df <- function(clean_names_df = NULL) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'make_names_to_clean_df' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }


  # Handle invalid input gracefully
  if (is.null(clean_names_df) || !tibble::is_tibble(clean_names_df)) {
    return(tibble::tibble(
      student_id = character(),
      preferred_name = character(),
      transcript_name = character(),
      n = numeric()
    ))
  }
  # Use base R operations instead of dplyr to avoid segmentation fault
  # Filter for records with transcript_name but no student_id
  result <- clean_names_df[!is.na(clean_names_df$transcript_name) & is.na(clean_names_df$student_id), , drop = FALSE]

  # Group by student_id, preferred_name, transcript_name and count occurrences
  group_cols <- c("student_id", "preferred_name", "transcript_name")

  # Create a unique identifier for each group
  result$group_id <- apply(result[, group_cols], 1, paste, collapse = "|")

  # Count occurrences per group
  group_counts <- table(result$group_id)

  # Get the first row from each group (equivalent to summarise)
  result <- result[!duplicated(result$group_id), group_cols, drop = FALSE]

  # Add count column (n) - use actual group counts
  # Create group_id for the deduplicated result
  result$group_id <- apply(result[, group_cols], 1, paste, collapse = "|")
  result$n <- as.numeric(group_counts[result$group_id])

  # Remove temporary group_id column
  result$group_id <- NULL

  # Convert to tibble to maintain expected return type
  return(tibble::as_tibble(result))
}
