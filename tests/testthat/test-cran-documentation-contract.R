test_that("exported documentation has values and internal docs have no examples", {
  package_root <- normalizePath(test_path("../.."), mustWork = TRUE)
  namespace_path <- file.path(package_root, "NAMESPACE")
  man_dir <- file.path(package_root, "man")
  skip_if_not(file.exists(namespace_path) && dir.exists(man_dir))

  namespace <- readLines(namespace_path, warn = FALSE)
  export_lines <- grep("^export[(]", namespace, value = TRUE)
  exports <- substr(export_lines, 8, nchar(export_lines) - 1L)
  rd_files <- list.files(man_dir, pattern = "[.]Rd$", full.names = TRUE)

  documented_exports <- character()
  internal_examples <- character()
  missing_values <- character()
  missing_arguments <- character()

  for (rd_file in rd_files) {
    rd <- readLines(rd_file, warn = FALSE)
    alias_lines <- rd[startsWith(rd, "\\alias{")]
    aliases <- substr(alias_lines, 8, nchar(alias_lines) - 1L)
    exported_aliases <- intersect(exports, aliases)
    has_examples <- any(startsWith(rd, "\\examples{"))

    if (length(exported_aliases) > 0L) {
      documented_exports <- union(documented_exports, exported_aliases)
      if (!any(startsWith(rd, "\\value{"))) {
        missing_values <- union(missing_values, exported_aliases)
      }
      rd_text <- paste(rd, collapse = "\n")
      argument_items <- regmatches(
        rd_text,
        gregexpr("\\\\item\\{[^}]+\\}", rd_text, perl = TRUE)
      )[[1]]
      documented_arguments <- if (identical(argument_items, "")) {
        character()
      } else {
        sub("^\\\\item\\{([^}]+)\\}$", "\\1", argument_items)
      }
      for (exported_alias in exported_aliases) {
        function_arguments <- names(formals(get(exported_alias, envir = asNamespace("engager"))))
        missing <- setdiff(function_arguments, documented_arguments)
        if (length(missing) > 0L) {
          missing_arguments <- c(
            missing_arguments,
            paste0(exported_alias, "(", paste(missing, collapse = ", "), ")")
          )
        }
      }
    } else if (has_examples) {
      internal_examples <- c(internal_examples, basename(rd_file))
    }
  }

  expect_setequal(documented_exports, exports)
  expect_length(missing_values, 0)
  expect_length(missing_arguments, 0)
  expect_length(internal_examples, 0)

  documentation_text <- paste(
    unlist(lapply(c(list.files(file.path(package_root, "R"), full.names = TRUE), rd_files),
      readLines,
      warn = FALSE
    )),
    collapse = "\n"
  )
  expect_false(grepl("\\\\dontrun", documentation_text))
  expect_false(grepl("\\\\donttest", documentation_text))
})

test_that("generated test artifacts are absent from the package source", {
  expect_false(file.exists(test_path("test.csv")))
  expect_false(file.exists(test_path("session_mapping.csv")))
  expect_false(file.exists(test_path("section_names_lookup.csv")))
})

test_that("tests do not target literal relative write destinations", {
  package_root <- normalizePath(test_path("../.."), mustWork = TRUE)
  test_files <- list.files(
    file.path(package_root, "tests", "testthat"),
    pattern = "[.]R$",
    full.names = TRUE
  )
  test_files <- test_files[basename(test_files) != "test-cran-documentation-contract.R"]
  test_lines <- unlist(lapply(test_files, readLines, warn = FALSE), use.names = FALSE)

  relative_side_effects <- c(
    "dir[.]create[(][[:space:]]*['\"]",
    "unlink[(][[:space:]]*['\"]",
    "file[.]create[(][[:space:]]*['\"]",
    "setwd[(]"
  )
  matches <- vapply(
    relative_side_effects,
    function(pattern) any(grepl(pattern, test_lines)),
    logical(1)
  )

  expect_false(any(matches), info = paste(names(matches)[matches], collapse = ", "))
})

test_that("worktree metadata is excluded from source builds", {
  package_root <- normalizePath(test_path("../.."), mustWork = TRUE)
  build_ignore_path <- file.path(package_root, ".Rbuildignore")
  skip_if_not(
    file.exists(build_ignore_path),
    ".Rbuildignore is only available in a source checkout"
  )
  build_ignore <- readLines(build_ignore_path, warn = FALSE)
  expect_true(any(build_ignore == "^\\.git$"))
})
