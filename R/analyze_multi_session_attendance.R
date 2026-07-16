#' Analyze Exact Roster Attendance Across Sessions
#'
#' Internal 0.1.1 engine. The roster defines the participant universe and
#' exact matching determines presence. The returned object contains local
#' roster identifiers and is not a shareable report.
#'
#' @param sessions Either a character vector of WebVTT paths or a data frame
#'   with `session_id`, `transcript_file`, `status`, and optional `session_at`.
#' @param roster_data A data frame with `student_id`, `preferred_name`, optional
#'   semicolon-delimited `aliases`, and optional logical `eligible`.
#' @param unmatched_names_action Either `"warn"` or `"stop"`.
#' @param min_attendance_threshold One finite numeric scalar in `[0, 1]`.
#' @return An internal `engager_attendance` object containing typed attendance,
#'   participant, session, problem, and metadata components.
#' @keywords internal
analyze_multi_session_attendance <- function(
    sessions,
    roster_data,
    unmatched_names_action = c("warn", "stop"),
    min_attendance_threshold = 0.5) {
  unmatched_names_action <- match.arg(unmatched_names_action)
  validate_attendance_threshold(min_attendance_threshold)

  session_spec <- prepare_attendance_sessions(sessions)
  roster_spec <- prepare_attendance_roster(roster_data)
  eligible_roster <- roster_spec[roster_spec$eligible, , drop = FALSE]

  matched_ids <- vector("list", nrow(session_spec))
  unmatched_counts <- integer(nrow(session_spec))

  for (i in seq_len(nrow(session_spec))) {
    if (session_spec$status[i] == "cancelled") {
      matched_ids[[i]] <- character()
      next
    }

    transcript <- tryCatch(
      load_zoom_transcript(session_spec$transcript_file[i]),
      error = function(error) {
        rlang::abort(
          message = "A recorded transcript could not be read as valid WebVTT.",
          class = "engager_input_error",
          parent = error
        )
      }
    )

    if (is.null(transcript)) {
      transcript <- tibble::tibble(name = character())
    }

    match_result <- match_names_workflow(
      transcript,
      roster_spec,
      options = list(match_strategy = "exact", include_name_hash = FALSE)
    )
    matched_ids[[i]] <- unique(stats::na.omit(
      as.character(match_result$transcripts_with_ids$student_id)
    ))
    unmatched_counts[i] <- length(unique(match_result$unresolved$name_hash))
  }

  unmatched_sessions <- unmatched_counts > 0L
  if (any(unmatched_sessions) && unmatched_names_action == "stop") {
    rlang::abort(
      message = sprintf(
        paste0(
          "%d unmatched speaker occurrence%s %s recorded across %d session%s; ",
          "attendance output was not returned."
        ),
        sum(unmatched_counts),
        if (sum(unmatched_counts) == 1L) "" else "s",
        if (sum(unmatched_counts) == 1L) "was" else "were",
        sum(unmatched_sessions),
        if (sum(unmatched_sessions) == 1L) "" else "s"
      ),
      class = "engager_unmatched_error"
    )
  }

  attendance <- build_attendance_rows(
    eligible_roster$student_id,
    session_spec,
    matched_ids
  )
  participant_summary <- build_participant_summary(
    attendance,
    eligible_roster$student_id,
    min_attendance_threshold
  )
  session_summary <- build_session_summary(
    attendance,
    session_spec,
    nrow(eligible_roster),
    unmatched_counts
  )
  problems <- build_attendance_problems(session_spec, unmatched_counts)

  if (any(unmatched_sessions) && unmatched_names_action == "warn") {
    warning(
      sprintf(
        paste0(
          "%d unmatched speaker occurrence%s %s recorded across %d session%s; ",
          "review the non-identifying problems table."
        ),
        sum(unmatched_counts),
        if (sum(unmatched_counts) == 1L) "" else "s",
        if (sum(unmatched_counts) == 1L) "was" else "were",
        sum(unmatched_sessions),
        if (sum(unmatched_sessions) == 1L) "" else "s"
      ),
      call. = FALSE
    )
  }

  result <- list(
    attendance = attendance,
    participant_summary = participant_summary,
    session_summary = session_summary,
    problems = problems,
    metadata = list(
      schema_version = "engager_attendance_v1",
      package_version = attendance_package_version(),
      min_attendance_threshold = min_attendance_threshold,
      unmatched_names_action = unmatched_names_action,
      eligible_roster_size = nrow(eligible_roster),
      eligible_session_count = sum(session_spec$status == "recorded"),
      roster_fingerprint = digest::digest(
        roster_spec[, c("student_id", "preferred_name", "aliases", "eligible"), drop = FALSE],
        algo = "sha256"
      ),
      transcript_fingerprints = unname(vapply(
        session_spec$transcript_file[session_spec$status == "recorded"],
        digest::digest,
        character(1),
        file = TRUE,
        algo = "sha256"
      ))
    )
  )
  class(result) <- c("engager_attendance", "list")
  result
}

