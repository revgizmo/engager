#!/usr/bin/env Rscript

# Fix remaining line length issues
library(lintr)

# Get all line length issues
lint_results <- lintr::lint_package()
line_length_issues <- lint_results[sapply(lint_results, function(x) x$linter == "line_length_linter")]

cat("Found", length(line_length_issues), "remaining line length issues\n")

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
    
    cat("  Line", line_num, ":", nchar(line_content), "characters\n")
    
    # Handle different types of long lines
    if (grepl("#'", line_content)) {
      # Handle roxygen2 comments - break at word boundaries
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
    } else if (grepl("<-", line_content) && !grepl("warning", line_content)) {
      # Handle long assignments - break at logical points
      if (nchar(line_content) > 120) {
        # Find a good break point (after comma, before long parameter)
        if (grepl(",", line_content)) {
          # Break after the first comma
          comma_pos <- regexpr(",", line_content)
          if (comma_pos > 0 && comma_pos < 100) {
            part1 <- substr(line_content, 1, comma_pos)
            part2 <- substr(line_content, comma_pos + 1, nchar(line_content))
            # Add proper indentation to part2
            indent <- strrep(" ", nchar(line_content) - nchar(trimws(line_content)))
            lines[line_num] <- paste0(part1, "\n", indent, trimws(part2))
          }
        }
      }
    }
  }
  
  # Write the file back
  writeLines(lines, file_path)
}

cat("Remaining line length fixes completed\n")
