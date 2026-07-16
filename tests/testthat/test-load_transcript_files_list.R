test_that("load_transcript_files_list lists transcript files correctly", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)

  # Create transcript, closed caption, and chat files
  transcript_file <- file.path(transcripts_dir, "GMT20240612-120000_Recording.transcript.vtt")
  cc_file <- file.path(transcripts_dir, "GMT20240612-120000_Recording.cc.vtt")
  chat_file <- file.path(transcripts_dir, "GMT20240612-120000_Recording.chat.vtt")
  file.create(transcript_file)
  file.create(cc_file)
  file.create(chat_file)

  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts"
  )

  expect_s3_class(result, "data.frame")
  expect_true("transcript_file" %in% names(result))
  expect_true("closed_caption_file" %in% names(result))
  expect_true("chat_file" %in% names(result))
  expect_true(grepl("transcript", result$transcript_file[1]))
  expect_true(grepl("cc", result$closed_caption_file[1]))
  expect_true(grepl("chat", result$chat_file[1]))

  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_transcript_files_list returns NULL if folder does not exist", {
  temp_dir <- tempdir()
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "nonexistent_folder"
  )
  expect_null(result)
})

test_that("load_transcript_files_list returns empty data.frame if no matching files", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  # No matching files in the folder
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts",
    transcript_files_names_pattern = "NO_MATCH"
  )
  expect_true(is.data.frame(result) && nrow(result) == 0)
  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_transcript_files_list groups non-Zoom transcript siblings by session key", {
  temp_dir <- tempfile()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  file.create(
    file.path(transcripts_dir, "session1.transcript.vtt"),
    file.path(transcripts_dir, "session1.cc.vtt"),
    file.path(transcripts_dir, "session1.chat.vtt")
  )

  expect_warning(
    result <- load_transcript_files_list(
      data_folder = temp_dir,
      transcripts_folder = "transcripts",
      transcript_files_names_pattern = "session1"
    ),
    "Recording time could not be parsed for 1 session"
  )

  expect_equal(nrow(result), 1)
  expect_equal(result$session_key, "session1")
  expect_equal(result$date_extract, "session1")
  expect_true(is.na(result$recording_start))
  expect_true(is.na(result$start_time_local))
  expect_equal(result$transcript_file, "session1.transcript.vtt")
  expect_equal(result$closed_caption_file, "session1.cc.vtt")
  expect_equal(result$chat_file, "session1.chat.vtt")
})

test_that("load_transcript_files_list orders known and unknown sessions deterministically", {
  temp_dir <- tempfile()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  file.create(
    file.path(transcripts_dir, "zeta.transcript.vtt"),
    file.path(transcripts_dir, "alpha.transcript.vtt"),
    file.path(transcripts_dir, "GMT20240612-130000_Recording.transcript.vtt"),
    file.path(transcripts_dir, "GMT20240612-120000_Recording.transcript.vtt")
  )

  load_sessions <- function() {
    load_transcript_files_list(
      data_folder = temp_dir,
      transcripts_folder = "transcripts",
      transcript_files_names_pattern = "[.]transcript[.]vtt$"
    )
  }

  expect_warning(
    first <- load_sessions(),
    "Recording time could not be parsed for 2 sessions"
  )
  expect_warning(
    second <- load_sessions(),
    "Recording time could not be parsed for 2 sessions"
  )

  expect_identical(first, second)
  expect_equal(
    first$session_key,
    c(
      "GMT20240612-120000_Recording",
      "GMT20240612-130000_Recording",
      "alpha",
      "zeta"
    )
  )
  expect_false(any(is.na(first$recording_start[1:2])))
  expect_true(all(is.na(first$recording_start[3:4])))
  expect_true(all(is.na(first$start_time_local[3:4])))
})

test_that("load_transcript_files_list handles empty folder gracefully", {
  temp_dir <- tempdir()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, showWarnings = FALSE)
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts"
  )
  expect_true(is.data.frame(result) && nrow(result) == 0)
  unlink(transcripts_dir, recursive = TRUE)
})

test_that("load_transcript_files_list handles empty transcripts folder", {
  # Create a temporary directory structure
  temp_dir <- tempfile()
  transcripts_dir <- file.path(temp_dir, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  # Create a non-matching file in the transcripts folder
  non_matching_file <- file.path(transcripts_dir, "non_matching_file.txt")
  writeLines("test content", non_matching_file)

  # Should return empty data.frame when no matching files are found
  result <- load_transcript_files_list(
    data_folder = temp_dir,
    transcripts_folder = "transcripts"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})
