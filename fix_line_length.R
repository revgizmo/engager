#!/usr/bin/env Rscript

# Fix line length issues systematically
library(lintr)

# Get all line length issues
lint_results <- lintr::lint_package()
line_length_issues <- lint_results[sapply(lint_results, function(x) x$linter == "line_length_linter")]

cat("Found", length(line_length_issues), "line length issues\n")

# Group by file
file_issues <- split(line_length_issues, sapply(line_length_issues, function(x) x$filename))

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
    
    # Skip if line is already short enough
    if (nchar(line_content) <= 120) {
      next
    }
    
    cat("  Line", line_num, ":", nchar(line_content), "characters\n")
    
    # Handle different types of long lines
    if (grepl("warning\\(", line_content) && grepl("deprecated", line_content)) {
      # Split warning messages
      if (grepl("call\\. = FALSE", line_content)) {
        # Extract the warning message
        msg_match <- regmatches(line_content, regexec('warning\\("([^"]+)"', line_content))
        if (length(msg_match) > 0 && length(msg_match[[1]]) > 1) {
          msg <- msg_match[[1]][2]
          # Split message into parts
          if (nchar(msg) > 100) {
            # Find a good break point
            break_point <- max(gregexpr("\\s", substr(msg, 1, 100))[[1]])
            if (break_point > 50) {
              msg1 <- substr(msg, 1, break_point - 1)
              msg2 <- substr(msg, break_point + 1, nchar(msg))
              new_lines <- c(
                paste0("  warning("),
                paste0('    "', msg1, '",'),
                paste0('    "', msg2, '",'),
                "    call. = FALSE"
              )
              # Replace the line
              lines[line_num] <- paste(new_lines, collapse = "\n")
            }
          }
        }
      }
    } else if (grepl("#'", line_content)) {
      # Handle roxygen2 comments
      # Simple approach: break at word boundaries
      if (nchar(line_content) > 120) {
        words <- strsplit(line_content, " ")[[1]]
        new_lines <- character(0)
        current_line <- "#'"
        
        for (word in words[-1]) {  # Skip the first "#'"
          if (nchar(current_line) + nchar(word) + 1 > 120) {
            new_lines <- c(new_lines, current_line)
            current_line <- paste0("#' ", word)
          } else {
            current_line <- paste(current_line, word)
          }
        }
        new_lines <- c(new_lines, current_line)
        lines[line_num] <- paste(new_lines, collapse = "\n")
      }
    }
  }
  
  # Write the file back
  writeLines(lines, file_path)
}

cat("Line length fixes completed\n")
