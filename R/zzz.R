# Internal package environment for session-scoped state (e.g., logs)
.zse_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # Initialize logging container
  if (is.null(.zse_env$logs)) .zse_env$logs <- list()

  # Set default options if not already set (tested in test-onload-defaults.R)
  if (is.null(getOption("zoomstudentengagement.privacy_level"))) {
    options(zoomstudentengagement.privacy_level = "mask")
  }
}

# Internal helpers to get/set logs safely
.zse_get_logs_env <- function() {
  if (is.null(.zse_env$logs)) .zse_env$logs <- list()
  .zse_env
}
