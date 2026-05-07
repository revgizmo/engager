# Source Provenance

Generated: 2026-05-07

This file records how the backlog normalization artifacts were produced. It is intentionally concise so reviewers can reproduce the issue snapshot and validation without treating the generated manifest as authorization to mutate GitHub.

## GitHub Issue Snapshot

Source command:

```sh
gh issue list --repo revgizmo/engager --state open --limit 200 --json number,title,url,labels,milestone,assignees,createdAt,updatedAt
```

The `--limit 200` cap is intentionally above the 128-issue snapshot size. Before accepting a regenerated snapshot, confirm the repository still has fewer than 200 open issues; otherwise switch to a paginated `gh api` or GraphQL export so no issues are silently omitted.

Snapshot assumptions:

- Repository: `revgizmo/engager`
- Branch: `codex/backlog-normalization-control`
- Base branch: `main`
- Open issue count: 128
- Release evidence anchor: PR `#557` (`https://github.com/revgizmo/engager/pull/557`)

## Generated Artifacts

- `issue-normalization-register.csv`
- `github-mutation-plan.jsonl`
- `label-milestone-audit.md`
- `batch-review-log.md`
- `README.md`

## Validation

Run from the repository root:

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

Expected result:

```text
ok rows=128 jsonl=valid
```

## Mutation Boundary

No live issue mutations were performed while creating these artifacts. The JSONL file is a dry-run manifest and must be reviewed before any script or agent turns it into GitHub write operations.
