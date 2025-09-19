#!/usr/bin/env Rscript

# Fix object usage issues (unused variables)
library(lintr)

# Get all object usage issues
lint_results <- lintr::lint_package()
object_usage_issues <- lint_results[sapply(lint_results, function(x) x$linter == "object_usage_linter")]

cat("Found", length(object_usage_issues), "object usage issues\n")

# Group by file
file_issues <- split(object_usage_issues, sapply(object_usage_issues, function(x) x$filename))

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
    
    # Handle different types of unused variable issues
    if (grepl("local variable.*assigned but may not be used", issue$message)) {
      # Extract variable name
      var_match <- regmatches(issue$message, regexec("local variable '([^']+)' assigned but may not be used", issue$message))
      if (length(var_match) > 0 && length(var_match[[1]]) > 1) {
        var_name <- var_match[[1]][2]
        
        # Check if this is a NULL assignment (common pattern)
        if (grepl(paste0(var_name, "\\s*<-\\s*NULL"), line_content)) {
          # Remove the line entirely
          lines <- lines[-line_num]
          cat("    Removed NULL assignment for", var_name, "\n")
        } else if (grepl(paste0(var_name, "\\s*<-\\s*"), line_content)) {
          # Check if it's part of a multi-assignment
          if (grepl("<-.*<-.*<-", line_content)) {
            # Remove just this variable from the multi-assignment
            # This is more complex, so let's just comment it out for now
            lines[line_num] <- paste0("# ", line_content, " # UNUSED")
            cat("    Commented out assignment for", var_name, "\n")
          } else {
            # Single assignment - remove the line
            lines <- lines[-line_num]
            cat("    Removed assignment for", var_name, "\n")
          }
        }
      }
    }
  }
  
  # Write the file back
  writeLines(lines, file_path)
}

cat("Object usage fixes completed\n")
