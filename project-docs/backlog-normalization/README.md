# Backlog Normalization

Generated: 2026-05-07

This directory is the control surface for normalizing the open `engager` GitHub issue backlog before any live issue mutations. The current implementation intentionally creates reviewable artifacts only; it does not edit GitHub issues, labels, milestones, or comments.

## Source Provenance

- Source command: `gh issue list --repo revgizmo/engager --state open --limit 200 --json number,title,url,labels,milestone,assignees,createdAt,updatedAt`
- Snapshot date: 2026-05-07
- Repository state: branch `codex/backlog-normalization-control`, based on `main` after PR `#557` (`https://github.com/revgizmo/engager/pull/557`)
- Issue count at snapshot: 128 open issues
- Release evidence assumption: PR `#557` (`https://github.com/revgizmo/engager/pull/557`) is treated as the canonical release-prep integration point until contradicted by fresh validation.

## Goals

- Represent every open issue exactly once.
- Separate CRAN gate decisions from broad backlog cleanup.
- Normalize labels, milestones, lanes, and statuses without losing issue history.
- Produce a dry-run mutation manifest that can be reviewed before any GitHub writes.
- Keep closure and supersession decisions human-gated.

## Files

- `issue-normalization-register.csv`: the canonical issue-by-issue classification register.
- `github-mutation-plan.jsonl`: proposed GitHub issue edits in dry-run form.
- `label-milestone-audit.md`: current label/milestone state and proposed canonical taxonomy.
- `batch-review-log.md`: gate checklist and batch-level review status.

## Agent Model Routing

Use explicit model settings for all future subagents:

| Work | Model | Reasoning |
|---|---|---|
| Issue scouts and metadata extraction | `gpt-5.3-codex-spark` | low |
| First-pass classification | `gpt-5.3-codex-spark` | medium |
| Domain curation | `gpt-5.3-codex` | medium/high |
| Orchestration, dedupe, final review | `gpt-5.5` | high |

Every subagent prompt must include: `Read-only; do not edit files; do not mutate GitHub.`

## Lanes

- `cran`: release control, CRAN submission, external validation, CRAN blockers.
- `docs`: README, pkgdown, reference, vignettes, tutorials, roxygen documentation.
- `core`: product/API behavior, transcript processing, roster behavior, file handling.
- `testing`: tests, fixtures, QA process, coverage, diagnostic warning handling.
- `privacy`: privacy defaults, FERPA-oriented docs, masking, anonymization, audit behavior.
- `performance`: benchmarks, thresholds, large-file runtime and memory optimization.
- `infrastructure`: CI, scripts, Docker, development tooling, automation.
- `archive`: stale, superseded, or low-evidence items requiring human review before closure.

## Mutation Safety

The manifest uses exactly these `safety_class` tokens:

| Token | Meaning |
|---|---|
| `safe-after-pr-approval` | Comment-only rows after this PR and the dry-run manifest are approved. |
| `review-required` | Metadata updates, milestone changes, status changes, blocked/in-progress status changes, body edits, or priority changes. |
| `human-only` | Closure, supersession, duplicate marking, label deletion, or any other irreversible/noisy operation. |

Each JSONL row also has `proposed_actions`, an explicit ordered list of operations. A row with `proposed_action: "comment"` must have `proposed_actions: ["comment"]`; any labels, milestone, or status on those rows are context for reviewers, not authorization to apply metadata changes.

`proposed_action` is the executor-facing primary operation. Human workflow intent such as keeping a release gate active is represented separately in `proposed_disposition`, for example `keep-active`, so scripts do not confuse "keep this issue open" with "perform no mutation."

The current manifest does not authorize live writes. It is a dry-run proposal for review.

Do not pipe `github-mutation-plan.jsonl` into any GitHub write script directly. A later mutation pass must first generate exact operations from this manifest, run a dry-run comparison against current issue state, and receive explicit approval.

## CRAN Gate Policy

Pre-CRAN work stays narrow:

- `#4`: release umbrella until CRAN submission is complete.
- `#153`: real-world FERPA/privacy validation.
- `#154`: institutional adoption guide, unless explicitly deferred.

Likely stale or superseded by PR `#557` (`https://github.com/revgizmo/engager/pull/557`) unless fresh evidence contradicts it:

- `#215`, `#220`, `#228`, `#229`, `#277`, `#282`, `#300`, `#301`, `#394`, `#469`, `#471`.
- `#288`, `#296`, `#297` are optional external validation unless required by the release owner.
- `#395` and `#397` are post-CRAN follow-up, not active release blockers.

## Review Process

1. Review Batch 0 in `batch-review-log.md` and validate the schema.
2. Review each 15-issue batch for invented scope, missing issue IDs, priority inflation, and unsafe closure.
3. Review duplicate and superseded candidates globally.
4. Approve the Backlog Normalization PR.
5. Review `github-mutation-plan.jsonl` as a dry-run manifest.
6. Execute only approved safe mutations in small batches.
7. Stop after the first mutation batch for human review.

## Validation Commands

```sh
ruby -rcsv -rjson -e '
required = %w[number title url current_labels proposed_labels current_milestone proposed_milestone lane proposed_status proposed_action proposed_disposition confidence evidence_summary canonical_issue_or_pr updated_at]
rows = CSV.read("project-docs/backlog-normalization/issue-normalization-register.csv", headers: true)
abort("bad count") unless rows.length == 128
abort("duplicate CSV issues") unless rows["number"].uniq.length == rows.length
missing = required - rows.headers
abort("missing columns: #{missing.join(",")}") unless missing.empty?

json = File.readlines("project-docs/backlog-normalization/github-mutation-plan.jsonl").map { |line| JSON.parse(line) }
abort("bad JSONL count") unless json.length == rows.length
json_issues = json.map { |j| j["issue"] }
csv_issues = rows["number"].map(&:to_i)
abort("duplicate JSONL issues") unless json_issues.uniq.length == json_issues.length
abort("CSV/JSONL issue mismatch") unless csv_issues.sort == json_issues.sort

rows.each do |r|
  abort("missing canonical for ##{r["number"]}") if r["proposed_action"] == "supersede-candidate" && r["canonical_issue_or_pr"].to_s.empty?
end

allowed = %w[safe-after-pr-approval review-required human-only]
json.each do |j|
  abort("manifest row is not dry-run for ##{j["issue"]}") unless j["dry_run"] == true
  abort("unknown safety_class #{j["safety_class"]}") unless allowed.include?(j["safety_class"])
  abort("comment row has extra actions for ##{j["issue"]}") if j["proposed_action"] == "comment" && j["proposed_actions"] != ["comment"]
  abort("non-comment row marked safe for ##{j["issue"]}") if j["safety_class"] == "safe-after-pr-approval" && j["proposed_actions"] != ["comment"]
  abort("keep action leaked into manifest") if j["proposed_action"] == "keep"
end

puts "ok rows=#{rows.length} jsonl=valid"
'
```
