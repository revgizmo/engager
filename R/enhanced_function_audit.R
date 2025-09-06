#' Enhanced Function Audit System
#'
#' @description Comprehensive function audit and categorization system for Issue #393
#' @keywords internal
#' @noRd

#' Audit all exported functions
#'
#' @return Comprehensive function audit results
audit_all_functions <- function() {
  # Get all exported functions
  exported_functions <- get_exported_functions()

  cat("🔍 Starting comprehensive function audit...\n")
  cat("📊 Total functions to audit:", length(exported_functions), "\n\n")

  # Analyze each function
  function_analysis <- list()
  for (i in seq_along(exported_functions)) {
    func_name <- exported_functions[i]
    cat("📋 Analyzing function", i, "of", length(exported_functions), ":", func_name, "\n")

    function_analysis[[func_name]] <- analyze_function(func_name)
  }

  # Categorize functions
  categories <- list(
    exported = function_analysis[sapply(function_analysis, function(x) x$exported), ],
    internal = function_analysis[sapply(function_analysis, function(x) !x$exported), ]
  )

  # Generate audit report
  audit_report <- generate_audit_report(categories, function_analysis)

  cat("\n✅ Function audit completed successfully!\n")
  audit_report
}

#' Get all exported functions from NAMESPACE
#'
#' @return Vector of exported function names
get_exported_functions <- function() {
  # Read NAMESPACE file
  namespace_lines <- readLines("NAMESPACE")
  export_lines <- grep("^export\\(", namespace_lines, value = TRUE)

  # Extract function names
  function_names <- gsub("^export\\(([^)]+)\\)", "\\1", export_lines)
  function_names <- gsub('"', "", function_names)

  # Remove magrittr pipe operator
  function_names <- function_names[function_names != "%>%"]

  function_names
}

#' Analyze individual function
#'
#' @param function_name Name of function to analyze
#' @return Function analysis results
analyze_function <- function(function_name) {
  # Get function signature
  signature <- get_function_signature(function_name)

  # Get function documentation
  documentation <- get_function_documentation(function_name)

  # Analyze function usage
  usage <- analyze_function_usage(function_name)

  # Get function dependencies
  dependencies <- get_function_dependencies(function_name)

  # Get function file location
  file_location <- get_function_file_location(function_name)

  # Analyze function complexity
  complexity <- analyze_function_complexity(function_name)

  list(
    name = function_name,
    signature = signature,
    documentation = documentation,
    usage = usage,
    dependencies = dependencies,
    file_location = file_location,
    complexity = complexity
  )
}

#' Get function signature
#'
#' @param function_name Name of function
#' @return Function signature
get_function_signature <- function(function_name) {
  tryCatch(
    {
      func <- get(function_name, envir = asNamespace("zoomstudentengagement"))
      if (is.function(func)) {
        args <- formals(func)
        return(paste(names(args), collapse = ", "))
      } else {
        return("Not a function")
      }
    },
    error = function(e) {
      "Error retrieving signature"
    }
  )
}

#' Get function documentation
#'
#' @param function_name Name of function
#' @return Documentation status
get_function_documentation <- function(function_name) {
  # Check if function has roxygen2 documentation
  man_file <- file.path("man", paste0(function_name, ".Rd"))

  if (file.exists(man_file)) {
    "Complete"
  } else {
    "Missing"
  }
}

