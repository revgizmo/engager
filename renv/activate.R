local({
  project <- getwd()
  renv_dir <- file.path(project, "renv")
  repos <- Sys.getenv("RENV_CONFIG_REPOS_OVERRIDE", unset = "https://cloud.r-project.org")
  options(repos = c(CRAN = repos))

  if (!requireNamespace("renv", quietly = TRUE)) {
    install.packages("renv", repos = repos)
  }

  if (requireNamespace("renv", quietly = TRUE)) {
    renv::load(project = project)
  } else {
    stop("The 'renv' package could not be installed or loaded.")
  }
})
