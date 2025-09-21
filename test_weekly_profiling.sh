#!/bin/bash

# Test script for Weekly Performance Profiling workflow
# This simulates the GitHub Actions workflow locally

echo "🧪 Testing Weekly Performance Profiling Workflow"
echo "==============================================="

# Step 1: Run comprehensive performance profiling
echo "📊 Step 1: Running comprehensive performance profiling..."
Rscript perf/scripts/simple-performance-profiling.R perf/reports/weekly

if [ $? -ne 0 ]; then
    echo "❌ Comprehensive profiling failed"
    exit 1
fi

echo "✅ Comprehensive profiling completed"

# Step 2: Check generated files
echo "📁 Step 2: Checking generated files..."
if ls perf/reports/weekly/profiling_*.json >/dev/null 2>&1; then
    echo "✅ JSON profiling report generated"
    ls -la perf/reports/weekly/profiling_*.json
else
    echo "❌ JSON profiling report not found"
    exit 1
fi

if ls perf/reports/weekly/summary_*.txt >/dev/null 2>&1; then
    echo "✅ Summary report generated"
    ls -la perf/reports/weekly/summary_*.txt
else
    echo "❌ Summary report not found"
    exit 1
fi

# Step 3: Validate JSON structure
echo "🔍 Step 3: Validating JSON structure..."
latest_json=$(ls -t perf/reports/weekly/profiling_*.json | head -1)
if jq empty "$latest_json" 2>/dev/null; then
    echo "✅ JSON structure is valid"
else
    echo "❌ JSON structure is invalid"
    exit 1
fi

# Step 4: Check performance metrics
echo "📊 Step 4: Checking performance metrics..."
if jq -e '.profiling.small_transcript.time_stats.median_ms' "$latest_json" > /dev/null; then
    echo "✅ Small transcript metrics present"
else
    echo "❌ Small transcript metrics missing"
    exit 1
fi

if jq -e '.profiling.large_synthetic.time_stats.median_ms' "$latest_json" > /dev/null; then
    echo "✅ Large synthetic metrics present"
else
    echo "❌ Large synthetic metrics missing"
    exit 1
fi

if jq -e '.profiling.memory_stress.time_stats.median_ms' "$latest_json" > /dev/null; then
    echo "✅ Memory stress metrics present"
else
    echo "❌ Memory stress metrics missing"
    exit 1
fi

# Step 5: Display summary
echo "📋 Step 5: Performance Summary"
echo "=============================="
if [ -f perf/reports/weekly/summary_*.txt ]; then
    latest_summary=$(ls -t perf/reports/weekly/summary_*.txt | head -1)
    cat "$latest_summary"
fi

echo ""
echo "📊 Detailed Metrics:"
echo "==================="
echo "Small Transcript:"
jq -r '.profiling.small_transcript | "  Time (median): \(.time_stats.median_ms | round) ms", "  Memory (peak): \(.memory_stats.peak_mb | round * 1000) MB"' "$latest_json"

echo "Medium Transcript:"
jq -r '.profiling.medium_transcript | "  Time (median): \(.time_stats.median_ms | round) ms", "  Memory (peak): \(.memory_stats.peak_mb | round * 1000) MB"' "$latest_json"

echo "Large Synthetic:"
jq -r '.profiling.large_synthetic | "  Time (median): \(.time_stats.median_ms | round) ms", "  Memory (peak): \(.memory_stats.peak_mb | round * 1000) MB"' "$latest_json"

echo "Memory Stress:"
jq -r '.profiling.memory_stress | "  Time (median): \(.time_stats.median_ms | round) ms", "  Memory (peak): \(.memory_stats.peak_mb | round * 1000) MB"' "$latest_json"

echo ""
echo "🎉 Weekly Performance Profiling test completed successfully!"
echo "✅ All components working correctly"
echo "📁 Reports saved to: perf/reports/weekly/"
echo "🔄 Ready for GitHub Actions integration"
