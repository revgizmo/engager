#' Export Ideal Course Transcripts to CSV
#'
#' Exports ideal course transcript data to CSV format with privacy protection
#' and comprehensive metadata.
#'
#' @param transcript_data Data frame containing transcript data
#' @param file_path Character. Output file path. If NULL, generates default name
#' @param privacy_level Character. Privacy level for data masking. Default from option
#' @param include_metadata Logical. Whether to include metadata in export. Default: TRUE
#' @return Invisibly returns the exported data frame
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' # Export with default settings
#' export_ideal_transcripts_csv(transcript_data)
#'
#' # Export with custom privacy level
#' export_ideal_transcripts_csv(
#'   transcript_data,
#'   file_path = "my_transcript.csv",
#'   privacy_level = "full"
#' )
#' }
export_ideal_transcripts_csv <- function(
    transcript_data = NULL,
    file_path = NULL,
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"),
    include_metadata = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'export_ideal_transcripts_csv' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Validate inputs
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }

  if (!tibble::is_tibble(transcript_data) && !is.data.frame(transcript_data)) {
    stop("transcript_data must be a tibble or data frame")
  }

  # Apply privacy protection
  export_data <- zoomstudentengagement::ensure_privacy(
    transcript_data,
    privacy_level = privacy_level
  )

  # Add metadata if requested
  if (include_metadata) {
    export_data <- add_export_metadata(export_data, format = "csv")
  }

  # Determine output path
  if (is.null(file_path)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    file_path <- paste0("ideal_transcript_export_", timestamp, ".csv")
  }

  # Create directory if needed
  dir_path <- dirname(file_path)
  if (dir_path != "." && !dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }

  # Write CSV file
  utils::write.csv(export_data, file_path, row.names = FALSE)

  invisible(file_path)
}

#' Export Ideal Course Transcripts to JSON
#'
#' Exports ideal course transcript data to JSON format with structured output
#' and privacy protection.
#'
#' @param transcript_data Data frame containing transcript data
#' @param file_path Character. Output file path. If NULL, generates default name
#' @param privacy_level Character. Privacy level for data masking. Default from option
#' @param pretty_print Logical. Whether to format JSON with indentation. Default: TRUE
#' @param include_metadata Logical. Whether to include metadata. Default: TRUE
#' @return Invisibly returns the exported data as list
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' # Export with default settings
#' export_ideal_transcripts_json(transcript_data)
#'
#' # Export with custom formatting
#' export_ideal_transcripts_json(
#'   transcript_data,
#'   pretty_print = FALSE,
#'   include_metadata = FALSE
#' )
#' }
export_ideal_transcripts_json <- function(
    transcript_data = NULL,
    file_path = NULL,
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"),
    pretty_print = TRUE,
    include_metadata = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'export_ideal_transcripts_json' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Validate inputs
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }

  if (!tibble::is_tibble(transcript_data) && !is.data.frame(transcript_data)) {
    stop("transcript_data must be a tibble or data frame")
  }

  # Apply privacy protection
  export_data <- zoomstudentengagement::ensure_privacy(
    transcript_data,
    privacy_level = privacy_level
  )

  # Convert to list structure
  json_data <- list(
    transcript_data = as.list(export_data),
    export_info = list(
      timestamp = Sys.time(),
      format = "json",
      privacy_level = privacy_level,
      row_count = nrow(export_data),
      column_count = ncol(export_data)
    )
  )

  # Add metadata if requested
  if (include_metadata) {
    json_data$metadata <- generate_export_metadata(export_data, format = "json")
  }

  # Determine output path
  if (is.null(file_path)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    file_path <- paste0("ideal_transcript_export_", timestamp, ".json")
  }

  # Create directory if needed
  dir_path <- dirname(file_path)
  if (dir_path != "." && !dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }

  # Write JSON file
  jsonlite::write_json(
    json_data,
    file_path,
    pretty = pretty_print,
    auto_unbox = TRUE
  )

  invisible(file_path)
}

