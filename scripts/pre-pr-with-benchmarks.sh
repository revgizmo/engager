#!/bin/bash

# Pre-PR Validation with Benchmarking Enabled
# This script runs the pre-PR validation with benchmarking tests enabled
# Use this when you want to test performance characteristics

echo "🚀 Running Pre-PR Validation with Benchmarking Enabled"
echo "   Set PREPR_DO_BENCH=1 to enable performance tests"
echo ""

# Export environment variable to enable benchmarking
export PREPR_DO_BENCH=1

# Run the pre-PR validation script
Rscript scripts/pre-pr-validation.R

echo ""
echo "✅ Pre-PR validation with benchmarking completed!"
echo "   If you encountered segfaults, run without benchmarks: ./scripts/pre-pr.sh"
