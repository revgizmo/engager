#' FERPA Compliance Functions
#'
#' Functions to validate and ensure FERPA compliance for educational data.
#' These functions help institutions maintain compliance with the Family
#' Educational Rights and Privacy Act (FERPA) when using this package.
#'
#' @importFrom magrittr %>%
#' @name ferpa_compliance
NULL

# Internal function - no documentation needed
validate_ferpa_compliance <- function(data = NULL,
                                      institution_type = c("educational", "research", "mixed"),
                                      check_retention = TRUE,
                                      retention_period = c("academic_year", "semester", "quarter", "custom"),
                                      custom_retention_days = NULL,
                                      audit_log = TRUE) {
  institution_type <- match.arg(institution_type)
  retention_period <- match.arg(retention_period)

  if (!is.data.frame(data)) {
    abort_zse("`data` must be a data.frame or tibble", class = "zse_input_error")
  }

  # Initialize results
  result <- list(
    compliant = TRUE,
    pii_detected = character(0),
    recommendations = character(0),
    retention_check = NULL,
    institution_guidance = character(0)
  )

  # Check for PII fields
  pii_patterns <- c(
    "student_id", "studentid", "student_id_", "id",
    "preferred_name", "name", "first_last", "name_raw",
    "email", "email_address", "e_mail",
    "phone", "phone_number", "telephone",
    "address", "street_address", "home_address",
    "ssn", "social_security", "social_security_number",
    "birth_date", "birthday", "date_of_birth",
    "parent_name", "guardian_name"
  )

  detected_pii <- character(0)
  for (pattern in pii_patterns) {
    matching_cols <- grep(pattern, names(data), ignore.case = TRUE, value = TRUE)
    detected_pii <- c(detected_pii, matching_cols)
  }

  result$pii_detected <- unique(detected_pii)

  # Generate recommendations based on PII detection
  if (length(result$pii_detected) > 0) {
    result$compliant <- FALSE
    result$recommendations <- c(
      result$recommendations,
      paste("PII detected in columns:", paste(result$pii_detected, collapse = ", ")),
      "Consider using ensure_privacy() to mask identifiable data",
      "Review institutional FERPA policies for data handling",
      "Ensure data access is limited to authorized personnel"
    )
  }

  # Log FERPA compliance check for audit purposes
  if (audit_log) {
    log_ferpa_compliance_check(
      compliant = result$compliant,
      pii_detected = length(result$pii_detected),
      institution_type = institution_type,
      timestamp = Sys.time()
    )
  }

  # Institution-specific guidance
  if (institution_type == "educational") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Educational institutions must comply with FERPA regulations",
      "Student records must be protected from unauthorized access",
      "Consider implementing role-based access controls",
      "Document all data access and usage procedures"
    )
  } else if (institution_type == "research") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Research institutions should follow IRB guidelines",
      "Ensure proper consent procedures are in place",
      "Consider data anonymization for research publications",
      "Review institutional review board requirements"
    )
  } else if (institution_type == "mixed") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Mixed institutions must comply with both FERPA and research ethics",
      "Implement separate procedures for educational vs. research data",
      "Ensure clear data classification and handling procedures",
      "Review both FERPA and IRB requirements"
    )
  }

  # Data retention check
  if (check_retention) {
    result$retention_check <- check_data_retention_policy(
      data,
      retention_period = retention_period,
      custom_retention_days = custom_retention_days
    )

    if (!result$retention_check$compliant) {
      result$compliant <- FALSE
      result$recommendations <- c(
        result$recommendations,
        result$retention_check$recommendations
      )
    }
  }

  # Additional compliance recommendations
  result$recommendations <- c(
    result$recommendations,
    "Use set_privacy_defaults('mask') for privacy-safe outputs",
    "Implement secure data storage and transmission",
    "Train personnel on FERPA compliance requirements",
    "Maintain audit trails for data access and modifications"
  )

  result
}

