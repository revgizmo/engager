#!/bin/bash
# fix_function_calls.sh - Fix unqualified function calls

echo "🔧 Fixing unqualified function calls..."

# Add utils:: prefix to unqualified calls
find R/ -name "*.R" -exec sed -i '' 's/\bhelp(/utils::help(/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/\bstr(/utils::str(/g' {} \;

echo "✅ Function call qualification complete!"
