#' Plot Users
#'
#' Unified plotting function for engagement metrics with privacy-aware options.
#'
#' @param data A tibble containing the data to plot
#' @param metric Column name for the metric to plot (default: "session_ct")
#' @param student_col Column name for student identification (default: "name")
#' @param facet_by Faceting option: "section", "transcript_file", or "none" (default: "section")
#' @param mask_by Masking option: "name" or "rank" (default: "name")
#' @param privacy_level Privacy level for data visualization (default: from global option)
#' @param metrics_lookup_df Optional lookup table for metric names (default: NULL)
#' @return A ggplot2 object
#'
#' @export
plot_users <- function(
    data = NULL,
    metric = "session_ct",
    student_col = "name",
    facet_by = c("section", "transcript_file", "none"),
    mask_by = c("name", "rank"),
    privacy_level = getOption("zoomstudentengagement.privacy_level", "mask"),
    metrics_lookup_df = NULL) {
  facet_by <- match.arg(facet_by)
  mask_by <- match.arg(mask_by)

  # Validate and prepare data
  validation_result <- validate_plot_users_inputs(data, metric, student_col)
  data <- validation_result$data
  metric <- validation_result$metric
  student_col <- validation_result$student_col

  # Apply privacy masking if needed
  if (privacy_level != "none") {
    data <- apply_privacy_masking_plot(data, privacy_level, student_col, mask_by)
  }

  # Create the plot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = !!rlang::sym(student_col), y = !!rlang::sym(metric))) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = paste("Engagement by", metric),
      x = "Student",
      y = metric
    )

  # Add faceting if requested
  if (facet_by != "none" && facet_by %in% names(data)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet_by)))
  }

  return(p)
}

# Helper function to validate inputs
validate_plot_users_inputs <- function(data, metric, student_col) {
  if (is.null(data) || nrow(data) == 0) {
    stop("Data must be provided and non-empty")
  }

  if (!metric %in% names(data)) {
    stop("Metric column '", metric, "' not found in data")
  }

  if (!student_col %in% names(data)) {
    stop("Student column '", student_col, "' not found in data")
  }

  return(list(data = data, metric = metric, student_col = student_col))
}

# Helper function to apply privacy masking
apply_privacy_masking_plot <- function(data, privacy_level, student_col, mask_by) {
  # CRAN FIX: Handle vector privacy_level input to prevent "condition has length > 1" error
  # This was causing 100+ test failures and preventing CRAN submission

  # Validate inputs
  if (!is.character(privacy_level) || length(privacy_level) == 0) {
    stop("privacy_level must be a non-empty character vector")
  }

  # Handle vector input gracefully
  if (length(privacy_level) > 1) {
    privacy_level <- privacy_level[1]
    warning("privacy_level had length > 1, using first element: ", privacy_level)
  }

  # Apply masking based on privacy level
  if (privacy_level == "mask") {
    if (mask_by == "name") {
      data[[student_col]] <- paste0("Student_", seq_len(nrow(data)))
    } else if (mask_by == "rank") {
      data[[student_col]] <- paste0("Rank_", seq_len(nrow(data)))
    }
  }
  return(data)
}
