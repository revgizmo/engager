# Issue #416: Context Capture Process Fix - Consolidated Plan

## Issue Overview
**Title**: fix: Context capture process broken - PROJECT.md not auto-updating  
**Priority**: HIGH  
**Status**: OPEN  
**Labels**: priority:high, bug, documentation, area:core

## Problem Summary
The context capture process has become broken and inconsistent. The `pre-pr.sh` script was supposed to automatically refresh `PROJECT.md` with current metrics, but this functionality is not working properly.

## Current Status Analysis

### ✅ **What's Working**
- Basic context file generation (`context.md`, `r-context.md`, `full-context.md`)
- Pre-PR validation script (`pre-pr.sh`) runs successfully
- R package metrics collection (tests, coverage) works
- GitHub issue counting works

### ❌ **What's Broken**
1. **Missing Automated PROJECT.md Updates**: Scripts reference non-existent `--check-project-md` and `--fix-project-md` options
2. **Inconsistent Metrics**: PROJECT.md contains outdated information
3. **Broken Metrics JSON**: Variable scope errors prevent `.cursor/metrics.json` generation
4. **Hardcoded Values**: Context scripts use fallback values instead of actual metrics

### 📊 **Current Metrics Discrepancies**
- **Tests**: Current: 1785 passing vs PROJECT.md claims: 1825
- **Coverage**: Current: 90.48% vs PROJECT.md claims: 90.69%
- **Issues**: Current: 30 open vs PROJECT.md claims: 31

## Implementation Strategy

### **Phase 1: Core Fixes (High Priority - 1-2 days)**
1. **Implement Missing Command-Line Options**
   - Add `--check-project-md` to `save-context.sh`
   - Add `--fix-project-md` to `save-context.sh`
   - Add `--dry-run` option for safe testing

2. **Fix Metrics JSON Generation**
   - Resolve variable scope issues in R context script
   - Ensure proper error handling
   - Add validation for generated metrics

3. **Add Actual Metrics Collection**
   - Run `devtools::test()` for current test results
   - Run `covr::package_coverage()` for current coverage
   - Query GitHub API for current issue count
   - Run `devtools::check()` for R CMD check status

### **Phase 2: Automated Workflow (Medium Priority - 1 day)**
1. **Integrate PROJECT.md Updates**
   - Modify `pre-pr.sh` to automatically update PROJECT.md
   - Add validation that updates were successful
   - Provide clear success/failure feedback

2. **Add Validation Checks**
   - Verify PROJECT.md was updated correctly
   - Compare generated context with actual metrics
   - Fail workflow if discrepancies found

### **Phase 3: Enhanced Context System (Low Priority - 1 day)**
1. **Add Context Validation**
   - Check that context files match actual project state
   - Provide warnings for outdated information
   - Add timestamps to track context freshness

2. **Improve Error Handling**
   - Better error messages for failed operations
   - Fallback mechanisms for partial failures
   - Clear instructions for manual recovery

## Technical Requirements

### **Environment Limitations**
- Standard R development environment
- GitHub CLI access required for issue counting
- File system write access for PROJECT.md updates
- R package development tools (devtools, covr)

### **Dependencies**
- `devtools` for package operations
- `covr` for coverage calculation
- `jsonlite` for metrics JSON generation
- `gh` CLI for GitHub API access

### **File Modifications Required**
1. `scripts/save-context.sh` - Add command-line options
2. `scripts/context-for-new-chat.R` - Fix metrics JSON generation
3. `scripts/pre-pr.sh` - Integrate PROJECT.md updates
4. `PROJECT.md` - Will be automatically updated

## Success Criteria

### **Technical Requirements**
- [ ] `./scripts/pre-pr.sh` automatically updates PROJECT.md
- [ ] Context files contain accurate, current metrics
- [ ] No hardcoded values in context generation
- [ ] Metrics JSON generation works without errors
- [ ] PROJECT.md always reflects current project state

### **User Experience**
- [ ] Single command updates both validation and documentation
- [ ] Clear feedback on what was updated
- [ ] No manual PROJECT.md editing required
- [ ] Context files provide accurate information to AI agents

### **Quality Assurance**
- [ ] Automated validation of context accuracy
- [ ] Clear error messages for failed operations
- [ ] Fallback mechanisms for partial failures
- [ ] Documentation of troubleshooting procedures

## Testing Plan

### **Unit Tests**
- [ ] Test metrics collection functions
- [ ] Test PROJECT.md parsing and updating
- [ ] Test context file generation
- [ ] Test command-line option handling

### **Integration Tests**
- [ ] Test complete `pre-pr.sh` workflow
- [ ] Test context generation with actual package
- [ ] Test PROJECT.md update accuracy
- [ ] Test error handling and recovery

### **Manual Validation**
- [ ] Verify PROJECT.md contains current metrics
- [ ] Verify context files match actual project state
- [ ] Verify AI agents receive accurate information
- [ ] Verify workflow works in different environments

## Risk Assessment

### **Low Risk**
- Adding command-line options to existing scripts
- Fixing variable scope issues in R code
- Updating PROJECT.md with current metrics

### **Medium Risk**
- Integration with existing pre-PR workflow
- Ensuring backward compatibility
- Handling edge cases in metrics collection

### **Mitigation Strategies**
- Implement `--dry-run` option for safe testing
- Add comprehensive error handling
- Create backup mechanisms for PROJECT.md
- Test thoroughly before deployment

## Timeline

### **Week 1: Core Implementation**
- **Day 1-2**: Implement missing command-line options and fix metrics JSON
- **Day 3**: Add actual metrics collection and validation
- **Day 4**: Integrate with pre-PR workflow
- **Day 5**: Testing and validation

### **Week 2: Validation and Documentation**
- **Day 1-2**: Comprehensive testing
- **Day 3**: Documentation updates
- **Day 4**: Final validation and deployment
- **Day 5**: Monitor and address any issues

## Dependencies and Blockers

### **Dependencies**
- None - this is a self-contained fix

### **Blockers**
- None identified

### **Related Issues**
- This issue blocks effective project management
- This issue blocks CRAN preparation (accurate metrics required)
- This issue affects AI agent effectiveness

## Validation Requirements

### **Environment-Specific Testing**
- Test in standard R development environment
- Verify GitHub CLI access works correctly
- Test file system permissions for PROJECT.md updates
- Validate R package tools availability

### **Manual Validation Steps**
1. Run `./scripts/pre-pr.sh` and verify PROJECT.md is updated
2. Check that context files contain accurate metrics
3. Verify no hardcoded values remain in context generation
4. Test error handling with invalid inputs
5. Validate that AI agents receive correct information

### **Success Validation**
- PROJECT.md contains current metrics (tests: 1785, coverage: 90.48%, issues: 30)
- Context files match actual project state
- No errors in metrics JSON generation
- Pre-PR workflow updates documentation automatically
- Clear feedback provided for all operations

## Next Steps

1. **Immediate**: Create implementation guide with step-by-step instructions
2. **Short-term**: Implement core fixes and test thoroughly
3. **Medium-term**: Integrate with existing workflows
4. **Long-term**: Monitor and maintain context accuracy

---

**Last Updated**: 2025-08-28  
**Status**: Ready for Implementation  
**Priority**: HIGH - Blocking CRAN preparation and AI agent effectiveness

