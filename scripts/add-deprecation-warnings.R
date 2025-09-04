#!/usr/bin/env Rscript

# Add Deprecation Warnings to Source R Files
# This script adds deprecation warnings to deprecated functions at the source level

cat("🚨 ADDING DEPRECATION WARNINGS TO SOURCE FILES\n")
cat("=============================================\n\n")

# Source the scope reduction implementation
source("R/scope_reduction_implementation.R")

# Function to add deprecation warning to a source file
add_deprecation_warning_to_file <- function(file_path, function_name) {
  if (!file.exists(file_path)) {
    cat("  ✗ File not found:", file_path, "\n")
    return(FALSE)
  }
  
  # Read the file
  content <- readLines(file_path)
  
  # Find the function definition
  function_pattern <- paste0("^", function_name, "\\s*<-\\s*function")
  function_lines <- grep(function_pattern, content)
  
  if (length(function_lines) == 0) {
    cat("  ✗ Function", function_name, "not found in", file_path, "\n")
    return(FALSE)
  }
  
  # Add deprecation warning at the beginning of each function
  for (line_num in function_lines) {
    # Find the opening brace
    brace_line <- line_num
    for (i in line_num:length(content)) {
      if (grepl("\\{", content[i])) {
        brace_line <- i
        break
      }
    }
    
    # Create deprecation warning
    warning_code <- paste0(
      "  # DEPRECATED: This function will be removed in the next version\n",
      "  # Use essential functions instead. See ?get_essential_functions for alternatives.\n",
      "  warning(\"Function '", function_name, "' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.\", call. = FALSE)\n"
    )
    
    # Insert the warning after the opening brace
    content <- c(
      content[1:brace_line],
      warning_code,
      content[(brace_line + 1):length(content)]
    )
  }
  
  # Write the modified content back
  writeLines(content, file_path)
  cat("  ✓ Added deprecation warning to", function_name, "in", file_path, "\n")
  return(TRUE)
}

# Function to find which R file contains a function
find_function_file <- function(function_name) {
  r_files <- list.files("R/", pattern = "\\.R$", full.names = TRUE)
  
  for (file_path in r_files) {
    content <- readLines(file_path)
    if (any(grepl(paste0("^", function_name, "\\s*<-\\s*function"), content))) {
      return(file_path)
    }
  }
  
  return(NULL)
}

# Add deprecation warnings to deprecated functions
cat("Adding deprecation warnings to", length(DEPRECATED_FUNCTIONS), "deprecated functions...\n\n")

successful_deprecations <- 0
failed_deprecations <- 0

for (func_name in DEPRECATED_FUNCTIONS) {
  # Find which file contains this function
  file_path <- find_function_file(func_name)
  
  if (is.null(file_path)) {
    cat("  ✗ Could not find file for function:", func_name, "\n")
    failed_deprecations <- failed_deprecations + 1
    next
  }
  
  # Add deprecation warning
  if (add_deprecation_warning_to_file(file_path, func_name)) {
    successful_deprecations <- successful_deprecations + 1
  } else {
    failed_deprecations <- failed_deprecations + 1
  }
}

cat("\n📊 DEPRECATION WARNING SUMMARY\n")
cat("-------------------------------\n")
cat("Successful deprecations:", successful_deprecations, "\n")
cat("Failed deprecations:", failed_deprecations, "\n")
cat("Total functions processed:", length(DEPRECATED_FUNCTIONS), "\n")

if (successful_deprecations > 0) {
  cat("\n✅ DEPRECATION WARNINGS ADDED SUCCESSFULLY\n")
  cat("Next steps:\n")
  cat("1. Test the package to ensure deprecation warnings appear\n")
  cat("2. Update documentation\n")
  cat("3. Commit changes\n")
} else {
  cat("\n❌ NO DEPRECATION WARNINGS WERE ADDED\n")
  cat("Check the errors above and fix issues\n")
}
