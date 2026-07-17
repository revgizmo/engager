# `engager` 0.1.2 Privacy-Safe Aggregation Contract

Status: draft specification packet only. This document does not authorize
implementation, a public export, a version change, or a merge to `develop`.
Maintainer approval of the contract is required before an implementation
tranche begins.

## User job and boundary

Turn a supported local `engager` result into a review-ready group-level table
whose allowed dimensions and measures are explicit, whose small groups are
suppressed, and whose output cannot carry row-level participant identifiers,
pseudonyms, hashes, source paths, or transcript text.

The result is a candidate for sharing only after local disclosure review.

The operation supports disclosure review; it does not make a data set
anonymous, determine legal compliance, or establish institutional approval.
Users remain responsible for contextual disclosure risks, including cases in
which a course, section, session, or combination of dimensions identifies a
small or otherwise recognizable group.

Version 0.1.2 must not restore
`anonymize_educational_data(method = "aggregate")`. Identifier transformation
and aggregation are different operations: masking, hashing, and
pseudonymization preserve row-level records, while this contract produces only
approved group-level results.

## Proposed release boundary

The first implementation should support one named workflow end to end:

1. accept an `engager_attendance` object with schema
   `engager_attendance_v1`;
2. derive only approved course- or session-level attendance measures;
3. apply deterministic small-group suppression before returning results;
4. return a versioned result with non-identifying provenance; and
5. write and re-read the result in an installed-package UAT using bundled
   synthetic fixtures.

Speaker-level transcript metrics are a candidate extension only after their
current free-text, participant-name, percentage-denominator, and provenance
semantics have a separately approved input contract. Arbitrary data frames are
not accepted by the initial workflow because column names alone cannot prove
that a field is safe to group or aggregate.

## Provisional interface

The public name remains provisional until the contract is approved. A working
shape for design and tests is:

```r
aggregate_attendance(
  x,
  group_by = "session",
  metrics = c("attendance_count", "attendance_rate"),
  min_group_size
)
```

The function must not be added to `NAMESPACE`, documentation categories, or
the supported-export allowlist until its contract, adversarial tests, and
installed UAT pass. The implementation may begin as an internal helper, but
the public interface is earned only at a release boundary.

## Supported input

The initial input is one validated `engager_attendance` object. It may contain
local sensitive participant rows, but the aggregator reads those rows only to
compute an approved measure. It never copies them to the returned object.

Input validation is fail-closed:

- class must include `engager_attendance`;
- `metadata$schema_version` must be exactly `engager_attendance_v1`;
- required component schemas and types must match the attendance contract;
- participant and session denominators must be internally consistent;
- missing, duplicate, or unexpected required fields are errors; and
- unsupported future schemas are errors rather than best-effort coercions.

The implementation must not accept a path, transcript object, raw roster, or
untyped data frame through `...` or an undocumented fallback.

## Allowed grouping dimensions

`group_by` is an enum, not an arbitrary column list or expression.

| Value | Output grain | Required behavior |
|---|---|---|
| `"course"` | one course-total row | No participant or session identifier is returned. |
| `"session"` | one row per scheduled session | Returns a deterministic ordinal label and status; cancelled sessions remain distinct and have unavailable attendance measures. |

No combined dimensions are supported initially. Participant identifiers,
roster names, aliases, transformed identifiers, problem messages, source-file
attributes, paths, timestamps copied from filenames, and caller-supplied
columns are never grouping dimensions.

User-supplied `session_id` and `session_at` values are not copied to the result.
Session-grain output uses deterministic labels such as `session_001`, assigned
after the source object's validated ordering. The output does not include a
mapping back to source labels. A mapping is sensitive local analysis data and
is outside this candidate-for-sharing result.

## Allowed measures

`metrics` is a unique, non-empty vector selected from a schema-specific
allowlist. The initial attendance measures are:

| Measure | Type | Course grain | Session grain | Definition |
|---|---|---:|---:|---|
| `eligible_participant_count` | integer | yes | yes | Count of roster rows eligible for attendance. |
| `eligible_session_count` | integer | yes | no | Count of successfully validated recorded sessions. |
| `attendance_count` | integer | yes | yes | Course: sum of present participant-session cells. Session: present participants. |
| `absence_count` | integer | yes | yes | Course: sum of absent participant-session cells. Session: absent participants. |
| `attendance_rate` | double | yes | yes | `attendance_count` divided by the explicit eligible participant-session denominator. |
| `unmatched_speaker_count` | integer | yes | yes | Sum of non-identifying unmatched-speaker counts recorded by the source result. |

