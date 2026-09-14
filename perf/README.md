# Legacy performance infrastructure — non-authoritative

The scripts and baseline files in this directory are historical infrastructure.
They are not authoritative evidence of current performance, peak resident
memory, accepted regression thresholds, or a working regression guard. The old
baseline files remain unchanged; this tranche does not migrate or approve them.

Use the [synthetic measurement contract](../project-docs/performance/MEASUREMENT_CONTRACT.md)
and `scripts/benchmarks/measurement_contract.R` for current workload definitions,
reproduction, strict JSON validation, timing and Linux absolute peak RSS
semantics. The Benchmarks workflow retains the existing coarse file-count
budgets and records measurements without relative-baseline comparisons.

Issue [#471](https://github.com/revgizmo/engager/issues/471) tracks the broader
work. Baseline reconciliation, accepted regression thresholds, regression
detection, dashboards, and optimizations require separate work and authority.

The [descriptive comparison tool](../project-docs/performance/COMPARISON_CONTRACT.md)
compares two explicitly selected checksum-bound measurement artifacts. It does
not select or update these legacy baselines or issue regression verdicts.

New measurements use schema `2.0.0` runtime snapshots: loaded direct dependency
versions, constrained runner image/hardware metadata and a measurement-source
fingerprint. Legacy `1.0.0` is still readable but is non-comparable in the new
comparator because runtime evidence is absent. Matching recorded facts permits
descriptive differences only; it does not establish equivalent execution
conditions, a trusted baseline or accepted regression thresholds.

The [paired execution contract](../project-docs/performance/PAIRED_EXECUTION_CONTRACT.md)
adds an explicitly versioned, manual-only reference/repeat experiment on one
allocated worker. It preserves measurement2 and the ordinary comparator's
same-run rejection. Implementation tests use fabricated values; a real hosted
paired demonstration and later pilot require separate execution authority.
