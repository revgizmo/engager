# Bug Log

## Bug 1
- **Issue**: `load_transcript_files_list()` redundantly checked for file existence after confirming the directory, which could return `NULL` instead of an empty tibble when no matching files were found.
- **Fix**: Simplified directory handling, removed unnecessary `file.exists` check, and ensured the function always returns an empty tibble when no transcript files are present.
- **Strategic Solution**: N/A (fewer than 5 bugs fixed).