Every returned rate must include its integer numerator and denominator even if
the caller did not request those support columns. The output must distinguish
zero, missing, cancelled, suppressed, and not-applicable values.

The API does not accept functions, formulas, expressions, arbitrary column
names, quantiles, minima, maxima, free-text summaries, or user-defined
statistics. New measures require a contract revision with denominator,
missingness, sensitivity, and disclosure analysis.

## Minimum-group and suppression semantics

`min_group_size` is required and must be one finite whole number of at least
`2`. The package does not choose an institutional threshold or imply that one
number is appropriate for every setting. Documentation should explain the
tradeoff and require the caller to select a value under their own disclosure
review process.

For attendance results, the group size is the number of eligible roster
participants underlying the row, not the number observed present. A row is a
small cell when `eligible_participant_count < min_group_size`; equality is
released.

Small-cell handling is deterministic and fail-closed:

- grouping dimensions and status may remain visible;
- every numeric measure is set to `NA`;
- `release_status` is `"suppressed"`;
- `suppression_reason` is the stable code `"minimum_group_size"`;
- the exact below-threshold group size is not returned; and
- warnings and print methods report only the number of suppressed rows.

Complementary suppression is an invariant, not an optional mode. Totals or
sibling rows are additionally suppressed when their release would permit
reconstruction of a suppressed value. The implementation must define and test
a deterministic complementary-suppression algorithm before any public export.
If safe complementary suppression cannot be proven for a requested result, the
operation errors rather than returning a partially protected table.

The initial API provides no suppression selector, `"none"` value, or override
mode. Callers who need unsuppressed local analysis use the existing sensitive
analysis object rather than a candidate-for-sharing aggregation result.

## Missingness, cancellation, and denominator rules

- Cancelled sessions remain visible with `release_status = "not_applicable"`;
  attendance and absence measures are `NA`, and they do not enter course
  denominators.
- A validated recorded session with no observed matches has zero attendance,
  not missing attendance.
- Failed or unreadable inputs cannot appear in a returned attendance object and
  therefore cannot silently reduce an aggregation denominator.
- Unmatched speakers remain nonparticipants and do not change eligible-roster
  denominators.
- `attendance_rate` uses the same recorded-session and eligible-roster rules as
  `engager_attendance_v1`; the aggregator must not recompute a different
  denominator from non-missing output rows.
- Non-finite measures and internally inconsistent totals are input errors.

## Result contract

The proposed result class is `engager_aggregation` with schema version
`engager_aggregation_v1`. It contains `data`, `problems`, and `metadata`.

### `data`

Every row has the requested allowed grouping dimension plus:

| Column | Type | Meaning |
|---|---|---|
| `release_status` | character | `released`, `suppressed`, or `not_applicable`. |
| `suppression_reason` | character | Stable code or `NA`; never a free-text explanation containing source values. |
| requested measure columns | typed | Approved measures, set to `NA` when suppressed or not applicable. |
| required support columns | integer | Numerators and denominators needed to interpret released rates. |

The table never contains participant-level rows, `student_id`, participant
names, aliases, pseudonyms, hashes, email, transcript text, comments, source
paths, input filenames, or arbitrary input columns. Attributes are part of the
same disclosure boundary and may not carry forbidden values.

### `problems`

Zero or more rows with stable `code`, `severity`, `count`, and a fixed
non-identifying message. It may record counts such as suppressed rows or
unmatched-speaker occurrences, but never a participant, speaker, file, or
free-text value.

### `metadata`

Contains only:

- aggregation schema version and package version;
- source class and source schema version;
- requested grouping grain and measure names;
- minimum-group and suppression settings;
- counts of released, suppressed, and not-applicable rows; and
- deterministic output checksum computed from canonical result content.

It does not contain paths, filenames, session labels, participant identifiers,
raw parameter objects, run time embedded in deterministic content, salts, or
free-form caller notes. Print and summary methods reveal only aggregate counts
and contract settings.

The checksum supports local integrity checking; it does not make the underlying
values anonymous or prove that two releases are safe to link. Input
fingerprints belong in a separate local-only analysis-manifest contract. They
must not be copied into this candidate-for-sharing result by default because a
stable fingerprint can enable linkage across releases.

## Error contract

Input and contract violations use a stable `engager_aggregation_error` parent
class plus a specific subclass. Initial subclasses should cover:

- unsupported source class or schema;
- invalid group selection;
- invalid or duplicate metric selection;
- invalid minimum-group setting;
- inconsistent source denominators or types;
- forbidden source content in an output or attribute; and
- unsafe complementary suppression.

