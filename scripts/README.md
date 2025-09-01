# Context Capture System Documentation

## Overview

The context capture system provides automated project status tracking and documentation updates for the zoomstudentengagement R package. It generates context files for AI agents and automatically updates PROJECT.md with current metrics.

## Scripts

### Core Scripts

#### `save-context.sh`
Main context generation script that creates shell, R, and combined context files.

**Usage:**
```bash
# Generate context files only
./scripts/save-context.sh

# Check if PROJECT.md needs updating
./scripts/save-context.sh --check-project-md

# Update PROJECT.md with current metrics
./scripts/save-context.sh --fix-project-md

# Dry run - show what would be updated
./scripts/save-context.sh --fix-project-md --dry-run

# Show help
./scripts/save-context.sh --help
```

**Output Files:**
- `.cursor/context.md` - Shell context
- `.cursor/r-context.md` - R-specific context
- `.cursor/full-context.md` - Combined context
- `.cursor/metrics.json` - Current project metrics
- `.cursor/context_YYYYMMDD_HHMMSS.md` - Timestamped backup

#### `check-project-md.sh`
Validates if PROJECT.md needs updating by comparing current metrics with stored values.

**Usage:**
```bash
./scripts/check-project-md.sh
```

**Exit Codes:**
- `0` - PROJECT.md is up to date
- `1` - PROJECT.md needs updating

#### `update-project-md.sh`
Updates PROJECT.md with current metrics from the JSON file.

**Usage:**
```bash
# Update PROJECT.md
./scripts/update-project-md.sh

# Dry run - show what would be updated
./scripts/update-project-md.sh --dry-run
```

#### `validate-context-update.sh`
Validates that all context updates were successful.

**Usage:**
```bash
./scripts/validate-context-update.sh
```

**Checks:**
- Metrics JSON exists and is valid
- PROJECT.md is up to date
- All context files exist

### Integration Scripts

#### `pre-pr.sh`
Complete pre-PR workflow that runs validation, refreshes context, and updates PROJECT.md.

**Usage:**
```bash
./scripts/pre-pr.sh [args passed to pre-pr-validation.R]
```

**Workflow:**
1. Runs pre-PR validation
2. Refreshes context files
3. Updates PROJECT.md with current metrics

#### `r-environment-check.sh`
Assesses R development environment capabilities for AI agents.

**Usage:**
```bash
./scripts/r-environment-check.sh
```

**Environment Types:**
- `FULL_DEVELOPMENT` - Can build, test, and develop
- `TESTING_DEVELOPMENT` - Can build and test, limited dev tools
- `BUILD_ONLY` - Can build, limited testing
- `BACKGROUND` - Code analysis only

## Metrics Tracking

### Metrics JSON Structure

The system generates `.cursor/metrics.json` with the following structure:

```json
{
  "coverage": 90.48,
  "tests_passed": 1875,
  "failures": 0,
  "skipped": 15,
  "rcmd_notes": 2,
  "open_issues": 30,
  "exported_functions": 60,
  "last_updated": "2025-08-28",
  "package_status": "EXCELLENT - Very Close to CRAN Ready"
}
```

### PROJECT.md Updates

The system updates specific lines in PROJECT.md:

- **Date**: `Updated: YYYY-MM-DD`
- **Test Suite**: `- **Test Suite**: **XXXX tests passing, 0 failures**`
- **R CMD Check**: `- **R CMD Check**: **0 errors, 0 warnings, X notes**`
- **Test Coverage**: `- **Test Coverage**: XX.XX% (target achieved)`

## Workflow Integration

### Pre-PR Workflow

The complete pre-PR workflow automatically:

1. **Validates Code**: Runs comprehensive validation checks
2. **Refreshes Context**: Generates current context files
3. **Updates Documentation**: Updates PROJECT.md with current metrics
4. **Validates Updates**: Ensures all updates were successful

### AI Agent Integration

AI agents can use the context system by:

