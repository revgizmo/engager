#!/usr/bin/env Rscript

# Pre-PR Validation Script
# Runs checks similar to Cursor Bugbot for R packages

library(devtools)
library(lintr)
library(styler)



cat("🔍 Running Pre-PR Validation (Bugbot-style checks)...\n\n")

# Progress indicator functions
show_spinner <- function(message, duration = 2) {
  spinner <- c("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
  for (i in 1:(duration * 10)) {
    cat("\r", message, spinner[i %% length(spinner) + 1])
    Sys.sleep(0.1)
  }
  cat("\r", message, "✅\n")
}

show_progress <- function(message, operation, estimated_time = NULL) {
  if (!is.null(estimated_time)) {
    cat(message, "(estimated", estimated_time, ")\n")
  } else {
    cat(message, "\n")
  }
  
  start_time <- Sys.time()
  result <- tryCatch({
    operation()
    end_time <- Sys.time()
    duration <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 1)
    cat("   ✅ Completed in", duration, "seconds\n")
    TRUE
  }, error = function(e) {
    end_time <- Sys.time()
    duration <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 1)
    cat("   ❌ Failed after", duration, "seconds:", e$message, "\n")
    FALSE
  })
  return(result)
}

# Initialize status tracking
validation_status <- list(
  code_style = FALSE,
  linting = FALSE,
  documentation = FALSE,
  readme = FALSE,
  vignettes = FALSE,
  function_signatures = FALSE,
  data_validation = FALSE,
  testing = FALSE,
  package_check = FALSE,
  test_output_validation = FALSE
)

# 1. Code Style and Quality
cat("1. Code Style and Quality:\n")
validation_status$code_style <- show_progress(
  "   🔄 Applying code formatting",
  function() styler::style_pkg(),
  "5-15 seconds"
)

validation_status$linting <- show_progress(
  "   🔄 Running linting checks",
  function() {
    lint_results <- lintr::lint_package()
    if (length(lint_results) > 0) {
      cat("   ⚠️  Linting issues found:", length(lint_results), "\n")
      for (i in 1:min(5, length(lint_results))) {
        cat("      -", lint_results[[i]]$message, "at", lint_results[[i]]$filename, ":", lint_results[[i]]$line_number, "\n")
      }
      stop("Linting issues found")
    }
  },
  "3-8 seconds"
)

# 2. Documentation
cat("\n2. Documentation:\n")
validation_status$documentation <- show_progress(
  "   🔄 Updating documentation",
  function() devtools::document(),
  "10-30 seconds"
)

validation_status$readme <- show_progress(
  "   🔄 Building README",
  function() devtools::build_readme(),
  "5-15 seconds"
)

# 3. Vignette Validation
cat("\n3. Vignette Validation:\n")
validation_status$vignettes <- show_progress(
  "   🔄 Building vignettes",
  function() {
    devtools::build_vignettes()
    cat("   ℹ️  Generated HTML files in doc/ (auto-ignored by .gitignore)\n")
  },
  "1-3 minutes"
)

# 4. Function Signature Validation (Enhanced)
cat("\n4. Function Signature Validation:\n")
validation_status$function_signatures <- show_progress(
  "   🔄 Validating function signatures",
  function() {
    # Load package and check function signatures
    devtools::load_all()
    
    # Get only exported symbols from this package, not imported ones
    exported_functions <- getNamespaceExports("zoomstudentengagement")
    
    # Check for common issues
    issues_found <- FALSE
    
    # Track specific function signature issues
    function_signature_issues <- list()
    
    # Functions to ignore (test helpers or not applicable here)
    ignore_functions <- c(
      "create_sample_roster", "create_sample_section_names_lookup",
      "create_sample_transcript", "create_sample_transcript_data",
      "create_test_data", "create_test_transcript",
      "create_test_roster", "create_test_section_names_lookup"
    )
    
    # Check each exported function
    for (func_name in exported_functions) {
      if (func_name %in% ignore_functions) next
      
      tryCatch({
        func <- get(func_name, envir = asNamespace("zoomstudentengagement"))
        
        # Check if it's a function
        if (!is.function(func)) next
        
        # Get function arguments
        args <- formals(func)
        
        # Check for common issues
        if (length(args) == 0) {
          cat("   ⚠️  Function", func_name, "has no arguments\n")
          issues_found <- TRUE
        }
        
        # Check for missing default values in required arguments
        for (arg_name in names(args)) {
          if (arg_name == "...") next
          if (is.symbol(args[[arg_name]]) && as.character(args[[arg_name]]) == "") {
            cat("   ⚠️  Function", func_name, "argument", arg_name, "has no default value\n")
            issues_found <- TRUE
          }
        }
        
      }, error = function(e) {
        cat("   ⚠️  Could not analyze function", func_name, ":", e$message, "\n")
        issues_found <- TRUE
      })
    }
    
    if (!issues_found) {
      cat("   ✅ All function signatures validated\n")
    } else {
      stop("Function signature issues found")
    }
  },
  "10-20 seconds"
)

