# `engager` 0.1.2 Attendance Aggregation Disclosure Contract

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
2. derive a fixed aggregate schema at an explicitly selected course or session
   grain;
3. apply deterministic cohort-wide group-size suppression before returning
   results;
4. return a versioned result built only from allowlisted primitive content;
   and
5. validate the returned object in installed-package UAT using bundled or newly
   generated synthetic fixtures.

Speaker-level transcript metrics are a candidate extension only after their
current free-text, participant-name, percentage-denominator, and provenance
semantics have a separately approved input contract. Arbitrary data frames are
not accepted by the initial workflow because column names alone cannot prove
that a field is approved for grouping or aggregation.

## Provisional interface

The public name remains provisional until the contract is approved. A working
shape for design and tests is:

```r
aggregate_attendance(
  x,
  grain,
  min_group_size
)
```

`grain` is caller-required and must be exactly `"course"` or `"session"`.
There is no default because the release grain materially changes the disclosed
table. The result schema is fixed; callers cannot select metrics.

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
- every scheduled session must use the same course-wide eligible-roster size
  required by `engager_attendance_v1`;
- missing, duplicate, or unexpected required fields are errors; and
- unsupported future schemas are errors rather than best-effort coercions.

The implementation must not accept a path, transcript object, raw roster, or
untyped data frame through `...` or an undocumented fallback.

## Allowed output grains

`grain` is an enum, not an arbitrary column list or expression.

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
is outside this candidate-for-sharing result. Ordinal labels provide only
within-result ordering: they are not stable identifiers across changed
schedules and do not prevent linkage when users release related tables.

## Allowed measures

The first attendance result uses a fixed schema. Callers cannot request,
remove, or add measures.

| Measure | Type | Course grain | Session grain | Definition |
|---|---|---:|---:|---|
| `eligible_participant_count` | integer | yes | yes | Count of roster rows eligible for attendance. |
| `eligible_session_count` | integer | yes | no | Count of successfully validated recorded sessions. |
| `attendance_count` | integer | yes | yes | Course: sum of present participant-session cells. Session: present participants. |
| `attendance_opportunity_count` | integer | yes | yes | Course: eligible participants multiplied by eligible recorded sessions. Session: eligible participants. |
| `attendance_rate` | double | yes | yes | `attendance_count / attendance_opportunity_count`. |

`absence_count` may be derived internally to validate totals, but it is not
returned because it is exactly reconstructible from the fixed numerator and
denominator. Unmatched-speaker counts and source problem counts remain in the
local sensitive attendance object and are not copied to this result. The output
must distinguish zero, missing, cancelled, suppressed, and not-applicable
values.

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

For `engager_attendance_v1`, the group size is the single course-wide eligible
roster size, not the number observed present. That denominator is the same for
the course row and every scheduled-session row. Equality with
`min_group_size` is released.

Suppression is therefore deterministic and all-or-none for the first schema:

- when `eligible_participant_count < min_group_size`, every numeric value in a
  course result or recorded-session row is set to `NA`;
- each affected row has `release_status = "suppressed"` and
  `suppression_reason = "minimum_group_size"`;
- the exact below-threshold roster size is not returned;
- cancelled sessions remain `"not_applicable"` rather than `"suppressed"`;
- when `eligible_participant_count >= min_group_size`, the numeric values are
  released for the course result or recorded sessions; and
- warnings and print methods report only the number of suppressed rows.

This all-or-none rule is the complementary-suppression algorithm for
`engager_attendance_v1`: no numeric course total or recorded-session sibling is
released when the shared denominator is below threshold. If a future source
schema permits varying session rosters, sections, or other nested groups, this
operation errors as unsupported until a revised contract defines and tests an
appropriate complementary-suppression rule.

The threshold is a group-size control. It does not suppress rare attendance
counts, zero attendance, full attendance, or values recognizable from outside
information. Those remain contextual disclosure risks requiring local review.
If a later release needs rare-outcome cell suppression, it requires a separate
`min_cell_count` contract; `min_group_size` must not be overloaded with that
different meaning.

The operation is stateless and cannot prevent differencing across releases
made with different thresholds, source rosters, schedule versions, or related
tables. Users must review the complete release family, not only one returned
object.

The initial API provides no suppression selector, `"none"` value, or override
mode. Callers who need unsuppressed local analysis use the existing sensitive
analysis object rather than a candidate-for-sharing aggregation result.

## Missingness, cancellation, and denominator rules

- Cancelled sessions remain visible with `release_status = "not_applicable"`;
  attendance measures are `NA`, and they do not enter course
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

The proposed result class is `engager_attendance_aggregation` with schema
version `engager_attendance_aggregation_v1`. It contains only `data` and
`metadata`.

### `data`

Every row has the requested allowed grain plus:

| Column | Type | Meaning |
|---|---|---|
| `grain` | character | `course` or `session`. |
| `session` | character | Session grain only: deterministic ordinal label; otherwise absent. |
| `release_status` | character | `released`, `suppressed`, or `not_applicable`. |
| `suppression_reason` | character | Stable code or `NA`; never a free-text explanation containing source values. |
| fixed measure columns | integer/double | Approved measures, set to `NA` when suppressed or not applicable. |

