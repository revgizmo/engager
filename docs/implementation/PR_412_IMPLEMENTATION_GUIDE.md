# PR #412 Implementation Guide: Streamline Pre-PR and Context Scripts

## Overview
This guide provides step-by-step instructions to complete PR #412, which streamlines the pre-PR validation and context generation workflow by simplifying scripts and improving efficiency.

## Prerequisites
- R environment with devtools and testthat packages installed
- Access to the zoomstudentengagement package source code
- Git configured for the repository
- Basic shell scripting knowledge

## Step-by-Step Implementation

### Step 1: Environment Setup
```bash
# Navigate to package directory
cd /path/to/zoomstudentengagement

# Fetch latest changes
git fetch origin

# Checkout the PR branch
git checkout codex/optimize-and-enhance-pre-pr-and-save-context.sh-scripts

# Check current status
git status
```

### Step 2: Resolve Merge Conflicts (if needed)
The PR is BEHIND main branch. If there are conflicts:

```bash
# Check what conflicts exist
git status

# Rebase onto latest main
git rebase origin/main

# If conflicts occur, resolve them manually
# The conflicts are likely in:
# - scripts/save-context.sh
# - scripts/README.md
# - PROJECT.md
# - docs/development/pre-pr-save-context-streamlining.md

# After resolving conflicts, add the resolved files
git add scripts/save-context.sh
git add scripts/pre-pr.sh
git add scripts/README.md
git add PROJECT.md
git add docs/development/pre-pr-save-context-streamlining.md

# Continue rebase
git rebase --continue

# Push with force (since rebase rewrites history)
git push --force-with-lease origin codex/optimize-and-enhance-pre-pr-and-save-context.sh-scripts
```

### Step 3: Verify Script Changes
The PR significantly simplifies the save-context.sh script. Verify the changes:

```bash
# Check the simplified save-context.sh
cat scripts/save-context.sh

# Check the new pre-pr.sh helper
cat scripts/pre-pr.sh

# Verify script permissions
ls -la scripts/save-context.sh scripts/pre-pr.sh
```

Key changes to verify:
1. **save-context.sh reduced**: From 540+ lines to 27 lines
2. **pre-pr.sh created**: New helper script for one-step validation
3. **Removed dependencies**: No more gh, jq, or complex validation logic
4. **Focused functionality**: Core context generation only
5. **Proper permissions**: Scripts are executable

### Step 4: Test Context Generation
Test the simplified context generation workflow:

```bash
# Test 1: Generate context files only
./scripts/save-context.sh

# Verify context files were created
ls -la .cursor/
cat .cursor/context.md | head -10
cat .cursor/r-context.md | head -10
cat .cursor/full-context.md | head -10

# Test 2: Check timestamped backup
ls -la .cursor/context_*.md
```

Expected output:
- `.cursor/context.md` - Shell context
- `.cursor/r-context.md` - R-specific context
- `.cursor/full-context.md` - Combined context
- `.cursor/context_YYYYMMDD_HHMMSS.md` - Timestamped backup

### Step 5: Test Pre-PR Helper
Test the new pre-pr.sh helper script:

```bash
# Test 1: Run pre-pr validation and context refresh
./scripts/pre-pr.sh

# Test 2: Run with arguments (if any)
./scripts/pre-pr.sh --help

# Test 3: Verify both validation and context generation worked
ls -la .cursor/
```

The pre-pr.sh script should:
1. Run the pre-pr-validation.R script
2. Automatically refresh context files
3. Handle arguments properly
4. Provide clear error messages

### Step 6: Verify Documentation Updates
Check the updated documentation:

```bash
# Check scripts README
cat scripts/README.md

# Check workflow documentation
cat docs/development/pre-pr-save-context-streamlining.md

# Check PROJECT.md updates
cat PROJECT.md | head -10
```

Verify documentation includes:
- Updated usage instructions for pre-pr.sh
- Clear workflow documentation
- Clarification about manual PROJECT.md updates
- Benefits of streamlined approach

### Step 7: Test Backward Compatibility
Ensure the streamlined workflow doesn't break existing functionality:

```bash
# Test 1: Verify context generation still works
./scripts/save-context.sh

# Test 2: Verify pre-pr validation still works
Rscript scripts/pre-pr-validation.R

# Test 3: Verify individual context scripts work
./scripts/context-for-new-chat.sh | head -10
Rscript scripts/context-for-new-chat.R | head -10

# Test 4: Verify get-context.sh still works
./scripts/get-context.sh | head -10
```

