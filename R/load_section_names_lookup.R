# Internal function - no documentation needed
load_section_names_lookup <- function(data_folder = ".",
                                      names_lookup_file = "section_names_lookup.csv",
                                      section_names_lookup_col_types = "ccccccccc") {
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
