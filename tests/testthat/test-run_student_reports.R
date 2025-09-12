test_that("run_student_reports renders reports", {
  skip_if_not_installed("rmarkdown")
  temp_dir <- tempfile("zse_reports")
  dir.create(temp_dir)
  data_src <- system.file("extdata", package = "engager")
  file.copy(data_src, temp_dir, recursive = TRUE)
  df_sections <- tibble::tibble(section = "23.24")
  df_roster <- tibble::tibble(section = "23.24", preferred_name = "Conor Healy")
  outputs <- run_student_reports(
    df_sections = df_sections,
    df_roster = df_roster,
    data_folder = file.path(temp_dir, "extdata"),
    student_summary_report_folder = system.file("", package = "engager"),
    output_format = "html_document"
  )
  expect_true(all(file.exists(outputs)))
})
