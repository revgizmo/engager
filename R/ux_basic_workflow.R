#' Basic Analysis Workflow for New Users
#'
#' @description Simplified workflow that guides new users through basic analysis
#'   of Zoom transcripts with minimal complexity.

#' Complete basic transcript analysis workflow
#'
#' @description This is the main function for new users. It performs a complete
#'   analysis workflow in five simple steps: load, process, analyze, visualize,
#'   and either return results in memory or export to an explicit directory.
#'
#' @param transcript_file Path to a WebVTT transcript file
#' @param output_dir Optional output directory. When `NULL` (the default), the
#'   analysis is returned in memory and no files or directories are created.
#' @param privacy_level Privacy protection level: "high" (default), "medium",
#'   or "low". These map to `"privacy_strict"`, `"privacy_standard"`, and
#'   `"mask"`, respectively. All three levels mask common identifiers.
#' @return A named list with `analysis` (a tibble of speaker metrics), `plots`
#'   (a `ggplot` object), `output_dir` (the explicit output directory or
#'   `NULL`), `transcript_file`, and `privacy_level`.
#' @export
#' @examples
#' transcript_file <- system.file(
#'   "extdata/test_transcripts/ideal_course_session1.vtt",
#'   package = "engager"
#' )
#' results <- basic_transcript_analysis(transcript_file)
basic_transcript_analysis <- function(transcript_file, output_dir = NULL, privacy_level = "high") {
  # Validate inputs
  if (!file.exists(transcript_file)) {
    stop(
      "ERROR: File not found: ", transcript_file, "\n",
      "TIP: Please check the file path and try again"
    )
  }

  validate_optional_output_dir(output_dir)
  normalized_privacy_level <- normalize_basic_privacy_level(privacy_level)

  if (!is.null(output_dir) && !dir.exists(output_dir)) {
    message("Creating output directory: ", output_dir)
    dir.create(output_dir, recursive = TRUE)
  }

  previous_privacy_level <- getOption("engager.privacy_level")
  on.exit(options(engager.privacy_level = previous_privacy_level), add = TRUE)
  options(engager.privacy_level = normalized_privacy_level)

  # TARGET: Starting Basic Transcript Analysis
  message("==> Starting Basic Transcript Analysis")
  message(paste(rep("=", 40), collapse = ""))
  message("FILE: File: ", basename(transcript_file))
  message("DIR: Output: ", if (is.null(output_dir)) "in memory" else output_dir)
  message("PRIVACY: Privacy: ", privacy_level)
  message("")

  tryCatch(
    {
      # Step 1: Load transcript
      message("Step 1/5: Loading transcript...")
      transcript <- load_zoom_transcript(transcript_file)
      message("SUCCESS: Loaded ", nrow(transcript), " transcript entries")

      # Step 2: Process transcript
      message("Step 2/5: Processing transcript...")
      processed <- process_zoom_transcript(transcript_df = transcript)
      if (!is.data.frame(processed) || nrow(processed) == 0) {
        stop("Transcript processing returned no rows", call. = FALSE)
      }
      message("SUCCESS: Processed transcript data")

      # Step 3: Analyze engagement
      message("Step 3/5: Analyzing engagement...")
      analysis <- summarize_transcript_metrics(
        transcript_df = processed,
        names_exclude = c("dead_air"),
        comments_format = "count"
      )
      if (!is.data.frame(analysis) || nrow(analysis) == 0) {
        stop("Transcript analysis returned no engagement metrics", call. = FALSE)
      }
      message("SUCCESS: Calculated engagement metrics")

      # Step 4: Create visualizations
      message("Step 4/5: Creating visualizations...")
      plots <- plot_users(
        analysis,
        metric = "wordcount",
        student_col = "name",
        facet_by = "none",
        # `analysis` was already processed with the selected privacy level.
        # Avoid applying a second masking pass that would change stable labels.
        privacy_level = "none"
      )
      message("SUCCESS: Created engagement visualizations")

      # Step 5: Export results only when explicitly requested
      if (!is.null(output_dir)) {
        message("Step 5/5: Exporting results...")
        output_path <- file.path(output_dir, "engagement_metrics.csv")
        write_metrics(
          analysis,
          what = "engagement",
          path = output_path,
          privacy_level = normalized_privacy_level,
          comments_policy = "omit"
        )
        message("SUCCESS: Exported results to ", output_dir)
      } else {
        message("Step 5/5: Returning results in memory (no output directory supplied)")
      }

      message("")
      message("COMPLETE: Basic analysis complete!")
      message("RESULTS: Results ", if (is.null(output_dir)) "returned in memory" else paste0("saved to: ", output_dir))
      message("TIP: Next steps:")
      if (!is.null(output_dir)) {
        message("   - Check the output files in ", output_dir)
      }
      message("   - Use show_available_functions() to see more options")
      message("   - Use set_ux_level('intermediate') for more functions")

      return(list(
        analysis = analysis,
        plots = plots,
        output_dir = output_dir,
        transcript_file = transcript_file,
        privacy_level = privacy_level
      ))
    },
    error = function(e) {
      message("ERROR: Analysis failed: ", e$message)
      message("TIP: Try: show_getting_started() for help")
      message("TIP: Or: show_function_help('basic_transcript_analysis')")
      stop(e)
    }
  )
}

