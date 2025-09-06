#!/usr/bin/env Rscript

# Fix return issues (explicit returns not needed)
library(lintr)

# Get all return issues
lint_results <- lintr::lint_package()
return_issues <- lint_results[sapply(lint_results, function(x) x$linter == "return_linter")]

cat("Found", length(return_issues), "return issues\n")

# Group by file
file_issues <- split(return_issues, sapply(return_issues, function(x) x$filename))

for (file_path in names(file_issues)) {
  cat("Processing", file_path, "with", length(file_issues[[file_path]]), "issues\n")
  
  # Read the file
  lines <- readLines(file_path)
  
  # Sort issues by line number (descending to avoid line number shifts)
  issues <- file_issues[[file_path]]
  line_numbers <- sapply(issues, function(x) x$line_number)
  issues <- issues[order(line_numbers, decreasing = TRUE)]
  
  for (issue in issues) {
    line_num <- issue$line_number
    line_content <- lines[line_num]
    
    cat("  Line", line_num, ":", issue$message, "\n")
    
    # Remove explicit return statements
    if (grepl("return\\(", line_content)) {
      # Extract the return value
      return_match <- regmatches(line_content, regexec("return\\(([^)]+)\\)", line_content))
      if (length(return_match) > 0 && length(return_match[[1]]) > 1) {
        return_value <- return_match[[1]][2]
        # Replace with just the value
        lines[line_num] <- paste0(strrep(" ", nchar(line_content) - nchar(trimws(line_content))), return_value)
        cat("    Removed explicit return for:", return_value, "\n")
      }
    }
  }
  
  # Write the file back
  writeLines(lines, file_path)
}

cat("Return issues fixes completed\n")
