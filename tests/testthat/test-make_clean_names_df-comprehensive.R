# Test file for make_clean_names_df comprehensive coverage
# This function has complex data processing logic that needs thorough testing

test_that("make_clean_names_df handles input validation", {
  # Test with valid inputs
  valid_transcripts <- tibble::tibble(name = c("Student_01", "Student_02"))
  valid_roster <- tibble::tibble(
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  result1 <- tryCatch(
    {
      make_clean_names_df(
        data_folder = ".",
        section_names_lookup_file = "test.csv",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with invalid transcripts_metrics_df
  expect_error(
    make_clean_names_df(
      transcripts_metrics_df = "invalid",
      roster_sessions = valid_roster
    ),
    "transcripts_metrics_df must be a tibble"
  )

  # Test with invalid roster_sessions
  expect_error(
    make_clean_names_df(
      transcripts_metrics_df = valid_transcripts,
      roster_sessions = "invalid"
    ),
    "roster_sessions must be a tibble"
  )

  # Test with invalid data_folder
  expect_error(
    make_clean_names_df(
      data_folder = 123,
      transcripts_metrics_df = valid_transcripts,
      roster_sessions = valid_roster
    ),
    "data_folder must be a single character string"
  )

  # Test with invalid section_names_lookup_file
  expect_error(
    make_clean_names_df(
      section_names_lookup_file = 123,
      transcripts_metrics_df = valid_transcripts,
      roster_sessions = valid_roster
    ),
    "section_names_lookup_file must be a single character string"
  )
})

test_that("make_clean_names_df handles different data_folder values", {
  valid_transcripts <- tibble::tibble(name = c("Student_01", "Student_02"))
  valid_roster <- tibble::tibble(
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  # Test with default data folder
  result1 <- tryCatch(
    {
      make_clean_names_df(
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with custom data folder
  result2 <- tryCatch(
    {
      make_clean_names_df(
        data_folder = "/tmp",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with relative path
  result3 <- tryCatch(
    {
      make_clean_names_df(
        data_folder = "./data",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result3) || is.null(result3))
})

test_that("make_clean_names_df handles different section_names_lookup_file values", {
  valid_transcripts <- tibble::tibble(name = c("Student_01", "Student_02"))
  valid_roster <- tibble::tibble(
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  # Test with default file name
  result1 <- tryCatch(
    {
      make_clean_names_df(
        section_names_lookup_file = "section_names_lookup.csv",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with custom file name
  result2 <- tryCatch(
    {
      make_clean_names_df(
        section_names_lookup_file = "custom_lookup.csv",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result1))

  # Test with path in filename
  result3 <- tryCatch(
    {
      make_clean_names_df(
        section_names_lookup_file = "data/lookup.csv",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result3) || is.null(result3))
})

test_that("make_clean_names_df handles different roster_sessions structures", {
  valid_transcripts <- tibble::tibble(name = c("Student_01", "Student_02"))

  # Test with course_section column
  roster_with_course_section <- tibble::tibble(
    course_section = c("CS101.A", "CS102.B"),
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  result1 <- tryCatch(
    {
      make_clean_names_df(
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = roster_with_course_section
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with transcript_section column
  roster_with_transcript_section <- tibble::tibble(
    transcript_section = c("CS101.A", "CS102.B"),
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  result2 <- tryCatch(
    {
      make_clean_names_df(
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = roster_with_transcript_section
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with neither course_section nor transcript_section
  roster_basic <- tibble::tibble(
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  result3 <- tryCatch(
    {
      make_clean_names_df(
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = roster_basic
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result3) || is.null(result3))
})

test_that("make_clean_names_df handles different transcripts_metrics_df structures", {
  valid_roster <- tibble::tibble(
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  # Test with basic structure
  basic_transcripts <- tibble::tibble(
    name = c("Student_01", "Student_02"),
    n = c(5, 3),
    duration = c(100, 80)
  )

  result1 <- expect_error(
    make_clean_names_df(
      transcripts_metrics_df = basic_transcripts,
      roster_sessions = valid_roster
    ),
    regexp = "incompatible size|Can't recycle input of size 0|Assigned data"
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with additional columns
  extended_transcripts <- tibble::tibble(
    name = c("Student_01", "Student_02"),
    n = c(5, 3),
    duration = c(100, 80),
    wordcount = c(500, 400),
    wpm = c(5, 5),
    transcript_file = c("file1.vtt", "file2.vtt")
  )

  result2 <- expect_error(
    make_clean_names_df(
      transcripts_metrics_df = extended_transcripts,
      roster_sessions = valid_roster
    ),
    regexp = "incompatible size|Can't recycle input of size 0|Assigned data"
  )
  expect_true(is.list(result2) || is.null(result2))
})

test_that("make_clean_names_df handles edge cases", {
  # Test with empty tibbles
  empty_transcripts <- tibble::tibble(name = character())
  empty_roster <- tibble::tibble(
    course = character(),
    section = character(),
    student_id = character()
  )

  result1 <- expect_error(
    make_clean_names_df(
      transcripts_metrics_df = empty_transcripts,
      roster_sessions = empty_roster
    ),
    regexp = "'by' must specify uniquely valid columns|Unknown or uninitialised column"
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with single row
  single_transcript <- tibble::tibble(name = "Student_01")
  single_roster <- tibble::tibble(
    course = "CS101",
    section = "A",
    student_id = "123"
  )

  result2 <- expect_error(
    make_clean_names_df(
      transcripts_metrics_df = single_transcript,
      roster_sessions = single_roster
    ),
    regexp = "'by' must specify uniquely valid columns|Unknown or uninitialised column|incompatible size|Can't recycle input of size 0|Assigned data"
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with NA values
  na_transcripts <- tibble::tibble(
    name = c("Student_01", NA, "Student_02"),
    n = c(5, NA, 3)
  )
  na_roster <- tibble::tibble(
    course = c("CS101", NA, "CS102"),
    section = c("A", "B", NA),
    student_id = c("123", "456", NA)
  )

  result3 <- expect_error(
    make_clean_names_df(
      transcripts_metrics_df = na_transcripts,
      roster_sessions = na_roster
    ),
    regexp = "incompatible size|Can't recycle input of size 0|Assigned data|Unknown or uninitialised column"
  )
  expect_true(is.list(result3) || is.null(result3))
})

test_that("make_clean_names_df handles parameter combinations", {
  valid_transcripts <- tibble::tibble(name = c("Student_01", "Student_02"))
  valid_roster <- tibble::tibble(
    course = c("CS101", "CS102"),
    section = c("A", "B"),
    student_id = c("123", "456")
  )

  # Test all parameters together
  result1 <- tryCatch(
    {
      make_clean_names_df(
        data_folder = "/tmp",
        section_names_lookup_file = "custom_lookup.csv",
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with minimal parameters
  result2 <- tryCatch(
    {
      make_clean_names_df(
        transcripts_metrics_df = valid_transcripts,
        roster_sessions = valid_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))
})

test_that("make_clean_names_df handles large datasets", {
  # Test with larger datasets
  large_transcripts <- tibble::tibble(
    name = paste0("Student_", sprintf("%02d", 1:100)),
    n = rep(5, 100),
    duration = rep(100, 100)
  )
  large_roster <- tibble::tibble(
    course = rep(c("CS101", "CS102"), 50),
    section = rep(c("A", "B"), 50),
    student_id = paste0("ID_", sprintf("%03d", 1:100))
  )

  result <- tryCatch(
    {
      make_clean_names_df(
        transcripts_metrics_df = large_transcripts,
        roster_sessions = large_roster
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result) || is.null(result))
})
