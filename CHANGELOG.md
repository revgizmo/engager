# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-12

### Added
- **Initial CRAN-ready release** of the engager package
- **Complete package functionality** for analyzing student engagement from Zoom transcripts
- **47 exported functions** with comprehensive roxygen2 documentation
- **90.48% test coverage** with 1,785 passing tests
- **Privacy-first design** with FERPA compliance and data anonymization
- **Comprehensive plotting capabilities** for engagement visualization
- **Batch processing support** for multiple transcript files
- **Session management** and transcript consolidation
- **Multiple export formats** (CSV, Excel) for analysis results
- **Vignettes and documentation** for getting started and advanced usage

### Features
- **Student engagement analysis** from Zoom transcript data
- **Participation equity metrics** with privacy protection
- **Name matching workflow** with user-friendly prompts
- **Transcript processing** with support for various Zoom formats
- **Engagement visualization** with customizable plots
- **Privacy controls** including masking, hashing, and pseudonymization
- **FERPA compliance** with educational data protection
- **Performance optimization** for large transcript files

### Technical
- **R CMD check**: 0 errors, 0 warnings, 2 acceptable notes
- **All vignettes building** successfully
- **Complete roxygen2 documentation** for all exported functions
- **Professional package structure** following R package best practices
- **Comprehensive test suite** covering all major functionality
- **Code quality** with consistent styling and error handling
- **Dependency management** with proper version constraints

### Package Structure
- **Core functions**: Transcript loading, processing, and analysis
- **Privacy functions**: Data anonymization and FERPA compliance
- **Visualization functions**: Engagement plotting and reporting
- **Utility functions**: File handling, data validation, and formatting
- **Internal functions**: Helper functions for package operation

### Dependencies
- **Core**: data.table, dplyr, ggplot2, lubridate, magrittr, readr, rlang, stringr, tibble, tidyr, tidyselect
- **Development**: testthat, covr, knitr, rmarkdown
- **Optional**: openxlsx (for Excel export), digest (for hashing)

### Installation
```r
# Install from GitHub (development version)
remotes::install_github("revgizmo/engager")

# Install from CRAN (after submission)
install.packages("engager")
```

### Quick Start
```r
library(engager)

# Load and analyze transcripts
transcripts <- load_zoom_transcript("path/to/transcript.vtt")
engagement <- analyze_transcript_engagement(transcripts)

# Visualize results
plot_users(engagement, metric = "speaking_time")

# Export results
write_metrics(engagement, "output.csv")
```

### Documentation
- **README.md**: Package overview and installation
- **Vignettes**: Getting started and advanced usage
- **Function documentation**: Complete roxygen2 docs
- **Examples**: Working examples for all exported functions

### License
MIT License - see LICENSE file for details

### Contributing
See CONTRIBUTING.md for development guidelines and contribution process

### Support
- **Issues**: https://github.com/revgizmo/engager/issues
- **Documentation**: https://revgizmo.github.io/engager/
- **Email**: conorhealy@berkeley.edu

---

## Future Releases

### [0.1.1] - Planned
- Bug fixes and minor improvements
- Enhanced error handling
- Performance optimizations

### [0.2.0] - Planned
- New plotting options and themes
- Enhanced privacy controls
- Additional export formats
- Performance improvements

### [1.0.0] - Planned
- API stabilization
- Complete documentation
- Full test coverage
- Production-ready release
