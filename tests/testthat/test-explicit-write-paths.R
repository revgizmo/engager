test_that("write-capable helpers reject malformed destinations without side effects", {
  sandbox <- withr::local_tempdir()
  withr::local_dir(sandbox)
  before <- list.files(sandbox, all.files = TRUE, no.. = TRUE, recursive = TRUE)
  invalid_paths <- list(NULL, "", " ", NA_character_, character(), c("a", "b"), 1)
  data <- tibble::tibble(name = "Student_1", wordcount = 1L)

  for (path in invalid_paths) {
    expect_error(do.call(write_metrics, list(data = data, path = path)))
    expect_error(do.call(write_unresolved, list(
      unresolved_tbl = tibble::tibble(),
      path = path
    )))
    expect_error(write_lookup_transactional(data.frame(), path = path))
  }

  expect_identical(
    list.files(sandbox, all.files = TRUE, no.. = TRUE, recursive = TRUE),
    before
  )
})

test_that("optional writer destinations reject NA and whitespace before writing", {
  sandbox <- withr::local_tempdir()
  withr::local_dir(sandbox)
  before <- list.files(sandbox, all.files = TRUE, no.. = TRUE, recursive = TRUE)
  transcript_dir <- system.file("extdata/test_transcripts", package = "engager")
  review_data <- tibble::tibble(participant = "Student_1", wordcount = 1L)

  for (path in list(NA_character_, " ")) {
    expect_error(analyze_transcripts(transcript_dir, write = TRUE, output_path = path))
    expect_error(create_session_mapping(NULL, NULL, output_file = path))
    expect_error(generate_privacy_review_report(review_data, output_file = path))
  }

  expect_identical(
    list.files(sandbox, all.files = TRUE, no.. = TRUE, recursive = TRUE),
    before
  )
})

test_that("legacy writer helpers require explicit non-empty destinations", {
  sandbox <- withr::local_tempdir()
  withr::local_dir(sandbox)
  before <- list.files(sandbox, all.files = TRUE, no.. = TRUE, recursive = TRUE)
  summary_data <- tibble::tibble(name = "Student_1", wordcount = 1L)

  expect_error(load_cancelled_classes(
    data_folder = " ",
    write_blank_cancelled_classes = TRUE
  ))
  expect_error(load_cancelled_classes(
    data_folder = sandbox,
    cancelled_classes_file = " ",
    write_blank_cancelled_classes = TRUE
  ))
  expect_error(prompt_name_matching(
    "Unmatched Student",
    data_folder = " ",
    write_lookup = TRUE
  ))
  expect_error(prompt_name_matching(
    "Unmatched Student",
    data_folder = sandbox,
    section_names_lookup_file = NA_character_,
    write_lookup = TRUE
  ))
  expect_error(write_transcripts_summary(summary_data, data_folder = " "))
  expect_error(write_transcripts_summary(
    summary_data,
    data_folder = sandbox,
    transcripts_summary_file = NA_character_
  ))
  expect_error(write_transcripts_session_summary(summary_data, data_folder = " "))
  expect_error(write_transcripts_session_summary(
    summary_data,
    data_folder = sandbox,
    transcripts_session_summary_file = NA_character_
  ))
  expect_error(validate_directory_argument(" "))

  expect_identical(
    list.files(sandbox, all.files = TRUE, no.. = TRUE, recursive = TRUE),
    before
  )
})

test_that("explicit temporary destinations still write expected artifacts", {
  sandbox <- withr::local_tempdir()
  metrics_path <- file.path(sandbox, "metrics.csv")
  report_path <- file.path(sandbox, "privacy.txt")
  metrics <- tibble::tibble(name = "Student_1", wordcount = 1L)

  expect_s3_class(
    write_metrics(metrics, path = metrics_path, privacy_level = "mask"),
    "tbl_df"
  )
  report <- generate_privacy_review_report(
    tibble::tibble(participant = "Student_1", wordcount = 1L),
    output_file = report_path
  )

  expect_true(file.exists(metrics_path))
  expect_true(file.exists(report_path))
  expect_type(report, "list")
})