1. **Linking Context Files**: Use `@full-context.md` in Cursor chats
2. **Checking Status**: Run `./scripts/check-project-md.sh`
3. **Updating Documentation**: Run `./scripts/save-context.sh --fix-project-md`
4. **Validating Updates**: Run `./scripts/validate-context-update.sh`

## Error Handling

### Common Issues

1. **Metrics JSON Generation Fails**
   - Check R package dependencies (`devtools`, `covr`, `jsonlite`)
   - Verify file permissions for `.cursor/` directory
   - Check for variable scope issues in R script

2. **PROJECT.md Update Fails**
   - Verify file permissions for PROJECT.md
   - Check that sed commands work on your system
   - Ensure backup creation works

3. **GitHub CLI Issues**
   - Verify `gh` CLI is installed and authenticated
   - Check GitHub API rate limits
   - Ensure repository access permissions

### Debugging Commands

```bash
# Check current metrics
cat .cursor/metrics.json | jq .

# Check PROJECT.md status
./scripts/check-project-md.sh

# Test individual components
Rscript scripts/context-for-new-chat.R
./scripts/update-project-md.sh --dry-run

# Validate complete workflow
./scripts/validate-context-update.sh
```

## Dependencies

### Required Tools
- `R` and `Rscript` - R programming environment
- `jq` - JSON processing
- `sed` - Text processing
- `git` - Version control
- `gh` - GitHub CLI (optional, for issue counting)

### Required R Packages
- `devtools` - Package development
- `covr` - Test coverage
- `jsonlite` - JSON processing
- `testthat` - Testing framework

## Best Practices

### For Developers
1. **Always run pre-PR workflow** before creating pull requests
2. **Check context accuracy** when making significant changes
3. **Validate updates** after running context generation
4. **Use dry-run** to preview changes before applying them

### For AI Agents
1. **Check environment capabilities** before starting work
2. **Link context files** in Cursor chats for current status
3. **Update PROJECT.md** when project status changes
4. **Validate all changes** before proposing them

### For Maintainers
1. **Monitor context accuracy** regularly
2. **Review metrics JSON** for data quality
3. **Test workflow integration** after changes
4. **Document new metrics** when adding them

## Troubleshooting

### Validation Failures

If validation fails, check:

1. **File Permissions**: Ensure write access to `.cursor/` and `PROJECT.md`
2. **Dependencies**: Verify all required tools and packages are installed
3. **JSON Format**: Check that metrics.json is valid JSON
4. **Sed Patterns**: Verify sed commands match PROJECT.md format

### Context Generation Issues

If context generation fails:

1. **R Environment**: Check R package availability
2. **Variable Scope**: Verify all variables are properly defined
3. **Error Handling**: Check tryCatch blocks in R script
4. **Fallback Values**: Ensure default values are reasonable

### Integration Problems

If workflow integration fails:

1. **Script Permissions**: Ensure all scripts are executable
2. **Path Issues**: Verify script paths are correct
3. **Exit Codes**: Check that scripts return appropriate exit codes
4. **Error Propagation**: Ensure errors are properly handled

## Future Enhancements

### Planned Features
- **Real-time Metrics**: Live metrics from GitHub API
- **Performance Tracking**: Build and test performance metrics
- **Dependency Monitoring**: Package dependency status
- **Automated Alerts**: Notifications for metric changes

### Potential Improvements
- **Web Interface**: Web-based metrics dashboard
- **Historical Tracking**: Metric history and trends
- **Custom Metrics**: User-defined metric tracking
- **Integration APIs**: REST API for external tools

## Support

For issues with the context capture system:

1. **Check Documentation**: Review this README and implementation guide
2. **Run Diagnostics**: Use validation and debugging commands
3. **Review Logs**: Check script output for error messages
4. **Create Issues**: Report problems with detailed information

---

**Last Updated**: 2025-08-28  
**Version**: 1.0.0  
**Status**: Production Ready 