#' Anonymize Educational Data
#'
#' Advanced anonymization for educational data that preserves data utility
#' while ensuring FERPA compliance.
#'
#'
#'
#'
#' # Anonymize sample data
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   preferred_name = c("Alice Johnson", "Bob Smith"),
#'   section = c("A", "B"),
#'   participation_score = c(85, 92)
#' )
#'
#' # Mask method (default)
#' anonymized <- anonymize_educational_data(sample_data, method = "mask")
#'
#' # Hash method with salt
#' hashed <- anonymize_educational_data(sample_data, method = "hash", hash_salt = "my_salt")
#'
#' @param data Data frame or tibble containing educational data
#' @param method Anonymization method: "mask", "hash", "pseudonymize", or "aggregate"
#' @param preserve_columns Vector of column names to preserve unchanged
#' @param hash_salt Salt value for hash-based anonymization
#' @param aggregation_level Level of aggregation: "individual", "section", "course", or "institution"
#' @return Anonymized data frame
#' @examples
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   preferred_name = c("Alice Johnson", "Bob Smith"),
#'   section = c("A", "B"),
#'   participation_score = c(85, 92)
#' )
#' anonymize_educational_data(sample_data)
#' @importFrom magrittr %>%
#' @export
anonymize_educational_data <- function(data = NULL,
                                       method = c("mask", "hash", "pseudonymize", "aggregate"),
                                       preserve_columns = NULL,
                                       hash_salt = NULL,
                                       aggregation_level = c("individual", "section", "course", "institution")) {
  method <- match.arg(method)
  aggregation_level <- match.arg(aggregation_level)

  if (!is.data.frame(data)) {
    stop("Data must be a data frame or tibble", call. = FALSE)
  }

  # Identify columns to anonymize
  columns_to_anonymize <- identify_anonymization_columns(data, preserve_columns)

  if (length(columns_to_anonymize) == 0) {
    # No PII columns found to anonymize
    return(data)
  }

  # Apply anonymization based on method
  if (method == "mask") {
    for (col in columns_to_anonymize) {
      data[[col]] <- paste0("Student_", seq_len(nrow(data)))
    }
  } else if (method == "hash") {
    if (is.null(hash_salt)) {
      hash_salt <- "default_salt"
    }
    for (col in columns_to_anonymize) {
      data[[col]] <- sapply(data[[col]], function(x) {
        substr(digest::digest(paste0(x, hash_salt), algo = "sha256"), 1, 8)
      })
    }
  } else if (method == "pseudonymize") {
    for (col in columns_to_anonymize) {
      unique_values <- unique(data[[col]])
      pseudonyms <- paste0("PSEUDO_", seq_along(unique_values))
      data[[col]] <- pseudonyms[match(data[[col]], unique_values)]
    }
  } else if (method == "aggregate") {
    # For aggregation, we'll group by the aggregation level
    if (aggregation_level == "section" && "section" %in% names(data)) {
      data <- data %>%
        dplyr::group_by(section) %>%
        dplyr::summarise(dplyr::across(
          dplyr::everything(),
          ~ if (is.numeric(.)) mean(., na.rm = TRUE) else first(.)
        )) %>%
        dplyr::ungroup()
    } else if (aggregation_level == "course" && "course" %in% names(data)) {
      data <- data %>%
        dplyr::group_by(course) %>%
        dplyr::summarise(dplyr::across(
          dplyr::everything(),
          ~ if (is.numeric(.)) mean(., na.rm = TRUE) else first(.)
        )) %>%
        dplyr::ungroup()
    } else {
      # Individual level - just mask the PII columns
      for (col in columns_to_anonymize) {
        data[[col]] <- "[AGGREGATED]"
      }
    }
  }

  # Add privacy metadata
  attr(data, "privacy_applied") <- TRUE
  attr(data, "anonymization_method") <- method
  attr(data, "anonymized_columns") <- columns_to_anonymize
  attr(data, "anonymization_timestamp") <- Sys.time()

  data
}

