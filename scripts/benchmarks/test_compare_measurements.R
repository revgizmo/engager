#!/usr/bin/env Rscript
source("scripts/benchmarks/compare_measurements.R")

run_comparison_tests <- function() {
  contract <- comparison_contract()
  expected <- contract$measurement_expected()
  root <- tempfile("engager-comparison-tests-")
  stopifnot(dir.create(root))
  on.exit(unlink(root, recursive = TRUE))
  cases <- 0L
  check <- function(value) {
    stopifnot(isTRUE(value))
    cases <<- cases + 1L
  }
  # Fabricated validator fixtures only. No measured observations are committed.
  fixture <- function(run, multiplier = 1) {
    observations <- list()
    for (s in contract$benchmark_scenarios()) for (r in 1:5) {
      w <- expected[[s]]
      observations[[length(observations) + 1L]] <- list(
        scenario = s, repetition = r, workload = w,
        elapsed_seconds = r * multiplier, processed_files = w$expected_processed_files,
        output_rows = w$expected_output_rows, assertions_passed = TRUE,
        status = "passed", max_rss_kib = (1000 + r * 10) * multiplier)
    }
    list(schema_version = "1.0.0", metadata = list(
      commit = strrep(if (run == "100") "a" else "b", 40),
      package_version = "0.1.1", r_version = "4.6.1", os = "Linux",
      architecture = "x86_64", runner = "ubuntu-latest-X64",
      run_id = run, run_attempt = "1", measured_at_utc = "2026-09-08T00:00:00Z"),
      semantics = contract$measurement_semantics(), observations = observations,
      summaries = contract$measurement_summaries(observations),
      budgets_seconds = list(analyze_files_1 = 10, analyze_files_50 = 120,
                             analyze_files_500 = 1200), status = "passed")
  }
  write_fixture <- function(x) {
    path <- tempfile(tmpdir = root, fileext = ".json")
    jsonlite::write_json(x, path, auto_unbox = TRUE, digits = 17)
    list(path = path, hash = digest::digest(file = path, algo = "sha256"))
  }
  baseline <- fixture("100")
  candidate <- fixture("101", 2)
  a <- write_fixture(baseline)
  b <- write_fixture(candidate)
  invoke <- function(a, b, output = tempfile(tmpdir = root, fileext = ".json")) {
    status <- comparison_main(c(a$path, a$hash, b$path, b$hash, output))
    list(status = status, output = output,
         value = if (file.exists(output) && !dir.exists(output)) jsonlite::fromJSON(output, simplifyVector = FALSE) else NULL)
  }
  reject <- function(x, code = 2L) {
    result <- invoke(a, write_fixture(x))
    check(result$status == code)
    if (code == 2L) check(!file.exists(result$output))
    result
  }
  result <- invoke(a, b)
  check(result$status == 0L)
  check(result$value$disposition == "descriptive_only")
  check(result$value$regression_verdict == "not_assessed" && !result$value$trusted_baseline)
  check(length(result$value$limitations) == 4L)
  check(length(result$value$scenarios) == 6L)
  for (s in result$value$scenarios) {
    check(s$elapsed_seconds$median$baseline == 3 && s$elapsed_seconds$median$candidate == 6)
    check(s$elapsed_seconds$median$difference == 3 && s$elapsed_seconds$median$ratio == 2)
    check(s$max_rss_kib$median$baseline == 1030 && s$max_rss_kib$median$difference == 1030)
    check(s$elapsed_seconds$min$difference == 1 && s$elapsed_seconds$max$difference == 5)
  }
  reverse <- invoke(b, a)
  check(reverse$value$scenarios[[1]]$elapsed_seconds$median$difference == -3)
  check(reverse$value$scenarios[[1]]$elapsed_seconds$median$absolute_difference == 3)
  check(reverse$value$scenarios[[1]]$elapsed_seconds$median$ratio == 0.5)
  check(result$value$baseline$sha256 == a$hash && result$value$candidate$sha256 == b$hash)
  check(identical(result$value$baseline$metadata, baseline$metadata))
  check(identical(result$value$candidate$metadata, candidate$metadata))
  again <- invoke(a, b)
  check(identical(readBin(result$output, "raw", n = file.info(result$output)$size),
                  readBin(again$output, "raw", n = file.info(again$output)$size)))

  for (change in list(
    function(x) { x$observations <- x$observations[-1]; x },
    function(x) { x$observations[[2]] <- x$observations[[1]]; x },
    function(x) { x$observations[[1]]$scenario <- "unknown"; x },
    function(x) { x$observations[[1]]$max_rss_kib <- NULL; x },
    function(x) { x$observations[[1]]$assertions_passed <- FALSE; x },
    function(x) { x$observations[[1]]$output_rows <- 999; x },
    function(x) { x$observations[[1]]$workload$bytes <- 1020; x },
    function(x) { x$observations[[1]]$workload$sha256 <- strrep("c", 64); x },
    function(x) { x$observations[[1]]$elapsed_seconds <- -1; x },
    function(x) { x$observations[[1]]$elapsed_seconds <- "1"; x },
    function(x) { x$observations[[1]]$elapsed_seconds <- Inf; x },
    function(x) { x$summaries[[1]]$elapsed_seconds$median <- 9; x },
    function(x) { x$summaries[[1]]$elapsed_seconds$median <- 6 + 1e-10; x },
    function(x) { x$semantics$rss <- "other"; x },
    function(x) { x$budgets_seconds$analyze_files_1 <- 0.1; x },
    function(x) { x$metadata$runner <- "/private/input"; x },
    function(x) { x$metadata$commit <- "SyntheticSpeaker0"; x },
    function(x) { x$comment <- "private free text"; x },
    function(x) { names(x$observations) <- as.character(1:30); x },
    function(x) { x$schema_version <- "2.0.0"; x }
  )) reject(change(candidate))

  for (key in c("package_version", "r_version", "architecture", "runner")) {
    x <- candidate
    x$metadata[[key]] <- switch(key, package_version = "0.1.2", r_version = "4.5.3",
                               architecture = "aarch64", runner = "ubuntu-latest-ARM64")
    r <- reject(x, 3L)
    check(identical(r$value$reasons, list(paste0("environment_mismatch_", key))))
    check(length(r$value$scenarios) == 0L && r$value$disposition == "non_comparable")
  }
  x <- candidate
  x$metadata$r_version <- "4.5.3"
  x$metadata$runner <- "ubuntu-latest-ARM64"
  x$budgets_seconds$analyze_files_50 <- 121
  r <- reject(x, 3L)
  check(identical(r$value$reasons, list("environment_mismatch_r_version",
                                      "environment_mismatch_runner", "budget_mismatch")))
  same <- invoke(a, a)
  check(same$status == 3L)
  check(identical(same$value$reasons, list("identical_artifact", "same_run_identity")))
  x <- candidate
  x$metadata$run_id <- "100"
  r <- reject(x, 3L)
  check(identical(r$value$reasons, list("same_run_identity")))
  x$metadata$run_attempt <- "2"
  check(invoke(a, write_fixture(x))$status == 0L)
  x <- candidate
  x$metadata$commit <- baseline$metadata$commit
  x$metadata$measured_at_utc <- "2026-09-07T23:00:00Z"
  check(invoke(a, write_fixture(x))$status == 0L)
  x$metadata$run_id <- "local"
  check(identical(reject(x, 3L)$value$reasons, list("unverifiable_run_identity")))

  # Identical decoded content with different raw bytes retains different hashes.
  reencoded <- file.path(root, "reencoded.json")
  writeLines(paste0(paste(readLines(a$path), collapse = ""), " "), reencoded)
  a2 <- list(path = reencoded, hash = digest::digest(file = reencoded, algo = "sha256"))
  check(a2$hash != a$hash)
  check(identical(invoke(a, a2)$value$reasons, list("same_run_identity")))
  invalid <- list(path = b$path, hash = strrep("0", 64))
  check(invoke(a, invalid)$status == 2L)
  check(invoke(invalid, b)$status == 2L)
  invalid$hash <- "not-a-checksum"
  check(invoke(a, invalid)$status == 2L)
  invalid$path <- file.path(root, "absent.json")
  invalid$hash <- b$hash
  check(invoke(a, invalid)$status == 2L)
  malformed <- file.path(root, "malformed.json")
  for (text in c('{"broken":',
                 sub('"schema_version":"1.0.0"',
                     '"schema_version":"1.0.0","schema_version":"1.0.0"',
                     jsonlite::toJSON(candidate, auto_unbox = TRUE), fixed = TRUE))) {
    writeLines(text, malformed)
    m <- list(path = malformed, hash = digest::digest(file = malformed, algo = "sha256"))
    check(invoke(a, m)$status == 2L)
  }
  # Recompute summaries from new observations, including a zero timing baseline.
  zero <- baseline
  zero$observations <- lapply(zero$observations, function(o) { o$elapsed_seconds <- 0; o })
  zero$summaries <- contract$measurement_summaries(zero$observations)
  z <- invoke(write_fixture(zero), b)
  check(z$status == 0L && is.null(z$value$scenarios[[1]]$elapsed_seconds$median$ratio))
  check(z$value$scenarios[[1]]$elapsed_seconds$median$ratio_status == "zero_baseline")
  zero_candidate <- zero
  zero_candidate$metadata$run_id <- "102"
  z <- invoke(write_fixture(zero), write_fixture(zero_candidate))
  check(z$value$scenarios[[1]]$elapsed_seconds$median$ratio_status == "both_zero")
  check(is.null(z$value$scenarios[[1]]$elapsed_seconds$median$ratio))
  check(comparison_arithmetic(1e-300, 1e300)$ratio_status == "nonfinite_ratio")

  original_hash <- digest::digest(file = result$output, algo = "sha256")
  check(invoke(a, b, result$output)$status == 4L)
  check(digest::digest(file = result$output, algo = "sha256") == original_hash)
  check(invoke(a, b, a$path)$status == 4L)
  check(digest::digest(file = a$path, algo = "sha256") == a$hash)
  check(invoke(a, b, root)$status == 4L)
  check(invoke(a, b, file.path(root, "absent", "out.json"))$status == 4L)
  if (.Platform$OS.type == "unix") {
    link <- file.path(root, "dangling.json")
    target <- file.path(root, "not-created.json")
    check(file.symlink(target, link))
    check(invoke(a, b, link)$status == 4L)
    check(!file.exists(target) && identical(Sys.readlink(link), target))
  }
  # Output consists only of validated provenance and generated numeric results.
  output_text <- paste(readLines(result$output), collapse = "\n")
  check(!grepl(root, output_text, fixed = TRUE))
  check(!grepl("SyntheticSpeaker|Professor Ed|WEBVTT|private free text|transcript_file", output_text))
  check(length(list.files(root, pattern = "^[.]comparison-", all.files = TRUE)) == 0L)
  check(comparison_main(character()) == 2L)

  # Real CLI exit codes and location-independent loading from a different cwd.
  cli <- file.path(comparison_root, "scripts/benchmarks/compare_measurements.R")
  old <- setwd(root)
  on.exit(setwd(old), add = TRUE, after = FALSE)
  log <- file.path(root, "cli.log")
  cli_out <- file.path(root, "cli.json")
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    shQuote(c(cli, a$path, a$hash, b$path, b$hash, cli_out)),
                    stdout = log, stderr = log)
  check(status == 0L && file.exists(cli_out))
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    shQuote(c(cli, a$path, a$hash, a$path, a$hash,
                              file.path(root, "cli-same.json"))), stdout = log, stderr = log)
  check(status == 3L)
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    shQuote(c(cli, a$path, strrep("0", 64), b$path, b$hash,
                              file.path(root, "cli-invalid.json"))), stdout = log, stderr = log)
  check(status == 2L && !file.exists(file.path(root, "cli-invalid.json")))
  check(!grepl(root, paste(readLines(log), collapse = "\n"), fixed = TRUE))
  cat("PASS: comparator;", cases, "checks; no measured data fixtures\n")
}

run_comparison_tests()
