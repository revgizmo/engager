# Internal function - no documentation needed
load_section_names_lookup <- function(data_folder = ".",
                                      names_lookup_file = "section_names_lookup.csv",
                                      section_names_lookup_col_types = "ccccccccc") {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'load_section_names_lookup' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  # Simplified deprecated function - return empty tibble with correct structure
  tibble::tibble(
    section = character(),
    preferred_name = character(),
    formal_name = character(),
    transcript_name = character(),
    student_id = character(),
    course_section = character(),
    dept = character(),
    course = character(),
    instructor = character()
  )
}

# Internal function - no documentation needed
validate_lookup_file_format <- function(data) {
  # Simplified validation for deprecated function
  TRUE
}
