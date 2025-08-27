#!/bin/bash
set -euo pipefail

# AI Agent Environment Detection Script
# This script helps AI agents understand their environment capabilities and limitations

echo "🤖 AI Agent Environment Assessment"
echo "=================================="

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

# Function to check file existence
check_file() {
    local file=$1
    local name=${2:-$file}
    if [ -f "$file" ]; then
        print_status "OK" "$name: Present"
        return 0
    else
        print_status "ERROR" "$name: Missing"
        return 1
    fi
}

# Function to check directory existence
check_directory() {
    local dir=$1
    local name=${2:-$dir}
    if [ -d "$dir" ]; then
        print_status "OK" "$name: Present"
        return 0
    else
        print_status "ERROR" "$name: Missing"
        return 1
    fi
}

echo
echo "🔧 Build System Tools"
echo "-------------------"

# Check core build tools
XCODEBUILD_AVAILABLE=false
XCODEGEN_AVAILABLE=false
SWIFT_AVAILABLE=false

check_command "xcodebuild" "Xcode Build System" && XCODEBUILD_AVAILABLE=true
check_command "xcodegen" "XcodeGen" && XCODEGEN_AVAILABLE=true
check_command "swift" "Swift Compiler" && SWIFT_AVAILABLE=true

echo
echo "📱 iOS Development Tools"
echo "----------------------"

# Check iOS-specific tools
IOS_TOOLS_AVAILABLE=false
SIMCTL_AVAILABLE=false

check_command "xcrun" "Xcode Command Line Tools" && IOS_TOOLS_AVAILABLE=true

# Check simctl specifically
if command -v xcrun >/dev/null 2>&1; then
    if xcrun simctl list devices >/dev/null 2>&1; then
        print_status "OK" "iOS Simulator Control: Available"
        SIMCTL_AVAILABLE=true
    else
        print_status "WARN" "iOS Simulator Control: Limited access"
    fi
else
    print_status "ERROR" "iOS Simulator Control: Not available"
fi

echo
echo "📋 Code Quality Tools"
echo "-------------------"

# Check code quality tools
check_command "swiftlint" "SwiftLint"
check_command "swiftformat" "SwiftFormat"
check_command "xcbeautify" "Xcbeautify"

echo
echo "🏗️  Project Structure"
echo "-------------------"

# Check project files
PROJECT_YML_EXISTS=false
XCODEPROJ_EXISTS=false

check_file "project.yml" "XcodeGen Configuration" && PROJECT_YML_EXISTS=true

# Check for Xcode project
if ls *.xcodeproj >/dev/null 2>&1; then
    print_status "OK" "Xcode Project: Present"
    XCODEPROJ_EXISTS=true
else
    print_status "WARN" "Xcode Project: Not found"
fi

# Check key directories
check_directory "ScrabbleWordSolver" "App Source Directory"
check_directory "Tests/ScrabbleWordSolverTests" "Test Directory"

echo
echo "🔍 Environment Capabilities"
echo "-------------------------"

# Determine environment type
ENVIRONMENT_TYPE="UNKNOWN"
BUILD_CAPABLE=false
TEST_CAPABLE=false
IOS_CAPABLE=false

if [ "$XCODEBUILD_AVAILABLE" = true ] && [ "$XCODEGEN_AVAILABLE" = true ] && [ "$SWIFT_AVAILABLE" = true ]; then
    BUILD_CAPABLE=true
fi

if [ "$BUILD_CAPABLE" = true ] && [ "$SIMCTL_AVAILABLE" = true ]; then
    TEST_CAPABLE=true
fi

if [ "$IOS_TOOLS_AVAILABLE" = true ] && [ "$SIMCTL_AVAILABLE" = true ]; then
    IOS_CAPABLE=true
fi

# Classify environment
if [ "$BUILD_CAPABLE" = true ] && [ "$TEST_CAPABLE" = true ] && [ "$IOS_CAPABLE" = true ]; then
    ENVIRONMENT_TYPE="FULL_DEVELOPMENT"
    print_status "OK" "Environment: Full Development (can build, test, and run iOS)"
elif [ "$BUILD_CAPABLE" = true ] && [ "$IOS_CAPABLE" = true ]; then
    ENVIRONMENT_TYPE="LIMITED_DEVELOPMENT"
    print_status "WARN" "Environment: Limited Development (can build, limited testing)"
