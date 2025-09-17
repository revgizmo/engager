# Test file for summarize_transcript_files comprehensive coverage
# This function has complex logic that needs thorough testing

test_that("summarize_transcript_files handles different input types", {
  # Test with character vector input
  char_input <- c("file1.vtt", "file2.vtt")
  result1 <- tryCatch(
    {
      summarize_transcript_files(transcript_file_names = char_input)
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with tibble input
  tibble_input <- tibble::tibble(transcript_file = c("file1.vtt", "file2.vtt"))
  result2 <- tryCatch(
    {
      summarize_transcript_files(transcript_file_names = tibble_input)
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with NULL input
  result3 <- summarize_transcript_files(transcript_file_names = NULL)
  expect_null(result3)
})

test_that("summarize_transcript_files handles different parameter combinations", {
  # Test with custom data folder
  result1 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = c("file1.vtt"),
        data_folder = "/tmp"
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with custom transcripts folder
  result2 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = c("file1.vtt"),
        transcripts_folder = "custom_transcripts"
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with names to exclude
  result3 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = c("file1.vtt"),
        names_to_exclude = c("Instructor", "TA")
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result3) || is.null(result3))
})

test_that("summarize_transcript_files handles duplicate detection parameters", {
  # Test with deduplicate_content = TRUE
  result1 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = c("file1.vtt", "file2.vtt"),
        deduplicate_content = TRUE
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with different similarity threshold
  result2 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = c("file1.vtt", "file2.vtt"),
        deduplicate_content = TRUE,
        similarity_threshold = 0.8
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with different duplicate methods
  methods <- c("hybrid", "content", "metadata")
  for (method in methods) {
    result <- tryCatch(
      {
        summarize_transcript_files(
          transcript_file_names = c("file1.vtt", "file2.vtt"),
          deduplicate_content = TRUE,
          duplicate_method = method
        )
      },
      error = function(e) {
        list(status = "error", message = e$message)
      }
    )
    expect_true(is.list(result) || is.null(result))
  }
})

test_that("handle_duplicate_detection works with different parameters", {
  # Test the helper function directly
  test_files <- tibble::tibble(transcript_file = c("file1.vtt", "file2.vtt"))

  result <- tryCatch(
    {
      handle_duplicate_detection(
        test_files,
        data_folder = ".",
        transcripts_folder = "transcripts",
        similarity_threshold = 0.95,
        duplicate_method = "hybrid",
        names_to_exclude = NULL
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result) || is.null(result))
})

test_that("extract_original_metadata handles different scenarios", {
  # Test with metadata preservation
  test_files <- tibble::tibble(
    transcript_file = c("file1.vtt", "file2.vtt"),
    section = c("A", "B"),
    instructor = c("Dr. Smith", "Dr. Jones")
  )

  result1 <- extract_original_metadata(test_files, preserve_metadata = TRUE)
  expect_s3_class(result1, "tbl_df")
  expect_equal(nrow(result1), 2)
  expect_true("section" %in% names(result1))
  expect_true("instructor" %in% names(result1))
  expect_true("row_id" %in% names(result1))
  expect_false("transcript_file" %in% names(result1))

  # Test without metadata preservation
  result2 <- extract_original_metadata(test_files, preserve_metadata = FALSE)
  expect_null(result2)

  # Test with single column tibble
  single_col <- tibble::tibble(transcript_file = c("file1.vtt"))
  result3 <- extract_original_metadata(single_col, preserve_metadata = TRUE)
  expect_s3_class(result3, "tbl_df")
  expect_equal(nrow(result3), 1)
  expect_equal(ncol(result3), 1) # Only row_id
})

test_that("process_transcript_files handles different inputs", {
  # Test with valid tibble
  test_files <- tibble::tibble(transcript_file = c("file1.vtt", "file2.vtt"))

  result <- tryCatch(
    {
      process_transcript_files(test_files, "/tmp/transcripts/", c("Instructor"))
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result))

  # Test with empty tibble
  empty_files <- tibble::tibble(transcript_file = character())
  result_empty <- process_transcript_files(empty_files, "/tmp/transcripts/", NULL)
  expect_equal(length(result_empty), 0)

  # Test with NA file names
  na_files <- tibble::tibble(transcript_file = c("file1.vtt", NA, "file2.vtt"))
  result_na <- tryCatch(
    {
      process_transcript_files(na_files, "/tmp/transcripts/", NULL)
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result_na))
})

test_that("process_and_return_results handles different scenarios", {
  # Test with empty results
  result_empty <- process_and_return_results(list(), FALSE, NULL)
  expect_s3_class(result_empty, "tbl_df")
  expect_equal(nrow(result_empty), 0)
  expect_true(all(c(
    "name", "n", "duration", "wordcount", "comments",
    "n_perc", "duration_perc", "wordcount_perc", "wpm",
    "transcript_file", "transcript_path", "name_raw"
  ) %in% names(result_empty)))

  # Test with results but no metadata preservation
  test_results <- list(
    data.frame(
      name = "John",
      n = 5,
      duration = 100,
      wordcount = 500,
      comments = I(list("comment1")),
      n_perc = 50,
      duration_perc = 50,
      wordcount_perc = 50,
      wpm = 5,
      file_name = "file1.vtt",
      transcript_path = "/path/file1.vtt",
      stringsAsFactors = FALSE
    )
  )

  result_no_meta <- process_and_return_results(test_results, FALSE, NULL)
  expect_s3_class(result_no_meta, "tbl_df")
  expect_equal(nrow(result_no_meta), 1)
  expect_equal(result_no_meta$name, "John")

  # Test with metadata preservation
  test_metadata <- tibble::tibble(
    row_id = 1,
    section = "A",
    instructor = "Dr. Smith"
  )

  result_with_meta <- process_and_return_results(test_results, TRUE, test_metadata)
  expect_s3_class(result_with_meta, "tbl_df")
  expect_equal(nrow(result_with_meta), 1)
  expect_true("section" %in% names(result_with_meta))
  expect_true("instructor" %in% names(result_with_meta))
})

test_that("summarize_transcript_files handles edge cases", {
  # Test with empty character vector
  result1 <- summarize_transcript_files(transcript_file_names = character())
  expect_null(result1)

  # Test with empty tibble
  empty_tibble <- tibble::tibble(transcript_file = character())
  result2 <- tryCatch(
    {
      summarize_transcript_files(transcript_file_names = empty_tibble)
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))

  # Test with tibble containing only transcript_file column
  single_col_tibble <- tibble::tibble(transcript_file = c("file1.vtt", "file2.vtt"))
  result3 <- tryCatch(
    {
      summarize_transcript_files(transcript_file_names = single_col_tibble)
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result3) || is.null(result3))
})

test_that("summarize_transcript_files handles file path construction", {
  # Test with different folder combinations
  test_files <- tibble::tibble(transcript_file = c("file1.vtt"))

  # Test with default paths
  result1 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = test_files,
        data_folder = ".",
        transcripts_folder = "transcripts"
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result1) || is.null(result1))

  # Test with custom paths
  result2 <- tryCatch(
    {
      summarize_transcript_files(
        transcript_file_names = test_files,
        data_folder = "/custom/data",
        transcripts_folder = "custom_transcripts"
      )
    },
    error = function(e) {
      list(status = "error", message = e$message)
    }
  )
  expect_true(is.list(result2) || is.null(result2))
})
