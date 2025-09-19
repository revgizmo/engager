# Ideal Course Transcript Export Functions

## Overview

The `engager` package provides comprehensive export functions for ideal course transcripts, supporting multiple formats and maintaining privacy compliance.

## Available Export Functions

### CSV Export
- **Function**: `export_ideal_transcripts_csv()`
- **Format**: Comma-separated values
- **Use Case**: Spreadsheet analysis, data import to other tools
- **Features**: Privacy protection, metadata inclusion

### JSON Export
- **Function**: `export_ideal_transcripts_json()`
- **Format**: JavaScript Object Notation
- **Use Case**: Web applications, API integration
- **Features**: Structured data, pretty printing option

### Excel Export
- **Function**: `export_ideal_transcripts_excel()`
- **Format**: Microsoft Excel (.xlsx)
- **Use Case**: Detailed reporting, rich formatting
- **Features**: Multiple sheets, metadata, summary data

### Summary Export
- **Function**: `export_ideal_transcripts_summary()`
- **Format**: Multiple formats (CSV, JSON, Excel)
- **Use Case**: Key metrics and insights
- **Features**: Aggregated data, multiple output formats

## Usage Examples

### Basic CSV Export
```r
# Load ideal course transcript data
transcript_data <- process_ideal_course_batch()

# Export to CSV
export_ideal_transcripts_csv(transcript_data)
```

### JSON Export with Custom Settings
```r
# Export to JSON with custom privacy level
export_ideal_transcripts_json(
  transcript_data,
  file_path = "my_transcript.json",
  privacy_level = "full",
  pretty_print = TRUE
)
```

### Excel Export with Multiple Sheets
```r
# Export to Excel with summary and metadata
export_ideal_transcripts_excel(
  transcript_data,
  include_summary_sheet = TRUE,
  include_metadata_sheet = TRUE
)
```

### Summary Report Export
```r
# Export summary in multiple formats
export_ideal_transcripts_summary(
  transcript_data,
  format = "excel",
  include_charts = TRUE
)
```

## Privacy and Security

All export functions respect the package's privacy framework:
- **Data Masking**: Names are masked according to privacy level
- **FERPA Compliance**: No PII in exported files unless explicitly allowed
- **Audit Trail**: Export activities are logged (without sensitive data)

## File Naming

Export functions generate default filenames with timestamps:
- CSV: `ideal_transcript_export_YYYYMMDD_HHMMSS.csv`
- JSON: `ideal_transcript_export_YYYYMMDD_HHMMSS.json`
- Excel: `ideal_transcript_export_YYYYMMDD_HHMMSS.xlsx`
- Summary: `ideal_transcript_summary_YYYYMMDD_HHMMSS.[format]`

## Error Handling

Export functions provide clear error messages for:
- Invalid input data
- File system errors
- Permission issues
- Missing dependencies

## Performance Considerations

- **Large Files**: Functions handle large transcript datasets efficiently
- **Memory Usage**: Data is processed in chunks for large files
- **Progress Tracking**: Long operations show progress indicators

## Function Parameters

### Common Parameters
- `transcript_data`: Data frame containing transcript data
- `file_path`: Output file path (optional, generates default if NULL)
- `privacy_level`: Privacy level for data masking (default from option)

### CSV Export Parameters
- `include_metadata`: Whether to include metadata in export (default: TRUE)

### JSON Export Parameters
- `pretty_print`: Whether to format JSON with indentation (default: TRUE)
- `include_metadata`: Whether to include metadata (default: TRUE)

### Excel Export Parameters
- `include_summary_sheet`: Whether to include summary sheet (default: TRUE)
- `include_metadata_sheet`: Whether to include metadata sheet (default: TRUE)

### Summary Export Parameters
- `format`: Output format: "csv", "json", or "excel" (default: "csv")
- `include_charts`: Whether to include charts (Excel only, default: FALSE)

## Return Values

- **CSV Export**: Invisibly returns the exported data frame
- **JSON Export**: Invisibly returns the exported data as list
- **Excel Export**: Invisibly returns the workbook object
- **Summary Export**: Invisibly returns the summary data

## Dependencies

The export functions require the following packages:
- `jsonlite`: For JSON export functionality
- `openxlsx`: For Excel export functionality
- `tibble`: For data frame operations
- `utils`: For CSV writing

## Integration with Existing Functions

The export functions integrate seamlessly with existing package functions:
- **Privacy Protection**: Uses `ensure_privacy()` for data masking
- **Data Processing**: Works with output from `process_ideal_course_batch()`
- **Validation**: Compatible with validation functions from Issue #425

## Best Practices

1. **Privacy First**: Always use appropriate privacy levels for your use case
2. **File Management**: Use descriptive file paths and organize exports
3. **Data Validation**: Validate transcript data before export
4. **Error Handling**: Check return values and handle errors appropriately
5. **Performance**: For large datasets, consider chunked processing

## Troubleshooting

### Common Issues

1. **Missing Dependencies**: Install required packages (`openxlsx`, `jsonlite`)
2. **Permission Errors**: Check file path permissions and directory access
3. **Memory Issues**: For large files, ensure sufficient memory is available
4. **Privacy Errors**: Verify privacy level settings and data structure

### Error Messages

- `"transcript_data cannot be NULL"`: Provide valid transcript data
- `"transcript_data must be a tibble or data frame"`: Ensure data is in correct format
- File system errors: Check file paths and permissions

## Future Enhancements

Planned improvements for export functions:
- **Chart Support**: Enhanced Excel chart functionality
- **Batch Export**: Export multiple sessions simultaneously
- **Format Validation**: Validate exported files for integrity
- **Progress Indicators**: Show progress for large exports
- **Compression**: Support for compressed file formats

## Examples with Real Data

### Complete Workflow Example
```r
# Load and process ideal course transcripts
transcript_data <- process_ideal_course_batch()

# Export in multiple formats
export_ideal_transcripts_csv(transcript_data, "transcript_data.csv")
export_ideal_transcripts_json(transcript_data, "transcript_data.json")
export_ideal_transcripts_excel(transcript_data, "transcript_data.xlsx")

# Generate summary report
export_ideal_transcripts_summary(transcript_data, "summary_report.xlsx", format = "excel")
```

### Privacy-Aware Export
```r
# Set privacy level for sensitive data
options(engager.privacy_level = "full")

# Export with full privacy protection
export_ideal_transcripts_csv(transcript_data, "private_transcript.csv")
```

### Custom Export Configuration
```r
# Export with custom settings
export_ideal_transcripts_excel(
  transcript_data,
  file_path = "detailed_report.xlsx",
  privacy_level = "mask",
  include_summary_sheet = TRUE,
  include_metadata_sheet = TRUE
)
```

This documentation provides comprehensive guidance for using the ideal course transcript export functions while maintaining privacy compliance and following best practices.
