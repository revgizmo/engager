#' Set Privacy Defaults
#'
#' Configure global privacy behavior for the package. The default on package
#' load is `mask`, which replaces personally identifiable fields with
#' FERPA-safe placeholders. Set to `"none"` to disable masking (not
#' recommended).
#'
#'   Defaults to `"mask"`. Use `"ferpa_strict"` for maximum FERPA compliance.
#'   One of `c("stop", "warn")`. Defaults to `"stop"` for maximum privacy protection.
#'   Use `"warn"` for guided matching with user intervention.
#'
#'
#'
#' # Set privacy to mask (default)
#' set_privacy_defaults("mask")
#'
#' # Set FERPA standard compliance
#' set_privacy_defaults("ferpa_standard")
#'
#' # Set maximum FERPA compliance
#' set_privacy_defaults("ferpa_strict")
#'
#' # Temporarily disable masking (will emit a warning)
#' set_privacy_defaults("none")
#'
#' # Configure unmatched names behavior
#' set_privacy_defaults(
#'   privacy_level = "mask",
#'   unmatched_names_action = "warn"
#' )
set_privacy_defaults <- function(privacy_level = c("ferpa_strict", "ferpa_standard", "mask", "none"),
                                 unmatched_names_action = c("stop", "warn")) {
  privacy_level <- match.arg(privacy_level)
  unmatched_names_action <- match.arg(unmatched_names_action)

  # Validate privacy level
  if (identical(privacy_level, "none")) {
    warning(
      "Privacy disabled globally; outputs may contain identifiable data.",
      call. = FALSE
    )
  } else if (identical(privacy_level, "ferpa_strict")) {
    if (getOption("engager.verbose", FALSE)) {
      message("FERPA strict mode enabled; maximum privacy protection applied.")
    }
  } else if (identical(privacy_level, "ferpa_standard")) {
    if (getOption("engager.verbose", FALSE)) {
      message("FERPA standard mode enabled; educational compliance protection applied.")
    }
  }

  # Validate unmatched names action
  if (identical(unmatched_names_action, "stop")) {
    # Unmatched names action set to 'stop' - maximum privacy protection enabled.
  } else if (identical(unmatched_names_action, "warn")) {
    # Unmatched names action set to 'warn' - guided matching enabled.
  }

  # Set global options
  options(
    engager.privacy_level = privacy_level,
    engager.unmatched_names_action = unmatched_names_action
  )

  # Return configuration invisibly
  invisible(list(
    privacy_level = privacy_level,
    unmatched_names_action = unmatched_names_action
  ))
}