Errors identify the violated contract and allowed choices without echoing
participant values, transcript text, file paths, or raw offending content.
There is no partial-result, best-effort, or silent-column-dropping mode.

## Disclosure and adversarial test matrix

All tests use bundled or generated synthetic data. Before export, the contract
requires regression tests for:

1. direct identifiers in participant rows, names, aliases, email-like values,
   and custom attributes;
2. row-level hashes, pseudonyms, masks, and stable linkage keys;
3. free text in comments, problem messages, labels, and attributes;
4. singleton, empty, below-threshold, threshold-equal, and above-threshold
   groups;
5. cancelled sessions, zero attendance, all attendance, missing values, and
   unmatched-speaker counts;
6. total-minus-cell and sibling-cell reconstruction, including repeated calls
   with different metric selections;
7. reordered inputs, repeated runs, and deterministic output/checksum behavior;
8. unsupported future schemas, malformed types, duplicate rows, and impossible
   denominators;
9. malicious session labels containing Markdown, path-like strings, or
   synthetic participant names; and
10. recursive scans of returned data, attributes, printed output, written
    artifacts, and machine-readable metadata for forbidden synthetic tokens.

Tests must prove absence from exported artifacts; warnings about identifier-like
column names are not sufficient evidence.

## Installed-package UAT

The release UAT installs the built source tarball into a fresh library and uses
only bundled synthetic attendance fixtures. It must:

1. construct an `engager_attendance_v1` result through the public 0.1.1
   workflow;
2. create course- and session-grain aggregation results;
3. exercise released, suppressed, and cancelled rows;
4. write the candidate-for-sharing result to a temporary directory; a separate
   local-only manifest tranche may be exercised independently;
5. verify schemas, numerators, denominators, stable problem codes, and
   checksums; and
6. recursively scan every artifact for raw synthetic identifiers, names,
   aliases, transcript excerpts, source paths, hashes, and pseudonyms.

No real course data or generated UAT output is committed.

## Delivery tranches and dependencies

The contract is intentionally smaller than the full candidate 0.1.2 roadmap.
Implementation should proceed only after 0.1.1 ships, fresh-user feedback is
reviewed, and the maintainer approves this specification.

1. **A0 — Contract approval:** resolve grouping, metric, default-threshold,
   complementary-suppression, schema, and naming decisions.
2. **A1 — Internal engine:** validate `engager_attendance_v1`, compute allowed
   measures, and fail closed; no export.
3. **A2 — Disclosure controls:** implement minimum-group and complementary
   suppression with adversarial reconstruction tests.
4. **A3 — Result schema:** add deterministic provenance, output checksums,
   stable errors, and artifact scanners. Coordinate with, but do not silently
   absorb, a separate local-only analysis-manifest contract.
5. **A4 — Public workflow:** approve the final name, export only the reviewed
   function, document disclosure limits, and add installed-tarball UAT.
6. **A5 — 0.1.2 release candidate:** reconcile other accepted 0.1.2 tranches,
   run release gates, and obtain explicit approval for promotion.

Issue #341 may inform shared identifier-transformation provenance, but its old
blanket-anonymization premise does not govern this API. Issue #381 is a separate
metadata-only audit-record tranche and must not log identifiers. Issue #438 is
a separate atomic-write/error tranche. None is silently folded into the
aggregation implementation.

## Explicit non-goals

- Restoring `method = "aggregate"` on `anonymize_educational_data()`.
- Accepting arbitrary data frames, columns, formulas, or user functions.
- Returning row-level identifiers in raw, masked, hashed, or pseudonymized form.
- Transcript-topic analysis, free-text aggregation, or comment export.
- Fuzzy matching, longitudinal participant profiles, ranking, risk scoring, or
  intervention recommendations.
- Compliance reports, anonymity claims, institutional-policy defaults, or
  legal determinations.
- Excel output, charts, performance optimization, or additional input formats.
- Implementing issues #341, #381, or #438 within this contract tranche.

## Open decisions requiring maintainer approval

Implementation remains blocked until the maintainer explicitly decides:

1. the public function name (the narrow `aggregate_attendance()` name is the
   current proposal; a generic engagement name would overstate the first input
   contract);
2. whether the initial release supports both course and session grain or only
   one;
3. the exact complementary-suppression algorithm and behavior when a safe
   result cannot be produced;
4. whether deterministic ordinal session labels are sufficient for the
   session-grain workflow; and
5. whether all six initial measures are necessary for the first installed
   workflow.

Approval of this document authorizes later bounded implementation planning; it
does not authorize code changes, a public export, a merge to `develop`, release
promotion, or external publication.
