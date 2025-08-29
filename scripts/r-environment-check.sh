#!/bin/bash
set -euo pipefail

# R Development Environment Detection Script
# This script helps AI agents understand their R development environment capabilities

echo "🤖 R Development Environment Assessment"
echo "======================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to check command availability
check_command() {
    local cmd=$1
    local name=${2:-$1}
    if command -v "$cmd" >/dev/null 2>&1; then
        print_status "OK" "$name: Available"
        return 0
    else
        print_status "ERROR" "$name: Not available"
        return 1
    fi
}

# Function to check R package availability
check_r_package() {
    local pkg=$1
    local name=${2:-$1}
    if Rscript -e "library($pkg, quietly = TRUE)" >/dev/null 2>&1; then
        print_status "OK" "$name: Available"
        return 0
    else
        print_status "ERROR" "$name: Not available"
        return 1
    fi
}

echo
echo "🔧 R Development Tools"
echo "-------------------"

# Check core R tools
R_AVAILABLE=false
RSCRIPT_AVAILABLE=false
RSTUDIO_AVAILABLE=false

check_command "R" "R Interpreter" && R_AVAILABLE=true
check_command "Rscript" "Rscript" && RSCRIPT_AVAILABLE=true
check_command "RStudio" "RStudio" && RSTUDIO_AVAILABLE=true

echo
echo "📦 R Package Development Tools"
echo "----------------------------"

# Check R package development tools
DEVTOOLS_AVAILABLE=false
TESTTHAT_AVAILABLE=false
COVR_AVAILABLE=false
STYLER_AVAILABLE=false
LINTR_AVAILABLE=false

check_r_package "devtools" "devtools" && DEVTOOLS_AVAILABLE=true
check_r_package "testthat" "testthat" && TESTTHAT_AVAILABLE=true
check_r_package "covr" "covr" && COVR_AVAILABLE=true
check_r_package "styler" "styler" && STYLER_AVAILABLE=true
check_r_package "lintr" "lintr" && LINTR_AVAILABLE=true

echo
echo "🔍 Project Structure"
echo "-------------------"

# Check project files
DESCRIPTION_EXISTS=false
NAMESPACE_EXISTS=false
R_DIR_EXISTS=false
TESTS_DIR_EXISTS=false

if [ -f "DESCRIPTION" ]; then
    print_status "OK" "DESCRIPTION: Present"
    DESCRIPTION_EXISTS=true
else
    print_status "ERROR" "DESCRIPTION: Missing"
fi

if [ -f "NAMESPACE" ]; then
    print_status "OK" "NAMESPACE: Present"
    NAMESPACE_EXISTS=true
else
    print_status "ERROR" "NAMESPACE: Missing"
fi

if [ -d "R" ]; then
    print_status "OK" "R/ Directory: Present"
    R_DIR_EXISTS=true
else
    print_status "ERROR" "R/ Directory: Missing"
fi

if [ -d "tests" ]; then
    print_status "OK" "tests/ Directory: Present"
    TESTS_DIR_EXISTS=true
else
    print_status "ERROR" "tests/ Directory: Missing"
fi

echo
echo "🔄 Development Workflow Tools"
echo "---------------------------"

# Check development workflow tools
GIT_AVAILABLE=false
GH_AVAILABLE=false

check_command "git" "Git" && GIT_AVAILABLE=true
check_command "gh" "GitHub CLI" && GH_AVAILABLE=true

echo
echo "🔍 Environment Capabilities"
echo "-------------------------"

# Determine environment type
ENVIRONMENT_TYPE="UNKNOWN"
BUILD_CAPABLE=false
TEST_CAPABLE=false
DEV_CAPABLE=false

if [ "$RSCRIPT_AVAILABLE" = true ] && [ "$DEVTOOLS_AVAILABLE" = true ]; then
    BUILD_CAPABLE=true
fi

if [ "$BUILD_CAPABLE" = true ] && [ "$TESTTHAT_AVAILABLE" = true ] && [ "$COVR_AVAILABLE" = true ]; then
    TEST_CAPABLE=true
fi

if [ "$BUILD_CAPABLE" = true ] && [ "$STYLER_AVAILABLE" = true ] && [ "$LINTR_AVAILABLE" = true ]; then
    DEV_CAPABLE=true
fi

