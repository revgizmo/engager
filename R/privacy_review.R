#' Privacy Review Functions
#'
#' Functions to support institutional privacy review for educational data.
#' These helpers do not guarantee legal compliance; institutions remain
#' responsible for policy review and authorization.
#'
#' @importFrom magrittr %>%
#' @name privacy_review
NULL

.privacy_review_log_env <- new.env(parent = emptyenv())

#' Review Data for Privacy Risks
#'
#' Performs a technical privacy review of a data frame by looking for common
#' identifier columns, optional retention concerns, and institution-specific
#' review prompts. This is a screening helper, not a legal compliance
#' determination.
#'
#' @param data Data frame or tibble containing educational data.
#' @param institution_type Review context: "educational", "research", or "mixed".
#' @param check_retention Whether to run the retention-policy helper.
#' @param retention_period Retention period: "academic_year", "semester",
#'   "quarter", or "custom".
#' @param custom_retention_days Custom retention period in days, used when
#'   `retention_period = "custom"`.
#' @param audit_log Whether to record an in-memory review audit event.
#' @return A named list containing the logical technical review status,
#'   detected identifier fields, recommendations, retention-review details,
#'   and institutional review prompts.
#' @export
review_privacy_risks <- function(data = NULL,
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
    passed = TRUE,
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
    result$passed <- FALSE
    result$recommendations <- c(
      result$recommendations,
      paste("PII detected in columns:", paste(result$pii_detected, collapse = ", ")),
      "Consider using ensure_privacy() to mask identifiable data",
      "Review institutional privacy policies for data handling",
      "Ensure data access is limited to authorized personnel"
    )
  }

  # Log privacy review for audit purposes
  if (audit_log) {
    log_privacy_review(
      passed = result$passed,
      pii_detected = length(result$pii_detected),
      institution_type = institution_type,
      timestamp = Sys.time()
    )
  }

  # Institution-specific guidance
  if (institution_type == "educational") {
    result$institution_guidance <- c(
      result$institution_guidance,
      "Consider reviewing applicable student-record privacy requirements",
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
      "Mixed institutions should review both student-record privacy and research ethics requirements",
      "Implement separate procedures for educational vs. research data",
      "Ensure clear data classification and handling procedures",
      "Review applicable student-record privacy and IRB requirements"
    )
  }

  # Data retention check
  if (check_retention) {
    result$retention_check <- check_data_retention_policy(
      data,
      retention_period = retention_period,
      custom_retention_days = custom_retention_days
    )

    if (!result$retention_check$passed) {
      result$passed <- FALSE
      result$recommendations <- c(
        result$recommendations,
        result$retention_check$recommendations
      )
    }
  }

  # Additional privacy review recommendations
  result$recommendations <- c(
    result$recommendations,
    "Use ensure_privacy(..., privacy_level = 'mask') or write_metrics(..., privacy_level = 'mask') for masked outputs",
    "Implement secure data storage and transmission",
    "Train personnel on applicable privacy requirements",
    "Maintain audit trails for data access and modifications"
  )

  result
}

# Deprecated compatibility wrapper. Kept unexported because the old helper was
# not part of the public NAMESPACE, but tests and historical scripts may call it.
validate_ferpa_compliance <- function(data = NULL,
                                      institution_type = c("educational", "research", "mixed"),
                                      check_retention = TRUE,
                                      retention_period = c("academic_year", "semester", "quarter", "custom"),
                                      custom_retention_days = NULL,
                                      audit_log = TRUE) {
  .Deprecated("review_privacy_risks")
  result <- review_privacy_risks(
    data = data,
    institution_type = institution_type,
    check_retention = check_retention,
    retention_period = retention_period,
    custom_retention_days = custom_retention_days,
    audit_log = audit_log
  )
  result$compliant <- result$passed
  result
}

