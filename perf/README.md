# Performance CI System

This directory contains the performance CI system for the engager R package, implementing a sophisticated regression-based testing approach.

## Overview

The performance CI system uses a two-tier approach:
- **PR Regression Guard**: Fast, blocking tests that compare to baseline
- **Weekly Profiling**: Comprehensive, non-blocking trend tracking

## Directory Structure

```
perf/
├── baselines/           # Committed performance baselines
│   ├── linux-R-release.json
│   ├── macos-R-release.json
│   └── windows-R-release.json
├── scripts/            # Performance test scripts
│   ├── performance-test.R
│   ├── check-performance-regression.R
│   └── performance-profiling.R
├── reports/            # Weekly profiling reports
│   └── weekly/
└── README.md           # This file
```

## Key Features

### 1. Baseline Management
- **Committed baselines**: JSON files stored in repository
- **Multi-environment**: Linux, macOS, Windows support
- **Auditable**: Easy to track baseline changes
- **Automated updates**: Via dedicated workflow

### 2. Regression Detection
- **Threshold-based**: +20% time, +30% memory thresholds
- **Real user workflows**: Tests actual transcript processing
- **Memory tracking**: GC count and allocation monitoring
- **Blocking**: PRs with regressions are blocked

### 3. CRAN Safety
- **skip_on_cran()**: Performance tests wrapped for CRAN safety
- **CI-only**: Actual benchmarking in CI workflows
- **No CRAN impact**: Performance tests don't affect CRAN submission

## Usage

### Running Performance Tests Locally

```r
# Fast performance tests
source("perf/scripts/performance-test.R")
results <- run_performance_tests(iterations = 5)

# Check for regressions
source("perf/scripts/check-performance-regression.R")
exit_code <- check_performance_regression()

# Comprehensive profiling
source("perf/scripts/performance-profiling.R")
profiling_results <- run_performance_profiling()
```

### Updating Baselines

1. **Manual update**: Edit baseline JSON files directly
2. **Automated update**: Use GitHub Actions workflow
3. **Validation**: Run tests to ensure baselines are current

### CI Integration

The system includes three GitHub Actions workflows:

1. **performance-regression-guard.yml**: PR regression guard
2. **performance-weekly-profiling.yml**: Weekly comprehensive profiling
3. **update-performance-baseline.yml**: Baseline management

## Performance Metrics

### Tracked Metrics
- **Processing Time**: Median execution time using `{bench}` package
- **Memory Usage**: Peak memory consumption and GC count
- **Scalability**: Performance with different transcript sizes
- **Regression Detection**: Automated baseline comparison

### Test Scenarios
- **Small transcripts**: Fast processing tests
- **Medium transcripts**: Moderate complexity tests
- **Large synthetic**: O(n²) canary tests
- **Memory stress**: Multiple dataset processing

## Regression Thresholds

Current thresholds (configurable in baseline files):
- **Time regression**: +20% increase triggers failure
- **Memory regression**: +30% increase triggers failure

## Best Practices

### For Developers
1. **Run locally**: Test performance before pushing
2. **Update baselines**: When performance improvements are made
3. **Monitor trends**: Check weekly profiling reports
4. **Optimize early**: Address performance issues in PRs

### For Maintainers
1. **Review baselines**: Ensure they're current and realistic
2. **Monitor CI**: Watch for performance regression alerts
3. **Update thresholds**: Adjust based on project needs
4. **Document changes**: Explain baseline updates

## Troubleshooting

### Common Issues

1. **Baseline not found**: Ensure baseline files exist and are valid JSON
2. **Performance regressions**: Check if regression is acceptable or needs optimization
3. **CI timeouts**: Performance tests should be fast; check for infinite loops
4. **Memory issues**: Monitor GC count and memory usage patterns

### Debug Commands

```bash
# Check baseline validity
jq . perf/baselines/linux-R-release.json

# Run performance tests with verbose output
Rscript perf/scripts/performance-test.R 10 debug_results.json

# Check regression detection
Rscript perf/scripts/check-performance-regression.R debug_results.json perf/baselines/linux-R-release.json
```

## Future Improvements

1. **Performance dashboards**: Visual trend tracking
2. **Automated optimization**: Suggest performance improvements
3. **Cross-platform baselines**: More environment support
4. **Integration alerts**: Slack/email notifications for regressions

## References

- [Issue #424](https://github.com/revgizmo/engager/issues/424): Performance Benchmarking
- [R Performance Best Practices](https://adv-r.hadley.nz/perf-intro.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
