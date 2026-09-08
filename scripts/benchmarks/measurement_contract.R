#!/usr/bin/env Rscript
source("scripts/benchmarks/bench_transcript_pipeline.R")

measurement_semantics <- function() {
  list(elapsed = "operation-wall-seconds-excludes-setup-and-assertions",
       rss = "absolute-process-peak-KiB-includes-interpreter-dependencies-input-operation-and-assertions",
       rss_method = "GNU-time-verbose-Linux", package_only_allocation = FALSE,
       isolation = "fresh-R-process-per-observation", regression_detection = FALSE)
}

measurement_keys <- function(x, keys) {
  stopifnot(is.list(x), !is.null(names(x)), !anyDuplicated(names(x)),
            identical(sort(names(x)), sort(keys)))
}

measurement_number <- function(x, integer = FALSE, positive = FALSE) {
  stopifnot(is.numeric(x), length(x) == 1L, is.finite(x), x >= 0)
  if (integer) stopifnot(x == floor(x))
  if (positive) stopifnot(x > 0)
}

measurement_token <- function(x, pattern = "^[A-Za-z0-9][A-Za-z0-9_.-]{0,127}$") {
  stopifnot(is.character(x), length(x) == 1L, !is.na(x), grepl(pattern, x))
}

measurement_metadata <- function() {
  commit <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  stopifnot(is.null(attr(commit, "status")))
  list(commit = commit, package_version = as.character(utils::packageVersion("engager")),
       r_version = as.character(getRversion()), os = unname(Sys.info()[["sysname"]]),
       architecture = R.version$arch,
       runner = Sys.getenv("BENCHMARK_RUNNER", "local"),
       run_id = Sys.getenv("GITHUB_RUN_ID", "local"),
       run_attempt = Sys.getenv("GITHUB_RUN_ATTEMPT", "local"),
       measured_at_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
}

measurement_validate_metadata <- function(x) {
  measurement_keys(x, c("commit", "package_version", "r_version", "os", "architecture",
                        "runner", "run_id", "run_attempt", "measured_at_utc"))
  measurement_token(x$commit, "^[a-f0-9]{40}$")
  for (key in c("package_version", "r_version")) {
    measurement_token(x[[key]], "^[0-9]+([.-][0-9]+)*$")
  }
  measurement_token(x$os, "^(Linux|Darwin|Windows)$")
  measurement_token(x$architecture, "^(x86_64|aarch64|arm64|i386)$")
  measurement_token(x$runner, "^(local|ubuntu-latest-(X64|ARM64))$")
  for (key in c("run_id", "run_attempt")) measurement_token(x[[key]], "^(local|[0-9]+)$")
  measurement_token(x$measured_at_utc, "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
}

measurement_validate_observation <- function(x, expected = NULL, rss = TRUE) {
  keys <- c("scenario", "repetition", "workload", "elapsed_seconds", "processed_files",
            "output_rows", "assertions_passed", "status")
  if (rss) keys <- c(keys, "max_rss_kib")
  measurement_keys(x, keys)
  benchmark_identity(x$scenario, x$repetition)
  measurement_number(x$elapsed_seconds)
  if (rss) measurement_number(x$max_rss_kib, integer = TRUE, positive = TRUE)
  w <- x$workload
  measurement_keys(w, c("generator", "file_count", "bytes", "rows", "cues", "speakers",
                        "target_bytes", "last_cue_bytes", "sha256",
                        "expected_processed_files", "expected_output_rows"))
  stopifnot(w$generator %in% c("synthetic-v1", "bundled-ideal-session1-v1"))
  measurement_token(w$sha256, "^(none|[a-f0-9]{64})$")
  for (k in setdiff(names(w), c("generator", "sha256"))) measurement_number(w[[k]], TRUE)
  if (!is.null(expected)) stopifnot(isTRUE(all.equal(w, expected, check.attributes = TRUE)))
  measurement_number(x$processed_files, TRUE)
  measurement_number(x$output_rows, TRUE, TRUE)
  stopifnot(x$processed_files == w$expected_processed_files,
            x$output_rows == w$expected_output_rows,
            identical(x$assertions_passed, TRUE), identical(x$status, "passed"))
  invisible(TRUE)
}

measurement_parse_rss <- function(lines) {
  rss <- grep("Maximum resident set size", lines, value = TRUE, fixed = TRUE)
  exit <- grep("Exit status:", lines, value = TRUE, fixed = TRUE)
  stopifnot(length(rss) == 1L, length(exit) == 1L,
            grepl("^[[:space:]]*Maximum resident set size \\(kbytes\\): [0-9]+$", rss),
            grepl("^[[:space:]]*Exit status: 0$", exit))
  value <- as.numeric(sub(".*: ", "", rss))
  measurement_number(value, integer = TRUE, positive = TRUE)
  value
}

measurement_summaries <- function(observations) {
  lapply(benchmark_scenarios(), function(scenario) {
    obs <- Filter(function(x) x$scenario == scenario, observations)
    stopifnot(length(obs) == 5L,
              identical(sort(vapply(obs, function(x) as.integer(x$repetition), 1L)), 1:5))
    stats <- function(key) {
      values <- vapply(obs, function(x) x[[key]], 0)
      list(median = stats::median(values), min = min(values), max = max(values))
    }
    list(scenario = scenario, observations = 5L,
         elapsed_seconds = stats("elapsed_seconds"), max_rss_kib = stats("max_rss_kib"))
  })
}

measurement_expected <- function() {
  root <- tempfile("engager-contract-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE))
  setNames(lapply(benchmark_scenarios(), function(s) {
    path <- file.path(root, s)
    dir.create(path)
    benchmark_input(s, path)$workload
  }), benchmark_scenarios())
}

measurement_validate <- function(x, expected = measurement_expected()) {
  measurement_keys(x, c("schema_version", "metadata", "semantics", "observations", "summaries", "budgets_seconds", "status"))
  stopifnot(identical(x$schema_version, "1.0.0"), identical(x$status, "passed"),
            identical(x$semantics, measurement_semantics()))
  measurement_validate_metadata(x$metadata)
  stopifnot(identical(x$metadata$os, "Linux"), is.list(x$observations), length(x$observations) == 30L,
            is.null(names(x$observations)), is.list(x$summaries),
            is.null(names(x$summaries)))
  for (o in x$observations) {
    benchmark_identity(o$scenario, o$repetition)
    measurement_validate_observation(o, expected[[o$scenario]])
  }
  stopifnot(isTRUE(all.equal(x$summaries, measurement_summaries(x$observations), check.attributes = TRUE)))
  measurement_keys(x$budgets_seconds, benchmark_scenarios()[1:3])
  for (s in names(x$budgets_seconds)) {
    measurement_number(x$budgets_seconds[[s]], positive = TRUE)
    stopifnot(all(vapply(Filter(function(o) o$scenario == s, x$observations),
                         function(o) o$elapsed_seconds <= x$budgets_seconds[[s]], TRUE)))
  }
  invisible(TRUE)
}

measurement_read <- function(path) {
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  stopifnot(jsonlite::validate(text))
  jsonlite::fromJSON(text, simplifyVector = FALSE)
}

measurement_run <- function(output) {
  benchmark_dependencies()
  stopifnot(identical(Sys.info()[["sysname"]], "Linux"), file.exists("/usr/bin/time"),
            !file.exists(output), dir.exists(dirname(output)))
  version <- system2("/usr/bin/time", "--version", stdout = TRUE, stderr = TRUE)
  stopifnot(is.null(attr(version, "status")), any(grepl("GNU", version)))
  metadata <- measurement_metadata()
  measurement_validate_metadata(metadata)
  expected <- measurement_expected()
  scratch <- tempfile("engager-measurements-")
  dir.create(scratch)
  on.exit(unlink(scratch, recursive = TRUE))
  observations <- list()
  for (scenario in benchmark_scenarios()) for (repetition in seq_len(5)) {
    result_path <- file.path(scratch, "worker.json")
    rss_path <- file.path(scratch, "time.txt")
    log_path <- file.path(scratch, "worker.log")
    unlink(c(result_path, rss_path, log_path))
    status <- system2("/usr/bin/time", c("-v", "-o", shQuote(rss_path),
      shQuote(file.path(R.home("bin"), "Rscript")), "--vanilla",
      "scripts/benchmarks/measurement_contract.R", "worker", scenario,
      repetition, shQuote(result_path)), stdout = log_path, stderr = log_path,
      env = "LC_ALL=C")
    stopifnot(status == 0L, file.exists(result_path), file.exists(rss_path))
    o <- measurement_read(result_path)
    measurement_validate_observation(o, expected[[scenario]], rss = FALSE)
    stopifnot(identical(o$scenario, scenario), o$repetition == repetition)
    o$max_rss_kib <- measurement_parse_rss(readLines(rss_path))
    measurement_validate_observation(o, expected[[scenario]])
    observations[[length(observations) + 1L]] <- o
    cat(scenario, repetition, "passed\n")
  }
  budgets <- setNames(lapply(c(1, 50, 500), function(n) {
    value <- as.numeric(Sys.getenv(paste0("BUDGET_", n),
                                  as.character(c(`1` = 10, `50` = 120, `500` = 1200)[as.character(n)])))
    measurement_number(value, positive = TRUE)
    value
  }), benchmark_scenarios()[1:3])
  result <- list(schema_version = "1.0.0", metadata = metadata,
                 semantics = measurement_semantics(), observations = observations,
                 summaries = measurement_summaries(observations),
                 budgets_seconds = budgets, status = "passed")
  measurement_validate(result, expected)
  candidate <- file.path(scratch, "validated.json")
  jsonlite::write_json(result, candidate, auto_unbox = TRUE, pretty = TRUE, digits = NA)
  measurement_validate(measurement_read(candidate), expected)
  stopifnot(file.copy(candidate, output, overwrite = FALSE))
  invisible(result)
}

measurement_main <- function(args) {
  benchmark_dependencies()
  stopifnot(length(args) >= 1L)
  if (identical(args[[1]], "worker")) {
    stopifnot(length(args) == 4L, grepl("^[1-5]$", args[[3]]))
    o <- benchmark_observation(args[[2]], as.integer(args[[3]]))
    measurement_validate_observation(o, rss = FALSE)
    jsonlite::write_json(o, args[[4]], auto_unbox = TRUE, digits = NA)
  } else if (identical(args[[1]], "run")) {
    stopifnot(length(args) == 2L)
    measurement_run(args[[2]])
  } else if (identical(args[[1]], "validate")) {
    stopifnot(length(args) == 2L)
    measurement_validate(measurement_read(args[[2]]))
    cat("Measurement artifact validated: 30 observations, six summaries\n")
  } else stop("Invalid measurement command")
}

if (sys.nframe() == 0L) measurement_main(commandArgs(trailingOnly = TRUE))
