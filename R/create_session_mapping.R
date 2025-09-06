#' Create Session Mapping from Zoom Recordings and Course Information
#'
#' This function creates a mapping between Zoom recordings and course information
#' by matching recording topics with course patterns.
#'
#' @param zoom_recordings_df A tibble containing Zoom recording information with
#'   columns: ID, Topic, Start Time
#' @param course_info_df A tibble containing course information created by
#'   `create_course_info()` with columns: dept, course, section, instructor,
#'   session_length_hours
#' @param output_file Optional file path to save the mapping CSV file
#' @param semester_start_mdy Semester start date in "MMM DD, YYYY" format
#' @param auto_assign_patterns List of patterns for automatic assignment
#' @param interactive Whether to enable interactive assignment for unmatched recordings
#'   (prompts only shown in interactive sessions). In non-interactive sessions,
#'   a quiet fallback is used. Default is FALSE.
#' @param verbose Logical flag to enable diagnostic output. Defaults to FALSE.
#'
#' @return A tibble with session mapping information
#' @export
#' @keywords deprecated
#'
#' @examples
#' \dontrun{
#' # Create session mapping
#' session_mapping <- create_session_mapping(
#'   zoom_recordings_df = zoom_recordings,
#'   course_info_df = course_info,
#'   output_file = "session_mapping.csv",
#'   semester_start_mdy = "Jan 15, 2024"
#' )
#' }
create_session_mapping <- function(
    zoom_recordings_df = NULL,
    course_info_df = NULL,
    output_file = "session_mapping.csv",
    semester_start_mdy = "Jan 01, 2024",
    auto_assign_patterns = list(
      "CS 101" = "CS.*101",
      "MATH 250" = "MATH.*250",
      "LTF 201" = "LTF.*201"
    ),
    interactive = FALSE,
    verbose = FALSE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'create_session_mapping' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  # Simplified deprecated function - return empty tibble with correct structure
  tibble::tibble(
    zoom_recording_id = character(),
    dept = character(),
    course = character(),
    section = character(),
    session_date = as.Date(character()),
    session_time = character(),
    instructor = character(),
    topic = character(),
    notes = character()
  )
}
