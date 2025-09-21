#!/bin/bash

# Comprehensive test for PR Regression Guard workflow
# Tests both normal performance and regression scenarios

echo "🧪 Comprehensive PR Regression Guard Test"
echo "=========================================="

# Test 1: Normal performance (should pass)
echo "📊 Test 1: Normal Performance (should pass)"
echo "--------------------------------------------"
Rscript perf/scripts/simple-performance-test.R 3 normal_results.json
Rscript perf/scripts/check-performance-regression.R normal_results.json perf/baselines/linux-R-release.json
normal_exit_code=$?

if [ $normal_exit_code -eq 0 ]; then
    echo "✅ Test 1 PASSED: Normal performance detected correctly"
else
    echo "❌ Test 1 FAILED: Normal performance incorrectly flagged as regression"
fi

echo ""

# Test 2: Regression scenario (should fail)
echo "📊 Test 2: Regression Scenario (should fail)"
echo "--------------------------------------------"
Rscript perf/scripts/check-performance-regression.R test_regression_results.json perf/baselines/linux-R-release.json
regression_exit_code=$?

if [ $regression_exit_code -eq 1 ]; then
    echo "✅ Test 2 PASSED: Regression detected correctly"
else
    echo "❌ Test 2 FAILED: Regression not detected"
fi

echo ""

# Summary
echo "📋 Test Summary"
echo "==============="
echo "Normal performance test: $([ $normal_exit_code -eq 0 ] && echo "✅ PASS" || echo "❌ FAIL")"
echo "Regression detection test: $([ $regression_exit_code -eq 1 ] && echo "✅ PASS" || echo "❌ FAIL")"

if [ $normal_exit_code -eq 0 ] && [ $regression_exit_code -eq 1 ]; then
    echo ""
    echo "🎉 All tests PASSED! PR Regression Guard is working correctly."
    echo "✅ Normal performance: Allowed to proceed"
    echo "❌ Performance regressions: Blocked correctly"
else
    echo ""
    echo "❌ Some tests FAILED! PR Regression Guard needs fixing."
    exit 1
fi
