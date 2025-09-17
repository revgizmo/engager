# Internal function - no documentation needed
mask_user_names_by_metric <-
  function(df = NULL,
           metric = "session_ct",
           target_student = "") {
    if (tibble::is_tibble(df)) {
      # Use base R operations instead of dplyr to avoid segmentation fault
      if (!metric %in% names(df)) {
        stop(sprintf("Metric '%s' not found in data", metric), call. = FALSE)
      }
      metric_col <- df[[metric]]

      # Handle NA values by replacing with -Inf for sorting
      metric_col_clean <- ifelse(is.na(metric_col), -Inf, metric_col)

      # Sort by metric (descending) and get row numbers
      sorted_indices <- order(metric_col_clean, decreasing = TRUE)
      row_numbers <- match(seq_along(metric_col_clean), sorted_indices)

      # Create student names using base R
      student_names <- character(length(row_numbers))
      for (i in seq_along(row_numbers)) {
        name_i <- df$preferred_name[i]
        if (!is.na(name_i) && nzchar(target_student) && identical(name_i, target_student)) {
          student_names[i] <- paste0("**", target_student, "**")
        } else {
          student_names[i] <- paste("Student", stringr::str_pad(row_numbers[i], width = 2, pad = "0"), sep = " ")
        }
      }

      # Create result dataframe
      result <- df
      result$student <- student_names

      # Convert to tibble to maintain expected return type
      return(tibble::as_tibble(result))
    }
  }
