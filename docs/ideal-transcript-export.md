# Ideal Course Transcript Export Functions

## Overview

The `zoomstudentengagement` package provides comprehensive export functions for ideal course transcripts, supporting multiple formats and maintaining privacy compliance.

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
- **Note**: Requires optional `openxlsx` package

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

## Dependencies

### Required Dependencies
- `jsonlite`: For JSON export functionality (included in package)

### Optional Dependencies
- `openxlsx`: For Excel export functionality (optional)

### Installation
```r
# Install optional Excel support (only if needed)
install.packages("openxlsx")
```

## Function Reference

### `export_ideal_transcripts_csv()`

Exports transcript data to CSV format with privacy protection.

**Parameters:**
- `transcript_data`: Data frame containing transcript data
- `file_path`: Output file path (optional, generates default if NULL)
- `privacy_level`: Privacy level for data masking (default: from option)
- `include_metadata`: Whether to include metadata columns (default: TRUE)

**Returns:** Invisibly returns the exported data frame

### `export_ideal_transcripts_json()`

Exports transcript data to JSON format with structured output.

**Parameters:**
- `transcript_data`: Data frame containing transcript data
- `file_path`: Output file path (optional, generates default if NULL)
- `privacy_level`: Privacy level for data masking (default: from option)
- `pretty_print`: Whether to format JSON with indentation (default: TRUE)
- `include_metadata`: Whether to include metadata (default: TRUE)

**Returns:** Invisibly returns the exported data as list

### `export_ideal_transcripts_excel()`

Exports transcript data to Excel format with multiple sheets.

**Parameters:**
- `transcript_data`: Data frame containing transcript data
- `file_path`: Output file path (optional, generates default if NULL)
- `privacy_level`: Privacy level for data masking (default: from option)
- `include_summary_sheet`: Whether to include summary sheet (default: TRUE)
- `include_metadata_sheet`: Whether to include metadata sheet (default: TRUE)

**Returns:** Invisibly returns the workbook object

### `export_ideal_transcripts_summary()`

Creates and exports summary reports in multiple formats.

**Parameters:**
- `transcript_data`: Data frame containing transcript data
- `file_path`: Output file path (optional, generates default if NULL)
- `format`: Output format: "csv", "json", or "excel" (default: "csv")
- `privacy_level`: Privacy level for data masking (default: from option)
- `include_charts`: Whether to include charts (Excel only, default: FALSE)

**Returns:** Invisibly returns the summary data

## Integration with Ideal Course Transcripts

These export functions are designed to work seamlessly with the ideal course transcript system:

```r
# Complete workflow example
library(zoomstudentengagement)

# Process ideal course batch
batch_results <- process_ideal_course_batch(
  output_format = "data.frame",
  privacy_level = "masked"
)

# Export in multiple formats
export_ideal_transcripts_csv(batch_results, "transcript_data.csv")
export_ideal_transcripts_json(batch_results, "transcript_data.json")
export_ideal_transcripts_excel(batch_results, "transcript_data.xlsx")
export_ideal_transcripts_summary(batch_results, "summary.csv", format = "csv")
```

## Best Practices

1. **Privacy First**: Always use appropriate privacy levels for your use case
2. **File Organization**: Use descriptive file paths and organize exports logically
3. **Metadata**: Include metadata for traceability and data provenance
4. **Error Handling**: Check for errors and handle file system issues gracefully
5. **Performance**: For large datasets, consider processing in chunks

## Troubleshooting

### Common Issues

**Excel Export Fails**
- Ensure `openxlsx` package is installed (optional dependency)
- Check file permissions in target directory
- Verify data frame structure is valid
- Consider using CSV or JSON export as alternatives

**JSON Export Issues**
- Check for non-serializable data types
- Verify JSON structure is valid
- Ensure proper encoding for special characters

**CSV Export Problems**
- Check for invalid characters in data
- Verify file path permissions
- Ensure data frame is properly formatted

### Error Messages

- **"openxlsx package is required"**: Install with `install.packages("openxlsx")` or use CSV/JSON export instead
- **"transcript_data cannot be NULL"**: Provide valid data frame
- **"transcript_data must be a tibble or data frame"**: Check data type
- **"File not found"**: Check file path and permissions

## Future Enhancements

Planned improvements for export functions:
- **Chart Generation**: Enhanced Excel chart functionality
- **Batch Processing**: Export multiple sessions simultaneously
- **Format Validation**: Validate exported files for integrity
- **Compression**: Support for compressed file formats
- **Streaming**: Memory-efficient processing for very large files
