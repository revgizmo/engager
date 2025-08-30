#!/bin/bash
set -euo pipefail

# AI Agent Environment Detection Script
# This script helps AI agents understand their environment capabilities and limitations
# Supports multiple project types: R packages, iOS projects, and others

echo "🤖 AI Agent Environment Assessment"
echo "=================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
        "PROJECT")
            echo -e "${PURPLE}📦 $message${NC}"
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

# Function to detect project type
detect_project_type() {
    # Check for R package indicators
    if [ -f "DESCRIPTION" ] && [ -f "NAMESPACE" ] && [ -d "R" ]; then
        print_status "PROJECT" "Project Type: R Package" >&2
        echo "R_PACKAGE"
        return 0
    fi
    
    # Check for iOS project indicators
    if [ -f "project.yml" ] || ls *.xcodeproj >/dev/null 2>&1; then
        print_status "PROJECT" "Project Type: iOS Project" >&2
        echo "IOS_PROJECT"
        return 0
    fi
    
    # Check for Python project indicators
    if [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
        print_status "PROJECT" "Project Type: Python Project" >&2
        echo "PYTHON_PROJECT"
        return 0
    fi
    
    # Check for Node.js project indicators
    if [ -f "package.json" ]; then
        print_status "PROJECT" "Project Type: Node.js Project" >&2
        echo "NODEJS_PROJECT"
        return 0
    fi
    
    # Check for Java project indicators
    if [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        print_status "PROJECT" "Project Type: Java Project" >&2
        echo "JAVA_PROJECT"
        return 0
    fi
    
    print_status "WARN" "Project Type: Unknown (generic project)" >&2
    echo "UNKNOWN"
    return 1
}

# Detect project type first
PROJECT_TYPE=$(detect_project_type)

echo
echo "🔧 Build System Tools"
echo "-------------------"

# Initialize capability flags
BUILD_CAPABLE=false
TEST_CAPABLE=false
DEV_CAPABLE=false

case "$PROJECT_TYPE" in
    "R_PACKAGE")
        echo "📊 R Package Development Tools"
        echo "----------------------------"
        
        # Check R and Rscript availability
        R_AVAILABLE=false
        RSCRIPT_AVAILABLE=false
        
        if command -v R >/dev/null 2>&1; then
            print_status "OK" "R Interpreter: Available"
            R_AVAILABLE=true
        else
            print_status "ERROR" "R Interpreter: Not available"
        fi
        
        if command -v Rscript >/dev/null 2>&1; then
            print_status "OK" "Rscript: Available"
            RSCRIPT_AVAILABLE=true
        else
            print_status "ERROR" "Rscript: Not available"
        fi
        
        # Check R package development tools (these are R packages, not shell commands)
        echo
        echo "📦 R Package Development Tools"
        echo "----------------------------"
        
        # Check if we can run R to check for packages
        if [ "$RSCRIPT_AVAILABLE" = true ]; then
            # Check for devtools
            if Rscript -e "if (!require(devtools, quietly = TRUE)) cat('devtools not found\n') else cat('devtools available\n')" 2>/dev/null | grep -q "available"; then
                print_status "OK" "devtools: Available"
            else
                print_status "WARN" "devtools: Not available (install with install.packages('devtools'))"
            fi
            
            # Check for roxygen2
            if Rscript -e "if (!require(roxygen2, quietly = TRUE)) cat('roxygen2 not found\n') else cat('roxygen2 available\n')" 2>/dev/null | grep -q "available"; then
                print_status "OK" "roxygen2: Available"
            else
                print_status "WARN" "roxygen2: Not available (install with install.packages('roxygen2'))"
            fi
            
            # Check for testthat
            if Rscript -e "if (!require(testthat, quietly = TRUE)) cat('testthat not found\n') else cat('testthat available\n')" 2>/dev/null | grep -q "available"; then
                print_status "OK" "testthat: Available"
            else
                print_status "WARN" "testthat: Not available (install with install.packages('testthat'))"
            fi
            
            # Check for styler
            if Rscript -e "if (!require(styler, quietly = TRUE)) cat('styler not found\n') else cat('styler available\n')" 2>/dev/null | grep -q "available"; then
                print_status "OK" "styler: Available"
            else
                print_status "WARN" "styler: Not available (install with install.packages('styler'))"
            fi
            
            # Check for lintr
            if Rscript -e "if (!require(lintr, quietly = TRUE)) cat('lintr not found\n') else cat('lintr available\n')" 2>/dev/null | grep -q "available"; then
                print_status "OK" "lintr: Available"
            else
                print_status "WARN" "lintr: Not available (install with install.packages('lintr'))"
            fi
            
            # Check for covr
            if Rscript -e "if (!require(covr, quietly = TRUE)) cat('covr not found\n') else cat('covr available\n')" 2>/dev/null | grep -q "available"; then
                print_status "OK" "covr: Available"
            else
                print_status "WARN" "covr: Not available (install with install.packages('covr'))"
            fi
        else
            print_status "ERROR" "Cannot check R packages - Rscript not available"
        fi
        
        # Check for RStudio
        if command -v rstudio >/dev/null 2>&1; then
            print_status "OK" "RStudio: Available"
        else
            print_status "INFO" "RStudio: Not available (optional)"
        fi
        
        # Determine capabilities
        if [ "$R_AVAILABLE" = true ] && [ "$RSCRIPT_AVAILABLE" = true ]; then
            BUILD_CAPABLE=true
            TEST_CAPABLE=true
            DEV_CAPABLE=true
        fi
        
        echo
        echo "🏗️  R Package Structure"
        echo "---------------------"
        
        # Check standard R package directories and files
        check_file "DESCRIPTION" "DESCRIPTION file"
        check_file "NAMESPACE" "NAMESPACE file"
        check_directory "R" "R source directory"
        check_directory "man" "Documentation directory"
        check_directory "tests" "Tests directory"
        check_directory "vignettes" "Vignettes directory"
        check_directory "inst" "Installed files directory"
        
        # Check for additional R package files
        check_file ".Rbuildignore" ".Rbuildignore file"
        check_file ".Rprofile" ".Rprofile file"
        
        # Check for R project file
        if ls *.Rproj >/dev/null 2>&1; then
            print_status "OK" "RStudio Project: Present"
        else
            print_status "INFO" "RStudio Project: Not found (optional)"
        fi
        
        ;;
        
    "IOS_PROJECT")
        echo "📱 iOS Development Tools"
        echo "----------------------"
        
        # Check iOS-specific tools
        XCODEBUILD_AVAILABLE=false
        XCODEGEN_AVAILABLE=false
        SWIFT_AVAILABLE=false
        IOS_TOOLS_AVAILABLE=false
        SIMCTL_AVAILABLE=false
        
        check_command "xcodebuild" "Xcode Build System" && XCODEBUILD_AVAILABLE=true
        check_command "xcodegen" "XcodeGen" && XCODEGEN_AVAILABLE=true
        check_command "swift" "Swift Compiler" && SWIFT_AVAILABLE=true
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
        
        # Check code quality tools
        echo
        echo "📋 Code Quality Tools"
        echo "-------------------"
        check_command "swiftlint" "SwiftLint"
        check_command "swiftformat" "SwiftFormat"
        check_command "xcbeautify" "Xcbeautify"
        
        # Determine capabilities
        if [ "$XCODEBUILD_AVAILABLE" = true ] && [ "$XCODEGEN_AVAILABLE" = true ] && [ "$SWIFT_AVAILABLE" = true ]; then
            BUILD_CAPABLE=true
        fi
        
        if [ "$BUILD_CAPABLE" = true ] && [ "$SIMCTL_AVAILABLE" = true ]; then
            TEST_CAPABLE=true
        fi
        
        if [ "$IOS_TOOLS_AVAILABLE" = true ] && [ "$SIMCTL_AVAILABLE" = true ]; then
            DEV_CAPABLE=true
        fi
        
        echo
        echo "🏗️  iOS Project Structure"
        echo "----------------------"
        
        # Check project files
        check_file "project.yml" "XcodeGen Configuration"
        
        # Check for Xcode project
        if ls *.xcodeproj >/dev/null 2>&1; then
            print_status "OK" "Xcode Project: Present"
        else
            print_status "WARN" "Xcode Project: Not found"
        fi
        
        # Check key directories
        check_directory "ScrabbleWordSolver" "App Source Directory"
        check_directory "Tests/ScrabbleWordSolverTests" "Test Directory"
        
        ;;
        
    "PYTHON_PROJECT")
        echo "🐍 Python Development Tools"
        echo "-------------------------"
        
        check_command "python" "Python Interpreter"
        check_command "pip" "pip Package Manager"
        check_command "pytest" "pytest Testing Framework"
        
        BUILD_CAPABLE=true
        TEST_CAPABLE=true
        DEV_CAPABLE=true
        
        ;;
        
    "NODEJS_PROJECT")
        echo "📦 Node.js Development Tools"
        echo "--------------------------"
        
        check_command "node" "Node.js Runtime"
        check_command "npm" "npm Package Manager"
        check_command "yarn" "yarn Package Manager"
        
        BUILD_CAPABLE=true
        TEST_CAPABLE=true
        DEV_CAPABLE=true
        
        ;;
        
    "JAVA_PROJECT")
        echo "☕ Java Development Tools"
        echo "----------------------"
        
        check_command "java" "Java Runtime"
        check_command "javac" "Java Compiler"
        check_command "mvn" "Maven Build Tool"
        check_command "gradle" "Gradle Build Tool"
        
        BUILD_CAPABLE=true
        TEST_CAPABLE=true
        DEV_CAPABLE=true
        
        ;;
        
    *)
        echo "🔧 Generic Development Tools"
        echo "-------------------------"
        
        # Check for common development tools
        check_command "git" "Git Version Control"
        check_command "make" "Make Build System"
        check_command "cmake" "CMake Build System"
        
        # Generic capabilities
        BUILD_CAPABLE=true
        TEST_CAPABLE=false
        DEV_CAPABLE=true
        
        ;;
