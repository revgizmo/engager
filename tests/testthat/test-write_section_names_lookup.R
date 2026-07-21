test_that("write_section_names_lookup writes a CSV and returns a tibble", {
  temp_dir <- withr::local_tempdir()
  temp_file <- "test_section_names_lookup.csv"
  df <- tibble::tibble(
    course_section = c("101.A", "201.B"),
    day = c("Mon", "Tue"),
    time = c("09:00", "10:00"),
    course = c(101L, 201L),
    section = c("A", "B"),
    preferred_name = c("Alice", "Bob"),
    formal_name = c("Alice Smith", "Bob Jones"),
    transcript_name = c("Alice", "Bob"),
    student_id = c(1, 2)
  )
  result <- write_section_names_lookup(df, data_folder = temp_dir, section_names_lookup_file = temp_file)
  expect_true(file.exists(file.path(temp_dir, temp_file)))
  written <- readr::read_csv(file.path(temp_dir, temp_file), show_col_types = FALSE)
  expect_equal(nrow(written), 2)
  expect_equal(written$preferred_name, c("Alice", "Bob"))
})

test_that("write_section_names_lookup handles empty input", {
  temp_dir <- withr::local_tempdir()
  temp_file <- "test_section_names_lookup_empty.csv"
  df <- tibble::tibble(
    course_section = character(),
    day = character(),
    time = character(),
    course = integer(),
    section = character(),
    preferred_name = character(),
    formal_name = character(),
    transcript_name = character(),
    student_id = integer()
  )
  result <- write_section_names_lookup(df, data_folder = temp_dir, section_names_lookup_file = temp_file)
  expect_true(file.exists(file.path(temp_dir, temp_file)))
  written <- readr::read_csv(file.path(temp_dir, temp_file), show_col_types = FALSE)
  expect_equal(nrow(written), 0)
})

test_that("write_section_names_lookup handles invalid input gracefully", {
  temp_dir <- withr::local_tempdir()
  expect_null(
    write_section_names_lookup(
      NULL,
      data_folder = temp_dir,
      section_names_lookup_file = "should_not_exist.csv"
    )
  )
  expect_false(file.exists(file.path(temp_dir, "should_not_exist.csv")))
})

test_that("write_section_names_lookup requires explicit valid destinations", {
  temp_dir <- withr::local_tempdir()
  df <- tibble::tibble(
    course_section = "101.A",
    day = "Mon",
    time = "09:00",
    course = 101L,
    section = "A",
    preferred_name = "Alice",
    formal_name = "Alice Smith",
    transcript_name = "Alice",
    student_id = 1
  )
  nonexistent <- file.path(temp_dir, "not-created")
  ordinary_file <- file.path(temp_dir, "ordinary-file")
  file.create(ordinary_file)
  before <- list.files(temp_dir, all.files = TRUE, no.. = TRUE, recursive = TRUE)

  for (data_folder in list(NULL, "", NA_character_, character(), nonexistent, ordinary_file)) {
    expect_error(
      write_section_names_lookup(df, data_folder = data_folder),
      "data_folder"
    )
  }
  for (lookup_file in list(
    "", NA_character_, character(), c("one", "two"), 1,
    ".", "..", "nested/output.csv", "nested\\output.csv"
  )) {
    expect_error(
      write_section_names_lookup(
        df,
        data_folder = temp_dir,
        section_names_lookup_file = lookup_file
      ),
      "section_names_lookup_file"
    )
  }

  expect_identical(
    list.files(temp_dir, all.files = TRUE, no.. = TRUE, recursive = TRUE),
    before
  )
})
