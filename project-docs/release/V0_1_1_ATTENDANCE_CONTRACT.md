# `engager` 0.1.1 Attendance Contract

Status: proposed T1 contract; maintainer authorization is required before T2
or T3 implementation treats it as approved.

This contract governs the planned public
`analyze_multi_session_attendance()` and `generate_attendance_report()`
workflow. It replaces the retained internal prototype's behavior; historical
behavior is not compatibility authority because these functions were not
exported in 0.1.0.

## User job and boundary

Given a course roster and at least two recorded WebVTT sessions, determine which
roster participants appeared in each session by exact name matching, preserve
unmatched and cancelled-session uncertainty, and produce a reviewable aggregate
report without raw participant identifiers or transcript text by default.

Version 0.1.1 does not infer attendance from duration, word count, camera use,
chat activity, or pedagogical judgment. It does not perform fuzzy matching,
claim anonymity or compliance, produce longitudinal student profiles, or
silently discard failed sessions.

## Proposed analysis interface

```r
analyze_multi_session_attendance(
  sessions,
  roster_data,
  unmatched_names_action = c("warn", "stop"),
  min_attendance_threshold = 0.5
)
```

`sessions` accepts either:

1. A character vector of WebVTT paths. Non-empty names, when supplied, are
   explicit session identifiers. Otherwise T2 derives stable identifiers and
   timestamps from filenames. Every entry is a recorded session.
2. A data frame with one row per scheduled session and these columns:
   - `session_id`: unique, non-empty character identifier;
   - `transcript_file`: a WebVTT path for `recorded` rows and `NA` for
     `cancelled` rows;
   - `status`: exactly `recorded` or `cancelled`;
   - `session_at`: optional timestamp. Unknown values remain `NA`.

Known timestamps sort chronologically. Unknown timestamps sort after known
timestamps by `session_id`. Input order never determines the result. Duplicate
session identifiers or duplicate normalized file paths are errors.

The development version requires at least two `recorded` sessions after
validating explicit cancellations. This is a multi-session contract, not a
single-session wrapper.

## Roster authority

The roster, not the set of observed speakers, defines the attendance universe.
Required columns are:

- `student_id`: unique, non-missing, non-blank character identifier;
- `preferred_name`: non-missing, non-blank character name used by the exact
  matching path.

Optional columns are:

- `aliases`: semicolon-delimited exact-name aliases using the existing
  normalization rules;
- `eligible`: logical, defaulting to `TRUE` when absent.

Every `eligible = TRUE` row appears in the participant summary, including
people with zero observed attendance. An `eligible = FALSE` row represents a
known nonparticipant such as an instructor: it may match a speaker, but it is
excluded from attendance rows, denominators, and unmatched counts. The package
does not infer eligibility from `role`, names, email domains, or other fields.
At least one roster row must be eligible; an all-ineligible roster is an input
error rather than a result with an undefined `0 / 0` session rate.

Duplicate identifiers and name/alias collisions are errors. Blank identifiers
or names are errors. Exact normalization may remove case and accent differences
as already documented by the name-matching API, but it never selects among
ambiguous roster rows.

## Attendance and denominator semantics

- A roster participant is `present` for a recorded session when at least one
  transcript cue matches that participant exactly. Additional cues do not
  increase attendance.
- An eligible roster participant with no exact match is `absent` for that
  recorded session.
- A cancelled session has `present = NA` for every participant and is excluded
  from all eligible-session denominators.
- `eligible_sessions` is the number of successfully validated recorded
  sessions. Missing, unreadable, or invalid recorded inputs abort the analysis;
  therefore a failed input can never shrink a returned denominator.
- Participant `attendance_rate` is `sessions_attended / eligible_sessions` and
  is stored as a proportion from 0 through 1. Formatting as a percentage is a
  report concern.
- Session `attendance_rate` is `attended_count / eligible_roster_size`.
- `meets_threshold` uses `attendance_rate >= min_attendance_threshold`.
  Equality is included. Threshold must be one finite numeric scalar in `[0, 1]`.
- `is_one_time_attendee` means exactly one recorded session attended. It is
  independent of threshold status.

No `occasional`, `consistent`, or risk category is stored as a normative label.
The result carries counts, rates, and the caller-selected threshold so users can
review the evidence without a package-authored judgment about a student.

## Unmatched and failed-input policy

Observed speakers that do not map exactly to any roster row never become
participants and never change attendance denominators.

- `unmatched_names_action = "warn"` is the default. The analysis returns one
  non-identifying warning summary and records a per-session problem count.
- `unmatched_names_action = "stop"` aborts with class
  `engager_unmatched_error` after matching, before returning attendance output.
- No ignore mode is supported in 0.1.1.

