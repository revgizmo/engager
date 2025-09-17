# Internal function - no documentation needed
# # Basic usage
# hash_name_consistently(c("John Smith", "J. Smith", "Smith, John"))
#
# # With normalization (handles variations)
# hash_name_consistently(c("Tom", "Thomas", "Tommy"), normalize_names = TRUE)
#
# # Without normalization (exact matching only)
# hash_name_consistently(c("Tom", "Thomas", "Tommy"), normalize_names = FALSE)
hash_name_consistently <- function(names = NULL,
                                   salt = "zoomstudentengagement",
                                   normalize_names = TRUE) {
  # Input validation
  if (!is.character(names)) {
    stop("names must be a character vector", call. = FALSE)
  }
  if (!is.character(salt) || length(salt) != 1) {
    stop("salt must be a single character string", call. = FALSE)
  }
  if (!is.logical(normalize_names) || length(normalize_names) != 1) {
    stop("normalize_names must be a single logical value", call. = FALSE)
  }

  # Handle empty input
  if (length(names) == 0) {
    return(character(0))
  }

  # Normalize names if requested
  if (normalize_names) {
    normalized_names <- normalize_name_for_matching(names)
  } else {
    normalized_names <- names
  }

  # Generate consistent hashes
  # Use digest package for secure hashing
  hashes <- sapply(normalized_names, function(name) {
    if (is.na(name) || nchar(trimws(name)) == 0) {
      return(NA_character_)
    }

    # Create hash input: normalized name + salt
    hash_input <- paste0(trimws(name), "|", salt)

    # Generate hash using digest package
    hash <- digest::digest(hash_input, algo = "sha256", serialize = FALSE)

    # Return a shorter, more readable hash (first 8 characters)
    substr(hash, 1, 8)
  })

  # Ensure we return a character vector
  as.character(hashes)
}

# Internal function - no documentation needed
normalize_name_for_matching <- function(names) {
  # DEPRECATED: This function will be removed in the next version
  # Use essential functions instead. See ?get_essential_functions for alternatives.
  if (Sys.getenv("TESTTHAT") != "true") {
    warning(
      "Function 'normalize_name_for_matching' is deprecated and will be removed in the next version. ",
      "Please use the essential functions instead. See ?get_essential_functions for alternatives.",
      call. = FALSE
    )
  }

  # Handle NA and empty values
  names[is.na(names)] <- ""
  names[nchar(trimws(names)) == 0] <- ""

  # Convert to lowercase
  normalized <- tolower(names)

  # Remove common punctuation and extra whitespace
  normalized <- gsub("[[:punct:]]", " ", normalized)
  normalized <- gsub("\\s+", " ", normalized)
  normalized <- trimws(normalized)

  # Handle common name variations
  # Remove titles (Dr., Prof., etc.)
  normalized <- gsub("\\b(dr|prof|professor|mr|mrs|ms|miss)\\b", "", normalized)
  normalized <- trimws(normalized)

  # Sort name parts for consistent ordering
  # This handles "John Smith" vs "Smith, John"
  normalized <- sapply(strsplit(normalized, " "), function(parts) {
    if (length(parts) == 0) {
      return("")
    }
    paste(sort(parts), collapse = " ")
  })

  # Return empty string for completely empty names
  normalized[nchar(normalized) == 0] <- ""

  normalized
}
