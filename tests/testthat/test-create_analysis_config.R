test_that("create_analysis_config creates valid configuration with defaults", {
  config <- create_analysis_config()

  expect_type(config, "list")
  expect_named(config, c("course", "paths", "patterns", "reports", "analysis", "session_mapping"))

  # Check course section
  expect_named(config$course, c("dept", "semester_start", "session_length_hours", "instructor_name"))
  expect_equal(config$course$dept, "LTF")
  expect_equal(config$course$semester_start, "Jan 01, 2024")
  expect_equal(config$course$session_length_hours, 1.5)
  expect_equal(config$course$instructor_name, "Instructor")

  # Check paths section
  expect_named(config$paths, c(
    "data_folder", "transcripts_folder", "roster_file",
    "cancelled_classes_file", "names_lookup_file",
    "transcripts_session_summary_file", "transcripts_summary_file"
  ))
  expect_equal(config$paths$transcripts_folder, "test_transcripts")
  expect_equal(config$paths$roster_file, "test_transcripts/ideal_course_roster.csv")
  expect_equal(config$paths$names_lookup_file, "example_section_names_lookup.csv")

  # Check patterns section
  expect_named(config$patterns, c(
    "topic_split", "zoom_recordings_csv", "zoom_recordings_csv_col_names",
    "transcript_files_names", "dt_extract", "transcript_file_extension",
    "closed_caption_file_extension", "recording_start", "recording_start_format",
    "start_time_local_tzone"
  ))
  expect_equal(config$patterns$start_time_local_tzone, "America/Los_Angeles")
  expect_equal(config$patterns$transcript_files_names, "[.]vtt$")

  # Check reports section
  expect_named(config$reports, c("student_summary_report", "student_summary_report_folder"))
  expect_null(config$reports$student_summary_report)
  expect_null(config$reports$student_summary_report_folder)

  # Check analysis section
  expect_named(config$analysis, c("cancelled_classes_col_types", "section_names_lookup_col_types", "names_to_exclude"))
  expect_null(config$analysis$names_to_exclude)
})

test_that("create_analysis_config accepts custom parameters", {
  config <- create_analysis_config(
    dept = "MATH",
    semester_start_mdy = "Aug 28, 2024",
    scheduled_session_length_hours = 2.0,
    instructor_name = "Dr. Smith",
    data_folder = "custom_data",
    transcripts_folder = "zoom_files",
    start_time_local_tzone = "America/New_York",
    names_to_exclude = c("dead_air", "unknown")
  )

  expect_equal(config$course$dept, "MATH")
  expect_equal(config$course$semester_start, "Aug 28, 2024")
  expect_equal(config$course$session_length_hours, 2.0)
  expect_equal(config$course$instructor_name, "Dr. Smith")
  expect_equal(config$paths$data_folder, "custom_data")
  expect_equal(config$paths$transcripts_folder, "zoom_files")
  expect_equal(config$patterns$start_time_local_tzone, "America/New_York")
  expect_equal(config$analysis$names_to_exclude, c("dead_air", "unknown"))
})

test_that("create_analysis_config validates input parameters", {
  # Test invalid dept
  expect_error(create_analysis_config(dept = c("LTF", "MATH")), "dept must be a single character string")
  expect_error(create_analysis_config(dept = 123), "dept must be a single character string")

  # Test invalid semester_start_mdy
  expect_error(create_analysis_config(semester_start_mdy = c("Jan 01", "2024")), "semester_start_mdy must be a single character string")

  # Test invalid scheduled_session_length_hours
  expect_error(create_analysis_config(scheduled_session_length_hours = -1), "scheduled_session_length_hours must be a positive number")
  expect_error(create_analysis_config(scheduled_session_length_hours = 0), "scheduled_session_length_hours must be a positive number")
  expect_error(create_analysis_config(scheduled_session_length_hours = "1.5"), "scheduled_session_length_hours must be a positive number")

  # Test invalid instructor_name
  expect_error(create_analysis_config(instructor_name = c("Dr. Smith", "Dr. Jones")), "instructor_name must be a single character string")

  # Test invalid data_folder
  expect_error(create_analysis_config(data_folder = c("data1", "data2")), "data_folder must be a single character string")

  # Test invalid transcripts_folder
  expect_error(create_analysis_config(transcripts_folder = c("transcripts1", "transcripts2")), "transcripts_folder must be a single character string")

  # Test invalid start_time_local_tzone
  expect_error(create_analysis_config(start_time_local_tzone = c("America/Los_Angeles", "UTC")), "start_time_local_tzone must be a single character string")

  # Test invalid report template settings
  expect_error(create_analysis_config(student_summary_report = c("a", "b")), "student_summary_report must be NULL or a single character string")
  expect_error(create_analysis_config(student_summary_report_folder = c("a", "b")), "student_summary_report_folder must be NULL or a single character string")
})

