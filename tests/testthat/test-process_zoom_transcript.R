test_that("process_zoom_transcript handles basic transcript processing", {
  # Create sample transcript data
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c("Student1", "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

  # Test basic processing
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )

  # Check basic structure
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("begin", "end", "name", "comment", "duration") %in% names(result)))
  expect_equal(nrow(result), 3)
})

test_that("process_zoom_transcript consolidates comments correctly", {
  # Create sample transcript data
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c("Student1", "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

  # Test comment consolidation
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = TRUE,
    max_pause_sec = 2,
    add_dead_air = FALSE
  )

  # Check that comments are not consolidated since the gap is too large
  expect_equal(nrow(result), 3) # Should have 3 rows since gap between Student1's comments is 7s > max_pause_sec of 2s
})

test_that("process_zoom_transcript adds dead air correctly", {
  # Create sample transcript data
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c("Student1", "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

  # Test dead air addition
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = TRUE
  )

  # Check that dead air rows are added
  expect_true(any(result$name == "dead_air"))
})

test_that("process_zoom_transcript handles NA names correctly", {
  # Create sample transcript with NA names
  sample_transcript <- tibble::tibble(
    transcript_file = "test_transcript.vtt",
    comment_num = 1:3,
    name = c(NA, "Student2", "Student1"),
    comment = c("Hello", "Hi there", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13")),
    duration = c(3, 3, 3)
  )

  # Test NA name handling
  result <- process_zoom_transcript(
    transcript_df = sample_transcript,
    consolidate_comments = FALSE,
    add_dead_air = FALSE,
    na_name = "unknown"
  )

  # Check that NA names are replaced
  expect_equal(result$name[1], "unknown")
})

test_that("process_zoom_transcript handles empty input gracefully", {
  # Test with empty data frame
  empty_df <- tibble::tibble(
    transcript_file = character(),
    comment_num = integer(),
    name = character(),
    comment = character(),
    start = hms::hms(),
    end = hms::hms(),
    duration = numeric()
  )

  result <- process_zoom_transcript(
    transcript_df = empty_df,
    consolidate_comments = FALSE,
    add_dead_air = FALSE
  )

  expect_equal(nrow(result), 0)
})

test_that("process_zoom_transcript returns NULL when no file and no df", {
  expect_null(process_zoom_transcript(transcript_file_path = ""))
})

test_that("process_zoom_transcript processes provided tibble and respects toggles", {
  df <- tibble::tibble(
    transcript_file = "f.vtt",
    comment_num = c(1, 2, 3),
    name = c("Alice", "Alice", NA),
    comment = c("Hi", "there", "..."),
    start = c(hms::as_hms(0), hms::as_hms(1), hms::as_hms(5)),
    end = c(hms::as_hms(1), hms::as_hms(2), hms::as_hms(6)),
    duration = c(1, 1, 1)
  )

  # Stub internal helpers to avoid dependence and ensure branch coverage
  with_mocked_bindings(
    consolidate_transcript = function(transcript_df, max_pause_sec = 1) {
      # Combine first two rows when same speaker within pause
      transcript_df$comment[2] <- paste(transcript_df$comment[1], transcript_df$comment[2])
      transcript_df <- transcript_df[-1, ]
      transcript_df
    },
    add_dead_air_rows = function(transcript_df, dead_air_name = "dead_air") {
      # Insert a dead_air row between 2 and 3
      dead <- transcript_df[2, ]
      dead$name <- dead_air_name
      dead$comment <- ""
      transcript_df <- rbind(transcript_df[1:2, ], dead, transcript_df[3, ])
      rownames(transcript_df) <- NULL
      transcript_df
    },
    {
      # Both toggles TRUE
      res1 <- process_zoom_transcript(transcript_df = df, consolidate_comments = TRUE, add_dead_air = TRUE)
      expect_s3_class(res1, "tbl_df")
      expect_true(any(res1$name == "dead_air"))
      expect_true(any(grepl("Hi there", res1$comment)))
      expect_true(all(!is.na(res1$comment_num)))

      # Consolidate only
      res2 <- process_zoom_transcript(transcript_df = df, consolidate_comments = TRUE, add_dead_air = FALSE)
      expect_false(any(res2$name == "dead_air"))
      expect_true(any(grepl("Hi there", res2$comment)))

      # Dead air only
      res3 <- process_zoom_transcript(transcript_df = df, consolidate_comments = FALSE, add_dead_air = TRUE)
      expect_true(any(res3$name == "dead_air"))

      # Neither
      res4 <- process_zoom_transcript(transcript_df = df, consolidate_comments = FALSE, add_dead_air = FALSE)
      expect_false(any(res4$name == "dead_air"))
      expect_false(any(grepl("Hi there", res4$comment)))

      # NA name replaced by na_name
      expect_true(any(res1$name == "unknown"))
    }
  )
})
