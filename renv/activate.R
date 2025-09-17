local({
  project <- getwd()
  repos <- Sys.getenv("RENV_CONFIG_REPOS_OVERRIDE", unset = "https://cloud.r-project.org")
  options(repos = c(CRAN = repos))

  ensure_package <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg, repos = repos)
    }
  }

  ensure_package("renv")

  if (!requireNamespace("renv", quietly = TRUE)) {
    stop("The 'renv' package could not be installed or loaded.")
  }

  renv::load(project = project)

  has_package <- function(pkg) {
    isTRUE(tryCatch(requireNamespace(pkg, quietly = TRUE), error = function(e) FALSE))
  }

  required <- c(
    "digest", "dplyr", "ggplot2", "hms", "jsonlite", "lubridate", "magrittr",
    "openxlsx", "readr", "rlang", "stringr", "tibble",
    "testthat", "withr", "covr", "knitr", "rmarkdown", "purrr",
    "microbenchmark", "pryr", "gridExtra", "devtools",
    "styler", "roxygen2", "rcmdcheck"
  )

  missing <- required[!vapply(required, has_package, logical(1))]

  if (length(missing)) {
    message("Installing missing project packages via renv: ", paste(missing, collapse = ", "))
    tryCatch(
      renv::install(missing, prompt = FALSE),
      error = function(err) {
        warning("renv automatic install failed: ", conditionMessage(err))
      }
    )
  }
})