esac

echo
echo "🔍 Environment Capabilities"
echo "-------------------------"

# Determine environment type
ENVIRONMENT_TYPE="UNKNOWN"

case $PROJECT_TYPE in
    "R_PACKAGE")
        if [ "$BUILD_CAPABLE" = true ] && [ "$TEST_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="FULL_R_DEVELOPMENT"
            print_status "OK" "Environment: Full R Package Development (can build, test, and develop)"
        elif [ "$BUILD_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="LIMITED_R_DEVELOPMENT"
            print_status "WARN" "Environment: Limited R Development (can build, limited testing)"
        elif [ "$BUILD_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="R_BUILD_ONLY"
            print_status "WARN" "Environment: R Build Only (can build, no testing)"
        else
            ENVIRONMENT_TYPE="R_BACKGROUND"
            print_status "ERROR" "Environment: R Background (code analysis only)"
        fi
        ;;
        
    "IOS_PROJECT")
        if [ "$BUILD_CAPABLE" = true ] && [ "$TEST_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="FULL_IOS_DEVELOPMENT"
            print_status "OK" "Environment: Full iOS Development (can build, test, and run iOS)"
        elif [ "$BUILD_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="LIMITED_IOS_DEVELOPMENT"
            print_status "WARN" "Environment: Limited iOS Development (can build, limited testing)"
        elif [ "$BUILD_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="IOS_BUILD_ONLY"
            print_status "WARN" "Environment: iOS Build Only (can build, no iOS tools)"
        else
            ENVIRONMENT_TYPE="IOS_BACKGROUND"
            print_status "ERROR" "Environment: iOS Background (code analysis only)"
        fi
        ;;
        
    *)
        if [ "$BUILD_CAPABLE" = true ] && [ "$TEST_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="FULL_DEVELOPMENT"
            print_status "OK" "Environment: Full Development"
        elif [ "$BUILD_CAPABLE" = true ] && [ "$DEV_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="LIMITED_DEVELOPMENT"
            print_status "WARN" "Environment: Limited Development"
        elif [ "$BUILD_CAPABLE" = true ]; then
            ENVIRONMENT_TYPE="BUILD_ONLY"
            print_status "WARN" "Environment: Build Only"
        else
            ENVIRONMENT_TYPE="BACKGROUND"
            print_status "ERROR" "Environment: Background (code analysis only)"
        fi
        ;;
esac

echo
echo "📊 Capability Summary"
echo "-------------------"

print_status "INFO" "Project Type: $PROJECT_TYPE"
print_status "INFO" "Build System: $([ "$BUILD_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "Testing: $([ "$TEST_CAPABLE" = true ] && echo "Available" || echo "Not Available")"
print_status "INFO" "Development: $([ "$DEV_CAPABLE" = true ] && echo "Available" || echo "Not Available")"

echo
echo "🎯 Work Recommendations"
echo "---------------------"

case $ENVIRONMENT_TYPE in
    "FULL_R_DEVELOPMENT")
        print_status "OK" "✅ Can perform full R package development work"
        print_status "INFO" "  - Build and test R packages"
        print_status "INFO" "  - Run R CMD check"
        print_status "INFO" "  - Generate documentation"
        print_status "INFO" "  - Run unit tests"
        print_status "INFO" "  - Check code coverage"
        ;;
    "LIMITED_R_DEVELOPMENT")
        print_status "WARN" "⚠️  Can build R packages but limited testing capability"
        print_status "INFO" "  - Build and validate R packages"
        print_status "INFO" "  - Limited testing"
        print_status "INFO" "  - Focus on code quality"
        print_status "INFO" "  - Request validation for complex features"
        ;;
    "R_BUILD_ONLY")
        print_status "WARN" "⚠️  Can build R packages but no testing available"
        print_status "INFO" "  - Build and validate R packages"
        print_status "INFO" "  - Cannot run tests"
        print_status "INFO" "  - Focus on code analysis"
        print_status "INFO" "  - Request testing from user"
        ;;
    "R_BACKGROUND")
        print_status "ERROR" "❌ Limited to R code analysis only"
        print_status "INFO" "  - Cannot build or test R packages"
        print_status "INFO" "  - Focus on static analysis"
        print_status "INFO" "  - Create patches with validation requirements"
        print_status "INFO" "  - Document all assumptions"
        ;;
    "FULL_IOS_DEVELOPMENT")
        print_status "OK" "✅ Can perform full iOS development work"
        print_status "INFO" "  - Build and test changes"
        print_status "INFO" "  - Run iOS simulators"
        print_status "INFO" "  - Measure performance"
        print_status "INFO" "  - Test accessibility"
        ;;
    "LIMITED_IOS_DEVELOPMENT")
        print_status "WARN" "⚠️  Can build but limited iOS testing capability"
        print_status "INFO" "  - Build and validate changes"
        print_status "INFO" "  - Limited iOS testing"
        print_status "INFO" "  - Focus on code quality"
        print_status "INFO" "  - Request validation for iOS-specific features"
        ;;
    "IOS_BUILD_ONLY")
        print_status "WARN" "⚠️  Can build but no iOS tools available"
        print_status "INFO" "  - Build and validate changes"
        print_status "INFO" "  - Cannot test iOS-specific features"
        print_status "INFO" "  - Focus on code analysis"
        print_status "INFO" "  - Request iOS testing from user"
        ;;
    "IOS_BACKGROUND")
        print_status "ERROR" "❌ Limited to iOS code analysis only"
        print_status "INFO" "  - Cannot build or test"
        print_status "INFO" "  - Focus on static analysis"
        print_status "INFO" "  - Create patches with validation requirements"
        print_status "INFO" "  - Document all assumptions"
        ;;
    "FULL_DEVELOPMENT")
        print_status "OK" "✅ Can perform full development work"
        print_status "INFO" "  - Build and test changes"
        print_status "INFO" "  - Run comprehensive tests"
        print_status "INFO" "  - Measure performance"
        ;;
    "LIMITED_DEVELOPMENT")
        print_status "WARN" "⚠️  Can build but limited testing capability"
        print_status "INFO" "  - Build and validate changes"
        print_status "INFO" "  - Limited testing"
        print_status "INFO" "  - Focus on code quality"
        print_status "INFO" "  - Request validation for complex features"
        ;;
    "BUILD_ONLY")
        print_status "WARN" "⚠️  Can build but no testing available"
        print_status "INFO" "  - Build and validate changes"
        print_status "INFO" "  - Cannot run tests"
        print_status "INFO" "  - Focus on code analysis"
        print_status "INFO" "  - Request testing from user"
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

