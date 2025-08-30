test_that("ideal course transcripts parse", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  files <- file.path(dir, paste0("ideal_course_session", 1:3, ".vtt"))
  purrr::walk(files, function(f) {
    tr <- load_zoom_transcript(f)
    expect_s3_class(tr, "data.frame")
  })
})

test_that("name variations present in session2", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  tr <- load_zoom_transcript(file.path(dir, "ideal_course_session2.vtt"))
  expect_true("Samantha Smith" %in% tr$name)
  expect_true("Sam Smith (she/her)" %in% tr$name)
})

test_that("attendance gaps are present in session2", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  tr <- load_zoom_transcript(file.path(dir, "ideal_course_session2.vtt"))
  
  # Check for timing gaps (dead air periods)
  start_times <- as.numeric(tr$start)
  end_times <- as.numeric(tr$end)
  
  # There should be gaps between some entries
  # For example, between "Samantha Smith" at 00:00:06.700 and "Sam Smith (she/her)" at 00:00:20.000
  expect_true(any(diff(start_times) > 10)) # Gap of more than 10 seconds
})

test_that("guest speakers are present in session2", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  tr <- load_zoom_transcript(file.path(dir, "ideal_course_session2.vtt"))
  
  # Check for guest speakers
  expect_true("Guest Librarian Grace" %in% tr$name)
  expect_true("Guest Mentor Hank" %in% tr$name)
})

test_that("international names are handled correctly", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  tr <- load_zoom_transcript(file.path(dir, "ideal_course_session1.vtt"))
  
  # Check for international names
  expect_true("Jose Alvarez" %in% tr$name) # Accented name José -> Jose
  expect_true("A.J. Lopez" %in% tr$name)   # Hyphenated name
})

test_that("roster attendance patterns are reflected", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  
  # Load roster
  roster <- readr::read_csv(file.path(dir, "ideal_course_roster.csv"))
  
  # Check that students who attend session 1 are present
  session1_attendees <- roster$formal_name[grepl("1", roster$attends_sessions)]
  tr1 <- load_zoom_transcript(file.path(dir, "ideal_course_session1.vtt"))
  
  # Some attendees should be present (not all may speak)
  expect_true(length(intersect(session1_attendees, tr1$name)) > 0)
  
  # Check that students who don't attend session 3 are absent
  session3_attendees <- roster$formal_name[grepl("3", roster$attends_sessions)]
  tr3 <- load_zoom_transcript(file.path(dir, "ideal_course_session3.vtt"))
  
  # Students not attending session 3 should not be present
  non_attendees <- roster$formal_name[!grepl("3", roster$attends_sessions)]
  expect_true(length(intersect(non_attendees, tr3$name)) == 0)
})