#' Export Ideal Course Transcripts to Excel (Temporarily CSV)
#'
#' Exports ideal course transcript data to CSV format as a temporary workaround
#' for Excel export segfault issues. This function temporarily creates CSV files
#' instead of Excel files due to openxlsx package segfault problems.
#'
#' @param transcript_data Data frame containing transcript data
#' @param file_path Character. Output file path. If NULL, generates default name
#' @param privacy_level Character. Privacy level for data masking. Default from option
#' @param include_summary_sheet Logical. Whether to include summary sheet. Default: TRUE
#' @param include_metadata_sheet Logical. Whether to include metadata sheet. Default: TRUE
#' @return Invisibly returns the file path (CSV format due to temporary workaround)
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' # Export with default settings (creates CSV file)
#' export_ideal_transcripts_excel(transcript_data)
#'
#' # Export with custom sheets (creates separate CSV files)
#' export_ideal_transcripts_excel(
#'   transcript_data,
#'   include_summary_sheet = FALSE,
#'   include_metadata_sheet = TRUE
#' )
#' }
#' @note
#' This function temporarily exports to CSV format instead of Excel due to
#' segfault issues with the openxlsx package. The function name is maintained
#' for backward compatibility, but it creates CSV files with appropriate
#' extensions. Summary and metadata sheets are created as separate CSV files
#' when requested.
export_ideal_transcripts_excel <- function(
    transcript_data = NULL,
    file_path = NULL,
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"),
    include_summary_sheet = TRUE,
    include_metadata_sheet = TRUE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'export_ideal_transcripts_excel' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Validate inputs
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }

  if (!tibble::is_tibble(transcript_data) && !is.data.frame(transcript_data)) {
    stop("transcript_data must be a tibble or data frame")
  }

  # Apply privacy protection
  export_data <- zoomstudentengagement::ensure_privacy(
    transcript_data,
    privacy_level = privacy_level
  )

  # Convert to data frame and ensure all columns are simple types
  export_data <- as.data.frame(export_data, stringsAsFactors = FALSE)

  # Convert list columns to character strings
  for (col in names(export_data)) {
    if (is.list(export_data[[col]])) {
      export_data[[col]] <- sapply(export_data[[col]], function(x) {
        if (is.null(x)) {
          return(NA_character_)
        }
        if (length(x) == 0) {
          return(NA_character_)
        }
        paste(as.character(x), collapse = "; ")
      })
    }
  }

  # Ensure all columns are atomic types that openxlsx can handle
  for (col in names(export_data)) {
    if (!is.atomic(export_data[[col]])) {
      export_data[[col]] <- as.character(export_data[[col]])
    }
  }

  # Convert any remaining complex types to character
  export_data <- data.frame(
    lapply(export_data, function(x) {
      if (is.factor(x)) {
        as.character(x)
      } else if (is.list(x)) {
        sapply(x, function(y) if (is.null(y)) NA_character_ else as.character(y))
      } else {
        x
      }
    }),
    stringsAsFactors = FALSE
  )

  # Determine output path first
  if (is.null(file_path)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    file_path <- paste0("ideal_transcript_export_", timestamp, ".xlsx")
  }

  # Ensure file_path is not empty
  if (file_path == "" || is.na(file_path)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    file_path <- paste0("ideal_transcript_export_", timestamp, ".xlsx")
  }

  # Create directory if needed
  dir_path <- dirname(file_path)
  if (dir_path != "." && !dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }

  # TEMPORARILY DISABLED: Excel workbook creation due to segfault issues
  # wb <- openxlsx::createWorkbook()
  # openxlsx::addWorksheet(wb, "Transcript Data")

  # TEMPORARY WORKAROUND: Skip Excel export due to segfault issues
  # Create a CSV file instead of Excel to avoid openxlsx segfault
  warning("Excel export temporarily disabled due to segfault issues. Creating CSV file instead.")

  # Create CSV file as alternative
  csv_file <- gsub("\\.xlsx$", ".csv", file_path)
  utils::write.csv(export_data, csv_file, row.names = FALSE)

  # Create a simple text file explaining the situation
  info_file <- gsub("\\.xlsx$", "_info.txt", file_path)
  info_content <- c(
    "Excel export temporarily disabled due to segfault issues.",
    "Data has been exported to CSV format instead.",
    paste("CSV file:", csv_file),
    paste("Timestamp:", Sys.time()),
    "",
    "To re-enable Excel export, the openxlsx package segfault issue must be resolved."
  )
  writeLines(info_content, info_file)

  # Return the CSV file path instead of Excel file path
  # Note: This function now returns a CSV file due to Excel segfault issues
  # But we need to maintain the original file_path for backward compatibility
  # The actual CSV file is created at csv_file, but we return the original path
  # This allows tests to still expect .xlsx files while we create .csv files

  # Add summary sheet if requested (temporarily disabled due to segfault)
  if (include_summary_sheet) {
    warning("Summary sheet temporarily disabled due to Excel segfault issues")
    # Create summary as separate CSV file
    summary_data <- generate_transcript_summary(export_data)
    if (is.data.frame(summary_data)) {
      summary_csv_file <- gsub("\\.xlsx$", "_summary.csv", file_path)
      utils::write.csv(summary_data, summary_csv_file, row.names = FALSE)
    }
  }

  # Add metadata sheet if requested (temporarily disabled due to segfault)
  if (include_metadata_sheet) {
    warning("Metadata sheet temporarily disabled due to Excel segfault issues")
    # Create metadata as separate CSV file
    metadata_data <- generate_export_metadata(export_data, format = "excel")
    if (is.data.frame(metadata_data)) {
      metadata_csv_file <- gsub("\\.xlsx$", "_metadata.csv", file_path)
      utils::write.csv(metadata_data, metadata_csv_file, row.names = FALSE)
    }
  }



  # TEMPORARILY DISABLED: Excel workbook saving due to segfault issues
  # openxlsx::saveWorkbook(wb, file_path, overwrite = TRUE)

  # Return the actual CSV file path since we're creating CSV instead of Excel
  invisible(csv_file)
}