if [[ "$ENVIRONMENT_TYPE" == *"BACKGROUND"* ]]; then
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
    print_status "WARN" "⚠️  Cannot test functionality"
    print_status "INFO" "ℹ️  Focus on code implementation, not testing"
    print_status "INFO" "ℹ️  Request testing from user"
fi

echo
echo "📝 Next Steps"
echo "------------"

case $ENVIRONMENT_TYPE in
    "FULL_R_DEVELOPMENT")
        print_status "OK" "✅ Proceed with full R package development workflow"
        print_status "INFO" "  - Test all changes before proposing"
        print_status "INFO" "  - Run R CMD check before creating patches"
        print_status "INFO" "  - Validate documentation generation"
        ;;
    "LIMITED_R_DEVELOPMENT"|"R_BUILD_ONLY")
        print_status "WARN" "⚠️  Proceed with caution for R package development"
        print_status "INFO" "  - Test what you can"
        print_status "INFO" "  - Document limitations"
        print_status "INFO" "  - Request validation for untested areas"
        ;;
    "R_BACKGROUND")
        print_status "ERROR" "❌ Proceed with extreme caution for R package development"
        print_status "INFO" "  - Focus on code analysis only"
        print_status "INFO" "  - Document all assumptions"
        print_status "INFO" "  - Create validation requirements for all changes"
        print_status "INFO" "  - Request full validation before applying changes"
        ;;
    "FULL_IOS_DEVELOPMENT")
        print_status "OK" "✅ Proceed with full iOS development workflow"
        print_status "INFO" "  - Test all changes before proposing"
        print_status "INFO" "  - Validate patches before creating"
        print_status "INFO" "  - Run performance and accessibility tests"
        ;;
    "LIMITED_IOS_DEVELOPMENT"|"IOS_BUILD_ONLY")
        print_status "WARN" "⚠️  Proceed with caution for iOS development"
        print_status "INFO" "  - Test what you can"
        print_status "INFO" "  - Document limitations"
        print_status "INFO" "  - Request validation for untested areas"
        ;;
    "IOS_BACKGROUND")
        print_status "ERROR" "❌ Proceed with extreme caution for iOS development"
        print_status "INFO" "  - Focus on code analysis only"
        print_status "INFO" "  - Document all assumptions"
        print_status "INFO" "  - Create validation requirements for all changes"
        print_status "INFO" "  - Request full validation before applying changes"
        ;;
    "FULL_DEVELOPMENT")
        print_status "OK" "✅ Proceed with full development workflow"
        print_status "INFO" "  - Test all changes before proposing"
        print_status "INFO" "  - Validate patches before creating"
        print_status "INFO" "  - Run comprehensive tests"
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
export AI_PROJECT_TYPE="$PROJECT_TYPE"
export AI_BUILD_CAPABLE="$BUILD_CAPABLE"
export AI_TEST_CAPABLE="$TEST_CAPABLE"
export AI_DEV_CAPABLE="$DEV_CAPABLE"

# Return appropriate exit code
case $ENVIRONMENT_TYPE in
    "FULL_R_DEVELOPMENT"|"FULL_IOS_DEVELOPMENT"|"FULL_DEVELOPMENT")
        exit 0
        ;;
    "LIMITED_R_DEVELOPMENT"|"R_BUILD_ONLY"|"LIMITED_IOS_DEVELOPMENT"|"IOS_BUILD_ONLY"|"LIMITED_DEVELOPMENT"|"BUILD_ONLY")
        exit 1
        ;;
    "R_BACKGROUND"|"IOS_BACKGROUND"|"BACKGROUND")
        exit 2
        ;;
    *)
        exit 3
        ;;
esac