# Internal validation shared by the beginner workflows. Validate before any
# directory creation so malformed destinations fail without side effects.
validate_optional_output_dir <- function(output_dir) {
  if (is.null(output_dir)) {
    return(invisible(NULL))
  }

  if (!is.character(output_dir) || length(output_dir) != 1L ||
      is.na(output_dir) || !nzchar(trimws(output_dir))) {
    stop(
      "`output_dir` must be NULL or an explicit non-empty directory path",
      call. = FALSE
    )
  }

  invisible(output_dir)
}

# Internal mapping retained for the beginner-facing high/medium/low API.
normalize_basic_privacy_level <- function(privacy_level) {
  if (!is.character(privacy_level) || length(privacy_level) != 1 || is.na(privacy_level)) {
    stop('`privacy_level` must be one of: "high", "medium", "low"', call. = FALSE)
  }

  levels <- c(
    high = "privacy_strict",
    medium = "privacy_standard",
    low = "mask"
  )
  if (!privacy_level %in% names(levels)) {
    stop('`privacy_level` must be one of: "high", "medium", "low"', call. = FALSE)
  }

  unname(levels[[privacy_level]])
}

#' Quick analysis for single transcript file
#'
#' @description Simplified version for users who just want quick results
#'
#' @param transcript_file Path to transcript file
#' @param output_dir Optional output directory. When `NULL`, no files or
#'   directories are created.
#' @return The named analysis list returned by `basic_transcript_analysis()`.
#' @export
#' @examples
#' transcript_file <- system.file(
#'   "extdata/test_transcripts/ideal_course_session1.vtt",
#'   package = "engager"
#' )
#' results <- quick_analysis(transcript_file)
quick_analysis <- function(transcript_file, output_dir = NULL) {
  message("QUICK: Quick Analysis Mode")
  message(paste(rep("=", 25), collapse = ""))

  # Use basic workflow with default settings
  results <- basic_transcript_analysis(transcript_file, output_dir)

  message("SUCCESS: Quick analysis complete!")
  message("DIR: Results: ", if (is.null(output_dir)) "in memory" else output_dir)

  results
}

#' Batch analysis for multiple transcript files
#'
#' @description Process multiple transcript files in one workflow
#'
#' @param transcript_files Vector of transcript file paths
#' @param output_dir Optional parent output directory. When `NULL` (the
#'   default), all results are returned in memory without creating directories.
#' @param privacy_level Privacy protection level
#' @return A named list keyed by transcript basename. Each element is the
#'   analysis list returned by `basic_transcript_analysis()` or a list with an
#'   `error` message when that file could not be processed.
#' @export
#' @examples
#' transcript_dir <- system.file("extdata/test_transcripts", package = "engager")
#' files <- file.path(transcript_dir, c(
#'   "ideal_course_session1.vtt", "ideal_course_session2.vtt"
#' ))
#' results <- batch_basic_analysis(files)
batch_basic_analysis <- function(transcript_files, output_dir = NULL, privacy_level = "high") {
  if (length(transcript_files) == 0) {
    stop("ERROR: No transcript files provided")
  }

  validate_optional_output_dir(output_dir)

  # Validate all files exist
  missing_files <- transcript_files[!file.exists(transcript_files)]
  if (length(missing_files) > 0) {
    stop("ERROR: Files not found: ", paste(missing_files, collapse = ", "))
  }

  message("BATCH: Batch Analysis Mode")
  message(paste(rep("=", 25), collapse = ""))
  message("FILE: Files: ", length(transcript_files))
  message("DIR: Output: ", if (is.null(output_dir)) "in memory" else output_dir)
  message("PRIVACY: Privacy: ", privacy_level)
  message("")

  results <- list()

  for (i in seq_along(transcript_files)) {
    file <- transcript_files[i]
    message("Processing file ", i, "/", length(transcript_files), ": ", basename(file))

    # Create subdirectory for each file
    file_output_dir <- if (is.null(output_dir)) NULL else file.path(output_dir, paste0("session_", i))

    tryCatch(
      {
        result <- basic_transcript_analysis(file, file_output_dir, privacy_level)
        results[[basename(file)]] <- result
        message("SUCCESS: Completed: ", basename(file))
      },
      error = function(e) {
        message("ERROR: Failed: ", basename(file), " - ", e$message)
        results[[basename(file)]] <- list(error = e$message)
      }
    )

    message("")
  }

  message("COMPLETE: Batch analysis complete!")
  message("RESULTS: Results ", if (is.null(output_dir)) "returned in memory" else paste0("saved to: ", output_dir))
  message("STATS: Successful: ", sum(sapply(results, function(x) is.null(x$error))))
  message("ERROR: Failed: ", sum(sapply(results, function(x) !is.null(x$error))))

  results
}