#' Analyze function usage patterns
#'
#' @param function_name Name of function
#' @return Usage analysis
analyze_function_usage <- function(function_name) {
  usage_info <- list(
    in_vignettes = FALSE,
    in_examples = FALSE,
    in_tests = FALSE,
    usage_count = 0
  )

  # Check vignettes
  vignette_files <- list.files("vignettes", pattern = "\\.Rmd$", full.names = TRUE)
  for (vignette in vignette_files) {
    if (file.exists(vignette)) {
      content <- readLines(vignette, warn = FALSE)
      if (any(grepl(function_name, content, fixed = TRUE))) {
        usage_info$in_vignettes <- TRUE
        usage_info$usage_count <- usage_info$usage_count + 1
      }
    }
  }

  # Check examples in man files
  man_file <- file.path("man", paste0(function_name, ".Rd"))
  if (file.exists(man_file)) {
    content <- readLines(man_file, warn = FALSE)
    if (any(grepl("\\\\examples", content))) {
      usage_info$in_examples <- TRUE
      usage_info$usage_count <- usage_info$usage_count + 1
    }
  }

  # Check tests - look for function name in test files
  all_files <- list.files("tests/testthat", full.names = TRUE)
  test_files <- all_files[grepl("^test-.*\\.R$", basename(all_files))]
  for (test_file in test_files) {
    if (file.exists(test_file)) {
      content <- readLines(test_file, warn = FALSE)
      # Look for function name in various contexts (calls, test names, etc.)
      if (any(grepl(function_name, content, fixed = TRUE)) ||
        any(grepl(paste0("test.*", function_name), content, ignore.case = TRUE))) {
        usage_info$in_tests <- TRUE
        usage_info$usage_count <- usage_info$usage_count + 1
        break # Found in at least one test file
      }
    }
  }

  usage_info
}

#' Get function dependencies
#'
#' @param function_name Name of function
#' @return Function dependencies
get_function_dependencies <- function(function_name) {
  tryCatch(
    {
      func <- get(function_name, envir = asNamespace("zoomstudentengagement"))
      if (is.function(func)) {
        # Get function body
        body_text <- deparse(body(func))

        # Find function calls
        function_calls <- character(0)
        for (line in body_text) {
          # Simple regex to find function calls
          calls <- regmatches(line, gregexpr("\\b[a-zA-Z_][a-zA-Z0-9_.]*\\s*\\(", line))[[1]]
          calls <- gsub("\\s*\\(", "", calls)
          function_calls <- c(function_calls, calls)
        }

        # Remove duplicates and common R functions
        function_calls <- unique(function_calls)
        common_functions <- c(
          "if", "for", "while", "return", "stop", "warning", "message",
          "cat", "print", "paste", "paste0", "c", "list", "data.frame",
          "as.data.frame", "as.character", "as.numeric", "length", "nrow", "ncol"
        )
        function_calls <- setdiff(function_calls, common_functions)

        return(function_calls)
      } else {
        return(character(0))
      }
    },
    error = function(e) {
      character(0)
    }
  )
}

#' Get function file location
#'
#' @param function_name Name of function
#' @return File location
get_function_file_location <- function(function_name) {
  # Search through R files
  r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)

  for (r_file in r_files) {
    if (file.exists(r_file)) {
      content <- readLines(r_file, warn = FALSE)
      # Look for function definition
      func_pattern <- paste0("^", function_name, "\\s*<-\\s*function")
      if (any(grepl(func_pattern, content))) {
        return(basename(r_file))
      }
    }
  }

  "Unknown"
}

#' Analyze function complexity
#'
#' @param function_name Name of function
#' @return Complexity analysis
analyze_function_complexity <- function(function_name) {
  tryCatch(
    {
      func <- get(function_name, envir = asNamespace("zoomstudentengagement"))
      if (is.function(func)) {
        body_text <- deparse(body(func))

        complexity <- list(
          lines_of_code = length(body_text),
          has_loops = any(grepl("for\\s*\\(|while\\s*\\(", body_text)),
          has_conditionals = any(grepl("if\\s*\\(|else", body_text)),
          has_error_handling = any(grepl("tryCatch|stop|warning", body_text)),
          function_calls = length(grep("\\w+\\s*\\(", body_text))
        )

        return(complexity)
      } else {
        return(list(
          lines_of_code = 0, has_loops = FALSE, has_conditionals = FALSE,
          has_error_handling = FALSE, function_calls = 0
        ))
      }
    },
    error = function(e) {
      list(
        lines_of_code = 0, has_loops = FALSE, has_conditionals = FALSE,
        has_error_handling = FALSE, function_calls = 0
      )
    }
  )
}