validate_attendance_threshold <- function(threshold) {
  valid <- is.numeric(threshold) && length(threshold) == 1L &&
    !is.na(threshold) && is.finite(threshold) && threshold >= 0 && threshold <= 1
  if (!valid) {
    rlang::abort(
      message = "min_attendance_threshold must be one finite number between 0 and 1 inclusive.",
      class = "engager_input_error"
    )
  }
  invisible(threshold)
}

prepare_attendance_sessions <- function(sessions) {
  if (is.character(sessions)) {
    if (length(sessions) == 0L || any(is.na(sessions) | !nzchar(trimws(sessions)))) {
      rlang::abort(
        message = "sessions must contain non-empty WebVTT paths.",
        class = "engager_input_error"
      )
    }
    session_ids <- derive_transcript_session_key(basename(sessions))
    supplied_ids <- names(sessions)
    if (!is.null(supplied_ids)) {
      use_supplied <- !is.na(supplied_ids) & nzchar(trimws(supplied_ids))
      session_ids[use_supplied] <- trimws(supplied_ids[use_supplied])
    }
    timestamp_text <- stringr::str_extract(
      basename(sessions),
      "(?<=GMT)\\d{8}-\\d{6}"
    )
    session_spec <- data.frame(
      session_id = session_ids,
      transcript_file = unname(sessions),
      status = rep("recorded", length(sessions)),
      session_at = as.POSIXct(
        timestamp_text,
        format = "%Y%m%d-%H%M%S",
        tz = "UTC"
      ),
      stringsAsFactors = FALSE
    )
  } else if (is.data.frame(sessions)) {
    required <- c("session_id", "transcript_file", "status")
    missing_columns <- setdiff(required, names(sessions))
    if (length(missing_columns) > 0L) {
      rlang::abort(
        message = sprintf(
          "sessions is missing required columns: %s.",
          paste(missing_columns, collapse = ", ")
        ),
        class = "engager_schema_error"
      )
    }
    session_spec <- data.frame(
      session_id = sessions$session_id,
      transcript_file = sessions$transcript_file,
      status = sessions$status,
      stringsAsFactors = FALSE
    )
    session_spec$session_at <- parse_attendance_session_time(
      if ("session_at" %in% names(sessions)) sessions$session_at else NULL,
      nrow(session_spec)
    )
  } else {
    rlang::abort(
      message = "sessions must be a character vector or data frame.",
      class = "engager_input_error"
    )
  }

  if (!is.character(session_spec$session_id) ||
        any(is.na(session_spec$session_id) |
              !nzchar(trimws(session_spec$session_id)))) {
    rlang::abort(
      message = "session_id must be non-empty character values.",
      class = "engager_schema_error"
    )
  }
  if (anyDuplicated(session_spec$session_id)) {
    rlang::abort(
      message = "session_id must be unique.",
      class = "engager_schema_error"
    )
  }
  if (!is.character(session_spec$status) ||
        any(is.na(session_spec$status) |
              !session_spec$status %in% c("recorded", "cancelled"))) {
    rlang::abort(
      message = "status must contain only recorded or cancelled.",
      class = "engager_schema_error"
    )
  }

  recorded <- session_spec$status == "recorded"
  cancelled <- !recorded
  invalid_recorded_path <- !is.character(session_spec$transcript_file) ||
    any(is.na(session_spec$transcript_file[recorded]) |
          !nzchar(trimws(session_spec$transcript_file[recorded])))
  if (invalid_recorded_path) {
    rlang::abort(
      message = "Every recorded session must have a non-empty transcript_file.",
      class = "engager_input_error"
    )
  }
  if (any(cancelled & !is.na(session_spec$transcript_file) &
            nzchar(trimws(session_spec$transcript_file)))) {
    rlang::abort(
      message = "Cancelled sessions must not specify a transcript_file.",
      class = "engager_schema_error"
    )
  }
  if (sum(recorded) < 2L) {
    rlang::abort(
      message = "At least two recorded sessions are required.",
      class = "engager_input_error"
    )
  }
  if (any(!file.exists(session_spec$transcript_file[recorded])) ||
        any(file.access(session_spec$transcript_file[recorded], 4L) != 0L)) {
    rlang::abort(
      message = "Every recorded transcript_file must exist and be readable.",
      class = "engager_input_error"
    )
  }

  normalized_files <- normalizePath(
    session_spec$transcript_file[recorded],
    winslash = "/",
    mustWork = TRUE
  )
  if (anyDuplicated(normalized_files)) {
    rlang::abort(
      message = "Normalized recorded transcript paths must be unique.",
      class = "engager_schema_error"
    )
  }
  session_spec$transcript_file[recorded] <- normalized_files

  unknown_time_count <- sum(is.na(session_spec$session_at))
  if (unknown_time_count > 0L) {
    warning(
      sprintf(
        paste0(
          "%d session time%s could not be determined; session_at remains NA ",
          "and unknown-time sessions are ordered by session_id."
        ),
        unknown_time_count,
        if (unknown_time_count == 1L) "" else "s"
      ),
      call. = FALSE
    )
  }

  session_spec <- session_spec[order(
    is.na(session_spec$session_at),
    session_spec$session_at,
    session_spec$session_id
  ), , drop = FALSE]
  rownames(session_spec) <- NULL
  session_spec
}

