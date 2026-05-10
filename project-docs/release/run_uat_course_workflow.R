#!/usr/bin/env Rscript

fail <- function(...) {
  stop(paste0(...), call. = FALSE)
}

pass <- function(message) {
  cat("[PASS] ", message, "\n", sep = "")
}

check <- function(condition, message) {
  if (!isTRUE(condition)) {
    fail("[FAIL] ", message)
  }
  pass(message)
}

non_empty_file <- function(path) {
  file.exists(path) && file.info(path)$size > 0
}

split_aliases <- function(x) {
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0) {
    return(character(0))
  }
  pieces <- unlist(strsplit(x, "[;|,]", perl = TRUE), use.names = FALSE)
  trimws(pieces[nzchar(trimws(pieces))])
}

contains_identifiers <- function(path, identifiers) {
  identifiers <- unique(identifiers[!is.na(identifiers) & nzchar(identifiers)])
  text <- tolower(paste(readLines(path, warn = FALSE), collapse = "\n"))
  identifiers[vapply(
    identifiers,
    function(identifier) grepl(tolower(identifier), text, fixed = TRUE),
    logical(1)
  )]
}

tail_file <- function(path, n = 40) {
  if (!file.exists(path)) {
    return(character(0))
  }
  lines <- readLines(path, warn = FALSE)
  utils::tail(lines, n)
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1 || args[[1]] %in% c("-h", "--help")) {
  cat(
    "Usage: Rscript project-docs/release/run_uat_course_workflow.R ",
    "/path/to/engager_0.1.0.tar.gz [output_dir]\n",
    sep = ""
  )
  quit(status = if (length(args) < 1) 1 else 0)
}

tarball <- normalizePath(args[[1]], mustWork = FALSE)
if (!file.exists(tarball)) {
  fail("Tarball does not exist: ", tarball)
}

timestamp <- format(Sys.time(), "%Y%m%d-%H%M%S")
tmp_root <- Sys.getenv("TMPDIR", unset = tempdir())
tmp_root <- normalizePath(tmp_root, mustWork = TRUE)
output_dir <- if (length(args) >= 2) {
  normalizePath(args[[2]], mustWork = FALSE)
} else {
  file.path(tmp_root, paste0("engager-uat-course-workflow-", timestamp))
}

