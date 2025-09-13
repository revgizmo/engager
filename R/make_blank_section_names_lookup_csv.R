#' Create Blank Section Names Lookup Template
#'
#' Creates an empty tibble template for customizing student names by section.
#' This function generates a properly structured data frame that can be filled in
#' to map between different name formats (preferred names, formal names, transcript names)
#' for students across different course sections.

make_blank_section_names_lookup_csv <- function() {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'make_blank_section_names_lookup_csv' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  readr::read_csv(
    I("course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id"),
    col_types = readr::cols(
      course_section = readr::col_character(),
      day = readr::col_character(),
      time = readr::col_character(),
      course = readr::col_character(),
      section = readr::col_character(),
      preferred_name = readr::col_character(),
      formal_name = readr::col_character(),
      transcript_name = readr::col_character(),
      student_id = readr::col_character()
    )
  )
}
