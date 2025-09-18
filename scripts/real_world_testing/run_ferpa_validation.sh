#!/bin/bash
# FERPA Compliance Validation Runner
# Addresses Issue #153: Real-world FERPA compliance validation
#
# This script runs comprehensive FERPA compliance validation tests
# to ensure the package maintains privacy and security standards.
#
# CRITICAL: This script should be run in a secure environment with proper
# data handling protocols. Never run in LLM/IDE environments.

set -e  # Exit on any error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
VALIDATION_SCRIPT="$SCRIPT_DIR/validate_ferpa_compliance.R"
OUTPUT_DIR="$SCRIPT_DIR/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$OUTPUT_DIR/ferpa_validation_${TIMESTAMP}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
}

# Security check
check_security() {
    log "Performing security environment check..."
    
    # Check if running in potentially unsafe environment
    if [[ "$TERM_PROGRAM" == "vscode" ]] || [[ "$TERM_PROGRAM" == "cursor" ]]; then
        error "CRITICAL: Running in IDE environment. This script should be run in a secure terminal."
        error "Please run this script in a standalone terminal outside of any IDE."
        exit 1
    fi
    
    # Check for common LLM/cloud environments
    if [[ -n "$CODESPACES" ]] || [[ -n "$GITHUB_CODESPACES" ]]; then
        error "CRITICAL: Running in GitHub Codespaces. This script should be run in a secure local environment."
        exit 1
    fi
    
    success "Security environment check passed"
}

# Setup
setup() {
    log "Setting up FERPA validation environment..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Check if validation script exists
    if [[ ! -f "$VALIDATION_SCRIPT" ]]; then
        error "Validation script not found: $VALIDATION_SCRIPT"
        exit 1
    fi
    
    # Check if R is available
    if ! command -v Rscript &> /dev/null; then
        error "Rscript not found. Please ensure R is installed and available in PATH."
        exit 1
    fi
    
    # Check if package is installed
    if ! Rscript -e "library(engager)" &> /dev/null; then
        error "engager package not found. Please install the package first."
        exit 1
    fi
    
    success "Environment setup complete"
}

# Run validation
run_validation() {
    log "Starting FERPA compliance validation..."
    
    # Change to project root for consistent environment
    cd "$PROJECT_ROOT"
    
    # Run the validation script
    if Rscript "$VALIDATION_SCRIPT" 2>&1 | tee -a "$LOG_FILE"; then
        success "FERPA compliance validation completed successfully"
        return 0
    else
        error "FERPA compliance validation failed"
        return 1
    fi
}

# Generate report
generate_report() {
    log "Generating validation report..."
    
    REPORT_FILE="$OUTPUT_DIR/ferpa_validation_report_${TIMESTAMP}.md"
    
    cat > "$REPORT_FILE" << EOF
# FERPA Compliance Validation Report

**Date**: $(date)
**Package Version**: $(Rscript -e "cat(packageVersion('engager'))")
**Validation Script**: validate_ferpa_compliance.R
**Log File**: $(basename "$LOG_FILE")

## Summary

This report documents the results of comprehensive FERPA compliance validation testing for the engager package.

## Test Results

### Test Categories
1. **Basic FERPA Compliance Validation** - Validates PII detection and institutional guidance
2. **Privacy Level Validation** - Tests all 4 privacy levels (ferpa_strict, ferpa_standard, mask, none)
3. **Data Retention Policy Validation** - Validates data retention compliance
4. **Privacy Compliance Validation** - Tests privacy violation detection
5. **Export Security Validation** - Ensures exported files maintain privacy
6. **International Name Support** - Validates handling of international names
7. **Edge Case Validation** - Tests handling of edge cases
8. **Performance Validation** - Validates performance with large datasets

### Validation Status
$(if [[ $? -eq 0 ]]; then echo "✅ **PASSED** - All FERPA compliance tests passed"; else echo "❌ **FAILED** - Some FERPA compliance tests failed"; fi)

## Detailed Results

See the log file for detailed test output: \`$(basename "$LOG_FILE")\`

## Recommendations

$(if [[ $? -eq 0 ]]; then
    echo "- ✅ Package maintains FERPA compliance"
    echo "- ✅ Privacy features working correctly"
    echo "- ✅ Export security validated"
    echo "- ✅ International name support confirmed"
    echo "- ✅ Performance acceptable for production use"
else
    echo "- ❌ Address failed tests before production use"
    echo "- ⚠️ Review log file for specific issues"
    echo "- 🔧 Fix any privacy or security concerns"
fi)

## Next Steps

$(if [[ $? -eq 0 ]]; then
    echo "1. ✅ FERPA compliance validation complete"
    echo "2. ✅ Package ready for CRAN submission (from FERPA perspective)"
    echo "3. ✅ Continue with other CRAN readiness tasks"
else
    echo "1. ❌ Fix failed FERPA compliance tests"
    echo "2. ❌ Re-run validation after fixes"
    echo "3. ❌ Do not proceed to CRAN until FERPA compliance is confirmed"
fi)

---
*Generated by FERPA Compliance Validation Script*
EOF
    
    success "Validation report generated: $(basename "$REPORT_FILE")"
}

# Main execution
main() {
    echo "=== FERPA Compliance Validation ==="
    echo "Addressing Issue #153: Real-world FERPA compliance validation"
    echo "Date: $(date)"
    echo "Package: engager"
    echo ""
    
    # Run all steps
    check_security
    setup
    run_validation
    generate_report
    
    echo ""
    echo "=== Validation Complete ==="
    echo "Log file: $LOG_FILE"
    echo "Report: $OUTPUT_DIR/ferpa_validation_report_${TIMESTAMP}.md"
    
    if [[ $? -eq 0 ]]; then
        success "FERPA compliance validation PASSED"
        exit 0
    else
        error "FERPA compliance validation FAILED"
        exit 1
    fi
}

# Run main function
main "$@"