# 5. Data Validation
cat("\n5. Data Validation:\n")
validation_status$data_validation <- show_progress(
  "   🔄 Validating data loading",
  function() {
    # Test loading sample data
    devtools::load_all()
    
    # Test transcript loading
    sample_transcript <- system.file("extdata", "sample_transcript.csv", package = "zoomstudentengagement")
    if (file.exists(sample_transcript)) {
      transcript_data <- read.csv(sample_transcript)
      if (nrow(transcript_data) == 0) {
        stop("Sample transcript data is empty")
      }
      cat("   ✅ Sample transcript data loads correctly\n")
    } else {
      cat("   ⚠️  Sample transcript data not found\n")
    }
    
    # Test roster loading
    sample_roster <- system.file("extdata", "sample_roster.csv", package = "zoomstudentengagement")
    if (file.exists(sample_roster)) {
      roster_data <- read.csv(sample_roster)
      if (nrow(roster_data) == 0) {
        stop("Sample roster data is empty")
      }
      cat("   ✅ Sample roster data loads correctly\n")
    } else {
      cat("   ⚠️  Sample roster data not found\n")
    }
  },
  "5-10 seconds"
)

# 6. Mathematical Formula Validation
cat("\n6. Mathematical Formula Validation:\n")
show_progress(
  "   🔄 Validating mathematical formulas",
  function() {
    # Check for common mathematical errors in vignettes
    vignette_files <- list.files("vignettes", pattern = "\\.Rmd$", full.names = TRUE)
    
    for (vignette_file in vignette_files) {
      vignette_content <- readLines(vignette_file)
      
      # Check for Gini coefficient formula errors
      gini_patterns <- c(
        "1 - \\(?2 \\* sum\\(?rank\\(?\\.\\*\\) \\* \\.*\\) / \\(?n\\(?\\) \\* sum\\(?\\.\\*\\)\\)\\) - 1/n\\(?\\)",
        "gini_coefficient.*1 -"
      )
      
      for (pattern in gini_patterns) {
        matches <- grep(pattern, vignette_content, value = TRUE)
        if (length(matches) > 0) {
          cat("   ⚠️  Potential Gini coefficient formula error in", basename(vignette_file), "\n")
          cat("      Check formula: should not start with '1 -' and should use correct final term\n")
        }
      }
    }
    
    cat("   ✅ Mathematical formula validation completed\n")
  },
  "5-10 seconds"
)

# 7. Testing
cat("\n7. Testing:\n")

# Check environment variables and platform safety for benchmarking
do_benchmarks <- Sys.getenv("PREPR_DO_BENCH", "0") == "1"  # Explicit string comparison
platform_safe <- !grepl("aarch64|arm64", Sys.info()["machine"])
microbenchmark_available <- requireNamespace("microbenchmark", quietly = TRUE)



cat("   📊 Benchmark Configuration:\n")
cat("      - PREPR_DO_BENCH:", ifelse(do_benchmarks, "enabled", "disabled (default)"), "\n")
cat("      - Platform safe:", ifelse(platform_safe, "yes", "no (ARM64 detected)"), "\n")
cat("      - microbenchmark available:", ifelse(microbenchmark_available, "yes", "no"), "\n")