#' Anonymize Educational Data
#'
#' Advanced anonymization for educational data that preserves data utility
#' while supporting privacy review.
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
#' # Hash method requires a caller-provided salt
#' hashed <- anonymize_educational_data(sample_data, method = "hash", hash_salt = "my_salt")
#'
#' @param data Data frame or tibble containing educational data
#' @param method Identifier transformation method: "mask", "hash", or
#'   "pseudonymize". The previously advertised "aggregate" method is not
#'   supported in version 0.1.0 because it did not reliably remove row-level
#'   identifiers.
#' @param preserve_columns Vector of column names to preserve unchanged
#' @param hash_salt Required non-empty salt for hash-based transformation.
#' @param aggregation_level Reserved for a future aggregation workflow. It has
#'   no effect for supported version 0.1.0 methods.
#' @return A data frame of the same row shape as `data`, with recognized
#'   structured identifier columns transformed by the selected method.
#'   Missing and blank identifiers remain missing or blank. These transformations
#'   do not inspect free text and do not establish that a data set is anonymous or
#'   compliant with legal or institutional requirements.
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
                                       method = c("mask", "hash", "pseudonymize"),
                                       preserve_columns = NULL,
                                       hash_salt = NULL,
                                       aggregation_level = c("individual", "section", "course", "institution")) {
  if (!is.data.frame(data)) {
    stop("Data must be a data frame or tibble", call. = FALSE)
  }

  if (length(method) == 1 && identical(method, "aggregate")) {
    stop(
      paste(
        "method = \"aggregate\" is not supported in engager 0.1.0 because",
        "the prior implementation could retain row-level identifiers.",
        "Use a supported identifier transformation and aggregate only after",
        "removing identifiers."
      ),
      call. = FALSE
    )
  }

  method <- match.arg(method)
  aggregation_level <- match.arg(aggregation_level)

  if (identical(method, "hash")) {
    invalid_hash_salt <- !is.character(hash_salt) || length(hash_salt) != 1 ||
      is.na(hash_salt) || !nzchar(trimws(hash_salt))
    if (invalid_hash_salt) {
      stop(
        "hash_salt must be one non-empty character value when method = \"hash\"",
        call. = FALSE
      )
    }
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
      values <- as.character(data[[col]])
      present <- !is.na(values) & nzchar(trimws(values))
      unique_values <- unique(values[present])
      values[present] <- paste0("Student_", match(values[present], unique_values))
      data[[col]] <- values
    }
  } else if (method == "hash") {
    for (col in columns_to_anonymize) {
      values <- as.character(data[[col]])
      present <- !is.na(values) & nzchar(trimws(values))
      values[present] <- vapply(values[present], function(x) {
        substr(digest::digest(
          paste0(x, hash_salt),
          algo = "sha256",
          serialize = FALSE
        ), 1, 8)
      }, character(1))
      data[[col]] <- values
    }
  } else if (method == "pseudonymize") {
    for (col in columns_to_anonymize) {
      values <- as.character(data[[col]])
      present <- !is.na(values) & nzchar(trimws(values))
      unique_values <- unique(values[present])
      pseudonyms <- paste0("PSEUDO_", seq_along(unique_values))
      values[present] <- pseudonyms[match(values[present], unique_values)]
      data[[col]] <- values
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


#' Generate a Privacy Review Report
#'
#' Generates a lightweight report from `review_privacy_risks()`. The report is
#' intended to support local review and documentation; it does not certify legal
#' compliance.
#'
#' @param data Data frame or tibble containing educational data.
#' @param output_file Optional file path for writing the report.
#' @param report_format Output format: "text", "html", or "json".
#' @param include_audit_trail Whether to include basic report metadata.
#' @param institution_info Optional institution-provided metadata to include.
#' @param institution_type Review context: "educational", "research", or "mixed".
#' @return A named list containing report metadata, a summary, the underlying
#'   technical review results, and recommendations. When `output_file` is
#'   supplied, the same report is also serialized there.
#' @export
generate_privacy_review_report <- function(data = NULL,
                                           output_file = NULL,
                                           report_format = c("text", "html", "json"),
                                           include_audit_trail = TRUE,
                                           institution_info = NULL,
                                           institution_type = c("educational", "research", "mixed")) {
  validate_optional_privacy_report_path(output_file)
  report_format <- match.arg(report_format)
  institution_type <- match.arg(institution_type)

  # Validate data
  validation_result <- review_privacy_risks(data, institution_type = institution_type)

  # Generate audit trail
  audit_trail <- if (include_audit_trail) {
    list(
      report_generated = Sys.time(),
      data_rows = nrow(data),
      data_columns = ncol(data),
      pii_columns_detected = length(validation_result$pii_detected),
      privacy_level = getOption("engager.privacy_level", "mask")
    )
  } else {
    NULL
  }

  # Build report
  report <- list(
    title = "Privacy Review Report",
    generated = Sys.time(),
    summary = list(
      passed = validation_result$passed,
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
    write_privacy_review_report(
      report = report,
      output_file = output_file,
      report_format = report_format,
      status_field = "passed",
      status_label = "Review passed"
    )
  }

  report
}

write_privacy_review_report <- function(report,
                                        output_file,
                                        report_format,
                                        status_field,
                                        status_label) {
  validate_optional_privacy_report_path(output_file, allow_null = FALSE)
  if (report_format == "json") {
    jsonlite::write_json(report, output_file, pretty = TRUE)
  } else if (report_format == "html") {
    html_content <- paste0(
      "<html><head><title>Privacy Review Report</title></head><body>",
      "<h1>Privacy Review Report</h1>",
      "<p><strong>Generated:</strong> ", report$generated, "</p>",
      "<p><strong>", status_label, ":</strong> ", ifelse(report$summary[[status_field]], "Yes", "No"), "</p>",
      "<h2>Recommendations</h2><ul>",
      paste0("<li>", report$recommendations, "</li>", collapse = ""),
      "</ul></body></html>"
    )
    writeLines(html_content, output_file)
  } else {
    text_content <- paste0(
      "Privacy Review Report\n",
      "Generated: ", report$generated, "\n",
      status_label, ": ", ifelse(report$summary[[status_field]], "Yes", "No"), "\n",
      "PII Detected: ", paste(report$summary$pii_detected, collapse = ", "), "\n",
      "\nRecommendations:\n",
      paste0("- ", report$recommendations, collapse = "\n")
    )
    writeLines(text_content, output_file)
  }
}

validate_optional_privacy_report_path <- function(output_file, allow_null = TRUE) {
  if (is.null(output_file) && isTRUE(allow_null)) {
    return(invisible(TRUE))
  }
  if (is.null(output_file) || !is.character(output_file) ||
      length(output_file) != 1L || is.na(output_file) ||
      !nzchar(trimws(output_file))) {
    stop(
      "`output_file` must be NULL or one explicit non-empty character path.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# Deprecated compatibility wrapper. Kept unexported because the old helper was
# not part of the public NAMESPACE, but tests and historical scripts may call it.
generate_ferpa_report <- function(data = NULL,
                                  output_file = NULL,
                                  report_format = c("text", "html", "json"),
                                  include_audit_trail = TRUE,
                                  institution_info = NULL) {
  validate_optional_privacy_report_path(output_file)
  .Deprecated("generate_privacy_review_report")
  report <- generate_privacy_review_report(
    data = data,
    output_file = NULL,
    report_format = report_format,
    include_audit_trail = include_audit_trail,
    institution_info = institution_info
  )
  report$summary$compliant <- report$summary$passed
  report$validation_results$compliant <- report$validation_results$passed

  if (!is.null(output_file)) {
    write_privacy_review_report(
      report = report,
      output_file = output_file,
      report_format = match.arg(report_format),
      status_field = "compliant",
      status_label = "Compliant"
    )
  }

  report
}

#' Review a Configured Data Retention Period
#'
#' Compares configured date fields with a selected period to support local
#' records review. It does not determine or enforce institutional policy.
#'
#' @param data Data frame to inspect for retention-period review
#' @param retention_period Retention period: "academic_year", "semester", "quarter", or "custom"
#' @param custom_retention_days Custom retention period in days (for "custom" period)
#' @param date_column Column name containing dates to check
#' @param current_date Current date for comparison (default: Sys.Date())
#' @return List containing review status and retention analysis. The `passed`
#'   field is the preferred status name; `compliant` is retained as a
#'   backward-compatible alias.
#' @keywords internal
check_data_retention_policy <- function(data = NULL,
                                        retention_period = c("academic_year", "semester", "quarter", "custom"),
                                        custom_retention_days = NULL,
                                        date_column = NULL,
                                        current_date = Sys.Date()) {
  retention_period <- match.arg(retention_period)

  if (!is.data.frame(data)) {
    stop("Data must be a data frame or tibble", call. = FALSE)
  }

  result <- list(
    passed = TRUE,
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
      result$passed <- FALSE
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
log_privacy_review <- function(passed,
                               pii_detected,
                               institution_type,
                               timestamp = Sys.time()) {
  # Create log entry
  log_entry <- list(
    timestamp = timestamp,
    passed = passed,
    pii_detected = pii_detected,
    institution_type = institution_type,
    session_id = Sys.getpid()
  )

  # Store in package environment for session tracking (CRAN compliant)
  log_key <- paste0("engager_privacy_review_log_", format(timestamp, "%Y%m%d_%H%M%OS6"))
  current_logs <- as.list(.privacy_review_log_env)
  if (length(current_logs) == 0) {
    current_logs <- getOption(
      "engager.privacy_review_logs",
      getOption("engager.ferpa_logs", list())
    )
    if (is.list(current_logs) && length(current_logs) > 0) {
      for (existing_log_key in names(current_logs)) {
        assign(existing_log_key, current_logs[[existing_log_key]], envir = .privacy_review_log_env)
      }
    }
  }
  assign(log_key, log_entry, envir = .privacy_review_log_env)

  # Backward-compatible read mirror for historical scripts/tests.
  current_logs <- as.list(.privacy_review_log_env)
  current_logs[[log_key]] <- log_entry
  options(engager.privacy_review_logs = current_logs)
  options(engager.ferpa_logs = current_logs)

  # Optionally write to file if logging is enabled
  log_file <- getOption(
    "engager.privacy_review_log_file",
    getOption("engager.ferpa_log_file", NULL)
  )
  if (!is.null(log_file) && is.character(log_file)) {
    tryCatch(
      {
        log_line <- paste(
          format(timestamp, "%Y-%m-%d %H:%M:%S"),
          ifelse(passed, "PASSED", "RISKS_DETECTED"),
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

log_ferpa_compliance_check <- function(compliant,
                                       pii_detected,
                                       institution_type,
                                       timestamp = Sys.time()) {
  .Deprecated("log_privacy_review")
  result <- log_privacy_review(
    passed = compliant,
    pii_detected = pii_detected,
    institution_type = institution_type,
    timestamp = timestamp
  )
  result$compliant <- result$passed
  invisible(result)
}
