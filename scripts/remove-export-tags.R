#!/usr/bin/env Rscript

# Remove @export tags from deprecated functions
# This script removes @export tags from deprecated functions to implement scope reduction

cat("🚨 REMOVING @EXPORT TAGS FROM DEPRECATED FUNCTIONS\n")
cat("================================================\n\n")

# Source the scope reduction implementation
source("R/scope_reduction_implementation.R")

# Function to remove @export tag from a file
remove_export_tag_from_file <- function(file_path, function_name) {
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
  
  # Look for @export tag in the roxygen2 documentation above the function
  for (line_num in function_lines) {
    # Look backwards from function definition for roxygen2 comments
    start_line <- max(1, line_num - 20)  # Look up to 20 lines back
    
    for (i in start_line:line_num) {
      if (grepl("^#'", content[i])) {
        # Found roxygen2 comment
        if (grepl("@export", content[i])) {
          # Remove @export tag
          content[i] <- gsub("@export", "# @export (REMOVED - deprecated function)", content[i])
          cat("  ✓ Removed @export tag from", function_name, "in", file_path, "\n")
          break
        }
      } else if (grepl("^[^#]", content[i])) {
        # Found non-comment line, stop looking
        break
      }
    }
  }
  
  # Write the modified content back
  writeLines(content, file_path)
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

# Remove @export tags from deprecated functions
cat("Removing @export tags from", length(DEPRECATED_FUNCTIONS), "deprecated functions...\n\n")

successful_removals <- 0
failed_removals <- 0

for (func_name in DEPRECATED_FUNCTIONS) {
  # Find which file contains this function
  file_path <- find_function_file(func_name)
  
  if (is.null(file_path)) {
    cat("  ✗ Could not find file for function:", func_name, "\n")
    failed_removals <- failed_removals + 1
    next
  }
  
  # Remove @export tag
  if (remove_export_tag_from_file(file_path, func_name)) {
    successful_removals <- successful_removals + 1
  } else {
    failed_removals <- failed_removals + 1
  }
}

cat("\n📊 @EXPORT TAG REMOVAL SUMMARY\n")
cat("-------------------------------\n")
cat("Successful removals:", successful_removals, "\n")
cat("Failed removals:", failed_removals, "\n")
cat("Total functions processed:", length(DEPRECATED_FUNCTIONS), "\n")

if (successful_removals > 0) {
  cat("\n✅ @EXPORT TAGS REMOVED SUCCESSFULLY\n")
  cat("Next steps:\n")
  cat("1. Run devtools::document() to regenerate NAMESPACE\n")
  cat("2. Test package functionality\n")
  cat("3. Commit changes\n")
} else {
  cat("\n❌ NO @EXPORT TAGS WERE REMOVED\n")
  cat("Check the errors above and fix issues\n")
}
