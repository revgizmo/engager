test_that("ideal course transcripts work with main package functions", {
  # Test that ideal course transcripts can be processed through the main workflow
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")

  # Load ideal course transcripts
  session1 <- load_zoom_transcript(file.path(dir, "ideal_course_session1.vtt"))
  session2 <- load_zoom_transcript(file.path(dir, "ideal_course_session2.vtt"))
  session3 <- load_zoom_transcript(file.path(dir, "ideal_course_session3.vtt"))

  # Test that transcripts load correctly
  expect_s3_class(session1, "tbl_df")
  expect_s3_class(session2, "tbl_df")
  expect_s3_class(session3, "tbl_df")

  # Test that transcripts have expected structure
  expected_cols <- c("transcript_file", "comment_num", "name", "comment", "start", "end", "duration", "wordcount")
  expect_true(all(expected_cols %in% names(session1)))
  expect_true(all(expected_cols %in% names(session2)))
  expect_true(all(expected_cols %in% names(session3)))

  # Test that transcripts contain data
  expect_gt(nrow(session1), 0)
  expect_gt(nrow(session2), 0)
  expect_gt(nrow(session3), 0)

  # Test that names are properly parsed
  expect_true(all(!is.na(session1$name)))
  expect_true(all(!is.na(session2$name)))
  expect_true(all(!is.na(session3$name)))

  # Test that timing information is valid
  expect_true(all(session1$duration >= 0, na.rm = TRUE))
  expect_true(all(session2$duration >= 0, na.rm = TRUE))
  expect_true(all(session3$duration >= 0, na.rm = TRUE))
})

test_that("ideal course transcripts demonstrate name variation handling", {
  # Test that the ideal course transcripts showcase name variation scenarios
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")

  # Load session 2 which has name variations
  session2 <- load_zoom_transcript(file.path(dir, "ideal_course_session2.vtt"))

  # Check for specific name variations
  names_in_session <- unique(session2$name)

  # Should have both formal and preferred name variations
  expect_true("Samantha Smith" %in% names_in_session)
  expect_true("Sam Smith (she/her)" %in% names_in_session)

  # Should have international names
  expect_true("Jose Alvarez" %in% names_in_session)
  expect_true("A.J. Lopez" %in% names_in_session)

  # Should have guest speakers
  expect_true("Guest Librarian Grace" %in% names_in_session)
  expect_true("Guest Mentor Hank" %in% names_in_session)
})
