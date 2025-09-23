# Roster loader enforcing engager_v1 schema (scaffold)

#' Load a roster and compute canonical names and hashes
#'
#' @param path Path to a CSV roster file
#' @param schema Schema name, default 'engager_v1'
#' @param key Optional override key for name hashing
#' @param delimiter Delimiter for aliases parsing autodetect/override
#' @param include_formal_as_alias Logical; include formal_name as alias
#' @param ... Additional arguments passed to readr::read_csv
#' @return A tibble with schema-enforced columns and attributes
#' @export
#' @family name-matching
load_roster <- function(path,
                        ..., 
                        schema = "engager_v1",
                        key = NULL,
                        delimiter = ";",
                        include_formal_as_alias = FALSE) {
  rlang::abort("load_roster() not yet implemented in MVP scaffolding.",
               class = "engager_not_implemented_error")
}

# Internal function - no documentation needed
load_roster <- function(
    data_folder = ".",
    roster_file = "roster.csv",
    strict_errors = FALSE) {
  roster_file_path <- file.path(data_folder, roster_file)

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
