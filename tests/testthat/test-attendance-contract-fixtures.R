attendance_contract_path <- function(file) {
  testthat::test_path("fixtures", "attendance-contract", file)
}

read_attendance_contract <- function(file) {
  readr::read_csv(
    attendance_contract_path(file),
    show_col_types = FALSE,
    na = c("", "NA")
  )
}

test_that("attendance contract fixture is complete and synthetic", {
  required_files <- c(
    "README.md",
    "roster.csv",
    "sessions.csv",
    "observed-speakers.csv",
    "expected-attendance.csv",
    "expected-participants.csv",
    "expected-sessions.csv",
    "expected-problems.csv",
    "invalid-cases.csv"
  )

  expect_true(all(file.exists(attendance_contract_path(required_files))))

  fixture_text <- paste(
    unlist(lapply(required_files, function(file) {
      readLines(attendance_contract_path(file), warn = FALSE)
    })),
    collapse = "\n"
  )

  expect_false(grepl("@", fixture_text, fixed = TRUE))
  expect_false(grepl("berkeley", fixture_text, ignore.case = TRUE))
  expect_false(grepl("zoomstudentengagement", fixture_text, ignore.case = TRUE))
})

test_that("attendance contract derives roster-based presence", {
  roster <- read_attendance_contract("roster.csv")
  sessions <- read_attendance_contract("sessions.csv")
  observed <- read_attendance_contract("observed-speakers.csv")
  attendance <- read_attendance_contract("expected-attendance.csv")

  eligible_roster <- roster[roster$eligible, , drop = FALSE]
  recorded_sessions <- sessions[sessions$status == "recorded", , drop = FALSE]
  cancelled_sessions <- sessions[sessions$status == "cancelled", , drop = FALSE]

  expect_equal(nrow(eligible_roster), 5)
  expect_equal(nrow(recorded_sessions), 3)
  expect_equal(nrow(cancelled_sessions), 1)
  expect_equal(
    nrow(attendance),
    nrow(eligible_roster) * nrow(sessions)
  )
  expect_setequal(attendance$student_id, eligible_roster$student_id)
  expect_false("staff-001" %in% attendance$student_id)

  recorded_rows <- attendance$session_status == "recorded"
  cancelled_rows <- attendance$session_status == "cancelled"
  expect_false(any(is.na(attendance$present[recorded_rows])))
  expect_true(all(is.na(attendance$present[cancelled_rows])))

  for (i in seq_len(nrow(attendance))) {
    row <- attendance[i, , drop = FALSE]
    if (row$session_status == "cancelled") {
      next
    }
    roster_name <- eligible_roster$preferred_name[
      match(row$student_id, eligible_roster$student_id)
    ]
    observed_names <- observed$speaker[observed$session_id == row$session_id]
    expect_identical(row$present, roster_name %in% observed_names)
  }
})

test_that("attendance contract preserves denominator and threshold boundaries", {
  attendance <- read_attendance_contract("expected-attendance.csv")
  participants <- read_attendance_contract("expected-participants.csv")
  sessions <- read_attendance_contract("expected-sessions.csv")
  threshold <- 2 / 3

  recorded <- attendance$session_status == "recorded"
  derived_counts <- vapply(participants$student_id, function(student_id) {
    sum(attendance$present[
      attendance$student_id == student_id & recorded
    ])
  }, integer(1))

  expect_equal(participants$eligible_sessions, rep(3L, nrow(participants)))
  expect_equal(participants$sessions_attended, unname(derived_counts))
  expect_equal(
    participants$attendance_rate,
    participants$sessions_attended / participants$eligible_sessions,
    tolerance = 1e-9
  )
  expect_identical(
    participants$meets_threshold,
    participants$attendance_rate >= threshold
  )
  expect_true(participants$meets_threshold[participants$student_id == "student-002"])
  expect_true(participants$is_one_time_attendee[participants$student_id == "student-004"])
  expect_equal(participants$sessions_attended[participants$student_id == "student-005"], 0)

  cancelled <- sessions$status == "cancelled"
  expect_false(sessions$eligible[cancelled])
  expect_true(is.na(sessions$attended_count[cancelled]))
  expect_true(is.na(sessions$absent_count[cancelled]))
  expect_true(is.na(sessions$attendance_rate[cancelled]))
})

test_that("attendance contract distinguishes known nonparticipants and unknown speakers", {
  roster <- read_attendance_contract("roster.csv")
  observed <- read_attendance_contract("observed-speakers.csv")
  sessions <- read_attendance_contract("expected-sessions.csv")
  problems <- read_attendance_contract("expected-problems.csv")

  known_names <- roster$preferred_name
  unmatched <- observed[!observed$speaker %in% known_names, , drop = FALSE]

  expect_equal(unmatched$speaker, "Guest Nova")
  expect_equal(sessions$unmatched_speaker_count[sessions$session_id == "session-01"], 1)
  expect_equal(nrow(problems), 1)
  expect_equal(problems$code, "unmatched_speaker")
  expect_false(any(grepl("Guest Nova", problems$message, fixed = TRUE)))
  expect_false(any(grepl("Instructor Vale", problems$message, fixed = TRUE)))
})

test_that("attendance contract enumerates fail-fast cases", {
  invalid <- read_attendance_contract("invalid-cases.csv")

  expect_setequal(
    invalid$expected_class,
    c("engager_schema_error", "engager_input_error", "engager_unmatched_error")
  )
  expect_true(all(nzchar(invalid$case)))
  expect_true(all(nzchar(invalid$reason)))
  expect_true(any(invalid$case == "blank_student_id"))
  expect_true(any(invalid$case == "blank_preferred_name"))
  expect_true(any(invalid$case == "unmatched_stop"))
})
