# Updated Name Matching Implementation Plan

## Current State Analysis

### What We Have ✅
1. **Core infrastructure exists**:
   - `detect_unmatched_names()` - new API with `transcripts_df`, `roster_df`, `options`
   - `match_names_workflow()` - new API with same signature
   - `safe_name_matching_workflow()` - legacy file-based API
   - Internal helpers: `normalize_name()`, `hash_canonical_name()`, `build_roster_hash_index()`, etc.

2. **Schema enforcement partially implemented**:
   - `validate_roster_for_matching()` - validates required columns
   - `compute_roster_hashes()` - computes derived columns (canonical_name, name_hash, alias_hashes, all_name_hashes)
   - Spec attributes attached with `engager_spec`

3. **Privacy-first design partially implemented**:
   - Hash-based matching with HMAC-SHA-256 support
   - S3 class `engager_match` with redacted print/summary
   - Typed errors with `engager_schema_error`, etc.

### What's Broken ❌
1. **Schema enforcement not integrated**: `load_roster()` doesn't call the validation/hash functions
2. **API mismatch**: Tests call old function signatures
3. **Missing speaker column**: Transcript data lacks required `speaker` column for `detect_unmatched_names()`
4. **Legacy function conflicts**: `safe_name_matching_workflow()` calls `detect_unmatched_names()` with wrong parameters

### Key Findings from CI Failures
- **12 test failures** all related to missing `speaker` column in transcript data
- Tests expect transcript data with `user_name`/`message`/`timestamp` but functions need `speaker`
- Function signature mismatches between old and new APIs
- Schema enforcement not happening in `load_roster()`

## Updated Implementation Plan

### Phase 1: Fix Core Data Flow (Priority 1)
**Goal**: Get the basic data flow working with proper schema enforcement

#### 1.1 Integrate Schema Enforcement into `load_roster()`
- Modify `load_roster()` to call `validate_roster_for_matching()` and `compute_roster_hashes()`
- Ensure it returns roster with derived columns and spec attributes
- Maintain backward compatibility for existing callers

#### 1.2 Fix Transcript Data Flow
- Ensure transcript data has `speaker` column for `detect_unmatched_names()`
- Either modify transcript loading to add `speaker` column or update `prepare_transcript_names()` to handle different column names
- Update test data to have proper structure

#### 1.3 Resolve API Conflicts
- Fix `safe_name_matching_workflow()` to call `detect_unmatched_names()` with correct parameters
- Update all test calls to use correct function signatures
- Ensure both old and new APIs work

### Phase 2: Complete Privacy-First Implementation (Priority 2)
**Goal**: Implement full privacy-first design as specified in original task

#### 2.1 Implement Missing Components
- `write_unresolved()` function for opt-in hashed-only exports
- Complete S3 methods for `engager_match` class
- Proper error handling with typed errors

#### 2.2 Add Missing Tests
- Schema enforcement tests
- Privacy defaults tests (no raw names by default)
- Collision handling tests
- Determinism tests

### Phase 3: Documentation and Vignettes (Priority 3)
**Goal**: Complete documentation as specified in original task

#### 3.1 Update Vignettes
- `01-getting-started.Rmd` with new API
- `02-essential-functions.Rmd` with name matching functions
- Security & Privacy page on pkgdown

#### 3.2 Complete Documentation
- All functions have proper roxygen2 docs
- Examples use synthetic data
- No raw names in examples

## Detailed Implementation Checklist

### ✅ Already Done
- [x] Core normalization and hashing functions
- [x] Exact matching logic
- [x] S3 class structure
- [x] Internal helper functions
- [x] Basic test structure

### 🔄 In Progress
- [ ] Integrate schema enforcement into `load_roster()`
- [ ] Fix transcript data flow (speaker column)
- [ ] Resolve API conflicts
- [ ] Update test calls

### ⏳ Pending
- [ ] Complete privacy-first implementation
- [ ] Add missing tests
- [ ] Update documentation
- [ ] Create vignettes
- [ ] CI/CD fixes

## Key Decisions Made

1. **Keep both APIs**: Maintain `safe_name_matching_workflow()` for backward compatibility while promoting `match_names_workflow()` as the new API
2. **Schema enforcement in `load_roster()`**: This aligns with the original task document
3. **Fix transcript data flow**: Ensure transcript data has required `speaker` column
4. **Maintain privacy-first design**: No raw names by default, hashed-only exports

## Next Steps

1. **Immediate**: Fix the 12 test failures by resolving schema enforcement and speaker column issues
2. **Short-term**: Complete the privacy-first implementation
3. **Long-term**: Add comprehensive documentation and vignettes

## Risk Assessment

- **Low Risk**: Core functionality exists, just needs integration
- **Medium Risk**: API compatibility between old and new functions
- **High Risk**: Breaking changes to existing user workflows

## Success Criteria

- [ ] All CI checks pass (0 errors, 0 warnings)
- [ ] Schema enforcement working in `load_roster()`
- [ ] Both old and new APIs functional
- [ ] Privacy-first design implemented
- [ ] Comprehensive test coverage
- [ ] Documentation complete