artifact_dir <- file.path(output_dir, "artifacts")
local_lib <- file.path(output_dir, "library")
dir.create(artifact_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(local_lib, recursive = TRUE, showWarnings = FALSE)

cat("engager UAT course workflow\n")
cat("Tarball: ", tarball, "\n", sep = "")
cat("Output directory: ", output_dir, "\n", sep = "")

install_log <- file.path(output_dir, "install.log")
r_bin <- file.path(R.home("bin"), "R")
install_args <- c("CMD", "INSTALL", "--no-multiarch", "-l", local_lib, tarball)
install_status <- system2(r_bin, install_args, stdout = install_log, stderr = install_log)
if (!identical(install_status, 0L)) {
  cat(paste(tail_file(install_log), collapse = "\n"), "\n")
  fail("R CMD INSTALL failed; see ", install_log)
}
check(non_empty_file(install_log), "installed tarball into isolated library")

.libPaths(c(local_lib, .libPaths()))
options(engager.show_startup = FALSE)
suppressPackageStartupMessages(library(engager, lib.loc = local_lib))
installed_path <- normalizePath(find.package("engager", lib.loc = local_lib), mustWork = TRUE)
check(startsWith(installed_path, normalizePath(local_lib, mustWork = TRUE)), "loaded engager from isolated library")

pkg_version <- as.character(utils::packageVersion("engager", lib.loc = local_lib))
check(identical(pkg_version, "0.1.0"), paste0("installed package version is ", pkg_version))

test_transcript_dir <- system.file("extdata/test_transcripts", package = "engager")
check(dir.exists(test_transcript_dir), "discovered installed synthetic transcript fixture directory")

metadata_path <- file.path(test_transcript_dir, "metadata.csv")
roster_path <- file.path(test_transcript_dir, "ideal_course_roster.csv")
check(non_empty_file(metadata_path), "discovered installed transcript metadata fixture")
check(non_empty_file(roster_path), "discovered installed ideal course roster fixture")

ideal_files <- list.files(
  test_transcript_dir,
  pattern = "^ideal_course_session[0-9]+[.]vtt$",
  full.names = TRUE
)
ideal_files <- sort(ideal_files)
check(length(ideal_files) >= 3, "discovered installed ideal course VTT sessions")

loaded_transcripts <- lapply(ideal_files, engager::load_zoom_transcript)
check(
  all(vapply(loaded_transcripts, function(x) is.data.frame(x) && nrow(x) > 0, logical(1))),
  "loaded ideal course VTT files with transcript rows"
)

required_transcript_cols <- c("transcript_file", "name", "comment", "start", "end", "duration", "wordcount")
check(
  all(vapply(
    loaded_transcripts,
    function(x) all(required_transcript_cols %in% names(x)),
    logical(1)
  )),
  "loaded transcripts include expected transcript columns"
)

processed_transcripts <- lapply(
  ideal_files,
  engager::process_zoom_transcript,
  consolidate_comments = TRUE,
  add_dead_air = TRUE
)
check(
  all(vapply(processed_transcripts, function(x) is.data.frame(x) && nrow(x) > 0, logical(1))),
  "processed transcripts with consolidation and dead-air rows"
)

transcript_index <- tibble::tibble(
  transcript_file = basename(ideal_files),
  session_num = seq_along(ideal_files),
  course_section = "UAT-101"
)
metrics <- engager::summarize_transcript_files(
  transcript_file_names = transcript_index,
  data_folder = dirname(test_transcript_dir),
  transcripts_folder = basename(test_transcript_dir),
  names_to_exclude = c("dead_air")
)
check(tibble::is_tibble(metrics) && nrow(metrics) > 0, "summarized multiple transcript files")
check(sum(metrics$wordcount, na.rm = TRUE) > 0, "summary metrics contain non-empty word counts")

single_session_metrics <- engager::summarize_transcript_metrics(
  transcript_file_path = ideal_files[[1]],
  names_exclude = c("dead_air")
)
check(
  tibble::is_tibble(single_session_metrics) && nrow(single_session_metrics) > 0,
  "summarized a single transcript session"
)

roster <- engager::load_roster(roster_path)
check(is.data.frame(roster) && nrow(roster) > 0, "loaded installed ideal course roster")

matching_roster <- roster
matching_roster$student_id <- sprintf("UAT%03d", seq_len(nrow(matching_roster)))
matching_roster$aliases <- matching_roster$transcript_names

transcripts_for_matching <- tibble::as_tibble(do.call(rbind, loaded_transcripts))
transcripts_for_matching$speaker <- transcripts_for_matching$name
transcripts_for_matching$timestamp <- as.character(transcripts_for_matching$start)

match_result <- engager::match_names_workflow(
  transcripts_df = transcripts_for_matching,
  roster_df = matching_roster,
  options = list(match_strategy = "exact", include_name_hash = FALSE)
)
check(inherits(match_result, "engager_match"), "ran exact name matching workflow")
check(
  sum(!is.na(match_result$transcripts_with_ids$student_id)) > 0,
  "name matching linked at least one transcript speaker to the roster"
)

unresolved_public <- engager::detect_unmatched_names(
  transcripts_df = transcripts_for_matching,
  roster_df = matching_roster,
  options = list(match_strategy = "exact", include_name_hash = FALSE)
)
check(!"name_hash" %in% names(unresolved_public), "unresolved-name detection omits hashes by default")

unresolved_hashed <- engager::detect_unmatched_names(
  transcripts_df = transcripts_for_matching,
  roster_df = matching_roster,
  options = list(match_strategy = "exact", include_name_hash = TRUE)
)
unresolved_path <- file.path(artifact_dir, "unresolved_names_hashed.csv")
engager::write_unresolved(unresolved_hashed, unresolved_path, overwrite = TRUE)
check(non_empty_file(unresolved_path), "wrote hashed unresolved-name review file")

engagement_path <- file.path(artifact_dir, "engagement_metrics.csv")
session_summary_path <- file.path(artifact_dir, "session_summary_metrics.csv")
single_session_path <- file.path(artifact_dir, "single_session_metrics.csv")
engager::write_metrics(
  metrics,
  what = "engagement",
  path = engagement_path,
  comments_policy = "count"
)
engager::write_metrics(
  metrics,
  what = "session_summary",
  path = session_summary_path,
  comments_policy = "omit"
)
engager::write_metrics(
  single_session_metrics,
  what = "summary",
  path = single_session_path,
  comments_policy = "omit"
)
check(non_empty_file(engagement_path), "wrote engagement metrics CSV")
check(non_empty_file(session_summary_path), "wrote session summary CSV")
check(non_empty_file(single_session_path), "wrote single-session summary CSV")

exported_engagement <- utils::read.csv(engagement_path, check.names = FALSE)
check(!"comments" %in% names(exported_engagement), "exported engagement CSV omits raw transcript comments")
check(nrow(exported_engagement) > 0, "exported engagement CSV contains rows")

privacy_review <- engager::review_privacy_risks(
  metrics,
  institution_type = "educational",
  check_retention = TRUE,
  retention_period = "academic_year"
)
check(is.list(privacy_review) && "passed" %in% names(privacy_review), "ran privacy risk review")

privacy_report_path <- file.path(artifact_dir, "privacy_review_report.json")
privacy_report <- engager::generate_privacy_review_report(
  metrics,
  output_file = privacy_report_path,
  report_format = "json",
  institution_info = list(workflow = "engager course UAT", fixtures = "bundled synthetic")
)
check(is.list(privacy_report), "generated privacy review report object")
check(non_empty_file(privacy_report_path), "wrote privacy review report JSON")

identifier_values <- unique(c(
  roster$formal_name,
  split_aliases(roster$transcript_names),
  "Professor Ed"
))
identifier_values <- identifier_values[nchar(identifier_values) >= 4]
privacy_checked_paths <- c(engagement_path, session_summary_path, single_session_path, privacy_report_path)
identifier_hits <- unlist(lapply(privacy_checked_paths, contains_identifiers, identifiers = identifier_values))
check(
  length(identifier_hits) == 0,
  "exported summaries and privacy report do not contain obvious raw course identifiers"
)

all_vignettes <- utils::vignette(package = "engager")
check(!is.null(all_vignettes$results) && NROW(all_vignettes$results) > 0, "listed installed package vignettes")

required_vignettes <- c("getting-started", "essential-functions", "privacy-ethics-review")
for (required_vignette in required_vignettes) {
  vignette_result <- utils::vignette(required_vignette, package = "engager")
  vignette_info <- unclass(vignette_result)
  check(
    inherits(vignette_result, "vignette") &&
      !is.null(vignette_info$Dir) &&
      dir.exists(vignette_info$Dir) &&
      !is.null(vignette_info$File) &&
      nzchar(vignette_info$File),
    paste0("discovered installed vignette: ", required_vignette)
  )
}

evidence_path <- file.path(output_dir, "UAT_EVIDENCE.md")
evidence_lines <- c(
  "# engager Course Workflow UAT Evidence",
  "",
  paste0("- Package version: ", pkg_version),
  paste0("- Tarball: ", tarball),
  paste0("- Installed package path: ", installed_path),
  paste0("- R version: ", R.version.string),
  paste0("- Platform: ", R.version$platform),
  paste0("- Output directory: ", output_dir),
  paste0("- Transcript sessions loaded: ", length(ideal_files)),
  paste0("- Transcript rows loaded: ", nrow(transcripts_for_matching)),
  paste0("- Summary metric rows: ", nrow(metrics)),
  paste0("- Matched transcript rows: ", sum(!is.na(match_result$transcripts_with_ids$student_id))),
  paste0("- Unresolved speaker groups: ", nrow(unresolved_public)),
  paste0("- Privacy review passed field: ", privacy_review$passed),
  paste0("- Privacy review PII columns detected: ", paste(privacy_review$pii_detected, collapse = ", ")),
  "",
  "## Artifacts",
  "",
  paste0("- ", engagement_path),
  paste0("- ", session_summary_path),
  paste0("- ", single_session_path),
  paste0("- ", unresolved_path),
  paste0("- ", privacy_report_path),
  paste0("- ", install_log)
)
writeLines(evidence_lines, evidence_path)
check(non_empty_file(evidence_path), "wrote UAT evidence summary")

cat("\nUAT PASS\n")
cat("Output directory: ", output_dir, "\n", sep = "")
cat("Evidence: ", evidence_path, "\n", sep = "")
