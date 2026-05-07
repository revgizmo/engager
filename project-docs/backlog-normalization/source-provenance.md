# Source Provenance

Generated: 2026-05-07

This file records how the backlog normalization artifacts were produced. It is intentionally concise so reviewers can reproduce the issue snapshot and validation without treating the generated manifest as authorization to mutate GitHub.

## GitHub Issue Snapshot

Source command:

```sh
gh issue list --state open --limit 200 --json number,title,url,labels,milestone,assignees,createdAt,updatedAt
```

Snapshot assumptions:

- Repository: `revgizmo/engager`
- Branch: `codex/backlog-normalization-control`
- Base branch: `main`
- Open issue count: 128
- Release evidence anchor: PR `#557`

## Generated Artifacts

- `issue-normalization-register.csv`
- `github-mutation-plan.jsonl`
- `label-milestone-audit.md`
- `batch-review-log.md`
- `README.md`

## Validation

Run from the repository root:

```sh
ruby -rcsv -rjson -e 'required=%w[number title url current_labels proposed_labels current_milestone proposed_milestone lane proposed_status proposed_action confidence evidence_summary canonical_issue_or_pr updated_at]; rows=CSV.read("project-docs/backlog-normalization/issue-normalization-register.csv", headers:true); abort("bad count") unless rows.length==128; abort("duplicate issues") unless rows["number"].uniq.length==rows.length; missing=required-rows.headers; abort("missing columns: #{missing.join(",")}") unless missing.empty?; rows.each{|r| abort("missing canonical for ##{r["number"]}") if r["proposed_action"]=="supersede-candidate" && r["canonical_issue_or_pr"].to_s.empty?}; File.foreach("project-docs/backlog-normalization/github-mutation-plan.jsonl"){|line| JSON.parse(line)}; puts "ok rows=#{rows.length} jsonl=valid"'
```

Expected result:

```text
ok rows=128 jsonl=valid
```

## Mutation Boundary

No live issue mutations were performed while creating these artifacts. The JSONL file is a dry-run manifest and must be reviewed before any script or agent turns it into GitHub write operations.
