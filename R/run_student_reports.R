#' Run student summary reports
#'
#' Render the packaged student summary R Markdown template for each student in
#' each section.
#'
#' @param df_sections Tibble with a `section` column listing sections to render.
#' @param df_roster Tibble with columns `section` and `preferred_name`.
#' @param data_folder Directory containing summary CSVs and where reports are written.
#' @param transcripts_session_summary_file Name of the session summary CSV file.
#' @param transcripts_summary_file Name of the summary CSV file.
#' @param student_summary_report Name of the report template file.
#' @param student_summary_report_folder Folder containing the template file.
#' @param output_format Output format passed to [rmarkdown::render()].
#'
#' @return Invisibly, a character vector of generated report paths.
#' @export
#'
#' @examples
#' \dontrun{
#' run_student_reports(
#'   df_sections = tibble::tibble(section = 1),
#'   df_roster = tibble::tibble(section = 1, preferred_name = "Alice"),
#'   data_folder = tempdir()
#' )
#' }
run_student_reports <- function(
    df_sections,
    df_roster,
    data_folder,
    transcripts_session_summary_file = "transcripts_session_summary.csv",
    transcripts_summary_file = "transcripts_summary.csv",
    student_summary_report = "Zoom_Student_Engagement_Analysis_student_summary_report.Rmd",
    student_summary_report_folder = system.file("", package = "zoomstudentengagement"),
    output_format = NULL) {
  template <- file.path(student_summary_report_folder, student_summary_report)
  outputs <- character(0)
  for (section in df_sections$section) {
    target_section <- section
    # Use base R operations to avoid dplyr segfault issues
    section_mask <- df_roster$section == target_section
    target_students <- df_roster$preferred_name[section_mask]
    target_students <- c("All Students", target_students)
    base_name <- tools::file_path_sans_ext(basename(student_summary_report))
    for (target_student in target_students) {
      output_file <- file.path(
        data_folder,
        sprintf("%s - section %s - %s.html", base_name, target_section, target_student)
      )
      # Add error handling for R Markdown rendering
      tryCatch(
        {
          rmarkdown::render(
            template,
            params = list(
              target_section = target_section,
              target_student = target_student,
              data_folder = data_folder,
              transcripts_session_summary_file = transcripts_session_summary_file,
              transcripts_summary_file = transcripts_summary_file
            ),
            output_file = output_file,
            output_format = output_format
          )
        },
        error = function(e) {
          warning(sprintf(
            "Failed to render report for section %s, student %s: %s",
            target_section, target_student, e$message
          ))
          # Create a simple error report instead
          error_content <- sprintf(
            "Error generating report for section %s, student %s: %s",
            target_section, target_student, e$message
          )
          writeLines(error_content, output_file)
        }
      )
      outputs <- c(outputs, output_file)
    }
  }
  invisible(outputs)
}
