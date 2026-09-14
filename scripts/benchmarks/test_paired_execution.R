#!/usr/bin/env Rscript
# All numbers below are fabricated validator fixtures, never measurements.
source("scripts/benchmarks/paired_execution.R")
source("scripts/benchmarks/test_runtime_metadata.R")

paired_test_context <- function() list(repository = "synthetic/fixture", run_id = "100",
  run_attempt = "1", job = "paired_benchmarks", workflow = "paired-benchmarks.yaml",
  workflow_sha = strrep("a", 40))
paired_test_source <- function() list(commit = strrep("a", 40), tree = strrep("b", 40),
  harness = paired_manifest(paired_startup))
paired_test_measurement <- function(multiplier = 1) {
  c <- paired_contract
  expected <- c$measurement_expected()
  runtime <- runtime_test_fixture()
  runtime$harness <- c$runtime_manifest(c$measurement_source_bytes)
  observations <- list()
  for (s in c$benchmark_scenarios()) for (r in 1:5) {
    w <- expected[[s]]
    observations[[length(observations) + 1L]] <- list(scenario = s, repetition = r,
      workload = w, elapsed_seconds = r * multiplier,
      processed_files = w$expected_processed_files, output_rows = w$expected_output_rows,
      assertions_passed = TRUE, status = "passed", max_rss_kib = (1000 + 10 * r) * multiplier,
      runtime_start = runtime, runtime_end = runtime)
  }
  list(schema_version = "2.0.0", metadata = list(commit = strrep("a", 40),
    package_version = "0.1.1", r_version = "4.6.1", os = "Linux", architecture = "x86_64",
    runner = "ubuntu-latest-X64", run_id = "100", run_attempt = "1",
    measured_at_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
    runtime_start = runtime, runtime_end = runtime, semantics = c$measurement_semantics(),
    observations = observations, summaries = c$measurement_summaries(observations),
    budgets_seconds = list(analyze_files_1 = 10, analyze_files_50 = 120, analyze_files_500 = 1200),
    status = "passed")
}
paired_test_write <- function(value, path) {
  jsonlite::write_json(value, path, auto_unbox = TRUE, digits = 17, null = "null")
}
paired_test_child <- function(args) {
  stopifnot(length(args) == 4L)
  paired_block(args[[1]], args[[2]], args[[3]], args[[4]],
    measure = function(path) paired_test_write(
      paired_test_measurement(if (args[[1]] == "reference") 1 else 2), path),
    context = paired_test_context, source = paired_test_source)
}
paired_test_launch <- function(block, pair_id, previous, directory) {
  status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla",
    shQuote(file.path(paired_root, "scripts/benchmarks/test_paired_execution.R")),
    "child", block, pair_id, previous, shQuote(directory)), timeout = 60)
  stopifnot(status == 0L)
}
run_paired_tests <- function() {
  root <- tempfile("engager-paired-tests-")
  stopifnot(dir.create(root))
  on.exit(unlink(root, recursive = TRUE))
  cases <- 0L
  check <- function(value) { stopifnot(isTRUE(value)); cases <<- cases + 1L }
  fails <- function(expr) check(inherits(tryCatch(force(expr), error = identity), "error"))
  hash <- function(path) paired_hash(paired_contract$measurement_raw(path))
  output <- file.path(root, "actual-children")
  pair <- paired_run(output, paired_test_launch, paired_test_context, paired_test_source)
  check(file.exists(file.path(output, "pair.json")))
  check(pair$blocks[[1]]$invocation_id != pair$blocks[[2]]$invocation_id)
  check(pair$blocks[[1]]$finished_at_unix_ms <= pair$blocks[[2]]$started_at_unix_ms)
  measurements <- paired_inputs(pair, output)
  check("same_run_identity" %in% comparison_reasons(measurements[[1]], measurements[[2]], paired_contract))
  check(comparison_build(measurements[[1]], measurements[[2]], paired_contract)$disposition == "non_comparable")
  report_path <- file.path(root, "report.json")
  report <- paired_compare(file.path(output, "pair.json"), hash(file.path(output, "pair.json")), report_path)
  check(report$disposition == "descriptive_only")
  check(report$regression_verdict == "not_assessed" && !report$trusted_baseline)
  check(length(report$scenarios) == 6L)
  for (s in report$scenarios) {
    check(s$elapsed_seconds$median$difference == 3 && s$elapsed_seconds$median$ratio == 2)
    check(s$max_rss_kib$median$baseline == 1030 && s$max_rss_kib$median$candidate == 2060)
    check(s$elapsed_seconds$min$difference == 1 && s$elapsed_seconds$max$difference == 5)
  }
  reject_pair <- function(value) fails(paired_validate(value, measurements))
  for (key in names(pair)) { bad <- pair; bad[[key]] <- NULL; reject_pair(bad) }
  bad <- pair; bad$extra <- "free text"; reject_pair(bad)
  bad <- pair; names(bad)[[2]] <- names(bad)[[1]]; reject_pair(bad)
  bad <- pair; bad$paired_schema_version <- "2.0.0"; reject_pair(bad)
  bad <- pair; bad$status <- "partial"; reject_pair(bad)
  bad <- pair; bad$blocks <- rev(bad$blocks); reject_pair(bad)
  bad <- pair; bad$blocks <- bad$blocks[1]; reject_pair(bad)
  bad <- pair; names(bad$blocks) <- c("a", "b"); reject_pair(bad)
  for (key in names(pair$blocks[[2]])) {
    bad <- pair; bad$blocks[[2]][[key]] <- NULL; reject_pair(bad)
  }
  for (key in c("pair_id", "invocation_id", "measurement_sha256", "previous_measurement_sha256")) {
    for (value in list("", "local", strrep("x", 64), c(strrep("a", 64), strrep("b", 64)))) {
      bad <- pair; bad$blocks[[2]][[key]] <- value; reject_pair(bad)
    }
  }
  for (key in c("pair_id", "invocation_id", "measurement_sha256")) {
    bad <- pair
    bad$blocks[[2]][[key]] <- if (key == "pair_id") strrep("c", 64) else pair$blocks[[1]][[key]]
    reject_pair(bad)
  }
  bad <- pair; bad$blocks[[2]]$previous_measurement_sha256 <- strrep("c", 64); reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$started_at_unix_ms <- pair$blocks[[1]]$finished_at_unix_ms - 1; reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$finished_at_unix_ms <- bad$blocks[[2]]$started_at_unix_ms - 1; reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$finished_at_unix_ms <- bad$blocks[[2]]$started_at_unix_ms + 7200001; reject_pair(bad)
  for (value in list(NA_real_, Inf, -1, 1.1, 2^53, "123")) {
    bad <- pair; bad$blocks[[2]]$started_at_unix_ms <- value; reject_pair(bad)
  }
  for (key in names(pair$blocks[[2]]$context)) {
    bad <- pair; bad$blocks[[2]]$context[[key]] <- "wrong"; reject_pair(bad)
  }
  bad <- pair; bad$blocks[[2]]$context$run_id <- "101"; reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$context$run_attempt <- "2"; reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$source$tree <- strrep("c", 40); reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$source$commit <- strrep("c", 40); reject_pair(bad)
  bad <- pair; bad$blocks[[2]]$source$harness$files[[7]]$sha256 <- strrep("c", 64)
  bad$blocks[[2]]$source$harness$sha256 <- paired_manifest_hash(bad$blocks[[2]]$source$harness$files)
  reject_pair(bad)
  bad <- pair; bad$blocks[[2]] <- bad$blocks[[1]]
  bad$blocks[[2]]$position <- 2; bad$blocks[[2]]$block <- "repeat"; reject_pair(bad)

  # Change fixture measurements and rebind their legitimate hashes to isolate rules.
  exercise <- function(change, expected_status, reason = NULL) {
    dir <- tempfile(tmpdir = root); stopifnot(dir.create(dir))
    p <- pair
    for (i in 1:2) {
      m <- measurements[[i]]$measurement
      m <- change(m, i)
      path <- file.path(dir, paste0(c("reference", "repeat")[[i]], ".json"))
      paired_test_write(m, path)
      p$blocks[[i]]$measurement_sha256 <- hash(path)
    }
    p$blocks[[2]]$previous_measurement_sha256 <- p$blocks[[1]]$measurement_sha256
    manifest <- file.path(dir, "pair.json"); paired_test_write(p, manifest)
    result_path <- file.path(dir, "report.json")
    check(paired_main(c("compare", manifest, hash(manifest), result_path)) == expected_status)
    if (expected_status == 2L) check(!file.exists(result_path)) else {
      result <- jsonlite::fromJSON(result_path, simplifyVector = FALSE)
      if (!is.null(reason)) check(reason %in% unlist(result$reasons))
      check(result$regression_verdict == "not_assessed" && !result$trusted_baseline)
      if (expected_status == 3L) check(length(result$scenarios) == 0L)
      result
    }
  }
  update_runtime <- function(m, mutate) {
    runtime <- mutate(m$runtime_start)
    m$runtime_start <- m$runtime_end <- runtime
    m$observations <- lapply(m$observations, function(o) {
      o$runtime_start <- o$runtime_end <- runtime; o
    }); m
  }
  exercise(function(m, i) update_runtime(m, function(r) { r$image$id <- NULL; r$image["id"] <- list(NULL); r }),
           3L, "runtime_evidence_unknown")
  exercise(function(m, i) if (i == 1) m else update_runtime(m, function(r) { r$hardware$cpu_model <- 17; r }),
           3L, "runtime_mismatch_hardware")
  exercise(function(m, i) { m$schema_version <- "1.0.0"; m }, 2L)
  exercise(function(m, i) {
    m$schema_version <- "1.0.0"; m$runtime_start <- m$runtime_end <- NULL
    m$observations <- lapply(m$observations, function(o) {
      o$runtime_start <- o$runtime_end <- NULL; o
    }); m
  }, 2L)
  exercise(function(m, i) {
    if (i == 2) m$budgets_seconds$analyze_files_1 <- 20; m
  }, 3L, "budget_mismatch")
  exercise(function(m, i) { if (i == 2) m$metadata$commit <- strrep("d", 40); m }, 2L)
  exercise(function(m, i) { if (i == 2) m$summaries[[1]]$elapsed_seconds$median <- 6 + 1e-12; m }, 2L)
  exercise(function(m, i) { if (i == 2) m$metadata$measured_at_utc <- "2020-01-01T00:00:00Z"; m }, 2L)
  zero <- exercise(function(m, i) {
    if (i == 1) {
      m$observations <- lapply(m$observations, function(o) { o$elapsed_seconds <- 0; o })
      m$summaries <- paired_contract$measurement_summaries(m$observations)
    }; m
  }, 0L)
  check(is.null(zero$scenarios[[1]]$elapsed_seconds$median$ratio))
  check(zero$scenarios[[1]]$elapsed_seconds$median$ratio_status == "zero_baseline")

  # Raw JSON duplicate keys and checksum failures must publish no report.
  hostile <- file.path(output, "hostile.json")
  json <- paste(readLines(file.path(output, "pair.json")), collapse = "\n")
  writeLines(sub('"status": "complete"', '"status": "complete", "status": "complete"', json, fixed = TRUE), hostile)
  rejected_output <- file.path(root, "rejected.json")
  check(paired_main(c("compare", hostile, hash(hostile), rejected_output)) == 2L)
  check(!file.exists(rejected_output))
  check(paired_main(c("compare", file.path(output, "pair.json"), strrep("0", 64), rejected_output)) == 2L)
  check(paired_main(c("compare", file.path(output, "reference.json"), hash(file.path(output, "reference.json")), rejected_output)) == 2L)
  # File and directory no-clobber, including dangling links where supported.
  before <- hash(report_path)
  check(paired_main(c("compare", file.path(output, "pair.json"), hash(file.path(output, "pair.json")), report_path)) == 4L)
  check(hash(report_path) == before)
  fails(paired_run(output, paired_test_launch, paired_test_context, paired_test_source))
  link <- file.path(root, "dangling")
  if (suppressWarnings(file.symlink(file.path(root, "absent"), link))) {
    fails(paired_run(link, paired_test_launch, paired_test_context, paired_test_source))
    check(paired_main(c("compare", file.path(output, "pair.json"), hash(file.path(output, "pair.json")), link)) == 4L)
  }
  # A second-controller failure or source drift cannot publish a completion marker.
  failed <- file.path(root, "failed")
  fails(paired_run(failed, function(block, id, previous, dir) {
    if (block == "repeat") stop("fabricated interruption")
    paired_test_launch(block, id, previous, dir)
  }, paired_test_context, paired_test_source))
  check(length(list.files(failed, all.files = TRUE, no.. = TRUE)) == 0L)
  calls <- 0L
  drift <- file.path(root, "drift")
  fails(paired_run(drift, paired_test_launch, paired_test_context, function() {
    calls <<- calls + 1L; value <- paired_test_source()
    if (calls > 1L) value$tree <- strrep("d", 40)
    value
  }))
  check(!file.exists(file.path(drift, "pair.json")))
  replay <- file.path(root, "replay")
  fails(paired_run(replay, function(block, id, previous, dir) {
    # Replay fully valid old receipts, not just malformed labels.
    for (name in c("reference", "repeat")) {
      file.copy(file.path(output, paste0(name, ".json")), file.path(dir, paste0(name, ".json")))
      comparison_publish(pair$blocks[[match(name, c("reference", "repeat"))]],
                         file.path(dir, paste0(name, ".receipt.json")))
    }
  }, paired_test_context, paired_test_source))
  check(!file.exists(file.path(replay, "pair.json")))
  partial <- file.path(root, "partial-publication")
  fails(suppressWarnings(paired_run(partial, function(block, id, previous, dir) {
    paired_test_launch(block, id, previous, dir)
    if (block == "repeat") writeLines("preexisting sentinel", file.path(partial, "repeat.json"))
  }, paired_test_context, paired_test_source)))
  check(file.exists(file.path(partial, "reference.json")))
  check(identical(readLines(file.path(partial, "repeat.json")), "preexisting sentinel"))
  check(!file.exists(file.path(partial, "pair.json")))
  missing <- file.path(root, "missing-block")
  stopifnot(dir.create(missing))
  file.copy(file.path(output, "pair.json"), file.path(missing, "pair.json"))
  check(paired_main(c("compare", file.path(missing, "pair.json"),
    hash(file.path(missing, "pair.json")), file.path(missing, "report.json"))) == 2L)
  check(!file.exists(file.path(missing, "report.json")))
  check(paired_main(c("run", file.path(root, "not-hosted"))) == 2L)
  cat("Paired execution:", cases, "checks passed (fabricated fixtures; two real child invocations)\n")
}
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) > 0L && args[[1]] == "child") paired_test_child(args[-1]) else run_paired_tests()
}