parse_attendance_session_time <- function(value, size) {
  if (is.null(value)) {
    return(as.POSIXct(rep(NA_real_, size), origin = "1970-01-01", tz = "UTC"))
  }
  if (length(value) != size) {
    rlang::abort(
      message = "session_at must have one value per session.",
      class = "engager_schema_error"
    )
  }
  if (inherits(value, "POSIXt")) {
    return(as.POSIXct(value, tz = "UTC"))
  }
  if (!is.character(value)) {
    rlang::abort(
      message = "session_at must be a POSIX timestamp or character vector.",
      class = "engager_schema_error"
    )
  }
  as.POSIXct(
    suppressWarnings(lubridate::ymd_hms(value, quiet = TRUE, tz = "UTC")),
    tz = "UTC"
  )
}

prepare_attendance_roster <- function(roster_data) {
  if (!is.data.frame(roster_data) || nrow(roster_data) == 0L) {
    rlang::abort(
      message = "roster_data must be a non-empty data frame.",
      class = "engager_input_error"
    )
  }
  required <- c("student_id", "preferred_name")
  missing_columns <- setdiff(required, names(roster_data))
  if (length(missing_columns) > 0L) {
    rlang::abort(
      message = sprintf(
        "roster_data is missing required columns: %s.",
        paste(missing_columns, collapse = ", ")
      ),
      class = "engager_schema_error"
    )
  }
  if (!is.character(roster_data$student_id) ||
        any(is.na(roster_data$student_id) |
              !nzchar(trimws(roster_data$student_id)))) {
    rlang::abort(
      message = "student_id must be non-empty character values.",
      class = "engager_schema_error"
    )
  }
  if (anyDuplicated(roster_data$student_id)) {
    rlang::abort(
      message = "student_id must be unique.",
      class = "engager_schema_error"
    )
  }
  if (!is.character(roster_data$preferred_name) ||
        any(is.na(roster_data$preferred_name) |
              !nzchar(trimws(roster_data$preferred_name)))) {
    rlang::abort(
      message = "preferred_name must be non-empty character values.",
      class = "engager_schema_error"
    )
  }

  aliases <- if ("aliases" %in% names(roster_data)) {
    roster_data$aliases
  } else {
    rep(NA_character_, nrow(roster_data))
  }
  if (is.logical(aliases) && all(is.na(aliases))) {
    aliases <- rep(NA_character_, length(aliases))
  }
  roster_spec <- data.frame(
    student_id = roster_data$student_id,
    preferred_name = roster_data$preferred_name,
    aliases = aliases,
    eligible = if ("eligible" %in% names(roster_data)) roster_data$eligible else TRUE,
    stringsAsFactors = FALSE
  )
  if (!is.character(roster_spec$aliases)) {
    rlang::abort(
      message = "aliases must be semicolon-delimited character values.",
      class = "engager_schema_error"
    )
  }
  if (!is.logical(roster_spec$eligible) || any(is.na(roster_spec$eligible))) {
    rlang::abort(
      message = "eligible must contain non-missing logical values.",
      class = "engager_schema_error"
    )
  }
  if (!any(roster_spec$eligible)) {
    rlang::abort(
      message = "At least one roster row must be eligible.",
      class = "engager_input_error"
    )
  }

  normalized_names <- unlist(lapply(seq_len(nrow(roster_spec)), function(i) {
    unique(normalize_name(c(
      roster_spec$preferred_name[i],
      split_aliases(roster_spec$aliases[i], delimiter = ";")
    )))
  }), use.names = FALSE)
  normalized_ids <- unlist(lapply(seq_len(nrow(roster_spec)), function(i) {
    names_for_row <- unique(normalize_name(c(
      roster_spec$preferred_name[i],
      split_aliases(roster_spec$aliases[i], delimiter = ";")
    )))
    rep(roster_spec$student_id[i], length(names_for_row))
  }), use.names = FALSE)
  collision <- vapply(unique(normalized_names), function(name) {
    length(unique(normalized_ids[normalized_names == name])) > 1L
  }, logical(1))
  if (any(collision)) {
    rlang::abort(
      message = "Exact preferred names and aliases must map uniquely to one student_id.",
      class = "engager_schema_error"
    )
  }
  roster_spec
}

