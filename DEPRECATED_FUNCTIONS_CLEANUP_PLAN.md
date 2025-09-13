# Deprecated Functions Cleanup Plan

## 🛡️ **Safe Removal Strategy**

### **Backup Created**
- ✅ **Backup Branch**: `backup-before-deprecated-cleanup` 
- ✅ **Remote Backup**: Pushed to origin
- ✅ **Rollback Command**: `git checkout backup-before-deprecated-cleanup`

### **Function Analysis Results**

**Total Deprecated Functions**: 44

**Functions Still Used by Exported Functions** (MUST KEEP):
1. `calculate_content_similarity()` - Used by `detect_duplicate_transcripts()`
2. `log_privacy_operation()` - Used by `ensure_privacy()`

**Functions Safe to Remove** (42 functions):
- All other deprecated functions that are NOT called by exported functions

### **Removal Strategy**

#### **Phase 1: Remove Deprecation Warnings from Used Functions**
1. Remove deprecation warning from `calculate_content_similarity()`
2. Remove deprecation warning from `log_privacy_operation()`
3. Test to ensure functionality still works

#### **Phase 2: Remove Unused Deprecated Functions (Batch 1)**
Remove entire files containing only deprecated functions:
- `R/add_dead_air_rows.R`
- `R/make_blank_cancelled_classes_df.R`
- `R/make_blank_section_names_lookup_csv.R`
- `R/make_clean_names_df.R`
- `R/make_metrics_lookup_df.R`
- `R/make_names_to_clean_df.R`
- `R/make_roster_small.R`
- `R/make_sections_df.R`
- `R/make_semester_df.R`
- `R/write_engagement_metrics.R`

#### **Phase 3: Remove Unused Deprecated Functions (Batch 2)**
Remove entire files containing only deprecated functions:
- `R/create_analysis_config.R`
- `R/create_course_info.R`
- `R/create_session_mapping.R`
- `R/ethical_compliance.R`
- `R/hash_name_consistently.R`
- `R/join_transcripts_list.R`
- `R/load_section_names_lookup.R`
- `R/make_transcripts_session_summary_df.R`
- `R/prompt_name_matching.R`
- `R/safe_name_matching_workflow.R`

#### **Phase 4: Remove Unused Deprecated Functions (Batch 3)**
Remove entire files containing only deprecated functions:
- `R/validate_privacy_compliance.R`
- `R/lookup_merge_utils.R`

#### **Phase 5: Clean Up Mixed Files**
Remove deprecated functions from files that also contain non-deprecated functions:
- `R/ferpa_compliance.R` - Remove 3 deprecated functions, keep `validate_ferpa_compliance()`

### **Testing Strategy**

After each phase:
1. Run `devtools::test()` to ensure no test failures
2. Run `devtools::check()` to ensure no R CMD check issues
3. Test key exported functions manually
4. If any issues, rollback with `git checkout backup-before-deprecated-cleanup`

### **Expected Results**

- **Warnings Reduced**: From 544 to ~50 (90%+ reduction)
- **Functions Removed**: 42 deprecated functions
- **Functions Kept**: 2 functions (with deprecation warnings removed)
- **Functionality**: All exported functions continue to work
- **CRAN Readiness**: Significantly improved

### **Rollback Plan**

If any issues arise:
```bash
git checkout backup-before-deprecated-cleanup
git checkout -b cran-submission-v0.1.0-rollback
```

This ensures we can always return to the working state.