#' Generate comprehensive audit report
#'
#' @param categories Function categories
#' @param function_analysis Function analysis results
#' @return Audit report
generate_audit_report <- function(categories, function_analysis) {
  cat("\n📊 GENERATING COMPREHENSIVE AUDIT REPORT\n")
  cat(paste(rep("=", 50), collapse = ""), "\n\n")

  # Summary statistics
  total_functions <- length(function_analysis)
  
  # Handle empty function_analysis gracefully
  if (total_functions == 0) {
    documented_functions <- 0
    functions_with_examples <- 0
    functions_in_tests <- 0
  } else {
    documented_functions <- sum(sapply(function_analysis, function(x) x$documentation == "Complete"))
    functions_with_examples <- sum(sapply(function_analysis, function(x) x$usage$in_examples))
    functions_in_tests <- sum(sapply(function_analysis, function(x) x$usage$in_tests))
  }

  cat("📈 SUMMARY STATISTICS\n")
  cat(paste(rep("-", 20), collapse = ""), "\n")
  cat("Total exported functions:", total_functions, "\n")
  if (total_functions > 0) {
    cat(
      "Functions with documentation:", documented_functions, "(",
      round(100 * documented_functions / total_functions, 1), "%)\n"
    )
    cat(
      "Functions with examples:", functions_with_examples, "(",
      round(100 * functions_with_examples / total_functions, 1), "%)\n"
    )
  } else {
    cat("Functions with documentation:", documented_functions, "(0%)\n")
    cat("Functions with examples:", functions_with_examples, "(0%)\n")
  }
  if (total_functions > 0) {
    cat(
      "Functions with tests:", functions_in_tests, "(",
      round(100 * functions_in_tests / total_functions, 1), "%)\n\n"
    )
  } else {
    cat("Functions with tests:", functions_in_tests, "(0%)\n\n")
  }

  # Category breakdown
  cat("📂 FUNCTION CATEGORIES\n")
  cat(paste(rep("-", 20), collapse = ""), "\n")
  for (category in names(categories)) {
    count <- length(categories[[category]])
    cat(sprintf("%-20s: %2d functions\n", category, count))
  }
  cat("\n")

  # Detailed function list by category
  for (category in names(categories)) {
    if (length(categories[[category]]) > 0) {
      cat("📁", toupper(category), "FUNCTIONS\n")
      cat(paste(rep("-", nchar(category) + 10), collapse = ""), "\n")
      for (func_name in categories[[category]]) {
        func_info <- function_analysis[[func_name]]
        doc_status <- if (func_info$documentation == "Complete") "✅" else "❌"
        test_status <- if (func_info$usage$in_tests) "✅" else "❌"
        example_status <- if (func_info$usage$in_examples) "✅" else "❌"

        cat(sprintf(
          "  %-30s | Doc:%s Test:%s Ex:%s | %s\n",
          func_name, doc_status, test_status, example_status,
          func_info$file_location
        ))
      }
      cat("\n")
    }
  }

  # Create report object
  report <- list(
    summary = list(
      total_functions = total_functions,
      documented_functions = documented_functions,
      functions_with_examples = functions_with_examples,
      functions_in_tests = functions_in_tests
    ),
    categories = categories,
    function_analysis = function_analysis,
    generated_at = Sys.time()
  )

  report
}

#' Save audit report to file
#'
#' @param audit_report Audit report object
#' @param filename Output filename
save_audit_report <- function(audit_report, filename = "function_audit_report.rds") {
  saveRDS(audit_report, filename)
  cat("💾 Audit report saved to:", filename, "\n")
}

#' Load audit report from file
#'
#' @param filename Input filename
#' @return Audit report object
load_audit_report <- function(filename = "function_audit_report.rds") {
  if (file.exists(filename)) {
    return(readRDS(filename))
  } else {
    stop("Audit report file not found: ", filename)
  }
}