build_attendance_rows <- function(student_ids, session_spec, matched_ids) {
  attendance <- data.frame(
    student_id = rep(student_ids, each = nrow(session_spec)),
    session_id = rep(session_spec$session_id, times = length(student_ids)),
    status = rep(session_spec$status, times = length(student_ids)),
    present = rep(NA, length(student_ids) * nrow(session_spec)),
    stringsAsFactors = FALSE
  )
  for (i in seq_len(nrow(session_spec))) {
    session_rows <- attendance$session_id == session_spec$session_id[i]
    if (session_spec$status[i] == "recorded") {
      attendance$present[session_rows] <-
        attendance$student_id[session_rows] %in% matched_ids[[i]]
    }
  }
  tibble::as_tibble(attendance)
}

build_participant_summary <- function(attendance, student_ids, threshold) {
  recorded <- attendance$status == "recorded"
  eligible_sessions <- length(unique(attendance$session_id[recorded]))
  attended <- vapply(student_ids, function(student_id) {
    sum(attendance$present[attendance$student_id == student_id & recorded])
  }, integer(1))
  rate <- attended / eligible_sessions
  tibble::tibble(
    student_id = student_ids,
    eligible_sessions = rep(as.integer(eligible_sessions), length(student_ids)),
    sessions_attended = unname(attended),
    attendance_rate = unname(rate),
    meets_threshold = unname(rate >= threshold),
    is_one_time_attendee = unname(attended == 1L)
  )
}

build_session_summary <- function(
    attendance,
    session_spec,
    roster_size,
    unmatched_counts) {
  attended_count <- vapply(seq_len(nrow(session_spec)), function(i) {
    if (session_spec$status[i] == "cancelled") return(NA_integer_)
    sum(attendance$present[attendance$session_id == session_spec$session_id[i]])
  }, integer(1))
  absent_count <- ifelse(
    session_spec$status == "cancelled",
    NA_integer_,
    as.integer(roster_size - attended_count)
  )
  tibble::tibble(
    session_id = session_spec$session_id,
    status = session_spec$status,
    eligible = session_spec$status == "recorded",
    roster_size = rep(as.integer(roster_size), nrow(session_spec)),
    attended_count = attended_count,
    absent_count = absent_count,
    unmatched_speaker_count = as.integer(unmatched_counts),
    attendance_rate = attended_count / roster_size
  )
}

build_attendance_problems <- function(session_spec, unmatched_counts) {
  rows <- list()
  for (i in seq_len(nrow(session_spec))) {
    if (unmatched_counts[i] > 0L) {
      count <- unmatched_counts[i]
      rows[[length(rows) + 1L]] <- data.frame(
        session_id = session_spec$session_id[i],
        code = "unmatched_speaker",
        severity = "warning",
        count = as.integer(count),
        message = if (count == 1L) {
          "One unique speaker did not match the roster."
        } else {
          sprintf("%d unique speakers did not match the roster.", count)
        },
        stringsAsFactors = FALSE
      )
    }
    if (is.na(session_spec$session_at[i])) {
      rows[[length(rows) + 1L]] <- data.frame(
        session_id = session_spec$session_id[i],
        code = "unknown_session_time",
        severity = "warning",
        count = 1L,
        message = "The session time is unknown and remains missing.",
        stringsAsFactors = FALSE
      )
    }
  }
  if (length(rows) == 0L) {
    return(tibble::tibble(
      session_id = character(),
      code = character(),
      severity = character(),
      count = integer(),
      message = character()
    ))
  }
  tibble::as_tibble(do.call(rbind, rows))
}

