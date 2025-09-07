# Function Migration Guide

## Overview
This guide helps users migrate from deprecated functions to their essential function equivalents in the `zoomstudentengagement` package.

## Quick Start
The main function for most users is `analyze_transcripts()`:

```r
# Load and analyze transcripts
results <- analyze_transcripts(
  transcript_files = c("session1.vtt", "session2.vtt"),
  roster_file = "roster.csv"
)

# View results
print(results)
```

## Essential Functions (24 Total)

### Core Workflow (7 functions)
- `analyze_transcripts()` - Main user-facing function
- `process_zoom_transcript()` - Core transcript processing
- `load_zoom_transcript()` - Basic transcript loading
- `consolidate_transcript()` - Transcript consolidation
- `summarize_transcript_metrics()` - Basic metrics
- `plot_users()` - Basic visualization
- `write_metrics()` - Basic output

### Privacy & Compliance (8 functions)
- `ensure_privacy()` - Privacy protection
- `set_privacy_defaults()` - Privacy configuration
- `privacy_audit()` - Privacy validation
- `mask_user_names_by_metric()` - Name masking
- `hash_name_consistently()` - Consistent hashing
- `anonymize_educational_data()` - Data anonymization
- `validate_privacy_compliance()` - Privacy validation
- `validate_ferpa_compliance()` - FERPA compliance

### Name Matching & Data (9 functions)
- `load_roster()` - Load student roster
- `load_session_mapping()` - Load session mapping
- `load_transcript_files_list()` - Load transcript files
- `detect_duplicate_transcripts()` - Find duplicate files
- `detect_unmatched_names()` - Find unmatched names
- `analyze_multi_session_attendance()` - Multi-session analysis
- `generate_attendance_report()` - Generate attendance reports
- `safe_name_matching_workflow()` - Safe name matching
- `validate_schema()` - Validate data structure

## Function Replacements

### Visualization Functions
**Before (Deprecated):**
```r
plot_engagement(data)
plot_participation(data)
plot_attendance(data)
```

**After (Essential Functions):**
```r
plot_users(data, metric = "n")           # Comment count
plot_users(data, metric = "duration")    # Speaking duration
plot_users(data, metric = "session_ct")  # Attendance
```

### Writing Functions
**Before (Deprecated):**
```r
write_engagement(data, "output.csv")
write_participation(data, "output.csv")
```

**After (Essential Functions):**
```r
write_metrics(data, "output.csv")
```

### Analysis Functions
**Before (Deprecated):**
```r
summarize_engagement(data)
analyze_participation(data)
```

**After (Essential Functions):**
```r
summarize_transcript_metrics(data)
analyze_transcripts(transcript_files, roster_file)
```

### Privacy Functions
**Before (Deprecated):**
```r
mask_names(data)
anonymize_data(data)
```

**After (Essential Functions):**
```r
mask_user_names_by_metric(data)
anonymize_educational_data(data)
```

## Migration Examples

### Example 1: Basic Analysis Workflow

**Before:**
```r
# Old workflow
transcript <- load_zoom_transcript("session.vtt")
processed <- process_zoom_transcript(transcript)
summary <- summarize_engagement(processed)
plot_engagement(summary)
write_engagement(summary, "output.csv")
```

**After:**
```r
# New workflow using essential functions
transcript <- load_zoom_transcript("session.vtt")
processed <- process_zoom_transcript(transcript)
summary <- summarize_transcript_metrics(processed)
plot_users(summary, metric = "n")
write_metrics(summary, "output.csv")
```

### Example 2: Privacy-First Analysis

**Before:**
```r
# Old privacy workflow
data <- load_data()
masked <- mask_names(data)
validated <- validate_privacy(masked)
```

**After:**
```r
# New privacy workflow
data <- load_data()
masked <- mask_user_names_by_metric(data)
validated <- validate_privacy_compliance(masked)
```

### Example 3: Multi-Session Analysis

**Before:**
```r
# Old multi-session workflow
sessions <- load_multiple_sessions()
attendance <- analyze_attendance(sessions)
report <- generate_report(attendance)
```

**After:**
```r
# New multi-session workflow
sessions <- load_transcript_files_list("transcripts/")
attendance <- analyze_multi_session_attendance(sessions)
report <- generate_attendance_report(attendance)
```

## Vignette Updates

### Active Vignettes (4)
- ✅ `essential-functions.Rmd` - Core functionality overview
- ✅ `ferpa-ethics.Rmd` - Privacy and compliance guide
- ✅ `getting-started.Rmd` - Quick start guide
- ✅ `plotting.Rmd` - Visualization examples

### Disabled Vignettes (6) - Ready for Re-enabling
- `ideal-course-transcripts.Rmd.disabled` - Uses essential functions ✓
- `institutional-adoption-guide.Rmd.disabled` - Uses essential functions ✓
- `name-matching-troubleshooting.Rmd.disabled` - Uses essential functions ✓
- `roster-cleaning.Rmd.disabled` - Uses essential functions ✓
- `session-mapping.Rmd.disabled` - Uses essential functions ✓
- `transcript-processing.Rmd.disabled` - Uses essential functions ✓
- `whole-game.Rmd.disabled` - Uses essential functions ✓

## Benefits of Migration

1. **Focused Functionality**: Only essential functions are exported
2. **Easier Maintenance**: Smaller codebase to maintain
3. **Better User Experience**: Clear, focused API
4. **CRAN Ready**: Minimal function surface for submission
5. **Privacy First**: All functions prioritize data protection

## Getting Help

- **Package Documentation**: `?zoomstudentengagement`
- **Function Help**: `?analyze_transcripts`, `?plot_users`, `?write_metrics`
- **Vignettes**: `vignette("essential-functions")`, `vignette("getting-started")`
- **GitHub Issues**: Report problems or ask questions

## Next Steps

1. **Update Your Code**: Replace deprecated function calls with essential functions
2. **Test Your Workflows**: Ensure all examples work with the new API
3. **Review Privacy Settings**: Use `set_privacy_defaults()` for your institution
4. **Validate Compliance**: Use `validate_ferpa_compliance()` for data validation

The package now provides a clean, focused API for analyzing student engagement from Zoom transcripts while maintaining strong privacy protection and FERPA compliance.
