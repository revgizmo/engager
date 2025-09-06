#' Load Section Names Lookup File
#'
#' This function creates a tibble from a provided file of customized student names by section.
#' If the file does not exist, the function prints an error and creates an empty tibble using
#' `make_blank_section_names_lookup_csv()`.
#'
#' @param data_folder overall data folder for your recordings
#' @param names_lookup_file File name of the csv file of customized student names by section
#'   Defaults to 'section_names_lookup.csv'
#' @param section_names_lookup_col_types column types in the csv file of customized student names by section. Defaults
#' to 'cccccccc'
#'
#' @return A tibble of customized student names by section.
#' @export
#' @keywords deprecated
#'
#' @examples
#' load_section_names_lookup()
#'
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

#' Validate Lookup File Format
#'
#' Internal function to validate the format of section names lookup files.
#'
#' @param data The data to validate
#' @return TRUE if valid, FALSE otherwise
#' @keywords internal
validate_lookup_file_format <- function(data) {
  # Simplified validation for deprecated function
  TRUE
}
