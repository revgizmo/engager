# Vignette Function Migration Map

## Essential Functions (Use These)
The package now exports 24 essential functions:

### Core Workflow (7 functions):
- `analyze_transcripts()` - Main user-facing function
- `process_zoom_transcript()` - Core transcript processing
- `load_zoom_transcript()` - Basic transcript loading
- `consolidate_transcript()` - Transcript consolidation
- `summarize_transcript_metrics()` - Basic metrics
- `plot_users()` - Basic visualization
- `write_metrics()` - Basic output

### Privacy & Compliance (8 functions):
- `ensure_privacy()` - Privacy protection
- `set_privacy_defaults()` - Privacy configuration
- `privacy_audit()` - Privacy validation
- `mask_user_names_by_metric()` - Name masking
- `hash_name_consistently()` - Consistent hashing
- `anonymize_educational_data()` - Data anonymization
- `validate_privacy_compliance()` - Privacy validation
- `validate_ferpa_compliance()` - FERPA compliance

### Name Matching & Data (9 functions):
- `load_roster()` - Load student roster
- `load_session_mapping()` - Load session mapping
- `load_transcript_files_list()` - Load transcript files
- `detect_duplicate_transcripts()` - Find duplicate files
- `detect_unmatched_names()` - Find unmatched names
- `analyze_multi_session_attendance()` - Multi-session analysis
- `generate_attendance_report()` - Generate attendance reports
- `safe_name_matching_workflow()` - Safe name matching
- `validate_schema()` - Validate data structure

## Migration Examples

### Before (Deprecated):
```r
# Old function calls that may not work
plot_engagement(data)
write_engagement(data, "output.csv")
summarize_engagement(data)
```

### After (Essential Functions):
```r
# Use essential functions
plot_users(data)
write_metrics(data, "output.csv")
summarize_transcript_metrics(data)
```

## Vignette Status

### Active Vignettes (2):
- ✅ `essential-functions.Rmd` - Uses essential functions correctly
- ✅ `ferpa-ethics.Rmd` - Uses essential functions correctly

### Disabled Vignettes (8) - Need Updates:
- `getting-started.Rmd.disabled` - Uses `process_zoom_transcript()` ✓
- `ideal-course-transcripts.Rmd.disabled` - Uses `load_zoom_transcript()`, `process_zoom_transcript()`, `analyze_transcripts()` ✓
- `institutional-adoption-guide.Rmd.disabled` - Uses `analyze_transcripts()`, `plot_users()`, `write_metrics()` ✓
- `name-matching-troubleshooting.Rmd.disabled` - Uses `load_zoom_transcript()` ✓
- `plotting.Rmd.disabled` - Needs to use `plot_users()` instead of deprecated plotting functions
- `roster-cleaning.Rmd.disabled` - Uses essential functions ✓
- `session-mapping.Rmd.disabled` - Uses essential functions ✓
- `transcript-processing.Rmd.disabled` - Uses essential functions ✓
- `whole-game.Rmd.disabled` - Uses essential functions ✓

## Migration Strategy

1. **Update function calls** to use only essential functions
2. **Remove deprecated function references**
3. **Update examples** to work with current API
4. **Test all vignettes** before re-enabling
5. **Create migration guide** for users

## Success Criteria

- [ ] All vignettes use only essential functions
- [ ] All vignettes build successfully
- [ ] All examples run without errors
- [ ] Clear migration guidance provided
- [ ] CRAN compliance maintained
