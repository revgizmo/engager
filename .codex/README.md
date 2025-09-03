# Codex Development Environment

This directory contains configuration files for Codex-powered R package development.

## Files

- **`setup.sh`**: Containerized R development environment setup script
  - Installs R, system libraries, and development dependencies
  - Configures CRAN repository and installs essential R packages
  - Designed for use in Docker containers and CI/CD environments

## Usage

```bash
# Make setup script executable
chmod +x .codex/setup.sh

# Run in container environment
./.codex/setup.sh
```

## Dependencies Installed

### System Libraries
- R base and development packages
- Build tools and development libraries
- Graphics and font libraries
- Network and SSL libraries

### R Packages
- Development: devtools, roxygen2, testthat
- Code Quality: lintr, styler
- Documentation: pkgdown, rmarkdown
- Utilities: remotes, withr, jsonlite, httr, cli

## Notes

- LaTeX installation is commented out by default
- Script uses `set -euxo pipefail` for safety
- Designed for Ubuntu/Debian-based systems
