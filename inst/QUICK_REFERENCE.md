# Quick Reference - zoomstudentengagement

## 🚀 Essential Functions (5)

| Function | Description | Usage |
|----------|-------------|-------|
| `load_zoom_transcript()` | Load transcript files | `load_zoom_transcript("file.vtt")` |
| `process_zoom_transcript()` | Clean and prepare data | `process_zoom_transcript(transcript)` |
| `analyze_transcripts()` | Calculate engagement metrics | `analyze_transcripts(processed)` |
| `plot_users()` | Create visualizations | `plot_users(analysis)` |
| `write_metrics()` | Save results | `write_metrics(analysis, "output/")` |

## 🎯 Quick Workflows

### Basic Analysis (Recommended)
```r
results <- basic_transcript_analysis("transcript.vtt", "output/")
```

### Quick Analysis (Fastest)
```r
results <- quick_analysis("transcript.vtt")
```

### Batch Processing
```r
files <- c("session1.vtt", "session2.vtt")
results <- batch_basic_analysis(files, "output/")
```

### Step-by-Step
```r
transcript <- load_zoom_transcript("file.vtt")
processed <- process_zoom_transcript(transcript)
analysis <- analyze_transcripts(processed)
plots <- plot_users(analysis)
write_metrics(analysis, "output/")
```

## 📊 Common Functions (10)

| Function | Description | Usage |
|----------|-------------|-------|
| `validate_schema()` | Check data structure | `validate_schema(data)` |
| `consolidate_transcript()` | Combine multiple files | `consolidate_transcript(files)` |
| `join_transcripts_list()` | Merge with roster | `join_transcripts_list(transcript, roster)` |
| `load_roster()` | Load student roster | `load_roster("roster.csv")` |
| `load_session_mapping()` | Load session data | `load_session_mapping("sessions.csv")` |
| `safe_name_matching_workflow()` | Match names safely | `safe_name_matching_workflow(data)` |
| `ensure_privacy()` | Apply privacy protection | `ensure_privacy(data)` |
| `set_privacy_defaults()` | Configure privacy | `set_privacy_defaults()` |
| `privacy_audit()` | Check privacy compliance | `privacy_audit(data)` |
| `write_engagement_metrics()` | Export detailed metrics | `write_engagement_metrics(analysis, "output/")` |

## 🔒 Privacy & Ethics

| Function | Description | Usage |
|----------|-------------|-------|
| `ensure_privacy()` | Apply privacy protection | `ensure_privacy(data)` |
| `set_privacy_defaults()` | Configure privacy settings | `set_privacy_defaults()` |
| `privacy_audit()` | Check privacy compliance | `privacy_audit(data)` |
| `validate_ferpa_compliance()` | Check FERPA compliance | `validate_ferpa_compliance(data)` |
| `mask_user_names_by_metric()` | Anonymize names | `mask_user_names_by_metric(data)` |

## ❓ Getting Help

| Function | Description | Usage |
|----------|-------------|-------|
| `show_getting_started()` | Show getting started guide | `show_getting_started()` |
| `show_available_functions()` | See available functions | `show_available_functions()` |
| `show_function_help()` | Get function help | `show_function_help("function_name")` |
| `find_function_for_task()` | Find right function | `find_function_for_task("what you want to do")` |
| `show_troubleshooting()` | Show troubleshooting guide | `show_troubleshooting()` |
| `show_privacy_guidance()` | Show privacy guidance | `show_privacy_guidance()` |

## 🎛️ Progressive Disclosure

| Level | Functions | Description |
|-------|-----------|-------------|
| **Basic** (default) | 5 | Essential functions only |
| **Intermediate** | 15 | Essential + common functions |
| **Advanced** | 35+ | Essential + common + advanced |
| **Expert** | 79 | All functions |

### Change UX Level
```r
set_ux_level("basic")      # 5 functions
set_ux_level("intermediate") # 15 functions  
set_ux_level("advanced")   # 35+ functions
set_ux_level("expert")     # All 79 functions
```

## 📁 Supported File Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| VTT | `.vtt` | Video transcript files |
| TXT | `.txt` | Text transcript files |
| CSV | `.csv` | Comma-separated data |

## 🔧 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| File not found | Check file path, use `list.files()` |
| Function not found | Use `show_available_functions()` or `set_ux_level("intermediate")` |
| Permission denied | Check file permissions, try different output directory |
| Memory issues | Use smaller files, try batch processing |
| Data format errors | Check file format, use `validate_schema()` |

## 📚 Resources

- **Getting Started**: `show_getting_started()`
- **Function Help**: `show_function_help("function_name")`
- **Find Functions**: `find_function_for_task("what you want to do")`
- **Troubleshooting**: `show_troubleshooting()`
- **Privacy Guide**: `show_privacy_guidance()`
- **Package Help**: `help(package = "zoomstudentengagement")`

## 🎯 Best Practices

1. **Start Simple**: Use `basic_transcript_analysis()` for your first analysis
2. **Privacy First**: Privacy protection is enabled by default
3. **Progressive Learning**: Start with basic level, advance as needed
4. **Get Help**: Use the help functions when you need guidance
5. **Validate Data**: Use `validate_schema()` to check your data

---

**Need more help?** Use `show_getting_started()` for the complete guide!
