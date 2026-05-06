test_that("load_roster enforces schema and parses aliases", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  dat <- tibble::tibble(
    preferred_name = c("Alice Smith", "Bob Jones"),
    student_id = c("S1", "S2"),
    formal_name = c("Alice A. Smith", NA_character_),
    transcript_name = c(NA_character_, NA_character_),
    aliases = c("A Smith; Alice S", "B Jones|Bobby")
  )
  readr::write_csv(dat, tmp)

  ro <- load_roster(tmp)
  expect_true("preferred_name" %in% names(ro))
  expect_true("student_id" %in% names(ro))
  expect_true("aliases" %in% names(ro))
  expect_equal(nrow(ro), 2)
  expect_equal(ro$preferred_name, c("Alice Smith", "Bob Jones"))
})

test_that("load_roster loads file even with invalid data (no schema enforcement)", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  dat <- tibble::tibble(
    preferred_name = c("", "Charlie"),
    student_id = c("S3", "S3")
  )
  readr::write_csv(dat, tmp)
  ro <- load_roster(tmp)
  expect_equal(nrow(ro), 2)
  expect_equal(ro$preferred_name, c(NA_character_, "Charlie"))
})

test_that("load_roster loads valid roster file and filters enrolled students", {
  # Create a temporary CSV file
  roster_content <- "student_id,name,enrolled\n1,Alice,TRUE\n2,Bob,FALSE\n3,Carol,TRUE"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$name, c("Alice", "Carol"))
  expect_true(all(result$enrolled))

  unlink(temp_file)
})

test_that("load_roster returns empty tibble if file does not exist", {
  temp_dir <- tempdir()
  result <- load_roster(data_folder = temp_dir, roster_file = "nonexistent.csv")
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("load_roster returns empty tibble if no students are enrolled", {
  roster_content <- "student_id,name,enrolled\n1,Alice,FALSE\n2,Bob,FALSE"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)

  unlink(temp_file)
})

test_that("load_roster returns all students if all are enrolled", {
  roster_content <- "student_id,name,enrolled\n1,Alice,TRUE\n2,Bob,TRUE"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true(all(result$enrolled))

  unlink(temp_file)
})

test_that("load_roster returns all students if enrolled column does not exist", {
  roster_content <- "student_id,name\n1,Alice\n2,Bob\n3,Carol"
  temp_dir <- tempdir()
  temp_file <- file.path(temp_dir, "roster.csv")
  writeLines(roster_content, temp_file)

  result <- load_roster(data_folder = temp_dir, roster_file = "roster.csv")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_equal(result$name, c("Alice", "Bob", "Carol"))
  expect_false("enrolled" %in% names(result))

  unlink(temp_file)
})
