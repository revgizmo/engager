#' Load a roster file
#'
#' @param data_folder Directory containing the roster file
#' @param roster_file Name of the roster CSV file
#' @param strict_errors Logical; if TRUE, throw error when file doesn't exist
#' @return A tibble with roster data, filtered by enrolled status if applicable
#' @export
load_roster <- function(
    data_folder = ".",
    roster_file = "roster.csv",
    strict_errors = FALSE) {
  # Handle case where first argument is a direct file path
  if (is.character(data_folder) && length(data_folder) == 1 && 
      file.exists(data_folder) && !dir.exists(data_folder)) {
    roster_file_path <- data_folder
  } else {
    roster_file_path <- file.path(data_folder, roster_file)
  }

  if (file.exists(roster_file_path)) {
    roster_data <- readr::read_csv(roster_file_path, show_col_types = FALSE)

    # Check if enrolled column exists and filter if it does
    if ("enrolled" %in% names(roster_data)) {
      # Use base R subsetting to avoid segmentation faults
      roster_data <- roster_data[roster_data$enrolled == TRUE, ]
    }

    roster_tbl <- tibble::as_tibble(roster_data)
    # Validate minimal roster schema where possible
    try(validate_schema(roster_tbl, zse_schema$roster$required), silent = TRUE)
    return(roster_tbl)
  } else {
    if (strict_errors) {
      # Throw error when file doesn't exist for enhanced error handling
      abort_zse(paste0("Roster file not found at `", roster_file_path, "`"), class = "zse_input_error")                                                         
    } else {
      # Return empty tibble with expected structure when file doesn't exist (backward compatibility)                                                            
      return(tibble::tibble())
    }
  }
}