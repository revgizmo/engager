#' Write Engagement Metrics to CSV
#'
#' Deprecated: use `write_metrics(data, what = 'engagement', path = ...)` instead.
#'
#' @param metrics_data A tibble containing engagement metrics (typically from `summarize_transcript_files`)
#' @param file_path Path where the CSV file should be saved
#' @param comments_format How to format the comments column: "text" (semicolon-separated) or "count" (number of comments)
#'
#' @return Invisibly returns the processed data that was written
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
write_engagement_metrics <- function(metrics_data = NULL, file_path = NULL, comments_format = c("text", "count")) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'write_engagement_metrics' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  comments_format <- match.arg(comments_format)
  write_metrics(
    data = metrics_data,
    what = "engagement",
    path = file_path,
    comments_format = comments_format
  )
}
