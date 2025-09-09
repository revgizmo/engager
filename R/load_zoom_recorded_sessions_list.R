#' Load Zoom Recorded Sessions List
#'
#' This function creates a tibble from a provided csv file of Zoom recordings.
#'
#' ## Download Zoom csv file with list of recordings and transcripts
#'
#' 1. Go to [https://www.zoom.us/recording](https://www.zoom.us/recording)
#'
#' 2. Export the Cloud Recordings
#' 3. Copy the cloud recording csv (naming convention:
#'    `zoomus_recordings__\\d{8}\.csv`) to `data/transcripts/`
#'    (or whatever path you identify in the `data_folder` and
#'    `transcripts_folder` parameters).
#'
#' @note The function handles several legacy and edge cases:
#' - Trailing commas in CSV headers (common in Zoom exports)
#' - Multiple recordings of the same session (takes the most recent)
#' - Timezone handling for session start/end times
#' - Department filtering for targeted recordings
#' - Date format variations in Zoom exports
#'
#' @param data_folder overall data folder for your recordings
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs
#' @param topic_split_pattern REGEX pattern used to parse the `Topic` from the
#'   csvs and extract useful columns. Defaults to
#'   `paste0("^(?<dept>\\\\S+) (?<course_section>\\\\S+) - ",
#'   "(?<day>[A-Za-z]+) (?<time>\\\\S+\\\\s*\\\\S+) (?<instructor>\\\\(.*?\\\\))")`
#'   (Note: this REGEX pattern is formatted here as paste0() rather than a
#'   single string to stay beneath the 90 character line limit in the code
#'   checker. A single string works just as well as this combined one). Note:
#'   The function now uses a generalized pattern that can handle various course
#'   naming conventions including `DATASCI 201.006`, `LTF 101`, and
#'   `MATH 250.001` formats.
#' @param zmrcrddsssnscsvnmspttrn REGEX pattern used to parse
#'   the csv file names from the cloud recording csvs and extract useful
#'   columns. Defaults to
#'   `zoomus_recordings__\\\\d{8}(?:\\\\s+copy\\\\s*\\\\d*)?\\\\.csv`
#' @param zmrcrddsssnscsvclnms Comma separated string of column
#'   names in the cloud recording csvs. Zoom tends to save the file with an
#'   extra `,` at the end of the header row, causing a null column to be
#'   imported. Defaults to
#'   `Topic,ID,Start Time,File Size (MB),File Count,Total Views,Total Downloads,Last Accessed`
#' @param dept the school department associated with the recordings to keep.
#'   Zoom often captures unwanted recordings, and this is used to filter only
#'   the targeted ones. This value is compared to the `dept` column extracted
#'   from the `Topic` column extracted from cloud recording csvs. Defaults to
#'   `LTF`
#' @param semester_start_mdy date of the first class in the semester. Defaults
#'   to `Jan 01, 2024`
#' @param scheduled_session_length_hours scheduled length of each class session
#'   in hours. Defaults to `1.5`
#' @param verbose Logical flag to enable diagnostic output. Defaults to FALSE.
#'
#' @return A tibble listing the session recordings loaded from the cloud
#'   recording csvs. Returns `NULL` if the transcripts folder doesn't exist,
#'   or an empty tibble with the correct column structure if no matching
#'   files are found.
#'
#' @export
#'
#' @examples
#' # Show what happens when no data files exist (returns empty tibble)
#' load_zoom_recorded_sessions_list(
#'   data_folder = "nonexistent_folder",
#'   transcripts_folder = "transcripts"
#' )
#'
#' \dontrun{
#' # Load actual Zoom recordings data (requires data files)
#' # Requires a Zoom cloud recordings CSV in the appropriate folder, e.g.:
#' # inst/extdata/transcripts/zoomus_recordings__20240124.csv
#' load_zoom_recorded_sessions_list(
#'   data_folder = system.file("extdata", package = "zoomstudentengagement"),
#'   transcripts_folder = "transcripts"
#' )
#' }
load_zoom_recorded_sessions_list <-
  function(data_folder = ".",
           transcripts_folder = "transcripts",
           topic_split_pattern =
             paste0(
               "^(?<dept>\\S+) (?<course_section>\\S+) - ",
               "(?<day>[A-Za-z]+) (?<time>\\S+\\s*\\S+) (?<instructor>\\(.*?\\))"
             ),
           zmrcrddsssnscsvnmspttrn =
             "zoomus_recordings__\\d{8}(?:\\s+copy\\s*\\d*)?\\.csv",
           zmrcrddsssnscsvclnms = paste(
             "Topic",
             "ID",
             "Start Time",
             "File Size (MB)",
             "File Count",
             "Total Views",
             "Total Downloads",
             "Last Accessed",
             sep = ","
           ),
           dept = "LTF",
           semester_start_mdy = "Jan 01, 2024",
           scheduled_session_length_hours = 1.5,
           verbose = FALSE) {
    # Declare global variables to avoid R CMD check warnings
    # nolint start: object_name_linter
    . <- `Topic` <- `ID` <- `Start Time` <- `File Size (MB)` <- `File Count` <- `Total Views` <- NULL
    # nolint end: object_name_linter

    # Setup and validation
    setup_result <- setup_zoom_sessions_loading(
      data_folder, transcripts_folder,
      zmrcrddsssnscsvclnms,
      zmrcrddsssnscsvnmspttrn
    )
    if (is.null(setup_result)) {
      return(NULL)
    }

    if (setup_result$no_files) {
      return(create_empty_zoom_tibble())
    }

    # Load and process CSV data
    result <- load_and_process_zoom_csvs(setup_result, verbose)
    if (nrow(result) == 0) {
      return(tibble::tibble())
    }

    # Aggregate duplicate records
    result <- aggregate_zoom_sessions_data(result, verbose)

    # Parse topic components and process dates
    result <- parse_topic_components(result, topic_split_pattern, verbose)
    result <- process_session_times(result, scheduled_session_length_hours, verbose)

    # Filter by department if specified
    result <- filter_by_department(result, dept, verbose)

    tibble::as_tibble(result)
  }

