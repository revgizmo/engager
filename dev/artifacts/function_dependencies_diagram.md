# Function Dependencies Diagram for zoomstudentengagement Package

This diagram shows all exported functions and their dependencies on internal functions in the zoomstudentengagement R package.

```mermaid
graph TD
    %% Core Processing Functions
    analyze_transcripts["analyze_transcripts<br/>(exported)"] --> summarize_transcript_files["summarize_transcript_files<br/>(exported)"]
    analyze_transcripts --> write_metrics["write_metrics<br/>(exported)"]

    summarize_transcript_files --> detect_duplicate_transcripts["detect_duplicate_transcripts<br/>(exported)"]
    summarize_transcript_files --> summarize_transcript_metrics["summarize_transcript_metrics<br/>(exported)"]
    summarize_transcript_files --> process_transcript_files["process_transcript_files<br/>(internal)"]

    summarize_transcript_metrics --> process_zoom_transcript["process_zoom_transcript<br/>(exported)"]
    summarize_transcript_metrics --> ensure_privacy["ensure_privacy<br/>(exported)"]

    process_zoom_transcript --> load_zoom_transcript["load_zoom_transcript<br/>(exported)"]
    process_zoom_transcript --> consolidate_transcript["consolidate_transcript<br/>(exported)"]
    process_zoom_transcript --> add_dead_air_rows["add_dead_air_rows<br/>(exported)"]

    %% Privacy and Compliance
    ensure_privacy --> validate_privacy_level["validate_privacy_level<br/>(internal)"]
    ensure_privacy --> apply_privacy_masking["apply_privacy_masking<br/>(internal)"]

    validate_privacy_compliance["validate_privacy_compliance<br/>(exported)"] --> detect_privacy_violations["detect_privacy_violations<br/>(internal)"]

    %% Plotting Functions
    plot_users["plot_users<br/>(exported)"] --> validate_plot_users_inputs["validate_plot_users_inputs<br/>(internal)"]
    plot_users --> apply_plot_users_masking["apply_plot_users_masking<br/>(internal)"]
    plot_users --> build_plot_users_chart["build_plot_users_chart<br/>(internal)"]

    %% Duplicate Detection
    detect_duplicate_transcripts --> validate_duplicate_inputs["validate_duplicate_inputs<br/>(exported)"]
    detect_duplicate_transcripts --> calculate_content_similarity["calculate_content_similarity<br/>(exported)"]

    %% Error Handling
    abort_zse["abort_zse<br/>(internal)"] --> rlang["rlang::abort<br/>(external)"]

    %% Styling
    classDef exported fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef internal fill:#f3e5f5,stroke:#4a148c,stroke-width:1px
    classDef deprecated fill:#ffebee,stroke:#b71c1c,stroke-width:2px,stroke-dasharray: 5 5
    classDef external fill:#e8f5e8,stroke:#2e7d32,stroke-width:1px

    class analyze_transcripts,summarize_transcript_files,summarize_transcript_metrics,process_zoom_transcript,load_zoom_transcript,consolidate_transcript,detect_duplicate_transcripts,validate_duplicate_inputs,calculate_content_similarity,ensure_privacy,write_metrics,validate_privacy_compliance,plot_users exported

    class process_transcript_files,validate_privacy_level,apply_privacy_masking,detect_privacy_violations,validate_plot_users_inputs,apply_plot_users_masking,build_plot_users_chart,abort_zse internal

    class rlang external
```

## Key Function Categories

### Core Processing Pipeline
- **analyze_transcripts**: Main entry point for transcript analysis
- **summarize_transcript_files**: Orchestrates batch processing of multiple transcripts
- **summarize_transcript_metrics**: Processes individual transcript files
- **process_zoom_transcript**: Core transcript processing with consolidation and dead air handling
- **load_zoom_transcript**: Loads and parses VTT transcript files

### Privacy and Compliance
- **ensure_privacy**: Applies privacy masking to data outputs
- **validate_privacy_compliance**: Validates that privacy rules are properly applied
- **write_metrics**: Unified writer with privacy enforcement

### Duplicate Detection
- **detect_duplicate_transcripts**: Identifies duplicate transcript files
- **calculate_content_similarity**: Compares transcript content for similarity

### Visualization
- **plot_users**: Creates engagement visualizations with privacy options

## Legend
- **Blue nodes**: Exported functions (public API)
- **Purple nodes**: Internal helper functions
- **Red dashed nodes**: Deprecated functions (marked for removal)
- **Green nodes**: External dependencies (base R, other packages)

## Notes
- Updated on2025-09-18to reflect current package structure
- The package emphasizes privacy-first design with automatic name masking
- Core processing functions use base R operations to avoid segmentation faults
- Error handling is centralized through the `abort_zse` function

