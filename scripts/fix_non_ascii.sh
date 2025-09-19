#!/bin/bash
# fix_non_ascii.sh - Remove non-ASCII characters from R files

echo "🔍 Removing non-ASCII characters from R files..."

# Replace emoji characters with ASCII alternatives
find R/ -name "*.R" -exec sed -i '' 's/🎯/TARGET:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📊/RESULTS:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/❌/ERROR:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/💡/TIP:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/✅/SUCCESS:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📁/DIR:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📄/FILE:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🔒/PRIVACY:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🎉/COMPLETE:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🚀/QUICK:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🔄/BATCH:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📈/STATS:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/⚙️/TOOLS:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🛡️/PROTECT:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/⚖️/ETHICS:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📋/LIST:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🔧/ADVANCED:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🌟/ESSENTIAL:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🔍/FIND:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📝/DESC:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/📅/DATE:/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/🧪/TEST:/g' {} \;

# Replace bullet points
find R/ -name "*.R" -exec sed -i '' 's/•/-/g' {} \;

# Replace arrow characters
find R/ -name "*.R" -exec sed -i '' 's/→/->/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/≤/<=/g' {} \;
find R/ -name "*.R" -exec sed -i '' 's/≥/>=/g' {} \;

echo "✅ Non-ASCII character removal complete!"