# Internal function - no documentation needed
identify_anonymization_columns <- function(data, preserve_columns) {
  # Define PII columns to anonymize
  pii_columns <- c(
    "student_id", "studentid", "student_id_",
    "preferred_name", "name", "first_last", "name_raw",
    "email", "email_address", "e_mail",
    "phone", "phone_number", "telephone"
  )

  # Find columns to anonymize
  columns_to_anonymize <- intersect(pii_columns, names(data))
  columns_to_preserve <- intersect(preserve_columns, names(data))
  setdiff(columns_to_anonymize, columns_to_preserve)
}

# Helper function for hash-based anonymization
apply_hash_anonymization <- function(data, columns_to_anonymize, hash_salt) {
  for (col in columns_to_anonymize) {
    if (is.character(data[[col]]) || is.factor(data[[col]])) {
      values <- as.character(data[[col]])
      # Create deterministic hash
      hash_input <- if (!is.null(hash_salt)) paste0(values, hash_salt) else values
      hashed_values <- sapply(hash_input, function(x) {
        if (is.na(x) || nchar(x) == 0) {
          return(x)
        }
        digest::digest(x, algo = "sha256", serialize = FALSE)
      })
      data[[col]] <- substr(hashed_values, 1, 8) # Use first 8 characters
    }
  }
  data
}


# Internal function - no documentation needed
generate_ferpa_report <- function(data = NULL,
                                  output_file = NULL,
                                  report_format = c("text", "html", "json"),
                                  include_audit_trail = TRUE,
                                  institution_info = NULL) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'generate_ferpa_report' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  report_format <- match.arg(report_format)

  # Validate data
  validation_result <- validate_ferpa_compliance(data)

  # Generate audit trail
  audit_trail <- if (include_audit_trail) {
    list(
      report_generated = Sys.time(),
      data_rows = nrow(data),
      data_columns = ncol(data),
      pii_columns_detected = length(validation_result$pii_detected),
      privacy_level = getOption("zoomstudentengagement.privacy_level", "mask")
    )
  } else {
    NULL
  }

  # Build report
  report <- list(
    title = "FERPA Compliance Report",
    generated = Sys.time(),
    summary = list(
      compliant = validation_result$compliant,
      pii_detected = validation_result$pii_detected,
      recommendations_count = length(validation_result$recommendations)
    ),
    validation_results = validation_result,
    audit_trail = audit_trail,
    institution_info = institution_info,
    recommendations = validation_result$recommendations
  )

  # Save to file if requested
  if (!is.null(output_file)) {
    if (report_format == "json") {
      jsonlite::write_json(report, output_file, pretty = TRUE)
    } else if (report_format == "html") {
      # Create simple HTML report
      html_content <- paste0(
        "<html><head><title>FERPA Compliance Report</title></head><body>",
        "<h1>FERPA Compliance Report</h1>",
        "<p><strong>Generated:</strong> ", report$generated, "</p>",
        "<p><strong>Compliant:</strong> ", ifelse(report$summary$compliant, "Yes", "No"), "</p>",
        "<h2>Recommendations</h2><ul>",
        paste0("<li>", report$recommendations, "</li>", collapse = ""),
        "</ul></body></html>"
      )
      writeLines(html_content, output_file)
    } else {
      # Text format
      text_content <- paste0(
        "FERPA Compliance Report\n",
        "Generated: ", report$generated, "\n",
        "Compliant: ", ifelse(report$summary$compliant, "Yes", "No"), "\n",
        "PII Detected: ", paste(report$summary$pii_detected, collapse = ", "), "\n",
        "\nRecommendations:\n",
        paste0("- ", report$recommendations, collapse = "\n")
      )
      writeLines(text_content, output_file)
    }
  }

  report
}

