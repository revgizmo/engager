#!/bin/bash

# Script to remove non-essential R files for CRAN submission
# Keep only essential functions and supporting files

# Essential function files to KEEP
ESSENTIAL_FILES=(
    "analyze_transcripts.R"
    "process_zoom_transcript.R"
    "load_zoom_transcript.R"
    "consolidate_transcript.R"
    "summarize_transcript_metrics.R"
    "plot_users.R"
    "write_metrics.R"
    "ensure_privacy.R"
    "set_privacy_defaults.R"
    "privacy_audit.R"
    "load_roster.R"
    "load_session_mapping.R"
    "safe_name_matching_workflow.R"
    "schema.R"
    "validate_privacy_compliance.R"
)

# Supporting files to KEEP
SUPPORTING_FILES=(
    "engager-package.R"
    "data.R"
    "errors.R"
    "utils-pipe.R"
    "zzz.R"
)

# Combine all files to keep
ALL_KEEP_FILES=("${ESSENTIAL_FILES[@]}" "${SUPPORTING_FILES[@]}")

echo "Removing non-essential R files for CRAN submission..."
echo "Keeping essential functions and supporting files..."

# Remove non-essential files
for file in R/*.R; do
    filename=$(basename "$file")
    if [[ ! " ${ALL_KEEP_FILES[@]} " =~ " ${filename} " ]]; then
        echo "Removing non-essential file: $file"
        git rm "$file"
    else
        echo "Keeping essential file: $file"
    fi
done

echo "Package streamlining complete!"
echo "Remaining files:"
ls -la R/*.R
