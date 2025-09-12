#!/bin/bash

# Script to remove non-essential test files for CRAN submission
# Keep only tests for essential functions

# Essential function test files to KEEP
ESSENTIAL_TEST_FILES=(
    "test-analyze_transcripts.R"
    "test-process_zoom_transcript.R"
    "test-load_zoom_transcript.R"
    "test-consolidate_transcript.R"
    "test-summarize_transcript_metrics.R"
    "test-plot_users.R"
    "test-write_metrics.R"
    "test-ensure_privacy.R"
    "test-set_privacy_defaults.R"
    "test-privacy_audit.R"
    "test-load_roster.R"
    "test-load_session_mapping.R"
    "test-safe_name_matching_workflow.R"
    "test-validate_schema.R"
    "test-validate_privacy_compliance.R"
)

# Supporting test files to KEEP
SUPPORTING_TEST_FILES=(
    "test-engager-package.R"
    "test-data.R"
    "test-errors.R"
    "test-utils-pipe.R"
    "test-zzz.R"
)

# Combine all test files to keep
ALL_KEEP_TEST_FILES=("${ESSENTIAL_TEST_FILES[@]}" "${SUPPORTING_TEST_FILES[@]}")

echo "Removing non-essential test files for CRAN submission..."
echo "Keeping tests for essential functions and supporting files..."

# Remove non-essential test files
for file in tests/testthat/test-*.R; do
    filename=$(basename "$file")
    if [[ ! " ${ALL_KEEP_TEST_FILES[@]} " =~ " ${filename} " ]]; then
        echo "Removing non-essential test file: $file"
        git rm "$file"
    else
        echo "Keeping essential test file: $file"
    fi
done

echo "Test file streamlining complete!"
echo "Remaining test files:"
ls -la tests/testthat/test-*.R
