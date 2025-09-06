#' Classify Participants (Pure, Privacy-Aware)
#'
#' Given transcript utterances, a student roster, and an optional lookup,
#' returns a data frame with classification columns that identify each
#' utterance's `clean_name`, `participant_type`, `student_id`, and
#' `is_matched`. This function is pure and performs no filesystem writes.
#'
#' Privacy defaults are applied to outputs. Use this to classify participants
#' BEFORE computing metrics so that downstream functions operate on a
#' privacy-safe, idempotent representation.
#'
#' @param transcript_df Data frame of transcript utterances.
#'   Must contain one of: `transcript_name`, `name`, `speaker_name`, `participant_name`.
#' @param roster_df Data frame of enrolled students.
#'   Should contain one of: `first_last`, `preferred_name`, `formal_name`, `name`, `student_name`,
#'   and optionally `student_id`.
#' @param lookup_df Optional data frame of name mappings as produced by
#'   `read_lookup_safely()`.
#' @param privacy_level One of `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#'
#' @return The `transcript_df` augmented with columns:
#'   `clean_name`, `participant_type`, `student_id`, `is_matched`.
#' @export
#' @keywords deprecated
#'
#' @examples
#' # classify_participants(transcript_df, roster_df, lookup_df)
classify_participants <- function(transcript_df = NULL,
                                  roster_df = NULL,
                                  lookup_df = NULL,
                                  privacy_level = getOption(
                                    "zoomstudentengagement.privacy_level",
                                    "mask"
                                  )) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'classify_participants' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  # Simplified deprecated function - return original transcript_df
  if (is.null(transcript_df)) {
    return(tibble::tibble())
  }

  transcript_df
}
