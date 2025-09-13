#' Load Cancelled Classes csv file
#'
#' This function creates a tibble from a provided csv file of cancelled class
#' sessions for scheduled classes where a zoom recording is not expected.
#'
#'   to 'data'
#'   Defaults to 'cancelled_classes.csv'
#'   classes. Defaults to 'ccccccccnnnncTTcTTccci'
#'   creates a blank cancelled classes file. Defaults to FALSE
#'
#'   where a zoom recording is not expected.
#'
#' @importFrom magrittr %>%
load_cancelled_classes <- function(data_folder = ".",
           cancelled_classes_file = "cancelled_classes.csv",
           cancelled_classes_col_types = "ccccccccnnnncTTcTTccci",
           write_blank_cancelled_classes = FALSE) {
    cancelled_classes_file_path <-
      paste0(data_folder, "/", cancelled_classes_file)

    # Check if the file exists
    if (file.exists(cancelled_classes_file_path)) {
      # File exists, proceed with importing it
      data <- readr::read_csv(cancelled_classes_file_path,
        col_types = cancelled_classes_col_types,
        show_col_types = FALSE
      )
    } else {
      # File doesn't exist, handle the situation accordingly
      warning(paste("File does not exist:", cancelled_classes_file_path))
      data <- make_blank_cancelled_classes_df()

      if (write_blank_cancelled_classes && !file.exists(cancelled_classes_file_path)) {
        data %>%
          readr::write_csv(paste0(data_folder, "/", cancelled_classes_file))
      } else if (!write_blank_cancelled_classes) {
        # keep returning blank template to preserve legacy behavior
      }
    }

    tibble::as_tibble(data)
  }