if (do_benchmarks && platform_safe && microbenchmark_available) {
  cat("      - Benchmarking: ENABLED (all conditions met)\n")
} else {
  cat("      - Benchmarking: DISABLED (", 
      if (!do_benchmarks) "flag not set" 
      else if (!platform_safe) "platform not supported"
      else "microbenchmark not available", ")\n")
}

validation_status$testing <- show_progress(
  "   🔄 Running test suite",
  function() {
    # Set environment variable to control benchmarking in tests
    if (do_benchmarks && platform_safe && microbenchmark_available) {
      cat("   🚀 Running with benchmarking enabled\n")
      # Set environment variable for this R session
      Sys.setenv("PREPR_DO_BENCH" = "1")
    } else {
      cat("   ⏭️  Skipping benchmarking tests\n")
      # Set environment variable for this R session
      Sys.setenv("PREPR_DO_BENCH" = "0")
    }
    
    # Run tests with timeout and error handling
    test_results <- devtools::test(reporter = "stop")
    cat("   ✅ All tests pass\n")
  },
  "10-30 seconds"
)

# 7.5. Test Output Validation
cat("\n7.5. Test Output Validation:\n")
validation_status$test_output_validation <- show_progress(
  "   🔄 Validating test output",
  function() {
    # Check for diagnostic output pollution in R files
    r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
    # Whitelist helper files that intentionally wrap diagnostics
    whitelist_files <- c("utils_diagnostics.R")
    output_issues <- list()
    
    for (r_file in r_files) {
      if (basename(r_file) %in% whitelist_files) next
      content <- readLines(r_file)
      # Look for print(), cat(), message() outside of TESTTHAT checks
      for (i in seq_along(content)) {
        line <- content[i]
        # Skip commented lines (including roxygen)
        if (grepl("^\\s*#", line)) next
        
        # Check for output functions
        if (grepl("\\b(print|cat|message)\\s*\\(", line)) {
          # Check if this line is inside a TESTTHAT conditional
          in_testthat_block <- FALSE
          
          # Look backwards for TESTTHAT check with proper scope detection
          brace_count <- 0
          for (j in i:1) {
            line_content <- content[j]
            
            # Count closing braces
            if (grepl("^\\s*}", line_content)) {
              brace_count <- brace_count + 1
            }
            
            # Count opening braces
            if (grepl("\\{\\s*$", line_content)) {
              brace_count <- brace_count - 1
            }
            
            # Check for TESTTHAT conditional
            if (grepl('Sys.getenv("TESTTHAT") != "true"', line_content, fixed = TRUE)) {
              # If we're at brace level 0 or 1, we're in the TESTTHAT block
              if (brace_count <= 1) {
                in_testthat_block <- TRUE
              }
              break
            }
            
            # If we've gone too far back without finding the conditional, stop
            if (j < max(1, i - 50)) {
              break
            }
          }
          
          if (!in_testthat_block) {
            output_issues[[basename(r_file)]] <- c(output_issues[[basename(r_file)]], 
                                                  paste("Line", i, ":", trimws(line)))
          }
        }
      }
    }
    
    if (length(output_issues) > 0) {
      cat("   ⚠️  Diagnostic output found in R files:\n")
      for (file in names(output_issues)) {
        cat("      -", file, ":", length(output_issues[[file]]), "issues\n")
      }
      stop("Diagnostic output issues found")
    } else {
      cat("   ✅ All diagnostic output properly conditional\n")
    }
  },
  "5-10 seconds"
)

# 8. Shell Script Validation
cat("\n8. Shell Script Validation:\n")
show_progress(
  "   🔄 Validating shell scripts",
  function() {
    # Check if shell scripts are executable and have proper shebangs
    shell_scripts <- list.files("scripts", pattern = "\\.sh$", full.names = TRUE)
    
    for (script in shell_scripts) {
      # Check if executable
      if (file.access(script, mode = 1) == -1) {
        cat("   ⚠️  Shell script", basename(script), "is not executable\n")
      }
      
      # Check shebang
      first_line <- readLines(script, n = 1)
      if (!grepl("^#!/", first_line)) {
        cat("   ⚠️  Shell script", basename(script), "missing shebang\n")
      }
    }
    
    cat("   ✅ Shell script validation completed\n")
  },
  "2-5 seconds"
)

