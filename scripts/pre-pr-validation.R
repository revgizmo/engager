#!/usr/bin/env Rscript

fail <- function(...) {
  stop(paste0(...), call. = FALSE)
}

require_tool <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    fail("Required development package is not installed: ", package)
  }
}

run_git <- function(args, label) {
  output <- system2("git", args, stdout = TRUE, stderr = TRUE)
  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }
  if (!identical(status, 0L)) {
    if (length(output) > 0L) {
      cat(paste(output, collapse = "\n"), "\n")
    }
    fail(label, " failed")
  }
  output
}

run_external <- function(command, args, label) {
  output <- system2(command, args, stdout = TRUE, stderr = TRUE)
  if (length(output) > 0L) {
    cat(paste(output, collapse = "\n"), "\n")
  }
  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }
  if (!identical(status, 0L)) {
    fail(label, " failed with exit status ", status)
  }
  invisible(output)
}

repository_state <- function() {
  run_git(
    c("status", "--porcelain=v1", "--untracked-files=all"),
    "git status"
  )
}

main <- function() {
  require_tool("devtools")

  before <- repository_state()
  check_root <- tempfile("engager-rcmdcheck-")
  dir.create(check_root, recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(check_root, recursive = TRUE, force = TRUE), add = TRUE)

  run_package_check <- function(source_path, output_root) {
    source_path <- normalizePath(source_path, mustWork = TRUE)
    build_root <- file.path(output_root, "build")
    check_output <- file.path(output_root, "check")
    source_copy <- file.path(output_root, "source", "engager")
    dir.create(build_root, recursive = TRUE, showWarnings = FALSE)
    dir.create(check_output, recursive = TRUE, showWarnings = FALSE)
    dir.create(source_copy, recursive = TRUE, showWarnings = FALSE)

    source_entries <- list.files(
      source_path,
      all.files = TRUE,
      full.names = TRUE,
      no.. = TRUE
    )
    source_entries <- source_entries[basename(source_entries) != ".git"]
    copied <- file.copy(
      source_entries,
      source_copy,
      recursive = TRUE,
      copy.mode = TRUE,
      copy.date = TRUE
    )
    if (!all(copied)) {
      fail("Could not create a complete temporary source copy")
    }

    old_working_directory <- setwd(build_root)
    on.exit(setwd(old_working_directory), add = TRUE)

    r_binary <- file.path(R.home("bin"), "R")
    run_external(
      r_binary,
      c("CMD", "build", "--no-manual", source_copy),
      "R CMD build"
    )

    tarballs <- list.files(
      build_root,
      pattern = "[.]tar[.]gz$",
      full.names = TRUE
    )
    if (length(tarballs) != 1L) {
      fail("R CMD build did not create exactly one source tarball")
    }

    run_external(
      r_binary,
      c(
        "CMD",
        "check",
        "--no-manual",
        "--as-cran",
        paste0("--output=", check_output),
        tarballs[[1]]
      ),
      "R CMD check --as-cran"
    )

    package_name <- read.dcf(
      file.path(source_copy, "DESCRIPTION"),
      fields = "Package"
    )[[1]]
    check_log <- file.path(
      check_output,
      paste0(package_name, ".Rcheck"),
      "00check.log"
    )
    if (!file.exists(check_log)) {
      fail("R CMD check did not create 00check.log")
    }
    status_lines <- grep(
      "^Status:",
      readLines(check_log, warn = FALSE),
      value = TRUE
    )
    if (length(status_lines) > 0L && any(grepl("ERROR|WARNING", status_lines))) {
      fail("R CMD check reported: ", paste(status_lines, collapse = "; "))
    }
  }

  validation_error <- tryCatch(
    {
      cat("[1/3] Checking whitespace errors\n")
      run_git(c("diff", "--check"), "git diff --check")
      run_git(c("diff", "--cached", "--check"), "git diff --cached --check")

      cat("[2/3] Running tests\n")
      devtools::test(
        reporter = "summary",
        stop_on_failure = TRUE,
        stop_on_warning = FALSE
      )

      cat("[3/3] Running R CMD check --as-cran in a temporary directory\n")
      run_package_check(normalizePath(".", mustWork = TRUE), check_root)
      NULL
    },
    error = function(error) error
  )

  after <- repository_state()
  if (!identical(before, after)) {
    cat("Repository state before validation:\n")
    cat(paste(before, collapse = "\n"), "\n")
    cat("Repository state after validation:\n")
    cat(paste(after, collapse = "\n"), "\n")
    fail("Validation changed the repository worktree")
  }

  if (!is.null(validation_error)) {
    fail("Validation failed: ", conditionMessage(validation_error))
  }

  cat("[PASS] validation completed without changing repository state\n")
}

main()