Warnings, errors, and the default `problems` table contain counts and stable
problem codes, not speaker names, raw transcript text, name hashes, email
addresses, or source paths. A user who needs local name review uses the existing
`detect_unmatched_names()` or `match_names_workflow()` flow separately.

Missing files, unreadable files, invalid WebVTT, duplicate sessions, schema
errors, and ambiguous roster matches are fail-fast errors. A permissive
partial-result mode is excluded from 0.1.1 because its denominator and retry
contract is not yet justified.

## Result contract

The analysis returns an object of class `engager_attendance` with schema version
`engager_attendance_v1`. Its print and summary methods reveal aggregate counts
only.

### `attendance`

One row per eligible roster participant per scheduled session:

| Column | Type | Meaning |
|---|---|---|
| `student_id` | character | Roster identifier; sensitive local analysis data |
| `session_id` | character | Stable session identifier |
| `status` | character | `recorded` or `cancelled` |
| `present` | logical | `TRUE`/`FALSE` for recorded; `NA` for cancelled |

### `participant_summary`

| Column | Type | Meaning |
|---|---|---|
| `student_id` | character | Roster identifier; sensitive local analysis data |
| `eligible_sessions` | integer | Recorded-session denominator |
| `sessions_attended` | integer | Recorded sessions present |
| `attendance_rate` | double | Proportion from 0 through 1 |
| `meets_threshold` | logical | Inclusive comparison with the stored threshold |
| `is_one_time_attendee` | logical | Exactly one session attended |

### `session_summary`

| Column | Type | Meaning |
|---|---|---|
| `session_id` | character | Stable session identifier |
| `status` | character | `recorded` or `cancelled` |
| `eligible` | logical | Whether the session enters denominators |
| `roster_size` | integer | Count of eligible roster rows |
| `attended_count` | integer | Present count; `NA` when cancelled |
| `absent_count` | integer | Absent count; `NA` when cancelled |
| `unmatched_speaker_count` | integer | Unique unmatched speaker count |
| `attendance_rate` | double | Proportion; `NA` when cancelled |

### `problems`

Zero or more rows with `session_id`, `code`, `severity`, `count`, and a
non-identifying `message`. Initial stable codes are `unmatched_speaker` and
`unknown_session_time`. Fatal input conditions are errors rather than rows in a
partial result.

### `metadata`

Contains `schema_version`, package version, caller threshold, unmatched action,
eligible roster/session counts, and non-identifying input fingerprints. It does
not contain file paths or names. Run time, when recorded, is metadata and is not
embedded in deterministic report content.

The analysis object contains roster identifiers and is local sensitive data. It
is not a shareable report.

## Report contract

```r
generate_attendance_report(
  analysis_results,
  output_file = NULL,
  detail = c("aggregate", "participant"),
  identifier_method = NULL,
  salt = NULL
)
```

- `detail = "aggregate"` is the default and contains only course/session counts,
  rates, threshold context, and non-identifying problem counts.
- Aggregate output contains no `student_id`, roster/transcript name, name hash,
  transcript text, email, or input path.
- `detail = "participant"` is explicit opt-in and requires one supported
  technical transformation: `mask`, `hash`, or `pseudonymize`. Raw/untransformed
  participant detail is not a supported report mode in 0.1.1. Hash mode requires
  an explicit non-empty salt.
- The report propagates the analysis threshold; it never substitutes `0.5`.
- Report content is deterministic by default. A generated timestamp, if later
  exposed, is isolated in metadata rather than inserted into content under test.
- `include_charts` is removed from the prototype contract. Chart behavior and
  Excel-specific output are outside 0.1.1.

Masking, hashing, pseudonymization, and aggregate reporting are technical
privacy-supporting operations, not guarantees of anonymity, FERPA compliance,
or institutional approval. Small cohorts and contextual disclosure remain user
review responsibilities and must be documented in T4/T5.

## Golden fixture

The synthetic tables under
`tests/testthat/fixtures/attendance-contract/` are normative examples for this
contract. At threshold `2 / 3`, they prove:

- full, boundary-equal, one-time, and zero attendance;
- a known ineligible instructor who does not affect counts;
- an unknown guest recorded as one unmatched problem;
- a cancelled session excluded from denominators;
- stable participant, session, attendance, and problem schemas; and
- explicit invalid-input cases, including blank identifiers.

T2 and T3 may add WebVTT fixtures but must not change these expected tables
without a separately authorized contract revision.

## Approval gate

Maintainer authorization of this contract approves the semantics, not the later
public export or release. T2 may implement session identity and T3 may implement
the engine only after that authorization is recorded on the T1 pull request or
issue #576. T4 privacy/report behavior, T5 exports, and T6 release promotion
retain their own gates.
