# Internal function - no documentation needed
create_course_info <- function(
    dept = NULL,
    course = NULL,
    section = NULL,
    instructor = NULL,
    session_length_hours = 1.5,
    semester_start_mdy = "Jan 01, 2024",
    semester_end_mdy = "May 15, 2024",
    session_days = NULL,
    session_times = NULL) {

  # Input validation
  if (length(unique(c(
    length(dept), length(course), length(section),
    length(instructor), length(session_length_hours)
  ))) != 1) {
    stop("All input vectors must have the same length")
  }

  if (!is.null(session_days) && length(session_days) != length(dept)) {
    stop("session_days must have the same length as other inputs")
  }

  if (!is.null(session_times) && length(session_times) != length(dept)) {
    stop("session_times must have the same length as other inputs")
  }

  # Create the tibble
  result <- tibble::tibble(
    dept = as.character(dept),
    course = as.character(course),
    section = as.character(section),
    instructor = as.character(instructor),
    session_length_hours = as.numeric(session_length_hours),
    semester_start = lubridate::mdy(semester_start_mdy),
    semester_end = lubridate::mdy(semester_end_mdy)
  )

  # Add optional session information
  if (!is.null(session_days)) {
    result$session_days <- as.character(session_days)
  }

  if (!is.null(session_times)) {
    result$session_times <- as.character(session_times)
  }

  # Add course identifier - using base R to avoid potential dplyr issues
  result$course_id <- paste(result$dept, result$course, result$section, sep = "_")
  result$course_name <- paste(result$dept, result$course, "Section", result$section)

  # Sort by department, course number, and section - using base R
  result[order(result$dept, result$course, result$section), ]
}
