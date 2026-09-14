#!/usr/bin/env Rscript
# Repository-only A/A execution receipts. These are not hosted attestations.
paired_script <- if (sys.nframe() > 0L) sys.frame(1)$ofile else
  sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
paired_root <- normalizePath(file.path(dirname(paired_script), "..", ".."), mustWork = TRUE)
source(file.path(paired_root, "scripts/benchmarks/compare_measurements.R"))
paired_contract <- comparison_contract()
paired_sources <- c(paired_contract$measurement_sources,
  paired_producer = "scripts/benchmarks/paired_execution.R",
  comparator = "scripts/benchmarks/compare_measurements.R",
  paired_workflow = ".github/workflows/paired-benchmarks.yaml")
paired_startup <- lapply(file.path(paired_root, paired_sources), paired_contract$measurement_raw)
names(paired_startup) <- names(paired_sources)

paired_hash <- function(bytes) digest::digest(bytes, algo = "sha256", serialize = FALSE)
paired_nonce <- function() paste(format(openssl::rand_bytes(32)), collapse = "")
paired_clock <- function() floor(as.numeric(Sys.time()) * 1000)
paired_manifest_hash <- function(files) paired_hash(charToRaw(paste0(
  "engager-paired-sources-v1\n", paste0(vapply(files, function(x)
    paste0(x$id, ":", x$sha256, "\n"), character(1)), collapse = ""))))
