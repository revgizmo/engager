#' @importFrom magrittr %>%
# Internal function - no documentation needed
load_cancelled_classes <- function(data_folder = NULL,
                                   cancelled_classes_file = "cancelled_classes.csv",
                                   cancelled_classes_col_types = "ccccccccnnnncTTcTTccci",
                                   write_blank_cancelled_classes = FALSE) {
  if (!is.null(data_folder) &&
      (!is.character(data_folder) || length(data_folder) != 1L ||
        is.na(data_folder) || !nzchar(trimws(data_folder)))) {
    stop(
      "`data_folder` must be NULL or an explicit non-empty directory path.",
      call. = FALSE
    )
  }
  if (!is.character(cancelled_classes_file) ||
      length(cancelled_classes_file) != 1L ||
      is.na(cancelled_classes_file) ||
      !nzchar(trimws(cancelled_classes_file))) {
    stop(
      "`cancelled_classes_file` must be one explicit non-empty file name.",
      call. = FALSE
    )
  }
  if (isTRUE(write_blank_cancelled_classes) &&
      is.null(data_folder)) {
    stop(
      "`data_folder` must be supplied when `write_blank_cancelled_classes = TRUE`.",
      call. = FALSE
    )
  }

  cancelled_classes_file_path <- if (is.null(data_folder)) {
    NULL
  } else {
    file.path(data_folder, cancelled_classes_file)
  }

  # Check if the file exists
  if (!is.null(cancelled_classes_file_path) && file.exists(cancelled_classes_file_path)) {
    # File exists, proceed with importing it
    data <- readr::read_csv(cancelled_classes_file_path,
      col_types = cancelled_classes_col_types,
      show_col_types = FALSE
    )
  } else {
    # File doesn't exist, handle the situation accordingly
    if (!is.null(cancelled_classes_file_path)) {
      warning(paste("File does not exist:", cancelled_classes_file_path))
    }
    data <- make_blank_cancelled_classes_df()

    if (write_blank_cancelled_classes && !file.exists(cancelled_classes_file_path)) {
      data %>%
        readr::write_csv(cancelled_classes_file_path)
    } else if (!write_blank_cancelled_classes) {
      # keep returning blank template to preserve legacy behavior
    }
  }

  tibble::as_tibble(data)
}
