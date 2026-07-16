attendance_fixture_path <- function(file) {
  system.file("extdata", "attendance-contract", file, package = "engager")
}

attendance_contract_expected <- function(file) {
  readr::read_csv(
    testthat::test_path("fixtures", "attendance-contract", file),
    show_col_types = FALSE,
    na = c("", "NA")
  )
}

attendance_contract_roster <- function() {
  readr::read_csv(
    attendance_fixture_path("roster.csv"),
    show_col_types = FALSE,
    na = c("", "NA")
  )
}

attendance_contract_sessions <- function() {
  tibble::tibble(
    session_id = sprintf("session-%02d", 1:4),
    transcript_file = c(
      attendance_fixture_path("session-01.vtt"),
      attendance_fixture_path("session-02.vtt"),
      attendance_fixture_path("session-03.vtt"),
      NA_character_
    ),
    status = c(rep("recorded", 3), "cancelled"),
    session_at = as.POSIXct(
      c(
        "2026-01-10 09:00:00",
        "2026-01-17 09:00:00",
        "2026-01-24 09:00:00",
        "2026-01-31 09:00:00"
      ),
      tz = "UTC"
    )
  )
}

test_that("attendance engine reproduces the approved golden contract", {
  roster <- attendance_contract_roster()
  expect_equal(roster, attendance_contract_expected("roster.csv"))

  expect_warning(
    result <- analyze_multi_session_attendance(
      attendance_contract_sessions(),
      roster,
      unmatched_names_action = "warn",
      min_attendance_threshold = 2 / 3
    ),
    "1 unmatched speaker occurrence was recorded"
  )

  expect_s3_class(result, "engager_attendance")
  expect_identical(names(result), c(
    "attendance",
    "participant_summary",
    "session_summary",
    "problems",
    "metadata"
  ))
  expect_equal(
    result$attendance,
    attendance_contract_expected("expected-attendance.csv")
  )
  expect_equal(
    result$participant_summary,
    attendance_contract_expected("expected-participants.csv"),
    tolerance = 1e-9
  )
  expect_equal(
    result$session_summary,
    attendance_contract_expected("expected-sessions.csv")
  )
  expect_equal(
    result$problems,
    attendance_contract_expected("expected-problems.csv")
  )
  expect_identical(result$metadata$schema_version, "engager_attendance_v1")
  expect_identical(result$metadata$eligible_roster_size, 5L)
  expect_identical(result$metadata$eligible_session_count, 3L)
  expect_equal(result$metadata$min_attendance_threshold, 2 / 3)
  expect_length(result$metadata$transcript_fingerprints, 3)

  metadata_text <- paste(unlist(result$metadata), collapse = " ")
  expect_false(grepl("Ada Rowan|Guest Nova|session-01.vtt", metadata_text))
})

test_that("attendance engine stop policy returns no partial attendance", {
  expect_error(
    analyze_multi_session_attendance(
      attendance_contract_sessions(),
      attendance_contract_roster(),
      unmatched_names_action = "stop"
    ),
    "attendance output was not returned",
    class = "engager_unmatched_error"
  )
})

test_that("attendance engine derives stable character-vector sessions", {
  paths <- c(
    zeta = attendance_fixture_path("session-02.vtt"),
    alpha = attendance_fixture_path("session-03.vtt")
  )
  before <- options()[c("engager.privacy_level", "engager.unmatched_names_action")]

  expect_warning(
    first <- analyze_multi_session_attendance(paths, attendance_contract_roster()),
    "2 session times could not be determined"
  )
  expect_warning(
    second <- analyze_multi_session_attendance(rev(paths), attendance_contract_roster()),
    "2 session times could not be determined"
  )

  expect_identical(first$session_summary$session_id, c("alpha", "zeta"))
  expect_equal(first$attendance, second$attendance)
  expect_equal(first$session_summary, second$session_summary)
  expect_setequal(first$problems$code, "unknown_session_time")
  expect_equal(
    options()[c("engager.privacy_level", "engager.unmatched_names_action")],
    before
  )
})

test_that("attendance engine uses exact aliases without changing the roster universe", {
  roster <- attendance_contract_roster()
  roster$aliases <- rep(NA_character_, nrow(roster))
  roster$aliases[roster$student_id == "student-002"] <- "Benjamin Ortiz"

  transcript <- tempfile(fileext = ".vtt")
  writeLines(c(
    "WEBVTT",
    "",
    "00:00:00.000 --> 00:00:01.000",
    "Benjamin Ortiz: Present"
  ), transcript)
  on.exit(unlink(transcript), add = TRUE)

  sessions <- attendance_contract_sessions()[1:2, ]
  sessions$transcript_file[1] <- transcript
  result <- analyze_multi_session_attendance(sessions, roster)

  alias_row <- result$attendance$student_id == "student-002" &
    result$attendance$session_id == "session-01"
  expect_true(result$attendance$present[alias_row])
  expect_equal(nrow(result$participant_summary), 5)
})

