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
