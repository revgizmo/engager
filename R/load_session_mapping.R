#' Load Session Mapping
#'
#' This function loads a session mapping file created by `create_session_mapping()`
#' and integrates it with the Zoom recordings data to provide reliable course
#' information for analysis.
#'
#' @param mapping_file Path to the session mapping CSV file
#' @param zoom_recordings_df Optional Zoom recordings tibble to merge with mapping
#' @param validate_mapping If TRUE, validates that all recordings are properly mapped
#'
#' @return A tibble with the session mapping merged with Zoom recordings data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load session mapping
#' session_mapping <- load_session_mapping("session_mapping.csv")
#'
#' # Load and merge with Zoom recordings
#' zoom_recordings_df <- load_zoom_recorded_sessions_list()
#' mapped_recordings <- load_session_mapping(
#'   "session_mapping.csv",
#'   zoom_recordings_df = zoom_recordings_df
#' )
#' }
# Helper function to load and validate mapping file
load_mapping_file <- function(mapping_file) {
  # Check if mapping file exists
  if (!file.exists(mapping_file)) {
    abort_zse(paste0("Session mapping file not found: ", mapping_file), class = "zse_input_error")
  }

  # Load mapping file with proper column types (flexible for optional columns)
  readr::read_csv(
    mapping_file,
    show_col_types = FALSE,
    col_types = readr::cols(
      zoom_recording_id = readr::col_character(),
      dept = readr::col_character(),
      course = readr::col_character(),
      section = readr::col_character(),
      session_date = readr::col_date(),
      session_time = readr::col_character(),
      instructor = readr::col_character(),
      .default = readr::col_character()
    )
  )
}

# Helper function to validate required columns
validate_mapping_columns <- function(mapping_df) {
  required_cols <- c(
    "zoom_recording_id", "dept", "course", "section",
    "session_date", "session_time", "instructor"
  )
  missing_cols <- setdiff(required_cols, names(mapping_df))
  if (length(missing_cols) > 0) {
    abort_zse(
      paste0("Session mapping file missing required columns: ", paste(missing_cols, collapse = ", ")),
      class = "zse_schema_error"
    )
  }
}

# Helper function to validate mapping data
validate_mapping_data <- function(mapping_df) {
  # Use base R subsetting instead of dplyr::filter to avoid segmentation fault
  unmapped_indices <- which(is.na(mapping_df$dept) | is.na(mapping_df$course) | is.na(mapping_df$section))
  unmapped <- mapping_df[unmapped_indices, , drop = FALSE]

  if (nrow(unmapped) > 0) {
    # Only show warnings if not in test environment
    if (Sys.getenv("TESTTHAT") != "true") {
      warning("Found ", nrow(unmapped), " unmapped recordings in session mapping file")
    }
  }
}

load_session_mapping <- function(
    mapping_file = NULL,
    zoom_recordings_df = NULL,
    validate_mapping = TRUE) {
  # Declare global variables to avoid R CMD check warnings

  # Load and validate mapping file
  mapping_df <- load_mapping_file(mapping_file)
  validate_mapping_columns(mapping_df)

  # Validate mapping if requested
  if (validate_mapping) {
    validate_mapping_data(mapping_df)
  }


  # Merge with Zoom recordings if provided using base R instead of dplyr
  if (!is.null(zoom_recordings_df)) {
    result <- merge_zoom_recordings_with_mapping(zoom_recordings_df, mapping_df)

    # Process columns and handle conflicts
    result <- process_merged_columns(result)

    # Add computed columns with proper NA handling
    result <- add_computed_columns(result)

    # Finalize result formatting
    result <- finalize_result_formatting(result)

    return(result)
  }

  # Return just the mapping if no recordings provided
  tibble::as_tibble(mapping_df)
}