test_that("attendance engine validates roster authority", {
  sessions <- attendance_contract_sessions()
  roster <- attendance_contract_roster()

  blank_id <- roster
  blank_id$student_id[1] <- " "
  expect_error(
    analyze_multi_session_attendance(sessions, blank_id),
    "student_id must be non-empty",
    class = "engager_schema_error"
  )

  duplicate_id <- roster
  duplicate_id$student_id[2] <- duplicate_id$student_id[1]
  expect_error(
    analyze_multi_session_attendance(sessions, duplicate_id),
    "student_id must be unique",
    class = "engager_schema_error"
  )

  alias_collision <- roster
  alias_collision$aliases <- rep(NA_character_, nrow(alias_collision))
  alias_collision$aliases[2] <- alias_collision$preferred_name[1]
  expect_error(
    analyze_multi_session_attendance(sessions, alias_collision),
    "names and aliases must map uniquely",
    class = "engager_schema_error"
  )

  no_eligible <- roster
  no_eligible$eligible <- FALSE
  expect_error(
    analyze_multi_session_attendance(sessions, no_eligible),
    "At least one roster row must be eligible",
    class = "engager_input_error"
  )
})

test_that("attendance engine validates session and threshold inputs", {
  sessions <- attendance_contract_sessions()
  roster <- attendance_contract_roster()

  duplicate_id <- sessions
  duplicate_id$session_id[2] <- duplicate_id$session_id[1]
  expect_error(
    analyze_multi_session_attendance(duplicate_id, roster),
    "session_id must be unique",
    class = "engager_schema_error"
  )

  duplicate_path <- sessions
  duplicate_path$transcript_file[2] <- duplicate_path$transcript_file[1]
  expect_error(
    analyze_multi_session_attendance(duplicate_path, roster),
    "paths must be unique",
    class = "engager_schema_error"
  )

  unknown_status <- sessions
  unknown_status$status[1] <- "planned"
  expect_error(
    analyze_multi_session_attendance(unknown_status, roster),
    "recorded or cancelled",
    class = "engager_schema_error"
  )

  cancelled_file <- sessions
  cancelled_file$transcript_file[4] <- cancelled_file$transcript_file[1]
  expect_error(
    analyze_multi_session_attendance(cancelled_file, roster),
    "Cancelled sessions must not specify",
    class = "engager_schema_error"
  )

  expect_error(
    analyze_multi_session_attendance(sessions[1:2, ], roster, min_attendance_threshold = Inf),
    "one finite number",
    class = "engager_input_error"
  )
  expect_error(
    analyze_multi_session_attendance(sessions[1, ], roster),
    "At least two recorded sessions",
    class = "engager_input_error"
  )
})

test_that("attendance engine fails fast for missing and invalid WebVTT", {
  roster <- attendance_contract_roster()
  sessions <- attendance_contract_sessions()[1:2, ]

  missing_file <- sessions
  missing_file$transcript_file[1] <- tempfile(fileext = ".vtt")
  expect_error(
    analyze_multi_session_attendance(missing_file, roster),
    "must exist and be readable",
    class = "engager_input_error"
  )

  invalid_file <- tempfile(fileext = ".vtt")
  writeLines("not WebVTT", invalid_file)
  on.exit(unlink(invalid_file), add = TRUE)
  invalid_vtt <- sessions
  invalid_vtt$transcript_file[1] <- invalid_file
  expect_error(
    analyze_multi_session_attendance(invalid_vtt, roster),
    "could not be read as valid WebVTT",
    class = "engager_input_error"
  )
})

test_that("attendance print and summary disclose aggregate counts only", {
  result <- suppressWarnings(analyze_multi_session_attendance(
    attendance_contract_sessions(),
    attendance_contract_roster()
  ))

  printed <- capture.output(print(result))
  summarized <- summary(result)
  disclosure_text <- paste(c(printed, unlist(summarized)), collapse = " ")

  expect_match(printed, "5 eligible participants across 3 recorded sessions")
  expect_identical(summarized$eligible_roster_size, 5L)
  expect_false(grepl("Ada Rowan|student-001|Guest Nova", disclosure_text))
})

test_that("experimental report remains internal pending T4", {
  mock_results <- list(
    attendance_summary = data.frame(
      participant = "Student_001",
      total_sessions = 2L,
      attendance_rate = 100,
      stringsAsFactors = FALSE
    ),
    participation_patterns = list(
      total_participants = 1L,
      total_sessions = 2L,
      consistent_attendees = 1L,
      occasional_attendees = 0L,
      one_time_attendees = 0L,
      average_attendance_rate = 100,
      median_attendance_rate = 100,
      attendance_rate_std = 0
    ),
    privacy_compliant = TRUE
  )

  report <- generate_attendance_report(mock_results)
  expect_true(any(grepl("Multi-Session Attendance Analysis Report", report)))
  expect_false("generate_attendance_report" %in% getNamespaceExports("engager"))
})
