#!/bin/bash

# Save context output to files for linking in Cursor chats
# Usage: ./scripts/save-context.sh [--update-sections]
# Then link with: @context.md or @r-context.md
#
# Features:
# - Validation of required scripts and dependencies
# - Comprehensive error handling
# - Progress indicators
# - Backup of existing files
# - Clean error messages
# - Optional PROJECT.md section updates

set -euo pipefail  # Stricter error handling
trap 'echo "❌ Script failed at line $LINENO"' ERR

# Function to update PROJECT.md sections with fresh GitHub data
update_project_sections() {
    echo "🔄 Updating PROJECT.md sections with fresh GitHub data..."
    
    # Validate dependencies
    if ! command -v gh &> /dev/null; then
        echo "❌ Error: GitHub CLI (gh) not found"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "❌ Error: jq not found"
        return 1
    fi
    
    # Create backup
    echo "💾 Creating backup..."
    cp PROJECT.md PROJECT.md.backup.$(date '+%Y%m%d_%H%M%S')
    echo "✅ Backup created"
    
    # Generate fresh critical issues section
    echo "📝 Generating fresh critical issues..."
    gh issue list --label "priority:high" --json number,title,state --jq '.[] | "- **\(.title)**: \(.state) ([Issue #\(.number)](https://github.com/revgizmo/zoomstudentengagement/issues/\(.number)) - Priority: HIGH)"' > /tmp/fresh_critical.md 2>/dev/null || echo "# No high priority issues found" > /tmp/fresh_critical.md
    
    # Generate fresh CRAN submission issues
    echo "📝 Generating fresh CRAN submission issues..."
    gh issue list --label "CRAN:submission" --json number,title,state --jq '.[] | "- **[Issue #\(.number)](https://github.com/revgizmo/zoomstudentengagement/issues/\(.number))**: \(.title) (\(.state))"' > /tmp/fresh_cran.md 2>/dev/null || echo "# No CRAN submission issues found" > /tmp/fresh_cran.md
    
    echo "✅ Fresh data generated"
    
    # Update PROJECT.md using awk
    echo "📝 Updating PROJECT.md..."
    awk '
    BEGIN { 
        in_critical = 0
        in_cran = 0
    }
    
    # Detect start of critical issues section
    /^### What Needs Work/ { 
        in_critical = 1
        print
        # Print the fresh critical issues
        while ((getline line < "/tmp/fresh_critical.md") > 0) {
            print line
        }
        close("/tmp/fresh_critical.md")
        next
    }
    
    # Detect end of critical issues section
    in_critical && /^## 🚨/ { 
        in_critical = 0
        print
        next
    }
    
    # Skip lines while in critical section
    in_critical { next }
    
    # Detect start of CRAN issues section
    /^### 🔄 \*\*Remaining Issues/ { 
        in_cran = 1
        print
        # Print the fresh CRAN issues
        while ((getline line < "/tmp/fresh_cran.md") > 0) {
            print line
        }
        close("/tmp/fresh_cran.md")
        next
    }
    
    # Detect end of CRAN issues section
    in_cran && /^### 🆕 \*\*New Critical Issues/ { 
        in_cran = 0
        print
        next
    }
    
    # Skip lines while in CRAN section
    in_cran { next }
    
    # Print all other lines
    { print }
    ' PROJECT.md > PROJECT.md.new
    
    # Replace original with new version
    mv PROJECT.md.new PROJECT.md
    
    # Clean up temporary files
    rm -f /tmp/fresh_critical.md /tmp/fresh_cran.md
    
    echo "✅ PROJECT.md sections updated successfully!"
    echo "📊 Updated 'What Needs Work' and 'Remaining Issues' sections"
}

# Check if --update-sections flag is provided
UPDATE_SECTIONS=false
if [[ "${1:-}" == "--update-sections" ]]; then
    UPDATE_SECTIONS=true
fi

echo "💾 Saving context output to files for linking..."
echo "=================================================="

# Validate dependencies and scripts
echo "🔍 Validating dependencies and scripts..."