The table never contains participant-level rows, `student_id`, participant
names, aliases, pseudonyms, hashes, email, transcript text, comments, source
paths, input filenames, or arbitrary input columns. Attributes are part of the
same disclosure boundary and may not carry forbidden values.

### `metadata`

Contains only:

- aggregation schema version and package version;
- source class and source schema version;
- requested grain;
- caller-supplied minimum-group setting and the fixed suppression rule; and
- counts of released, suppressed, and not-applicable rows.

It does not contain paths, filenames, session labels, participant identifiers,
raw parameter objects, problems or messages copied from the source, run times,
salts, free-form caller notes, input fingerprints, or output checksums. Print
and summary methods reveal only aggregate counts and contract settings.

Input fingerprints and output checksums belong in a separate local-only
analysis-manifest contract. They are not copied into this
candidate-for-sharing result because stable fingerprints or checksums can
enable linkage across releases and do not prove disclosure safety.

## Error contract

Input and contract violations use a stable
`engager_attendance_aggregation_error` parent class plus a specific subclass.
Initial subclasses should cover:

- unsupported source class or schema;
- invalid grain selection;
- invalid minimum-group setting;
- inconsistent source denominators or types;
- forbidden source content in an output or attribute; and
- an unsupported suppression structure, including varying session rosters.

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
   course rosters;
5. cancelled sessions, zero attendance, all attendance, missing values, and
   source unmatched-speaker counts that must not be propagated;
6. course-versus-session reconstruction and repeated calls at both grains,
   proving the same all-or-none group-size decision;
7. repeated calls with different thresholds, rosters, or schedule versions,
   documenting the stateless differencing limitation;
8. unsupported future schemas, varying session rosters, malformed types,
   duplicate rows, and impossible denominators;
9. malicious session labels containing Markdown, path-like strings, or
   synthetic participant names; and
10. recursive scans of returned objects, data, attributes, printed and summary
    output, and machine-readable metadata for forbidden synthetic tokens.

Tests must prove absence from the complete returned object and its observable
representations; warnings about identifier-like column names are not sufficient
evidence.

## Installed-package UAT

The release UAT installs the built source tarball into a fresh library and uses
only bundled synthetic attendance fixtures. It must:

1. construct an `engager_attendance_v1` result through the public 0.1.1
   workflow;
2. create course- and session-grain aggregation results;
3. exercise released, suppressed, and cancelled rows;
4. verify the fixed schema, numerators, denominators, release states, and stable
   suppression codes; and
5. recursively scan the returned objects, attributes, printed output, and
   summaries for raw synthetic identifiers, names, aliases, transcript
   excerpts, source paths, hashes, and pseudonyms.

Writing, serialization, checksums, and manifest generation are outside this
aggregation tranche. No real course data or generated UAT output is committed.

## Delivery tranches and dependencies

The contract is intentionally smaller than the full candidate 0.1.2 roadmap.
Implementation should proceed only after 0.1.1 ships, fresh-user feedback is
reviewed, and the maintainer approves this specification.

1. **A0 — Contract approval:** after 0.1.1 ships and fresh-user feedback is
   reviewed, approve or revise the name, supported grains, fixed schema,
   caller-selected threshold, and all-or-none suppression rule.
2. **A1 — Internal engine and disclosure contract:** validate
   `engager_attendance_v1`, compute the fixed schema, apply suppression, add
   stable errors and adversarial object scanners, and fail closed; no export.
3. **A2 — Public workflow:** approve the final name, add the reviewed export and
   documentation, and pass installed-tarball result-object UAT.
4. **A3 — 0.1.2 release candidate:** reconcile other separately accepted 0.1.2
   tranches, run release gates, and obtain explicit approval for promotion.

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
- File writers, serialization formats, shareable-result checksums, Excel
  output, charts, performance optimization, or additional input formats.
- A rare-outcome or institutional cell-size policy hidden inside
  `min_group_size`.
- Implementing issues #341, #381, or #438 within this contract tranche.

## Open decisions requiring maintainer approval

Implementation remains blocked until the maintainer explicitly decides:

1. the public function name (the narrow `aggregate_attendance()` name is the
   current proposal; a generic engagement name would overstate the first input
   contract);
2. whether the initial release supports both course and session grain through
   the required `grain` argument, as proposed, or narrows to one;
3. whether the schema-specific all-or-none group-size rule is sufficient and
   unsupported varying-roster structures must error, as proposed;
4. whether deterministic ordinal session labels are sufficient for within-
   result ordering given the documented cross-release linkage limitation;
5. whether the fixed five-measure schema and denominator definitions are the
   minimum necessary first-release output; and
6. whether `min_group_size` remains caller-required with no package default, as
   proposed.

Approval of this document authorizes later bounded implementation planning; it
does not authorize code changes, a public export, a merge to `develop`, release
promotion, or external publication.
