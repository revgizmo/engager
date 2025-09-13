#' Write Engagement Metrics to CSV
#'
#' Deprecated: use `write_metrics(data, what = 'engagement', path = ...)` instead.
#'
#' comments)
#'
write_engagement_metrics <- function(metrics_data = NULL, file_path = NULL, comments_format = c("text", "count")) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'write_engagement_metrics' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  comments_format <- match.arg(comments_format)
  write_metrics(
    data = metrics_data,
    what = "engagement",
    path = file_path,
    comments_format = comments_format
  )
}