# Classify environment
if [ "$BUILD_CAPABLE" = true ] && [ "$TEST_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
    ENVIRONMENT_TYPE="FULL_DEVELOPMENT"
    print_status "OK" "Environment: Full Development (can build, test, and develop)"
elif [ "$BUILD_CAPABLE" = true ] && [ "$TEST_CAPABLE" = true ]; then
    ENVIRONMENT_TYPE="TESTING_DEVELOPMENT"
    print_status "WARN" "Environment: Testing Development (can build and test, limited dev tools)"
elif [ "$BUILD_CAPABLE" = true ]; then
    ENVIRONMENT_TYPE="BUILD_ONLY"
    print_status "WARN" "Environment: Build Only (can build, limited testing)"
else
    ENVIRONMENT_TYPE="BACKGROUND"
    print_status "ERROR" "Environment: Background (code analysis only)"
fi

echo
echo "📊 Capability Summary"
echo "-------------------"

print_status "INFO" "R Development: $([ "$BUILD_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "R Testing: $([ "$TEST_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "R Dev Tools: $([ "$DEV_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "Git Workflow: $([ "$GIT_AVAILABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "GitHub CLI: $([ "$GH_AVAILABLE" = true ] && echo "Available" || echo "Not Available")"

echo
echo "🎯 Work Recommendations"
echo "---------------------"

case $ENVIRONMENT_TYPE in
    "FULL_DEVELOPMENT")
        print_status "OK" "✅ Can perform full R package development"
        print_status "INFO" "  - Build and test R packages"
        print_status "INFO" "  - Run comprehensive tests"
        print_status "INFO" "  - Check code quality and style"
        print_status "INFO" "  - Validate CRAN compliance"
        ;;
    "TESTING_DEVELOPMENT")
        print_status "WARN" "⚠️  Can build and test but limited development tools"
        print_status "INFO" "  - Build and test R packages"
        print_status "INFO" "  - Run tests and check coverage"
        print_status "INFO" "  - Limited code quality tools"
        print_status "INFO" "  - Request validation for code quality"
        ;;
    "BUILD_ONLY")
        print_status "WARN" "⚠️  Can build but limited testing capability"
        print_status "INFO" "  - Build R packages"
        print_status "INFO" "  - Cannot run comprehensive tests"
        print_status "INFO" "  - Focus on code analysis"
        print_status "INFO" "  - Request testing validation"
        ;;
    "BACKGROUND")
        print_status "ERROR" "❌ Limited to code analysis only"
        print_status "INFO" "  - Cannot build or test R packages"
        print_status "INFO" "  - Focus on static analysis"
        print_status "INFO" "  - Create patches with validation requirements"
        print_status "INFO" "  - Document all assumptions"
        ;;
esac

echo
echo "🚨 Important Notes"
echo "----------------"

if [ "$ENVIRONMENT_TYPE" = "BACKGROUND" ]; then
    print_status "ERROR" "❌ DO NOT assume R environment is broken"
    print_status "ERROR" "❌ DO NOT assume tools are missing"
    print_status "ERROR" "❌ DO NOT create false positives"
    print_status "INFO" "ℹ️  Focus on code quality and patterns"
    print_status "INFO" "ℹ️  Document all assumptions"
    print_status "INFO" "ℹ️  Request validation for all changes"
fi

if [ "$BUILD_CAPABLE" = false ]; then
    print_status "WARN" "⚠️  Cannot validate R package functionality"
    print_status "INFO" "ℹ️  Assume R environment works unless code analysis shows issues"
    print_status "INFO" "ℹ️  Request build validation from user"
fi

if [ "$TEST_CAPABLE" = false ]; then
    print_status "WARN" "⚠️  Cannot test R package functionality"
    print_status "INFO" "ℹ️  Focus on code implementation, not testing"
    print_status "INFO" "ℹ️  Request R testing from user"
fi

echo
echo "📝 Next Steps"
echo "------------"

case $ENVIRONMENT_TYPE in
    "FULL_DEVELOPMENT")
        print_status "OK" "✅ Proceed with full R development workflow"
        print_status "INFO" "  - Test all changes before proposing"
        print_status "INFO" "  - Validate patches before creating"
        print_status "INFO" "  - Run R CMD check and tests"
        ;;
    "TESTING_DEVELOPMENT"|"BUILD_ONLY")
        print_status "WARN" "⚠️  Proceed with caution"
        print_status "INFO" "  - Test what you can"
        print_status "INFO" "  - Document limitations"
        print_status "INFO" "  - Request validation for untested areas"
        ;;
    "BACKGROUND")
        print_status "ERROR" "❌ Proceed with extreme caution"
        print_status "INFO" "  - Focus on code analysis only"
        print_status "INFO" "  - Document all assumptions"
        print_status "INFO" "  - Create validation requirements for all changes"
        print_status "INFO" "  - Request full validation before applying changes"
        ;;
esac

echo
echo "======================================"

# Export environment variables for other scripts
export AI_ENVIRONMENT_TYPE="$ENVIRONMENT_TYPE"
export AI_BUILD_CAPABLE="$BUILD_CAPABLE"
export AI_TEST_CAPABLE="$TEST_CAPABLE"
export AI_DEV_CAPABLE="$DEV_CAPABLE"

# Return appropriate exit code
case $ENVIRONMENT_TYPE in
    "FULL_DEVELOPMENT")
        exit 0
        ;;
    "TESTING_DEVELOPMENT"|"BUILD_ONLY")
        exit 1
        ;;
    "BACKGROUND")
        exit 2
        ;;
    *)
        exit 3
        ;;
esac
