#' Make Semester DF
#'
#' This function creates a tibble for the units in the semester that correspond
#' to expected number of units, with class start time, end time, and duration.
#'   to 14.
#'   'HH:MM:SS'. Defaults to '04:00:00'.
#'   Defaults to 14.
#'   and duration.
# make_semester_df()
make_semester_df <- function(semester_units = 14,
                             class_start_time_gmt = "04:00:00",
                             class_duration_min = 90) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'make_semester_df' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  start_time_gmt <- end_time_gmt <- NULL

  if (semester_units <= 0) {
    return(tibble::tibble(
      unit = integer(),
      start_time_gmt = hms::as_hms(character()),
      end_time_gmt = hms::as_hms(character()),
      duration = as.difftime(numeric(), units = "secs"),
      d2 = as.difftime(numeric(), units = "mins")
    ))
  }

  class_start_time_gmt <- hms::as_hms(class_start_time_gmt)
  class_end_time_gmt <- hms::as_hms(class_start_time_gmt + (class_duration_min * 60))

  tibble::tibble(
    unit = 1:semester_units,
    start_time_gmt = class_start_time_gmt,
    end_time_gmt = class_end_time_gmt,
    duration = end_time_gmt - start_time_gmt,
    d2 = base::difftime(end_time_gmt,
      start_time_gmt,
      units = c("mins")
    )
  )
}