# Helper function to setup zoom sessions loading
setup_zoom_sessions_loading <- function(data_folder, transcripts_folder,
                                        csv_col_names,
                                        csv_names_pattern) {
  # Handle trailing comma in column names
  csv_col_names_vector <-
    strsplit(csv_col_names, ",")[[1]] %>%
    stringr::str_trim() %>%
    Filter(function(x) x != "", .)

  transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")

  if (!file.exists(transcripts_folder_path)) {
    return(NULL)
  }

  term_files <- list.files(transcripts_folder_path)
  csv_names <-
    term_files[grepl(csv_names_pattern, term_files, fixed = FALSE)]

  list(
    transcripts_folder_path = transcripts_folder_path,
    csv_names = csv_names,
    csv_col_names_vector = csv_col_names_vector,
    no_files = length(csv_names) == 0
  )
}

# Helper function to create empty zoom sessions tibble
create_empty_zoom_tibble <- function() {
  tibble::tibble(
    Topic = character(),
    ID = character(),
    `Start Time` = character(),
    `File Size (MB)` = numeric(),
    `File Count` = numeric(),
    `Total Views` = numeric(),
    `Total Downloads` = numeric(),
    `Last Accessed` = character(),
    dept = character(),
    course_section = character(),
    day = character(),
    time = character(),
    instructor = character(),
    match_start_time = as.POSIXct(character(), tz = "America/Los_Angeles"),
    match_end_time = as.POSIXct(character(), tz = "America/Los_Angeles")
  )
}

# Helper function to load and process zoom CSVs
load_and_process_zoom_csvs <- function(setup_result, verbose) {
  .verbose <- isTRUE(verbose) || is_verbose()
  if (.verbose) {
    diag_message("CSV files to process:")
    diag_message(paste(setup_result$csv_names, collapse = "\n"))
  }

  result <- setup_result$csv_names %>%
    paste0(setup_result$transcripts_folder_path, .) %>%
    readr::read_csv(
      id = "filepath",
      col_names = setup_result$csv_col_names_vector,
      col_types = readr::cols(
        Topic = readr::col_character(),
        ID = readr::col_character(),
        `Start Time` = readr::col_character(),
        `File Size (MB)` = readr::col_character(),
        `File Count` = readr::col_double(),
        `Total Views` = readr::col_double(),
        `Total Downloads` = readr::col_double(),
        `Last Accessed` = readr::col_character()
      ),
      skip = 1,
      quote = "\"",
      show_col_types = FALSE
    )

  if (.verbose) {
    diag_message("After reading CSV:")
    diag_message(paste(utils::capture.output(utils::str(result)), collapse = "\n"))
  }

  result
}