paired_manifest <- function(bytes) {
  stopifnot(identical(names(bytes), names(paired_sources)))
  files <- lapply(names(bytes), function(id) list(id = id, sha256 = paired_hash(bytes[[id]])))
  list(algorithm = "sha256-paired-sources-v1", files = files,
       sha256 = paired_manifest_hash(files))
}
paired_git <- function(args) {
  x <- system2("git", c("-C", shQuote(paired_root), args), stdout = TRUE, stderr = TRUE)
  stopifnot(is.null(attr(x, "status")))
  x
}
paired_source <- function() {
  # An exact committed checkout is required for production, including untracked files.
  stopifnot(length(paired_git(c("status", "--porcelain", "--untracked-files=all"))) == 0L)
  bytes <- lapply(file.path(paired_root, paired_sources), paired_contract$measurement_raw)
  names(bytes) <- names(paired_sources)
  paired_contract$runtime_equal(bytes, paired_startup)
  list(commit = paired_git(c("rev-parse", "HEAD")),
       tree = paired_git(c("rev-parse", "HEAD^{tree}")), harness = paired_manifest(bytes))
}
paired_context <- function() {
  stopifnot(Sys.getenv("GITHUB_ACTIONS") == "true",
            Sys.getenv("GITHUB_EVENT_NAME") == "workflow_dispatch",
            Sys.getenv("GITHUB_SHA") == paired_git(c("rev-parse", "HEAD")),
            Sys.getenv("GITHUB_WORKFLOW_SHA") == Sys.getenv("GITHUB_SHA"))
  repository <- Sys.getenv("GITHUB_REPOSITORY")
  ref <- Sys.getenv("GITHUB_WORKFLOW_REF")
  prefix <- paste0(repository, "/.github/workflows/paired-benchmarks.yaml@")
  stopifnot(startsWith(ref, prefix), nchar(ref) > nchar(prefix))
  # Retain only fixed workflow identity, not arbitrary ref text.
  list(repository = repository, run_id = Sys.getenv("GITHUB_RUN_ID"),
       run_attempt = Sys.getenv("GITHUB_RUN_ATTEMPT"), job = Sys.getenv("GITHUB_JOB"),
       workflow = "paired-benchmarks.yaml", workflow_sha = Sys.getenv("GITHUB_WORKFLOW_SHA"))
}
paired_validate_context <- function(x) {
  c <- paired_contract
  c$measurement_keys(x, c("repository", "run_id", "run_attempt", "job", "workflow", "workflow_sha"))
  c$measurement_token(x$repository, "^[A-Za-z0-9_.-]{1,100}/[A-Za-z0-9_.-]{1,100}$")
  for (key in c("run_id", "run_attempt")) c$measurement_token(x[[key]], "^[1-9][0-9]{0,19}$")
  stopifnot(identical(x$job, "paired_benchmarks"), identical(x$workflow, "paired-benchmarks.yaml"))
  c$measurement_token(x$workflow_sha, "^[a-f0-9]{40}$")
}
paired_validate_source <- function(x) {
  c <- paired_contract
  c$measurement_keys(x, c("commit", "tree", "harness"))
  for (key in c("commit", "tree")) c$measurement_token(x[[key]], "^[a-f0-9]{40}$")
  h <- x$harness
  c$measurement_keys(h, c("algorithm", "files", "sha256"))
  stopifnot(identical(h$algorithm, "sha256-paired-sources-v1"), is.list(h$files),
            is.null(names(h$files)), length(h$files) == length(paired_sources))
  for (i in seq_along(paired_sources)) {
    c$measurement_keys(h$files[[i]], c("id", "sha256"))
    stopifnot(identical(h$files[[i]]$id, names(paired_sources)[i]))
    c$measurement_token(h$files[[i]]$sha256, "^[a-f0-9]{64}$")
  }
  stopifnot(identical(h$sha256, paired_manifest_hash(h$files)))
}
paired_read_json <- function(path, checksum) {
  paired_contract$measurement_token(checksum, "^[a-f0-9]{64}$")
  bytes <- paired_contract$measurement_raw(path)
  stopifnot(identical(paired_hash(bytes), checksum))
  text <- rawToChar(bytes)
  stopifnot(jsonlite::validate(text))
  jsonlite::fromJSON(text, simplifyVector = FALSE)
}
paired_validate_receipt <- function(x, measurement, position) {
  c <- paired_contract
  c$measurement_keys(x, c("receipt_schema_version", "pair_id", "invocation_id", "block",
    "position", "context", "source", "started_at_unix_ms", "finished_at_unix_ms",
    "previous_measurement_sha256", "measurement_sha256"))
  stopifnot(identical(x$receipt_schema_version, "1.0.0"), x$position == position,
            identical(x$block, c("reference", "repeat")[[position]]))
  c$measurement_number(x$position, integer = TRUE, positive = TRUE)
  for (key in c("pair_id", "invocation_id", "measurement_sha256")) {
    c$measurement_token(x[[key]], "^[a-f0-9]{64}$")
  }
  stopifnot(x$pair_id != x$invocation_id)
  if (position == 1L) stopifnot(is.null(x$previous_measurement_sha256)) else
    c$measurement_token(x$previous_measurement_sha256, "^[a-f0-9]{64}$")
  paired_validate_context(x$context)
  paired_validate_source(x$source)
  for (key in c("started_at_unix_ms", "finished_at_unix_ms")) {
    c$measurement_number(x[[key]], integer = TRUE, positive = TRUE)
    stopifnot(x[[key]] < 2^53)
  }
  stopifnot(x$finished_at_unix_ms >= x$started_at_unix_ms,
            x$finished_at_unix_ms - x$started_at_unix_ms <= 7200000)
  m <- measurement$measurement
  stopifnot(identical(m$schema_version, "2.0.0"),
            identical(x$measurement_sha256, measurement$sha256),
            identical(x$source$commit, m$metadata$commit),
            identical(x$context$workflow_sha, x$source$commit),
            identical(x$context$run_id, m$metadata$run_id),
            identical(x$context$run_attempt, m$metadata$run_attempt),
            identical(m$metadata$os, "Linux"), m$metadata$runner != "local")
  c$runtime_equal(x$source$harness$files[seq_along(c$measurement_sources)], m$runtime_start$harness$files)
  measured <- as.numeric(as.POSIXct(m$metadata$measured_at_utc,
                                   format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")) * 1000
  # Measurement v2 records whole seconds, so compare whole-second windows.
  stopifnot(is.finite(measured), measured >= floor(x$started_at_unix_ms / 1000) * 1000,
            measured <= x$finished_at_unix_ms)
  invisible(TRUE)
}
paired_validate <- function(pair, measurements) {
  c <- paired_contract
  c$measurement_keys(pair, c("paired_schema_version", "status", "blocks"))
  stopifnot(identical(pair$paired_schema_version, "1.0.0"), identical(pair$status, "complete"),
            is.list(pair$blocks), is.null(names(pair$blocks)), length(pair$blocks) == 2L,
            length(measurements) == 2L)
  for (i in 1:2) paired_validate_receipt(pair$blocks[[i]], measurements[[i]], i)
  a <- pair$blocks[[1]]
  b <- pair$blocks[[2]]
  c$runtime_equal(a$context, b$context)
  c$runtime_equal(a$source, b$source)
  stopifnot(identical(a$pair_id, b$pair_id), a$invocation_id != b$invocation_id,
            a$measurement_sha256 != b$measurement_sha256,
            identical(b$previous_measurement_sha256, a$measurement_sha256),
            a$finished_at_unix_ms <= b$started_at_unix_ms)
  invisible(TRUE)
}
paired_inputs <- function(pair, directory) {
  stopifnot(is.list(pair$blocks), length(pair$blocks) == 2L)
  lapply(1:2, function(i) comparison_read(
    file.path(directory, paste0(c("reference", "repeat")[[i]], ".json")),
    pair$blocks[[i]]$measurement_sha256, c("reference", "repeat")[[i]],
    paired_contract, paired_contract$measurement_expected()))
}
paired_compare <- function(path, checksum, output) {
  pair <- paired_read_json(path, checksum)
  measurements <- paired_inputs(pair, dirname(path))
  paired_validate(pair, measurements)
  # Only this fully validated pair earns the same-job exception. The legacy
  # helper and every other compatibility rule are retained byte-for-byte.
  contract <- new.env(parent = environment(comparison_build))
  contract$comparison_reasons <- function(a, b, c) {
    reasons <- comparison_reasons(a, b, c)
    stopifnot(sum(reasons == "same_run_identity") == 1L)
    reasons[reasons != "same_run_identity"]
  }
  build <- comparison_build
  environment(build) <- contract
  report <- build(measurements[[1]], measurements[[2]], paired_contract)
  report$paired_comparison_schema_version <- "1.0.0"
  report$pair_manifest_sha256 <- checksum
  report$execution <- pair
  report$separation_seconds <- (pair$blocks[[2]]$started_at_unix_ms -
                              pair$blocks[[1]]$finished_at_unix_ms) / 1000
  report$limitations <- c(report$limitations, as.list(c("fixed_reference_then_repeat_order",
    "shared_caches_and_host_activity", "receipts_are_not_hosted_attestation")))
  comparison_publish(report, output)
  report
}

# These injectable function arguments support fabricated, bounded process tests.
# CLI production uses only the defaults; no environment/CLI test bypass exists.
paired_block <- function(block, pair_id, previous, directory,
                         measure = paired_contract$measurement_run,
                         context = paired_context, source = paired_source) {
  position <- match(block, c("reference", "repeat"))
  stopifnot(!is.na(position), dir.exists(directory))
  paired_contract$measurement_token(pair_id, "^[a-f0-9]{64}$")
  if (position == 1L) stopifnot(identical(previous, "none")) else
    paired_contract$measurement_token(previous, "^[a-f0-9]{64}$")
  receipt <- list(receipt_schema_version = "1.0.0", pair_id = pair_id,
    invocation_id = paired_nonce(), block = block, position = position,
    context = context(), source = source(), started_at_unix_ms = paired_clock(),
    finished_at_unix_ms = NULL,
    previous_measurement_sha256 = if (position == 1L) NULL else previous,
    measurement_sha256 = NULL)
  paired_validate_context(receipt$context)
  paired_validate_source(receipt$source)
  path <- file.path(directory, paste0(block, ".json"))
  measure(path)
  receipt$finished_at_unix_ms <- paired_clock()
  paired_contract$runtime_equal(receipt$context, context())
  paired_contract$runtime_equal(receipt$source, source())
  receipt$measurement_sha256 <- paired_hash(paired_contract$measurement_raw(path))
  value <- comparison_read(path, receipt$measurement_sha256, block,
                           paired_contract, paired_contract$measurement_expected())
  paired_validate_receipt(receipt, value, position)
  comparison_publish(receipt, file.path(directory, paste0(block, ".receipt.json")))
  invisible(receipt)
}
paired_launch <- function(block, pair_id, previous, directory) {
  status <- system2(file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(file.path(paired_root, "scripts/benchmarks/paired_execution.R")),
      "block", block, pair_id, previous, shQuote(directory)), timeout = 7200)
  stopifnot(status == 0L)
}
paired_run <- function(output, launch = paired_launch, context = paired_context,
                       source = paired_source) {
  # Reserve once; even an existing empty directory or dangling symlink is refused.
  stopifnot(dir.create(output, showWarnings = FALSE))
  scratch <- tempfile("engager-pair-", tmpdir = dirname(output))
  stopifnot(dir.create(scratch))
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  initial_context <- context()
  initial_source <- source()
  paired_validate_context(initial_context)
  paired_validate_source(initial_source)
  pair_id <- paired_nonce()
  receipts <- list()
  previous <- "none"
  for (block in c("reference", "repeat")) {
    launch(block, pair_id, previous, scratch)
    path <- file.path(scratch, paste0(block, ".receipt.json"))
    receipt <- paired_read_json(path, paired_hash(paired_contract$measurement_raw(path)))
    stopifnot(identical(receipt$pair_id, pair_id))
    paired_contract$runtime_equal(receipt$context, initial_context)
    paired_contract$runtime_equal(receipt$source, initial_source)
    receipts[[length(receipts) + 1L]] <- receipt
    previous <- receipt$measurement_sha256
    paired_contract$runtime_equal(context(), initial_context)
    paired_contract$runtime_equal(source(), initial_source)
  }
  pair <- list(paired_schema_version = "1.0.0", status = "complete", blocks = receipts)
  paired_validate(pair, paired_inputs(pair, scratch))
  # The manifest is the completion marker and is always published last.
  for (block in c("reference", "repeat")) {
    stopifnot(file.link(file.path(scratch, paste0(block, ".json")),
                        file.path(output, paste0(block, ".json"))))
  }
  comparison_publish(pair, file.path(output, "pair.json"))
  invisible(pair)
}
paired_main <- function(args) {
  tryCatch({
    stopifnot(length(args) > 0L)
    if (identical(args[[1]], "run")) {
      stopifnot(length(args) == 2L)
      paired_run(args[[2]])
    } else if (identical(args[[1]], "block")) {
      stopifnot(length(args) == 5L)
      do.call(paired_block, as.list(args[-1]))
    } else if (identical(args[[1]], "compare")) {
      stopifnot(length(args) == 4L)
      report <- do.call(paired_compare, as.list(args[-1]))
      if (report$disposition != "descriptive_only") return(3L)
    } else stop("invalid command")
    0L
  }, error = function(e) {
    cat("paired execution: invalid input, execution, or output\n", file = stderr())
    if (inherits(e, "comparison_error")) e$status else 2L
  })
}
if (sys.nframe() == 0L) quit(status = paired_main(commandArgs(trailingOnly = TRUE)))
