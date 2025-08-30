test_that("ideal course transcripts parse", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  files <- file.path(dir, paste0("ideal_course_session", 1:3, ".vtt"))
  purrr::walk(files, function(f) {
    tr <- parse_zoom_transcript(f)
    expect_s3_class(tr, "data.frame")
  })
})

test_that("name variations present in session2", {
  dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")
  tr <- parse_zoom_transcript(file.path(dir, "ideal_course_session2.vtt"))
  expect_true("Samantha Smith" %in% tr$speaker)
  expect_true("Sam Smith (she/her)" %in% tr$speaker)
})