# 9. Parameter Usage Validation
cat("\n9. Parameter Usage Validation:\n")
show_progress(
  "   🔄 Validating parameter usage",
  function() {
    # Check for parameters that are validated but not used
    r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
    issues_found <- FALSE
    
    for (file in r_files) {
      content <- readLines(file)
      # Look for match.arg() calls
      match_args <- grep("match\\.arg\\(", content)
      
      for (line_num in match_args) {
        line <- content[line_num]
        # Extract parameter name from match.arg() call
        param_match <- regexpr("match\\.arg\\(([^,)]+)", line)
        if (param_match > 0) {
          param_name <- substr(line, param_match + 10, param_match + attr(param_match, "match.length") - 1)
          param_name <- gsub("^\\s+|\\s+$", "", param_name) # trim whitespace
          
          # Check if parameter is actually used in the function
          function_start <- max(1, line_num - 50) # Look back 50 lines for function start
          function_end <- min(length(content), line_num + 100) # Look forward 100 lines
          function_content <- content[function_start:function_end]
          
          # Look for parameter usage (excluding the match.arg line itself)
          usage_lines <- grep(paste0("\\b", param_name, "\\b"), function_content)
          usage_lines <- usage_lines[usage_lines != (line_num - function_start + 1)] # Exclude match.arg line
          
          if (length(usage_lines) == 0) {
            cat("   ⚠️  Parameter", param_name, "validated but not used in", basename(file), "\n")
            issues_found <- TRUE
          }
        }
      }
    }
    
    if (!issues_found) {
      cat("   ✅ Parameter usage validation completed\n")
    } else {
      stop("Parameter usage issues found")
    }
  },
  "5-10 seconds"
)

# 10. Package Check
cat("\n10. Package Check:\n")
validation_status$package_check <- show_progress(
  "   🔄 Running R CMD check",
  function() {
    check_results <- devtools::check()
    cat("   ✅ Package check completed\n")
  },
  "2-5 minutes"
)

cat("\n🎯 Pre-PR Validation Complete!\n")
cat("Review the results above and fix any issues before creating your PR.\n")
cat("This helps catch issues that Bugbot would identify.\n\n")

# Dynamic Summary based on actual results
cat("📊 SUMMARY:\n")
cat(ifelse(validation_status$code_style, "✅", "❌"), "Code Quality: Styling and linting\n")
cat(ifelse(validation_status$documentation, "✅", "❌"), "Documentation: Updated and built\n")
cat(ifelse(validation_status$readme, "✅", "❌"), "README: Built successfully\n")
cat(ifelse(validation_status$vignettes, "✅", "❌"), "Vignettes: All build successfully\n")
cat(ifelse(validation_status$function_signatures, "✅", "❌"), "Function Signatures: Validated\n")
cat(ifelse(validation_status$data_validation, "✅", "❌"), "Data Validation: Completed\n")
cat(ifelse(validation_status$testing, "✅", "❌"), "Testing: All tests pass\n")
cat(ifelse(validation_status$test_output_validation, "✅", "❌"), "Test Output: Clean and minimal\n")
cat(ifelse(validation_status$package_check, "✅", "❌"), "Package Check: Completed\n\n")

# Count issues
total_checks <- length(validation_status)
passed_checks <- sum(unlist(validation_status))
failed_checks <- total_checks - passed_checks

if (failed_checks == 0) {
  cat("🎉 All validation checks passed! Ready for PR.\n")
} else {
  cat("⚠️  ", failed_checks, "validation check(s) failed. Please fix issues before creating PR.\n")
}

cat("\n🔧 NEXT STEPS:\n")
if (!validation_status$testing) {
  cat("1. Fix failing tests\n")
}
if (!validation_status$data_validation) {
  cat("2. Fix data loading issues\n")
}
if (!validation_status$function_signatures) {
  cat("3. Fix function signature issues\n")
}
if (!validation_status$vignettes) {
  cat("4. Fix vignette build issues\n")
}
if (failed_checks == 0) {
  cat("✅ Ready to create PR!\n")
} else {
  cat("5. Run validation again after fixes\n")
} 