#' Export Ideal Course Transcripts Summary Report
#'
#' Creates and exports summary reports for ideal course transcripts in multiple
#' formats with key metrics and insights. Note: Excel export temporarily creates
#' CSV files due to openxlsx segfault issues.
#'
#' @param transcript_data Data frame containing transcript data
#' @param file_path Character. Output file path. If NULL, generates default name
#' @param format Character. Output format: "csv", "json", or "excel". Default: "csv"
#' @param privacy_level Character. Privacy level for data masking. Default from option
#' @param include_charts Logical. Whether to include charts (Excel only). Default: FALSE
#' @return Invisibly returns the summary data
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
#' @examples
#' \dontrun{
#' # Export summary as CSV
#' export_ideal_transcripts_summary(transcript_data, format = "csv")
#'
#' # Export summary as Excel with charts
#' export_ideal_transcripts_summary(
#'   transcript_data,
#'   format = "excel",
#'   include_charts = TRUE
#' )
#' }
export_ideal_transcripts_summary <- function(
    transcript_data = NULL,
    file_path = NULL,
    format = c("csv", "json", "excel"),
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"),
    include_charts = FALSE) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'export_ideal_transcripts_summary' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Validate inputs
  if (is.null(transcript_data)) {
    stop("transcript_data cannot be NULL")
  }

  if (!tibble::is_tibble(transcript_data) && !is.data.frame(transcript_data)) {
    stop("transcript_data must be a tibble or data frame")
  }

  format <- match.arg(format)

  # Apply privacy protection
  export_data <- zoomstudentengagement::ensure_privacy(
    transcript_data,
    privacy_level = privacy_level
  )

  # Generate summary data
  summary_data <- generate_transcript_summary(export_data)

  # Determine output path
  if (is.null(file_path)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    file_path <- paste0("ideal_transcript_summary_", timestamp, ".", format)
  }

  # Export based on format
  if (format == "csv") {
    utils::write.csv(summary_data, file_path, row.names = FALSE)
  } else if (format == "json") {
    json_data <- list(
      summary_data = as.list(summary_data),
      export_info = list(
        timestamp = Sys.time(),
        format = "json",
        privacy_level = privacy_level
      )
    )
    jsonlite::write_json(json_data, file_path, pretty = TRUE, auto_unbox = TRUE)
  } else if (format == "excel") {
    # TEMPORARY WORKAROUND: Skip Excel export due to segfault issues
    # Create a CSV file instead of Excel to avoid openxlsx segfault
    warning("Excel export temporarily disabled due to segfault issues. Creating CSV file instead.")

    # Create CSV file as alternative
    csv_file <- gsub("\\.xlsx$", ".csv", file_path)
    utils::write.csv(summary_data, csv_file, row.names = FALSE)

    # Create a simple text file explaining the situation
    info_file <- gsub("\\.xlsx$", "_info.txt", file_path)
    info_content <- c(
      "Excel export temporarily disabled due to segfault issues.",
      "Summary data has been exported to CSV format instead.",
      paste("CSV file:", csv_file),
      paste("Timestamp:", Sys.time()),
      "",
      "To re-enable Excel export, the openxlsx package segfault issue must be resolved."
    )
    writeLines(info_content, info_file)

    # Return the CSV file path instead of Excel file path
    file_path <- csv_file
  }

  invisible(file_path)
}

#' Add Export Metadata
#' @keywords internal
add_export_metadata <- function(data, format = "csv") {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'add_export_metadata' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Add export timestamp and format info
  data$export_timestamp <- Sys.time()
  data$export_format <- format
  data$export_version <- "1.0.0"
  return(data)
}

#' Generate Export Metadata
#' @keywords internal
generate_export_metadata <- function(data, format = "csv") {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'generate_export_metadata' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  metadata <- list(
    export_timestamp = Sys.time(),
    export_format = format,
    export_version = "1.0.0",
    row_count = nrow(data),
    column_count = ncol(data),
    column_names = names(data),
    data_types = sapply(data, class)
  )
  return(metadata)
}

#' Generate Transcript Summary
#' @keywords internal
generate_transcript_summary <- function(data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'generate_transcript_summary' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  summary_data <- list(
    total_rows = nrow(data),
    total_columns = ncol(data),
    unique_speakers = if ("name" %in% names(data)) length(unique(data$name)) else NA,
    time_range = if (all(c("start", "end") %in% names(data))) {
      paste(min(data$start), "to", max(data$end))
    } else {
      NA
    },
    export_timestamp = Sys.time()
  )

  return(as.data.frame(summary_data))
}

#' Add Summary Charts to Excel Workbook
#' @keywords internal
add_summary_charts <- function(wb, summary_data) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'add_summary_charts' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  # Add basic charts if summary data is available
  # This is a placeholder for future chart functionality
  # Chart functionality not yet implemented
}
