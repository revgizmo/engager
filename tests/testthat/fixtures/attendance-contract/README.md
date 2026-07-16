# Synthetic attendance contract fixture

These tables are the normative T1 example for the 0.1.1 attendance contract.
All people, identifiers, dates, and session names are synthetic.

Parameters:

- threshold: `2 / 3` (inclusive)
- unmatched action: `warn`
- eligible roster rows: 5
- recorded sessions: 3
- cancelled sessions: 1

`observed-speakers.csv` is a contract-level input table, not a substitute for
the installed WebVTT fixture required by T3/T5. `expected-attendance.csv`,
`expected-participants.csv`, `expected-sessions.csv`, and
`expected-problems.csv` define the expected typed result. `invalid-cases.csv`
defines fail-fast conditions without storing invalid private data.