elif [ "$BUILD_CAPABLE" = true ]; then
    ENVIRONMENT_TYPE="BUILD_ONLY"
    print_status "WARN" "Environment: Build Only (can build, no iOS tools)"
else
    ENVIRONMENT_TYPE="BACKGROUND"
    print_status "ERROR" "Environment: Background (code analysis only)"
fi

echo
echo "📊 Capability Summary"
echo "-------------------"

print_status "INFO" "Build System: $([ "$BUILD_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "iOS Testing: $([ "$TEST_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "iOS Tools: $([ "$IOS_CAPABLE" = true ] && echo "Available" || echo "Not Available")"

echo
echo "🎯 Work Recommendations"
echo "---------------------"

case $ENVIRONMENT_TYPE in
    "FULL_DEVELOPMENT")
        print_status "OK" "✅ Can perform full development work"
        print_status "INFO" "  - Build and test changes"
        print_status "INFO" "  - Run iOS simulators"
        print_status "INFO" "  - Measure performance"
        print_status "INFO" "  - Test accessibility"
        ;;
    "LIMITED_DEVELOPMENT")
        print_status "WARN" "⚠️  Can build but limited testing capability"
        print_status "INFO" "  - Build and validate changes"
        print_status "INFO" "  - Limited iOS testing"
        print_status "INFO" "  - Focus on code quality"
        print_status "INFO" "  - Request validation for iOS-specific features"
        ;;
    "BUILD_ONLY")
        print_status "WARN" "⚠️  Can build but no iOS tools available"
        print_status "INFO" "  - Build and validate changes"
        print_status "INFO" "  - Cannot test iOS-specific features"
        print_status "INFO" "  - Focus on code analysis"
        print_status "INFO" "  - Request iOS testing from user"
        ;;
    "BACKGROUND")
        print_status "ERROR" "❌ Limited to code analysis only"
        print_status "INFO" "  - Cannot build or test"
        print_status "INFO" "  - Focus on static analysis"
        print_status "INFO" "  - Create patches with validation requirements"
        print_status "INFO" "  - Document all assumptions"
        ;;
esac

echo
echo "🚨 Important Notes"
echo "----------------"

if [ "$ENVIRONMENT_TYPE" = "BACKGROUND" ]; then
    print_status "ERROR" "❌ DO NOT assume build system is broken"
    print_status "ERROR" "❌ DO NOT assume tools are missing"
    print_status "ERROR" "❌ DO NOT create false positives"
    print_status "INFO" "ℹ️  Focus on code quality and patterns"
    print_status "INFO" "ℹ️  Document all assumptions"
    print_status "INFO" "ℹ️  Request validation for all changes"
fi

if [ "$BUILD_CAPABLE" = false ]; then
    print_status "WARN" "⚠️  Cannot validate build system functionality"
    print_status "INFO" "ℹ️  Assume build system works unless code analysis shows issues"
    print_status "INFO" "ℹ️  Request build validation from user"
fi

if [ "$TEST_CAPABLE" = false ]; then
    print_status "WARN" "⚠️  Cannot test iOS-specific functionality"
    print_status "INFO" "ℹ️  Focus on code implementation, not testing"
    print_status "INFO" "ℹ️  Request iOS testing from user"
fi

echo
echo "📝 Next Steps"
echo "------------"

case $ENVIRONMENT_TYPE in
    "FULL_DEVELOPMENT")
        print_status "OK" "✅ Proceed with full development workflow"
        print_status "INFO" "  - Test all changes before proposing"
        print_status "INFO" "  - Validate patches before creating"
        print_status "INFO" "  - Run performance and accessibility tests"
        ;;
    "LIMITED_DEVELOPMENT"|"BUILD_ONLY")
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
echo "=================================="

# Export environment variables for other scripts
export AI_ENVIRONMENT_TYPE="$ENVIRONMENT_TYPE"
export AI_BUILD_CAPABLE="$BUILD_CAPABLE"
export AI_TEST_CAPABLE="$TEST_CAPABLE"
export AI_IOS_CAPABLE="$IOS_CAPABLE"

# Return appropriate exit code
case $ENVIRONMENT_TYPE in
    "FULL_DEVELOPMENT")
        exit 0
        ;;
    "LIMITED_DEVELOPMENT"|"BUILD_ONLY")
        exit 1
        ;;
    "BACKGROUND")
        exit 2
        ;;
    *)
        exit 3
        ;;
esac