# Helper function to aggregate zoom sessions data
aggregate_zoom_sessions_data <- function(result, verbose) {
  .verbose <- isTRUE(verbose) || is_verbose()

  # Use base R operations instead of dplyr to avoid segmentation fault
  # Group by the specified columns and take max values
  group_cols <- c("Topic", "ID", "Start Time", "File Size (MB)", "File Count")

  # Create a unique identifier for each group
  result$group_id <- apply(result[, group_cols], 1, paste, collapse = "|")

  # Aggregate using base R
  aggregated_data <- stats::aggregate(
    result[, c("Total Views", "Total Downloads", "Last Accessed")],
    by = list(group_id = result$group_id),
    FUN = function(x) if (is.character(x)) x[which.max(nchar(x))] else max(x, na.rm = TRUE)
  )

  # Get the first row from each group for the grouping columns
  group_data <- result[!duplicated(result$group_id), group_cols, drop = FALSE]
  group_data$group_id <- result$group_id[!duplicated(result$group_id)]

  # Merge the aggregated data with the group data
  result <- merge(group_data, aggregated_data, by = "group_id", all.x = TRUE)
  result$group_id <- NULL # Remove the temporary group_id column

  if (.verbose) {
    diag_message("After summarise:")
    diag_message(paste(utils::capture.output(utils::str(result)), collapse = "\n"))
  }

  result
}

# Helper function to parse topic components
parse_topic_components <- function(result, topic_split_pattern, verbose) {
  .verbose <- isTRUE(verbose) || is_verbose()

  # Convert named capture groups to plain groups for compatibility if needed
  pattern_plain <- gsub("\\(\\?<[^>]+>", "(", topic_split_pattern, perl = TRUE)
  topic_components <- tryCatch(
    stringr::str_match(result$Topic, topic_split_pattern),
    error = function(e) stringr::str_match(result$Topic, pattern_plain)
  )

  # Assign dept and course_section from either named or positional groups
  if (!is.null(colnames(topic_components)) && any(colnames(topic_components) == "dept")) {
    result$dept <- topic_components[, "dept"]
    result$course_section <- topic_components[, "course_section"]
  } else {
    result$dept <- topic_components[, 2]
    result$course_section <- topic_components[, 3]
  }

  # Split course and section if course_section has a dot format (e.g., 201.006)
  split_course_section <- strsplit(result$course_section, ".", fixed = TRUE)
  result$course <- sapply(split_course_section, function(x) x[1])
  result$section <- sapply(split_course_section, function(x) ifelse(length(x) > 1, x[2], NA))

  # Coerce course/section to integers where possible
  result$course <- suppressWarnings(as.integer(result$course))
  result$section <- suppressWarnings(as.integer(result$section))

  if (.verbose) {
    diag_message("After topic parsing:")
    diag_message(paste(utils::capture.output(utils::str(result)), collapse = "\n"))
  }

  result
}

# Helper function to process session times
process_session_times <- function(result, scheduled_session_length_hours, verbose) {
  .verbose <- isTRUE(verbose) || is_verbose()

  # Extract start time values as strings
  start_time_values <- result$`Start Time`
  if (.verbose) {
    diag_message("Start Time values:")
    diag_message(paste(start_time_values, collapse = "\n"))
  }

  # Parse dates using multiple formats in America/Los_Angeles tz
  parsed_dates <- lubridate::parse_date_time(
    start_time_values,
    orders = c("b d, Y I:M:S p", "b d, Y I:M p"),
    tz = "America/Los_Angeles"
  )
  result$`Start Time` <- start_time_values

  result$match_start_time <- parsed_dates
  # Add scheduled session length plus a 0.5 hour buffer, per tests
  result$match_end_time <- result$match_start_time +
    lubridate::dhours(scheduled_session_length_hours) + lubridate::dminutes(30)

  if (.verbose) {
    diag_message("After date parsing:")
    diag_message(paste(utils::capture.output(utils::str(result)), collapse = "\n"))
  }

  result
}

# Helper function to filter by department
filter_by_department <- function(result, dept, verbose) {
  .verbose <- isTRUE(verbose) || is_verbose()

  # Optionally filter rows to those matching department, if provided
  if (!is.null(dept) && nzchar(dept)) {
    result <- result[!is.na(result$dept) & result$dept == dept, ]
  }

  if (.verbose) {
    diag_message("Final result after filtering:")
    diag_message(paste(utils::capture.output(utils::str(result)), collapse = "\n"))
  }

  result
}
