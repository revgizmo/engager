#' Coverage Analysis Framework
#'
#' @description Analyzes current test coverage and identifies gaps
#' @keywords internal
#' @noRd

#' Analyze coverage gaps
#'
#' @return Coverage gap analysis results
analyze_coverage_gaps <- function() {
  # Get current coverage
  coverage <- covr::package_coverage()

  # Initialize variables
  file_coverage <- NULL
  low_coverage <- NULL
  impact_ranking <- list()

  # Get file-specific coverage (simplified approach)
  tryCatch(
    {
      file_coverage <- covr::file_coverage(coverage)
      low_coverage <- file_coverage[file_coverage < 90]
      impact_ranking <- rank_coverage_impact(low_coverage)
    },
    error = function(e) {
      # Fallback: use coverage object directly
      file_coverage <<- coverage$filecoverage
      low_coverage <<- file_coverage[file_coverage < 90]
      impact_ranking <<- list() # Simplified for now
    }
  )

  return(list(
    overall_coverage = covr::percent_coverage(coverage),
    file_coverage = file_coverage,
    low_coverage = low_coverage,
    impact_ranking = impact_ranking,
    target_gap = max(0, 90 - covr::percent_coverage(coverage))
  ))
}

#' Rank files by coverage impact
#'
#' @param low_coverage Files with low coverage
#' @return Impact ranking
rank_coverage_impact <- function(low_coverage) {
  if (length(low_coverage) == 0) {
    return(list())
  }

  # Sort by coverage percentage (lowest first)
  sorted_coverage <- sort(low_coverage)

  # Calculate potential impact based on coverage gap
  impact_scores <- sapply(names(sorted_coverage), function(file) {
    current_coverage <- sorted_coverage[file]
    potential_improvement <- (100 - current_coverage) / 100
    return(potential_improvement)
  })

  # Return ranked list
  return(sort(impact_scores, decreasing = TRUE))
}

#' Count lines in file
#'
#' @param file_path Path to file
#' @return Number of lines
count_file_lines <- function(file_path) {
  # Handle file paths that might be relative to R/ directory
  # Try with .R extension first
  full_path <- file.path("R", paste0(file_path, ".R"))
  if (file.exists(full_path)) {
    return(length(readLines(full_path)))
  }
  # Try without .R extension
  full_path <- file.path("R", file_path)
  if (file.exists(full_path)) {
    return(length(readLines(full_path)))
  }
  # Try direct path with .R extension
  if (file.exists(paste0(file_path, ".R"))) {
    return(length(readLines(paste0(file_path, ".R"))))
  }
  # Try direct path
  if (file.exists(file_path)) {
    return(length(readLines(file_path)))
  }
  return(0)
}
