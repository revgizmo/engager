report_fixture_path <- function(file) {
  system.file("extdata", "attendance-contract", file, package = "engager")
}

report_fixture_roster <- function() {
  readr::read_csv(
    report_fixture_path("roster.csv"),
    show_col_types = FALSE,
    na = c("", "NA")
  )
}

report_fixture_sessions <- function() {
  tibble::tibble(
    session_id = sprintf("session-%02d", 1:4),
    transcript_file = c(
      report_fixture_path("session-01.vtt"),
      report_fixture_path("session-02.vtt"),
      report_fixture_path("session-03.vtt"),
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

report_fixture_analysis <- function(threshold = 2 / 3) {
  suppressWarnings(analyze_multi_session_attendance(
    report_fixture_sessions(),
    report_fixture_roster(),
    min_attendance_threshold = threshold
  ))
}

test_that("aggregate attendance report is deterministic and identifier-free", {
  analysis <- report_fixture_analysis()
  first <- generate_attendance_report(analysis)
  second <- generate_attendance_report(analysis)
  report_text <- paste(first, collapse = "\n")

  expect_identical(first, second)
  expect_match(report_text, "Attendance threshold: 66.7%", fixed = TRUE)
  expect_match(report_text, "Recorded sessions: 3", fixed = TRUE)
  expect_match(report_text, "Eligible participants: 5", fixed = TRUE)
  expect_match(report_text, "Participants meeting threshold: 3", fixed = TRUE)
  expect_match(report_text, "Participants with zero recorded attendance: 1", fixed = TRUE)
  expect_match(report_text, "session-04 | cancelled", fixed = TRUE)
  expect_match(report_text, "Recorded problem count: 1", fixed = TRUE)
  expect_match(report_text, "unmatched_speaker", fixed = TRUE)
  expect_match(report_text, "does not determine anonymity", fixed = TRUE)
  expect_match(report_text, "Small cohorts", fixed = TRUE)
  expect_false(grepl("## Participant detail", report_text, fixed = TRUE))
  expect_false(grepl("Generated", report_text, fixed = TRUE))

  forbidden <- c(
    report_fixture_roster()$student_id,
    report_fixture_roster()$preferred_name,
    "Guest Nova",
    "Welcome back",
    report_fixture_path("session-01.vtt")
  )
  expect_false(any(vapply(forbidden, grepl, logical(1), x = report_text, fixed = TRUE)))

  output <- tempfile(fileext = ".md")
  on.exit(unlink(output), add = TRUE)
  written <- generate_attendance_report(analysis, output_file = output)
  expect_identical(readLines(output, warn = FALSE), written)
})

test_that("participant report requires and applies a supported transformation", {
  analysis <- report_fixture_analysis()
  salt <- "synthetic-report-salt"

  masked <- generate_attendance_report(
    analysis,
    detail = "participant",
    identifier_method = "mask"
  )
  pseudonymized <- generate_attendance_report(
    analysis,
    detail = "participant",
    identifier_method = "pseudonymize"
  )
  hashed <- generate_attendance_report(
    analysis,
    detail = "participant",
    identifier_method = "hash",
    salt = salt
  )

  masked_text <- paste(masked, collapse = "\n")
  pseudonymized_text <- paste(pseudonymized, collapse = "\n")
  hashed_text <- paste(hashed, collapse = "\n")
  expected_hash <- substr(digest::digest(
    paste0("student-001", salt),
    algo = "sha256",
    serialize = FALSE
  ), 1, 8)

  expect_match(masked_text, "Student_1", fixed = TRUE)
  expect_match(pseudonymized_text, "PSEUDO_1", fixed = TRUE)
  expect_match(hashed_text, expected_hash, fixed = TRUE)
  for (text in c(masked_text, pseudonymized_text, hashed_text)) {
    expect_false(grepl("student-001|Ada Rowan|Guest Nova", text))
    expect_match(text, "Attendance threshold: 66.7%", fixed = TRUE)
  }
})

test_that("participant report rejects raw or ambiguous detail requests", {
  analysis <- report_fixture_analysis()

  expect_error(
    generate_attendance_report(analysis, detail = "participant"),
    "requires identifier_method",
    class = "engager_input_error"
  )
  expect_error(
    generate_attendance_report(
      analysis,
      detail = "participant",
      identifier_method = "hash"
    ),
    "explicit non-empty salt",
    class = "engager_input_error"
  )
  expect_error(
    generate_attendance_report(
      analysis,
      detail = "participant",
      identifier_method = "mask",
      salt = "unused"
    ),
    "supported only when identifier_method",
    class = "engager_input_error"
  )
  expect_error(
    generate_attendance_report(
      analysis,
      identifier_method = "mask"
    ),
    "only supported when detail",
    class = "engager_input_error"
  )
  expect_error(
    generate_attendance_report(analysis, output_file = " "),
    "one non-empty character path",
    class = "engager_input_error"
  )
  expect_error(
    generate_attendance_report(
      analysis,
      output_file = file.path(tempfile(), "report.md")
    ),
    "parent directory must already exist",
    class = "engager_input_error"
  )
})

test_that("attendance identifier transformation preserves missing and blank values", {
  data <- tibble::tibble(
    student_id = c("student-001", NA_character_, "", "  "),
    sessions_attended = c(1L, 0L, 0L, 0L)
  )

  for (method in c("mask", "pseudonymize")) {
    transformed <- transform_report_identifiers(data, method)
    expect_true(is.na(transformed$student_id[2]))
    expect_identical(transformed$student_id[3], "")
    expect_identical(transformed$student_id[4], "  ")
  }
  hashed <- transform_report_identifiers(data, "hash", "synthetic-salt")
  expect_true(is.na(hashed$student_id[2]))
  expect_identical(hashed$student_id[3], "")
  expect_identical(hashed$student_id[4], "  ")
})

test_that("attendance report validates schema and escapes Markdown cells", {
  expect_error(
    generate_attendance_report(list()),
    "engager_attendance_v1",
    class = "engager_input_error"
  )

  analysis <- report_fixture_analysis()
  analysis$metadata$schema_version <- "future_schema"
  expect_error(
    generate_attendance_report(analysis),
    "engager_attendance_v1",
    class = "engager_input_error"
  )

  analysis <- report_fixture_analysis()
  analysis$session_summary$session_id[1] <- "session|one\nreview"
  report <- paste(generate_attendance_report(analysis), collapse = "\n")
  expect_match(report, "session\\\\|one review", fixed = TRUE)
})

test_that("attendance report remains internal until T5", {
  expect_false("generate_attendance_report" %in% getNamespaceExports("engager"))
})