#' Check Data Retention Policy
#'
#' Validates data retention policies and identifies data that should be
#' disposed of according to institutional policies.
#'
#' @param data Data frame to check for retention policy compliance
#' @param retention_period Retention period: "academic_year", "semester", "quarter", or "custom"
#' @param custom_retention_days Custom retention period in days (for "custom" period)
#' @param date_column Column name containing dates to check
#' @param current_date Current date for comparison (default: Sys.Date())
#' @return List containing compliance status and retention analysis
#' @keywords internal
#' @examples
#' \dontrun{
#' # Check data retention policy
#' sample_data <- tibble::tibble(
#'   student_id = c("12345", "67890"),
#'   session_date = as.Date(c("2024-01-15", "2024-02-20")),
#'   participation_score = c(85, 92)
#' )
#'
#' retention_check <- check_data_retention_policy(
#'   sample_data,
#'   retention_period = "academic_year",
#'   date_column = "session_date"
#' )
#' print(retention_check$compliant)
#' }
check_data_retention_policy <- function(data = NULL,
                                        retention_period = c("academic_year", "semester", "quarter", "custom"),
                                        custom_retention_days = NULL,
                                        date_column = NULL,
                                        current_date = Sys.Date()) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'check_data_retention_policy' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  retention_period <- match.arg(retention_period)

  result <- list(
    compliant = TRUE,
    retention_period_days = 0,
    data_to_dispose = NULL,
    recommendations = character(0)
  )

  # Calculate retention period in days
  retention_days <- switch(retention_period,
    "academic_year" = 365,
    "semester" = 180,
    "quarter" = 90,
    "custom" = if (!is.null(custom_retention_days)) custom_retention_days else 365
  )

  result$retention_period_days <- retention_days

  # Check date column if provided
  if (!is.null(date_column) && date_column %in% names(data)) {
    if (is.character(data[[date_column]])) {
      dates <- as.Date(data[[date_column]])
    } else if (inherits(data[[date_column]], "Date")) {
      dates <- data[[date_column]]
    } else {
      dates <- as.Date(data[[date_column]])
    }

    # Find data older than retention period
    cutoff_date <- current_date - retention_days
    old_data_indices <- which(dates < cutoff_date)

    if (length(old_data_indices) > 0) {
      result$compliant <- FALSE
      result$data_to_dispose <- data[old_data_indices, ]
      result$recommendations <- c(
        result$recommendations,
        paste("Found", length(old_data_indices), "records older than retention period"),
        paste("Cutoff date:", cutoff_date),
        "Consider disposing of old data according to institutional policy",
        "Review data retention requirements with institutional compliance officer"
      )
    }
  }

  # General retention recommendations
  result$recommendations <- c(
    result$recommendations,
    paste("Retention period:", retention_period, "(", retention_days, "days)"),
    "Implement automated data disposal procedures",
    "Document data retention and disposal procedures",
    "Train personnel on data retention requirements"
  )

  result
}

# Internal function - no documentation needed
log_ferpa_compliance_check <- function(compliant,
                                       pii_detected,
                                       institution_type,
                                       timestamp = Sys.time()) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  warning(
    "Function 'log_ferpa_compliance_check' is deprecated and will be removed in the next version. ",
    "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
    call. = FALSE
  )

  # Create log entry
  log_entry <- list(
    timestamp = timestamp,
    compliant = compliant,
    pii_detected = pii_detected,
    institution_type = institution_type,
    session_id = Sys.getpid()
  )

  # Store in package environment for session tracking (CRAN compliant)
  log_key <- paste0("zse_ferpa_log_", format(timestamp, "%Y%m%d_%H%M%S"))
  # Simple in-memory storage for session tracking - use options() for CRAN compliance
  current_logs <- getOption("zoomstudentengagement.ferpa_logs", list())
  current_logs[[log_key]] <- log_entry
  options(zoomstudentengagement.ferpa_logs = current_logs)

  # Optionally write to file if logging is enabled
  log_file <- getOption("zoomstudentengagement.ferpa_log_file", NULL)
  if (!is.null(log_file) && is.character(log_file)) {
    tryCatch(
      {
        log_line <- paste(
          format(timestamp, "%Y-%m-%d %H:%M:%S"),
          ifelse(compliant, "COMPLIANT", "NON_COMPLIANT"),
          pii_detected,
          institution_type,
          sep = "\t"
        )
        write(log_line, file = log_file, append = TRUE)
      },
      error = function(e) {
        # Silently fail if logging fails
        NULL
      }
    )
  }

  invisible(log_entry)
}
