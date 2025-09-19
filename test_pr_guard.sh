#!/bin/bash

# Test script for PR Regression Guard workflow
# This simulates the GitHub Actions workflow locally

echo "🧪 Testing PR Regression Guard Workflow"
echo "========================================"

# Step 1: Run performance tests
echo "📊 Step 1: Running performance tests..."
Rscript perf/scripts/simple-performance-test.R 3 test_pr_results.json

if [ $? -ne 0 ]; then
    echo "❌ Performance tests failed"
    exit 1
fi

echo "✅ Performance tests completed"

# Step 2: Check for regressions
echo "🔍 Step 2: Checking for performance regressions..."
Rscript perf/scripts/check-performance-regression.R test_pr_results.json perf/baselines/linux-R-release.json
regression_exit_code=$?

# Step 3: Report results
echo "📋 Step 3: Reporting results..."
if [ $regression_exit_code -eq 0 ]; then
    echo "✅ No performance regressions detected"
    echo "🎉 PR would be allowed to proceed"
else
    echo "❌ Performance regressions detected"
    echo "🚫 PR would be blocked"
fi

echo ""
echo "📊 Performance Test Summary:"
if [ -f test_pr_results.json ]; then
    echo "Results saved to: test_pr_results.json"
    echo "Raw results:"
    cat test_pr_results.json | head -20
fi

echo ""
echo "🏁 PR Regression Guard test completed"
echo "Exit code: $regression_exit_code"