attendance_package_version <- function() {
  tryCatch(
    as.character(utils::packageVersion("engager")),
    error = function(error) "0.1.0.9000"
  )
}

#' @export
print.engager_attendance <- function(x, ...) {
  cat(
    "engager_attendance: ",
    x$metadata$eligible_roster_size,
    " eligible participants across ",
    x$metadata$eligible_session_count,
    " recorded sessions; ",
    sum(x$session_summary$unmatched_speaker_count),
    " unmatched speaker counts\n",
    sep = ""
  )
  invisible(x)
}

#' @export
summary.engager_attendance <- function(object, ...) {
  list(
    eligible_roster_size = object$metadata$eligible_roster_size,
    eligible_session_count = object$metadata$eligible_session_count,
    mean_attendance_rate = mean(object$participant_summary$attendance_rate),
    threshold = object$metadata$min_attendance_threshold,
    participants_meeting_threshold = sum(object$participant_summary$meets_threshold),
    unmatched_speaker_count = sum(object$session_summary$unmatched_speaker_count)
  )
}

#' Experimental Attendance Report
#'
#' Internal prototype for a possible v0.1.1 reporting workflow. Chart and
#' threshold semantics are not part of the v0.1.0 public API.
#'
#' @param analysis_results Results from `analyze_multi_session_attendance()`
#' @param output_file Optional file path to save the report
#' @param include_charts Boolean to include charts (default: FALSE)
#' @return Report content as character vector
#' @keywords internal
generate_attendance_report <- function(
    analysis_results = NULL,
    output_file = NULL,
    include_charts = FALSE) {
  if (!is.list(analysis_results) || !"participation_patterns" %in% names(analysis_results)) {
    stop("analysis_results must be the output from analyze_multi_session_attendance()")
  }

  patterns <- analysis_results$participation_patterns
  summary <- analysis_results$attendance_summary

  # Generate report content
  report_content <- c(
    "# Multi-Session Attendance Analysis Report",
    "",
    paste("**Generated**:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    paste("**Sessions Analyzed**:", patterns$total_sessions),
    paste("**Total Participants**:", patterns$total_participants),
    "",
    "## Participation Summary",
    "",
    paste(
      "- **Consistent Attendees** (>=", patterns$total_sessions * 0.5,
      "sessions):", patterns$consistent_attendees
    ),
    paste(
      "- **Occasional Attendees** (2-",
      ceiling(patterns$total_sessions * 0.5) - 1,
      "sessions):", patterns$occasional_attendees
    ),
    paste("- **One-time Attendees**:", patterns$one_time_attendees),
    "",
    "## Attendance Statistics",
    "",
    paste("- **Average Attendance Rate**:", patterns$average_attendance_rate, "%"),
    paste("- **Median Attendance Rate**:", patterns$median_attendance_rate, "%"),
    paste("- **Attendance Rate Std Dev**:", patterns$attendance_rate_std, "%"),
    "",
    "## Technical Privacy Check",
    "",
    if (analysis_results$privacy_compliant) {
      "[PASS] Package masking checks completed"
    } else {
      "[FAIL] Package masking checks detected possible identifiers"
    },
    ""
  )

  # Add attendance matrix if privacy allows
  if (analysis_results$privacy_compliant) {
    report_content <- c(
      report_content,
      "## Attendance Matrix",
      "",
      "| Participant | Sessions Attended | Attendance Rate |",
      "|-------------|-------------------|-----------------|"
    )

    for (i in seq_len(min(10, nrow(summary)))) { # Limit to first 10 for report
      row <- summary[i, ]
      report_content <- c(
        report_content,
        sprintf(
          "| %s | %d | %.1f%% |",
          row$participant,
          row$total_sessions,
          row$attendance_rate
        )
      )
    }

    if (nrow(summary) > 10) {
      report_content <- c(report_content, "| ... | ... | ... |")
    }
  }

  # Save report if output file specified
  if (!is.null(output_file)) {
    writeLines(report_content, output_file)
  }

  return(report_content)
}
