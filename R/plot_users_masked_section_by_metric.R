#' Plot Users by Metric
#'
#' Deprecated: use `plot_users(mask_by = 'rank')` instead. Delegates to `plot_users()`
#' for backward compatibility.
#'
#' @param df a tibble that summarizes results at the level of the class section and student.
#' @param metric Label of the metric to plot. Defaults to 'session_ct'.
#'
#' @return A ggplot object.
#' # # @export (REMOVED - deprecated function) (REMOVED - deprecated function)
plot_users_masked_section_by_metric <- function(df = NULL, metric = "session_ct") {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning("Function 'plot_users_masked_section_by_metric' is deprecated and will be removed in the next version. Please use the essential functions instead. See ?get_essential_functions for alternatives.", call. = FALSE)

  if (!tibble::is_tibble(df)) stop("`df` must be a tibble")
  if (!metric %in% names(df)) {
    stop(sprintf("Metric '%s' not found in data", metric))
  }
  plot_users(
    data = df,
    metric = metric,
    student_col = "preferred_name",
    facet_by = "section",
    mask_by = "rank"
  )
}