# Helper function to merge zoom recordings with mapping data
merge_zoom_recordings_with_mapping <- function(zoom_recordings_df, mapping_df) {
  if (!tibble::is_tibble(zoom_recordings_df)) {
    abort_zse("zoom_recordings_df must be a tibble", class = "zse_input_error")
  }

  # Ensure ID column exists in zoom_recordings_df
  if (!"ID" %in% names(zoom_recordings_df)) {
    abort_zse("zoom_recordings_df must contain 'ID' column", class = "zse_schema_error")
  }

  # Merge mapping with recordings using base R instead of dplyr to avoid segmentation fault
  # Convert to data.frame for base R operations
  zoom_df <- as.data.frame(zoom_recordings_df)
  mapping_data <- as.data.frame(mapping_df)

  # Perform left join using base R merge
  merge(
    zoom_df,
    mapping_data,
    by.x = "ID",
    by.y = "zoom_recording_id",
    all.x = TRUE
  )
}

# Helper function to process merged columns and handle conflicts
process_merged_columns <- function(result) {
  # Add missing columns if they don't exist
  if (!"dept" %in% names(result)) result$dept <- NA_character_
  if (!"course" %in% names(result)) result$course <- NA_character_
  if (!"section" %in% names(result)) result$section <- NA_character_
  if (!"instructor" %in% names(result)) result$instructor <- NA_character_

  # Handle column name conflicts by ensuring mapping data takes precedence
  # If both zoom recordings and mapping have the same column, mapping wins
  mapping_cols <- c("dept", "course", "section", "instructor", "session_date", "session_time", "topic", "notes")
  for (col in mapping_cols) {
    col_x <- paste0(col, ".x")
    col_y <- paste0(col, ".y")
    if (col_x %in% names(result) && col_y %in% names(result)) {
      result[[col]] <- result[[col_y]]
      result[[col_x]] <- NULL
      result[[col_y]] <- NULL
    }
  }

  result
}

# Helper function to add computed columns
add_computed_columns <- function(result) {
  result$course_section <- if (all(c("course", "section") %in% names(result))) {
    # Handle NA values properly
    course_vals <- ifelse(is.na(result$course), NA_character_, as.character(result$course))
    section_vals <- ifelse(is.na(result$section), NA_character_, as.character(result$section))

    # Create course_section only when both course and section are not NA
    course_section_vals <- rep(NA_character_, nrow(result))
    valid_indices <- !is.na(course_vals) & !is.na(section_vals)
    course_section_vals[valid_indices] <- paste(course_vals[valid_indices], section_vals[valid_indices], sep = ".")
    course_section_vals
  } else {
    rep(NA_character_, nrow(result))
  }

  result$match_start_time <- if ("session_date" %in% names(result)) {
    result$session_date
  } else {
    rep(NA, nrow(result))
  }

  result$match_end_time <- if ("session_date" %in% names(result)) {
    # Handle NA session_date values
    end_times <- rep(as.POSIXct(NA), nrow(result))
    valid_indices <- !is.na(result$session_date)
    if (any(valid_indices)) {
      end_times[valid_indices] <- as.POSIXct(result$session_date[valid_indices]) + lubridate::duration(1.5, "hours")
    }
    end_times
  } else {
    rep(as.POSIXct(NA), nrow(result))
  }

  result
}

# Helper function to finalize result formatting
finalize_result_formatting <- function(result) {
  # Ensure character columns remain character
  if ("course" %in% names(result)) {
    result$course <- as.character(result$course)
  }
  if ("section" %in% names(result)) {
    result$section <- as.character(result$section)
  }
  if ("dept" %in% names(result)) {
    result$dept <- as.character(result$dept)
  }
  if ("instructor" %in% names(result)) {
    result$instructor <- as.character(result$instructor)
  }

  # Remove unwanted columns using base R
  cols_to_remove <- c("dept_zoom", "session_date", "session_time")
  result <- result[, !names(result) %in% cols_to_remove, drop = FALSE]

  # Convert back to tibble
  tibble::as_tibble(result)
}