# Check if required scripts exist
if [ ! -f "./scripts/context-for-new-chat.sh" ]; then
    echo "❌ Error: context-for-new-chat.sh not found"
    exit 1
fi

if [ ! -f "./scripts/context-for-new-chat.R" ]; then
    echo "❌ Error: context-for-new-chat.R not found"
    exit 1
fi

if [ ! -f "./scripts/get-context.sh" ]; then
    echo "❌ Error: get-context.sh not found"
    exit 1
fi

# Check if scripts are executable
if [ ! -x "./scripts/context-for-new-chat.sh" ]; then
    echo "❌ Error: context-for-new-chat.sh is not executable"
    exit 1
fi

if [ ! -x "./scripts/get-context.sh" ]; then
    echo "❌ Error: get-context.sh is not executable"
    exit 1
fi

# Check for R
if ! command -v Rscript &> /dev/null; then
    echo "❌ Error: Rscript not found. Please install R."
    exit 1
fi

echo "✅ All dependencies validated"
echo ""

# Update PROJECT.md sections if requested
if [ "$UPDATE_SECTIONS" = true ]; then
    update_project_sections
    echo ""
fi

# Create .cursor directory if it doesn't exist
echo "📁 Creating .cursor directory..."
mkdir -p .cursor
echo "✅ Directory ready"
echo ""

# Backup existing files if they exist
echo "💾 Backing up existing context files..."
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
if [ -f ".cursor/context.md" ]; then
    cp .cursor/context.md .cursor/context_backup_${TIMESTAMP}.md
    echo "✅ Backed up context.md"
fi
if [ -f ".cursor/r-context.md" ]; then
    cp .cursor/r-context.md .cursor/r-context_backup_${TIMESTAMP}.md
    echo "✅ Backed up r-context.md"
fi
if [ -f ".cursor/full-context.md" ]; then
    cp .cursor/full-context.md .cursor/full-context_backup_${TIMESTAMP}.md
    echo "✅ Backed up full-context.md"
fi
echo ""

# Save shell context
echo "📝 Saving shell context to .cursor/context.md..."
if ./scripts/context-for-new-chat.sh > .cursor/context.md; then
    echo "✅ Shell context saved successfully"
else
    echo "❌ Failed to save shell context"
    exit 1
fi

# Save R context
echo "📝 Saving R context to .cursor/r-context.md..."
if Rscript scripts/context-for-new-chat.R > .cursor/r-context.md; then
    echo "✅ R context saved successfully"
else
    echo "❌ Failed to save R context"
    exit 1
fi

# Save combined context
echo "📝 Saving combined context to .cursor/full-context.md..."
if ./scripts/get-context.sh > .cursor/full-context.md; then
    echo "✅ Combined context saved successfully"
else
    echo "❌ Failed to save combined context"
    exit 1
fi

# Create a timestamped version for historical reference
echo "📝 Saving timestamped context to .cursor/context_${TIMESTAMP}.md..."
if ./scripts/get-context.sh > .cursor/context_${TIMESTAMP}.md; then
    echo "✅ Timestamped context saved successfully"
else
    echo "❌ Failed to save timestamped context"
    exit 1
fi

echo ""
echo "✅ All context files saved successfully!"
echo "=================================================="
echo "📁 Context files saved:"
echo "   • .cursor/context.md - Shell context (link with @context.md)"
echo "   • .cursor/r-context.md - R-specific context (link with @r-context.md)"
echo "   • .cursor/full-context.md - Combined context (link with @full-context.md)"
echo "   • .cursor/context_${TIMESTAMP}.md - Timestamped version"
echo ""
echo "💡 Usage in Cursor:"
echo "   • Link shell context: @context.md"
echo "   • Link R context: @r-context.md"
echo "   • Link full context: @full-context.md"
echo ""
echo "🔄 Run this script whenever you want to update the saved context files"
if [ "$UPDATE_SECTIONS" = true ]; then
    echo "📝 PROJECT.md sections updated with fresh GitHub data"
fi
echo "💾 Backups created with timestamp: ${TIMESTAMP}"
echo "==================================================" 