### Step 8: Test Error Handling
Test error scenarios to ensure robust behavior:

```bash
# Test 1: Missing R environment
# (This would fail in environments without R, which is expected)

# Test 2: Missing context scripts
# (This would fail if scripts are missing, which is expected)

# Test 3: Invalid arguments
./scripts/pre-pr.sh --invalid-arg

# Test 4: Permission issues
chmod -x scripts/save-context.sh
./scripts/save-context.sh
chmod +x scripts/save-context.sh
```

### Step 9: Performance Testing
Verify the streamlined workflow is faster:

```bash
# Test 1: Time the old workflow (if possible)
time (Rscript scripts/pre-pr-validation.R && ./scripts/save-context.sh)

# Test 2: Time the new workflow
time ./scripts/pre-pr.sh

# Test 3: Time context generation only
time ./scripts/save-context.sh
```

### Step 10: Commit and Push Changes
```bash
# Add any additional changes
git add .

# Commit with descriptive message
git commit -m "streamline: optimize pre-pr and context scripts

- Simplify save-context.sh from 540+ lines to 27 lines
- Add pre-pr.sh helper for one-step validation and context refresh
- Remove external dependencies (gh, jq) and complex validation logic
- Update documentation with streamlined workflow
- Clarify PROJECT.md manual update process
- Improve development workflow efficiency"

# Push to remote
git push origin codex/optimize-and-enhance-pre-pr-and-save-context.sh-scripts
```

### Step 11: Verify PR Status
```bash
# Check PR status
gh pr view 412

# Verify all checks are passing
gh pr checks 412

# Check if merge conflicts are resolved
gh pr view 412 --json mergeable,mergeStateStatus
```

## Validation Checklist

### Script Simplification
- [ ] save-context.sh reduced to <50 lines
- [ ] Removed complex validation and backup logic
- [ ] Eliminated external dependencies (gh, jq)
- [ ] Focused on core context generation only
- [ ] Maintained all essential functionality

### Workflow Enhancement
- [ ] pre-pr.sh helper script created and executable
- [ ] One-step validation and context refresh works
- [ ] Arguments are passed through correctly
- [ ] Error handling is appropriate
- [ ] Performance is improved

### Documentation Updates
- [ ] scripts/README.md updated with new usage
- [ ] Workflow documentation created
- [ ] PROJECT.md manual update process clarified
- [ ] Usage examples are clear and accurate
- [ ] Benefits are well documented

### Testing
- [ ] Context generation works correctly
- [ ] Pre-PR validation still functions
- [ ] Backward compatibility maintained
- [ ] Error handling is robust
- [ ] Performance is improved

### Integration
- [ ] No breaking changes to existing workflow
- [ ] All scripts are executable
- [ ] Documentation is accurate
- [ ] Merge conflicts resolved
- [ ] PR is ready for review

## Troubleshooting

### Common Issues

**Issue**: Scripts are not executable
**Solution**: 
```bash
chmod +x scripts/save-context.sh scripts/pre-pr.sh
```

**Issue**: Context files not generated
**Solution**: 
1. Check if required scripts exist
2. Verify R environment is available
3. Check script permissions
4. Review error messages

**Issue**: Pre-PR validation fails
**Solution**: 
1. Check R environment and dependencies
2. Verify pre-pr-validation.R script exists
3. Review validation error messages
4. Ensure package is in valid state

**Issue**: Merge conflicts in scripts
**Solution**: 
1. Check what changed in main branch
2. Manually resolve conflicts
3. Ensure script logic is preserved
4. Test after resolution

### Error Recovery
If any step fails:
1. Review error messages carefully
2. Check script permissions and dependencies
3. Verify file paths and structure
4. Re-run failed steps after fixes

## Success Criteria
- [ ] save-context.sh simplified to <50 lines
- [ ] pre-pr.sh helper works correctly
- [ ] Context generation functions properly
- [ ] Documentation is clear and accurate
- [ ] No breaking changes to existing workflow
- [ ] Performance is improved
- [ ] PR is ready for review and merge

## Next Steps
After completing this implementation:
1. Review the PR changes
2. Ensure all checks pass
3. Request review if needed
4. Merge the PR when approved

## Notes
- This is a workflow improvement with no functional impact on package functionality
- The changes improve development efficiency and reduce complexity
- No breaking changes or API modifications
- Low risk, high value improvement for development workflow
- External dependencies (gh, jq) are no longer required for basic context generation