test_that("create_analysis_config defaults discover bundled synthetic transcripts", {
  config <- create_analysis_config()

  expect_warning(
    transcript_files <- load_transcript_files_list(
      data_folder = config$paths$data_folder,
      transcripts_folder = config$paths$transcripts_folder,
      transcript_files_names_pattern = config$patterns$transcript_files_names,
      dt_extract_pattern = config$patterns$dt_extract,
      trnscrptflxtnsnpttrn = config$patterns$transcript_file_extension,
      clsdcptnflxtnsnpttrn = config$patterns$closed_caption_file_extension,
      recording_start_pattern = config$patterns$recording_start,
      recording_start_format = config$patterns$recording_start_format,
      start_time_local_tzone = config$patterns$start_time_local_tzone
    ),
    "Recording time could not be parsed for [0-9]+ sessions"
  )

  expect_gt(nrow(transcript_files), 0)
  expect_true("session_key" %in% names(transcript_files))
  expect_true("transcript_file" %in% names(transcript_files))
  expect_true(any(transcript_files$transcript_file == "intro_statistics_week1.vtt"))
  expect_true(any(is.na(transcript_files$recording_start)))
  expect_identical(
    is.na(transcript_files$recording_start),
    is.na(transcript_files$start_time_local)
  )
})

test_that("create_analysis_config works with edge cases", {
  # Test with very short session length
  config <- create_analysis_config(scheduled_session_length_hours = 0.5)
  expect_equal(config$course$session_length_hours, 0.5)

  # Test with very long session length
  config <- create_analysis_config(scheduled_session_length_hours = 4.0)
  expect_equal(config$course$session_length_hours, 4.0)

  # Test with empty names_to_exclude
  config <- create_analysis_config(names_to_exclude = character(0))
  expect_equal(config$analysis$names_to_exclude, character(0))

  # Test with single name in names_to_exclude
  config <- create_analysis_config(names_to_exclude = "dead_air")
  expect_equal(config$analysis$names_to_exclude, "dead_air")
})

test_that("create_analysis_config maintains all required parameters", {
  config <- create_analysis_config()

  # Verify all expected parameters are present
  expected_course_params <- c("dept", "semester_start", "session_length_hours", "instructor_name")
  expected_paths_params <- c(
    "data_folder", "transcripts_folder", "roster_file",
    "cancelled_classes_file", "names_lookup_file",
    "transcripts_session_summary_file", "transcripts_summary_file"
  )
  expected_patterns_params <- c(
    "topic_split", "zoom_recordings_csv", "zoom_recordings_csv_col_names",
    "transcript_files_names", "dt_extract", "transcript_file_extension",
    "closed_caption_file_extension", "recording_start", "recording_start_format",
    "start_time_local_tzone"
  )
  expected_reports_params <- c("student_summary_report", "student_summary_report_folder")
  expected_analysis_params <- c("cancelled_classes_col_types", "section_names_lookup_col_types", "names_to_exclude")

  expect_true(all(expected_course_params %in% names(config$course)))
  expect_true(all(expected_paths_params %in% names(config$paths)))
  expect_true(all(expected_patterns_params %in% names(config$patterns)))
  expect_true(all(expected_reports_params %in% names(config$reports)))
  expect_true(all(expected_analysis_params %in% names(config$analysis)))
})
